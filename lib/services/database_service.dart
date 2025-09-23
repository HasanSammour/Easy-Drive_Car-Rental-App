import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easydrive/models/car_model.dart';
import 'package:easydrive/models/booking_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cars Collection
  CollectionReference get cars => _firestore.collection('cars');

  // Bookings Collection
  CollectionReference get bookings => _firestore.collection('bookings');

  // Users Collection
  CollectionReference get users => _firestore.collection('users');

  // Get all cars
  Stream<List<CarModel>> getCars() {
    print('Executing Firestore query for cars...');
    return _firestore
        .collection('cars')
        .snapshots()
        .handleError((error) {
          print('Firestore error: $error');
          throw error;
        })
        .asyncMap((snapshot) async {
          print('Firestore snapshot received: ${snapshot.docs.length} documents');
          // Check if collection exists and has documents
          if (snapshot.docs.isEmpty) {
            print('⚠️  No cars found in Firestore collection');
            print('⚠️  Please add cars to the "cars" collection in Firebase Console');
            return [];
          }
          final cars = snapshot.docs.map((doc) {
            print('Processing document: ${doc.id}');
            print('Document data: ${doc.data()}');
            try {
              final car = CarModel.fromMap(doc.data(), id: doc.id);
              print('✅ Successfully created CarModel: ${car.brand} ${car.model}');
              return car;
            } catch (e) {
              print('❌ Error creating CarModel from document ${doc.id}: $e');
              return null;
            }
          }).where((car) => car != null).cast<CarModel>().toList();
          print('✅ Successfully processed ${cars.length} cars');
          return cars;
        });
  }

  Future<void> addSampleCars() async {
    try {
      final sampleCars = [
        {
          'brand': 'Honda',
          'model': 'CR-V',
          'type': 'SUV',
          'pricePerDay': 55.0,
          'description': 'Spacious SUV perfect for families',
          'features': ['GPS', 'Sunroof', 'Leather Seats', 'Apple CarPlay'],
          'imageUrls': ['https://images.unsplash.com/photo-1553440569-bcc63803a83d?w=400'],
          'isAvailable': true,
          'status': 'Available',
          'averageRating': 4.3,
          'totalReviews': 8,
        },
        {
          'brand': 'BMW',
          'model': 'X5',
          'type': 'Luxury SUV',
          'pricePerDay': 85.0,
          'description': 'Luxury SUV with premium features',
          'features': ['Premium Sound', 'Panoramic Sunroof', 'Heated Seats', 'Navigation'],
          'imageUrls': ['https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400'],
          'isAvailable': true,
          'status': 'Available',
          'averageRating': 4.7,
          'totalReviews': 15,
        },
      ];

      for (final carData in sampleCars) {
        await _firestore.collection('cars').add(carData);
      }

      print('✅ Sample cars added successfully');
    } catch (e) {
      print('❌ Error adding sample cars: $e');
    }
  }


  Stream<List<CarModel>> getAvailableCars({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? carTypes,
  }) {
    Query query = _firestore
        .collection('cars')
        .where('isAvailable', isEqualTo: true);

    if (carTypes != null && carTypes.isNotEmpty) {
      query = query.where('type', whereIn: carTypes);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => CarModel.fromMap(
              doc.data() as Map<String, dynamic>,
              id: doc.id,
            ),
          )
          .toList(),
    );
  }

  Future<void> addCar(CarModel car) async {
    await _firestore.collection('cars').add(car.toMap());
  }

  Future<void> updateCar(String carId, Map<String, dynamic> data) async {
    await _firestore.collection('cars').doc(carId).update(data);
  }

  Future<void> deleteCar(String carId) async {
    await _firestore.collection('cars').doc(carId).delete();
  }

  // Check if a car is available for specific dates
  Future<bool> isCarAvailableForDates(
    String carId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    QuerySnapshot conflictingBookings = await bookings
        .where('carId', isEqualTo: carId)
        .where('status', whereIn: ['Confirmed', 'Pending'])
        .get();

    for (var doc in conflictingBookings.docs) {
      BookingModel booking = BookingModel.fromMap(
        doc.data() as Map<String, dynamic>,
      );

      // Check for date overlap
      if (startDate.isBefore(booking.endDate) &&
          endDate.isAfter(booking.startDate)) {
        return false;
      }
    }

    return true;
  }

  // Create a new booking
  Future<void> createBooking(BookingModel booking) async {
    await bookings.doc(booking.id).set(booking.toMap());
  }

  // Get user bookings
  Stream<List<BookingModel>> getUserBookings(String userId) {
    return bookings
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    BookingModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();
        });
  }

  // Update car status
  Future<void> updateCarStatus(String carId, String status) async {
    bool isAvailable = status == 'Available';
    await cars.doc(carId).update({
      'status': status,
      'isAvailable': isAvailable,
    });
  }

  // Get revenue report
  Future<Map<String, dynamic>> getRevenueReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Use a simpler query that doesn't require complex indexing
    QuerySnapshot allCompletedBookings = await bookings
        .where('status', isEqualTo: 'Completed')
        .get();

    // Filter manually on client side
    List<BookingModel> filteredBookings = allCompletedBookings.docs
        .map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>))
        .where(
          (booking) =>
              booking.endDate.isAfter(startDate) &&
              booking.endDate.isBefore(
                endDate.add(const Duration(days: 1)),
              ), // Include end date
        )
        .toList();

    double totalRevenue = 0;
    int totalBookings = filteredBookings.length;
    Map<String, int> carRentalCount = {};

    for (var booking in filteredBookings) {
      totalRevenue += booking.totalPrice;

      // Count rentals per car
      carRentalCount[booking.carModel] =
          (carRentalCount[booking.carModel] ?? 0) + 1;
    }

    // Find most rented car
    String mostRentedCar = '';
    int maxRentals = 0;
    carRentalCount.forEach((car, count) {
      if (count > maxRentals) {
        maxRentals = count;
        mostRentedCar = car;
      }
    });

    return {
      'totalRevenue': totalRevenue,
      'totalBookings': totalBookings,
      'mostRentedCar': mostRentedCar,
      'mostRentedCount': maxRentals,
    };
  }
}
