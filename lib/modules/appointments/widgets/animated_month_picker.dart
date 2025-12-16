import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Animated month picker that expands/collapses
class AnimatedMonthPicker extends StatelessWidget {
  const AnimatedMonthPicker({
    super.key,
    required this.isVisible,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final bool isVisible;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isVisible ? 320 : 0,
      child: ClipRect(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isVisible ? 1.0 : 0.0,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.border.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: SfCalendar(
              view: CalendarView.month,
              initialSelectedDate: selectedDate,
              initialDisplayDate: selectedDate,
              showNavigationArrow: true,
              todayHighlightColor: theme.colorScheme.primary,
              selectionDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              headerStyle: CalendarHeaderStyle(
                textAlign: TextAlign.center,
                backgroundColor: theme.colorScheme.card,
                textStyle: TextStyle(
                  color: theme.colorScheme.foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              viewHeaderStyle: ViewHeaderStyle(
                dayTextStyle: TextStyle(
                  color: theme.colorScheme.mutedForeground,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              monthCellBuilder: (context, details) {
                final isToday = _isSameDay(details.date, DateTime.now());
                final isSelected = _isSameDay(details.date, selectedDate);
                final isCurrentMonth =
                    details.date.month == details.visibleDates[15].month;

                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Text(
                    details.date.day.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isCurrentMonth
                          ? theme.colorScheme.foreground
                          : theme.colorScheme.mutedForeground.withValues(
                              alpha: 0.5,
                            ),
                      fontWeight: isToday || isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
              onTap: (details) {
                if (details.date != null) {
                  onDateSelected(details.date!);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
