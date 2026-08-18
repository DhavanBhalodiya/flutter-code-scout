import 'package:intl/intl.dart';

/// Helper utility for formatting movie dates and runtimes.
class DateFormatter {
  DateFormatter._();

  /// Formats an ISO date string (e.g. '2023-11-20') to 'Nov 20, 2023'.
  static String formatFullDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) {
      return 'N/A';
    }
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat.yMMMd().format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  /// Extracts the year from an ISO date string (e.g. '2023').
  static String formatYear(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) {
      return 'N/A';
    }
    try {
      final parsed = DateTime.parse(rawDate);
      return parsed.year.toString();
    } catch (_) {
      return rawDate;
    }
  }

  /// Formats movie runtime minutes to '1h 45m'.
  static String formatRuntime(int? minutes) {
    if (minutes == null || minutes <= 0) {
      return 'N/A';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0 && remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${remainingMinutes}m';
    }
  }
}
