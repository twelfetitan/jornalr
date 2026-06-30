import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import 'edit_hours_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();

  // Navigation to next/previous month
  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset, 1);
    });
  }

  // Show Bottom Sheet to modify hours for a clicked day
  void _showEditHoursSheet(BuildContext context, DateTime date) {
    final appState = context.read<AppState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditHoursSheet(
        appState: appState,
        date: date,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Calculate dates in month
    final int daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final int firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday; // 1 = Monday, 7 = Sunday
    
    // Month name
    final String monthName = DateFormat('MMMM yyyy', 'es_ES').format(_currentMonth);
    final String capitalizedMonthName = monthName[0].toUpperCase() + monthName.substring(1);

    // Weekdays headers
    final List<String> weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    // List of day widgets
    final List<Widget> dayWidgets = [];

    // Weekday offset (firstWeekday: 1 is Mon, so offset is firstWeekday - 1)
    final int offset = firstWeekday - 1;
    for (int i = 0; i < offset; i++) {
      dayWidgets.add(const SizedBox()); // Empty grid cell for alignment
    }

    final DateTime now = DateTime.now();

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final double hours = appState.getHoursForDate(date);
      final String note = appState.getNoteForDate(date);
      
      final bool isToday = now.year == date.year && now.month == date.month && now.day == date.day;
      final bool hasHours = hours > 0.0;
      final bool hasNote = note.isNotEmpty;
      final bool isHoliday = appState.isHoliday(date);
      final String? holidayName = appState.getHolidayName(date);

      dayWidgets.add(
        InkWell(
          onTap: () => _showEditHoursSheet(context, date),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: hasHours ? AppTheme.primaryGradient : null,
              color: hasHours 
                  ? null 
                  : (isHoliday 
                      ? AppTheme.errorRed.withOpacity(0.08)
                      : (isToday ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.02))),
              border: Border.all(
                color: isToday 
                    ? AppTheme.primaryBlue 
                    : (hasHours 
                        ? Colors.transparent 
                        : (isHoliday ? AppTheme.errorRed.withOpacity(0.3) : Colors.white.withOpacity(0.05))),
                width: isToday ? 2.0 : 1.0,
              ),
              boxShadow: hasHours 
                  ? [
                      BoxShadow(
                         color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Day number
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isToday || hasHours || isHoliday ? FontWeight.bold : FontWeight.w500,
                          color: hasHours 
                              ? Colors.white 
                              : (isToday 
                                  ? AppTheme.primaryBlue 
                                  : (isHoliday ? AppTheme.errorRed : const Color(0xCCFFFFFF))),
                        ),
                      ),
                      const SizedBox(height: 2),
                      
                      // Hours label or dot indicators
                      if (hasHours)
                        Text(
                          '${hours.toStringAsFixed(hours % 1 == 0 ? 0 : (hours % 0.5 == 0 ? 1 : 2))}h',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      else if (isHoliday)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.errorRed,
                          ),
                        )
                      else
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday ? AppTheme.primaryBlue : Colors.transparent,
                          ),
                        ),
                    ],
                  ),
                ),
                // Holiday badge (red dot) in top-left if the day has hours logged
                if (isHoliday && hasHours)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.errorRed,
                      ),
                    ),
                  ),
                if (hasNote)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.warningOrange,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.darkBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Historial',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Visualiza y modifica días anteriores',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Month Navigation Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      capitalizedMonthName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Custom Calendar Box
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Weekday Names Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: weekdays.map((day) {
                            return SizedBox(
                              width: 40,
                              child: Text(
                                day,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white38,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white10, height: 1),
                        const SizedBox(height: 12),

                        // Monthly Grid View
                        Expanded(
                          child: GridView.builder(
                            itemCount: dayWidgets.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1.0,
                            ),
                            itemBuilder: (context, index) {
                              return dayWidgets[index];
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
