import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedYear = DateTime.now().year;

  // Monthly stats helper model
  List<_MonthStat> _calculateYearStats(AppState appState, int year) {
    final List<_MonthStat> stats = [];
    for (int month = 1; month <= 12; month++) {
      final DateTime date = DateTime(year, month, 1);
      final double hours = appState.getTotalHoursForMonth(date);
      final double earnings = appState.getEarningsForMonth(date);
      
      // Count work days
      int daysWorked = 0;
      final int daysInMonth = DateTime(year, month + 1, 0).day;
      for (int day = 1; day <= daysInMonth; day++) {
        final d = DateTime(year, month, day);
        if (appState.getHoursForDate(d) > 0) {
          daysWorked++;
        }
      }

      stats.add(_MonthStat(
        date: date,
        monthName: DateFormat('MMMM', 'es_ES').format(date),
        hours: hours,
        earnings: earnings,
        daysWorked: daysWorked,
      ));
    }
    return stats;
  }

  List<int> _getAvailableYears(AppState appState) {
    final Set<int> years = {DateTime.now().year};
    for (final key in appState.workEntries.keys) {
      final parts = key.split('-');
      if (parts.isNotEmpty) {
        final y = int.tryParse(parts[0]);
        if (y != null) {
          years.add(y);
        }
      }
    }
    final sorted = years.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final availableYears = _getAvailableYears(appState);
    if (!availableYears.contains(_selectedYear)) {
      _selectedYear = availableYears.first;
    }

    final monthlyStats = _calculateYearStats(appState, _selectedYear);
    
    // Totals for selected year
    final double totalYearHours = monthlyStats.fold(0.0, (sum, m) => sum + m.hours);
    final double totalYearEarnings = monthlyStats.fold(0.0, (sum, m) => sum + m.earnings);
    final int totalYearDays = monthlyStats.fold(0, (sum, m) => sum + m.daysWorked);
    
    // Average calculation
    final List<_MonthStat> activeMonths = monthlyStats.where((m) => m.hours > 0).toList();
    final double avgHoursPerActiveMonth = activeMonths.isEmpty ? 0.0 : totalYearHours / activeMonths.length;
    final double avgEarningsPerActiveMonth = activeMonths.isEmpty ? 0.0 : totalYearEarnings / activeMonths.length;
    final double avgHourlyPayReal = totalYearHours == 0 ? 0.0 : totalYearEarnings / totalYearHours;

    // Highest month for chart bar scale
    final double maxMonthlyHours = monthlyStats.fold(0.0, (max, m) => m.hours > max ? m.hours : max);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.darkBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header & Year Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estadísticas',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Resumen comparativo por meses',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    // Year dropdown / Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          dropdownColor: AppTheme.darkBgStart,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          items: availableYears.map((int year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                          onChanged: (int? newYear) {
                            if (newYear != null) {
                              setState(() {
                                _selectedYear = newYear;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Year Summary Overview Card
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.analytics_rounded, color: AppTheme.primaryBlue, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resumen Anual $_selectedYear',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${totalYearEarnings.toStringAsFixed(2)} ${appState.currency}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            'Horas totales',
                            '${totalYearHours.toStringAsFixed(totalYearHours % 1 == 0 ? 0 : 1)}h',
                            Icons.access_time_filled_rounded,
                          ),
                          _buildSummaryItem(
                            'Días trabajados',
                            '$totalYearDays días',
                            Icons.calendar_today_rounded,
                          ),
                          _buildSummaryItem(
                            'Media/Hora real',
                            '${avgHourlyPayReal.toStringAsFixed(2)}${appState.currency}',
                            Icons.payments_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Visual Chart of Monthly Hours
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Horas trabajadas por mes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Comparativa visual mes a mes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 160,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: monthlyStats.map((stat) {
                            final double barRatio = maxMonthlyHours > 0 ? (stat.hours / maxMonthlyHours) : 0.0;
                            final String shortMonth = stat.monthName.substring(0, 3).toUpperCase();
                            final bool isCurrentMonth = stat.date.year == DateTime.now().year && stat.date.month == DateTime.now().month;

                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (stat.hours > 0)
                                    FittedBox(
                                      child: Text(
                                        '${stat.hours.toStringAsFixed(stat.hours % 1 == 0 ? 0 : 1)}h',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isCurrentMonth ? AppTheme.primaryBlue : Colors.white70,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    width: 14,
                                    height: (barRatio * 100).clamp(4.0, 100.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      gradient: isCurrentMonth 
                                          ? AppTheme.primaryGradient 
                                          : (stat.hours > 0
                                              ? LinearGradient(
                                                  colors: [
                                                    AppTheme.primaryBlue.withOpacity(0.7),
                                                    AppTheme.primaryBlue.withOpacity(0.4),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                )
                                              : null),
                                      color: stat.hours > 0 ? null : Colors.white.withOpacity(0.05),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    shortMonth[0],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.w500,
                                      color: isCurrentMonth ? AppTheme.primaryBlue : Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Detailed Monthly Breakdown List
                const Text(
                  'Desglose Mensual',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                ...monthlyStats.reversed.map((stat) {
                  final String capitalizedMonth = stat.monthName[0].toUpperCase() + stat.monthName.substring(1);
                  final bool hasActivity = stat.hours > 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: hasActivity 
                                  ? AppTheme.primaryBlue.withOpacity(0.12)
                                  : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: hasActivity 
                                    ? AppTheme.primaryBlue.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                stat.monthName.substring(0, 3).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: hasActivity ? AppTheme.primaryBlue : Colors.white38,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  capitalizedMonth,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  hasActivity 
                                      ? '${stat.daysWorked} días trabajados' 
                                      : 'Sin registros de actividad',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${stat.earnings.toStringAsFixed(2)} ${appState.currency}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: hasActivity ? Colors.white : Colors.white38,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${stat.hours.toStringAsFixed(stat.hours % 1 == 0 ? 0 : 1)} horas',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: hasActivity ? AppTheme.primaryBlue : Colors.white24,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}

class _MonthStat {
  final DateTime date;
  final String monthName;
  final double hours;
  final double earnings;
  final int daysWorked;

  _MonthStat({
    required this.date,
    required this.monthName,
    required this.hours,
    required this.earnings,
    required this.daysWorked,
  });
}
