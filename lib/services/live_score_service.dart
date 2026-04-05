import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/league_option.dart';
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

    final uri = Uri.parse(
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

    final uri = Uri.parse(
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

    final uri = Uri.parse(
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
    ).replace(
      queryParameters: {
        'Category': category,
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
    ).replace(
      queryParameters: {
        'Category': category,
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
        'LiveScore popular leagues request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    final options = _extractLeagueOptions(decoded, category);
    _cache.set(cacheKey, options, ttl: const Duration(minutes: 15));
    return options;
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

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/v2/search',
    ).replace(
      queryParameters: {
        'Category': category,
        'Query': normalizedQuery,
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

    throw Exception('LiveScore league request returned an empty response (302).');
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

    final uri = Uri.parse('${ApiConfig.liveScoreBaseUrl}/news/v2/list-by-sport').replace(
      queryParameters: {
        'category': categoryId,
        'page': page.toString(),
      },
    );

    print('DEBUG: Fetching news from $uri');

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
      print('DEBUG: News response keys: ${decoded is Map ? decoded.keys.toList() : 'Not a map'}');
      
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
      
      if (newsItems.isEmpty) {
        print('DEBUG: No news items extracted, returning empty list');
      } else {
        print('DEBUG: Extracted ${newsItems.length} news items');
      }
      
      _cache.set(cacheKey, newsItems, ttl: const Duration(minutes: 15));
      return newsItems;
    } catch (e) {
      print('DEBUG: Error parsing news response: $e');
      // Return empty list instead of throwing to allow partial loading
      return [];
    }
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
    ).replace(
      queryParameters: {
        'Eid': eid,
        'Category': category,
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

  Future<Map<String, dynamic>> fetchLineups({
    required String eid,
    required String category,
  }) async {
    print('DEBUG: fetchLineups called with EID = $eid, Category = $category');
    
    final cacheKey = 'match_lineups_${eid}_$category';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      print('DEBUG: Returning cached lineups for EID = $eid');
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/matches/v2/get-lineups',
    ).replace(
      queryParameters: {
        'Eid': eid,
        'Category': category,
      },
    );
    
    print('DEBUG: Lineups API URL = ${uri.toString()}');

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
        'LiveScore lineups request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    // Parse the response - handle various formats
    Map<String, dynamic> lineupsData = {};
    
    try {
      final dynamic decoded = jsonDecode(response.body);
      
      if (decoded is Map<String, dynamic>) {
        // Log the structure for debugging (in production, this helps us understand API responses)
        print('DEBUG: Lineups response keys: ${decoded.keys.toList()}');
        
        // Check for data in various possible keys
        if (decoded.containsKey('pl')) {
          // Direct players array at top level
          print('DEBUG: Found pl key (players array)');
          lineupsData = decoded;
        } else if (decoded.containsKey('players')) {
          // Alternative players key
          print('DEBUG: Found players key');
          lineupsData = decoded;
        } else if (decoded.containsKey('teams')) {
          // Teams data at top level
          print('DEBUG: Found teams key');
          lineupsData = decoded;
        } else if (decoded.containsKey('Lineups')) {
          // Capitalized lineups key
          print('DEBUG: Found Lineups key');
          lineupsData = decoded;
        } else if (decoded.containsKey('lineups')) {
          // Lowercase lineups key
          print('DEBUG: Found lineups key');
          lineupsData = decoded;
        } else if (decoded.containsKey('match')) {
          // Data nested under 'match' key
          print('DEBUG: Found match key');
          final matchData = decoded['match'];
          if (matchData is Map<String, dynamic>) {
            lineupsData = matchData;
          }
        } else if (decoded.containsKey('M')) {
          // Abbreviated match key
          print('DEBUG: Found M key');
          final matchData = decoded['M'];
          if (matchData is Map<String, dynamic>) {
            lineupsData = matchData;
          }
        } else if (decoded.containsKey('data')) {
          // Data nested under 'data' key
          print('DEBUG: Found data key');
          final dataValue = decoded['data'];
          if (dataValue is Map<String, dynamic>) {
            lineupsData = dataValue;
          }
        } else if (decoded.containsKey('response')) {
          // Data nested under 'response' key
          print('DEBUG: Found response key');
          final responseValue = decoded['response'];
          if (responseValue is Map<String, dynamic>) {
            lineupsData = responseValue;
          }
        } else {
          // Return the full response for inspection if format is unknown
          print('DEBUG: Unknown response format, returning full response');
          lineupsData = decoded.isEmpty ? {} : decoded;
        }
      }
    } catch (e) {
      // If parsing fails, return empty map
      print('DEBUG: Error parsing lineups response: $e');
      lineupsData = {};
    }

    print('DEBUG: Final lineupsData keys: ${lineupsData.keys.toList()}');
    _cache.set(cacheKey, lineupsData, ttl: const Duration(minutes: 5));
    return lineupsData;
  }

  Future<Map<String, dynamic>> fetchStatistics({
    required String eid,
    required String category,
  }) async {
    print('DEBUG: fetchStatistics called with EID = $eid, Category = $category');
    
    final cacheKey = 'match_statistics_${eid}_$category';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      print('DEBUG: Returning cached statistics for EID = $eid');
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/matches/v2/get-statistics',
    ).replace(
      queryParameters: {
        'Eid': eid,
        'Category': category,
      },
    );
    
    print('DEBUG: Statistics API URL = ${uri.toString()}');

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
        print('DEBUG: Statistics response keys: ${decoded.keys.toList()}');
        
        // Check for data in various possible keys
        if (decoded.containsKey('stats')) {
          // Direct stats array at top level
          print('DEBUG: Found stats key');
          statisticsData = decoded;
        } else if (decoded.containsKey('statistics')) {
          // Alternative statistics key
          print('DEBUG: Found statistics key');
          statisticsData = decoded;
        } else if (decoded.containsKey('match')) {
          // Data nested under 'match' key
          print('DEBUG: Found match key');
          final matchData = decoded['match'];
          if (matchData is Map<String, dynamic>) {
            statisticsData = matchData;
          }
        } else if (decoded.containsKey('M')) {
          // Abbreviated match key
          print('DEBUG: Found M key');
          final matchData = decoded['M'];
          if (matchData is Map<String, dynamic>) {
            statisticsData = matchData;
          }
        } else if (decoded.containsKey('data')) {
          // Data nested under 'data' key
          print('DEBUG: Found data key');
          final dataValue = decoded['data'];
          if (dataValue is Map<String, dynamic>) {
            statisticsData = dataValue;
          }
        } else if (decoded.containsKey('response')) {
          // Data nested under 'response' key
          print('DEBUG: Found response key');
          final responseValue = decoded['response'];
          if (responseValue is Map<String, dynamic>) {
            statisticsData = responseValue;
          }
        } else {
          // Return the full response for inspection if format is unknown
          print('DEBUG: Unknown response format, returning full response');
          statisticsData = decoded.isEmpty ? {} : decoded;
        }
      }
    } catch (e) {
      // If parsing fails, return empty map
      print('DEBUG: Error parsing statistics response: $e');
      statisticsData = {};
    }

    print('DEBUG: Final statisticsData keys: ${statisticsData.keys.toList()}');
    _cache.set(cacheKey, statisticsData, ttl: const Duration(minutes: 5));
    return statisticsData;
  }

  Future<Map<String, dynamic>> fetchH2H({
    required String eid,
    required String category,
  }) async {
    print('DEBUG: fetchH2H called with EID = $eid, Category = $category');
    
    final cacheKey = 'match_h2h_${eid}_$category';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      print('DEBUG: Returning cached H2H for EID = $eid');
      return cached;
    }

    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Missing LiveScore API config. Set LIVE_SCORE_API_KEY with --dart-define.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.liveScoreBaseUrl}/matches/v2/get-h2h',
    ).replace(
      queryParameters: {
        'Eid': eid,
        'Category': category,
      },
    );
    
    print('DEBUG: H2H API URL = ${uri.toString()}');

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
        print('DEBUG: H2H response keys: ${decoded.keys.toList()}');
        
        // Check for data in various possible keys
        if (decoded.containsKey('h2h')) {
          // Direct h2h array at top level
          print('DEBUG: Found h2h key');
          h2hData = decoded;
        } else if (decoded.containsKey('headToHead')) {
          // Alternative h2h key
          print('DEBUG: Found headToHead key');
          h2hData = decoded;
        } else if (decoded.containsKey('H2H')) {
          // Capitalized h2h key
          print('DEBUG: Found H2H key');
          h2hData = decoded;
        } else if (decoded.containsKey('events')) {
          // Events array
          print('DEBUG: Found events key');
          h2hData = decoded;
        } else if (decoded.containsKey('match')) {
          // Data nested under 'match' key
          print('DEBUG: Found match key');
          final matchData = decoded['match'];
          if (matchData is Map<String, dynamic>) {
            h2hData = matchData;
          }
        } else if (decoded.containsKey('data')) {
          // Data nested under 'data' key
          print('DEBUG: Found data key');
          final dataValue = decoded['data'];
          if (dataValue is Map<String, dynamic>) {
            h2hData = dataValue;
          }
        } else if (decoded.containsKey('response')) {
          // Data nested under 'response' key
          print('DEBUG: Found response key');
          final responseValue = decoded['response'];
          if (responseValue is Map<String, dynamic>) {
            h2hData = responseValue;
          }
        } else {
          // Return the full response for inspection if format is unknown
          print('DEBUG: Unknown response format, returning full response');
          h2hData = decoded.isEmpty ? {} : decoded;
        }
      }
    } catch (e) {
      // If parsing fails, return empty map
      print('DEBUG: Error parsing H2H response: $e');
      h2hData = {};
    }

    print('DEBUG: Final h2hData keys: ${h2hData.keys.toList()}');
    _cache.set(cacheKey, h2hData, ttl: const Duration(minutes: 5));
    return h2hData;
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

  List<LeagueOption> _extractLeagueOptions(
    dynamic decoded,
    String category,
  ) {
    final stages = _extractStages(decoded);
    final options = <LeagueOption>[];
    final seen = <String>{};

    for (final stage in stages) {
      if (stage is! Map<String, dynamic>) {
        continue;
      }

      final ccd = _readString(
        stage,
        const ['Ccd', 'ccd', 'CompCcd', 'competitionCode'],
      );
      if (ccd.isEmpty) {
        continue;
      }

      final scd = _readString(
        stage,
        const ['Scd', 'scd', 'stageCode', 'groupCode'],
      );
      final key = '$ccd|$scd';
      if (!seen.add(key)) {
        continue;
      }

      options.add(
        LeagueOption(
          category: category,
          title: _readString(
            stage,
            const ['CompN', 'Snm', 'competitionName', 'name'],
            fallback: ccd,
          ),
          subtitle: _readString(
            stage,
            const ['CompD', 'CompST', 'Cnm', 'Csnm', 'country', 'region'],
            fallback: category.toUpperCase(),
          ),
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

    final items = newsNodes
        .map(_parseNewsItem)
        .whereType<NewsItem>()
        .toList();

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
    );
    final eid = _readString(
      node,
      const ['Eid', 'eid', 'eventId', 'matchId'],
    );
    final ccd = _readString(
      node,
      const ['Ccd', 'ccd', 'CompCcd', 'countryCode'],
    );
    final scd = _readString(
      node,
      const ['Scd', 'scd', 'stageCode', 'leagueCode'],
    );
    final teamA = _readString(
      node,
      const ['T1.0.Nm', 'homeTeam', 'home_name'],
    );
    final teamB = _readString(
      node,
      const ['T2.0.Nm', 'awayTeam', 'away_name'],
    );

    return title.isNotEmpty ||
        eid.isNotEmpty ||
        ccd.isNotEmpty ||
        scd.isNotEmpty ||
        teamA.isNotEmpty ||
        teamB.isNotEmpty;
  }

  SearchResult? _parseSearchResult(
    Map<String, dynamic> node,
    String category,
  ) {
    final eid = _readString(
      node,
      const ['Eid', 'eid', 'eventId', 'matchId'],
    );
    final ccd = _readString(
      node,
      const ['Ccd', 'ccd', 'CompCcd', 'countryCode'],
    );
    final scd = _readString(
      node,
      const ['Scd', 'scd', 'stageCode', 'leagueCode'],
    );

    final homeTeam = _readString(
      node,
      const ['T1.0.Nm', 'homeTeam', 'home_name'],
    );
    final awayTeam = _readString(
      node,
      const ['T2.0.Nm', 'awayTeam', 'away_name'],
    );

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

    final subtitle = _readString(
      node,
      const [
        'CompD',
        'CompST',
        'Cnm',
        'Csnm',
        'country',
        'region',
        'subtitle',
        'description',
      ],
      fallback: category.toUpperCase(),
    );

    final explicitType = _readString(
      node,
      const ['Type', 'type', 'entityType', 'searchType'],
    ).toLowerCase();

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
      imageUrl: _readString(
        node,
        const ['Img', 'img', 'image', 'logo', 'badge'],
      ),
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeScore: _readString(
        node,
        const ['Tr1', 'Tr1OR', 'homeScore', 'home_score'],
      ),
      awayScore: _readString(
        node,
        const ['Tr2', 'Tr2OR', 'awayScore', 'away_score'],
      ),
      status: _readString(
        node,
        const ['Eps', 'EpsL', 'status', 'statusText'],
        fallback: 'Scheduled',
      ),
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
    final countryCode = _readString(
      stage,
      const ['Ccd', 'ccd', 'CompCcd', 'countryCode'],
      fallback: '',
    );

    final events = stage['Events'] ?? stage['events'];
    if (events is! List<dynamic>) {
      return const [];
    }

    return events
        .map((dynamic event) => _parseEvent(event, competition, country, countryCode))
        .whereType<MatchItem>()
        .toList();
  }

  MatchItem? _parseEvent(dynamic event, String competition, String country, String countryCode) {
    if (event is! Map<String, dynamic>) {
      return null;
    }

    // Extract eid with multiple fallback keys
    final eid = _readString(
      event,
      const [
        'Eid',           // Primary key from list endpoints
        'eid',           // Lowercase variant
        'ID',            // Alternative uppercase
        'Id',            // Mixed case
        'eventId',       // Alternative name
        'event_id',      // Snake case
        'matchId',       // Alternative name
        'match_id',      // Snake case
        'E_Id',          // Underscore variant
      ],
    );
    if (eid.isEmpty) {
      print('DEBUG: Failed to extract EID from event. Available keys: ${event.keys.toList()}');
      return null;
    }
    print('DEBUG: Extracted EID = $eid from list endpoint. Available keys: ${event.keys.take(10).toList()}');

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
      eid: eid,
      competition: competition,
      country: country,
      countryCode: countryCode,
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






