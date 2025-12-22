/// Model for a service item within an appointment
///
/// Used when fetching services for a specific appointment from
/// GET /appointments/:id (returns list of services with employee info)
class AppointmentServiceItem {
  final String id;
  final String name;
  final double price;
  final int duration;
  final String startTime;
  final String endTime;
  final AppointmentServiceEmployee? employee;

  AppointmentServiceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.employee,
  });

  factory AppointmentServiceItem.fromJson(Map<String, dynamic> json) {
    return AppointmentServiceItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: _parseDouble(json['price']),
      duration: json['duration'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      employee: json['employee'] != null
          ? AppointmentServiceEmployee.fromJson(
              json['employee'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  AppointmentServiceItem copyWith({
    String? id,
    String? name,
    double? price,
    int? duration,
    String? startTime,
    String? endTime,
    AppointmentServiceEmployee? employee,
  }) {
    return AppointmentServiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      employee: employee ?? this.employee,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Get formatted start time (HH:MM)
  String get formattedStartTime {
    final parts = startTime.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return startTime;
  }

  String get formattedEndTime {
    final parts = endTime.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return endTime;
  }

  /// Get formatted duration (e.g., "1h 15min" or "30min")
  String get formattedDuration {
    if (duration >= 60) {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      if (minutes > 0) {
        return '${hours}h ${minutes}min';
      }
      return '${hours}h';
    }
    return '${duration}min';
  }
}

/// Employee info within an appointment service
class AppointmentServiceEmployee {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatar;

  AppointmentServiceEmployee({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatar,
  });

  factory AppointmentServiceEmployee.fromJson(Map<String, dynamic> json) {
    return AppointmentServiceEmployee(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      avatar: json['avatar'] as String?,
    );
  }

  String get fullName => '$firstName $lastName';
}
