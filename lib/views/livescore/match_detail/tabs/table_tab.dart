import 'package:flutter/material.dart';
import '../../../../models/match_item.dart';
import '../../../../widgets/app_skeleton.dart';
import '../match_detail_fields.dart';
import '../match_detail_helpers.dart';
import '../widgets/shared_widgets.dart';

class TableTab extends StatelessWidget {
  final MatchItem match;
  final Future<Map<String, dynamic>> tableFuture;

  const TableTab({
    super.key,
    required this.match,
    required this.tableFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: tableFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MatchListLoadingSkeleton(cardCount: 4, showHeader: true);
        }

        if (snapshot.hasError) {
          return SimpleInfoState(
            title: 'Unable to load table',
            message: snapshot.error.toString(),
            accentColor: Colors.red.shade300,
          );
        }

        final table = snapshot.data ?? {};
        final rows = _extractLeagueTableRows(table);

        if (rows.isEmpty) {
          return const SimpleInfoState(
            title: 'No table available',
            message: 'League standings are not available for this match yet.',
            accentColor: Colors.orange,
          );
        }

        final competitionName = H.readDisplayValue(
            table, const [F.competitionName, F.stageName, 'Sdn'], 'League Table');
        final competitionSubtitle = H.readDisplayValue(
            table, const [F.competitionDesc, F.competitionSub, F.countryName], match.country);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.yellow.shade700.withOpacity(0.16),
                    Colors.blue.shade400.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(competitionName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(competitionSubtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.68), fontSize: 13)),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _tableBadge('Rows', '${rows.length}'),
                      _tableBadge('Home', match.homeTeam),
                      _tableBadge('Away', match.awayTeam),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  _buildTableHeaderRow(),
                  Divider(color: Colors.white.withOpacity(0.08), height: 1),
                  ...rows.map(_buildLeagueRow),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _tableBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12)),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: '$label  ',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          TextSpan(
              text: value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _buildTableHeaderRow() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(12, 14, 12, 10),
      child: Row(
        children: [
          SizedBox(width: 32, child: _TableHeaderText('#')),
          Expanded(flex: 4, child: _TableHeaderText('Team')),
          Expanded(child: _TableHeaderText('MP', align: TextAlign.center)),
          Expanded(child: _TableHeaderText('W', align: TextAlign.center)),
          Expanded(child: _TableHeaderText('D', align: TextAlign.center)),
          Expanded(child: _TableHeaderText('L', align: TextAlign.center)),
          Expanded(child: _TableHeaderText('GD', align: TextAlign.center)),
          Expanded(child: _TableHeaderText('PTS', align: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildLeagueRow(Map<String, dynamic> row) {
    String r(List<String> keys, String fb) => H.readDisplayValue(row, keys, fb);

    final teamId   = r(const [F.teamId, 'teamId', F.participantId], '');
    final teamName = r(const [F.teamName, F.participantNm, 'name'], 'Unknown');
    final rank     = r(const ['rnk', 'rank', 'pos'], '-');
    final played   = r(const ['pld', 'played'], '-');
    final wins     = r(const ['win', 'winn', 'wins'], '-');
    final draws    = r(const ['drw', 'drwn', 'draws'], '-');
    final losses   = r(const ['lst', 'lstn', 'losses'], '-');
    final gd       = r(const ['gd', 'goalDifference'], '-');
    final points   = r(const ['ptsn', 'pts', 'points'], '-');
    final teamImage= r(const [F.badgeId, 'img'], '');

    final isHomeTeam = teamId == match.homeTeamId;
    final isAwayTeam = teamId == match.awayTeamId;
    final isHighlighted = isHomeTeam || isAwayTeam;
    final accentColor = isHomeTeam
        ? Colors.yellow.shade600
        : isAwayTeam
        ? Colors.blue.shade300
        : Colors.white;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted
            ? accentColor.withOpacity(0.12)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isHighlighted ? accentColor.withOpacity(0.45) : Colors.transparent),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(rank,
                style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800)),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                MiniTeamBadge(
                    teamName: teamName,
                    imagePath: teamImage,
                    accentColor: accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(teamName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      if (isHighlighted)
                        Text(isHomeTeam ? 'Home side' : 'Away side',
                            style: TextStyle(
                                color: accentColor.withOpacity(0.92),
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _tableCell(played),
          _tableCell(wins),
          _tableCell(draws),
          _tableCell(losses),
          _tableCell(gd),
          _tableCell(points, emphasize: true),
        ],
      ),
    );
  }

  Widget _tableCell(String value, {bool emphasize = false}) {
    return Expanded(
      child: Text(value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: emphasize ? Colors.white : Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
          )),
    );
  }

  List<Map<String, dynamic>> _extractLeagueTableRows(Map<String, dynamic> tableData) {
    final leagueTable = tableData['LeagueTable'];
    if (leagueTable is! Map<String, dynamic>) return const [];
    final groups = leagueTable['L'];
    if (groups is! List) return const [];

    final rows = <Map<String, dynamic>>[];
    for (final group in groups) {
      if (group is! Map<String, dynamic>) continue;
      final tables = group['Tables'];
      if (tables is! List) continue;
      for (final table in tables) {
        if (table is! Map<String, dynamic>) continue;
        final teams = table['team'];
        if (teams is! List) continue;
        rows.addAll(teams.whereType<Map<String, dynamic>>());
      }
    }
    return rows;
  }
}

class _TableHeaderText extends StatelessWidget {
  final String text;
  final TextAlign align;

  const _TableHeaderText(this.text, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: align,
        style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4));
  }
}