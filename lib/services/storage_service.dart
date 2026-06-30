import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyHourlyRate = 'hourly_rate';
  static const String _keySpecialHourlyRate = 'special_hourly_rate';
  static const String _keyCurrency = 'currency';
  static const String _keyTargetHours = 'target_hours';
  static const String _keyWorkEntries = 'work_entries';
  static const String _keyDayNotes = 'day_notes';
  static const String _keyReminderEnabled = 'reminder_enabled';
  static const String _keyReminderTime = 'reminder_time';
  static const String _keyWorkStateCode = 'work_state_code';
  static const String _keyWorkStateName = 'work_state_name';
  static const String _keyHolidaysCache = 'holidays_cache';
  static const String _keyHolidaysCacheKey = 'holidays_cache_key';
  static const String _keyLocalHolidays = 'local_holidays';

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

  // Special Hourly Rate (Weekends & Holidays)
  double getSpecialHourlyRate() {
    return _prefs.getDouble(_keySpecialHourlyRate) ?? 20.0; // Default to 20.0
  }

  Future<void> setSpecialHourlyRate(double rate) async {
    await _prefs.setDouble(_keySpecialHourlyRate, rate);
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

  // --- Holidays: Work Location ---

  // Work State Code (e.g. "MD" for Madrid)
  String getWorkStateCode() {
    return _prefs.getString(_keyWorkStateCode) ?? '';
  }

  Future<void> setWorkStateCode(String code) async {
    await _prefs.setString(_keyWorkStateCode, code);
  }

  // Work State Name (e.g. "Comunidad de Madrid")
  String getWorkStateName() {
    return _prefs.getString(_keyWorkStateName) ?? '';
  }

  Future<void> setWorkStateName(String name) async {
    await _prefs.setString(_keyWorkStateName, name);
  }

  // --- Holidays: API Cache ---

  // Cache key format: "{stateCode}_{year}" for invalidation
  String getHolidaysCacheKey() {
    return _prefs.getString(_keyHolidaysCacheKey) ?? '';
  }

  Future<void> setHolidaysCacheKey(String key) async {
    await _prefs.setString(_keyHolidaysCacheKey, key);
  }

  // Cached holidays (JSON-serialized list of Holiday objects)
  String getHolidaysCache() {
    return _prefs.getString(_keyHolidaysCache) ?? '[]';
  }

  Future<void> saveHolidaysCache(String jsonData) async {
    await _prefs.setString(_keyHolidaysCache, jsonData);
  }

  // --- Holidays: Local (manually added by user) ---

  String getLocalHolidays() {
    return _prefs.getString(_keyLocalHolidays) ?? '[]';
  }

  Future<void> saveLocalHolidays(String jsonData) async {
    await _prefs.setString(_keyLocalHolidays, jsonData);
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
