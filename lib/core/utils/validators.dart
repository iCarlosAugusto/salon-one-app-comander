/// Utility class for input validation
class Validators {
  Validators._();

  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : 'This field is required';
    }
    return null;
  }

  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 11) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate price/currency
  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final numValue = double.tryParse(value.replaceAll(',', '.'));
    if (numValue == null) {
      return 'Please enter a valid price';
    }
    if (numValue < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }

  /// Validate duration in minutes
  static String? duration(String? value) {
    if (value == null || value.isEmpty) {
      return 'Duration is required';
    }
    final numValue = int.tryParse(value);
    if (numValue == null) {
      return 'Please enter a valid duration';
    }
    if (numValue < 1) {
      return 'Duration must be at least 1 minute';
    }
    if (numValue > 480) {
      return 'Duration cannot exceed 8 hours';
    }
    return null;
  }

  /// Validate time format (HH:mm)
  static String? time(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time is required';
    }
    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return 'Please enter a valid time (HH:mm)';
    }
    return null;
  }

  /// Validate date format (yyyy-MM-dd)
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    try {
      DateTime.parse(value);
      return null;
    } catch (_) {
      return 'Please enter a valid date';
    }
  }

  /// Validate minimum length
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.length < minLength) {
      return fieldName != null
          ? '$fieldName must be at least $minLength characters'
          : 'Must be at least $minLength characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return fieldName != null
          ? '$fieldName must be at most $maxLength characters'
          : 'Must be at most $maxLength characters';
    }
    return null;
  }

  /// Combine multiple validators
  static String? combine(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
