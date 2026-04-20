import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/league_option.dart';
import '../models/news_detail.dart';
import '../models/match_item.dart';
import '../models/news_item.dart';
import '../models/search_result.dart';
import 'api_cache.dart';

class LiveScoreService {
  const LiveScoreService();

  static const String _newsPath = '/news/v3/list';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);
  static final _cache = ApiCache();

  Future<List<MatchItem>> fetchMatchesByDate({
    required String category,
    required DateTime date,
    double timezone = -7,
  }) async {
    final cacheKey = 'matches_by_date_${category}_${_formatDate(date)}';
    final cached = _cache.get<List<MatchItem>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri =
        Uri.parse(
          '${ApiConfig.liveScoreBaseUrl}${ApiConfig.liveScorePath}',
        ).replace(
          queryParameters: {
            'Category': category,
            'Date': _formatDate(date),
            'Timezone': timezone.toString(),
          },
        );

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> stages = _extractStages(decoded);

    final matches = stages
        .expand((dynamic stage) => _parseStageMatches(stage))
        .toList();

    _cache.set(cacheKey, matches, ttl: const Duration(minutes: 10));
    return matches;
  }

  Future<List<MatchItem>> fetchLiveMatches({
    required String category,
    double timezone = -7,
  }) async {
    final cacheKey = 'matches_live_$category';
    final cached = _cache.get<List<MatchItem>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri =
        Uri.parse(
          '${ApiConfig.liveScoreBaseUrl}${ApiConfig.liveScoreLivePath}',
        ).replace(
          queryParameters: {
            'Category': category,
            'Timezone': timezone.toString(),
          },
        );

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> stages = _extractStages(decoded);

    final matches = stages
        .expand((dynamic stage) => _parseStageMatches(stage))
        .toList();

    _cache.set(cacheKey, matches, ttl: const Duration(minutes: 5));
    return matches;
  }

  Future<List<LeagueOption>> fetchLeagueOptions({
    required String category,
    required DateTime date,
    double timezone = -7,
  }) async {
    final cacheKey = 'league_options_${category}_${_formatDate(date)}';
    final cached = _cache.get<List<LeagueOption>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri =
        Uri.parse(
          '${ApiConfig.liveScoreBaseUrl}${ApiConfig.liveScorePath}',
        ).replace(
          queryParameters: {
            'Category': category,
            'Date': _formatDate(date),
            'Timezone': timezone.toString(),
          },
        );

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    final options = _extractLeagueOptions(decoded, category);
    _cache.set(cacheKey, options, ttl: const Duration(minutes: 10));
    return options;
  }

  Future<List<LeagueOption>> fetchPopularLeagues({
    required String category,
  }) async {
    final cacheKey = 'popular_leagues_$category';
    final cached = _cache.get<List<LeagueOption>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/leagues/v2/list-popular',
    ).replace(queryParameters: {'Category': category});

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore popular leagues request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    final options = _extractLeagueOptions(decoded, category);
    _cache.set(cacheKey, options, ttl: const Duration(minutes: 15));
    return options;
  }

  Future<List<LeagueOption>> fetchPopularLeaguesOnHomePage({
    required String category,
  }) async {
    final cacheKey = 'popular_leagues_$category';
    final cached = _cache.get<List<LeagueOption>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/leagues/v2/list-popular',
    ).replace(queryParameters: {'Category': category});

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore popular leagues request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    final options = _extractLeagueOptions(decoded, category);
    _cache.set(cacheKey, options, ttl: const Duration(minutes: 15));
    return options;
  }

  Future<Map<String, dynamic>> fetchIncidents({
    required String eid,
    required String category,
  }) async {
    final cacheKey = 'match_incidents_${eid}_$category';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) return cached;

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/matches/v2/get-incidents',
    ).replace(queryParameters: {'Eid': eid, 'Category': category});

    final response = await _retryWithBackoff(
          () => http.get(uri, headers: {
        'Content-Type': 'application/json',
        'x-rapidapi-key': ApiConfig.liveScoreApiKey,
        'x-rapidapi-host': ApiConfig.liveScoreApiHost,
      }),
    );

    if (response.statusCode != 200) {
      print("⚠️ fetchIncidents failed: ${response.statusCode}");
      print("⚠️ body: ${response.body}");
      return const {};
    }

    final body = response.body.trim();
    if (body.isEmpty || body == '{}' || body == '[]') return const {};

    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return const {};

    print("✅ incidents response keys: ${decoded.keys.toList()}");
    print("✅ incidents Incs: ${decoded['Incs']}");


    _cache.set(cacheKey, decoded, ttl: const Duration(minutes: 3));
    return decoded;
  }

  Future<List<SearchResult>> fetchSearchResults({
    required String category,
    required String query,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final cacheKey = 'search_${category}_${normalizedQuery.toLowerCase()}';
    final cached = _cache.get<List<SearchResult>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse('${ApiConfig.liveScoreBaseUrl}/v2/search').replace(
      queryParameters: {'Category': category, 'Query': normalizedQuery},
    );

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore search request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final body = response.body.trim();
    if (body.isEmpty || body == '{}' || body == '[]') {
      return const [];
    }

    final dynamic decoded = jsonDecode(body);
    final results = _extractSearchResults(decoded, category);
    _cache.set(cacheKey, results, ttl: const Duration(minutes: 5));
    return results;
  }

  Future<List<MatchItem>> fetchMatchesFromPopularLeagues({
    required String category,
    double timezone = -7,
  }) async {
    final cacheKey = 'matches_from_popular_leagues_$category';
    final cached = _cache.get<List<MatchItem>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    final popularLeagues = await fetchPopularLeagues(category: category);

    final matchesList = <MatchItem>[];
    for (final league in popularLeagues.take(10)) {
      try {
        final matches = await fetchMatchesByLeague(
          category: category,
          ccd: league.ccd,
          scd: league.scd,
          timezone: timezone,
        );
        matchesList.addAll(matches);
      } catch (_) {
        // Skip leagues that fail to load
        continue;
      }
    }

    // Sort by start time
    matchesList.sort((a, b) {
      if (a.startTime == null || b.startTime == null) {
        return 0;
      }
      return b.startTime!.compareTo(a.startTime!);
    });

    _cache.set(cacheKey, matchesList, ttl: const Duration(minutes: 5));
    return matchesList;
  }

  Future<List<MatchItem>> fetchMatchesByLeague({
    required String category,
    required String ccd,
    String? scd,
    double timezone = -7,
  }) async {
    final cacheKey = 'matches_by_league_${category}_${ccd}_${scd ?? ""}';
    final cached = _cache.get<List<MatchItem>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    final primary = await _fetchMatchesByLeagueAttempt(
      category: category,
      ccd: ccd,
      scd: scd,
      timezone: timezone,
    );

    if (primary != null) {
      _cache.set(cacheKey, primary, ttl: const Duration(minutes: 10));
      return primary;
    }

    if (scd != null && scd.trim().isNotEmpty) {
      final fallback = await _fetchMatchesByLeagueAttempt(
        category: category,
        ccd: ccd,
        timezone: timezone,
      );
      if (fallback != null) {
        _cache.set(cacheKey, fallback, ttl: const Duration(minutes: 10));
        return fallback;
      }
    }

    throw Exception(
      'LiveScore league request returned an empty response (302).',
    );
  }

  Future<List<MatchItem>?> _fetchMatchesByLeagueAttempt({
    required String category,
    required String ccd,
    String? scd,
    required double timezone,
  }) async {
    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final queryParameters = <String, String>{
      'Category': category,
      'Ccd': ccd,
      'Timezone': timezone.toString(),
    };

    if (scd != null && scd.trim().isNotEmpty) {
      queryParameters['Scd'] = scd.trim();
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/matches/v2/list-by-league',
    ).replace(queryParameters: queryParameters);

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.followRedirects = false;
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');
      request.headers.set('x-rapidapi-key', ApiConfig.liveScoreApiKey);
      request.headers.set('x-rapidapi-host', ApiConfig.liveScoreApiHost);

      late HttpClientResponse response;
      int retryCount = 0;
      while (retryCount < _maxRetries) {
        response = await request.close();
        if (response.statusCode == 429 && retryCount < _maxRetries - 1) {
          final delay = _retryDelay * (2 ^ retryCount);
          await Future.delayed(delay);
          retryCount++;
          continue;
        }
        break;
      }

      final body = await utf8.decoder.bind(response).join();
      if (body.trim().isEmpty) {
        return null;
      }

      final dynamic decoded = jsonDecode(body);
      final List<dynamic> stages = _extractStages(decoded);
      return stages
          .expand((dynamic stage) => _parseStageMatches(stage))
          .toList();
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<List<NewsItem>> fetchNews({
    String countryCode = 'US',
    String locale = 'en',
    bool includeBet = true,
    String competitionIds = '65,77,60',
    String participantIds = '2810,3340,2773',
  }) async {
    final cacheKey = 'news_${countryCode}_$locale';
    final cached = _cache.get<List<NewsItem>>(cacheKey);
    if (cached != null) {
      return cached;
    }

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

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore news request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    final newsItems = _extractNewsItems(decoded).toList();
    _cache.set(cacheKey, newsItems, ttl: const Duration(minutes: 15));
    return newsItems;
  }

  Future<List<NewsItem>> fetchNewsBySport({
    String categoryId = '20210209133211500030',
    int page = 1,
  }) async {
    final cacheKey = 'news_by_sport_${categoryId}_$page';
    final cached = _cache.get<List<NewsItem>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse('${ApiConfig.liveScoreBaseUrl}/news/v2/list-by-sport')
        .replace(
          queryParameters: {'category': categoryId, 'page': page.toString()},
        );

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore news request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    try {
      final dynamic decoded = jsonDecode(response.body);

      // Try to extract news items - handle both array and object responses
      List<NewsItem> newsItems = [];

      if (decoded is List<dynamic>) {
        // If response is directly an array of news items
        newsItems = decoded
            .whereType<Map<String, dynamic>>()
            .map(_parseNewsItem)
            .whereType<NewsItem>()
            .toList();
      } else {
        // Use standard extraction for object responses
        newsItems = _extractNewsItems(decoded).toList();
      }

      _cache.set(cacheKey, newsItems, ttl: const Duration(minutes: 15));
      return newsItems;
    } catch (e) {
      return [];
    }
  }

  Future<NewsDetail> fetchNewsDetail({
    required String id,
    NewsItem? fallbackItem,
  }) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw Exception('Missing news article id');
    }

    final cacheKey = 'news_detail_$normalizedId';
    final cached = _cache.get<NewsDetail>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/news/v2/detail',
    ).replace(queryParameters: {'id': normalizedId});

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore news detail request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final body = response.body.trim();
    if (body.isEmpty || body == '{}' || body == '[]') {
      if (fallbackItem != null) {
        return NewsDetail.fromNewsItem(fallbackItem);
      }
      throw Exception('LiveScore news detail response was empty');
    }

    final dynamic decoded = jsonDecode(body);
    final detail = _parseNewsDetail(decoded, normalizedId, fallbackItem);
    _cache.set(cacheKey, detail, ttl: const Duration(minutes: 15));
    return detail;
  }

  Future<Map<String, dynamic>> fetchMatchDetail({
    required String eid,
    required String category,
  }) async {
    final cacheKey = 'match_detail_${eid}_$category';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/matches/v2/get-info',
    ).replace(queryParameters: {'Eid': eid, 'Category': category});

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore match detail request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid match detail response format');
    }

    _cache.set(cacheKey, decoded, ttl: const Duration(minutes: 5));
    return decoded;
  }

  Future<Map<String, dynamic>> fetchScoreboard({
    required String eid,
    required String category,
  }) async {
    final cacheKey = 'match_scoreboard_${eid}_$category';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/matches/v2/get-scoreboard',
    ).replace(queryParameters: {'Eid': eid, 'Category': category});

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore scoreboard request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final body = response.body.trim();
    if (body.isEmpty || body == '{}' || body == '[]') {
      return const {};
    }

    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid scoreboard response format');
    }

    _cache.set(cacheKey, decoded, ttl: const Duration(minutes: 3));
    return decoded;
  }

  Future<Map<String, dynamic>> fetchLineups({
    required String eid,
    required String category,
  }) async {
    final cacheKey = 'match_lineups_${eid}_$category';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/matches/v2/get-lineups',
    ).replace(queryParameters: {'Category': category, 'Eid': eid});

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'X-RapidAPI-Key': ApiConfig.liveScoreApiKey,
          'X-RapidAPI-Host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore lineups request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    // Parse the response - handle various formats
    Map<String, dynamic> lineupsData = {};

    try {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        // Check for data in various possible keys
        if (decoded.containsKey('pl')) {
          // Direct players array at top level
          lineupsData = decoded;
        } else if (decoded.containsKey('players')) {
          // Alternative players key
          lineupsData = decoded;
        } else if (decoded.containsKey('teams')) {
          // Teams data at top level
          lineupsData = decoded;
        } else if (decoded.containsKey('Lineups')) {
          // Capitalized lineups key
          lineupsData = decoded;
        } else if (decoded.containsKey('lineups')) {
          // Lowercase lineups key
          lineupsData = decoded;
        } else if (decoded.containsKey('match')) {
          // Data nested under 'match' key
          final matchData = decoded['match'];
          if (matchData is Map<String, dynamic>) {
            lineupsData = matchData;
          }
        } else if (decoded.containsKey('M')) {
          // Abbreviated match key
          final matchData = decoded['M'];
          if (matchData is Map<String, dynamic>) {
            lineupsData = matchData;
          }
        } else if (decoded.containsKey('data')) {
          // Data nested under 'data' key
          final dataValue = decoded['data'];
          if (dataValue is Map<String, dynamic>) {
            lineupsData = dataValue;
          }
        } else if (decoded.containsKey('response')) {
          // Data nested under 'response' key
          final responseValue = decoded['response'];
          if (responseValue is Map<String, dynamic>) {
            lineupsData = responseValue;
          }
        } else {
          // Return the full response for inspection if format is unknown
          lineupsData = decoded.isEmpty ? {} : decoded;
        }
      }
    } catch (e) {
      // If parsing fails, return empty map
      lineupsData = {};
    }

    _cache.set(cacheKey, lineupsData, ttl: const Duration(minutes: 5));
    return lineupsData;
  }

  Future<Map<String, dynamic>> fetchStatistics({
    required String eid,
    required String category,
  }) async {
    final cacheKey = 'match_statistics_${eid}_$category';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/matches/v2/get-statistics',
    ).replace(queryParameters: {'Eid': eid, 'Category': category});

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore statistics request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    // Parse the response - handle various formats
    Map<String, dynamic> statisticsData = {};

    try {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        // Check for data in various possible keys
        if (decoded.containsKey('stats')) {
          // Direct stats array at top level
          statisticsData = decoded;
        } else if (decoded.containsKey('statistics')) {
          // Alternative statistics key
          statisticsData = decoded;
        } else if (decoded.containsKey('match')) {
          // Data nested under 'match' key
          final matchData = decoded['match'];
          if (matchData is Map<String, dynamic>) {
            statisticsData = matchData;
          }
        } else if (decoded.containsKey('M')) {
          // Abbreviated match key
          final matchData = decoded['M'];
          if (matchData is Map<String, dynamic>) {
            statisticsData = matchData;
          }
        } else if (decoded.containsKey('data')) {
          // Data nested under 'data' key
          final dataValue = decoded['data'];
          if (dataValue is Map<String, dynamic>) {
            statisticsData = dataValue;
          }
        } else if (decoded.containsKey('response')) {
          // Data nested under 'response' key
          final responseValue = decoded['response'];
          if (responseValue is Map<String, dynamic>) {
            statisticsData = responseValue;
          }
        } else {
          // Return the full response for inspection if format is unknown
          statisticsData = decoded.isEmpty ? {} : decoded;
        }
      }
    } catch (e) {
      // If parsing fails, return empty map
      statisticsData = {};
    }

    _cache.set(cacheKey, statisticsData, ttl: const Duration(minutes: 5));
    return statisticsData;
  }

  Future<Map<String, dynamic>> fetchH2H({
    required String eid,
    required String category,
  }) async {
    final cacheKey = 'match_h2h_${eid}_$category';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/matches/v2/get-h2h',
    ).replace(queryParameters: {'Eid': eid, 'Category': category});

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore H2H request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    // Parse the response - handle various formats
    Map<String, dynamic> h2hData = {};

    try {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        // Check for data in various possible keys
        if (decoded.containsKey('h2h')) {
          // Direct h2h array at top level
          h2hData = decoded;
        } else if (decoded.containsKey('headToHead')) {
          // Alternative h2h key
          h2hData = decoded;
        } else if (decoded.containsKey('H2H')) {
          // Capitalized h2h key
          h2hData = decoded;
        } else if (decoded.containsKey('events')) {
          // Events array
          h2hData = decoded;
        } else if (decoded.containsKey('match')) {
          // Data nested under 'match' key
          final matchData = decoded['match'];
          if (matchData is Map<String, dynamic>) {
            h2hData = matchData;
          }
        } else if (decoded.containsKey('data')) {
          // Data nested under 'data' key
          final dataValue = decoded['data'];
          if (dataValue is Map<String, dynamic>) {
            h2hData = dataValue;
          }
        } else if (decoded.containsKey('response')) {
          // Data nested under 'response' key
          final responseValue = decoded['response'];
          if (responseValue is Map<String, dynamic>) {
            h2hData = responseValue;
          }
        } else {
          // Return the full response for inspection if format is unknown
          h2hData = decoded.isEmpty ? {} : decoded;
        }
      }
    } catch (e) {
      // If parsing fails, return empty map
      h2hData = {};
    }

    _cache.set(cacheKey, h2hData, ttl: const Duration(minutes: 5));
    return h2hData;
  }

  Future<Map<String, dynamic>> fetchLeagueTable({
    required String teamId,
    String type = 'short',
  }) async {
    final normalizedTeamId = teamId.trim();
    if (normalizedTeamId.isEmpty) {
      return const {};
    }

    final cacheKey = 'league_table_${normalizedTeamId}_$type';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/teams/get-table',
    ).replace(queryParameters: {'ID': normalizedTeamId, 'Type': type});

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore league table request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final body = response.body.trim();
    if (body.isEmpty || body == '{}' || body == '[]') {
      return const {};
    }

    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid league table response format');
    }

    _cache.set(cacheKey, decoded, ttl: const Duration(minutes: 10));
    return decoded;
  }

  Future<Map<String, dynamic>> fetchTeamDetail({required String teamId}) async {
    final normalizedTeamId = teamId.trim();
    if (normalizedTeamId.isEmpty) {
      return const {};
    }

    final cacheKey = 'team_detail_$normalizedTeamId';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/teams/detail',
    ).replace(queryParameters: {'ID': normalizedTeamId});

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore team detail request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final body = response.body.trim();
    if (body.isEmpty || body == '{}' || body == '[]') {
      return const {};
    }

    final dynamic decoded = jsonDecode(body);
    final normalized = _normalizeTeamDetailResponse(decoded);
    if (normalized.isEmpty) {
      return const {};
    }

    _cache.set(cacheKey, normalized, ttl: const Duration(minutes: 15));
    return normalized;
  }

  Map<String, dynamic> _normalizeTeamDetailResponse(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      if (_looksLikeTeamDetailMap(decoded)) {
        return decoded;
      }

      for (final key in const [
        'team',
        'Team',
        'data',
        'Data',
        'response',
        'Response',
        'details',
        'Details',
      ]) {
        final value = decoded[key];
        if (value is Map<String, dynamic>) {
          if (_looksLikeTeamDetailMap(value)) {
            return value;
          }

          for (final nestedKey in const [
            'team',
            'Team',
            'details',
            'Details',
          ]) {
            final nested = value[nestedKey];
            if (nested is Map<String, dynamic> &&
                _looksLikeTeamDetailMap(nested)) {
              return nested;
            }
          }
        }
      }

      for (final value in decoded.values) {
        final nested = _normalizeTeamDetailResponse(value);
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }

    if (decoded is List<dynamic>) {
      for (final item in decoded) {
        final nested = _normalizeTeamDetailResponse(item);
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }

    return const {};
  }

  bool _looksLikeTeamDetailMap(Map<String, dynamic> source) {
    const keys = [
      'ID',
      'Id',
      'id',
      'Tid',
      'Tnm',
      'Nm',
      'name',
      'Country',
      'country',
      'Venue',
      'venue',
      'Stadium',
      'stadium',
      'Manager',
      'manager',
      'Coach',
      'coach',
      'Founded',
      'founded',
    ];

    for (final key in keys) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  Future<Map<String, dynamic>> fetchTeamPlayerStats({
    required String teamId,
    String? compId,
    String stype = 'cm',
    int? type,
  }) async {
    final normalizedTeamId = teamId.trim();
    if (normalizedTeamId.isEmpty) {
      return const {};
    }

    final normalizedCompId = compId?.trim() ?? '';
    final cacheKey =
        'team_player_stats_${normalizedTeamId}_${normalizedCompId}_${stype}_${type ?? ''}';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final queryParameters = <String, String>{
      'ID': normalizedTeamId,
      'Stype': stype,
    };

    if (normalizedCompId.isNotEmpty) {
      queryParameters['CompId'] = normalizedCompId;
    }

    if (type != null) {
      queryParameters['Type'] = type.toString();
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/teams/get-player-stats',
    ).replace(queryParameters: queryParameters);

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore team player stats request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final body = response.body.trim();
    if (body.isEmpty || body == '{}' || body == '[]') {
      return const {};
    }

    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid team player stats response format');
    }

    _cache.set(cacheKey, decoded, ttl: const Duration(minutes: 10));
    return decoded;
  }

  Future<Map<String, dynamic>> fetchTeamStats({
    required String teamId,
    String? compId,
    String stype = 'cm',
  }) async {
    final normalizedTeamId = teamId.trim();
    if (normalizedTeamId.isEmpty) {
      return const {};
    }

    final normalizedCompId = compId?.trim() ?? '';
    final cacheKey =
        'team_stats_${normalizedTeamId}_${normalizedCompId}_$stype';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final queryParameters = <String, String>{
      'ID': normalizedTeamId,
      'Stype': stype,
    };

    if (normalizedCompId.isNotEmpty) {
      queryParameters['CompId'] = normalizedCompId;
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/teams/get-team-stats',
    ).replace(queryParameters: queryParameters);

    final response = await _retryWithBackoff(
      () => http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': ApiConfig.liveScoreApiKey,
          'x-rapidapi-host': ApiConfig.liveScoreApiHost,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LiveScore team stats request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final body = response.body.trim();
    if (body.isEmpty || body == '{}' || body == '[]') {
      return const {};
    }

    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid team stats response format');
    }

    _cache.set(cacheKey, decoded, ttl: const Duration(minutes: 10));
    return decoded;
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  static Future<http.Response> _retryWithBackoff(
    Future<http.Response> Function() request,
  ) async {
    int retryCount = 0;

    while (retryCount < _maxRetries) {
      try {
        final response = await request();

        if (response.statusCode == 429) {
          if (retryCount < _maxRetries - 1) {
            final delay = _retryDelay * (2 ^ retryCount);
            await Future.delayed(delay);
            retryCount++;
            continue;
          }
        }

        return response;
      } catch (e) {
        if (retryCount < _maxRetries - 1) {
          final delay = _retryDelay * (2 ^ retryCount);
          await Future.delayed(delay);
          retryCount++;
          continue;
        }
        rethrow;
      }
    }

    throw Exception('Max retries exceeded');
  }

  List<LeagueOption> _extractLeagueOptions(dynamic decoded, String category) {
    final stages = _extractStages(decoded);
    final options = <LeagueOption>[];
    final seen = <String>{};

    for (final stage in stages) {
      if (stage is! Map<String, dynamic>) {
        continue;
      }

      final ccd = _readString(stage, const [
        'Ccd',
        'ccd',
        'CompCcd',
        'competitionCode',
      ]);
      if (ccd.isEmpty) {
        continue;
      }

      final scd = _readString(stage, const [
        'Scd',
        'scd',
        'stageCode',
        'groupCode',
      ]);
      final key = '$ccd|$scd';
      if (!seen.add(key)) {
        continue;
      }

      options.add(
        LeagueOption(
          category: category,
          title: _readString(stage, const [
            'CompN',
            'Snm',
            'competitionName',
            'name',
          ], fallback: ccd),
          subtitle: _readString(stage, const [
            'CompD',
            'CompST',
            'Cnm',
            'Csnm',
            'country',
            'region',
          ], fallback: category.toUpperCase()),
          ccd: ccd,
          scd: scd,
        ),
      );
    }

    return options;
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

    final items = newsNodes.map(_parseNewsItem).whereType<NewsItem>().toList();

    final seen = <String>{};
    return items.where((item) => seen.add(_newsIdentity(item))).toList();
  }

  List<SearchResult> _extractSearchResults(dynamic decoded, String category) {
    final candidates = <Map<String, dynamic>>[];
    _collectSearchNodes(decoded, candidates);

    final seen = <String>{};
    final results = <SearchResult>[];

    for (final node in candidates) {
      final parsed = _parseSearchResult(node, category);
      if (parsed == null) {
        continue;
      }

      final identity = [
        parsed.type.toLowerCase(),
        parsed.eid.toLowerCase(),
        parsed.ccd.toLowerCase(),
        parsed.scd.toLowerCase(),
        parsed.title.toLowerCase(),
        parsed.subtitle.toLowerCase(),
      ].join('|');

      if (!seen.add(identity)) {
        continue;
      }

      results.add(parsed);
    }

    return results;
  }

  void _collectSearchNodes(
    dynamic current,
    List<Map<String, dynamic>> candidates,
  ) {
    if (current is Map<String, dynamic>) {
      if (_looksLikeSearchNode(current)) {
        candidates.add(current);
      }

      for (final value in current.values) {
        _collectSearchNodes(value, candidates);
      }
      return;
    }

    if (current is List<dynamic>) {
      for (final value in current) {
        _collectSearchNodes(value, candidates);
      }
    }
  }

  bool _looksLikeSearchNode(Map<String, dynamic> node) {
    final title = _readString(node, const [
      'Nm',
      'Snm',
      'CompN',
      'name',
      'title',
      'searchValue',
      'teamName',
      'leagueName',
    ]);
    final eid = _readString(node, const ['Eid', 'eid', 'eventId', 'matchId']);
    final ccd = _readString(node, const [
      'Ccd',
      'ccd',
      'CompCcd',
      'countryCode',
    ]);
    final scd = _readString(node, const [
      'Scd',
      'scd',
      'stageCode',
      'leagueCode',
    ]);
    final teamA = _readString(node, const ['T1.0.Nm', 'homeTeam', 'home_name']);
    final teamB = _readString(node, const ['T2.0.Nm', 'awayTeam', 'away_name']);

    return title.isNotEmpty ||
        eid.isNotEmpty ||
        ccd.isNotEmpty ||
        scd.isNotEmpty ||
        teamA.isNotEmpty ||
        teamB.isNotEmpty;
  }

  SearchResult? _parseSearchResult(Map<String, dynamic> node, String category) {
    final eid = _readString(node, const ['Eid', 'eid', 'eventId', 'matchId']);
    final ccd = _readString(node, const [
      'Ccd',
      'ccd',
      'CompCcd',
      'countryCode',
    ]);
    final scd = _readString(node, const [
      'Scd',
      'scd',
      'stageCode',
      'leagueCode',
    ]);

    final homeTeam = _readString(node, const [
      'T1.0.Nm',
      'homeTeam',
      'home_name',
    ]);
    final awayTeam = _readString(node, const [
      'T2.0.Nm',
      'awayTeam',
      'away_name',
    ]);

    final title = _readString(
      node,
      const [
        'Nm',
        'Snm',
        'CompN',
        'name',
        'title',
        'searchValue',
        'teamName',
        'leagueName',
      ],
      fallback: homeTeam.isNotEmpty && awayTeam.isNotEmpty
          ? '$homeTeam vs $awayTeam'
          : '',
    );

    if (title.isEmpty) {
      return null;
    }

    final subtitle = _readString(node, const [
      'CompD',
      'CompST',
      'Cnm',
      'Csnm',
      'country',
      'region',
      'subtitle',
      'description',
    ], fallback: category.toUpperCase());

    final explicitType = _readString(node, const [
      'Type',
      'type',
      'entityType',
      'searchType',
    ]).toLowerCase();

    final type = explicitType.isNotEmpty
        ? explicitType
        : eid.isNotEmpty
        ? 'match'
        : ccd.isNotEmpty
        ? 'league'
        : 'item';

    return SearchResult(
      category: category,
      title: title,
      subtitle: subtitle,
      type: type,
      eid: eid,
      ccd: ccd,
      scd: scd,
      imageUrl: _readString(node, const [
        'Img',
        'img',
        'image',
        'logo',
        'badge',
      ]),
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeScore: _readString(node, const [
        'Tr1',
        'Tr1OR',
        'homeScore',
        'home_score',
      ]),
      awayScore: _readString(node, const [
        'Tr2',
        'Tr2OR',
        'awayScore',
        'away_score',
      ]),
      status: _readString(node, const [
        'Eps',
        'EpsL',
        'status',
        'statusText',
      ], fallback: 'Scheduled'),
      startTime: _parseEsd(_readPath(node, 'Esd')),
    );
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
    final title = _readString(node, const [
      'title',
      'headline',
      'articleTitle',
      'shortTitle',
      'tn',
      'hdln',
      'nm',
      'snm',
    ]);
    final image = _readString(node, const [
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
    ]);

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

    final competition = _readString(stage, const [
      'CompN',
      'Snm',
      'competitionName',
      'name',
    ], fallback: 'Competition');
    final country = _readString(stage, const [
      'CompD',
      'CompST',
      'Cnm',
      'Csnm',
      'country',
      'region',
    ], fallback: 'International');
    final countryCode = _readString(stage, const [
      'Ccd',
      'ccd',
      'CompCcd',
      'countryCode',
    ], fallback: '');

    final events = stage['Events'] ?? stage['events'];
    if (events is! List<dynamic>) {
      return const [];
    }

    return events
        .map(
          (dynamic event) =>
              _parseEvent(event, competition, country, countryCode),
        )
        .whereType<MatchItem>()
        .toList();
  }

  MatchItem? _parseEvent(
    dynamic event,
    String competition,
    String country,
    String countryCode,
  ) {
    if (event is! Map<String, dynamic>) {
      return null;
    }

    // Extract eid with multiple fallback keys
    final eid = _readString(event, const [
      'Eid', // Primary key from list endpoints
      'eid', // Lowercase variant
      'ID', // Alternative uppercase
      'Id', // Mixed case
      'eventId', // Alternative name
      'event_id', // Snake case
      'matchId', // Alternative name
      'match_id', // Snake case
      'E_Id', // Underscore variant
    ]);
    if (eid.isEmpty) {
      return null;
    }

    final homeTeam = _readString(event, const [
      'T1.0.Nm',
      'T1.0.name',
      'homeTeam',
      'home_name',
    ], fallback: 'Home');
    final homeTeamId = _readString(event, const [
      'T1.0.ID',
      'T1.0.id',
      'homeTeamId',
      'home_team_id',
    ]);
    final awayTeam = _readString(event, const [
      'T2.0.Nm',
      'T2.0.name',
      'awayTeam',
      'away_name',
    ], fallback: 'Away');
    final awayTeamId = _readString(event, const [
      'T2.0.ID',
      'T2.0.id',
      'awayTeamId',
      'away_team_id',
    ]);
    final homeTeamImage = _readString(event, const [
      'T1.0.Img',
      'T1.0.image',
      'homeTeamImage',
      'home_image',
    ]);
    final awayTeamImage = _readString(event, const [
      'T2.0.Img',
      'T2.0.image',
      'awayTeamImage',
      'away_image',
    ]);

    final homeScore = _readString(event, const [
      'Tr1',
      'Tr1OR',
      'homeScore',
      'home_score',
    ], fallback: '');
    final awayScore = _readString(event, const [
      'Tr2',
      'Tr2OR',
      'awayScore',
      'away_score',
    ], fallback: '');
    final homeRedCards = _readInt(event, const [
      'T1.0.YRcs',
      'T1.0.yrCs',
      'T1.0.RCs',
      'T1.0.rcs',
      'T1.0.RC',
      'T1.0.rc',
      'T1.0.RedCards',
      'T1.0.redCards',
      'T1.0.Cards.Red',
      'T1.0.cards.red',
      'T1RC',
      't1rc',
      'homeRedCards',
      'home_red_cards',
    ], fallback: 0);
    final awayRedCards = _readInt(event, const [
      'T2.0.YRcs',
      'T2.0.yrCs',
      'T2.0.RCs',
      'T2.0.rcs',
      'T2.0.RC',
      'T2.0.rc',
      'T2.0.RedCards',
      'T2.0.redCards',
      'T2.0.Cards.Red',
      'T2.0.cards.red',
      'T2RC',
      't2rc',
      'awayRedCards',
      'away_red_cards',
    ], fallback: 0);

    final status = _readString(event, const [
      'Eps',
      'EpsL',
      'status',
      'statusText',
    ], fallback: 'Scheduled');

    return MatchItem(
      eid: eid,
      competition: competition,
      country: country,
      countryCode: countryCode,
      homeTeamId: homeTeamId,
      awayTeamId: awayTeamId,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeTeamImage: homeTeamImage,
      awayTeamImage: awayTeamImage,
      homeScore: homeScore,
      awayScore: awayScore,
      homeRedCards: homeRedCards,
      awayRedCards: awayRedCards,
      status: status,
      startTime: _parseEsd(event['Esd']),
    );
  }

  NewsItem? _parseNewsItem(Map<String, dynamic> raw) {
    final id = _readString(raw, const [
      'id',
      'ID',
      'articleId',
      'articleID',
      'newsId',
      'nid',
    ]);
    final headline = _readString(raw, const [
      'title',
      'headline',
      'articleTitle',
      'shortTitle',
      'seo.title',
      'tn',
      'hdln',
      'nm',
      'snm',
    ]);
    if (headline.isEmpty) {
      return null;
    }

    return NewsItem(
      id: id,
      headline: headline,
      summary: _readString(raw, const [
        'subTitle',
        'subtitle',
        'summary',
        'description',
        'seo.description',
        'excerpt',
        'smry',
        'desc',
        'teaser',
      ]),
      imageUrl: _normalizeNewsImageUrl(
        _readString(raw, const [
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
        ]),
      ),
      source: _readString(raw, const [
        'publishedBy.name',
        'source',
        'provider',
        'publisher',
        'origin',
        'src',
        'prv',
      ], fallback: 'LiveScore'),
      publishedAt: _readString(raw, const [
        'publishedAt',
        'updatedAtUtc',
        'publishedDate',
        'publishDate',
        'date',
        'lastUpdated',
        'dt',
        'ut',
      ]),
      category: _readString(raw, const [
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
      ], fallback: 'NEWS'),
    );
  }

  NewsDetail _parseNewsDetail(
    dynamic decoded,
    String id,
    NewsItem? fallbackItem,
  ) {
    final fallback = fallbackItem == null
        ? null
        : NewsDetail.fromNewsItem(fallbackItem);

    final nodes = <Map<String, dynamic>>[];
    _collectMapNodes(decoded, nodes);

    Map<String, dynamic>? bestNode;
    var bestScore = -1;

    for (final node in nodes) {
      final score = _scoreNewsDetailNode(node);
      if (score > bestScore) {
        bestScore = score;
        bestNode = node;
      }
    }

    final source = bestNode ?? <String, dynamic>{};
    final headline = _readString(source, const [
      'title',
      'headline',
      'articleTitle',
      'shortTitle',
      'seo.title',
      'tn',
      'hdln',
      'nm',
      'snm',
    ], fallback: fallback?.headline ?? '');

    final summary = _readString(source, const [
      'subTitle',
      'subtitle',
      'summary',
      'description',
      'seo.description',
      'excerpt',
      'smry',
      'desc',
      'teaser',
    ], fallback: fallback?.summary ?? '');

    final content = _normalizeNewsContent(
      _readString(source, const [
        'content',
        'body',
        'articleBody',
        'story.body',
        'story.content',
        'details',
        'text',
        'html',
        'contentHtml',
        'contentText',
        'article.content',
        'article.body',
      ]),
      fallback: summary.isNotEmpty ? summary : (fallback?.content ?? ''),
    );

    return NewsDetail(
      id: id,
      headline: headline.isNotEmpty
          ? headline
          : (fallback?.headline ?? 'News Detail'),
      summary: summary.isNotEmpty ? summary : (fallback?.summary ?? ''),
      content: content,
      imageUrl: _normalizeNewsImageUrl(
        _readString(source, const [
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
        ], fallback: fallback?.imageUrl ?? ''),
      ),
      source: _readString(source, const [
        'publishedBy.name',
        'source',
        'provider',
        'publisher',
        'origin',
        'src',
        'prv',
      ], fallback: fallback?.source ?? 'LiveScore'),
      publishedAt: _readString(source, const [
        'publishedAt',
        'updatedAtUtc',
        'publishedDate',
        'publishDate',
        'date',
        'lastUpdated',
        'dt',
        'ut',
      ], fallback: fallback?.publishedAt ?? ''),
      category: _readString(source, const [
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
      ], fallback: fallback?.category ?? 'NEWS'),
    );
  }

  void _collectMapNodes(dynamic current, List<Map<String, dynamic>> nodes) {
    if (current is Map<String, dynamic>) {
      nodes.add(current);
      for (final value in current.values) {
        _collectMapNodes(value, nodes);
      }
      return;
    }

    if (current is List<dynamic>) {
      for (final value in current) {
        _collectMapNodes(value, nodes);
      }
    }
  }

  int _scoreNewsDetailNode(Map<String, dynamic> node) {
    var score = 0;

    if (_readString(node, const [
      'content',
      'body',
      'articleBody',
    ]).isNotEmpty) {
      score += 4;
    }
    if (_readString(node, const [
      'title',
      'headline',
      'articleTitle',
    ]).isNotEmpty) {
      score += 3;
    }
    if (_readString(node, const [
      'description',
      'summary',
      'subtitle',
    ]).isNotEmpty) {
      score += 2;
    }
    if (_readString(node, const [
      'mainMedia.gallery.url',
      'image',
      'imageUrl',
    ]).isNotEmpty) {
      score += 1;
    }

    return score;
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

  int _readInt(
    Map<String, dynamic> source,
    List<String> paths, {
    int fallback = 0,
  }) {
    for (final path in paths) {
      final value = _readPath(source, path);
      if (value == null) {
        continue;
      }

      if (value is num) {
        return value.toInt();
      }

      final parsed = int.tryParse(value.toString().trim());
      if (parsed != null) {
        return parsed;
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

    return 'https://getimage.membertsd.workers.dev/?url=${Uri.encodeComponent(sourceUrl)}';
  }

  String _normalizeNewsContent(String value, {String fallback = ''}) {
    final raw = value.trim().isNotEmpty ? value.trim() : fallback.trim();
    if (raw.isEmpty) {
      return '';
    }

    final withBreaks = raw
        .replaceAll(RegExp(r'(?i)<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'(?i)</p>'), '\n\n')
        .replaceAll(RegExp(r'(?i)</div>'), '\n\n')
        .replaceAll(RegExp(r'(?i)</li>'), '\n');

    final stripped = withBreaks
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    return stripped
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
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
