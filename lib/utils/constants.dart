class AppConstants {
  // Firebase collections
  static const String usersCollection = 'users';
  static const String carsCollection = 'cars';
  static const String bookingsCollection = 'bookings';
  static const String chatsCollection = 'chats';

  // Car types
  static const List<String> carTypes = [
    'Sedan',
    'SUV',
    'Hatchback',
    'Convertible',
    'Coupe',
    'Minivan',
    'Pickup Truck',
    'Luxury',
  ];

  // Car statuses
  static const String carStatusAvailable = 'Available';
  static const String carStatusBooked = 'Booked';
  static const String carStatusMaintenance = 'Maintenance';

  // Booking statuses
  static const String bookingStatusPending = 'Pending';
  static const String bookingStatusConfirmed = 'Confirmed';
  static const String bookingStatusCompleted = 'Completed';
  static const String bookingStatusCancelled = 'Cancelled';
}
