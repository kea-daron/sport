class MatchItem {
  final String competition;
  final String country;
  final String homeTeam;
  final String awayTeam;
  final String homeScore;
  final String awayScore;
  final String status;
  final DateTime? startTime;

  const MatchItem({
    required this.competition,
    required this.country,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    required this.startTime,
  });
}
