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
    defaultValue: 'f5133f2291msh011e18c436f75a3p17a014jsnc98ab760a371',
  );

  static const String liveScoreApiHost = String.fromEnvironment(
    'LIVE_SCORE_API_HOST',
    defaultValue: 'livescore6.p.rapidapi.com',
  );

  static bool get isConfigured => liveScoreApiKey.isNotEmpty;
}
