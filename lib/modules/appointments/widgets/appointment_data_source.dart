import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/appointment_model.dart';

/// Data source for Syncfusion calendar
class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(
    List<AppointmentModel> appointmentsList,
    String Function(String?) getEmployeeName,
  ) {
    appointments = appointmentsList.map((apt) {
      return CalendarAppointmentData(
        data: apt,
        employeeName: getEmployeeName(apt.employeeId),
      );
    }).toList();
  }

  @override
  DateTime getStartTime(int index) {
    final apt = appointments![index] as CalendarAppointmentData;
    return apt.startDateTime;
  }

  @override
  DateTime getEndTime(int index) {
    final apt = appointments![index] as CalendarAppointmentData;
    return apt.endDateTime;
  }

  @override
  String getSubject(int index) {
    final apt = appointments![index] as CalendarAppointmentData;
    return apt.data.clientName;
  }

  @override
  Color getColor(int index) {
    final apt = appointments![index] as CalendarAppointmentData;
    return getStatusColor(apt.data.status);
  }
}

/// Custom appointment data for Syncfusion calendar
class CalendarAppointmentData {
  CalendarAppointmentData({required this.data, required this.employeeName});

  final AppointmentModel data;
  final String employeeName;

  DateTime get startDateTime {
    final dateParts = data.appointmentDate.split('-');
    final timeParts = data.startTime.split(':');
    return DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts.length > 1 ? timeParts[1] : '0'),
    );
  }

  DateTime get endDateTime {
    return startDateTime.add(Duration(minutes: data.totalDuration));
  }
}

/// Get color for appointment status
Color getStatusColor(AppointmentStatus status) {
  switch (status) {
    case AppointmentStatus.pending:
      return AppColors.statusPending;
    case AppointmentStatus.confirmed:
      return AppColors.statusConfirmed;
    case AppointmentStatus.inProgress:
      return AppColors.statusInProgress;
    case AppointmentStatus.completed:
      return AppColors.statusCompleted;
    case AppointmentStatus.cancelled:
      return AppColors.statusCancelled;
    case AppointmentStatus.noShow:
      return AppColors.statusNoShow;
  }
}
