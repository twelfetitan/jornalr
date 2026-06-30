import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/holiday.dart';

/// Service responsible for fetching public holidays from the generadordni.es API.
class HolidayService {
  static const String _baseUrl = 'https://api.generadordni.es/v2/holidays';

  /// Fetches public holidays for a given Spanish autonomous community and year.
  ///
  /// Only returns holidays with type "public" (official non-working days).
  /// Returns an empty list if the API call fails.
  Future<List<Holiday>> fetchHolidays(String stateCode, int year) async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/holidays?country=ES&state=$stateCode&year=$year');
      final http.Response response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;

        // Filter only "public" type holidays and parse them
        final List<Holiday> holidays = data
            .where((item) => item['type'] == 'public')
            .map<Holiday>((item) {
              // The API returns date as "2026-01-01 00:00:00", extract the date part
              final String dateStr = (item['date'] as String).split(' ').first;
              return Holiday(
                date: DateTime.parse(dateStr),
                name: item['name'] as String,
                isLocal: false,
              );
            })
            .toList();

        // Sort by date
        holidays.sort((a, b) => a.date.compareTo(b.date));
        return holidays;
      } else {
        return [];
      }
    } catch (e) {
      // Network error, timeout, or parse error — return empty list
      return [];
    }
  }
}
