class BookingModel {
  final String id;
  final String userId;
  final String carId;
  final String carModel;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status; // Pending, Confirmed, Completed, Cancelled, Payment_Pending
  final DateTime createdAt;
  final double? rating;
  final String? review;
  final bool isPaid; // New field for payment status
  final DateTime? paymentDate; // New field for payment timestamp
  final String? paymentMethod; // New field for payment method

  BookingModel({
    required this.id,
    required this.userId,
    required this.carId,
    required this.carModel,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.rating,
    this.review,
    this.isPaid = false, // Default to false
    this.paymentDate,
    this.paymentMethod,
  });

  int get durationInDays => endDate.difference(startDate).inDays;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'carId': carId,
      'carModel': carModel,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'rating': rating,
      'review': review,
      'isPaid': isPaid, // Include payment fields
      'paymentDate': paymentDate?.millisecondsSinceEpoch,
      'paymentMethod': paymentMethod,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      carId: map['carId'] ?? '',
      carModel: map['carModel'] ?? '',
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'Pending',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      rating: map['rating']?.toDouble(),
      review: map['review'],
      isPaid: map['isPaid'] ?? false, // Handle payment fields
      paymentDate: map['paymentDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['paymentDate'])
          : null,
      paymentMethod: map['paymentMethod'],
    );
  }
}