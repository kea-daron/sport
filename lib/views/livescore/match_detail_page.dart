import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/match_item.dart';
import '../../services/live_score_service.dart';
import '../../theme/app_palette.dart';
import '../../widgets/app_skeleton.dart';

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

  Widget _buildTabBar() {
    final tabs = [
      'OVERVIEW',
      'SUMMARY',
      'LINEUPS',
      'STATISTICS',
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
        return _buildTableTab();
      case 5:
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
          return const MatchDetailLoadingSkeleton();
        }

        final scoreboard = snapshot.data ?? const <String, dynamic>{};
        final summaryRows = _extractSummaryRows(
          scoreboard: scoreboard,
          detail: detail,
        );
        final timelineItems = _extractSummaryTimeline(
          scoreboard: scoreboard,
          detail: detail,
        );
        final highlightText = _extractSummaryHighlight(
          scoreboard: scoreboard,
          detail: detail,
        );

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
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.025),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.07),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Timeline',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.05),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.open_in_full_rounded,
                                    color: Colors.white.withOpacity(0.82),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...timelineItems.map((item) {
                            if (item['kind'] == 'divider') {
                              return _buildTimelineDividerRow(item['label'] ?? '');
                            }

                            final side = item['side'] ?? 'neutral';
                            final isHome = side == 'home';
                            final isAway = side == 'away';
                            final isNeutral = !isHome && !isAway;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: isHome
                                        ? _buildTimelineSide(
                                            item,
                                            alignEnd: true,
                                            accentColor: Colors.yellow.shade600,
                                          )
                                        : isNeutral
                                        ? _buildTimelineSide(
                                            item,
                                            alignEnd: true,
                                            accentColor: Colors.white70,
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: _buildTimelineMinuteChip(item),
                                  ),
                                  Expanded(
                                    child: isAway
                                        ? _buildTimelineSide(
                                            item,
                                            alignEnd: false,
                                            accentColor: Colors.blue.shade300,
                                          )
                                        : isNeutral
                                        ? const SizedBox(
                                            width: double.infinity,
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
    final title = item['title'] ?? '';
    final subtitle = item['subtitle'] ?? '';
    final nameParts = _splitTimelineDisplayName(title);

    return Padding(
      padding: EdgeInsets.only(left: alignEnd ? 0 : 8, right: alignEnd ? 8 : 0),
      child: Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: alignEnd
                ? [
                    Flexible(
                      child: _buildTimelineTextBlock(
                        nameParts: nameParts,
                        subtitle: subtitle,
                        alignEnd: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTimelineEventMarker(item, accentColor),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTimelineConnector()),
                  ]
                : [
                    Expanded(child: _buildTimelineConnector()),
                    const SizedBox(width: 8),
                    _buildTimelineEventMarker(item, accentColor),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _buildTimelineTextBlock(
                        nameParts: nameParts,
                        subtitle: subtitle,
                        alignEnd: false,
                      ),
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTextBlock({
    required (String, String) nameParts,
    required String subtitle,
    required bool alignEnd,
  }) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          nameParts.$1,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        if (nameParts.$2.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            '(${nameParts.$2})',
            textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.68),
              fontSize: 9.5,
              height: 1.28,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimelineEventMarker(
    Map<String, String> item,
    Color accentColor,
  ) {
    final badge = item['badge'] ?? '';
    final iconType = item['icon'] ?? 'default';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (badge.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: Colors.white,
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
                height: 1,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
        _buildTimelineIcon(iconType, accentColor),
      ],
    );
  }

  Widget _buildTimelineDividerRow(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      child: Row(
        children: [
          Expanded(child: _buildTimelineConnector()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.74),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(child: _buildTimelineConnector()),
        ],
      ),
    );
  }

  Widget _buildTimelineConnector() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.12),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineMinuteChip(Map<String, String> item) {
    final iconType = item['icon'] ?? 'default';
    final isGoalStyle = iconType == 'goal' || iconType == 'penalty_goal';

    return Container(
      constraints: const BoxConstraints(minWidth: 64),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isGoalStyle ? Colors.white : const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isGoalStyle
              ? Colors.white.withOpacity(0.9)
              : Colors.white.withOpacity(0.04),
        ),
      ),
      child: Text(
        item['minute'] ?? '',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isGoalStyle ? Colors.black : Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  (String, String) _splitTimelineDisplayName(String value) {
    final trimmed = value.trim();
    final start = trimmed.indexOf('(');
    final end = trimmed.lastIndexOf(')');

    if (start <= 0 || end <= start) {
      return (trimmed, '');
    }

    final primary = trimmed.substring(0, start).trim();
    final secondary = trimmed.substring(start + 1, end).trim();
    return (primary, secondary);
  }

  Widget _buildTimelineIcon(String iconType, Color accentColor) {
    final color = _timelineIconColorSafe(iconType, accentColor);

    if (iconType == 'goal' || iconType == 'penalty_goal') {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.22),
              Colors.white.withOpacity(0.08),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.22),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFF111111), width: 1.1),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.sports_soccer, size: 11, color: const Color(0xFF111111)),
        ),
      );
    }

    if (iconType == 'yellow' || iconType == 'red') {
      return Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 4,
              left: 6,
              child: Transform.rotate(
                angle: -0.12,
                child: Container(
                  width: 11,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 3,
              left: 9,
              child: Transform.rotate(
                angle: 0.08,
                child: Container(
                  width: 11,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.26),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (iconType == 'missed_penalty') {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.close_rounded,
          size: 14,
          color: color,
        ),
      );
    }

    if (iconType == 'own_goal') {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        alignment: Alignment.center,
        child: Text(
          'OG',
          style: TextStyle(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    final symbol = _timelineIconSymbolSafe(iconType);

    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      child: symbol.isEmpty
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            )
          : Text(
              symbol,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }

  Color _timelineIconColorSafe(String iconType, Color accentColor) {
    switch (iconType) {
      case 'goal':
        return const Color(0xFF22C55E);
      case 'penalty_goal':
        return const Color(0xFF15803D);
      case 'missed_penalty':
        return const Color(0xFFEF4444);
      case 'own_goal':
        return const Color(0xFFDC2626);
      case 'yellow':
        return const Color(0xFFFACC15);
      case 'red':
        return const Color(0xFFEF4444);
      default:
        return accentColor;
    }
  }

  String _timelineIconSymbolSafe(String iconType) {
    switch (iconType) {
      case 'goal':
        return 'G';
      case 'penalty_goal':
        return 'PG';
      case 'missed_penalty':
        return 'MP';
      case 'own_goal':
        return 'OG';
      case 'yellow':
        return 'YC';
      case 'red':
        return 'RC';
      default:
        return '';
    }
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

  List<Map<String, String>> _extractSummaryRows({
    required Map<String, dynamic> scoreboard,
    required Map<String, dynamic> detail,
  }) {
    final rows = <Map<String, String>>[
      ..._extractScoreboardRows(scoreboard),
    ];
    final seenLabels = rows
        .map((row) => (row['label'] ?? '').toLowerCase())
        .where((label) => label.isNotEmpty)
        .toSet();

    for (final row in _extractDetailSummaryRows(detail)) {
      final label = (row['label'] ?? '').toLowerCase();
      if (label.isEmpty || !seenLabels.add(label)) {
        continue;
      }
      rows.add(row);
      if (rows.length >= 12) {
        break;
      }
    }

    return rows.take(12).toList();
  }

  List<Map<String, String>> _extractDetailSummaryRows(
    Map<String, dynamic> detail,
  ) {
    final rows = <Map<String, String>>[];
    final matchInfo = detail['m'] is Map<String, dynamic>
        ? detail['m'] as Map<String, dynamic>
        : const <String, dynamic>{};

    void addRow(String label, String value, {String? right}) {
      final trimmedValue = value.trim();
      final trimmedRight = (right ?? '').trim();
      if (trimmedValue.isEmpty && trimmedRight.isEmpty) {
        return;
      }

      rows.add({
        'label': label,
        'left': trimmedValue.isEmpty ? '-' : trimmedValue,
        'right': trimmedRight.isEmpty ? '-' : trimmedRight,
      });
    }

    addRow('Competition', widget.match.competition, right: widget.match.country);
    addRow(
      'Score',
      _displayScore(widget.match.homeScore),
      right: _displayScore(widget.match.awayScore),
    );
    addRow(
      'Status',
      _statusLabel(widget.match.status),
      right: _getStatusBadgeText(),
    );

    if (widget.match.startTime != null) {
      addRow('Kickoff', _formatDateTime(widget.match.startTime!));
    }

    addRow(
      'Venue',
      _readNestedDisplayValue(matchInfo, const [
        'Venue',
        'venue',
        'Vnm',
        'vnm',
        'Stadium',
        'stadium',
      ], ''),
    );
    addRow(
      'Referee',
      _readNestedDisplayValue(matchInfo, const [
        'Ref',
        'ref',
        'Referee',
        'referee',
      ], ''),
    );
    addRow(
      'Round',
      _readNestedDisplayValue(matchInfo, const [
        'Round',
        'round',
        'Rnd',
        'rnd',
      ], ''),
    );
    addRow(
      'Stage',
      _readNestedDisplayValue(matchInfo, const [
        'Stg.Nm',
        'Stg.nm',
        'Stg.Snm',
        'Stg.snm',
        'stage.name',
      ], ''),
    );
    addRow(
      'Attendance',
      _readNestedDisplayValue(matchInfo, const [
        'Att',
        'att',
        'Attendance',
        'attendance',
      ], ''),
    );
    addRow('Match ID', widget.match.eid);

    return rows;
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

  String _extractSummaryHighlight({
    required Map<String, dynamic> scoreboard,
    required Map<String, dynamic> detail,
  }) {
    final scoreboardHighlight = _extractScoreboardHighlight(scoreboard);
    if (scoreboardHighlight.isNotEmpty) {
      return scoreboardHighlight;
    }

    final detailHighlight = _readNestedDisplayValue(detail, const [
      'm.StatusText',
      'm.statusText',
      'm.EventStatus',
      'm.eventStatus',
      'm.Status',
      'm.status',
      'StatusText',
      'statusText',
      'Summary',
      'summary',
    ], '');
    if (detailHighlight.isNotEmpty) {
      return detailHighlight;
    }

    final venue = _readNestedDisplayValue(detail, const [
      'm.Venue',
      'm.venue',
    ], '');
    if (venue.isNotEmpty) {
      return 'Venue: $venue';
    }

    return '';
  }

  List<Map<String, String>> _extractSummaryTimeline({
    required Map<String, dynamic> scoreboard,
    required Map<String, dynamic> detail,
  }) {
    final mergedTimeline = _mergeTimelineItems([
      ..._extractScoreboardTimeline(scoreboard),
      ..._extractScoreboardTimeline(detail),
    ]);

    return _decorateTimelineItems(
      items: mergedTimeline,
      scoreboard: scoreboard,
      detail: detail,
    );
  }

  List<Map<String, String>> _mergeTimelineItems(
    List<Map<String, String>> items,
  ) {
    final mergedByKey = <String, Map<String, String>>{};

    for (final item in items) {
      final key = [
        item['minute'] ?? '',
        item['title'] ?? '',
        item['side'] ?? '',
      ].join('|').toLowerCase();

      final existing = mergedByKey[key];
      if (existing == null) {
        mergedByKey[key] = item;
        continue;
      }

      final existingScore = _timelineMergeScore(existing);
      final currentScore = _timelineMergeScore(item);
      if (currentScore > existingScore) {
        mergedByKey[key] = item;
      }
    }

    return mergedByKey.values.toList();
  }

  int _timelineMergeScore(Map<String, String> item) {
    var score = 0;
    final icon = item['icon'] ?? '';
    final subtitle = item['subtitle'] ?? '';
    final badge = item['badge'] ?? '';

    if (icon.isNotEmpty && icon != 'default') {
      score += 4;
    }
    if (badge.isNotEmpty) {
      score += 3;
    }
    if (subtitle.isNotEmpty) {
      score += 2;
    }
    if (subtitle.contains('[') && subtitle.contains(']')) {
      score += 2;
    }
    if (subtitle.toLowerCase().contains('goal') ||
        subtitle.toLowerCase().contains('card') ||
        subtitle.toLowerCase().contains('penalty') ||
        subtitle.toLowerCase().contains('review') ||
        subtitle.toLowerCase().contains('pitch')) {
      score += 2;
    }

    return score;
  }

  List<Map<String, String>> _extractScoreboardTimeline(
    Map<String, dynamic> payload,
  ) {
    final incsEvents = _extractTimelineFromIncs(payload);
    if (incsEvents.isNotEmpty) {
      return incsEvents;
    }

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
      final title = _buildTimelineTitle(node);
      final subtitle = _buildTimelineSubtitle(node);

      if (minute.isEmpty || (title.isEmpty && subtitle.isEmpty)) {
        continue;
      }

      if (_looksLikeNumericTimelineTitle(title)) {
        continue;
      }

      final side = _inferTimelineSide(node);
      var icon = _inferTimelineIcon(node, subtitle);
      
      // Double-check for cards in title as well
      if (icon == 'default') {
        final titleLower = title.toLowerCase();
        if (titleLower.contains('yellow') || titleLower.contains('yc')) {
          icon = 'yellow';
        } else if (titleLower.contains('red') || titleLower.contains('rc')) {
          icon = 'red';
        }
      }
      
      final resolvedTitle = title.isEmpty ? subtitle : title;
      final resolvedSubtitle = title.isEmpty ? '' : subtitle;
      final key =
          '${minute.toLowerCase()}|${resolvedTitle.toLowerCase()}|${resolvedSubtitle.toLowerCase()}|$side';
      if (!seen.add(key)) {
        continue;
      }

      items.add({
        'minute': minute,
        'title': resolvedTitle,
        'subtitle': resolvedSubtitle,
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

  List<Map<String, String>> _decorateTimelineItems({
    required List<Map<String, String>> items,
    required Map<String, dynamic> scoreboard,
    required Map<String, dynamic> detail,
  }) {
    final sorted = [...items]
      ..sort(
        (a, b) => _timelineMinuteSortValue(
          b['minute'] ?? '',
        ).compareTo(_timelineMinuteSortValue(a['minute'] ?? '')),
      );

    final firstHalf = <Map<String, String>>[];
    final secondHalf = <Map<String, String>>[];

    for (final item in sorted) {
      final minuteValue = _timelineMinuteSortValue(item['minute'] ?? '');
      if (minuteValue <= 4599) {
        firstHalf.add(item);
      } else {
        secondHalf.add(item);
      }
    }

    final decorated = <Map<String, String>>[];
    final fullTimeLabel = _buildFullTimeTimelineLabel(detail, scoreboard);
    if (fullTimeLabel.isNotEmpty) {
      decorated.add({'kind': 'divider', 'label': fullTimeLabel});
    }

    decorated.addAll(secondHalf);

    final halfTimeLabel = _buildHalfTimeTimelineLabel(detail, scoreboard, items);
    if (halfTimeLabel.isNotEmpty && (firstHalf.isNotEmpty || secondHalf.isNotEmpty)) {
      decorated.add({'kind': 'divider', 'label': halfTimeLabel});
    }

    decorated.addAll(firstHalf);
    return decorated;
  }

  String _buildFullTimeTimelineLabel(
    Map<String, dynamic> detail,
    Map<String, dynamic> scoreboard,
  ) {
    final home = _firstNonEmpty([
      _readNestedDisplayValue(scoreboard, const ['Tr1', 'tr1', 'T1Sc', 'm.Tr1'], ''),
      _readNestedDisplayValue(detail, const ['m.Tr1', 'Tr1', 'homeScore'], ''),
      widget.match.homeScore,
    ]);
    final away = _firstNonEmpty([
      _readNestedDisplayValue(scoreboard, const ['Tr2', 'tr2', 'T2Sc', 'm.Tr2'], ''),
      _readNestedDisplayValue(detail, const ['m.Tr2', 'Tr2', 'awayScore'], ''),
      widget.match.awayScore,
    ]);

    if (home.isEmpty && away.isEmpty) {
      return '';
    }

    return 'FT (${_displayScore(home)}-${_displayScore(away)})';
  }

  String _buildHalfTimeTimelineLabel(
    Map<String, dynamic> detail,
    Map<String, dynamic> scoreboard,
    List<Map<String, String>> timelineItems,
  ) {
    final explicitHome = _firstNonEmpty([
      _readNestedDisplayValue(scoreboard, const [
        'Ht1',
        'ht1',
        'HT1',
        'Ht.Tr1',
        'ht.tr1',
        'Scores.Ht1',
      ], ''),
      _readNestedDisplayValue(detail, const [
        'm.Ht1',
        'm.ht1',
        'HT1',
        'Ht1',
        'Scores.Ht1',
      ], ''),
    ]);
    final explicitAway = _firstNonEmpty([
      _readNestedDisplayValue(scoreboard, const [
        'Ht2',
        'ht2',
        'HT2',
        'Ht.Tr2',
        'ht.tr2',
        'Scores.Ht2',
      ], ''),
      _readNestedDisplayValue(detail, const [
        'm.Ht2',
        'm.ht2',
        'HT2',
        'Ht2',
        'Scores.Ht2',
      ], ''),
    ]);

    if (explicitHome.isNotEmpty || explicitAway.isNotEmpty) {
      return 'HT (${_displayScore(explicitHome)}-${_displayScore(explicitAway)})';
    }

    for (final item in timelineItems) {
      final minuteValue = _timelineMinuteSortValue(item['minute'] ?? '');
      if (minuteValue > 4599) {
        continue;
      }

      final score = _extractScoreFromTimelineText(item['subtitle'] ?? '');
      if (score != null) {
        return 'HT (${score.$1}-${score.$2})';
      }
    }

    return '';
  }

  (String, String)? _extractScoreFromTimelineText(String value) {
    final match = RegExp(r'\[(\d+)-(\d+)\]').firstMatch(value);
    if (match == null) {
      return null;
    }

    return (match.group(1) ?? '', match.group(2) ?? '');
  }

  String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return '';
  }

  List<Map<String, String>> _extractTimelineFromIncs(
    Map<String, dynamic> payload,
  ) {
    final incs = payload['Incs'];
    if (incs is! Map) {
      return const [];
    }

    final events = <Map<String, String>>[];

    for (final entry in incs.entries) {
      final key = entry.key.toString();

      final eventList = entry.value;
      if (eventList is! List) {
        continue;
      }

      for (final rawEvent in eventList) {
        if (rawEvent is! Map) {
          continue;
        }

        final event = Map<String, dynamic>.from(rawEvent);
        final minute = _formatTimelineMinute(
          _asInt(event['Min']),
          _asInt(event['MinEx']),
        );
        if (minute.isEmpty) {
          continue;
        }

        final nestedIncs = event['Incs'] is List ? event['Incs'] as List : const [];
        final nestedMaps = nestedIncs
            .whereType<Map>()
            .map((nested) => Map<String, dynamic>.from(nested))
            .toList();
        final primaryNode = _resolvePrimaryTimelineIncident(event, nestedMaps);
        final side = _timelineSideFromWebIncs(primaryNode ?? event);
        final scoreText = _timelineScoreText(event['Sc']);
        String displayName = _timelinePersonName(primaryNode ?? event);
        int incidentType = _resolveTimelineIncidentType(
          event: event,
          primaryNode: primaryNode,
          nestedMaps: nestedMaps,
          incidentBucketKey: key,
        );

        // Filter out penalty score events (bucket 4) only if they are not yellow/red cards
        if (key == '4' && incidentType != 43 && incidentType != 44 && incidentType != 45) {
          continue;
        }

        final assistPlayer = _resolveNestedIncidentByTypes(nestedMaps, const [63]);
        final assistName = assistPlayer == null
            ? ''
            : _timelinePersonName(assistPlayer);

        if (displayName.isEmpty) {
          final namedNode = nestedMaps.firstWhere(
            (item) => _timelinePersonName(item).isNotEmpty,
            orElse: () => <String, dynamic>{},
          );
          if (namedNode.isNotEmpty) {
            displayName = _timelinePersonName(namedNode);
          }
        }

        if (displayName.isEmpty) {
          displayName = 'Unknown Event';
        }

        final subtitle = _buildTimelineIncidentSubtitle(
          incidentType: incidentType,
          scoreText: scoreText,
          event: event,
          primaryNode: primaryNode,
          assistName: assistName,
        );

        events.add({
          'minute': minute,
          'title': displayName,
          'subtitle': subtitle,
          'side': side,
          'icon': _timelineIconFromIncidentType(incidentType),
          'badge': _timelineBadgeLabel(
            event: event,
            primaryNode: primaryNode,
            incidentType: incidentType,
          ),
          'sort': _timelineSortKey(
            _asInt(event['Min']),
            _asInt(event['MinEx']),
          ).toString(),
        });
      }
    }

    events.sort((a, b) {
      final aValue = int.tryParse(a['sort'] ?? '') ?? 0;
      final bValue = int.tryParse(b['sort'] ?? '') ?? 0;
      return aValue.compareTo(bValue);
    });

    return events
        .map((event) => Map<String, String>.from(event)..remove('sort'))
        .toList();
  }

  String _timelineSideFromWebIncs(Map<String, dynamic> event) {
    final nm = _asInt(event['Nm']);
    return nm == 2 ? 'home' : 'away';
  }

  Map<String, dynamic>? _resolvePrimaryTimelineIncident(
    Map<String, dynamic> event,
    List<Map<String, dynamic>> nestedMaps,
  ) {
    final preferred = _resolveNestedIncidentByTypes(
      nestedMaps,
      const [36, 37, 38, 39, 43, 44, 45, 47],
    );
    if (preferred != null) {
      return preferred;
    }

    final withPerson = nestedMaps.firstWhere(
      (item) => _timelinePersonName(item).isNotEmpty,
      orElse: () => <String, dynamic>{},
    );
    if (withPerson.isNotEmpty) {
      return withPerson;
    }

    return event;
  }

  Map<String, dynamic>? _resolveNestedIncidentByTypes(
    List<Map<String, dynamic>> nestedMaps,
    List<int> types,
  ) {
    for (final type in types) {
      for (final nested in nestedMaps) {
        if (_asInt(nested['IT']) == type) {
          return nested;
        }
      }
    }
    return null;
  }

  int _resolveTimelineIncidentType({
    required Map<String, dynamic> event,
    Map<String, dynamic>? primaryNode,
    required List<Map<String, dynamic>> nestedMaps,
    required String incidentBucketKey,
  }) {
    final directTypes = <int>[
      _asInt(event['IT']),
      if (primaryNode != null) _asInt(primaryNode['IT']),
      ...nestedMaps.map((item) => _asInt(item['IT'])),
    ].where((type) => type > 0).toList();

    for (final type in directTypes) {
      if (_isSupportedTimelineIncidentType(type)) {
        return type;
      }
    }

    final combined = [
      _readNestedDisplayValue(event, const [
        'Txt',
        'txt',
        'Desc',
        'desc',
        'Detail',
        'detail',
        'Reason',
        'reason',
        'StatusText',
        'statusText',
      ], ''),
      if (primaryNode != null)
        _readNestedDisplayValue(primaryNode, const [
          'Txt',
          'txt',
          'Desc',
          'desc',
          'Detail',
          'detail',
          'Reason',
          'reason',
          'StatusText',
          'statusText',
        ], ''),
      ...nestedMaps.map(
        (item) => _readNestedDisplayValue(item, const [
          'Txt',
          'txt',
          'Desc',
          'desc',
          'Detail',
          'detail',
          'Reason',
          'reason',
          'StatusText',
          'statusText',
        ], ''),
      ),
    ].join(' ').toLowerCase();

    if (combined.contains('second yellow') || combined.contains('second yellow card')) {
      return 44;
    }
    if (combined.contains('yellow card') || 
        combined.contains('yellow') ||
        combined.contains('yc')) {
      return 43;
    }
    if (combined.contains('red card') || 
        combined.contains('red') ||
        combined.contains('rc')) {
      return 45;
    }
    if (combined.contains('missed penalty')) {
      return 38;
    }
    if (combined.contains('own goal')) {
      return 39;
    }
    if (combined.contains('penalty goal')) {
      return 37;
    }
    if (combined.contains('goal')) {
      return 36;
    }

    final bucketFallback = _timelineIncidentTypeFromBucket(incidentBucketKey);
    if (bucketFallback != 0) {
      return bucketFallback;
    }

    return _asInt((primaryNode ?? event)['IT']);
  }

  int _timelineIncidentTypeFromBucket(String bucketKey) {
    switch (bucketKey) {
      case '1':
        return 36; // Goal
      case '2':
        return 43; // Yellow card
      case '3':
        return 45; // Red card
      case '4':
        return 43; // Mixed events including cards
      case '5':
        return 38; // Missed penalty
      case '6':
        return 39; // Own goal
      case '7':
        return 43; // Additional yellow card bucket
      case '8':
        return 44; // Second yellow
      case '9':
        return 49; // Additional red card type
      default:
        return 0;
    }
  }

  bool _isSupportedTimelineIncidentType(int type) {
    switch (type) {
      case 36:
      case 37:
      case 38:
      case 39:
      case 43:
      case 44:
      case 45:
      case 47:
      case 46: // Additional card-related types
      case 48:
      case 49:
      case 50:
        return true;
      default:
        return false;
    }
  }

  String _timelineScoreText(dynamic score) {
    if (score is List && score.length >= 2) {
      return '[${score[0]}-${score[1]}]';
    }
    return '';
  }

  String _timelinePersonName(Map<String, dynamic> node) {
    final pn = (node['Pn'] ?? '').toString().trim();
    if (pn.isNotEmpty) {
      return pn;
    }

    final first = (node['Fn'] ?? '').toString().trim();
    final last = (node['Ln'] ?? '').toString().trim();
    final full = '$first $last'.trim();
    if (full.isNotEmpty) {
      return full;
    }

    return '';
  }

  String _timelineIncidentLabel(int type) {
    switch (type) {
      case 36:
        return 'Goal';
      case 37:
        return 'Penalty Goal';
      case 38:
        return 'Missed Penalty';
      case 39:
        return 'Own Goal';
      case 43:
        return 'Yellow Card';
      case 44:
        return 'Second Yellow';
      case 45:
        return 'Red Card';
      case 47:
        return 'Goal ET';
      default:
        return 'Event';
    }
  }

  String _buildTimelineIncidentSubtitle({
    required int incidentType,
    required String scoreText,
    required Map<String, dynamic> event,
    Map<String, dynamic>? primaryNode,
    required String assistName,
  }) {
    final source = primaryNode ?? event;
    final explicit = _readNestedDisplayValue(source, const [
      'Txt',
      'txt',
      'Desc',
      'desc',
      'Detail',
      'detail',
      'Reason',
      'reason',
      'St',
      'st',
      'StatusText',
      'statusText',
    ], '');

    final normalizedExplicit = explicit.toLowerCase();
    if (normalizedExplicit.contains('var') ||
        normalizedExplicit.contains('review') ||
        normalizedExplicit.contains('not on pitch')) {
      return explicit;
    }

    if (assistName.trim().isNotEmpty &&
        (incidentType == 36 || incidentType == 37 || incidentType == 47)) {
      return assistName.trim();
    }

    final fallbackLabel = _timelineIncidentLabel(incidentType);
    if (scoreText.isNotEmpty &&
        (incidentType == 36 || incidentType == 37 || incidentType == 39 || incidentType == 47)) {
      return '$fallbackLabel $scoreText';
    }

    if (incidentType == 43 || incidentType == 44 || incidentType == 45) {
      return explicit;
    }

    if (explicit.isNotEmpty) {
      return explicit;
    }

    return fallbackLabel;
  }

  String _timelineBadgeLabel({
    required Map<String, dynamic> event,
    Map<String, dynamic>? primaryNode,
    required int incidentType,
  }) {
    final combined = [
      _readNestedDisplayValue(event, const [
        'Txt',
        'txt',
        'Desc',
        'desc',
        'Detail',
        'detail',
        'StatusText',
        'statusText',
      ], ''),
      if (primaryNode != null)
        _readNestedDisplayValue(primaryNode, const [
          'Txt',
          'txt',
          'Desc',
          'desc',
          'Detail',
          'detail',
          'StatusText',
          'statusText',
        ], ''),
    ].join(' ').toLowerCase();

    if (combined.contains('var') || combined.contains('review')) {
      return 'VAR';
    }

    if (incidentType == 38) {
      return 'MISS';
    }

    return '';
  }

  String _timelineIconFromIncidentType(int type) {
    switch (type) {
      case 36:
        return 'goal';
      case 37:
        return 'penalty_goal';
      case 38:
        return 'missed_penalty';
      case 39:
        return 'own_goal';
      case 43:
      case 44:
      case 46:
      case 48:
        return 'yellow';
      case 45:
      case 49:
      case 50:
        return 'red';
      case 47:
        return 'goal';
      default:
        return 'default';
    }
  }

  Color _timelineIconColor(String iconType, Color accentColor) {
    switch (iconType) {
      case 'goal':
        return const Color(0xFF22C55E);
      case 'penalty_goal':
        return const Color(0xFF15803D);
      case 'missed_penalty':
        return const Color(0xFFEF4444);
      case 'own_goal':
        return const Color(0xFFDC2626);
      case 'yellow':
        return const Color(0xFFFACC15);
      case 'red':
        return const Color(0xFFEF4444);
      default:
        return accentColor;
    }
  }

  String _timelineIconSymbol(String iconType) {
    switch (iconType) {
      case 'goal':
        return '⚽';
      case 'penalty_goal':
        return '⚽P';
      case 'missed_penalty':
        return '✖P';
      case 'own_goal':
        return 'OG';
      case 'yellow':
      case 'red':
        return '█';
      default:
        return '';
    }
  }

  String _formatTimelineMinute(int minute, int minuteExtra) {
    if (minute <= 0 && minuteExtra <= 0) {
      return '';
    }
    if (minuteExtra > 0) {
      return '$minute+$minuteExtra\'';
    }
    return '$minute\'';
  }

  int _timelineSortKey(int minute, int minuteExtra) {
    return (minute * 100) + minuteExtra;
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
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
    final title = _buildTimelineTitle(node);
    final subtitle = _buildTimelineSubtitle(node);

    return minute.isNotEmpty && (title.isNotEmpty || subtitle.isNotEmpty);
  }

  String _buildTimelineTitle(Map<String, dynamic> node) {
    final playerName = _readNestedDisplayValue(node, const [
      'Pn',
      'pn',
      'PlayerName',
      'playerName',
      'Pnm',
      'name',
      'Player.Nm',
      'Player.Pn',
      'Player.name',
      'Person.Pn',
      'Person.name',
    ], '');
    if (playerName.isNotEmpty) {
      return playerName;
    }

    final first = _readNestedDisplayValue(node, const ['Fn', 'fn'], '');
    final last = _readNestedDisplayValue(node, const ['Ln', 'ln'], '');
    final fullName = '$first $last'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    return _readNestedDisplayValue(node, const [
      'Title',
      'title',
      'Text',
      'text',
      'Event',
      'event',
      'TypeNm',
      'typeName',
      'IncidentType',
      'incidentType',
      'Type',
      'type',
      'Desc',
      'desc',
      'Detail',
      'detail',
      'Reason',
      'reason',
      'StatusText',
      'statusText',
    ], '');
  }

  bool _looksLikeNumericTimelineTitle(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    return int.tryParse(trimmed) != null;
  }

  String _buildTimelineSubtitle(Map<String, dynamic> node) {
    final primary = _readNestedDisplayValue(node, const [
      'Desc',
      'desc',
      'Text',
      'text',
      'Type',
      'type',
      'TypeNm',
      'typeName',
      'IncidentType',
      'incidentType',
      'Detail',
      'detail',
      'Reason',
      'reason',
      'StatusText',
      'statusText',
    ], '');
    final team = _readNestedDisplayValue(node, const [
      'Tnm',
      'tnm',
      'TeamName',
      'teamName',
      'CompetitorName',
      'competitorName',
    ], '');
    final score = _readNestedDisplayValue(node, const [
      'Score',
      'score',
      'Scr',
      'scr',
      'Result',
      'result',
    ], '');

    final parts = <String>[];
    if (primary.isNotEmpty) {
      parts.add(primary);
    }
    if (team.isNotEmpty &&
        !parts.any((part) => part.toLowerCase().contains(team.toLowerCase()))) {
      parts.add(team);
    }
    if (score.isNotEmpty &&
        !parts.any((part) => part.toLowerCase().contains(score.toLowerCase()))) {
      parts.add(score);
    }

    return parts.join(' • ');
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
      'CompetitorName',
      'competitorName',
      'TeamName',
      'teamName',
      'Tnm',
      'tnm',
      'Tid',
      'tid',
    ], '').toLowerCase();

    if (raw.contains('home') ||
        raw == 'h' ||
        raw == 'hometeam' ||
        raw == 'local' ||
        raw == '1' ||
        raw == widget.match.homeTeamId.toLowerCase()) {
      return 'home';
    }
    if (raw.contains('away') ||
        raw == 'a' ||
        raw == 'awayteam' ||
        raw == 'visitor' ||
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
    // Build comprehensive search string from all possible card indicator fields
    final fieldsList = [
      subtitle,
      _readNestedDisplayValue(node, const [
        'Type',
        'type',
        'IncidentType',
        'incidentType',
        'Desc',
        'desc',
        'Txt',
        'txt',
        'Text',
        'text',
        'TypeName',
        'typeName',
        'TypeNm',
        'typeNm',
        'CardType',
        'cardType',
        'Card',
        'card',
        'Period',
        'period',
        'Label',
        'label',
      ], ''),
    ];
    
    final combined = fieldsList.join(' ').toLowerCase();

    // Check for cards FIRST before other events
    if (combined.contains('second yellow') || combined.contains('second yellow card')) {
      return 'yellow';
    }
    if (combined.contains('yellow card') || 
        combined.contains('yellow') ||
        combined.contains('yc') ||
        combined.contains('card 2')) {
      return 'yellow';
    }
    if (combined.contains('red card') || 
        combined.contains('red') ||
        combined.contains('rc') ||
        combined.contains('card 1')) {
      return 'red';
    }
    
    // Then check for other event types
    if (combined.contains('missed penalty')) {
      return 'missed_penalty';
    }
    if (combined.contains('own goal')) {
      return 'own_goal';
    }
    if (combined.contains('penalty goal') || combined.contains('penalty')) {
      return 'penalty_goal';
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
          return const MatchListLoadingSkeleton(cardCount: 3, showHeader: true);
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
          return const MatchListLoadingSkeleton(cardCount: 3, showHeader: true);
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
    final statRows = _extractMatchStatComparisonRows(statistics);

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
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
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
                      child: _buildMatchStatBarRow(stat),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStatBarRow(Map<String, String> stat) {
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
                _formatStatDisplayValue(homeText),
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
                _formatStatDisplayValue(awayText),
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

  List<Map<String, String>> _extractMatchStatComparisonRows(
    Map<String, dynamic> statistics,
  ) {
    final selectedKeys = <String, String>{
      'Pss': 'Possession (%)',
      'Shon': 'Shots on target',
      'Shof': 'Shots off target',
      'Cos': 'Corner Kicks',
      'Fls': 'Fouls',
      'Ycs': 'Yellow cards',
      'YRcs': 'Red cards',
      'Ofs': 'Offsides',
    };

    final statList = <Map<String, dynamic>>[];
    if (statistics['Stat'] is List<dynamic>) {
      statList.addAll(
        (statistics['Stat'] as List<dynamic>).whereType<Map<String, dynamic>>(),
      );
    } else if (statistics['Stats'] is List<dynamic>) {
      statList.addAll(
        (statistics['Stats'] as List<dynamic>)
            .whereType<Map<String, dynamic>>(),
      );
    } else if (statistics['stats'] is List<dynamic>) {
      statList.addAll(
        (statistics['stats'] as List<dynamic>)
            .whereType<Map<String, dynamic>>(),
      );
    } else if (statistics['statistics'] is List<dynamic>) {
      statList.addAll(
        (statistics['statistics'] as List<dynamic>)
            .whereType<Map<String, dynamic>>(),
      );
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

    if (statList.length < 2) {
      return const [];
    }

    final homeStats = statList[0];
    final awayStats = statList[1];
    return selectedKeys.entries
        .map(
          (entry) => {
            'label': entry.value,
            'home': _readDisplayValue(homeStats, [entry.key], '0'),
            'away': _readDisplayValue(awayStats, [entry.key], '0'),
          },
        )
        .toList();
  }

  String _formatStatDisplayValue(String raw) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? '0' : trimmed;
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
          return const MatchListLoadingSkeleton(cardCount: 2, showHeader: false);
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
          return const MatchListLoadingSkeleton(cardCount: 2, showHeader: false);
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
          return const MatchListLoadingSkeleton(cardCount: 3, showHeader: true);
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
          return const MatchListLoadingSkeleton(cardCount: 4, showHeader: true);
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
                  ...rows.map(_buildLeagueRow),
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
    } else if (h2hData.containsKey('H2H') && h2hData['H2H'] is List) {
      matches = (h2hData['H2H'] as List<dynamic>)
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

    return Column(
      children: matches
          .map(
            (match) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildH2HMatchCard(match),
            ),
          )
          .toList(),
    );
  }

  Widget _buildH2HMatchCard(Map<String, dynamic> match) {
    final stage = match['Stg'] as Map<String, dynamic>?;
    final homeTeamData = _extractH2HTeam(match['T1']);
    final awayTeamData = _extractH2HTeam(match['T2']);
    final homeScore = _readNestedDisplayValue(match, const [
      'Tr1',
      'T1Sc',
      'homeScore',
    ], '-');
    final awayScore = _readNestedDisplayValue(match, const [
      'Tr2',
      'T2Sc',
      'awayScore',
    ], '-');
    final stageName = _readNestedDisplayValue(stage ?? const {}, const [
      'Snm',
      'snm',
      'Nm',
      'name',
    ], 'League');
    final formattedDate = _formatH2HDate(
      _readNestedDisplayValue(match, const ['Esd', 'esd', 'date'], ''),
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_outlined,
                        size: 12,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          stageName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 1,
              color: Colors.white.withOpacity(0.08),
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          homeTeamData['name'] ?? 'Home',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: _h2HWinningTextColor(
                              homeScore,
                              awayScore,
                              true,
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildH2HTeamLogo(
                        homeTeamData['image'] ?? '',
                        'Home Team',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      _buildH2HScoreBox(homeScore, awayScore),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '-',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _buildH2HScoreBox(awayScore, homeScore),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildH2HTeamLogo(
                        awayTeamData['image'] ?? '',
                        'Away Team',
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          awayTeamData['name'] ?? 'Away',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _h2HWinningTextColor(
                              awayScore,
                              homeScore,
                              true,
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _extractH2HTeam(dynamic raw) {
    if (raw is List<dynamic> &&
        raw.isNotEmpty &&
        raw.first is Map<String, dynamic>) {
      final team = raw.first as Map<String, dynamic>;
      return {
        'name': _readNestedDisplayValue(team, const [
          'Nm',
          'name',
          'Tnm',
        ], 'Unknown'),
        'image': _readNestedDisplayValue(team, const ['Img', 'img'], ''),
      };
    }

    if (raw is Map<String, dynamic>) {
      return {
        'name': _readNestedDisplayValue(raw, const [
          'Nm',
          'name',
          'Tnm',
        ], 'Unknown'),
        'image': _readNestedDisplayValue(raw, const ['Img', 'img'], ''),
      };
    }

    return {'name': raw?.toString() ?? 'Unknown', 'image': ''};
  }

  Widget _buildH2HTeamLogo(String imagePath, String semanticLabel) {
    final imageUrl = _teamImageUrl(imagePath);
    return Container(
      width: 32,
      height: 32,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: imageUrl == null
          ? const Icon(Icons.shield_outlined, size: 16, color: Colors.white70)
          : Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.shield_outlined,
                size: 16,
                color: Colors.white70,
              ),
            ),
    );
  }

  Widget _buildH2HScoreBox(String score, String opponentScore) {
    final colors = _h2HScoreColors(score, opponentScore);
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors['background']!,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors['border']!),
      ),
      child: Text(
        score,
        style: TextStyle(
          color: colors['text']!,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Map<String, Color> _h2HScoreColors(String score, String opponentScore) {
    final current = int.tryParse(score) ?? 0;
    final other = int.tryParse(opponentScore) ?? 0;
    if (current > other) {
      return {
        'background': const Color(0xFFDCFCE7),
        'text': Colors.black,
        'border': const Color(0xFFBBF7D0),
      };
    }
    if (current < other) {
      return {
        'background': const Color(0xFFFEE2E2),
        'text': Colors.black,
        'border': const Color(0xFFFECACA),
      };
    }
    return {
      'background': const Color(0xFF9CA3AF),
      'text': Colors.white,
      'border': const Color(0xFF6B7280),
    };
  }

  Color _h2HWinningTextColor(
    String score,
    String opponentScore,
    bool emphasis,
  ) {
    final current = int.tryParse(score) ?? 0;
    final other = int.tryParse(opponentScore) ?? 0;
    if (current > other && emphasis) {
      return Colors.white;
    }
    return Colors.white70;
  }

  String _formatH2HDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length >= 8) {
      final year = trimmed.substring(0, 4);
      final month = trimmed.substring(4, 6);
      final day = trimmed.substring(6, 8);
      return '$day/$month/$year';
    }
    return '-';
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
          return const MatchListLoadingSkeleton(cardCount: 2, showHeader: false);
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
