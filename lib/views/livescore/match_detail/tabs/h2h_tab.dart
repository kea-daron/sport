import 'package:flutter/material.dart';
import '../../../../models/match_item.dart';
import '../../../../widgets/app_skeleton.dart';
import '../match_detail_fields.dart';
import '../match_detail_helpers.dart';
import '../widgets/shared_widgets.dart';

class H2HTab extends StatelessWidget {
  final MatchItem match;
  final String category;
  final Future<Map<String, dynamic>> h2hFuture;

  const H2HTab({
    super.key,
    required this.match,
    required this.category,
    required this.h2hFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: h2hFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MatchListLoadingSkeleton(cardCount: 3, showHeader: true);
        }

        if (snapshot.hasError) {
          return SimpleInfoState(
            title: 'Error loading H2H history',
            message: snapshot.error.toString(),
            accentColor: Colors.red.shade300,
          );
        }

        final h2h = snapshot.data ?? {};
        if (h2h.isEmpty) return _buildEmptyState();

        final matches = _extractH2HMatches(h2h);
        if (matches.isEmpty) return _buildEmptyState();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...matches.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildH2HMatchCard(m),
            )),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.5)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.info_outline, color: Colors.orange.shade400, size: 20),
                const SizedBox(width: 8),
                Text('No H2H data available',
                    style: TextStyle(
                        color: Colors.orange.shade400,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 12),
              Text('Head-to-head history is not available for this match.',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              const SizedBox(height: 8),
              Text(
                  '• These teams haven\'t played each other\n• The API doesn\'t have H2H data\n• This is a new matchup',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Debug Info',
                      style: TextStyle(
                          color: Colors.yellow.shade600,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Match ID: ${match.eid}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
                  Text('Category: $category',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _extractH2HMatches(Map<String, dynamic> h2hData) {
    for (final key in [F.h2hEvents, 'h2h', 'headToHead', 'events', 'E']) {
      final v = h2hData[key];
      if (v is List) {
        return v.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  Widget _buildH2HMatchCard(Map<String, dynamic> m) {
    final stage = m[F.stageGroup] as Map<String, dynamic>?;
    final homeTeamData = _extractH2HTeam(m[F.homeTeam]);
    final awayTeamData = _extractH2HTeam(m[F.awayTeam]);
    final homeScore = H.readNested(m, const [F.homeScore, 'T1Sc', 'homeScore'], '-');
    final awayScore = H.readNested(m, const [F.awayScore, 'T2Sc', 'awayScore'], '-');
    final stageName = H.readNested(stage ?? const {}, const [F.stageName, 'snm', F.participantNm, 'name'], 'League');
    final formattedDate = H.formatH2HDate(H.readNested(m, const [F.matchStartDate, 'esd', 'date'], ''));

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: Row(children: [
                  const Icon(Icons.emoji_events_outlined, size: 12, color: Colors.white70),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(stageName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 11, color: Colors.white70),
                const SizedBox(width: 4),
                Text(formattedDate,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4)),
              ]),
            ]),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 1,
                color: Colors.white.withOpacity(0.08)),
            Row(children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(homeTeamData['name'] ?? 'Home',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: _winColor(homeScore, awayScore),
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    _teamLogo(homeTeamData['image'] ?? ''),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(children: [
                  _scoreBox(homeScore, awayScore),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: const Text('-',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                  _scoreBox(awayScore, homeScore),
                ]),
              ),
              Expanded(
                child: Row(
                  children: [
                    _teamLogo(awayTeamData['image'] ?? ''),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(awayTeamData['name'] ?? 'Away',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: _winColor(awayScore, homeScore),
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Map<String, String> _extractH2HTeam(dynamic raw) {
    Map<String, dynamic>? team;
    if (raw is List<dynamic> && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
      team = raw.first as Map<String, dynamic>;
    } else if (raw is Map<String, dynamic>) {
      team = raw;
    }
    if (team != null) {
      return {
        'name': H.readNested(team, const [F.participantNm, 'name', F.teamName], 'Unknown'),
        'image': H.readNested(team, const [F.badgeId, 'img'], ''),
      };
    }
    return {'name': raw?.toString() ?? 'Unknown', 'image': ''};
  }

  Widget _teamLogo(String imagePath) {
    final url = H.teamImageUrl(imagePath);
    return Container(
      width: 32, height: 32,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: url == null
          ? const Icon(Icons.shield_outlined, size: 16, color: Colors.white70)
          : Image.network(url,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.shield_outlined, size: 16, color: Colors.white70)),
    );
  }

  Widget _scoreBox(String score, String opponentScore) {
    final cur = int.tryParse(score) ?? 0;
    final opp = int.tryParse(opponentScore) ?? 0;
    Color bg, text, border;
    if (cur > opp) {
      bg = const Color(0xFFDCFCE7); text = Colors.black; border = const Color(0xFFBBF7D0);
    } else if (cur < opp) {
      bg = const Color(0xFFFEE2E2); text = Colors.black; border = const Color(0xFFFECACA);
    } else {
      bg = const Color(0xFF9CA3AF); text = Colors.white; border = const Color(0xFF6B7280);
    }
    return Container(
      width: 28, height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(score,
          style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w800)),
    );
  }

  Color _winColor(String score, String opponentScore) {
    final cur = int.tryParse(score) ?? 0;
    final opp = int.tryParse(opponentScore) ?? 0;
    return cur > opp ? Colors.white : Colors.white70;
  }
}