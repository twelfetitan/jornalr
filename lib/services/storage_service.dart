import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyHourlyRate = 'hourly_rate';
  static const String _keyCurrency = 'currency';
  static const String _keyTargetHours = 'target_hours';
  static const String _keyWorkEntries = 'work_entries';
  static const String _keyDayNotes = 'day_notes';
  static const String _keyReminderEnabled = 'reminder_enabled';
  static const String _keyReminderTime = 'reminder_time';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Initializer
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Hourly Rate
  double getHourlyRate() {
    return _prefs.getDouble(_keyHourlyRate) ?? 15.0; // Default to 15.0
  }

  Future<void> setHourlyRate(double rate) async {
    await _prefs.setDouble(_keyHourlyRate, rate);
  }

  // Currency
  String getCurrency() {
    return _prefs.getString(_keyCurrency) ?? '€'; // Default to Euro
  }

  Future<void> setCurrency(String currency) async {
    await _prefs.setString(_keyCurrency, currency);
  }

  // Target Hours
  double getTargetHours() {
    return _prefs.getDouble(_keyTargetHours) ?? 160.0; // Default to 160.0 hours
  }

  Future<void> setTargetHours(double hours) async {
    await _prefs.setDouble(_keyTargetHours, hours);
  }

  // Work Entries
  Map<String, double> getWorkEntries() {
    final String? entriesJson = _prefs.getString(_keyWorkEntries);
    if (entriesJson == null) return {};
    try {
      final Map<String, dynamic> decoded = json.decode(entriesJson);
      return decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
    } catch (e) {
      return {};
    }
  }

  Future<void> saveWorkEntries(Map<String, double> entries) async {
    final String encoded = json.encode(entries);
    await _prefs.setString(_keyWorkEntries, encoded);
  }

  // Reminders Configuration
  bool isReminderEnabled() {
    return _prefs.getBool(_keyReminderEnabled) ?? false; // Default to disabled
  }

  Future<void> setReminderEnabled(bool enabled) async {
    await _prefs.setBool(_keyReminderEnabled, enabled);
  }

  String getReminderTime() {
    return _prefs.getString(_keyReminderTime) ?? '20:00'; // Default to 8:00 PM
  }

  Future<void> setReminderTime(String time) async {
    await _prefs.setString(_keyReminderTime, time);
  }

  // Day Notes
  Map<String, String> getDayNotes() {
    final String? notesJson = _prefs.getString(_keyDayNotes);
    if (notesJson == null) return {};
    try {
      final Map<String, dynamic> decoded = json.decode(notesJson);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }

  Future<void> saveDayNotes(Map<String, String> notes) async {
    final String encoded = json.encode(notes);
    await _prefs.setString(_keyDayNotes, encoded);
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
