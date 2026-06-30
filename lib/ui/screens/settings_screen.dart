import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _specialRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _rateController.text = appState.hourlyRate.toStringAsFixed(2);
    _specialRateController.text = appState.specialHourlyRate.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _rateController.dispose();
    _specialRateController.dispose();
    super.dispose();
  }

  // Handle hourly rate submit
  void _saveRate(String value) {
    final double? rate = double.tryParse(value);
    if (rate != null && rate >= 0) {
      context.read<AppState>().updateHourlyRate(rate);
    }
  }

  // Handle special hourly rate submit
  void _saveSpecialRate(String value) {
    final double? rate = double.tryParse(value);
    if (rate != null && rate >= 0) {
      context.read<AppState>().updateSpecialHourlyRate(rate);
    }
  }

  // Handle setting reminder time
  Future<void> _selectReminderTime(BuildContext context, String currentTime) async {
    final List<String> parts = currentTime.split(':');
    final int initialHour = parts.length == 2 ? int.parse(parts[0]) : 20;
    final int initialMinute = parts.length == 2 ? int.parse(parts[1]) : 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.darkBgEnd,
              hourMinuteTextColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (context.mounted) {
        context.read<AppState>().updateReminderTime(formattedTime);
      }
    }
  }

  // Confirmation dialog for data reset
  void _showResetDialog(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1B4B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.glassCardBorder, width: 1),
          ),
          title: const Text(
            '¿Restablecer datos?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Esta acción eliminará de forma permanente todas las horas trabajadas registradas y volverá los ajustes a los valores iniciales. No se puede deshacer.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorRed,
              ),
              child: const Text('Restablecer', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                final appState = context.read<AppState>();
                await appState.resetAllData();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (context.mounted) {
                  _rateController.text = appState.hourlyRate.toStringAsFixed(2);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Todos los datos han sido restablecidos.'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog to add a custom local holiday
  void _showAddLocalHolidayDialog(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dateStr = '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';
            
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1B4B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppTheme.glassCardBorder, width: 1),
              ),
              title: const Text(
                'Añadir Festivo Local',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Festivo',
                      labelStyle: TextStyle(color: Colors.white60),
                      hintText: 'Ej. Fiesta Mayor, Patrón local',
                      hintStyle: TextStyle(color: Colors.white30),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryBlue)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fecha', style: TextStyle(color: Colors.white38, fontSize: 11)),
                          Text(dateStr, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_month_rounded, size: 18),
                        label: const Text('Cambiar'),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                TextButton(
                  child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      context.read<AppState>().addLocalHoliday(selectedDate, name);
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog warning that notifications are not supported on web
  void _showWebNotificationsLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1B4B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.glassCardBorder, width: 1),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.warningOrange, size: 24),
              SizedBox(width: 10),
              Text(
                'Función no disponible',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Los recordatorios diarios y las notificaciones locales son una función exclusiva para móvil y no están disponibles en la versión web.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.darkBackgroundGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              // Title
              Text(
                'Ajustes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Personaliza tus tarifas y recordatorios',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // SECTION 1: TARIFAS Y OBJETIVOS
              _buildSectionTitle('Salario y Objetivos'),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Hourly Rate input
                    _buildSettingsRow(
                      icon: Icons.payments_rounded,
                      title: 'Tarifa por Hora',
                      subtitle: 'Precio cobrado por cada hora estándar',
                      trailing: SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _rateController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          decoration: InputDecoration(
                            suffixText: ' ${appState.currency}',
                            suffixStyle: const TextStyle(color: Colors.white60),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            border: InputBorder.none,
                          ),
                          onSubmitted: _saveRate,
                          onChanged: _saveRate,
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 24),

                    // Special Hourly Rate input (Weekends & Holidays)
                    _buildSettingsRow(
                      icon: Icons.payments_rounded,
                      title: 'Tarifa Finde / Festivo',
                      subtitle: 'Precio cobrado en fines de semana y festivos',
                      trailing: SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _specialRateController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          decoration: InputDecoration(
                            suffixText: ' ${appState.currency}',
                            suffixStyle: const TextStyle(color: Colors.white60),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            border: InputBorder.none,
                          ),
                          onSubmitted: _saveSpecialRate,
                          onChanged: _saveSpecialRate,
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 24),

                    // Currency picker
                    _buildSettingsRow(
                      icon: Icons.monetization_on_rounded,
                      title: 'Moneda',
                      subtitle: 'Símbolo de divisa mostrado',
                      trailing: DropdownButton<String>(
                        value: appState.currency,
                        dropdownColor: AppTheme.darkBgEnd,
                        underline: const SizedBox(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            context.read<AppState>().updateCurrency(newValue);
                          }
                        },
                        items: <String>['€', r'$', '£', '¥', '₩']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 24),

                    // Target Hours
                    _buildSettingsRow(
                      icon: Icons.flag_rounded,
                      title: 'Objetivo Mensual',
                      subtitle: 'Meta de horas a trabajar al mes',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Color(0x80FFFFFF), size: 20),
                            onPressed: appState.targetHours > 40
                                ? () => context.read<AppState>().updateTargetHours(appState.targetHours - 5)
                                : null,
                          ),
                          Text(
                            '${appState.targetHours.round()}h',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Color(0x80FFFFFF), size: 20),
                            onPressed: appState.targetHours < 300
                                ? () => context.read<AppState>().updateTargetHours(appState.targetHours + 5)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 2: NOTIFICACIONES
              _buildSectionTitle('Recordatorios'),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Toggle Notifications
                    _buildSettingsRow(
                      icon: Icons.notifications_active_rounded,
                      title: 'Notificaciones Diarias',
                      subtitle: 'Recordar registrar las horas',
                      trailing: Switch(
                        value: kIsWeb ? false : appState.reminderEnabled,
                        activeColor: AppTheme.primaryBlue,
                        inactiveThumbColor: Colors.white60,
                        inactiveTrackColor: Colors.white10,
                        onChanged: (bool value) {
                          if (kIsWeb) {
                            _showWebNotificationsLimitDialog(context);
                          } else {
                            context.read<AppState>().toggleReminder(value);
                          }
                        },
                      ),
                    ),
                    
                    if (appState.reminderEnabled) ...[
                      const Divider(color: Colors.white10, height: 24),
                      // Time Picker for notifications
                      _buildSettingsRow(
                        icon: Icons.schedule_rounded,
                        title: 'Hora del Recordatorio',
                        subtitle: 'Hora de envío de la notificación',
                        trailing: InkWell(
                          onTap: () => _selectReminderTime(context, appState.reminderTime),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Text(
                              appState.reminderTime,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECCIÓN 3: UBICACIÓN DE TRABAJO (FESTIVOS)
              _buildSectionTitle('Ubicación de Trabajo'),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // CCAA Dropdown Selector
                    _buildSettingsRow(
                      icon: Icons.location_city_rounded,
                      title: 'Comunidad Autónoma',
                      subtitle: 'Festivos oficiales según tu ubicación',
                      trailing: appState.isLoadingHolidays
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryBlue,
                              ),
                            )
                          : DropdownButton<String>(
                              value: appState.workStateCode.isEmpty ? null : appState.workStateCode,
                              hint: const Text('Seleccionar', style: TextStyle(color: Colors.white30, fontSize: 14)),
                              dropdownColor: AppTheme.darkBgEnd,
                              underline: const SizedBox(),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  final states = {
                                    "AN": "Andalucía",
                                    "AR": "Aragón",
                                    "AS": "Asturias",
                                    "CB": "Cantabria",
                                    "CE": "Ciudad de Ceuta",
                                    "CL": "Castilla y León",
                                    "CM": "Castile-La Mancha",
                                    "CN": "Islas Canarias",
                                    "CT": "Cataluña",
                                    "EX": "Extremadura",
                                    "GA": "Galicia",
                                    "IB": "Illes Balears",
                                    "MC": "Murcia Region",
                                    "MD": "Comunidad de Madrid",
                                    "ML": "Ciudad de Melilla",
                                    "NC": "Comunidad Foral de Navarra",
                                    "PV": "País Vasco",
                                    "RI": "La Rioja",
                                    "VC": "Comunitat Valenciana"
                                  };
                                  context.read<AppState>().updateWorkState(newValue, states[newValue]!);
                                }
                              },
                              items: const [
                                DropdownMenuItem(value: "AN", child: Text("Andalucía")),
                                DropdownMenuItem(value: "AR", child: Text("Aragón")),
                                DropdownMenuItem(value: "AS", child: Text("Asturias")),
                                DropdownMenuItem(value: "CB", child: Text("Cantabria")),
                                DropdownMenuItem(value: "CE", child: Text("Ceuta")),
                                DropdownMenuItem(value: "CL", child: Text("Castilla y León")),
                                DropdownMenuItem(value: "CM", child: Text("Castilla-La Mancha")),
                                DropdownMenuItem(value: "CN", child: Text("Islas Canarias")),
                                DropdownMenuItem(value: "CT", child: Text("Cataluña")),
                                DropdownMenuItem(value: "EX", child: Text("Extremadura")),
                                DropdownMenuItem(value: "GA", child: Text("Galicia")),
                                DropdownMenuItem(value: "IB", child: Text("Islas Baleares")),
                                DropdownMenuItem(value: "MC", child: Text("Murcia")),
                                DropdownMenuItem(value: "MD", child: Text("Madrid")),
                                DropdownMenuItem(value: "ML", child: Text("Melilla")),
                                DropdownMenuItem(value: "NC", child: Text("Navarra")),
                                DropdownMenuItem(value: "PV", child: Text("País Vasco")),
                                DropdownMenuItem(value: "RI", child: Text("La Rioja")),
                                DropdownMenuItem(value: "VC", child: Text("Comunitat Valenciana")),
                              ],
                            ),
                    ),
                    if (appState.workStateCode.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, color: AppTheme.moneyGreen, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${appState.holidays.where((h) => !h.isLocal).length} festivos de la CCAA cargados',
                            style: const TextStyle(fontSize: 12, color: Colors.white60),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECCIÓN 4: FESTIVOS LOCALES (CIUDAD/MANUALES)
              _buildSectionTitle('Festivos Locales'),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Días Festivos de tu Ciudad',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                'Añade festivos específicos locales',
                                style: TextStyle(color: Colors.white38, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddLocalHolidayDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.08),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.white10),
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Añadir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (appState.localHolidays.isNotEmpty) ...[
                      const Divider(color: Colors.white10, height: 24),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: appState.localHolidays.length,
                        itemBuilder: (context, index) {
                          final holiday = appState.localHolidays[index];
                          final dateStr = '${holiday.date.day.toString().padLeft(2, '0')}/${holiday.date.month.toString().padLeft(2, '0')}/${holiday.date.year}';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.festival_rounded, color: AppTheme.warningOrange, size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        holiday.name,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        dateStr,
                                        style: const TextStyle(fontSize: 11, color: Colors.white38),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 20),
                                  onPressed: () {
                                    context.read<AppState>().removeLocalHoliday(holiday.date);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      const Text(
                        'No has añadido festivos locales todavía.',
                        style: TextStyle(color: Colors.white30, fontSize: 13, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // SECTION 3: ACCIONES PELIGROSAS
              GlassCard(
                padding: const EdgeInsets.all(8),
                bgColor: AppTheme.errorRed.withOpacity(0.06),
                child: ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: AppTheme.errorRed),
                  title: const Text(
                    'Restablecer Aplicación',
                    style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Eliminar datos y volver al estado de fábrica'),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white30),
                  onTap: () => _showResetDialog(context),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryBlue.withOpacity(0.9),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}
