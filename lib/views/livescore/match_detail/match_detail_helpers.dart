import 'package:flutter/material.dart';

/// Pure static helpers with no dependency on match state.
class H {
  H._();

  // ── Image ────────────────────────────────────────────────────────────────

  static String? teamImageUrl(String imagePath) {
    final t = imagePath.trim();
    if (t.isEmpty) return null;
    final src = t.startsWith('http')
        ? t
        : 'https://storage.livescore.com/images/team/medium/$t';
    return 'https://getimage.membertsd.workers.dev/?url=${Uri.encodeComponent(src)}';
  }

  // ── Text ─────────────────────────────────────────────────────────────────

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  static String displayScore(String score) {
    final t = score.trim();
    return t.isEmpty ? '0' : t;
  }

  static String firstNonEmpty(List<String> values) {
    for (final v in values) {
      final t = v.trim();
      if (t.isNotEmpty) return t;
    }
    return '';
  }

  // ── Status ────────────────────────────────────────────────────────────────

  static String statusLabel(String status) {
    const m = {
      'NS': 'Not Started', '1H': '1st Half',   'HT': 'Half Time',
      '2H': '2nd Half',    'ET': 'Extra Time',  'EH': 'Extra Time 1st Half',
      'EHT': 'Extra Time Half Time',             'E2H': 'Extra Time 2nd Half',
      'PEN': 'Penalties',  'FT': 'Full Time',   'AET': 'After Extra Time',
      'AP': 'After Penalties', 'Postp': 'Postponed', 'Cancl': 'Cancelled',
      'Susp': 'Suspended', 'Awd': 'Awarded',    'WO': 'Walkover',
      'Aban': 'Abandoned', 'LIVE': 'Live',
    };
    return m[status] ?? status;
  }

  static Color statusColor(String status) {
    switch (status) {
      case '1H': case '2H': case 'ET': case 'EH': case 'E2H':
      case 'PEN': case 'LIVE':
      return Colors.red.shade400;
      case 'HT': case 'EHT':
      return Colors.orange.shade400;
      case 'FT': case 'AET': case 'AP':
      return Colors.green.shade400;
      default:
        return Colors.white.withOpacity(0.6);
    }
  }

  static String statusBadgeText(String status) {
    switch (status) {
      case 'NS':    return 'UPCOMING';
      case '1H':    return 'LIVE · 1H';
      case 'HT':    return 'HALF TIME';
      case '2H':    return 'LIVE · 2H';
      case 'ET': case 'EH': case 'E2H': return 'LIVE · ET';
      case 'EHT':   return 'ET HALF TIME';
      case 'PEN':   return 'LIVE · PEN';
      case 'FT':    return 'ENDED';
      case 'AET':   return 'ENDED · AET';
      case 'AP':    return 'ENDED · AP';
      case 'LIVE':  return 'LIVE';
      case 'Postp': return 'POSTPONED';
      case 'Cancl': return 'CANCELLED';
      case 'Susp':  return 'SUSPENDED';
      case 'Aban':  return 'ABANDONED';
      default:      return status;
    }
  }

  // ── Dates ─────────────────────────────────────────────────────────────────

  static String formatDateTime(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} at $hh:$mm';
  }

  static String formatH2HDate(String raw) {
    final t = raw.trim();
    if (t.length >= 14) {
      return '${t.substring(6,8)}/${t.substring(4,6)}/${t.substring(0,4)} ${t.substring(8,10)}:${t.substring(10,12)}';
    }
    if (t.length >= 8) {
      return '${t.substring(6,8)}/${t.substring(4,6)}/${t.substring(0,4)}';
    }
    return '-';
  }

  // ── Timeline ──────────────────────────────────────────────────────────────

  static int asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int timelineMinuteSortValue(String value) {
    final n = value.replaceAll("'", '').trim();
    final parts = n.split('+');
    final base  = int.tryParse(parts.first.trim()) ?? 0;
    final extra = parts.length > 1 ? (int.tryParse(parts[1].trim()) ?? 0) : 0;
    return base * 100 + extra;
  }

  static String formatTimelineMinute(int minute, int minuteExtra) {
    if (minute <= 0 && minuteExtra <= 0) return '';
    if (minuteExtra > 0) return '$minute+$minuteExtra\'';
    return '$minute\'';
  }

  static int timelineSortKey(int minute, int minuteExtra) => (minute * 100) + minuteExtra;

  // ── Data reading ──────────────────────────────────────────────────────────

  static String readDisplayValue(
      Map<String, dynamic> source, List<String> keys, String fallback) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }

  static String readNested(
      Map<String, dynamic> source, List<String> paths, String fallback) {
    for (final path in paths) {
      dynamic cur = source;
      for (final part in path.split('.')) {
        if (cur is Map<String, dynamic>) {
          cur = cur[part];
        } else if (cur is List<dynamic>) {
          final idx = int.tryParse(part);
          if (idx == null || idx < 0 || idx >= cur.length) { cur = null; break; }
          cur = cur[idx];
        } else {
          cur = null; break;
        }
      }
      if (cur == null) continue;
      final text = cur.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }
}