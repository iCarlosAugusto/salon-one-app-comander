/// Operating hours for a specific day of the week
class OperatingHour {
  /// Day of the week (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
  final int dayOfWeek;

  /// Start time in HH:mm format (24-hour)
  final String startTime;

  /// End time in HH:mm format (24-hour)
  final String endTime;

  /// Whether the business is open on this day
  final bool isOpen;

  const OperatingHour({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isOpen = true,
  });

  factory OperatingHour.fromJson(Map<String, dynamic> json) {
    return OperatingHour(
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isOpen: json['isOpen'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'dayOfWeek': dayOfWeek, 'startTime': startTime, 'endTime': endTime};
  }

  OperatingHour copyWith({
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isOpen,
  }) {
    return OperatingHour(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  /// Get the localized day name
  String get dayName {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return days[dayOfWeek];
  }

  /// Get abbreviated day name
  String get dayNameShort {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[dayOfWeek];
  }

  /// Create default operating hours for all days (08:00-18:00)
  static List<OperatingHour> defaultHours() {
    return List.generate(
      7,
      (index) => OperatingHour(
        dayOfWeek: index,
        startTime: '08:00',
        endTime: '18:00',
        isOpen: index != 0, // Closed on Sunday by default
      ),
    );
  }

  @override
  String toString() =>
      'OperatingHour(day: $dayOfWeek, $startTime - $endTime, open: $isOpen)';
}
