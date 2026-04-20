class ApiConfig {
  const ApiConfig._();

  static const String liveScoreBaseUrl = String.fromEnvironment(
    'LIVE_SCORE_BASE_URL',
    defaultValue: 'https://livescore6.p.rapidapi.com',
  );

  static const String liveScorePath = String.fromEnvironment(
    'LIVE_SCORE_PATH',
    defaultValue: '/matches/v2/list-by-date',
  );

  static const String liveScoreLivePath = String.fromEnvironment(
    'LIVE_SCORE_LIVE_PATH',
    defaultValue: '/matches/v2/list-live',
  );

  static const String liveScoreApiKey = String.fromEnvironment(
    'LIVE_SCORE_API_KEY',
    defaultValue: '080bd0f095mshc00aa64a910bb81p18112ajsnf2d4904a643c',
  );

  static const String liveScoreApiHost = String.fromEnvironment(
    'LIVE_SCORE_API_HOST',
    defaultValue: 'livescore6.p.rapidapi.com',
  );

  static bool get isConfigured => liveScoreApiKey.isNotEmpty;
}
