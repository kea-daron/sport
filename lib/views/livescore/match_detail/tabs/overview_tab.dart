import 'package:flutter/material.dart';
import '../../../../models/match_item.dart';
import '../../../../widgets/app_skeleton.dart';
import '../match_detail_fields.dart';
import '../match_detail_helpers.dart';
import '../widgets/shared_widgets.dart';

class OverviewTab extends StatelessWidget {
  final MatchItem match;
  final Map<String, dynamic> detail;
  final Future<Map<String, dynamic>> homeTeamDetailFuture;
  final Future<Map<String, dynamic>> awayTeamDetailFuture;

  const OverviewTab({
    super.key,
    required this.match,
    required this.detail,
    required this.homeTeamDetailFuture,
    required this.awayTeamDetailFuture,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMatchHeader(),
        const SizedBox(height: 24),
        _buildDetailSection(context),
        const SizedBox(height: 24),
        _buildTeamDetailsSection(),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Match header ──────────────────────────────────────────────────────────

  Widget _buildMatchHeader() {
    final showScores =
        match.homeScore.isNotEmpty && match.awayScore.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromARGB(255, 111, 48, 48).withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Text(match.competition,
              style: TextStyle(
                  color: Colors.yellow.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(match.country,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TeamBadgeCircle(teamName: match.homeTeam, teamImage: match.homeTeamImage),
                    const SizedBox(height: 8),
                    Text(match.homeTeam,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    if (showScores) ...[
                      const SizedBox(height: 8),
                      Text(match.homeScore,
                          style: TextStyle(
                              color: Colors.yellow.shade600,
                              fontSize: 28,
                              fontWeight: FontWeight.w800)),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(H.statusLabel(match.status),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(H.statusBadgeText(match.status),
                        style: TextStyle(
                            color: H.statusColor(match.status),
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    TeamBadgeCircle(teamName: match.awayTeam, teamImage: match.awayTeamImage),
                    const SizedBox(height: 8),
                    Text(match.awayTeam,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    if (showScores) ...[
                      const SizedBox(height: 8),
                      Text(match.awayScore,
                          style: TextStyle(
                              color: Colors.yellow.shade600,
                              fontSize: 28,
                              fontWeight: FontWeight.w800)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Detail section ────────────────────────────────────────────────────────

  Widget _buildDetailSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Match Information',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildDetailItems(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItems() {
    final matchInfo =
    detail['m'] is Map<String, dynamic> ? detail['m'] as Map<String, dynamic> : <String, dynamic>{};
    final items = <Widget>[];

    if (match.startTime != null) {
      items.add(_detailItem('Scheduled Time', H.formatDateTime(match.startTime!)));
      items.add(const Divider(color: Color(0xFF262626), height: 1));
    }
    if (matchInfo.containsKey('Venue')) {
      items.add(_detailItem('Venue', matchInfo['Venue']?.toString() ?? 'N/A'));
      items.add(const Divider(color: Color(0xFF262626), height: 1));
    }
    items.add(_detailItem('Status (Eps)', H.statusLabel(match.status)));
    items.add(const Divider(color: Color(0xFF262626), height: 1));
    items.add(_detailItem('Match ID (Eid)', match.eid));

    return Column(children: items);
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 13)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Team details section ──────────────────────────────────────────────────

  Widget _buildTeamDetailsSection() {
    final hasAnyTeamId =
        match.homeTeamId.trim().isNotEmpty || match.awayTeamId.trim().isNotEmpty;
    if (!hasAnyTeamId) return const SizedBox.shrink();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait([homeTeamDetailFuture, awayTeamDetailFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MatchListLoadingSkeleton(cardCount: 2, showHeader: false);
        }

        final details = snapshot.data ?? [];
        final homeDetail = details.isNotEmpty ? details[0] : <String, dynamic>{};
        final awayDetail = details.length > 1 ? details[1] : <String, dynamic>{};

        if (homeDetail.isEmpty && awayDetail.isEmpty) {
          return InfoCard(
            title: 'Team Details',
            message: 'No team detail data is available for this match yet.',
            accentColor: Colors.orange.shade400,
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 0, 0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Team Details',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
              Divider(color: Colors.white.withOpacity(0.08), height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTeamDetailCard(
                      teamName: match.homeTeam,
                      teamImage: match.homeTeamImage,
                      fallbackTeamId: match.homeTeamId,
                      detail: homeDetail,
                      accentColor: Colors.yellow.shade600,
                    ),
                    const SizedBox(height: 12),
                    _buildTeamDetailCard(
                      teamName: match.awayTeam,
                      teamImage: match.awayTeamImage,
                      fallbackTeamId: match.awayTeamId,
                      detail: awayDetail,
                      accentColor: Colors.blue.shade300,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamDetailCard({
    required String teamName,
    required String teamImage,
    required String fallbackTeamId,
    required Map<String, dynamic> detail,
    required Color accentColor,
  }) {
    final rows = _teamDetailRows(detail, fallbackTeamId: fallbackTeamId);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MiniTeamBadge(
                  teamName: teamName,
                  imagePath: teamImage,
                  accentColor: accentColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(teamName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  List<Widget> _teamDetailRows(Map<String, dynamic> detail,
      {required String fallbackTeamId}) {
    String r(List<String> paths, String fb) => H.readNested(detail, paths, fb);

    final resolvedId = r([F.participantId, 'Id', 'id', F.teamId], fallbackTeamId.trim());
    final displayName = r(['Name', 'name', F.participantNm, F.teamName], '');
    final shortName   = r([F.stageName, 'shortName', 'ShortName'], '');
    final country     = r(['Country', 'country', F.countryName, 'CountryName'], 'N/A');
    final city        = r(['City', 'city'], '');
    final stadium     = r(['Stadium', 'stadium', 'Venue', 'venue', 'Ven', 'Stdm'], 'N/A');
    final founded     = r(['Founded', 'founded', 'YearFounded'], 'N/A');
    final manager     = r(['Manager', 'manager', 'Coach', 'coach'], 'N/A');
    final website     = r(['Website', 'website'], '');

    final values = <MapEntry<String, String>>[];
    if (resolvedId.isNotEmpty) values.add(MapEntry('Team ID', resolvedId));
    if (displayName.isNotEmpty) values.add(MapEntry('Name', displayName));
    if (shortName.isNotEmpty) values.add(MapEntry('Short Name', shortName));
    if (country.isNotEmpty && country != 'N/A') values.add(MapEntry('Country', country));
    if (city.isNotEmpty) values.add(MapEntry('City', city));
    if (stadium.isNotEmpty && stadium != 'N/A') values.add(MapEntry('Stadium', stadium));
    if (founded.isNotEmpty && founded != 'N/A') values.add(MapEntry('Founded', founded));
    if (manager.isNotEmpty && manager != 'N/A') values.add(MapEntry('Manager', manager));
    if (website.isNotEmpty) values.add(MapEntry('Website', website));
    if (values.isEmpty) values.add(MapEntry('Team ID', resolvedId.isEmpty ? 'N/A' : resolvedId));

    return values.map((e) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(e.key,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(e.value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    )).toList();
  }
}