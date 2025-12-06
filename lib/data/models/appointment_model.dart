/// Appointment status enum
enum AppointmentStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow;

  String get value {
    switch (this) {
      case AppointmentStatus.pending:
        return 'pending';
      case AppointmentStatus.confirmed:
        return 'confirmed';
      case AppointmentStatus.inProgress:
        return 'in_progress';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
      case AppointmentStatus.noShow:
        return 'no_show';
    }
  }

  String get displayName {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }

  static AppointmentStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'in_progress':
        return AppointmentStatus.inProgress;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'no_show':
        return AppointmentStatus.noShow;
      default:
        return AppointmentStatus.pending;
    }
  }
}

/// Appointment model
class AppointmentModel {
  final String id;
  final String salonId;
  final String? employeeId;
  final String appointmentDate;
  final String startTime;
  final String endTime;
  final int totalDuration;
  final double totalPrice;
  final AppointmentStatus status;
  final String clientName;
  final String? clientEmail;
  final String clientPhone;
  final String? notes;
  final String? cancellationReason;
  final bool reminderSent;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data (populated from joins)
  final List<String>? serviceIds;
  final String? employeeName;

  AppointmentModel({
    required this.id,
    required this.salonId,
    this.employeeId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.totalDuration,
    required this.totalPrice,
    required this.status,
    required this.clientName,
    this.clientEmail,
    required this.clientPhone,
    this.notes,
    this.cancellationReason,
    this.reminderSent = false,
    required this.createdAt,
    required this.updatedAt,
    this.serviceIds,
    this.employeeName,
  });

  /// Get formatted date
  DateTime get date => DateTime.parse(appointmentDate);

  /// Get time range for display
  String get timeRange {
    final start = _formatTime(startTime);
    final end = _formatTime(endTime);
    return '$start - $end';
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return time;
  }

  /// Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    final appointmentDateTime = date;
    return now.year == appointmentDateTime.year &&
        now.month == appointmentDateTime.month &&
        now.day == appointmentDateTime.day;
  }

  /// Check if appointment is in the past
  bool get isPast {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// Check if appointment can be cancelled
  bool get canBeCancelled {
    return status != AppointmentStatus.cancelled &&
        status != AppointmentStatus.completed &&
        status != AppointmentStatus.noShow;
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      salonId: json['salonId'] as String,
      employeeId: json['employeeId'] as String?,
      appointmentDate: json['appointmentDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      totalDuration: json['totalDuration'] as int,
      totalPrice: _parsePrice(json['totalPrice']),
      status: AppointmentStatus.fromString(json['status'] as String),
      clientName: json['clientName'] as String,
      clientEmail: json['clientEmail'] as String?,
      clientPhone: json['clientPhone'] as String,
      notes: json['notes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      reminderSent: json['reminderSent'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      serviceIds: json['serviceIds'] != null
          ? List<String>.from(json['serviceIds'] as List)
          : null,
      employeeName: json['employeeName'] as String?,
    );
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salonId': salonId,
      'employeeId': employeeId,
      'appointmentDate': appointmentDate,
      'startTime': startTime,
      'endTime': endTime,
      'totalDuration': totalDuration,
      'totalPrice': totalPrice,
      'status': status.value,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'notes': notes,
      'cancellationReason': cancellationReason,
      'reminderSent': reminderSent,
      'serviceIds': serviceIds,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? salonId,
    String? employeeId,
    String? appointmentDate,
    String? startTime,
    String? endTime,
    int? totalDuration,
    double? totalPrice,
    AppointmentStatus? status,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    String? notes,
    String? cancellationReason,
    bool? reminderSent,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? serviceIds,
    String? employeeName,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      salonId: salonId ?? this.salonId,
      employeeId: employeeId ?? this.employeeId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDuration: totalDuration ?? this.totalDuration,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      reminderSent: reminderSent ?? this.reminderSent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serviceIds: serviceIds ?? this.serviceIds,
      employeeName: employeeName ?? this.employeeName,
    );
  }
}
