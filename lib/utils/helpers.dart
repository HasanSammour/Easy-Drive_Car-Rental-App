import 'package:intl/intl.dart';

class Helpers {
  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
  }

  static int calculateDaysDifference(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  static double calculateTotalPrice(
    double pricePerDay,
    DateTime start,
    DateTime end,
  ) {
    final days = calculateDaysDifference(start, end);
    return pricePerDay * days;
  }

  static bool isDateRangeValid(DateTime start, DateTime end) {
    return end.isAfter(start);
  }

  static String getInitials(String name) {
    final names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return '';
  }
}
