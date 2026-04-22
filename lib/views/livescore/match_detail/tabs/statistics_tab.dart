import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../models/match_item.dart';
import '../../../../widgets/app_skeleton.dart';
import '../match_detail_fields.dart';
import '../match_detail_helpers.dart';
import '../widgets/shared_widgets.dart';

class StatisticsTab extends StatelessWidget {
  final MatchItem match;
  final String category;
  final Future<Map<String, dynamic>> statisticsFuture;

  const StatisticsTab({
    super.key,
    required this.match,
    required this.category,
    required this.statisticsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: statisticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MatchListLoadingSkeleton(cardCount: 3, showHeader: true);
        }

        if (snapshot.hasError) {
          return SimpleInfoState(
            title: 'Error loading statistics',
            message: snapshot.error.toString(),
            accentColor: Colors.red.shade300,
          );
        }

        final statistics = snapshot.data ?? {};
        if (statistics.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [_buildEmptyState()],
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatisticsSection(statistics),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade400, size: 20),
              const SizedBox(width: 8),
              Text(
                'No statistics data available yet',
                style: TextStyle(
                  color: Colors.orange.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Match statistics are not available for this match yet.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• The match is still in progress\n• The match hasn\'t started yet\n• The API doesn\'t have statistics data',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Debug Info',
                  style: TextStyle(
                    color: Colors.yellow.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Match ID: ${match.eid}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'Category: $category',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(Map<String, dynamic> statistics) {
    final statRows = _extractMatchStatRows(statistics);

    if (statRows.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF171717),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Match Statistics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No statistics data available yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 49, 49, 50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Match Statistics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: statRows
                  .map(
                    (stat) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildStatBarRow(stat),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBarRow(Map<String, String> stat) {
    final homeText = stat['home'] ?? '0';
    final awayText = stat['away'] ?? '0';
    final label = stat['label'] ?? 'Stat';
    final homeValue = double.tryParse(homeText) ?? 0;
    final awayValue = double.tryParse(awayText) ?? 0;
    final total = homeValue + awayValue;
    final homePercent = total == 0 ? 50.0 : (homeValue / total) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                homeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              child: Text(
                awayText,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                Expanded(
                  flex: math.max(1, (homePercent * 100).round()),
                  child: Container(color: const Color(0xFFFFCE00)),
                ),
                Expanded(
                  flex: math.max(1, ((100 - homePercent) * 100).round()),
                  child: Container(color: const Color(0xFF2F2151)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _extractMatchStatRows(
    Map<String, dynamic> statistics,
  ) {
    final selectedKeys = <String, String>{
      F.statPossession: 'Possession (%)',
      F.statShotsOn: 'Shots on Target',
      F.statShotsOff: 'Shots off Target',
      F.statTotalShots: 'Total Shots',
      F.statCorners: 'Corners',
      F.statFouls: 'Fouls',
      F.statYellowCards: 'Yellow Cards',
      F.statRedCards: 'Red Cards',
      F.statOffsides: 'Offsides',
      F.statSaves: 'Saves',
      F.statAttacks: 'Attacks',
      F.statDangerousAtk: 'Dangerous Attacks',
    };

    final statList = _extractStatNodes(statistics);
    if (statList.length < 2) return const [];

    final homeStats = statList[0];
    final awayStats = statList[1];

    return selectedKeys.entries
        .map(
          (entry) => {
            'label': entry.value,
            'home': H.readDisplayValue(homeStats, [entry.key], '0'),
            'away': H.readDisplayValue(awayStats, [entry.key], '0'),
          },
        )
        .where((row) {
          final h = double.tryParse(row['home'] ?? '0') ?? 0;
          final a = double.tryParse(row['away'] ?? '0') ?? 0;
          return h != 0 || a != 0;
        })
        .toList();
  }

  List<Map<String, dynamic>> _extractStatNodes(
    Map<String, dynamic> statistics,
  ) {
    final statList = <Map<String, dynamic>>[];
    for (final key in ['Stat', 'Stats', 'stats', 'statistics']) {
      if (statistics[key] is List<dynamic>) {
        statList.addAll(
          (statistics[key] as List<dynamic>).whereType<Map<String, dynamic>>(),
        );
        if (statList.isNotEmpty) return statList;
      }
    }
    if (statList.length < 2 && statistics['teams'] is Map<String, dynamic>) {
      final teams = statistics['teams'] as Map<String, dynamic>;
      for (final teamData in teams.values.whereType<Map<String, dynamic>>()) {
        if (teamData['statistics'] is Map<String, dynamic>) {
          statList.add(
            Map<String, dynamic>.from(
              teamData['statistics'] as Map<String, dynamic>,
            ),
          );
        } else if (teamData['statistics'] is List<dynamic>) {
          statList.addAll(
            (teamData['statistics'] as List<dynamic>)
                .whereType<Map<String, dynamic>>(),
          );
        }
      }
    }
    return statList;
  }
}
