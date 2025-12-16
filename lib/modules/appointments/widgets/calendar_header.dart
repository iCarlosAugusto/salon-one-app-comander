import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/utils/formatters.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.date,
    required this.isMonthPickerVisible,
    required this.onToggleMonthPicker,
    required this.onTodayPressed,
  });

  final DateTime date;
  final bool isMonthPickerVisible;
  final VoidCallback onToggleMonthPicker;
  final VoidCallback onTodayPressed;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDay(date, DateTime.now());
    final String formattedDate = DateFormat("MMMM", 'pt_BR').format(date);

    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date.day.toString(),
                    style: context.appTextTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isToday ? 'Today' : Formatters.formatRelativeDate(date),
                    style: context.appTextTheme.cardSubtitle,
                  ),
                ],
              ),
              InkWell(
                onTap: onToggleMonthPicker,
                child: Row(
                  children: [
                    Text(formattedDate),
                    AnimatedRotation(
                      turns: isMonthPickerVisible ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Navigation buttons
        Row(
          children: [
            // Today button
            if (!isToday)
              ShadButton.ghost(
                onPressed: onTodayPressed,
                child: const Text('Today'),
              ),
          ],
        ),
      ],
    );
  }
}
