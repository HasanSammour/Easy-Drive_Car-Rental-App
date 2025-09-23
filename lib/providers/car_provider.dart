// providers/car_provider.dart
import 'package:flutter/foundation.dart';
import 'package:easydrive/services/database_service.dart';
import 'package:easydrive/models/car_model.dart';

class CarProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<CarModel> _cars = [];
  List<CarModel> _filteredCars = [];
  bool _isLoading = false;
  String? _error;

  List<CarModel> get cars => _filteredCars;
  List<CarModel> get allCars => _cars;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CarProvider() {
    print('CarProvider initialized');
    loadCars();
  }

  Future<void> loadCars() async {
    print('Loading cars...');
    _isLoading = true;
    _error = null;
    notifyListeners();
  
    // Temporary sample data for testing
    await Future.delayed(const Duration(seconds: 2));
    
    _cars = [
      CarModel(
        id: 'sample-1',
        model: 'Camry',
        brand: 'Toyota',
        type: 'Sedan',
        pricePerDay: 45.0,
        description: 'A reliable family sedan',
        features: ['GPS', 'Air Conditioning', 'Bluetooth'],
        imageUrls: ['https://via.placeholder.com/300x200?text=Toyota+Camry'],
        isAvailable: true,
        status: 'Available',
      ),
      CarModel(
        id: 'sample-2',
        model: 'Civic',
        brand: 'Honda', 
        type: 'Sedan',
        pricePerDay: 40.0,
        description: 'Fuel-efficient compact car',
        features: ['GPS', 'Backup Camera'],
        imageUrls: ['https://via.placeholder.com/300x200?text=Honda+Civic'],
        isAvailable: true,
        status: 'Available',
      ),
    ];
    
    _filteredCars = _cars;
    _isLoading = false;
    notifyListeners();
  
    // Continue with actual Firestore query
    try {
      _databaseService.getCars().listen((cars) {
        if (cars.isNotEmpty && cars.any((car) => car.id != 'sample-1' && car.id != 'sample-2')) {
          print('Real cars loaded from Firestore: ${cars.length}');
          _cars = cars;
          _filteredCars = cars;
          _isLoading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      print('Firestore error, keeping sample data: $e');
    }
  }
  Future<void> filterCars({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? carTypes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _databaseService
          .getAvailableCars(
            startDate: startDate,
            endDate: endDate,
            carTypes: carTypes,
          )
          .listen((cars) {
            _filteredCars = cars;
            _isLoading = false;
            notifyListeners();
          });
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearFilters() {
    _filteredCars = _cars;
    notifyListeners();
  }

  CarModel? getCarById(String carId) {
    try {
      return _cars.firstWhere((car) => car.id == carId);
    } catch (e) {
      return null;
    }
  }
}