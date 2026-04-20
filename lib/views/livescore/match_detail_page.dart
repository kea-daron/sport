import 'package:flutter/material.dart';

import '../../models/match_item.dart';
import '../../services/live_score_service.dart';
import '../../theme/app_palette.dart';
import '../../widgets/app_skeleton.dart';
import 'match_detail/match_detail_helpers.dart';
import 'match_detail/tabs/overview_tab.dart';
import 'match_detail/tabs/summary_tab.dart';
import 'match_detail/tabs/lineups_tab.dart';
import 'match_detail/tabs/statistics_tab.dart';
import 'match_detail/tabs/table_tab.dart';
import 'match_detail/tabs/h2h_tab.dart';

class MatchDetailPage extends StatefulWidget {
  final MatchItem match;
  final String category;

  const MatchDetailPage({
    super.key,
    required this.match,
    required this.category,
  });

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  final LiveScoreService _liveScoreService = const LiveScoreService();

  late Future<Map<String, dynamic>> _detailFuture;
  late Future<Map<String, dynamic>> _scoreboardFuture;
  late Future<Map<String, dynamic>> _lineupsFuture;
  late Future<Map<String, dynamic>> _incidentsFuture;
  late Future<Map<String, dynamic>> _statisticsFuture;
  late Future<Map<String, dynamic>> _tableFuture;
  late Future<Map<String, dynamic>> _h2hFuture;
  late Future<Map<String, dynamic>> _homeTeamDetailFuture;
  late Future<Map<String, dynamic>> _awayTeamDetailFuture;

  int _selectedTab = 0;

  static const _tabs = [
    'OVERVIEW', 'SUMMARY', 'LINEUPS', 'STATISTICS', 'TABLE', 'H2H',
  ];

  @override
  void initState() {
    super.initState();
    _initFutures();
  }

  void _initFutures() {
    // ✅ Each future assigned to correct variable
    _detailFuture = _liveScoreService.fetchMatchDetail(
        eid: widget.match.eid, category: widget.category);

    _scoreboardFuture = _liveScoreService.fetchScoreboard(
        eid: widget.match.eid, category: widget.category);

    _incidentsFuture = _liveScoreService.fetchIncidents(  // ✅ correctly assigned
        eid: widget.match.eid, category: widget.category);

    _lineupsFuture = _liveScoreService.fetchLineups(
        eid: widget.match.eid, category: widget.category);

    _statisticsFuture = _liveScoreService.fetchStatistics(
        eid: widget.match.eid, category: widget.category);

    _tableFuture = _loadLeagueTable();

    _h2hFuture = _liveScoreService.fetchH2H(
        eid: widget.match.eid, category: widget.category);

    _homeTeamDetailFuture = _loadTeamDetail(widget.match.homeTeamId);
    _awayTeamDetailFuture = _loadTeamDetail(widget.match.awayTeamId);
  }

  Future<Map<String, dynamic>> _loadLeagueTable() async {
    final teamId = widget.match.homeTeamId.trim().isNotEmpty
        ? widget.match.homeTeamId
        : widget.match.awayTeamId;
    if (teamId.trim().isEmpty) return const {};
    return _liveScoreService.fetchLeagueTable(teamId: teamId);
  }

  Future<Map<String, dynamic>> _loadTeamDetail(String teamId) async {
    final id = teamId.trim();
    if (id.isEmpty) return const {};
    try {
      return await _liveScoreService.fetchTeamDetail(teamId: id);
    } catch (_) {
      return const {};
    }
  }

  void _reloadAllData() {
    setState(_initFutures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.pageBackground,
      appBar: AppBar(
        backgroundColor: AppPalette.pageBackground,
        foregroundColor: AppPalette.textPrimary,
        elevation: 0,
        title: Text(
          '${widget.match.homeTeam} vs ${widget.match.awayTeam}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MatchDetailLoadingSkeleton();
          }
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }
          final detail = snapshot.data ?? {};
          return Column(
            children: [
              _buildTabBar(),
              Expanded(child: _buildTabContent(detail)),
            ],
          );
        },
      ),
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final selected = _selectedTab == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.yellow.shade600.withOpacity(0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected
                        ? Colors.yellow.shade600.withOpacity(0.5)
                        : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? Colors.yellow.shade500
                        : Colors.white.withOpacity(0.65),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Tab content router ────────────────────────────────────────────────────

  Widget _buildTabContent(Map<String, dynamic> detail) {
    switch (_selectedTab) {
      case 0:
        return OverviewTab(
          match: widget.match,
          detail: detail,
          homeTeamDetailFuture: _homeTeamDetailFuture,
          awayTeamDetailFuture: _awayTeamDetailFuture,
        );
      case 1:
        return SummaryTab(
          match: widget.match,
          detail: detail,
          scoreboardFuture: _scoreboardFuture,
          incidentsFuture: _incidentsFuture,
        );
      case 2:
        return LineupsTab(
          match: widget.match,
          category: widget.category,
          lineupsFuture: _lineupsFuture,
        );
      case 3:
        return StatisticsTab(
          match: widget.match,
          category: widget.category,
          statisticsFuture: _statisticsFuture,
        );
      case 4:
        return TableTab(
          match: widget.match,
          tableFuture: _tableFuture,
        );
      case 5:
        return H2HTab(
          match: widget.match,
          category: widget.category,
          h2hFuture: _h2hFuture,
        );
      default:
        return OverviewTab(
          match: widget.match,
          detail: detail,
          homeTeamDetailFuture: _homeTeamDetailFuture,
          awayTeamDetailFuture: _awayTeamDetailFuture,
        );
    }
  }

  // ── Error widget ──────────────────────────────────────────────────────────

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            const Text('Failed to load match details',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 13)),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _reloadAllData,
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.yellow.shade600)),
              child: Text('Retry',
                  style: TextStyle(color: Colors.yellow.shade600)),
            ),
          ],
        ),
      ),
    );
  }
}