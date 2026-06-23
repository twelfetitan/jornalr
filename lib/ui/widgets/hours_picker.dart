import 'package:flutter/material.dart';
import '../theme.dart';

class HoursPicker extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const HoursPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  // Presets of hours
  static const List<double> _presets = [0, 4, 8, 10, 12];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stepper with hours display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decrement Button
            _buildIconButton(
              icon: Icons.remove_rounded,
              onPressed: value > 0 ? () => onChanged((value - 0.25).clamp(0.0, 24.0)) : null,
            ),
            const SizedBox(width: 24),
            
            // Value display
            Container(
              width: 140,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    value.toStringAsFixed(value % 1 == 0 ? 0 : (value % 0.5 == 0 ? 1 : 2)),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    value == 1 ? 'hora trabajada' : 'horas trabajadas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            
            // Increment Button
            _buildIconButton(
              icon: Icons.add_rounded,
              onPressed: value < 24 ? () => onChanged((value + 0.25).clamp(0.0, 24.0)) : null,
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Custom Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 24.0,
            divisions: 96, // 24 hours * 4 steps per hour = 96 divisions
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 16),
        
        // Presets chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _presets.map((preset) {
              final isSelected = value == preset;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text('${preset.toStringAsFixed(preset % 1 == 0 ? 0 : (preset % 0.5 == 0 ? 1 : 2))}h'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onChanged(preset);
                    }
                  },
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: FontWeight.w600,
                  ),
                   selectedColor: AppTheme.primaryBlue,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : Colors.white10,
                      width: 1,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({required IconData icon, VoidCallback? onPressed}) {
    final bool disabled = onPressed == null;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: disabled
            ? null
            : const LinearGradient(
                colors: [Color(0x1AFFFFFF), Color(0x0AFFFFFF)],
              ),
        border: Border.all(
          color: disabled ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: 28,
        color: disabled ? Colors.white.withOpacity(0.2) : Colors.white,
        onPressed: onPressed,
      ),
    );
  }
}
