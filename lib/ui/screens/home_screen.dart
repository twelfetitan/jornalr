import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_counter.dart';
import '../widgets/hours_picker.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Dynamic greeting based on current local time
  String _getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 6) return '¡Buenas noches! 🌙';
    if (hour < 12) return '¡Buenos días! ☀️';
    if (hour < 20) return '¡Buenas tardes! ☕';
    return '¡Buenas noches! 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final DateTime today = DateTime.now();
    
    // Values from state
    final double todayHours = appState.getHoursForDate(today);
    final double totalMonthHours = appState.getTotalHoursForMonth(today);
    final double monthlyEarnings = appState.getEarningsForMonth(today);
    final double progress = appState.getMonthlyProgress(today);
    
    // Month formatting
    final String monthName = DateFormat('MMMM', 'es_ES').format(today);
    final String capitalizedMonthName = monthName[0].toUpperCase() + monthName.substring(1);

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
                // Greeting and Subtitle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mes actual: $capitalizedMonthName',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                    // Quick Action: Today Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.moneyGreen,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Hoy',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Main Dashboard Panel: Earnings Counter & Progress
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  child: Row(
                    children: [
                      // Earnings side
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cobro Estimado',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.5),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedCounter(
                              value: monthlyEarnings,
                              currency: appState.currency,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tarifa: ${appState.hourlyRate.toStringAsFixed(1)}${appState.currency}/h',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.4),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Progress Ring side
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 84,
                            height: 84,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 8,
                              backgroundColor: Colors.white.withOpacity(0.05),
                              color: AppTheme.primaryBlue,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(progress * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${totalMonthHours.toStringAsFixed(totalMonthHours % 1 == 0 ? 0 : (totalMonthHours % 0.5 == 0 ? 1 : 2))}h / ${appState.targetHours.round()}h',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.white.withOpacity(0.4),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Edit Hours Panel: today
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Registrar Horas de Hoy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Desliza o presiona para ajustar las horas del día de hoy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Hours Picker
                      HoursPicker(
                        value: todayHours,
                        onChanged: (newHours) {
                          appState.setHoursForDate(today, newHours);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics Card
                _buildStatsGrid(context, totalMonthHours, monthlyEarnings, appState.currency),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, double totalHours, double monthlyEarnings, String currency) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.access_time_filled_rounded,
            value: '${totalHours.toStringAsFixed(totalHours % 1 == 0 ? 0 : (totalHours % 0.5 == 0 ? 1 : 2))} h',
            label: 'Horas Totales',
          ),
          Container(width: 1, height: 40, color: Colors.white10),
          _buildStatItem(
            icon: Icons.insights_rounded,
            value: '${monthlyEarnings.toStringAsFixed(2)}${currency}',
            label: 'Total Bruto',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
