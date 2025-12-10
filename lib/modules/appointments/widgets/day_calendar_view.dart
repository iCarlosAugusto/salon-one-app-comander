import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../data/models/appointment_model.dart';
import 'appointment_block.dart';

/// Google Calendar-style daily view with time slots
class DayCalendarView extends StatefulWidget {
  const DayCalendarView({
    super.key,
    required this.selectedDate,
    required this.appointments,
    this.startHour = 8,
    this.endHour = 22,
    this.hourHeight = 60.0,
    this.onAppointmentTap,
    this.onTimeSlotTap,
    required this.getEmployeeName,
  });

  final DateTime selectedDate;
  final List<AppointmentModel> appointments;
  final int startHour;
  final int endHour;
  final double hourHeight;
  final Function(AppointmentModel)? onAppointmentTap;
  final Function(DateTime time)? onTimeSlotTap;
  final String Function(String?) getEmployeeName;

  @override
  State<DayCalendarView> createState() => _DayCalendarViewState();
}

class _DayCalendarViewState extends State<DayCalendarView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentTime() {
    if (!_isToday) return;

    final now = DateTime.now();
    final currentHour = now.hour;

    if (currentHour >= widget.startHour && currentHour <= widget.endHour) {
      final offset = (currentHour - widget.startHour) * widget.hourHeight;
      _scrollController.animateTo(
        offset - 100, // Show some context above current time
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  bool get _isToday {
    final now = DateTime.now();
    return widget.selectedDate.year == now.year &&
        widget.selectedDate.month == now.month &&
        widget.selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final totalHours = widget.endHour - widget.startHour;
    final totalHeight = totalHours * widget.hourHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final calendarWidth =
            constraints.maxWidth - 56; // Subtract time label width

        return SingleChildScrollView(
          controller: _scrollController,
          child: SizedBox(
            height: totalHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time labels column
                SizedBox(
                  width: 56,
                  child: Column(
                    children: List.generate(totalHours, (index) {
                      final hour = widget.startHour + index;
                      return SizedBox(
                        height: widget.hourHeight,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8, top: 0),
                            child: Text(
                              '${hour.toString().padLeft(2, '0')}:00',
                              style: TextStyle(
                                color: theme.colorScheme.mutedForeground,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Calendar grid
                Expanded(
                  child: Stack(
                    children: [
                      // Hour grid lines
                      Column(
                        children: List.generate(totalHours, (index) {
                          return GestureDetector(
                            onTap: () {
                              final hour = widget.startHour + index;
                              final time = DateTime(
                                widget.selectedDate.year,
                                widget.selectedDate.month,
                                widget.selectedDate.day,
                                hour,
                              );
                              widget.onTimeSlotTap?.call(time);
                            },
                            child: Container(
                              height: widget.hourHeight,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: theme.colorScheme.border.withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      // Current time indicator
                      if (_isToday) _buildCurrentTimeIndicator(theme),
                      // Appointment blocks
                      ..._buildAppointmentBlocks(calendarWidth),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentTimeIndicator(ShadThemeData theme) {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    if (currentHour < widget.startHour || currentHour >= widget.endHour) {
      return const SizedBox.shrink();
    }

    final topPosition =
        (currentHour - widget.startHour) * widget.hourHeight +
        (currentMinute / 60) * widget.hourHeight;

    return Positioned(
      top: topPosition,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF4285F4), // Google Calendar blue
              shape: BoxShape.circle,
            ),
          ),
          Expanded(child: Container(height: 2, color: const Color(0xFF4285F4))),
        ],
      ),
    );
  }

  List<Widget> _buildAppointmentBlocks(double calendarWidth) {
    return widget.appointments.map((appointment) {
      final startParts = appointment.startTime.split(':');
      final startHour = int.tryParse(startParts[0]) ?? 0;
      final startMinute =
          int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0;

      // Calculate position
      final topPosition =
          (startHour - widget.startHour) * widget.hourHeight +
          (startMinute / 60) * widget.hourHeight;

      // Calculate height based on duration
      final height = (appointment.totalDuration / 60) * widget.hourHeight;

      // Skip if outside visible range
      if (startHour < widget.startHour || startHour >= widget.endHour) {
        return const SizedBox.shrink();
      }

      return Positioned(
        top: topPosition,
        left: 4,
        right: 4,
        height: height.clamp(30.0, double.infinity),
        child: AppointmentBlock(
          appointment: appointment,
          employeeName: widget.getEmployeeName(appointment.employeeId),
          onTap: () => widget.onAppointmentTap?.call(appointment),
        ),
      );
    }).toList();
  }
}
