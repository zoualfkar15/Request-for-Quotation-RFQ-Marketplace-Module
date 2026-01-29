import 'package:intl/intl.dart';

class DateTimeHelper {
  static final DateFormat _ymd = DateFormat('yyyy-MM-dd');
  static final DateFormat _ymdHms = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Parses "YYYY-MM-DD HH:mm:ss" as a UTC time and converts to local.
  static DateTime? utcToLocal(String? utcYmdHms) {
    if (utcYmdHms == null) return null;
    final s = utcYmdHms.trim();
    if (s.isEmpty) return null;
    try {
      final parts = s.split(RegExp(r'\s+'));
      if (parts.length != 2) return null;
      final date = parts[0].split('-').map(int.parse).toList(growable: false);
      final time = parts[1].split(':').map(int.parse).toList(growable: false);
      if (date.length != 3 || time.length != 3) return null;
      return DateTime.utc(date[0], date[1], date[2], time[0], time[1], time[2])
          .toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Parses "YYYY-MM-DD HH:mm:ss" as local time and formats it as UTC string.
  static String? localToUtcString(String? localYmdHms) {
    if (localYmdHms == null) return null;
    final s = localYmdHms.trim();
    if (s.isEmpty) return null;
    try {
      // Treat input as local, then convert to UTC.
      final local = _ymdHms.parseStrict(s);
      final utc = local.toUtc();
      return _ymdHms.format(utc);
    } catch (_) {
      return null;
    }
  }

  static String formatLocalDateTimeFromUtc(String? utcYmdHms) {
    final dt = utcToLocal(utcYmdHms);
    if (dt == null) return '';
    return _ymdHms.format(dt);
  }

  static String formatLocalDate(String? ymd) {
    if (ymd == null) return '';
    final s = ymd.trim();
    if (s.isEmpty) return '';
    try {
      final d = _ymd.parseStrict(s);
      return _ymd.format(d);
    } catch (_) {
      return s;
    }
  }
}


