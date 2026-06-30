/// Represents a holiday (public or local).
class Holiday {
  final DateTime date;
  final String name;
  final bool isLocal; // true if manually added by the user

  Holiday({
    required this.date,
    required this.name,
    this.isLocal = false,
  });

  /// Create a Holiday from a JSON map (API response or cache).
  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      date: DateTime.parse(json['date'] as String),
      name: json['name'] as String,
      isLocal: json['isLocal'] as bool? ?? false,
    );
  }

  /// Serialize to JSON map for cache storage.
  Map<String, dynamic> toJson() {
    return {
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'name': name,
      'isLocal': isLocal,
    };
  }

  /// Check if this holiday falls on the given date (ignoring time).
  bool isOnDate(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }
}
