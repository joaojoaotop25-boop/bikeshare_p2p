import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AvailabilityWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onAvailabilityChanged;
  final Map<String, dynamic> initialAvailability;

  const AvailabilityWidget({
    Key? key,
    required this.onAvailabilityChanged,
    this.initialAvailability = const {},
  }) : super(key: key);

  @override
  State<AvailabilityWidget> createState() => _AvailabilityWidgetState();
}

class _AvailabilityWidgetState extends State<AvailabilityWidget> {
  Set<DateTime> _blockedDates = {};
  DateTime _selectedMonth = DateTime.now();
  bool _isAlwaysAvailable = true;

  @override
  void initState() {
    super.initState();
    _initializeAvailability();
  }

  void _initializeAvailability() {
    _isAlwaysAvailable =
        widget.initialAvailability['isAlwaysAvailable'] ?? true;
    final blockedDatesList =
        widget.initialAvailability['blockedDates'] as List<DateTime>? ?? [];
    _blockedDates = Set.from(blockedDatesList);
  }

  void _updateAvailability() {
    final availability = {
      'isAlwaysAvailable': _isAlwaysAvailable,
      'blockedDates': _blockedDates.toList(),
    };
    widget.onAvailabilityChanged(availability);
  }

  void _toggleDateAvailability(DateTime date) {
    setState(() {
      if (_blockedDates.contains(date)) {
        _blockedDates.remove(date);
      } else {
        _blockedDates.add(date);
      }
    });
    _updateAvailability();
  }

  void _changeMonth(int direction) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + direction,
        1,
      );
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isDateBlocked(DateTime date) {
    return _blockedDates.any((blockedDate) => _isSameDay(blockedDate, date));
  }

  bool _isPastDate(DateTime date) {
    final today = DateTime.now();
    return date.isBefore(DateTime(today.year, today.month, today.day));
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];

    for (int i = 0; i < lastDay.day; i++) {
      days.add(firstDay.add(Duration(days: i)));
    }

    return days;
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return months[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return weekdays[weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'event_available',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Disponibilidade',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Always Available Toggle
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Switch(
                  value: _isAlwaysAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAlwaysAvailable = value;
                      if (value) {
                        _blockedDates.clear();
                      }
                    });
                    _updateAvailability();
                  },
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sempre Disponível',
                        style: AppTheme.lightTheme.textTheme.titleSmall,
                      ),
                      Text(
                        _isAlwaysAvailable
                            ? 'Sua bicicleta estará sempre disponível para aluguel'
                            : 'Você pode bloquear datas específicas',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (!_isAlwaysAvailable) ...[
            SizedBox(height: 3.h),

            // Calendar Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _changeMonth(-1),
                    icon: CustomIconWidget(
                      iconName: 'chevron_left',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  Text(
                    '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // Weekday Headers
            Row(
              children: List.generate(7, (index) {
                return Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child: Text(
                      _getWeekdayName(index),
                      textAlign: TextAlign.center,
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }),
            ),

            // Calendar Grid
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: _buildCalendarWeeks(),
              ),
            ),
            SizedBox(height: 3.h),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(
                  color: Colors.green.withValues(alpha: 0.3),
                  label: 'Disponível',
                  icon: 'check_circle',
                ),
                _buildLegendItem(
                  color: Colors.red.withValues(alpha: 0.3),
                  label: 'Bloqueado',
                  icon: 'block',
                ),
                _buildLegendItem(
                  color: Colors.grey.withValues(alpha: 0.3),
                  label: 'Passado',
                  icon: 'history',
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Quick Actions
            if (_blockedDates.isNotEmpty)
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      color: Colors.orange[700]!,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        '${_blockedDates.length} data(s) bloqueada(s)',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _blockedDates.clear();
                        });
                        _updateAvailability();
                      },
                      child: Text(
                        'Limpar Tudo',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: color.withValues(alpha: 0.8),
            ),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: color.withValues(alpha: 1.0),
            size: 12,
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCalendarWeeks() {
    final daysInMonth = _getDaysInMonth(_selectedMonth);
    final firstDayWeekday = daysInMonth.first.weekday % 7;
    final weeks = <Widget>[];

    // Add empty cells for days before the first day of the month
    final allDays = <DateTime?>[];
    for (int i = 0; i < firstDayWeekday; i++) {
      allDays.add(null);
    }
    allDays.addAll(daysInMonth);

    // Build weeks
    for (int i = 0; i < allDays.length; i += 7) {
      final weekDays = allDays.skip(i).take(7).toList();
      weeks.add(_buildCalendarWeek(weekDays));
    }

    return weeks;
  }

  Widget _buildCalendarWeek(List<DateTime?> weekDays) {
    return Row(
      children: weekDays.map((date) {
        if (date == null) {
          return Expanded(child: Container(height: 6.h));
        }

        final isBlocked = _isDateBlocked(date);
        final isPast = _isPastDate(date);
        final isToday = _isSameDay(date, DateTime.now());

        Color backgroundColor;
        Color textColor;

        if (isPast) {
          backgroundColor = Colors.grey.withValues(alpha: 0.3);
          textColor = Colors.grey[600]!;
        } else if (isBlocked) {
          backgroundColor = Colors.red.withValues(alpha: 0.3);
          textColor = Colors.red[700]!;
        } else {
          backgroundColor = Colors.green.withValues(alpha: 0.3);
          textColor = Colors.green[700]!;
        }

        return Expanded(
          child: GestureDetector(
            onTap: isPast ? null : () => _toggleDateAvailability(date),
            child: Container(
              height: 6.h,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: isToday
                    ? Border.all(
                        color: AppTheme.lightTheme.primaryColor,
                        width: 2,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  date.day.toString(),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
