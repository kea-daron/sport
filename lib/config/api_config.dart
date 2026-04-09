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
    defaultValue: '7a1388ff13msh64d06ac50d5a0cfp1e3d48jsnd37d68218ff7',
  );

  static const String liveScoreApiHost = String.fromEnvironment(
    'LIVE_SCORE_API_HOST',
    defaultValue: 'livescore6.p.rapidapi.com',
  );

  static bool get isConfigured => liveScoreApiKey.isNotEmpty;
}
