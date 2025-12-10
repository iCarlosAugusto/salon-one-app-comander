import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InlineCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateSelected;

  const InlineCalendar({
    super.key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });

  @override
  State<InlineCalendar> createState() => _InlineCalendarState();
}

class _InlineCalendarState extends State<InlineCalendar> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final dateFormat = DateFormat.yMMMM('pt_BR'); // ex: "dezembro de 2025"

    // Gera a matriz de dias (6 semanas * 7 colunas)
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);

    // Ajuste para semana começando na segunda (pt-BR): 0 = segunda, 6 = domingo
    final weekdayFromMonday = (firstOfMonth.weekday + 6) % 7;
    final firstDisplayDay = firstOfMonth.subtract(
      Duration(days: weekdayFromMonday),
    );

    final days = List<DateTime>.generate(
      42,
      (index) => DateTime(
        firstDisplayDay.year,
        firstDisplayDay.month,
        firstDisplayDay.day + index,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Tamanho responsivo das células
        final cellWidth = constraints.maxWidth / 7;
        final cellHeight = cellWidth * 0.9;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: mês, ano, setas
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _canGoToPreviousMonth()
                      ? _goToPreviousMonth
                      : null,
                  tooltip: 'Mês anterior',
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      dateFormat.format(_visibleMonth),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _canGoToNextMonth() ? _goToNextMonth : null,
                  tooltip: 'Próximo mês',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Linha com os nomes dos dias da semana
            Row(children: _buildWeekdayHeaders(theme, cellWidth)),
            const SizedBox(height: 4),

            // Grade de dias
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemBuilder: (context, index) {
                final date = days[index];
                final isCurrentMonth = date.month == _visibleMonth.month;
                final isDisabledRange =
                    date.isBefore(widget.firstDate) ||
                    date.isAfter(widget.lastDate);
                final isSelectable = isCurrentMonth && !isDisabledRange;

                final isSelected = _isSameDay(date, widget.selectedDate);
                final isToday = _isSameDay(date, today);

                Color? bgColor;
                Color? textColor;

                if (!isCurrentMonth) {
                  textColor = theme.disabledColor.withOpacity(0.6);
                } else if (isDisabledRange) {
                  textColor = theme.disabledColor;
                } else if (isSelected) {
                  bgColor = theme.colorScheme.primary;
                  textColor = theme.colorScheme.onPrimary;
                } else if (isToday) {
                  bgColor = theme.colorScheme.primary.withOpacity(0.12);
                  textColor = theme.colorScheme.primary;
                } else {
                  textColor = theme.textTheme.bodyMedium?.color;
                }

                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: isSelectable
                        ? () {
                            widget.onDateSelected(date);
                          }
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      // AspectRatio ajuda a manter quadradinho em diferentes telas
                      child: SizedBox(
                        width: cellWidth,
                        height: cellHeight,
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: textColor,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildWeekdayHeaders(ThemeData theme, double cellWidth) {
    // Ordem começando na segunda-feira
    const weekdays = [
      'S',
      'T',
      'Q',
      'Q',
      'S',
      'S',
      'D',
    ]; // Seg, Ter, Qua, Qui, Sex, Sáb, Dom
    return List.generate(7, (index) {
      return SizedBox(
        width: cellWidth,
        height: 24,
        child: Center(
          child: Text(
            weekdays[index],
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
      );
    });
  }

  bool _canGoToPreviousMonth() {
    final prevMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
    return prevMonth.isAfter(
          DateTime(widget.firstDate.year, widget.firstDate.month, 0),
        ) ||
        _isSameMonth(prevMonth, widget.firstDate);
  }

  bool _canGoToNextMonth() {
    final nextMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    return nextMonth.isBefore(
          DateTime(widget.lastDate.year, widget.lastDate.month + 1, 1),
        ) ||
        _isSameMonth(nextMonth, widget.lastDate);
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
