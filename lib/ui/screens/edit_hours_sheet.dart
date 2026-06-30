import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state.dart';
import '../../main.dart';
import '../theme.dart';
import '../widgets/hours_picker.dart';

class EditHoursSheet extends StatefulWidget {
  final AppState appState;
  final DateTime date;

  const EditHoursSheet({
    super.key,
    required this.appState,
    required this.date,
  });

  @override
  State<EditHoursSheet> createState() => _EditHoursSheetState();
}

class _EditHoursSheetState extends State<EditHoursSheet> {
  late double _tempHours;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    // El controller se crea y destruye dentro de este State
    _tempHours = widget.appState.getHoursForDate(widget.date);
    _noteController = TextEditingController(
      text: widget.appState.getNoteForDate(widget.date),
    );
  }

  @override
  void dispose() {
    _noteController.dispose(); // Flutter lo llama automáticamente al cerrar
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE d \'de\' MMMM, yyyy', 'es_ES').format(widget.date);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.only(
          top: 24, left: 20, right: 20, bottom: 24,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF131124),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: AppTheme.glassCardBorder, width: 1.5),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull handler
              Center(
                child: Container(
                  width: 48, height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Date Title
              Text(
                formattedDate[0].toUpperCase() + formattedDate.substring(1),
                style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Holiday Name Chip
              if (widget.appState.isHoliday(widget.date)) ...[
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.festival_rounded, color: AppTheme.errorRed, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          widget.appState.getHolidayName(widget.date) ?? 'Festivo',
                          style: const TextStyle(
                            color: AppTheme.errorRed,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              const Text(
                'Modifica las horas trabajadas en este día',
                style: TextStyle(fontSize: 14, color: Colors.white38),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Hours Picker
              HoursPicker(
                value: _tempHours,
                onChanged: (newHours) {
                  setState(() => _tempHours = newHours);
                },
              ),
              const SizedBox(height: 24),

              // Notes TextField
              TextField(
                controller: _noteController,
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Notas / Comentarios (opcional)',
                  labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                  hintText: 'Ej. Falté por cita médica, festivo...',
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                  prefixIcon: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryBlue, size: 28),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.03),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.glassCardBorder, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: () async {
                  final noteText = _noteController.text;
                  final hours = _tempHours;
                  final date = widget.date;

                  await widget.appState.setHoursForDate(date, hours);
                  await widget.appState.setNoteForDate(date, noteText);

                  if (mounted) Navigator.of(context).pop();

                  final String hoursText = hours.toStringAsFixed(
                    hours % 1 == 0 ? 0 : (hours % 0.5 == 0 ? 1 : 2),
                  );
                  scaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(
                      content: Text(
                        hours > 0
                            ? 'Registradas $hoursText horas para el día ${date.day}.'
                            : 'Registro eliminado para el día ${date.day}.',
                      ),
                      backgroundColor: AppTheme.moneyGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Guardar Cambios',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}