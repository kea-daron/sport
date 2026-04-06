class MatchItem {
  final String eid;
  final String competition;
  final String country;
  final String countryCode;
  final String homeTeamId;
  final String awayTeamId;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamImage;
  final String awayTeamImage;
  final String homeScore;
  final String awayScore;
  final String status;
  final DateTime? startTime;

  const MatchItem({
    required this.eid,
    required this.competition,
    required this.country,
    required this.countryCode,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeTeamImage,
    required this.awayTeamImage,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    required this.startTime,
  });
}
