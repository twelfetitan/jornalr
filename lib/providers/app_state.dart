import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/holiday.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/holiday_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;
  final HolidayService _holidayService;

  late double _hourlyRate;
  late double _specialHourlyRate;
  late String _currency;
  late double _targetHours;
  late Map<String, double> _workEntries;
  late Map<String, String> _dayNotes;
  late bool _reminderEnabled;
  late String _reminderTime;
  
  // Holidays
  late String _workStateCode;
  late String _workStateName;
  List<Holiday> _holidays = [];
  List<Holiday> _localHolidays = [];
  bool _isLoadingHolidays = false;
  
  DateTime _selectedDate = DateTime.now();

  AppState(this._storageService, this._notificationService, this._holidayService) {
    _loadFromStorage();
    // Load holidays asynchronously without blocking
    loadHolidays();
  }

  // Load configuration from local storage
  void _loadFromStorage() {
    _hourlyRate = _storageService.getHourlyRate();
    _specialHourlyRate = _storageService.getSpecialHourlyRate();
    _currency = _storageService.getCurrency();
    _targetHours = _storageService.getTargetHours();
    _workEntries = _storageService.getWorkEntries();
    _dayNotes = _storageService.getDayNotes();
    _reminderEnabled = _storageService.isReminderEnabled();
    _reminderTime = _storageService.getReminderTime();
    _workStateCode = _storageService.getWorkStateCode();
    _workStateName = _storageService.getWorkStateName();
    _loadLocalHolidaysFromStorage();
  }

  /// Load local holidays from storage
  void _loadLocalHolidaysFromStorage() {
    try {
      final String jsonStr = _storageService.getLocalHolidays();
      final List<dynamic> decoded = json.decode(jsonStr) as List<dynamic>;
      _localHolidays = decoded
          .map((item) => Holiday.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _localHolidays = [];
    }
  }

  // Getters
  double get hourlyRate => _hourlyRate;
  double get specialHourlyRate => _specialHourlyRate;
  String get currency => _currency;
  double get targetHours => _targetHours;
  Map<String, double> get workEntries => _workEntries;
  Map<String, String> get dayNotes => _dayNotes;
  bool get reminderEnabled => _reminderEnabled;
  String get reminderTime => _reminderTime;
  DateTime get selectedDate => _selectedDate;

  // Holiday Getters
  String get workStateCode => _workStateCode;
  String get workStateName => _workStateName;
  List<Holiday> get holidays => [..._holidays, ..._localHolidays];
  List<Holiday> get localHolidays => _localHolidays;
  bool get isLoadingHolidays => _isLoadingHolidays;

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

  // Calculate rate for a given date (special rate on weekend or holiday)
  double getRateForDate(DateTime date) {
    final bool isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    if (isWeekend || isHoliday(date)) {
      return _specialHourlyRate;
    }
    return _hourlyRate;
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

  // Calculate earnings for a specific month summing rate per day dynamically
  double getEarningsForMonth(DateTime monthDate) {
    double totalEarnings = 0.0;
    _workEntries.forEach((key, hours) {
      final List<String> parts = key.split('-');
      if (parts.length == 3) {
        final int year = int.parse(parts[0]);
        final int month = int.parse(parts[1]);
        final int day = int.parse(parts[2]);
        if (year == monthDate.year && month == monthDate.month) {
          final DateTime date = DateTime(year, month, day);
          totalEarnings += hours * getRateForDate(date);
        }
      }
    });
    return totalEarnings;
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

  // Update special hourly rate
  Future<void> updateSpecialHourlyRate(double rate) async {
    _specialHourlyRate = rate;
    await _storageService.setSpecialHourlyRate(rate);
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

  // ============================================================
  // HOLIDAYS
  // ============================================================

  /// Check if a specific date is a holiday (API or local).
  bool isHoliday(DateTime date) {
    final allHolidays = [..._holidays, ..._localHolidays];
    return allHolidays.any((h) => h.isOnDate(date));
  }

  /// Get the holiday name for a specific date, or null if not a holiday.
  String? getHolidayName(DateTime date) {
    final allHolidays = [..._holidays, ..._localHolidays];
    for (final h in allHolidays) {
      if (h.isOnDate(date)) return h.name;
    }
    return null;
  }

  /// Load holidays from cache or API. Only calls the API if the cache
  /// key (stateCode + year) has changed.
  Future<void> loadHolidays() async {
    if (_workStateCode.isEmpty) return;

    final int currentYear = DateTime.now().year;
    final String expectedKey = '${_workStateCode}_$currentYear';
    final String cachedKey = _storageService.getHolidaysCacheKey();

    if (expectedKey == cachedKey) {
      // Cache is valid — load from storage
      _loadHolidaysFromCache();
    } else {
      // Cache is stale or missing — fetch from API
      await _fetchAndCacheHolidays(_workStateCode, currentYear);
    }
  }

  /// Load holidays from the cached JSON in SharedPreferences.
  void _loadHolidaysFromCache() {
    try {
      final String jsonStr = _storageService.getHolidaysCache();
      final List<dynamic> decoded = json.decode(jsonStr) as List<dynamic>;
      _holidays = decoded
          .map((item) => Holiday.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      _holidays = [];
    }
  }

  /// Fetch holidays from the API and cache them.
  Future<void> _fetchAndCacheHolidays(String stateCode, int year) async {
    _isLoadingHolidays = true;
    notifyListeners();

    try {
      final List<Holiday> fetched = await _holidayService.fetchHolidays(stateCode, year);
      _holidays = fetched;

      // Serialize and cache
      final String jsonStr = json.encode(fetched.map((h) => h.toJson()).toList());
      await _storageService.saveHolidaysCache(jsonStr);
      await _storageService.setHolidaysCacheKey('${stateCode}_$year');
    } catch (e) {
      _holidays = [];
    }

    _isLoadingHolidays = false;
    notifyListeners();
  }

  /// Update the user's work state (autonomous community) and reload holidays.
  Future<void> updateWorkState(String code, String name) async {
    _workStateCode = code;
    _workStateName = name;
    await _storageService.setWorkStateCode(code);
    await _storageService.setWorkStateName(name);
    
    // Force re-fetch since state changed
    final int currentYear = DateTime.now().year;
    await _fetchAndCacheHolidays(code, currentYear);
  }

  /// Add a local holiday (manually by the user).
  Future<void> addLocalHoliday(DateTime date, String name) async {
    // Avoid duplicate on same date
    _localHolidays.removeWhere((h) => h.isOnDate(date));
    _localHolidays.add(Holiday(date: date, name: name, isLocal: true));
    _localHolidays.sort((a, b) => a.date.compareTo(b.date));
    await _saveLocalHolidays();
    notifyListeners();
  }

  /// Remove a local holiday.
  Future<void> removeLocalHoliday(DateTime date) async {
    _localHolidays.removeWhere((h) => h.isOnDate(date));
    await _saveLocalHolidays();
    notifyListeners();
  }

  /// Persist local holidays to SharedPreferences.
  Future<void> _saveLocalHolidays() async {
    final String jsonStr = json.encode(_localHolidays.map((h) => h.toJson()).toList());
    await _storageService.saveLocalHolidays(jsonStr);
  }

  // Reset all app data
  Future<void> resetAllData() async {
    await _storageService.clearAllData();
    await _notificationService.cancelDailyReminder();
    _holidays = [];
    _localHolidays = [];
    _loadFromStorage(); // Reload default configuration
    notifyListeners();
  }
}
