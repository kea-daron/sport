import 'league_option.dart';
import 'match_item.dart';

class SearchResult {
  final String category;
  final String title;
  final String subtitle;
  final String type;
  final String eid;
  final String ccd;
  final String scd;
  final String imageUrl;
  final String homeTeam;
  final String awayTeam;
  final String homeScore;
  final String awayScore;
  final String status;
  final DateTime? startTime;

  const SearchResult({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.eid,
    required this.ccd,
    required this.scd,
    required this.imageUrl,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    required this.startTime,
  });

  bool get canOpenMatch => eid.isNotEmpty;
  bool get canOpenLeague => ccd.isNotEmpty;

  LeagueOption toLeagueOption() {
    return LeagueOption(
      category: category,
      title: title,
      subtitle: subtitle,
      ccd: ccd,
      scd: scd,
    );
  }

  MatchItem toMatchItem() {
    return MatchItem(
      eid: eid,
      competition: title,
      country: subtitle,
      countryCode: ccd,
      homeTeamId: '',
      awayTeamId: '',
      homeTeam: homeTeam.isNotEmpty ? homeTeam : title,
      awayTeam: awayTeam,
      homeTeamImage: '',
      awayTeamImage: '',
      homeScore: homeScore,
      awayScore: awayScore,
      status: status,
      startTime: startTime,
    );
  }
}
