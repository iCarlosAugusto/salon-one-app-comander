import 'package:intl/intl.dart';

/// Utility class for formatting values
class Formatters {
  Formatters._();

  // Date formatters
  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _displayDateFormat = DateFormat('dd MMM yyyy');
  static final _displayDateTimeFormat = DateFormat('dd MMM yyyy HH:mm');
  static final _timeFormat = DateFormat('HH:mm');
  static final _dayOfWeekFormat = DateFormat('EEEE');
  static final _fullDateFormat = DateFormat('EEEE, d MMMM yyyy');

  /// Format date for API (yyyy-MM-dd)
  static String formatDateForApi(DateTime date) => _dateFormat.format(date);

  /// Format date for display (dd MMM yyyy)
  static String formatDate(DateTime date) => _displayDateFormat.format(date);

  /// Format date with full day name (Monday, 1 January 2024)
  static String formatDateFull(DateTime date) => _fullDateFormat.format(date);

  /// Format date and time for display
  static String formatDateTime(DateTime dateTime) =>
      _displayDateTimeFormat.format(dateTime);

  /// Format time (HH:mm)
  static String formatTime(DateTime time) => _timeFormat.format(time);

  /// Format time string (HH:mm:ss -> HH:mm)
  static String formatTimeString(String timeString) {
    final parts = timeString.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return timeString;
  }

  /// Get day of week name
  static String getDayOfWeek(DateTime date) => _dayOfWeekFormat.format(date);

  /// Format relative date (Yesterday, Tomorrow, or date)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 0 && difference <= 7) return 'In $difference days';
    if (difference < 0 && difference >= -7) return '${-difference} days ago';

    return formatDate(date);
  }

  /// Get day of week name from index (0 = Sunday)
  static String getDayOfWeekFromIndex(int index) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return days[index % 7];
  }

  /// Format currency
  static String formatCurrency(double amount, {String currency = 'BRL'}) {
    final format = NumberFormat.currency(
      locale: currency == 'BRL' ? 'pt_BR' : 'en_US',
      symbol: currency == 'BRL' ? 'R\$' : '\$',
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  /// Format duration in minutes to readable string
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}min';
  }

  /// Format phone number
  static String formatPhone(String phone) {
    // Remove non-digits
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    // Brazilian phone format
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    } else if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    }

    return phone;
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Get initials from name
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Format status for display
  static String formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => capitalize(word))
        .join(' ');
  }
}
