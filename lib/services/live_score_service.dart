import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/match_item.dart';
import '../models/news_item.dart';

class LiveScoreService {
  const LiveScoreService();

  static const String _newsPath = '/news/v3/list';

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
        .toList();
  }


  Future<List<MatchItem>> fetchLiveMatches({
    required String category,
    double timezone = -7,
  }) async {
    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}${ApiConfig.liveScoreLivePath}',
    ).replace(
      queryParameters: {
        'Category': category,
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
        .toList();
  }

  Future<List<NewsItem>> fetchNews({
    String countryCode = 'US',
    String locale = 'en',
    bool includeBet = true,
    String competitionIds = '65,77,60',
    String participantIds = '2810,3340,2773',
  }) async {
    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse('${ApiConfig.liveScoreBaseUrl}$_newsPath').replace(
      queryParameters: {
        'countryCode': countryCode,
        'locale': locale,
        'bet': includeBet.toString(),
        'competitionIds': competitionIds,
        'participantIds': participantIds,
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
        'LiveScore news request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    return _extractNewsItems(decoded).toList();
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

  List<NewsItem> _extractNewsItems(dynamic decoded) {
    final newsNodes = <Map<String, dynamic>>[];

    if (decoded is Map<String, dynamic>) {
      _addNewsCollection(decoded['topStories'], newsNodes);
      _addNewsCollection(decoded['featuredArticles'], newsNodes);

      final homepageArticles = decoded['homepageArticles'];
      if (homepageArticles is List<dynamic>) {
        for (final section in homepageArticles) {
          if (section is Map<String, dynamic>) {
            _addNewsCollection(section['articles'], newsNodes);
          }
        }
      }

      if (newsNodes.isEmpty) {
        final sections = decoded['scns'] ?? decoded['sections'];
        if (sections is List<dynamic>) {
          for (final section in sections) {
            _collectFallbackNewsNodes(section, newsNodes);
          }
        } else {
          _collectFallbackNewsNodes(decoded, newsNodes);
        }
      }
    } else {
      _collectFallbackNewsNodes(decoded, newsNodes);
    }

    final items = newsNodes
        .map(_parseNewsItem)
        .whereType<NewsItem>()
        .toList();

    final seen = <String>{};
    return items.where((item) => seen.add(_newsIdentity(item))).toList();
  }

  void _addNewsCollection(dynamic items, List<Map<String, dynamic>> newsNodes) {
    if (items is! List<dynamic>) {
      return;
    }

    for (final item in items) {
      if (item is Map<String, dynamic>) {
        newsNodes.add(item);
      }
    }
  }

  void _collectFallbackNewsNodes(
    dynamic current,
    List<Map<String, dynamic>> newsNodes,
  ) {
    if (current is Map<String, dynamic>) {
      if (_looksLikeFallbackNewsNode(current)) {
        newsNodes.add(current);
      }

      for (final value in current.values) {
        _collectFallbackNewsNodes(value, newsNodes);
      }
      return;
    }

    if (current is List<dynamic>) {
      for (final value in current) {
        _collectFallbackNewsNodes(value, newsNodes);
      }
    }
  }

  bool _looksLikeFallbackNewsNode(Map<String, dynamic> node) {
    final title = _readString(
      node,
      const [
        'title',
        'headline',
        'articleTitle',
        'shortTitle',
        'tn',
        'hdln',
        'nm',
        'snm',
      ],
    );
    final image = _readString(
      node,
      const [
        'mainMedia.gallery.url',
        'mainMedia.thumbnail.url',
        'image',
        'imageUrl',
        'img',
        'thumbnail',
        'thumb',
        'heroImage',
        'mainMedia.0.url',
        'media.0.url',
        'mi.0.url',
        'imt',
        'uri',
      ],
    );

    return title.isNotEmpty || image.isNotEmpty;
  }

  String _newsIdentity(NewsItem item) {
    final source = item.source.trim().toLowerCase();
    final publishedAt = item.publishedAt.trim().toLowerCase();
    return '${item.headline.trim().toLowerCase()}|$source|$publishedAt';
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

  NewsItem? _parseNewsItem(Map<String, dynamic> raw) {
    final headline = _readString(
      raw,
      const [
        'title',
        'headline',
        'articleTitle',
        'shortTitle',
        'seo.title',
        'tn',
        'hdln',
        'nm',
        'snm',
      ],
    );
    if (headline.isEmpty) {
      return null;
    }

    return NewsItem(
      headline: headline,
      summary: _readString(
        raw,
        const [
          'subTitle',
          'subtitle',
          'summary',
          'description',
          'seo.description',
          'excerpt',
          'smry',
          'desc',
          'teaser',
        ],
      ),
      imageUrl: _normalizeNewsImageUrl(
        _readString(
          raw,
          const [
            'mainMedia.gallery.url',
            'mainMedia.thumbnail.url',
            'image',
            'imageUrl',
            'img',
            'thumbnail',
            'thumb',
            'heroImage',
            'mainMedia.0.url',
            'media.0.url',
            'mi.0.url',
            'imt',
          ],
        ),
      ),
      source: _readString(
        raw,
        const [
          'publishedBy.name',
          'source',
          'provider',
          'publisher',
          'origin',
          'src',
          'prv',
        ],
        fallback: 'LiveScore',
      ),
      publishedAt: _readString(
        raw,
        const [
          'publishedAt',
          'updatedAtUtc',
          'publishedDate',
          'publishDate',
          'date',
          'lastUpdated',
          'dt',
          'ut',
        ],
      ),
      category: _readString(
        raw,
        const [
          'categoryLabel',
          'category.initialTitle',
          'category.title',
          'category',
          'tag',
          'section',
          'sport',
          'type',
          'snm',
          'nm',
        ],
        fallback: 'NEWS',
      ),
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

  String _normalizeNewsImageUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final normalized = trimmed.startsWith('//') ? 'https:$trimmed' : trimmed;

    final sourceUrl = normalized.startsWith('http')
        ? normalized
        : normalized.startsWith('/')
            ? 'https://storage.livescore.com$normalized'
            : normalized.contains('/')
                ? 'https://storage.livescore.com/$normalized'
                : 'https://storage.livescore.com/images/news/$normalized';

    return 'https://getimage.membertsd.workers.dev/?url=' + Uri.encodeComponent(sourceUrl);
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






