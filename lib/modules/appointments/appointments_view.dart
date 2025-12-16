import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../core/utils/responsive.dart';
import '../../shared/layouts/admin_layout.dart';
import '../../shared/routes/app_routes.dart';
import '../../shared/widgets/page_components.dart';
import '../../data/models/appointment_model.dart';
import 'appointments_controller.dart';
import 'widgets/appointment_data_source.dart';
import 'widgets/appointment_details_sheet.dart';
import 'widgets/animated_month_picker.dart';
import 'widgets/calendar_header.dart';

class AppointmentsView extends GetView<AppointmentsController> {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: Routes.appointments,
      floatingActionButton: _buildFab(context),
      child: Obx(() {
        if (controller.isLoading.value && controller.appointments.isEmpty) {
          return const LoadingState(message: 'Loading appointments...');
        }

        if (controller.hasError.value && controller.appointments.isEmpty) {
          return ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          );
        }

        return CalendarBody(controller: controller);
      }),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await Get.toNamed(
          Routes.appointmentForm,
          arguments: {'dateSelected': controller.calendarDate.value},
        );
        if (result == true) {
          controller.refresh();
        }
      },
      icon: const Icon(Icons.add),
      label: const Text('New'),
      backgroundColor: ShadTheme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    );
  }
}

/// Main calendar body with day view
class CalendarBody extends StatefulWidget {
  const CalendarBody({super.key, required this.controller});

  final AppointmentsController controller;

  @override
  State<CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends State<CalendarBody> {
  late CalendarController _calendarController;
  DateTime? _lastFetchedDate;

  // Pinch-to-zoom state
  double _timeIntervalHeight = 50.0;
  double _baseHeight = 50.0;
  static const double _minHeight = 35.0;
  static const double _maxHeight = 120.0;

  // Month picker state
  bool _isMonthPickerVisible = false;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _calendarController.selectedDate = widget.controller.calendarDate.value;
    _calendarController.displayDate = widget.controller.calendarDate.value;
    _lastFetchedDate = widget.controller.calendarDate.value;
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onViewChanged(ViewChangedDetails details) {
    if (details.visibleDates.isNotEmpty) {
      final newDate = details.visibleDates.first;
      if (_lastFetchedDate == null || !_isSameDay(_lastFetchedDate!, newDate)) {
        _lastFetchedDate = newDate;
        widget.controller.setCalendarDate(newDate);
      }
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _onAppointmentTap(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment &&
        details.appointments != null &&
        details.appointments!.isNotEmpty) {
      final appointment =
          details.appointments!.first as CalendarAppointmentData;
      _showAppointmentDetails(appointment.data);
    }
  }

  void _showAppointmentDetails(AppointmentModel appointment) {
    final theme = ShadTheme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AppointmentDetailsSheet(
        appointment: appointment,
        employeeName: widget.controller.getEmployeeName(appointment.employeeId),
        onStatusChange: (status) async {
          Navigator.pop(context);
          await widget.controller.updateStatus(appointment.id, status);
        },
        onCancel: () async {
          Navigator.pop(context);
          await widget.controller.cancelAppointment(appointment.id);
        },
      ),
    );
  }

  void _handleDateSelected(DateTime date) {
    widget.controller.setCalendarDate(date);
    _calendarController.displayDate = date;
    setState(() {
      _isMonthPickerVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with date and navigation
        Padding(
          padding: Responsive.padding(context).copyWith(bottom: 0),
          child: Obx(
            () => CalendarHeader(
              date: widget.controller.calendarDate.value,
              isMonthPickerVisible: _isMonthPickerVisible,
              onToggleMonthPicker: () {
                setState(() {
                  _isMonthPickerVisible = !_isMonthPickerVisible;
                });
              },
              onTodayPressed: () {
                final today = DateTime.now();
                _calendarController.displayDate = today;
                widget.controller.setCalendarDate(today);
              },
            ),
          ),
        ),

        // Animated month picker
        Obx(
          () => AnimatedMonthPicker(
            isVisible: _isMonthPickerVisible,
            selectedDate: widget.controller.calendarDate.value,
            onDateSelected: _handleDateSelected,
          ),
        ),

        // Calendar with pinch-to-zoom
        Expanded(
          child: GestureDetector(
            onScaleStart: (details) {
              _baseHeight = _timeIntervalHeight;
            },
            onScaleUpdate: (details) {
              setState(() {
                _timeIntervalHeight = (_baseHeight * details.scale).clamp(
                  _minHeight,
                  _maxHeight,
                );
              });
            },
            child: Obx(() {
              final dataSource = AppointmentDataSource(
                widget.controller.appointments,
                widget.controller.getEmployeeName,
              );

              print(dataSource);
              return Stack(
                children: [
                  SfCalendar(
                    controller: _calendarController,
                    view: CalendarView.day,
                    dataSource: dataSource,
                    onViewChanged: _onViewChanged,
                    onTap: _onAppointmentTap,
                    showNavigationArrow: false,
                    showDatePickerButton: false,
                    headerHeight: 0,
                    viewHeaderHeight: 0,
                    todayHighlightColor: theme.colorScheme.primary,
                    cellBorderColor: theme.colorScheme.border.withValues(
                      alpha: 0.3,
                    ),
                    backgroundColor: theme.colorScheme.background,
                    timeSlotViewSettings: TimeSlotViewSettings(
                      startHour: 6,
                      endHour: 23,
                      timeIntervalHeight: _timeIntervalHeight,
                      timeFormat: 'HH:mm',
                      timeTextStyle: TextStyle(
                        color: theme.colorScheme.mutedForeground,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      timeRulerSize: 56,
                      dayFormat: 'EEE',
                    ),
                    appointmentBuilder: _buildAppointment,
                    allowDragAndDrop: false,
                    allowAppointmentResize: false,
                  ),

                  // Loading overlay
                  if (widget.controller.isLoading.value)
                    Positioned.fill(
                      child: Container(
                        color: theme.colorScheme.background.withValues(
                          alpha: 0.5,
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointment(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    final appointment = details.appointments.first as CalendarAppointmentData;
    final statusColor = getStatusColor(appointment.data.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(color: statusColor.withValues(alpha: 1), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 40;

            if (isCompact) {
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      appointment.data.clientName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    appointment.data.timeRange,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appointment.data.clientName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.data.timeRange,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
                if (constraints.maxHeight > 60) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          appointment.employeeName,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
