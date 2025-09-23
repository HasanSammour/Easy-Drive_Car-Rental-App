import 'package:flutter/foundation.dart';
import 'package:easydrive/services/database_service.dart';
import 'package:easydrive/models/booking_model.dart';

class BookingProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _databaseService.getUserBookings(userId).listen((bookings) {
        _bookings = bookings;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createBooking(BookingModel booking) async {
    try {
      await _databaseService.createBooking(booking);
      _bookings.add(booking);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
