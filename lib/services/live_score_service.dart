import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/match_item.dart';

class LiveScoreService {
  const LiveScoreService();

  Future<List<MatchItem>> fetchMatchesByDate({
    required String category,
    required DateTime date,
    double timezone = -7,
  }) async {
    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}${ApiConfig.liveScorePath}',
    ).replace(
      queryParameters: {
        'Category': category,
        'Date': _formatDate(date),
        'Timezone': timezone.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-rapidapi-key': ApiConfig.liveScoreApiKey,
        'x-rapidapi-host': ApiConfig.liveScoreApiHost,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> stages = _extractStages(decoded);

    return stages
        .expand((dynamic stage) => _parseStageMatches(stage))
        .take(12)
        .toList();
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  List<dynamic> _extractStages(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final scores = decoded['Stages'] ?? decoded['stages'];
      if (scores is List<dynamic>) {
        return scores;
      }

      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        final nestedStages = data['Stages'] ?? data['stages'];
        if (nestedStages is List<dynamic>) {
          return nestedStages;
        }
      }
    }

    return const [];
  }

  List<MatchItem> _parseStageMatches(dynamic stage) {
    if (stage is! Map<String, dynamic>) {
      return const [];
    }

    final competition = _readString(
      stage,
      const ['CompN', 'Snm', 'competitionName', 'name'],
      fallback: 'Competition',
    );
    final country = _readString(
      stage,
      const ['CompD', 'CompST', 'Cnm', 'Csnm', 'country', 'region'],
      fallback: 'International',
    );

    final events = stage['Events'] ?? stage['events'];
    if (events is! List<dynamic>) {
      return const [];
    }

    return events
        .map((dynamic event) => _parseEvent(event, competition, country))
        .whereType<MatchItem>()
        .toList();
  }

  MatchItem? _parseEvent(dynamic event, String competition, String country) {
    if (event is! Map<String, dynamic>) {
      return null;
    }

    final homeTeam = _readString(
      event,
      const ['T1.0.Nm', 'T1.0.name', 'homeTeam', 'home_name'],
      fallback: 'Home',
    );
    final awayTeam = _readString(
      event,
      const ['T2.0.Nm', 'T2.0.name', 'awayTeam', 'away_name'],
      fallback: 'Away',
    );
    final homeTeamImage = _readString(
      event,
      const ['T1.0.Img', 'T1.0.image', 'homeTeamImage', 'home_image'],
    );
    final awayTeamImage = _readString(
      event,
      const ['T2.0.Img', 'T2.0.image', 'awayTeamImage', 'away_image'],
    );

    final homeScore = _readString(
      event,
      const ['Tr1', 'Tr1OR', 'homeScore', 'home_score'],
      fallback: '',
    );
    final awayScore = _readString(
      event,
      const ['Tr2', 'Tr2OR', 'awayScore', 'away_score'],
      fallback: '',
    );

    final status = _readString(
      event,
      const ['Eps', 'EpsL', 'status', 'statusText'],
      fallback: 'Scheduled',
    );

    return MatchItem(
      competition: competition,
      country: country,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeTeamImage: homeTeamImage,
      awayTeamImage: awayTeamImage,
      homeScore: homeScore,
      awayScore: awayScore,
      status: status,
      startTime: _parseEsd(event['Esd']),
    );
  }

  DateTime? _parseEsd(dynamic value) {
    if (value == null) {
      return null;
    }

    final raw = value.toString();
    if (raw.length != 14) {
      return null;
    }

    final year = int.tryParse(raw.substring(0, 4));
    final month = int.tryParse(raw.substring(4, 6));
    final day = int.tryParse(raw.substring(6, 8));
    final hour = int.tryParse(raw.substring(8, 10));
    final minute = int.tryParse(raw.substring(10, 12));
    final second = int.tryParse(raw.substring(12, 14));

    if ([year, month, day, hour, minute, second].contains(null)) {
      return null;
    }

    return DateTime(year!, month!, day!, hour!, minute!, second!);
  }

  String _readString(
    Map<String, dynamic> source,
    List<String> paths, {
    String fallback = '',
  }) {
    for (final path in paths) {
      final value = _readPath(source, path);
      if (value == null) {
        continue;
      }

      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }

      if (value is num) {
        return value.toString();
      }
    }

    return fallback;
  }

  dynamic _readPath(dynamic current, String path) {
    for (final part in path.split('.')) {
      if (current is Map<String, dynamic>) {
        current = current[part];
        continue;
      }

      if (current is List<dynamic>) {
        final index = int.tryParse(part);
        if (index == null || index < 0 || index >= current.length) {
          return null;
        }
        current = current[index];
        continue;
      }

      return null;
    }

    return current;
  }
}
