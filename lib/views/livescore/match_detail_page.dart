import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/match_item.dart';
import '../../services/live_score_service.dart';

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
  late Future<Map<String, dynamic>> _statisticsFuture;
  late Future<Map<String, dynamic>> _tableFuture;
  late Future<Map<String, dynamic>> _h2hFuture;
  late Future<Map<String, dynamic>> _homeTeamDetailFuture;
  late Future<Map<String, dynamic>> _awayTeamDetailFuture;
  late Future<Map<String, dynamic>> _homePlayerStatsFuture;
  late Future<Map<String, dynamic>> _awayPlayerStatsFuture;
  late Future<Map<String, dynamic>> _homeTeamStatsFuture;
  late Future<Map<String, dynamic>> _awayTeamStatsFuture;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    print(
      'DEBUG: MatchDetailPage initialized with EID = ${widget.match.eid}, Category = ${widget.category}',
    );
    print(
      'DEBUG: Match = ${widget.match.homeTeam} vs ${widget.match.awayTeam}',
    );

    _detailFuture = _liveScoreService.fetchMatchDetail(
      eid: widget.match.eid,
      category: widget.category,
    );
    _scoreboardFuture = _liveScoreService.fetchScoreboard(
      eid: widget.match.eid,
      category: widget.category,
    );
    _lineupsFuture = _liveScoreService.fetchLineups(
      eid: widget.match.eid,
      category: widget.category,
    );
    _statisticsFuture = _liveScoreService.fetchStatistics(
      eid: widget.match.eid,
      category: widget.category,
    );
    _tableFuture = _loadLeagueTable();
    _h2hFuture = _liveScoreService.fetchH2H(
      eid: widget.match.eid,
      category: widget.category,
    );
    _homeTeamDetailFuture = _loadTeamDetail(widget.match.homeTeamId);
    _awayTeamDetailFuture = _loadTeamDetail(widget.match.awayTeamId);
    _homePlayerStatsFuture = _loadPlayerStats(widget.match.homeTeamId);
    _awayPlayerStatsFuture = _loadPlayerStats(widget.match.awayTeamId);
    _homeTeamStatsFuture = _loadTeamStats(widget.match.homeTeamId);
    _awayTeamStatsFuture = _loadTeamStats(widget.match.awayTeamId);
  }

  Future<Map<String, dynamic>> _loadLeagueTable() async {
    final teamId = widget.match.homeTeamId.trim().isNotEmpty
        ? widget.match.homeTeamId
        : widget.match.awayTeamId;

    if (teamId.trim().isEmpty) {
      return const {};
    }

    return _liveScoreService.fetchLeagueTable(teamId: teamId);
  }

  Future<Map<String, dynamic>> _loadTeamDetail(String teamId) async {
    final normalizedTeamId = teamId.trim();
    if (normalizedTeamId.isEmpty) {
      return const {};
    }

    try {
      return await _liveScoreService.fetchTeamDetail(teamId: normalizedTeamId);
    } catch (_) {
      return const {};
    }
  }

  Future<Map<String, dynamic>> _loadPlayerStats(String teamId) async {
    final normalizedTeamId = teamId.trim();
    if (normalizedTeamId.isEmpty) {
      return const {};
    }

    try {
      return await _liveScoreService.fetchTeamPlayerStats(
        teamId: normalizedTeamId,
      );
    } catch (_) {
      return const {};
    }
  }

  Future<Map<String, dynamic>> _loadTeamStats(String teamId) async {
    final normalizedTeamId = teamId.trim();
    if (normalizedTeamId.isEmpty) {
      return const {};
    }

    try {
      return await _liveScoreService.fetchTeamStats(teamId: normalizedTeamId);
    } catch (_) {
      return const {};
    }
  }

  void _reloadAllData() {
    setState(() {
      _detailFuture = _liveScoreService.fetchMatchDetail(
        eid: widget.match.eid,
        category: widget.category,
      );
      _scoreboardFuture = _liveScoreService.fetchScoreboard(
        eid: widget.match.eid,
        category: widget.category,
      );
      _lineupsFuture = _liveScoreService.fetchLineups(
        eid: widget.match.eid,
        category: widget.category,
      );
      _statisticsFuture = _liveScoreService.fetchStatistics(
        eid: widget.match.eid,
        category: widget.category,
      );
      _tableFuture = _loadLeagueTable();
      _h2hFuture = _liveScoreService.fetchH2H(
        eid: widget.match.eid,
        category: widget.category,
      );
      _homeTeamDetailFuture = _loadTeamDetail(widget.match.homeTeamId);
      _awayTeamDetailFuture = _loadTeamDetail(widget.match.awayTeamId);
      _homePlayerStatsFuture = _loadPlayerStats(widget.match.homeTeamId);
      _awayPlayerStatsFuture = _loadPlayerStats(widget.match.awayTeamId);
      _homeTeamStatsFuture = _loadTeamStats(widget.match.homeTeamId);
      _awayTeamStatsFuture = _loadTeamStats(widget.match.awayTeamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
            return Center(
              child: CircularProgressIndicator(color: Colors.yellow.shade600),
            );
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

  Widget _buildTabBar() {
    final tabs = [
      'OVERVIEW',
      'SUMMARY',
      'LINEUPS',
      'STATISTICS',
      'PLAYERS',
      'TEAM STATS',
      'TABLE',
      'H2H',
    ];

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
          children: List.generate(
            tabs.length,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _selectedTab == index
                      ? Colors.yellow.shade600.withOpacity(0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _selectedTab == index
                        ? Colors.yellow.shade600.withOpacity(0.5)
                        : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == index
                        ? Colors.yellow.shade500
                        : Colors.white.withOpacity(0.65),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(Map<String, dynamic> detail) {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab(detail);
      case 1:
        return _buildSummaryTab(detail);
      case 2:
        return _buildLineupsTab();
      case 3:
        return _buildStatisticsTab();
      case 4:
        return _buildPlayerStatsTab();
      case 5:
        return _buildTeamStatsTab();
      case 6:
        return _buildTableTab();
      case 7:
        return _buildH2HTab();
      default:
        return _buildOverviewTab(detail);
    }
  }

  Widget _buildOverviewTab(Map<String, dynamic> detail) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMatchHeader(),
        const SizedBox(height: 24),
        _buildDetailSection('Match Information', detail),
        const SizedBox(height: 24),
        _buildTeamDetailsSection(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSummaryTab(Map<String, dynamic> detail) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _scoreboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.yellow.shade600),
          );
        }

        if (snapshot.hasError) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInlineInfoCard(
                title: 'Match Summary',
                message: 'Unable to load scoreboard data right now.',
                accentColor: Colors.orange.shade400,
              ),
            ],
          );
        }

        final scoreboard = snapshot.data ?? {};
        final summaryRows = _extractScoreboardRows(scoreboard);
        final timelineItems = _extractScoreboardTimeline(scoreboard);
        final highlightText = _extractScoreboardHighlight(scoreboard);

        if (summaryRows.isEmpty &&
            timelineItems.isEmpty &&
            highlightText.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInlineInfoCard(
                title: 'Match Summary',
                message: 'No scoreboard data is available for this match yet.',
                accentColor: Colors.orange.shade400,
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.yellow.shade600.withOpacity(0.14),
                          Colors.blue.shade300.withOpacity(0.08),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryHeroTeam(
                                teamName: widget.match.homeTeam,
                                teamImage: widget.match.homeTeamImage,
                                accentColor: Colors.yellow.shade600,
                                alignEnd: false,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _displayScore(widget.match.homeScore),
                                    style: TextStyle(
                                      color: Colors.yellow.shade600,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      '-',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _displayScore(widget.match.awayScore),
                                    style: TextStyle(
                                      color: Colors.blue.shade300,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: _buildSummaryHeroTeam(
                                teamName: widget.match.awayTeam,
                                teamImage: widget.match.awayTeamImage,
                                accentColor: Colors.blue.shade300,
                                alignEnd: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _statusLabel(widget.match.status),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.match.competition,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (highlightText.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            highlightText,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.72),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (timelineItems.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MATCH TIMELINE',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.42),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...timelineItems.map((item) {
                            final side = item['side'] ?? 'neutral';
                            final isHome = side == 'home';
                            final isAway = side == 'away';

                            return SizedBox(
                              height: 72,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: isHome
                                        ? _buildTimelineSide(
                                            item,
                                            alignEnd: true,
                                            accentColor: Colors.yellow.shade600,
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  SizedBox(
                                    width: 56,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: 1,
                                            color: Colors.white.withOpacity(
                                              0.08,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.08,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            item['minute'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            width: 1,
                                            color: Colors.white.withOpacity(
                                              0.08,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: isAway
                                        ? _buildTimelineSide(
                                            item,
                                            alignEnd: false,
                                            accentColor: Colors.blue.shade300,
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: summaryRows.map((row) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    row['left'] ?? '-',
                                    style: TextStyle(
                                      color: Colors.yellow.shade600,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    row['label'] ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.78),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    row['right'] ?? '-',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Colors.blue.shade300,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryHeroTeam({
    required String teamName,
    required String teamImage,
    required Color accentColor,
    required bool alignEnd,
  }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        _buildMiniTeamBadge(teamName, teamImage, accentColor),
        const SizedBox(height: 8),
        Text(
          teamName,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSide(
    Map<String, String> item, {
    required bool alignEnd,
    required Color accentColor,
  }) {
    final iconType = item['icon'] ?? 'default';
    final title = item['title'] ?? '';
    final subtitle = item['subtitle'] ?? '';

    return Padding(
      padding: EdgeInsets.only(left: alignEnd ? 0 : 8, right: alignEnd ? 8 : 0),
      child: Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: alignEnd
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!alignEnd) _buildTimelineIcon(iconType, accentColor),
              if (!alignEnd) const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  textAlign: alignEnd ? TextAlign.right : TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (alignEnd) const SizedBox(width: 8),
              if (alignEnd) _buildTimelineIcon(iconType, accentColor),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              textAlign: alignEnd ? TextAlign.right : TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
                height: 1.25,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineIcon(String iconType, Color accentColor) {
    IconData icon;
    Color color;

    switch (iconType) {
      case 'goal':
        icon = Icons.circle;
        color = Colors.lightBlue.shade300;
        break;
      case 'yellow':
        icon = Icons.stop;
        color = Colors.yellow.shade600;
        break;
      case 'red':
        icon = Icons.stop;
        color = Colors.red.shade400;
        break;
      case 'penalty':
        icon = Icons.circle;
        color = Colors.green.shade400;
        break;
      default:
        icon = Icons.circle;
        color = accentColor;
        break;
    }

    return Icon(icon, size: 15, color: color);
  }

  List<Map<String, String>> _extractScoreboardRows(
    Map<String, dynamic> payload,
  ) {
    final rows = <Map<String, String>>[];
    final candidates = <Map<String, dynamic>>[];
    _collectScoreboardNodes(payload, candidates);

    final seen = <String>{};
    for (final node in candidates) {
      final label = _readNestedDisplayValue(node, const [
        'Nm',
        'nm',
        'name',
        'Label',
        'label',
        'Period',
        'period',
        'Ttl',
        'ttl',
      ], '');
      final left = _readNestedDisplayValue(node, const [
        'Tr1',
        'tr1',
        'T1',
        't1',
        'home',
        'Home',
        'Left',
        'left',
        'S1',
        's1',
      ], '');
      final right = _readNestedDisplayValue(node, const [
        'Tr2',
        'tr2',
        'T2',
        't2',
        'away',
        'Away',
        'Right',
        'right',
        'S2',
        's2',
      ], '');

      if (label.isEmpty || (left.isEmpty && right.isEmpty)) {
        continue;
      }

      final key = '${label.toLowerCase()}|$left|$right';
      if (!seen.add(key)) {
        continue;
      }

      rows.add({
        'label': label,
        'left': left.isEmpty ? '-' : left,
        'right': right.isEmpty ? '-' : right,
      });
    }

    return rows.take(12).toList();
  }

  void _collectScoreboardNodes(
    dynamic current,
    List<Map<String, dynamic>> candidates,
  ) {
    if (current is Map<String, dynamic>) {
      if (_looksLikeScoreboardNode(current)) {
        candidates.add(current);
      }

      for (final value in current.values) {
        _collectScoreboardNodes(value, candidates);
      }
      return;
    }

    if (current is List<dynamic>) {
      for (final value in current) {
        _collectScoreboardNodes(value, candidates);
      }
    }
  }

  bool _looksLikeScoreboardNode(Map<String, dynamic> node) {
    final label = _readNestedDisplayValue(node, const [
      'Nm',
      'nm',
      'name',
      'Label',
      'label',
      'Period',
      'period',
      'Ttl',
      'ttl',
    ], '');
    final left = _readNestedDisplayValue(node, const [
      'Tr1',
      'tr1',
      'T1',
      't1',
      'home',
      'Home',
      'Left',
      'left',
      'S1',
      's1',
    ], '');
    final right = _readNestedDisplayValue(node, const [
      'Tr2',
      'tr2',
      'T2',
      't2',
      'away',
      'Away',
      'Right',
      'right',
      'S2',
      's2',
    ], '');

    return label.isNotEmpty && (left.isNotEmpty || right.isNotEmpty);
  }

  String _extractScoreboardHighlight(Map<String, dynamic> payload) {
    return _readNestedDisplayValue(payload, const [
      'Summary',
      'summary',
      'Desc',
      'desc',
      'Description',
      'description',
      'StatusText',
      'statusText',
      'EventStatus',
      'eventStatus',
    ], '');
  }

  List<Map<String, String>> _extractScoreboardTimeline(
    Map<String, dynamic> payload,
  ) {
    final candidates = <Map<String, dynamic>>[];
    _collectTimelineNodes(payload, candidates);

    final seen = <String>{};
    final items = <Map<String, String>>[];

    for (final node in candidates) {
      final minute = _readNestedDisplayValue(node, const [
        'Min',
        'min',
        'Minute',
        'minute',
        'Time',
        'time',
        'Tm',
        'tm',
      ], '');
      final title = _readNestedDisplayValue(node, const [
        'Nm',
        'nm',
        'name',
        'PlayerName',
        'playerName',
        'Pnm',
        'Title',
        'title',
      ], '');
      final subtitle = _buildTimelineSubtitle(node);

      if (minute.isEmpty || title.isEmpty) {
        continue;
      }

      final side = _inferTimelineSide(node);
      final icon = _inferTimelineIcon(node, subtitle);
      final key =
          '${minute.toLowerCase()}|${title.toLowerCase()}|${subtitle.toLowerCase()}|$side';
      if (!seen.add(key)) {
        continue;
      }

      items.add({
        'minute': minute,
        'title': title,
        'subtitle': subtitle,
        'side': side,
        'icon': icon,
      });
    }

    items.sort(
      (a, b) => _timelineMinuteSortValue(
        a['minute'] ?? '',
      ).compareTo(_timelineMinuteSortValue(b['minute'] ?? '')),
    );

    return items;
  }

  void _collectTimelineNodes(
    dynamic current,
    List<Map<String, dynamic>> candidates,
  ) {
    if (current is Map<String, dynamic>) {
      if (_looksLikeTimelineNode(current)) {
        candidates.add(current);
      }

      for (final value in current.values) {
        _collectTimelineNodes(value, candidates);
      }
      return;
    }

    if (current is List<dynamic>) {
      for (final value in current) {
        _collectTimelineNodes(value, candidates);
      }
    }
  }

  bool _looksLikeTimelineNode(Map<String, dynamic> node) {
    final minute = _readNestedDisplayValue(node, const [
      'Min',
      'min',
      'Minute',
      'minute',
      'Time',
      'time',
      'Tm',
      'tm',
    ], '');
    final title = _readNestedDisplayValue(node, const [
      'Nm',
      'nm',
      'name',
      'PlayerName',
      'playerName',
      'Pnm',
      'Title',
      'title',
    ], '');

    return minute.isNotEmpty && title.isNotEmpty;
  }

  String _buildTimelineSubtitle(Map<String, dynamic> node) {
    final primary = _readNestedDisplayValue(node, const [
      'Desc',
      'desc',
      'Type',
      'type',
      'TypeNm',
      'typeName',
      'IncidentType',
      'incidentType',
      'Detail',
      'detail',
    ], '');
    final score = _readNestedDisplayValue(node, const [
      'Score',
      'score',
      'Scr',
      'scr',
      'Result',
      'result',
    ], '');

    if (primary.isEmpty) {
      return score;
    }

    if (score.isEmpty || primary.contains(score)) {
      return primary;
    }

    return '$primary ($score)';
  }

  String _inferTimelineSide(Map<String, dynamic> node) {
    final raw = _readNestedDisplayValue(node, const [
      'Side',
      'side',
      'TeamSide',
      'teamSide',
      'Team',
      'team',
      'Competitor',
      'competitor',
      'Tid',
      'tid',
    ], '').toLowerCase();

    if (raw.contains('home') ||
        raw == '1' ||
        raw == widget.match.homeTeamId.toLowerCase()) {
      return 'home';
    }
    if (raw.contains('away') ||
        raw == '2' ||
        raw == widget.match.awayTeamId.toLowerCase()) {
      return 'away';
    }
    if (raw.contains(widget.match.homeTeam.toLowerCase())) {
      return 'home';
    }
    if (raw.contains(widget.match.awayTeam.toLowerCase())) {
      return 'away';
    }

    return 'neutral';
  }

  String _inferTimelineIcon(Map<String, dynamic> node, String subtitle) {
    final combined =
        (subtitle +
                ' ' +
                _readNestedDisplayValue(node, const [
                  'Type',
                  'type',
                  'IncidentType',
                  'incidentType',
                  'Desc',
                  'desc',
                ], ''))
            .toLowerCase();

    if (combined.contains('red')) {
      return 'red';
    }
    if (combined.contains('yellow')) {
      return 'yellow';
    }
    if (combined.contains('penalty')) {
      return 'penalty';
    }
    if (combined.contains('goal')) {
      return 'goal';
    }

    return 'default';
  }

  int _timelineMinuteSortValue(String value) {
    final normalized = value.replaceAll("'", '').trim();
    final parts = normalized.split('+');
    final base = int.tryParse(parts.first.trim()) ?? 0;
    final extra = parts.length > 1 ? (int.tryParse(parts[1].trim()) ?? 0) : 0;
    return base * 100 + extra;
  }

  String _displayScore(String score) {
    final trimmed = score.trim();
    return trimmed.isEmpty ? '0' : trimmed;
  }

  Widget _buildLineupsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _lineupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.yellow.shade600),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading lineups',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Match ID: ${widget.match.eid}',
                    style: TextStyle(
                      color: Colors.yellow.shade600,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final lineups = snapshot.data ?? {};

        print(
          'DEBUG Lineups Tab: Response keys = ${lineups.keys.toList()}, Empty = ${lineups.isEmpty}, EID = ${widget.match.eid}',
        );

        if (lineups.isEmpty) {
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
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No lineup data',
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
                      'Lineup information is not available for this match yet. This may be because:',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• The match hasn\'t started yet\n• The API doesn\'t have lineup data\n• The match ended without recording lineups',
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
                            'Match ID: ${widget.match.eid}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            'Category: ${widget.category}',
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
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _buildTacticalFormationField(lineups),
            const SizedBox(height: 16),
            _buildLineupDetailsSection(lineups),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildTacticalFormationField(Map<String, dynamic> lineups) {
    final homeTeam = _parseTeamLineup(lineups, true);
    final awayTeam = _parseTeamLineup(lineups, false);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF101010),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildLineupTeamHeader(
                    teamName: widget.match.homeTeam,
                    teamImage: widget.match.homeTeamImage,
                    formation: homeTeam['formation']?.toString() ?? '',
                    accentColor: Colors.amber.shade500,
                    alignEnd: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLineupTeamHeader(
                    teamName: widget.match.awayTeam,
                    teamImage: widget.match.awayTeamImage,
                    formation: awayTeam['formation']?.toString() ?? '',
                    accentColor: const Color(0xFF8D78FF),
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: MediaQuery.of(context).size.width < 760
                  ? 9 / 16
                  : 16 / 9,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 760;
                  final fieldSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: FootballFieldPainter(isCompact: isCompact),
                        ),
                      ),
                      ..._buildTeamFormationNodes(
                        homeTeam,
                        isHome: true,
                        fieldSize: fieldSize,
                        isCompact: isCompact,
                      ),
                      ..._buildTeamFormationNodes(
                        awayTeam,
                        isHome: false,
                        fieldSize: fieldSize,
                        isCompact: isCompact,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _parseTeamLineup(
    Map<String, dynamic> lineups,
    bool isHome,
  ) {
    if (lineups['Lu'] is List<dynamic>) {
      final parsed = _parseStructuredTeamLineup(lineups, isHome);
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }

    final starters = <Map<String, dynamic>>[];
    final bench = <Map<String, dynamic>>[];
    final injuries = <Map<String, dynamic>>[];
    final everyone = <Map<String, dynamic>>[];

    if (lineups.containsKey('pl') && lineups['pl'] is List) {
      final allPlayers = lineups['pl'] as List<dynamic>;
      for (final p in allPlayers) {
        if (p is Map<String, dynamic>) {
          if (_playerBelongsToTeam(p, isHome)) {
            everyone.add(p);
          }
        }
      }
    } else if (lineups.containsKey('teams') && lineups['teams'] is Map) {
      final teams = lineups['teams'] as Map<String, dynamic>;
      final teamKey = isHome ? 'home' : 'away';
      if (teams.containsKey(teamKey)) {
        final teamData = teams[teamKey] as Map<String, dynamic>?;
        everyone.addAll(_extractPlayerMapsFromDynamic(teamData?['players']));
        everyone.addAll(_extractPlayerMapsFromDynamic(teamData?['startingXI']));
        everyone.addAll(_extractPlayerMapsFromDynamic(teamData?['starting11']));
        everyone.addAll(_extractPlayerMapsFromDynamic(teamData?['lineup']));
        bench.addAll(_extractPlayerMapsFromDynamic(teamData?['substitutes']));
        bench.addAll(_extractPlayerMapsFromDynamic(teamData?['subs']));
        bench.addAll(_extractPlayerMapsFromDynamic(teamData?['bench']));
        bench.addAll(_extractPlayerMapsFromDynamic(teamData?['reserve']));
        injuries.addAll(_extractPlayerMapsFromDynamic(teamData?['injuries']));
        injuries.addAll(_extractPlayerMapsFromDynamic(teamData?['injury']));
        injuries.addAll(_extractPlayerMapsFromDynamic(teamData?['absent']));
        injuries.addAll(_extractPlayerMapsFromDynamic(teamData?['missing']));
      }
    }

    for (final player in everyone) {
      if (_isInjuryPlayer(player)) {
        injuries.add(player);
      } else if (_isStarterPlayer(player)) {
        starters.add(player);
      } else {
        bench.add(player);
      }
    }

    if (starters.isEmpty && everyone.isNotEmpty) {
      starters.addAll(everyone.take(11));
      bench.addAll(everyone.skip(11));
    }

    final dedupedStarters = _dedupePlayers(starters).take(11).toList();
    final dedupedBench = _dedupePlayers(
      bench,
    ).where((player) => !_containsPlayer(dedupedStarters, player)).toList();
    final dedupedInjuries = _dedupePlayers(injuries)
        .where(
          (player) =>
              !_containsPlayer(dedupedStarters, player) &&
              !_containsPlayer(dedupedBench, player),
        )
        .toList();

    String? formationStr;
    if (lineups.containsKey(isHome ? 'homeFormation' : 'awayFormation')) {
      formationStr = lineups[isHome ? 'homeFormation' : 'awayFormation']
          ?.toString();
    }

    return {
      'players': dedupedStarters,
      'bench': dedupedBench,
      'injuries': dedupedInjuries,
      'rows': _buildFormationRows(dedupedStarters, formationStr ?? ''),
      'formation': formationStr ?? '',
    };
  }

  Map<String, dynamic> _parseStructuredTeamLineup(
    Map<String, dynamic> lineups,
    bool isHome,
  ) {
    final lu = lineups['Lu'];
    if (lu is! List<dynamic> || lu.length < 2) {
      return const {};
    }

    final index = isHome ? 0 : 1;
    final team = lu[index];
    if (team is! Map<String, dynamic>) {
      return const {};
    }

    final allPlayers = _extractPlayerMapsFromDynamic(team['Ps']);
    final starters = allPlayers
        .where((player) => _lineupPlayerPos(player) != 5)
        .toList();
    final bench = allPlayers
        .where((player) => _lineupPlayerPos(player) == 5)
        .toList();
    final injuries = _extractPlayerMapsFromDynamic(team['IS']);
    final formation = _readNestedDisplayValue(team, const [
      'formation',
      'Formation',
      'Fm',
      'fm',
    ], _inferFormationFromPlayers(starters));

    final subsHistory = _buildLineupSubHistory(lineups, isHome: isHome);
    final starterCopies = starters.take(11).map(_copyPlayerMap).toList();
    final benchCopies = bench.map(_copyPlayerMap).toList();
    final injuryCopies = injuries.map(_copyPlayerMap).toList();

    for (final player in starterCopies) {
      final subOutMin = _getStarterSubOutTime(player, subsHistory);
      if (subOutMin != null) {
        player['subOutMin'] = subOutMin;
      }
    }

    for (final player in benchCopies) {
      final subInData = _getBenchSubInData(player, subsHistory);
      if (subInData != null) {
        player.addAll(subInData);
      }
    }

    return {
      'players': starterCopies,
      'bench': benchCopies,
      'injuries': injuryCopies,
      'rows': _buildStructuredFormationRows(starterCopies),
      'formation': formation,
    };
  }

  Widget _buildLineupTeamHeader({
    required String teamName,
    required String teamImage,
    required String formation,
    required Color accentColor,
    required bool alignEnd,
  }) {
    final teamImageUrl = _teamImageUrl(teamImage);

    return Row(
      mainAxisAlignment: alignEnd
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (alignEnd)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  teamName,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (formation.trim().isNotEmpty)
                  Text(
                    formation,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accentColor.withOpacity(0.30)),
          ),
          clipBehavior: Clip.antiAlias,
          child: teamImageUrl == null
              ? Center(
                  child: Text(
                    _initials(teamName),
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : Image.network(
                  teamImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      _initials(teamName),
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
        ),
        if (!alignEnd) const SizedBox(width: 10),
        if (!alignEnd)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teamName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (formation.trim().isNotEmpty)
                  Text(
                    formation,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        if (alignEnd) const SizedBox(width: 10),
      ],
    );
  }

  List<Widget> _buildTeamFormationNodes(
    Map<String, dynamic> teamData, {
    required bool isHome,
    required Size fieldSize,
    required bool isCompact,
  }) {
    final players =
        (teamData['players'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        [];

    if (players.isEmpty) {
      return [
        Positioned(
          left: isCompact
              ? fieldSize.width * 0.25
              : (isHome ? fieldSize.width * 0.14 : fieldSize.width * 0.64),
          top: isCompact
              ? (isHome ? fieldSize.height * 0.18 : fieldSize.height * 0.72)
              : fieldSize.height * 0.44,
          width: isCompact ? fieldSize.width * 0.50 : fieldSize.width * 0.22,
          child: Text(
            'No lineup data',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ];
    }

    final rows =
        (teamData['rows'] as List<dynamic>?)
            ?.whereType<List<dynamic>>()
            .map((row) => row.whereType<Map<String, dynamic>>().toList())
            .where((row) => row.isNotEmpty)
            .toList() ??
        _buildFormationRows(players, teamData['formation']?.toString() ?? '');
    final totalRows = math.max(rows.length, 1);
    final widgets = <Widget>[];

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final rowPlayers = rows[rowIndex];
      final depthT = totalRows == 1 ? 0.5 : rowIndex / (totalRows - 1);

      for (
        var playerIndex = 0;
        playerIndex < rowPlayers.length;
        playerIndex++
      ) {
        final player = rowPlayers[playerIndex];
        final spreadFactor = rowPlayers.length == 1
            ? 0.50
            : 0.12 + ((0.76 / (rowPlayers.length - 1)) * playerIndex);
        final cardWidth = isCompact ? 80.0 : 92.0;
        final top = isCompact
            ? _compactFormationTop(
                rowIndex: rowIndex,
                totalRows: totalRows,
                spreadFactor: spreadFactor,
                isHome: isHome,
                fieldHeight: fieldSize.height,
              )
            : (fieldSize.height * spreadFactor) - 48;
        final left = isCompact
            ? _compactFormationLeft(
                spreadFactor: spreadFactor,
                fieldWidth: fieldSize.width,
                cardWidth: cardWidth,
              )
            : (fieldSize.width *
                      (isHome
                          ? (0.08 + (0.36 * depthT))
                          : (0.92 - (0.36 * depthT))) -
                  (cardWidth / 2));

        widgets.add(
          Positioned(
            left: left,
            top: top,
            width: cardWidth,
            child: _buildFormationPlayerCard(player, isHome: isHome),
          ),
        );
      }
    }

    return widgets;
  }

  double _compactFormationTop({
    required int rowIndex,
    required int totalRows,
    required double spreadFactor,
    required bool isHome,
    required double fieldHeight,
  }) {
    final depthT = totalRows == 1 ? 0.5 : rowIndex / (totalRows - 1);
    final depth = isHome ? (0.12 + (0.30 * depthT)) : (0.88 - (0.30 * depthT));
    final rowOffset = (spreadFactor - 0.5) * 20;
    return (fieldHeight * depth) - 42 + rowOffset;
  }

  double _compactFormationLeft({
    required double spreadFactor,
    required double fieldWidth,
    required double cardWidth,
  }) {
    return (fieldWidth * spreadFactor) - (cardWidth / 2);
  }

  List<List<Map<String, dynamic>>> _buildFormationRows(
    List<Map<String, dynamic>> players,
    String formation,
  ) {
    if (players.isEmpty) {
      return const [];
    }

    final counts = formation
        .split(RegExp(r'[^0-9]+'))
        .where((part) => part.trim().isNotEmpty)
        .map((part) => int.tryParse(part) ?? 0)
        .where((value) => value > 0)
        .toList();

    final rows = <List<Map<String, dynamic>>>[
      [players.first],
    ];
    final outfield = players.skip(1).toList();

    if (outfield.isEmpty) {
      return rows;
    }

    if (counts.isEmpty) {
      final chunkSize = (outfield.length / 3).ceil();
      for (var i = 0; i < outfield.length; i += chunkSize) {
        rows.add(outfield.skip(i).take(chunkSize).toList());
      }
      return rows;
    }

    final normalizedCounts = List<int>.from(counts);
    final assigned = normalizedCounts.fold<int>(0, (sum, item) => sum + item);
    if (assigned < outfield.length) {
      normalizedCounts[normalizedCounts.length - 1] +=
          outfield.length - assigned;
    }

    var cursor = 0;
    for (final count in normalizedCounts) {
      if (cursor >= outfield.length) {
        break;
      }
      rows.add(outfield.skip(cursor).take(count).toList());
      cursor += count;
    }

    if (cursor < outfield.length) {
      rows.add(outfield.skip(cursor).toList());
    }

    return rows.where((row) => row.isNotEmpty).toList();
  }

  Widget _buildFormationPlayerCard(
    Map<String, dynamic> player, {
    required bool isHome,
  }) {
    final name = _lineupPlayerName(player);
    final number = _lineupPlayerNumber(player);
    final rating = _lineupPlayerRating(player);
    final eventText = _lineupPlayerEvent(player);
    final shirtColor = isHome
        ? const Color(0xFFFFC31A)
        : const Color(0xFF3B2A63);
    final numberColor = isHome ? Colors.black : Colors.white;
    final ratingColor = _lineupRatingColor(rating);
    final eventColor = _lineupEventColor(eventText);
    final numberLength = number.trim().length;
    final badgeSize = numberLength >= 3 ? 22.0 : 26.0;
    final numberFontSize = numberLength >= 3 ? 6.5 : 8.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (rating.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: ratingColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: Text(
              rating,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        else
          const SizedBox(height: 14),
        const SizedBox(height: 3),
        Container(
          width: badgeSize,
          height: badgeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: shirtColor,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              color: numberColor,
              fontWeight: FontWeight.w800,
              fontSize: numberFontSize,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          constraints: const BoxConstraints(minWidth: 24, maxWidth: 48),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (eventText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: eventColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              eventText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLineupDetailsSection(Map<String, dynamic> lineups) {
    final homeTeam = _parseTeamLineup(lineups, true);
    final awayTeam = _parseTeamLineup(lineups, false);

    return Column(
      children: [
        _buildLineupSplitSection(
          title: 'SUBSTITUTIONS',
          homeLabel: 'HOME',
          awayLabel: 'AWAY',
          homePlayers:
              (homeTeam['bench'] as List<dynamic>?)
                  ?.cast<Map<String, dynamic>>() ??
              [],
          awayPlayers:
              (awayTeam['bench'] as List<dynamic>?)
                  ?.cast<Map<String, dynamic>>() ??
              [],
        ),
        const SizedBox(height: 16),
        _buildLineupSplitSection(
          title: 'INJURIES',
          homeLabel: 'HOME',
          awayLabel: 'AWAY',
          homePlayers:
              (homeTeam['injuries'] as List<dynamic>?)
                  ?.cast<Map<String, dynamic>>() ??
              [],
          awayPlayers:
              (awayTeam['injuries'] as List<dynamic>?)
                  ?.cast<Map<String, dynamic>>() ??
              [],
          emptyLabel: 'No injury data available',
        ),
      ],
    );
  }

  Widget _buildLineupSplitSection({
    required String title,
    required String homeLabel,
    required String awayLabel,
    required List<Map<String, dynamic>> homePlayers,
    required List<Map<String, dynamic>> awayPlayers,
    String emptyLabel = 'No player details available',
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 760;
            final homeColumn = _buildLineupDetailColumn(
              label: homeLabel,
              players: homePlayers,
              isHome: true,
              emptyLabel: emptyLabel,
            );
            final awayColumn = _buildLineupDetailColumn(
              label: awayLabel,
              players: awayPlayers,
              isHome: false,
              emptyLabel: emptyLabel,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isCompact) ...[
                  homeColumn,
                  const SizedBox(height: 16),
                  awayColumn,
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: homeColumn),
                      Container(
                        width: 1,
                        height: math
                            .max(
                              240,
                              math.max(homePlayers.length, awayPlayers.length) *
                                  56,
                            )
                            .toDouble(),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.white.withOpacity(0.08),
                      ),
                      Expanded(child: awayColumn),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLineupDetailColumn({
    required String label,
    required List<Map<String, dynamic>> players,
    required bool isHome,
    required String emptyLabel,
  }) {
    return Column(
      crossAxisAlignment: isHome
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 10),
        if (players.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              emptyLabel,
              textAlign: isHome ? TextAlign.left : TextAlign.right,
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 12,
              ),
            ),
          )
        else
          Column(
            children: players
                .map((player) => _buildLineupDetailRow(player, isHome: isHome))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildLineupDetailRow(
    Map<String, dynamic> player, {
    required bool isHome,
  }) {
    final number = _lineupPlayerNumber(player);
    final name = _lineupPlayerName(player);
    final position = _lineupPlayerPosition(player);
    final details = _lineupPlayerDetailText(player);
    final numberBubble = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final textBlock = Expanded(
      child: Column(
        crossAxisAlignment: isHome
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            name,
            textAlign: isHome ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (position.isNotEmpty)
            Text(
              position,
              textAlign: isHome ? TextAlign.left : TextAlign.right,
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (details.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                details,
                textAlign: isHome ? TextAlign.left : TextAlign.right,
                style: TextStyle(
                  color: Colors.greenAccent.shade400,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: isHome
            ? [numberBubble, const SizedBox(width: 10), textBlock]
            : [textBlock, const SizedBox(width: 10), numberBubble],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statisticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.yellow.shade600),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading statistics',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Match ID: ${widget.match.eid}',
                    style: TextStyle(
                      color: Colors.yellow.shade600,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final statistics = snapshot.data ?? {};

        print(
          'DEBUG Statistics Tab: Response keys = ${statistics.keys.toList()}, Empty = ${statistics.isEmpty}, EID = ${widget.match.eid}',
        );

        if (statistics.isEmpty) {
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
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade400,
                          size: 20,
                        ),
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
                      'Match statistics are not available for this match yet. This may be because:',
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
                            'Match ID: ${widget.match.eid}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            'Category: ${widget.category}',
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
              ),
            ],
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

  Widget _buildStatisticsSection(Map<String, dynamic> statistics) {
    List<Map<String, dynamic>> stats = [];

    if (statistics.containsKey('stats') && statistics['stats'] is List) {
      stats = (statistics['stats'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
    } else if (statistics.containsKey('statistics') &&
        statistics['statistics'] is List) {
      stats = (statistics['statistics'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
    } else if (statistics.containsKey('teams') && statistics['teams'] is Map) {
      final teams = statistics['teams'] as Map<String, dynamic>;
      for (final teamData in teams.values.whereType<Map<String, dynamic>>()) {
        if (teamData.containsKey('statistics') &&
            teamData['statistics'] is List) {
          stats.addAll(
            (teamData['statistics'] as List<dynamic>)
                .whereType<Map<String, dynamic>>(),
          );
        }
      }
    }

    if (stats.isEmpty) {
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
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
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
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: stats.take(10).map((stat) {
                final statName =
                    stat['name'] ?? stat['N'] ?? stat['nm'] ?? 'Stat';
                final homeValue =
                    stat['home'] ?? stat['T1'] ?? stat['v1'] ?? '-';
                final awayValue =
                    stat['away'] ?? stat['T2'] ?? stat['v2'] ?? '-';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            homeValue.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.yellow.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            statName.toString(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            awayValue.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blue.shade400,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStatsTab() {
    final hasAnyTeamId =
        widget.match.homeTeamId.trim().isNotEmpty ||
        widget.match.awayTeamId.trim().isNotEmpty;

    if (!hasAnyTeamId) {
      return _buildInlineInfoCard(
        title: 'Player Stats',
        message:
            'This match does not include team IDs, so player stats cannot be loaded.',
        accentColor: Colors.orange.shade400,
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait([_homePlayerStatsFuture, _awayPlayerStatsFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.yellow.shade600),
          );
        }

        final payloads = snapshot.data ?? const <Map<String, dynamic>>[];
        final homePayload = payloads.isNotEmpty
            ? payloads[0]
            : const <String, dynamic>{};
        final awayPayload = payloads.length > 1
            ? payloads[1]
            : const <String, dynamic>{};
        final homePlayers = _extractPlayerStatRows(homePayload);
        final awayPlayers = _extractPlayerStatRows(awayPayload);

        if (homePlayers.isEmpty && awayPlayers.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInlineInfoCard(
                title: 'Player Stats',
                message: 'No player stats are available for these teams yet.',
                accentColor: Colors.orange.shade400,
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPlayerStatsTeamCard(
              teamName: widget.match.homeTeam,
              teamImage: widget.match.homeTeamImage,
              accentColor: Colors.yellow.shade600,
              players: homePlayers,
              fallbackMessage: 'No player stats found for the home team.',
            ),
            const SizedBox(height: 16),
            _buildPlayerStatsTeamCard(
              teamName: widget.match.awayTeam,
              teamImage: widget.match.awayTeamImage,
              accentColor: Colors.blue.shade300,
              players: awayPlayers,
              fallbackMessage: 'No player stats found for the away team.',
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayerStatsTeamCard({
    required String teamName,
    required String teamImage,
    required Color accentColor,
    required List<Map<String, String>> players,
    required String fallbackMessage,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildMiniTeamBadge(teamName, teamImage, accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    teamName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          if (players.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                fallbackMessage,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: players.take(10).map((player) {
                  final label = player['label'] ?? '';
                  final value = player['value'] ?? '';
                  final rank = player['rank'] ?? '';
                  final secondary = player['secondary'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentColor.withOpacity(0.18)),
                    ),
                    child: Row(
                      children: [
                        if (rank.isNotEmpty)
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              rank,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        if (rank.isNotEmpty) const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (secondary.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  secondary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          value.isEmpty ? '-' : value,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  List<Map<String, String>> _extractPlayerStatRows(
    Map<String, dynamic> payload,
  ) {
    final candidates = <Map<String, dynamic>>[];
    _collectPlayerStatNodes(payload, candidates);

    final seen = <String>{};
    final rows = <Map<String, String>>[];

    for (final node in candidates) {
      final name = _readNestedDisplayValue(node, const [
        'Nm',
        'nm',
        'name',
        'PlayerName',
        'playerName',
        'player.name',
        'Pnm',
      ], '');
      final value = _readNestedDisplayValue(node, const [
        'Stat',
        'stat',
        'Value',
        'value',
        'Val',
        'val',
        'Total',
        'total',
        'Cnt',
        'cnt',
        'S',
        's',
      ], '');

      if (name.isEmpty || value.isEmpty) {
        continue;
      }

      final rank = _readNestedDisplayValue(node, const [
        'Rank',
        'rank',
        'Rnk',
        'rnk',
        'Pos',
        'pos',
      ], '');
      final secondary = _readNestedDisplayValue(node, const [
        'Position',
        'position',
        'Team',
        'team',
        'Role',
        'role',
        'player.position',
      ], '');

      final identity =
          '${name.toLowerCase()}|${value.toLowerCase()}|${rank.toLowerCase()}';
      if (!seen.add(identity)) {
        continue;
      }

      rows.add({
        'label': name,
        'value': value,
        'rank': rank,
        'secondary': secondary,
      });
    }

    rows.sort((a, b) {
      final aRank = int.tryParse(a['rank'] ?? '') ?? 9999;
      final bRank = int.tryParse(b['rank'] ?? '') ?? 9999;
      if (aRank != bRank) {
        return aRank.compareTo(bRank);
      }

      final aValue = num.tryParse(a['value'] ?? '') ?? -1;
      final bValue = num.tryParse(b['value'] ?? '') ?? -1;
      return bValue.compareTo(aValue);
    });

    return rows;
  }

  void _collectPlayerStatNodes(
    dynamic current,
    List<Map<String, dynamic>> candidates,
  ) {
    if (current is Map<String, dynamic>) {
      if (_looksLikePlayerStatNode(current)) {
        candidates.add(current);
      }

      for (final value in current.values) {
        _collectPlayerStatNodes(value, candidates);
      }
      return;
    }

    if (current is List<dynamic>) {
      for (final value in current) {
        _collectPlayerStatNodes(value, candidates);
      }
    }
  }

  bool _looksLikePlayerStatNode(Map<String, dynamic> node) {
    final name = _readNestedDisplayValue(node, const [
      'Nm',
      'nm',
      'name',
      'PlayerName',
      'playerName',
      'player.name',
      'Pnm',
    ], '');
    final value = _readNestedDisplayValue(node, const [
      'Stat',
      'stat',
      'Value',
      'value',
      'Val',
      'val',
      'Total',
      'total',
      'Cnt',
      'cnt',
      'S',
      's',
    ], '');

    return name.isNotEmpty && value.isNotEmpty;
  }

  Widget _buildTeamStatsTab() {
    final hasAnyTeamId =
        widget.match.homeTeamId.trim().isNotEmpty ||
        widget.match.awayTeamId.trim().isNotEmpty;

    if (!hasAnyTeamId) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInlineInfoCard(
            title: 'Team Stats',
            message:
                'This match does not include team IDs, so team stats cannot be loaded.',
            accentColor: Colors.orange.shade400,
          ),
        ],
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait([_homeTeamStatsFuture, _awayTeamStatsFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.yellow.shade600),
          );
        }

        final payloads = snapshot.data ?? const <Map<String, dynamic>>[];
        final homePayload = payloads.isNotEmpty
            ? payloads[0]
            : const <String, dynamic>{};
        final awayPayload = payloads.length > 1
            ? payloads[1]
            : const <String, dynamic>{};
        final homeStats = _extractTeamStatRows(homePayload);
        final awayStats = _extractTeamStatRows(awayPayload);

        if (homeStats.isEmpty && awayStats.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInlineInfoCard(
                title: 'Team Stats',
                message: 'No team stats are available for these teams yet.',
                accentColor: Colors.orange.shade400,
              ),
            ],
          );
        }

        final mergedLabels = <String>{
          ...homeStats.keys,
          ...awayStats.keys,
        }.toList()..sort();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTeamStatsHeader(
                            teamName: widget.match.homeTeam,
                            teamImage: widget.match.homeTeamImage,
                            accentColor: Colors.yellow.shade600,
                            alignEnd: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTeamStatsHeader(
                            teamName: widget.match.awayTeam,
                            teamImage: widget.match.awayTeamImage,
                            accentColor: Colors.blue.shade300,
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.white.withOpacity(0.08), height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: mergedLabels.map((label) {
                        final homeValue = homeStats[label] ?? '-';
                        final awayValue = awayStats[label] ?? '-';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  homeValue,
                                  style: TextStyle(
                                    color: Colors.yellow.shade600,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.76),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  awayValue,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.blue.shade300,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeamStatsHeader({
    required String teamName,
    required String teamImage,
    required Color accentColor,
    required bool alignEnd,
  }) {
    return Row(
      mainAxisAlignment: alignEnd
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (alignEnd)
          Expanded(
            child: Text(
              teamName,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        if (alignEnd) const SizedBox(width: 10),
        _buildMiniTeamBadge(teamName, teamImage, accentColor),
        if (!alignEnd) const SizedBox(width: 10),
        if (!alignEnd)
          Expanded(
            child: Text(
              teamName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Map<String, String> _extractTeamStatRows(Map<String, dynamic> payload) {
    final candidates = <Map<String, dynamic>>[];
    _collectTeamStatNodes(payload, candidates);

    final rows = <String, String>{};
    for (final node in candidates) {
      final label = _readNestedDisplayValue(node, const [
        'Nm',
        'nm',
        'name',
        'StatName',
        'statName',
        'Label',
        'label',
        'Ttl',
        'ttl',
      ], '');
      final value = _readNestedDisplayValue(node, const [
        'Stat',
        'stat',
        'Value',
        'value',
        'Val',
        'val',
        'Total',
        'total',
        'Cnt',
        'cnt',
        'S',
        's',
      ], '');

      if (label.isEmpty || value.isEmpty) {
        continue;
      }

      rows.putIfAbsent(label, () => value);
    }

    return rows;
  }

  void _collectTeamStatNodes(
    dynamic current,
    List<Map<String, dynamic>> candidates,
  ) {
    if (current is Map<String, dynamic>) {
      if (_looksLikeTeamStatNode(current)) {
        candidates.add(current);
      }

      for (final value in current.values) {
        _collectTeamStatNodes(value, candidates);
      }
      return;
    }

    if (current is List<dynamic>) {
      for (final value in current) {
        _collectTeamStatNodes(value, candidates);
      }
    }
  }

  bool _looksLikeTeamStatNode(Map<String, dynamic> node) {
    final label = _readNestedDisplayValue(node, const [
      'Nm',
      'nm',
      'name',
      'StatName',
      'statName',
      'Label',
      'label',
      'Ttl',
      'ttl',
    ], '');
    final value = _readNestedDisplayValue(node, const [
      'Stat',
      'stat',
      'Value',
      'value',
      'Val',
      'val',
      'Total',
      'total',
      'Cnt',
      'cnt',
      'S',
      's',
    ], '');

    return label.isNotEmpty && value.isNotEmpty;
  }

  Widget _buildH2HTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _h2hFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.yellow.shade600),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading H2H history',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Match ID: ${widget.match.eid}',
                    style: TextStyle(
                      color: Colors.yellow.shade600,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final h2h = snapshot.data ?? {};

        print(
          'DEBUG H2H Tab: Response keys = ${h2h.keys.toList()}, Empty = ${h2h.isEmpty}, EID = ${widget.match.eid}',
        );

        if (h2h.isEmpty) {
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
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No H2H data available',
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
                      'Head-to-head history is not available for this match. This may be because:',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• These teams haven\'t played each other\n• The API doesn\'t have H2H data\n• This is a new matchup',
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
                            'Debug Info - Check Console',
                            style: TextStyle(
                              color: Colors.yellow.shade600,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Match ID: ${widget.match.eid}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            'Category: ${widget.category}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Search console for "H2H API URL"',
                            style: TextStyle(
                              color: Colors.cyan.shade300,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [_buildH2HSection(h2h), const SizedBox(height: 24)],
        );
      },
    );
  }

  Widget _buildTableTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _tableFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.yellow.shade600),
          );
        }

        if (snapshot.hasError) {
          return _buildSimpleInfoState(
            title: 'Unable to load table',
            message: '${snapshot.error}',
            accentColor: Colors.red.shade300,
          );
        }

        final table = snapshot.data ?? {};
        final rows = _extractLeagueTableRows(table);

        if (rows.isEmpty) {
          return _buildSimpleInfoState(
            title: 'No table available',
            message: 'League standings are not available for this match yet.',
            accentColor: Colors.orange.shade300,
          );
        }

        final competitionName = _readDisplayValue(table, const [
          'CompN',
          'Snm',
          'Sdn',
        ], 'League Table');
        final competitionSubtitle = _readDisplayValue(table, const [
          'CompD',
          'CompST',
          'Cnm',
        ], widget.match.country);

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
                  Text(
                    competitionName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    competitionSubtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTableBadge('Rows', '${rows.length}'),
                      _buildTableBadge('Home', widget.match.homeTeam),
                      _buildTableBadge('Away', widget.match.awayTeam),
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
                  ...rows.take(20).map(_buildLeagueRow),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildH2HSection(Map<String, dynamic> h2hData) {
    List<Map<String, dynamic>> matches = [];

    if (h2hData.containsKey('h2h') && h2hData['h2h'] is List) {
      matches = (h2hData['h2h'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
    } else if (h2hData.containsKey('headToHead') &&
        h2hData['headToHead'] is List) {
      matches = (h2hData['headToHead'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
    } else if (h2hData.containsKey('events') && h2hData['events'] is List) {
      matches = (h2hData['events'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
    } else if (h2hData.containsKey('E') && h2hData['E'] is List) {
      matches = (h2hData['E'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    if (matches.isEmpty) {
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
              'Head to Head',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No previous matches found',
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
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Head to Head History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: matches.take(5).map((match) {
                final homeTeam =
                    match['T1'] ?? match['t1'] ?? match['homeTeam'] ?? 'Home';
                final awayTeam =
                    match['T2'] ?? match['t2'] ?? match['awayTeam'] ?? 'Away';
                final homeScore =
                    match['Tr1'] ?? match['T1Sc'] ?? match['homeScore'] ?? '-';
                final awayScore =
                    match['Tr2'] ?? match['T2Sc'] ?? match['awayScore'] ?? '-';
                final status = match['Eps'] ?? match['status'] ?? 'Finished';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                homeTeam.toString(),
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${homeScore.toString()} - ${awayScore.toString()}',
                                style: TextStyle(
                                  color: Colors.yellow.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                awayTeam.toString(),
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          status.toString(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            const Text(
              'Failed to load match details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _reloadAllData,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.yellow.shade600),
              ),
              child: Text(
                'Retry',
                style: TextStyle(color: Colors.yellow.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader() {
    final showScores =
        widget.match.homeScore.isNotEmpty && widget.match.awayScore.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Text(
            widget.match.competition,
            style: TextStyle(
              color: Colors.yellow.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.match.country,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTeamBadge(
                      widget.match.homeTeam,
                      widget.match.homeTeamImage,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.match.homeTeam,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (showScores) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.match.homeScore,
                        style: TextStyle(
                          color: Colors.yellow.shade600,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      _statusLabel(widget.match.status),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusBadgeText(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTeamBadge(
                      widget.match.awayTeam,
                      widget.match.awayTeamImage,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.match.awayTeam,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (showScores) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.match.awayScore,
                        style: TextStyle(
                          color: Colors.yellow.shade600,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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

  Widget _buildTeamBadge(String teamName, String teamImage) {
    final imageUrl = _teamImageUrl(teamImage);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.08),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? _buildTeamInitials(teamName)
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildTeamInitials(teamName);
              },
            ),
    );
  }

  Widget _buildTeamInitials(String teamName) {
    return Center(
      child: Text(
        _initials(teamName),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, Map<String, dynamic> detail) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildDetailItems(detail),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItems(Map<String, dynamic> detail) {
    final items = <Widget>[];
    final matchInfo = detail['m'] as Map<String, dynamic>? ?? {};

    if (widget.match.startTime != null) {
      items.add(
        _buildDetailItem(
          'Scheduled Time',
          _formatDateTime(widget.match.startTime!),
        ),
      );
      items.add(const Divider(color: Color(0xFF262626), height: 1));
    }

    if (matchInfo.containsKey('Venue')) {
      items.add(
        _buildDetailItem('Venue', matchInfo['Venue']?.toString() ?? 'N/A'),
      );
      items.add(const Divider(color: Color(0xFF262626), height: 1));
    }

    items.add(_buildDetailItem('Status', widget.match.status));
    items.add(const Divider(color: Color(0xFF262626), height: 1));
    items.add(_buildDetailItem('Match ID', widget.match.eid));

    return Column(children: items);
  }

  Widget _buildTeamDetailsSection() {
    final hasAnyTeamId =
        widget.match.homeTeamId.trim().isNotEmpty ||
        widget.match.awayTeamId.trim().isNotEmpty;

    if (!hasAnyTeamId) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait([_homeTeamDetailFuture, _awayTeamDetailFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(color: Colors.yellow.shade600),
            ),
          );
        }

        final details = snapshot.data ?? const <Map<String, dynamic>>[];
        final homeDetail = details.isNotEmpty
            ? details[0]
            : const <String, dynamic>{};
        final awayDetail = details.length > 1
            ? details[1]
            : const <String, dynamic>{};

        if (homeDetail.isEmpty && awayDetail.isEmpty) {
          return _buildInlineInfoCard(
            title: 'Team Details',
            message: 'No team detail data is available for this match yet.',
            accentColor: Colors.orange.shade400,
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Team Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Divider(color: Colors.white.withOpacity(0.08), height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTeamDetailCard(
                      teamName: widget.match.homeTeam,
                      teamImage: widget.match.homeTeamImage,
                      fallbackTeamId: widget.match.homeTeamId,
                      detail: homeDetail,
                      accentColor: Colors.yellow.shade600,
                    ),
                    const SizedBox(height: 12),
                    _buildTeamDetailCard(
                      teamName: widget.match.awayTeam,
                      teamImage: widget.match.awayTeamImage,
                      fallbackTeamId: widget.match.awayTeamId,
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
    final rows = _buildTeamDetailRows(detail, fallbackTeamId: fallbackTeamId);

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
              _buildMiniTeamBadge(teamName, teamImage, accentColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  teamName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  List<Widget> _buildTeamDetailRows(
    Map<String, dynamic> detail, {
    required String fallbackTeamId,
  }) {
    final resolvedTeamId = _readNestedDisplayValue(detail, const [
      'ID',
      'Id',
      'id',
      'Tid',
      'team.id',
      'team.ID',
    ], fallbackTeamId.trim());
    final displayName = _readNestedDisplayValue(detail, const [
      'Name',
      'name',
      'Nm',
      'Tnm',
      'team.name',
      'team.Name',
    ], '');
    final shortName = _readNestedDisplayValue(detail, const [
      'Snm',
      'shortName',
      'ShortName',
      'team.shortName',
    ], '');
    final country = _readNestedDisplayValue(detail, const [
      'Country',
      'country',
      'Cnm',
      'CountryName',
      'team.country',
      'team.country.name',
    ], 'N/A');
    final city = _readNestedDisplayValue(detail, const [
      'City',
      'city',
      'team.city',
      'team.City',
    ], '');
    final stadium = _readNestedDisplayValue(detail, const [
      'Stadium',
      'stadium',
      'Venue',
      'venue',
      'Ven',
      'Stdm',
      'team.stadium',
      'team.venue',
      'team.stadium.name',
      'team.venue.name',
    ], 'N/A');
    final founded = _readNestedDisplayValue(detail, const [
      'Founded',
      'founded',
      'YearFounded',
      'yearFounded',
      'team.founded',
    ], 'N/A');
    final manager = _readNestedDisplayValue(detail, const [
      'Manager',
      'manager',
      'Coach',
      'coach',
      'ManagerName',
      'CoachName',
      'team.manager.name',
      'team.coach.name',
    ], 'N/A');
    final website = _readNestedDisplayValue(detail, const [
      'Website',
      'website',
      'team.website',
    ], '');

    final values = <MapEntry<String, String>>[];

    if (resolvedTeamId.isNotEmpty) {
      values.add(MapEntry('Team ID', resolvedTeamId));
    }
    if (displayName.isNotEmpty) {
      values.add(MapEntry('Name', displayName));
    }
    if (shortName.isNotEmpty) {
      values.add(MapEntry('Short Name', shortName));
    }
    if (country.isNotEmpty && country != 'N/A') {
      values.add(MapEntry('Country', country));
    }
    if (city.isNotEmpty) {
      values.add(MapEntry('City', city));
    }
    if (stadium.isNotEmpty && stadium != 'N/A') {
      values.add(MapEntry('Stadium', stadium));
    }
    if (founded.isNotEmpty && founded != 'N/A') {
      values.add(MapEntry('Founded', founded));
    }
    if (manager.isNotEmpty && manager != 'N/A') {
      values.add(MapEntry('Manager', manager));
    }
    if (website.isNotEmpty) {
      values.add(MapEntry('Website', website));
    }

    if (values.isEmpty) {
      values.add(
        MapEntry('Team ID', resolvedTeamId.isEmpty ? 'N/A' : resolvedTeamId),
      );
    }

    return values
        .map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    final statusMap = {
      'NS': 'Not Started',
      'LIVE': 'Live',
      'FT': 'Full Time',
      'AET': 'After Extra Time',
      'PEN': 'Penalties',
    };
    return statusMap[status] ?? status;
  }

  Color _getStatusColor() {
    switch (widget.match.status) {
      case 'LIVE':
        return Colors.red.shade400;
      case 'FT':
      case 'AET':
      case 'PEN':
        return Colors.green.shade400;
      default:
        return Colors.white.withOpacity(0.6);
    }
  }

  String _getStatusBadgeText() {
    switch (widget.match.status) {
      case 'NS':
        return 'UPCOMING';
      case 'LIVE':
        return 'LIVE';
      case 'FT':
        return 'ENDED';
      default:
        return widget.match.status;
    }
  }

  String? _teamImageUrl(String imagePath) {
    final trimmed = imagePath.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final sourceUrl = trimmed.startsWith('http')
        ? trimmed
        : 'https://storage.livescore.com/images/team/medium/$trimmed';
    return 'https://getimage.membertsd.workers.dev/?url=' +
        Uri.encodeComponent(sourceUrl);
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final month = months[dateTime.month - 1];
    return '${dateTime.day} $month ${dateTime.year} at $hour:$minute';
  }

  Widget _buildSimpleInfoState({
    required String title,
    required String message,
    required Color accentColor,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withOpacity(0.45)),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInlineInfoCard({
    required String title,
    required String message,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.45)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accentColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeaderRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
      child: Row(
        children: const [
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
    final teamId = _readDisplayValue(row, const ['Tid', 'teamId', 'ID'], '');
    final teamName = _readDisplayValue(row, const [
      'Tnm',
      'Nm',
      'name',
    ], 'Unknown');
    final rank = _readDisplayValue(row, const ['rnk', 'rank', 'pos'], '-');
    final played = _readDisplayValue(row, const ['pld', 'played'], '-');
    final wins = _readDisplayValue(row, const ['win', 'winn', 'wins'], '-');
    final draws = _readDisplayValue(row, const ['drw', 'drwn', 'draws'], '-');
    final losses = _readDisplayValue(row, const ['lst', 'lstn', 'losses'], '-');
    final goalDifference = _readDisplayValue(row, const [
      'gd',
      'goalDifference',
    ], '-');
    final points = _readDisplayValue(row, const ['ptsn', 'pts', 'points'], '-');
    final teamImage = _readDisplayValue(row, const ['Img', 'img'], '');

    final isHomeTeam = teamId == widget.match.homeTeamId;
    final isAwayTeam = teamId == widget.match.awayTeamId;
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
          color: isHighlighted
              ? accentColor.withOpacity(0.45)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rank,
              style: TextStyle(
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                _buildMiniTeamBadge(teamName, teamImage, accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teamName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isHighlighted)
                        Text(
                          isHomeTeam ? 'Home side' : 'Away side',
                          style: TextStyle(
                            color: accentColor.withOpacity(0.92),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildTableValueCell(played),
          _buildTableValueCell(wins),
          _buildTableValueCell(draws),
          _buildTableValueCell(losses),
          _buildTableValueCell(goalDifference),
          _buildTableValueCell(points, emphasize: true),
        ],
      ),
    );
  }

  Widget _buildMiniTeamBadge(
    String teamName,
    String imagePath,
    Color accentColor,
  ) {
    final imageUrl = _teamImageUrl(imagePath);
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          width: 28,
          height: 28,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _buildMiniFallbackBadge(teamName, accentColor),
        ),
      );
    }

    return _buildMiniFallbackBadge(teamName, accentColor);
  }

  Widget _buildMiniFallbackBadge(String teamName, Color accentColor) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(teamName),
        style: TextStyle(
          color: accentColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildTableValueCell(String value, {bool emphasize = false}) {
    return Expanded(
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: emphasize ? Colors.white : Colors.white.withOpacity(0.8),
          fontSize: 12,
          fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _extractLeagueTableRows(
    Map<String, dynamic> tableData,
  ) {
    final leagueTable = tableData['LeagueTable'];
    if (leagueTable is! Map<String, dynamic>) {
      return const [];
    }

    final groups = leagueTable['L'];
    if (groups is! List) {
      return const [];
    }

    final rows = <Map<String, dynamic>>[];
    for (final group in groups) {
      if (group is! Map<String, dynamic>) {
        continue;
      }

      final tables = group['Tables'];
      if (tables is! List) {
        continue;
      }

      for (final table in tables) {
        if (table is! Map<String, dynamic>) {
          continue;
        }

        final teams = table['team'];
        if (teams is! List) {
          continue;
        }

        rows.addAll(teams.whereType<Map<String, dynamic>>());
      }
    }

    return rows;
  }

  List<Map<String, dynamic>> _extractPlayerMapsFromDynamic(dynamic value) {
    if (value is List<dynamic>) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  Map<String, dynamic> _copyPlayerMap(Map<String, dynamic> source) {
    return Map<String, dynamic>.from(source);
  }

  int _lineupPlayerPos(Map<String, dynamic> player) {
    return int.tryParse(
          _readNestedDisplayValue(player, const [
            'Pos',
            'pos',
            'PosS',
            'position',
          ], ''),
        ) ??
        0;
  }

  String _lineupPositionLabelFromPos(int pos) {
    switch (pos) {
      case 1:
        return 'GK';
      case 2:
        return 'DEF';
      case 3:
        return 'MID';
      case 4:
        return 'FW';
      default:
        return 'BENCH';
    }
  }

  String _inferFormationFromPlayers(List<Map<String, dynamic>> players) {
    final defs = players.where((p) => _lineupPlayerPos(p) == 2).length;
    final mids = players.where((p) => _lineupPlayerPos(p) == 3).length;
    final fws = players.where((p) => _lineupPlayerPos(p) == 4).length;
    final parts = [
      defs,
      mids,
      fws,
    ].where((v) => v > 0).map((v) => '$v').toList();
    return parts.join('-');
  }

  List<List<Map<String, dynamic>>> _buildStructuredFormationRows(
    List<Map<String, dynamic>> players,
  ) {
    if (players.isEmpty) {
      return const [];
    }

    final goalkeepers = players.where((p) => _lineupPlayerPos(p) == 1).toList();
    final defenders = players.where((p) => _lineupPlayerPos(p) == 2).toList();
    final midfielders = players.where((p) => _lineupPlayerPos(p) == 3).toList();
    final forwards = players.where((p) => _lineupPlayerPos(p) == 4).toList();
    final unknown = players
        .where((p) => ![1, 2, 3, 4].contains(_lineupPlayerPos(p)))
        .toList();

    final rows = <List<Map<String, dynamic>>>[];
    if (goalkeepers.isNotEmpty) {
      rows.add([goalkeepers.first]);
    }
    if (defenders.isNotEmpty) {
      rows.add(defenders);
    }
    if (midfielders.isNotEmpty) {
      rows.add(midfielders);
    }
    if (forwards.isNotEmpty) {
      rows.add(forwards);
    }
    if (unknown.isNotEmpty) {
      rows.add(unknown);
    }

    return rows.isNotEmpty ? rows : [players];
  }

  List<Map<String, dynamic>> _buildLineupSubHistory(
    Map<String, dynamic> lineups, {
    required bool isHome,
  }) {
    final subs = lineups['Subs'];
    if (subs is! List<dynamic> ||
        subs.length < 3 ||
        subs[2] is! List<dynamic>) {
      return const [];
    }

    final teamNum = isHome ? '1' : '2';
    final entries = (subs[2] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .where((item) {
          final nm = _readNestedDisplayValue(item, const [
            'Nm',
            'nm',
            'team',
            'side',
          ], '');
          return nm == teamNum;
        })
        .toList();

    final history = <Map<String, dynamic>>[];
    for (var i = 0; i + 1 < entries.length; i += 2) {
      final first = entries[i];
      final second = entries[i + 1];
      final firstType = _readNestedDisplayValue(first, const [
        'Tp',
        'tp',
        'Type',
        'type',
        'EventType',
      ], '').toLowerCase();
      final secondType = _readNestedDisplayValue(second, const [
        'Tp',
        'tp',
        'Type',
        'type',
        'EventType',
      ], '').toLowerCase();

      Map<String, dynamic> inPlayer = first;
      Map<String, dynamic> outPlayer = second;
      if (firstType.contains('out') || firstType.contains('down')) {
        inPlayer = second;
        outPlayer = first;
      } else if (secondType.contains('in') || secondType.contains('up')) {
        inPlayer = second;
        outPlayer = first;
      }

      final minute = _readNestedDisplayValue(
        first,
        const ['Min', 'min', 'Minute', 'minute', 'Tm', 'tm'],
        _readNestedDisplayValue(second, const [
          'Min',
          'min',
          'Minute',
          'minute',
          'Tm',
          'tm',
        ], ''),
      );

      history.add({'min': minute, 'in': inPlayer, 'out': outPlayer});
    }

    return history;
  }

  String? _getStarterSubOutTime(
    Map<String, dynamic> player,
    List<Map<String, dynamic>> history,
  ) {
    final pid = _lineupPlayerId(player);
    for (final event in history) {
      final out = event['out'];
      if (out is Map<String, dynamic> && _lineupPlayerId(out) == pid) {
        final minute = event['min']?.toString().trim() ?? '';
        return minute.isEmpty ? null : minute;
      }
    }
    return null;
  }

  Map<String, dynamic>? _getBenchSubInData(
    Map<String, dynamic> player,
    List<Map<String, dynamic>> history,
  ) {
    final pid = _lineupPlayerId(player);
    for (final event in history) {
      final incoming = event['in'];
      final outgoing = event['out'];
      if (incoming is Map<String, dynamic> &&
          _lineupPlayerId(incoming) == pid) {
        final minute = event['min']?.toString().trim() ?? '';
        return {
          'subInMin': minute,
          'subOutName': outgoing is Map<String, dynamic>
              ? _lineupPlayerName(outgoing)
              : '',
        };
      }
    }
    return null;
  }

  bool _playerBelongsToTeam(Map<String, dynamic> player, bool isHome) {
    final raw = _readNestedDisplayValue(player, const [
      't',
      'team',
      'teamId',
      'teamName',
      'tid',
      'Tid',
      'tm',
      'side',
    ], '').toLowerCase();

    final targetId =
        (isHome ? widget.match.homeTeamId : widget.match.awayTeamId)
            .toLowerCase();
    final targetName = (isHome ? widget.match.homeTeam : widget.match.awayTeam)
        .toLowerCase();
    final sideLabel = isHome ? 'home' : 'away';

    return raw == targetId ||
        raw == targetName ||
        raw.contains(sideLabel) ||
        raw.contains(targetName);
  }

  bool _isStarterPlayer(Map<String, dynamic> player) {
    final raw = _readNestedDisplayValue(player, const [
      'starter',
      'isStarter',
      'st',
      'xi',
      'starting',
      'lineup',
      'first11',
      'status',
    ], '').toLowerCase();

    return raw == '1' ||
        raw == 'true' ||
        raw == 'yes' ||
        raw == 'starter' ||
        raw == 'starting' ||
        raw == 'xi';
  }

  bool _isInjuryPlayer(Map<String, dynamic> player) {
    final raw = _readNestedDisplayValue(player, const [
      'injury',
      'injuryType',
      'status',
      'availability',
      'reason',
      'desc',
    ], '').toLowerCase();

    return raw.contains('injur') ||
        raw.contains('knock') ||
        raw.contains('out') ||
        raw.contains('doubt') ||
        raw.contains('absent') ||
        raw.contains('hamstring') ||
        raw.contains('cruciate') ||
        raw.contains('achilles');
  }

  List<Map<String, dynamic>> _dedupePlayers(
    List<Map<String, dynamic>> players,
  ) {
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];

    for (final player in players) {
      final key =
          '${_lineupPlayerNumber(player)}|${_lineupPlayerName(player).toLowerCase()}';
      if (seen.add(key)) {
        result.add(player);
      }
    }

    return result;
  }

  bool _containsPlayer(
    List<Map<String, dynamic>> players,
    Map<String, dynamic> target,
  ) {
    final targetKey =
        '${_lineupPlayerNumber(target)}|${_lineupPlayerName(target).toLowerCase()}';
    for (final player in players) {
      final key =
          '${_lineupPlayerNumber(player)}|${_lineupPlayerName(player).toLowerCase()}';
      if (key == targetKey) {
        return true;
      }
    }
    return false;
  }

  String _lineupPlayerId(Map<String, dynamic> player) {
    return _readNestedDisplayValue(player, const [
      'Pid',
      'pid',
      'ID',
      'Id',
      'id',
    ], '');
  }

  String _lineupPlayerName(Map<String, dynamic> player) {
    final first = _readNestedDisplayValue(player, const [
      'Fn',
      'firstName',
    ], '');
    final last = _readNestedDisplayValue(player, const ['Ln', 'lastName'], '');
    final full = '$first $last'.trim();
    if (full.isNotEmpty) {
      return full;
    }
    return _readNestedDisplayValue(player, const [
      'nm',
      'name',
      'pn',
      'playerName',
      'Nm',
      'Pnm',
    ], 'Unknown');
  }

  String _lineupPlayerNumber(Map<String, dynamic> player) {
    return _readNestedDisplayValue(player, const [
      'Snu',
      'shirtNumber',
      'num',
      'shirtnumber',
      'No',
      'number',
    ], '?');
  }

  String _lineupPlayerPosition(Map<String, dynamic> player) {
    final explicit = _readNestedDisplayValue(player, const [
      'pos',
      'position',
      'role',
      'type',
      'Position',
    ], '').toUpperCase();
    if (explicit.isNotEmpty && explicit != '5') {
      return explicit;
    }
    return _lineupPositionLabelFromPos(_lineupPlayerPos(player));
  }

  String _lineupPlayerRating(Map<String, dynamic> player) {
    return _readNestedDisplayValue(player, const [
      'Rate',
      'rating',
      'rate',
      'rt',
      'Rating',
    ], '');
  }

  String _lineupPlayerEvent(Map<String, dynamic> player) {
    final subOutMin = _readNestedDisplayValue(player, const ['subOutMin'], '');
    if (subOutMin.isNotEmpty) {
      return "$subOutMin'";
    }

    final minute = _readNestedDisplayValue(player, const [
      'minute',
      'min',
      'Time',
      'tm',
    ], '');
    final shortText = _readNestedDisplayValue(player, const [
      'event',
      'status',
      'desc',
      'reason',
    ], '');

    if (minute.isNotEmpty) {
      return shortText.isNotEmpty ? "$minute' $shortText" : "$minute'";
    }

    if (shortText.length > 12) {
      return shortText.substring(0, 12);
    }

    return shortText;
  }

  String _lineupPlayerDetailText(Map<String, dynamic> player) {
    final subInMin = _readNestedDisplayValue(player, const ['subInMin'], '');
    final subOutName = _readNestedDisplayValue(player, const [
      'subOutName',
    ], '');
    if (subInMin.isNotEmpty) {
      return subOutName.isNotEmpty
          ? "$subInMin'  for $subOutName"
          : "$subInMin'";
    }

    final minute = _readNestedDisplayValue(player, const [
      'minute',
      'min',
      'Time',
      'tm',
    ], '');
    final relation = _readNestedDisplayValue(player, const [
      'for',
      'replacement',
      'replaced',
      'substituteFor',
      'playerOut',
      'out',
    ], '');
    final status = _readNestedDisplayValue(player, const [
      'Rs',
      'injury',
      'injuryType',
      'reason',
      'desc',
      'status',
    ], '');

    final segments = <String>[];
    if (minute.isNotEmpty) {
      segments.add("$minute'");
    }
    if (relation.isNotEmpty) {
      segments.add('for $relation');
    } else if (status.isNotEmpty) {
      segments.add(status);
    }

    return segments.join('  ');
  }

  Color _lineupRatingColor(String rating) {
    final parsed = double.tryParse(rating);
    if (parsed == null) {
      return const Color(0xFF1FAA59);
    }
    if (parsed >= 7.0) {
      return const Color(0xFF12B95C);
    }
    if (parsed >= 6.0) {
      return const Color(0xFFFF9F1A);
    }
    return const Color(0xFFE64C3C);
  }

  Color _lineupEventColor(String eventText) {
    final lower = eventText.toLowerCase();
    if (lower.contains('injur') || lower.contains('out')) {
      return const Color(0xFFE44141);
    }
    return const Color(0xFFE44141);
  }

  String _readDisplayValue(
    Map<String, dynamic> source,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) {
        continue;
      }

      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }

    return fallback;
  }

  String _readNestedDisplayValue(
    Map<String, dynamic> source,
    List<String> paths,
    String fallback,
  ) {
    for (final path in paths) {
      dynamic current = source;

      for (final part in path.split('.')) {
        if (current is Map<String, dynamic>) {
          current = current[part];
          continue;
        }

        if (current is List<dynamic>) {
          final index = int.tryParse(part);
          if (index == null || index < 0 || index >= current.length) {
            current = null;
            break;
          }
          current = current[index];
          continue;
        }

        current = null;
        break;
      }

      if (current == null) {
        continue;
      }

      final text = current.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }

    return fallback;
  }
}

class _TableHeaderText extends StatelessWidget {
  final String text;
  final TextAlign align;

  const _TableHeaderText(this.text, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        color: Colors.white.withOpacity(0.45),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}

class FootballFieldPainter extends CustomPainter {
  final bool isCompact;

  FootballFieldPainter({this.isCompact = false});

  @override
  void paint(Canvas canvas, Size size) {
    final fieldPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3C9646), Color(0xFF348C42)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.72)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fieldPaint);

    final stripePaint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..style = PaintingStyle.fill;
    final stripeCount = 10;
    final stripeWidth = isCompact
        ? size.height / stripeCount
        : size.width / stripeCount;
    for (var i = 0; i < stripeCount; i++) {
      if (i.isEven) {
        canvas.drawRect(
          isCompact
              ? Rect.fromLTWH(0, i * stripeWidth, size.width, stripeWidth)
              : Rect.fromLTWH(i * stripeWidth, 0, stripeWidth, size.height),
          stripePaint,
        );
      }
    }

    canvas.drawRect(
      Rect.fromLTWH(14, 14, size.width - 28, size.height - 28),
      linePaint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (isCompact ? size.width : size.height) * 0.10,
      linePaint,
    );

    canvas.drawLine(
      isCompact ? Offset(14, size.height / 2) : Offset(size.width / 2, 14),
      isCompact
          ? Offset(size.width - 14, size.height / 2)
          : Offset(size.width / 2, size.height - 14),
      linePaint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      3,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.fill,
    );

    if (isCompact) {
      final boxWidth = size.width * 0.30;
      final goalBoxWidth = size.width * 0.16;
      final penaltyHeight = size.height * 0.12;
      final goalBoxHeight = size.height * 0.06;
      final left = (size.width - boxWidth) / 2;
      final goalLeft = (size.width - goalBoxWidth) / 2;

      canvas.drawRect(
        Rect.fromLTWH(left, 14, boxWidth, penaltyHeight),
        linePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          left,
          size.height - 14 - penaltyHeight,
          boxWidth,
          penaltyHeight,
        ),
        linePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(goalLeft, 14, goalBoxWidth, goalBoxHeight),
        linePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          goalLeft,
          size.height - 14 - goalBoxHeight,
          goalBoxWidth,
          goalBoxHeight,
        ),
        linePaint,
      );

      canvas.drawCircle(
        Offset(size.width / 2, 14 + (penaltyHeight * 0.62)),
        2.4,
        Paint()
          ..color = Colors.white.withOpacity(0.72)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(size.width / 2, size.height - 14 - (penaltyHeight * 0.62)),
        2.4,
        Paint()
          ..color = Colors.white.withOpacity(0.72)
          ..style = PaintingStyle.fill,
      );
    } else {
      final boxHeight = size.height * 0.30;
      final goalBoxHeight = size.height * 0.16;
      final penaltyWidth = size.width * 0.12;
      final goalBoxWidth = size.width * 0.06;
      final top = (size.height - boxHeight) / 2;
      final goalTop = (size.height - goalBoxHeight) / 2;

      canvas.drawRect(
        Rect.fromLTWH(14, top, penaltyWidth, boxHeight),
        linePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          size.width - 14 - penaltyWidth,
          top,
          penaltyWidth,
          boxHeight,
        ),
        linePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(14, goalTop, goalBoxWidth, goalBoxHeight),
        linePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          size.width - 14 - goalBoxWidth,
          goalTop,
          goalBoxWidth,
          goalBoxHeight,
        ),
        linePaint,
      );

      canvas.drawCircle(
        Offset(14 + (penaltyWidth * 0.62), size.height / 2),
        2.4,
        Paint()
          ..color = Colors.white.withOpacity(0.72)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(size.width - 14 - (penaltyWidth * 0.62), size.height / 2),
        2.4,
        Paint()
          ..color = Colors.white.withOpacity(0.72)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(FootballFieldPainter oldDelegate) =>
      oldDelegate.isCompact != isCompact;
}
