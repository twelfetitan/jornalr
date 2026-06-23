import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;

  late double _hourlyRate;
  late String _currency;
  late double _targetHours;
  late Map<String, double> _workEntries;
  late Map<String, String> _dayNotes;
  late bool _reminderEnabled;
  late String _reminderTime;
  
  DateTime _selectedDate = DateTime.now();

  AppState(this._storageService, this._notificationService) {
    _loadFromStorage();
  }

  // Load configuration from local storage
  void _loadFromStorage() {
    _hourlyRate = _storageService.getHourlyRate();
    _currency = _storageService.getCurrency();
    _targetHours = _storageService.getTargetHours();
    _workEntries = _storageService.getWorkEntries();
    _dayNotes = _storageService.getDayNotes();
    _reminderEnabled = _storageService.isReminderEnabled();
    _reminderTime = _storageService.getReminderTime();
  }

  // Getters
  double get hourlyRate => _hourlyRate;
  String get currency => _currency;
  double get targetHours => _targetHours;
  Map<String, double> get workEntries => _workEntries;
  Map<String, String> get dayNotes => _dayNotes;
  bool get reminderEnabled => _reminderEnabled;
  String get reminderTime => _reminderTime;
  DateTime get selectedDate => _selectedDate;

  // Selected Date helper
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Helper: Format DateTime to YYYY-MM-DD
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Get hours for a specific date
  double getHoursForDate(DateTime date) {
    final String key = _formatDateKey(date);
    return _workEntries[key] ?? 0.0;
  }

  // Set hours for a specific date (and persist)
  Future<void> setHoursForDate(DateTime date, double hours) async {
    final String key = _formatDateKey(date);
    if (hours <= 0.0) {
      _workEntries.remove(key);
    } else {
      _workEntries[key] = hours;
    }
    await _storageService.saveWorkEntries(_workEntries);
    notifyListeners();
  }

  // Get note for a specific date
  String getNoteForDate(DateTime date) {
    final String key = _formatDateKey(date);
    return _dayNotes[key] ?? '';
  }

  // Set note for a specific date (and persist)
  Future<void> setNoteForDate(DateTime date, String note) async {
    final String key = _formatDateKey(date);
    if (note.trim().isEmpty) {
      _dayNotes.remove(key);
    } else {
      _dayNotes[key] = note.trim();
    }
    await _storageService.saveDayNotes(_dayNotes);
    notifyListeners();
  }

  // Calculate total hours for a specific month
  double getTotalHoursForMonth(DateTime monthDate) {
    double total = 0.0;
    _workEntries.forEach((key, hours) {
      final List<String> parts = key.split('-');
      if (parts.length == 3) {
        final int year = int.parse(parts[0]);
        final int month = int.parse(parts[1]);
        if (year == monthDate.year && month == monthDate.month) {
          total += hours;
        }
      }
    });
    return total;
  }

  // Calculate earnings for a specific month
  double getEarningsForMonth(DateTime monthDate) {
    return getTotalHoursForMonth(monthDate) * _hourlyRate;
  }

  // Calculate progress of hours compared to target (returns value between 0.0 and 1.0)
  double getMonthlyProgress(DateTime monthDate) {
    if (_targetHours <= 0.0) return 0.0;
    final double hours = getTotalHoursForMonth(monthDate);
    return (hours / _targetHours).clamp(0.0, 1.0);
  }

  // Update hourly rate
  Future<void> updateHourlyRate(double rate) async {
    _hourlyRate = rate;
    await _storageService.setHourlyRate(rate);
    notifyListeners();
  }

  // Update currency symbol
  Future<void> updateCurrency(String currency) async {
    _currency = currency;
    await _storageService.setCurrency(currency);
    notifyListeners();
  }

  // Update target hours
  Future<void> updateTargetHours(double hours) async {
    _targetHours = hours;
    await _storageService.setTargetHours(hours);
    notifyListeners();
  }

  // Enable/Disable local reminders
  Future<void> toggleReminder(bool enabled) async {
    _reminderEnabled = enabled;
    await _storageService.setReminderEnabled(enabled);
    
    if (enabled) {
      // Ask for permissions first
      final bool permissionGranted = await _notificationService.requestPermissions();
      if (permissionGranted) {
        await _updateNotifications();
      } else {
        // If not granted, disable setting again
        _reminderEnabled = false;
        await _storageService.setReminderEnabled(false);
      }
    } else {
      await _notificationService.cancelDailyReminder();
    }
    notifyListeners();
  }

  // Update reminder time (e.g. "20:00")
  Future<void> updateReminderTime(String time) async {
    _reminderTime = time;
    await _storageService.setReminderTime(time);
    if (_reminderEnabled) {
      await _updateNotifications();
    }
    notifyListeners();
  }

  // Internal helper to schedule notifications based on string time
  Future<void> _updateNotifications() async {
    final List<String> parts = _reminderTime.split(':');
    if (parts.length == 2) {
      final int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);
      await _notificationService.scheduleDailyReminder(hour, minute);
    }
  }

  // Reset all app data
  Future<void> resetAllData() async {
    await _storageService.clearAllData();
    await _notificationService.cancelDailyReminder();
    _loadFromStorage(); // Reload default configuration
    notifyListeners();
  }
}
