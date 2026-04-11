import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/match_item.dart';
import '../../services/live_score_service.dart';
import '../../theme/app_palette.dart';
import '../../widgets/app_skeleton.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LiveScore6 API field constants (per official tutorial field-meaning doc)
// ─────────────────────────────────────────────────────────────────────────────
class _F {
  // BasicMatchParser
  static const homeTeam       = 'T1';
  static const awayTeam       = 'T2';
  static const homeScore      = 'Tr1';
  static const awayScore      = 'Tr2';
  static const matchStartDate = 'Esd';
  static const matchEndDate   = 'Edf';
  static const matchStatus    = 'Eps';
  static const matchStatusId  = 'Esid';
  static const matchId        = 'Eid';
  static const overallStatus  = 'Epr';
  static const whichTeamWon   = 'Ewt';
  static const matchInfoProps = 'EO';

  // SoccerBasicMatchParser
  static const halfTimeHome   = 'Trh1';
  static const halfTimeAway   = 'Trh2';
  static const extraTimeHome  = 'Tr1ET';
  static const extraTimeAway  = 'Tr2ET';
  static const penaltyHome    = 'Trp1';
  static const penaltyAway    = 'Trp2';

  // BasicParticipantParser
  static const participantId  = 'ID';
  static const participantNm  = 'Nm';
  static const badgeId        = 'Img';
  static const countryName    = 'Cnm';
  static const countryId      = 'CoId';

  // BasicPlayersParser
  static const playerFirstNm    = 'Fn';
  static const playerLastNm     = 'Ln';
  static const playerFullNm     = 'Shnm';
  static const playerInternalId = 'Aid';
  static const playerExtId      = 'Pid';
  static const playerNumber     = 'Snu';
  static const playerPos        = 'Pos';
  static const playerActPos     = 'PosA';
  static const playerStatus     = 'Rt';
  static const playerStatusRs   = 'Rs';
  static const returnInfoShort  = 'RtonS';
  static const returnInfoLong   = 'Rton';

  // LineupsParser
  static const lineups          = 'Lu';
  static const lineupPs         = 'Ps';
  static const lineupFo         = 'Fo';   // Standing Formations
  static const lineupSubs       = 'Subs';
  static const lineupIS         = 'IS';   // Injured/Suspended

  // IncidentParser
  static const incs             = 'Incs';
  static const incidentType     = 'IT';
  static const incidentReason   = 'IR';
  static const minute           = 'Min';
  static const minuteExt        = 'MinEx';
  static const playerNameInc    = 'Pn';
  static const incidentPlayerAid= 'Aid';
  static const incidentNm       = 'Nm';   // 1=home, 2=away
  static const scores           = 'Sc';
  static const second           = 'Sec';

  // HeadToHeadParser
  static const h2hEvents        = 'H2H';
  static const stageGroup       = 'Stg';

  // CompetitionStatsParser
  static const playerRank       = 'Rnk';
  static const playerStatName   = 'Pnm';
  static const teamId           = 'Tid';
  static const teamName         = 'Tnm';

  // Match stats keys
  static const statPossession   = 'Pss';
  static const statShotsOn      = 'Shon';
  static const statShotsOff     = 'Shof';
  static const statTotalShots   = 'Sht';
  static const statCorners      = 'Cos';
  static const statFouls        = 'Fls';
  static const statYellowCards  = 'Ycs';
  static const statRedCards     = 'YRcs';
  static const statOffsides     = 'Ofs';
  static const statSaves        = 'Svs';
  static const statAttacks      = 'Atk';
  static const statDangerousAtk = 'Dngs';

  // CompetitionParser / StageParser
  static const competitionName  = 'CompN';
  static const competitionDesc  = 'CompD';
  static const competitionSub   = 'CompST';
  static const competitionId    = 'CompId';
  static const stageName        = 'Snm';
  static const stageCode        = 'Scd';
  static const stageId          = 'Sid';
  static const stageExtId       = 'ExSid';

  // Incident Type IDs
  static const itRegularGoal        = 36;
  static const itPenalty            = 37;
  static const itMissedPenalty      = 38;
  static const itOwnGoal            = 39;
  static const itShootoutMissed     = 40;
  static const itShootoutPenalty    = 41;
  static const itYellowCard         = 43;
  static const itSecondYellow       = 44;
  static const itRedCard            = 45;
  static const itUnknownCard        = 46;
  static const itExtraTimeGoal      = 47;
  static const itExtraTimeMissed    = 48;
  static const itAssist             = 63;
  static const itSecondAssist       = 64;
  static const itSubstitution       = 3;
  static const itSubstitutionOut    = 4;
  static const itSubstitutionIn     = 5;
  static const itTimePeriodFirst    = 10;
  static const itTimePeriodHalf     = 11;
  static const itTimePeriodSecond   = 12;
  static const itTimePeriodFinished = 22;
  static const itFinishedAET        = 23;
  static const itFinishedAP         = 24;
  static const itVarPenalty         = 1046;
  static const itVarGoal            = 1047;
  static const itVarCard            = 1048;

  // Esid numeric status
  static const esidNotStarted  = 0;
  static const esidFirstHalf   = 1;
  static const esidHalfTime    = 2;
  static const esidSecondHalf  = 3;
  static const esidETFirst     = 4;
  static const esidETHalfTime  = 5;
  static const esidETSecond    = 6;
  static const esidPenalties   = 7;
  static const esidFullTime    = 8;
  static const esidPostponed   = -1;
  static const esidCancelled   = -2;
  static const esidAbandoned   = -3;
  static const esidSuspended   = -4;
}

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
                          const SizedBox(height: 5),
                          ...timelineItems.map((item) {
                            if (item['kind'] == 'divider') {
                              return _buildTimelineDividerRow(item['label'] ?? '');
                            }

                            final side = item['side'] ?? 'neutral';
                            final isHome = side == 'home';
                            final isAway = side == 'away';
                            final isNeutral = !isHome && !isAway;

                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
                                      accentColor: const Color.fromARGB(
                                        179,
                                        132,
                                        130,
                                        130,
                                      ),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: alignEnd
            ? [
          Flexible(
            flex: 6,
            child: _buildTimelineTextBlock(
              nameParts: nameParts,
              subtitle: subtitle,
              alignEnd: true,
            ),
          ),
          const SizedBox(width: 8),
          _buildTimelineEventMarker(item, accentColor),
          const SizedBox(width: 12),
          Expanded(child: _buildTimelineConnector()),
        ]
            : [
          Expanded(child: _buildTimelineConnector()),
          const SizedBox(width: 12),
          _buildTimelineEventMarker(item, accentColor),
          const SizedBox(width: 8),
          Flexible(
            flex: 6,
            child: _buildTimelineTextBlock(
              nameParts: nameParts,
              subtitle: subtitle,
              alignEnd: false,
            ),
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
      mainAxisSize: MainAxisSize.min,
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
              style: const TextStyle(
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
            const Color.fromARGB(0, 230, 0, 0),
            Colors.white.withOpacity(0.14),
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
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.24),
              Colors.white.withOpacity(0.1),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
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
          width: 19,
          height: 19,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFF111111), width: 1.1),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.sports_soccer,
            size: 11,
            color: Color(0xFF111111),
          ),
        ),
      );
    }

    if (iconType == 'yellow' || iconType == 'red') {
      return SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: Transform.rotate(
            angle: 0.02,
            child: Container(
              width: 13,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.black.withOpacity(0.22)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
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
        child: Icon(Icons.close_rounded, size: 14, color: color),
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
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Summary / Scoreboard rows
  // ─────────────────────────────────────────────────────────────────────────

  List<Map<String, String>> _extractScoreboardRows(
      Map<String, dynamic> payload,
      ) {
    final rows = <Map<String, String>>[];
    final candidates = <Map<String, dynamic>>[];
    _collectScoreboardNodes(payload, candidates);

    final seen = <String>{};
    for (final node in candidates) {
      final label = _readNestedDisplayValue(node, const [
        'Nm', 'nm', 'name', 'Label', 'label', 'Period', 'period', 'Ttl', 'ttl',
      ], '');
      final left = _readNestedDisplayValue(node, const [
        _F.homeScore, 'tr1', _F.homeTeam, 't1', 'home', 'Home', 'Left', 'left', 'S1', 's1',
      ], '');
      final right = _readNestedDisplayValue(node, const [
        _F.awayScore, 'tr2', _F.awayTeam, 't2', 'away', 'Away', 'Right', 'right', 'S2', 's2',
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

    for (final row in _extractDetailSummaryRows(detail, scoreboard: scoreboard)) {
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

  /// Extracts soccer-specific score rows: Half Time, Extra Time, Penalties
  /// using official tutorial field names: Trh1/Trh2, Tr1ET/Tr2ET, Trp1/Trp2
  List<Map<String, String>> _extractSoccerScoreRows(
      Map<String, dynamic> scoreboard,
      ) {
    final rows = <Map<String, String>>[];

    final ht1 = _readNestedDisplayValue(scoreboard, const [
      _F.halfTimeHome, 'Ht1', 'ht1',
    ], '');
    final ht2 = _readNestedDisplayValue(scoreboard, const [
      _F.halfTimeAway, 'Ht2', 'ht2',
    ], '');
    if (ht1.isNotEmpty || ht2.isNotEmpty) {
      rows.add({
        'label': 'Half Time',
        'left': ht1.isEmpty ? '-' : ht1,
        'right': ht2.isEmpty ? '-' : ht2,
      });
    }

    final et1 = _readNestedDisplayValue(scoreboard, const [
      _F.extraTimeHome, 'Tr1ET',
    ], '');
    final et2 = _readNestedDisplayValue(scoreboard, const [
      _F.extraTimeAway, 'Tr2ET',
    ], '');
    if (et1.isNotEmpty || et2.isNotEmpty) {
      rows.add({
        'label': 'Extra Time',
        'left': et1.isEmpty ? '-' : et1,
        'right': et2.isEmpty ? '-' : et2,
      });
    }

    final pen1 = _readNestedDisplayValue(scoreboard, const [
      _F.penaltyHome, 'Trp1',
    ], '');
    final pen2 = _readNestedDisplayValue(scoreboard, const [
      _F.penaltyAway, 'Trp2',
    ], '');
    if (pen1.isNotEmpty || pen2.isNotEmpty) {
      rows.add({
        'label': 'Penalties',
        'left': pen1.isEmpty ? '-' : pen1,
        'right': pen2.isEmpty ? '-' : pen2,
      });
    }

    return rows;
  }

  List<Map<String, String>> _extractDetailSummaryRows(
      Map<String, dynamic> detail, {
        Map<String, dynamic>? scoreboard,
      }) {
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

    // Soccer-specific score breakdowns (Trh1/Trh2, Tr1ET/Tr2ET, Trp1/Trp2)
    if (scoreboard != null) {
      for (final row in _extractSoccerScoreRows(scoreboard)) {
        addRow(row['label']!, row['left']!, right: row['right']);
      }
    }

    addRow(
      'Venue',
      _readNestedDisplayValue(matchInfo, const [
        'Venue', 'venue', 'Vnm', 'vnm', 'Stadium', 'stadium',
      ], ''),
    );
    addRow(
      'Referee',
      _readNestedDisplayValue(matchInfo, const [
        'Ref', 'ref', 'Referee', 'referee',
      ], ''),
    );
    addRow(
      'Round',
      _readNestedDisplayValue(matchInfo, const [
        'Round', 'round', 'Rnd', 'rnd',
      ], ''),
    );
    addRow(
      'Stage',
      _readNestedDisplayValue(matchInfo, const [
        'Stg.Nm', 'Stg.nm', 'Stg.Snm', 'Stg.snm', 'stage.name',
      ], ''),
    );
    addRow(
      'Attendance',
      _readNestedDisplayValue(matchInfo, const [
        'Att', 'att', 'Attendance', 'attendance',
      ], ''),
    );
    // Eid = Match/Team ID per tutorial
    addRow('Match ID (Eid)', widget.match.eid);

    return rows;
  }

  List<Map<String, dynamic>> _extractStatisticsTeamStatNodes(
      Map<String, dynamic> statistics,
      ) {
    final statList = <Map<String, dynamic>>[];
    if (statistics['Stat'] is List<dynamic>) {
      statList.addAll(
        (statistics['Stat'] as List<dynamic>).whereType<Map<String, dynamic>>(),
      );
    } else if (statistics['Stats'] is List<dynamic>) {
      statList.addAll(
        (statistics['Stats'] as List<dynamic>).whereType<Map<String, dynamic>>(),
      );
    } else if (statistics['stats'] is List<dynamic>) {
      statList.addAll(
        (statistics['stats'] as List<dynamic>).whereType<Map<String, dynamic>>(),
      );
    } else if (statistics['statistics'] is List<dynamic>) {
      statList.addAll(
        (statistics['statistics'] as List<dynamic>).whereType<Map<String, dynamic>>(),
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
            (teamData['statistics'] as List<dynamic>).whereType<Map<String, dynamic>>(),
          );
        }
      }
    }

    return statList;
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
      'Nm', 'nm', 'name', 'Label', 'label', 'Period', 'period', 'Ttl', 'ttl',
    ], '');
    final left = _readNestedDisplayValue(node, const [
      _F.homeScore, 'tr1', _F.homeTeam, 't1', 'home', 'Home', 'Left', 'left', 'S1', 's1',
    ], '');
    final right = _readNestedDisplayValue(node, const [
      _F.awayScore, 'tr2', _F.awayTeam, 't2', 'away', 'Away', 'Right', 'right', 'S2', 's2',
    ], '');
    return label.isNotEmpty && (left.isNotEmpty || right.isNotEmpty);
  }

  String _extractScoreboardHighlight(Map<String, dynamic> payload) {
    return _readNestedDisplayValue(payload, const [
      'Summary', 'summary', 'Desc', 'desc', 'Description', 'description',
      'StatusText', 'statusText', 'EventStatus', 'eventStatus',
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
      'm.StatusText', 'm.statusText', 'm.EventStatus', 'm.eventStatus',
      'm.Status', 'm.status', 'StatusText', 'statusText', 'Summary', 'summary',
    ], '');
    if (detailHighlight.isNotEmpty) {
      return detailHighlight;
    }

    final venue = _readNestedDisplayValue(detail, const ['m.Venue', 'm.venue'], '');
    if (venue.isNotEmpty) {
      return 'Venue: $venue';
    }

    return '';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Timeline
  // ─────────────────────────────────────────────────────────────────────────

  List<Map<String, String>> _extractSummaryTimeline({
    required Map<String, dynamic> scoreboard,
    required Map<String, dynamic> detail,
  }) {
    final mergedTimeline = _mergeTimelineItems([
      ..._extractScoreboardTimeline(scoreboard),
      ..._extractScoreboardTimeline(detail),
    ]);

    return _decorateTimelineItems(
      items: _filterPrimaryTimelineItems(mergedTimeline),
      scoreboard: scoreboard,
      detail: detail,
    );
  }

  List<Map<String, String>> _filterPrimaryTimelineItems(
      List<Map<String, String>> items,
      ) {
    return items.where((item) {
      final icon = (item['icon'] ?? '').trim();
      final badge = (item['badge'] ?? '').trim();
      final subtitle = (item['subtitle'] ?? '').toLowerCase();

      if (badge.isNotEmpty) return true;
      if (icon == 'goal' || icon == 'penalty_goal' || icon == 'yellow' ||
          icon == 'red' || icon == 'missed_penalty' || icon == 'own_goal') {
        return true;
      }
      if (subtitle.contains('goal') || subtitle.contains('card') ||
          subtitle.contains('penalty') || subtitle.contains('review') ||
          subtitle.contains('var')) {
        return true;
      }
      return false;
    }).toList();
  }

  List<Map<String, String>> _mergeTimelineItems(
      List<Map<String, String>> items,
      ) {
    final mergedByKey = <String, Map<String, String>>{};
    for (final item in items) {
      final key = _timelineCanonicalKey(item);
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

  String _timelineCanonicalKey(Map<String, String> item) {
    String normalize(String value) =>
        value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    final minute = normalize(item['minute'] ?? '');
    final side = normalize(item['side'] ?? '');
    final icon = normalize(item['icon'] ?? '');
    final title = normalize(item['title'] ?? '');
    final subtitle = normalize(item['subtitle'] ?? '');
    final titleParts = _splitTimelineDisplayName(title);
    final subtitleParts = _splitTimelineDisplayName(subtitle);
    final person = normalize(
      titleParts.$1.isNotEmpty ? titleParts.$1 : subtitleParts.$1,
    );
    return [minute, person, side, icon].join('|');
  }

  int _timelineMergeScore(Map<String, String> item) {
    var score = 0;
    final icon = item['icon'] ?? '';
    final subtitle = item['subtitle'] ?? '';
    final badge = item['badge'] ?? '';
    if (icon.isNotEmpty && icon != 'default') score += 4;
    if (badge.isNotEmpty) score += 3;
    if (subtitle.isNotEmpty) score += 2;
    if (subtitle.contains('[') && subtitle.contains(']')) score += 2;
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
    // Primary: parse from Incs (IncidentParser structure per tutorial)
    final incsEvents = _extractTimelineFromIncs(payload);
    final candidates = <Map<String, dynamic>>[];
    _collectTimelineNodes(payload, candidates);

    final seen = <String>{};
    final items = <Map<String, String>>[...incsEvents];
    for (final event in incsEvents) {
      seen.add(_timelineCanonicalKey(event));
    }

    for (final node in candidates) {
      final minute = _readNestedDisplayValue(node, const [
        _F.minute, 'min', 'Minute', 'minute', 'Time', 'time', 'Tm', 'tm',
      ], '');
      final title = _buildTimelineTitle(node);
      final subtitle = _buildTimelineSubtitle(node);

      if (minute.isEmpty || (title.isEmpty && subtitle.isEmpty)) continue;
      if (_looksLikeNumericTimelineTitle(title)) continue;

      final side = _inferTimelineSide(node);
      var icon = _inferTimelineIcon(node, subtitle);
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
      final key = _timelineCanonicalKey({
        'minute': minute, 'title': resolvedTitle,
        'subtitle': resolvedSubtitle, 'side': side, 'icon': icon,
      });
      if (!seen.add(key)) continue;

      items.add({
        'minute': minute, 'title': resolvedTitle,
        'subtitle': resolvedSubtitle, 'side': side, 'icon': icon,
      });
    }

    items.sort(
          (a, b) => _timelineMinuteSortValue(a['minute'] ?? '')
          .compareTo(_timelineMinuteSortValue(b['minute'] ?? '')),
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
            (a, b) => _timelineMinuteSortValue(b['minute'] ?? '')
            .compareTo(_timelineMinuteSortValue(a['minute'] ?? '')),
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
      _readNestedDisplayValue(scoreboard, const [_F.homeScore, 'tr1', 'T1Sc', 'm.Tr1'], ''),
      _readNestedDisplayValue(detail, const ['m.Tr1', _F.homeScore, 'homeScore'], ''),
      widget.match.homeScore,
    ]);
    final away = _firstNonEmpty([
      _readNestedDisplayValue(scoreboard, const [_F.awayScore, 'tr2', 'T2Sc', 'm.Tr2'], ''),
      _readNestedDisplayValue(detail, const ['m.Tr2', _F.awayScore, 'awayScore'], ''),
      widget.match.awayScore,
    ]);
    if (home.isEmpty && away.isEmpty) return '';
    return 'FT (${_displayScore(home)}-${_displayScore(away)})';
  }

  /// Uses Trh1/Trh2 (tutorial: HalfTimeHome/HalfTimeAway) as primary keys
  String _buildHalfTimeTimelineLabel(
      Map<String, dynamic> detail,
      Map<String, dynamic> scoreboard,
      List<Map<String, String>> timelineItems,
      ) {
    final explicitHome = _firstNonEmpty([
      // Primary per tutorial: Trh1 = HalfTimeHome, Trh2 = HalfTimeAway
      _readNestedDisplayValue(scoreboard, const [_F.halfTimeHome], ''),
      _readNestedDisplayValue(detail, const ['m.${_F.halfTimeHome}', _F.halfTimeHome], ''),
      // Fallbacks
      _readNestedDisplayValue(scoreboard, const ['Ht1', 'ht1', 'HT1', 'Ht.Tr1'], ''),
      _readNestedDisplayValue(detail, const ['m.Ht1', 'HT1', 'Ht1'], ''),
    ]);
    final explicitAway = _firstNonEmpty([
      _readNestedDisplayValue(scoreboard, const [_F.halfTimeAway], ''),
      _readNestedDisplayValue(detail, const ['m.${_F.halfTimeAway}', _F.halfTimeAway], ''),
      _readNestedDisplayValue(scoreboard, const ['Ht2', 'ht2', 'HT2', 'Ht.Tr2'], ''),
      _readNestedDisplayValue(detail, const ['m.Ht2', 'HT2', 'Ht2'], ''),
    ]);

    if (explicitHome.isNotEmpty || explicitAway.isNotEmpty) {
      return 'HT (${_displayScore(explicitHome)}-${_displayScore(explicitAway)})';
    }

    for (final item in timelineItems) {
      final minuteValue = _timelineMinuteSortValue(item['minute'] ?? '');
      if (minuteValue > 4599) continue;
      final score = _extractScoreFromTimelineText(item['subtitle'] ?? '');
      if (score != null) {
        return 'HT (${score.$1}-${score.$2})';
      }
    }

    return '';
  }

  (String, String)? _extractScoreFromTimelineText(String value) {
    final match = RegExp(r'\[(\d+)-(\d+)\]').firstMatch(value);
    if (match == null) return null;
    return (match.group(1) ?? '', match.group(2) ?? '');
  }

  String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Incs parser (IncidentParser fields per tutorial)
  // ─────────────────────────────────────────────────────────────────────────

  List<Map<String, String>> _extractTimelineFromIncs(
      Map<String, dynamic> payload,
      ) {
    // Tutorial: Incs = Incidents map; also check Incs-s
    final incs = payload[_F.incs] ?? payload['Incs-s'];
    if (incs is! Map) return const [];

    final events = <Map<String, String>>[];

    for (final entry in incs.entries) {
      final key = entry.key.toString();
      final eventList = entry.value;
      if (eventList is! List) continue;

      for (final rawEvent in eventList) {
        if (rawEvent is! Map) continue;

        final event = Map<String, dynamic>.from(rawEvent);
        // Min = Minute, MinEx = MinuteExtended per tutorial
        final minute = _formatTimelineMinute(
          _asInt(event[_F.minute]),
          _asInt(event[_F.minuteExt]),
        );
        if (minute.isEmpty) continue;

        final nestedIncs = event[_F.incs] is List
            ? event[_F.incs] as List
            : const [];
        final nestedMaps = nestedIncs
            .whereType<Map>()
            .map((nested) => Map<String, dynamic>.from(nested))
            .toList();
        final primaryNode = _resolvePrimaryTimelineIncident(event, nestedMaps);
        // Nm = 1 (home) or 2 (away) per IncidentParser tutorial
        final side = _timelineSideFromWebIncs(primaryNode ?? event);
        // Sc = Scores per tutorial
        final scoreText = _timelineScoreText(event[_F.scores]);
        String displayName = _timelinePersonName(primaryNode ?? event);
        int incidentType = _resolveTimelineIncidentType(
          event: event,
          primaryNode: primaryNode,
          nestedMaps: nestedMaps,
          incidentBucketKey: key,
        );

        // Filter out penalty score events (bucket 4) unless cards
        if (key == '4' &&
            incidentType != _F.itYellowCard &&
            incidentType != _F.itSecondYellow &&
            incidentType != _F.itRedCard) {
          continue;
        }

        // IT=63 = Assist per tutorial
        final assistPlayer = _resolveNestedIncidentByTypes(
          nestedMaps, const [_F.itAssist],
        );
        final assistName = assistPlayer == null
            ? ''
            : _timelinePersonName(assistPlayer);

        if (displayName.isEmpty) {
          final namedNode = nestedMaps.firstWhere(
                (item) => _timelinePersonName(item).isNotEmpty,
            orElse: () => <String, dynamic>{},
          );
          if (namedNode.isNotEmpty) displayName = _timelinePersonName(namedNode);
        }

        if (displayName.isEmpty) displayName = 'Unknown Event';

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
            _asInt(event[_F.minute]),
            _asInt(event[_F.minuteExt]),
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

  /// Nm = 1 (home team) or 2 (away team) per IncidentParser tutorial
  String _timelineSideFromWebIncs(Map<String, dynamic> event) {
    final inferred = _inferTimelineSide(event);
    if (inferred != 'neutral') return inferred;

    // Tutorial: Nm = Number (team side: 1=home, 2=away)
    final nm = _asInt(event[_F.incidentNm]);
    if (nm == 1) return 'home';
    if (nm == 2) return 'away';

    return 'neutral';
  }

  Map<String, dynamic>? _resolvePrimaryTimelineIncident(
      Map<String, dynamic> event,
      List<Map<String, dynamic>> nestedMaps,
      ) {
    final preferred = _resolveNestedIncidentByTypes(
      nestedMaps,
      const [
        _F.itRegularGoal, _F.itPenalty, _F.itMissedPenalty, _F.itOwnGoal,
        _F.itYellowCard, _F.itSecondYellow, _F.itRedCard, _F.itExtraTimeGoal,
      ],
    );
    if (preferred != null) return preferred;

    final withPerson = nestedMaps.firstWhere(
          (item) => _timelinePersonName(item).isNotEmpty,
      orElse: () => <String, dynamic>{},
    );
    if (withPerson.isNotEmpty) return withPerson;

    return event;
  }

  Map<String, dynamic>? _resolveNestedIncidentByTypes(
      List<Map<String, dynamic>> nestedMaps,
      List<int> types,
      ) {
    for (final type in types) {
      for (final nested in nestedMaps) {
        // IT = IncidentType per tutorial
        if (_asInt(nested[_F.incidentType]) == type) return nested;
      }
    }
    return null;
  }

  int _incidentTypeFromIcon(String icon) {
    switch (icon) {
      case 'yellow':        return _F.itYellowCard;
      case 'red':           return _F.itRedCard;
      case 'goal':          return _F.itRegularGoal;
      case 'penalty_goal':  return _F.itPenalty;
      case 'missed_penalty':return _F.itMissedPenalty;
      case 'own_goal':      return _F.itOwnGoal;
      default:              return 0;
    }
  }

  int _resolveTimelineIncidentTypeByIconHeuristics(
      List<Map<String, dynamic>> nodes,
      ) {
    for (final node in nodes) {
      // IR = IncidentReason is the primary per tutorial
      final subtitle = _readNestedDisplayValue(node, const [
        _F.incidentReason, 'Txt', 'txt', 'Desc', 'desc', 'Detail', 'detail',
        'Reason', 'reason', 'StatusText', 'statusText', 'TypeName', 'typeName',
        'TypeNm', 'typeNm', 'CardType', 'cardType', 'Card', 'card',
      ], '');
      final icon = _inferTimelineIcon(node, subtitle);
      final type = _incidentTypeFromIcon(icon);
      if (type != 0) return type;
    }
    return 0;
  }

  int _resolveTimelineIncidentType({
    required Map<String, dynamic> event,
    Map<String, dynamic>? primaryNode,
    required List<Map<String, dynamic>> nestedMaps,
    required String incidentBucketKey,
  }) {
    // IT = IncidentType per tutorial; check direct IT fields first
    final directTypes = <int>[
      _asInt(event[_F.incidentType]),
      if (primaryNode != null) _asInt(primaryNode[_F.incidentType]),
      ...nestedMaps.map((item) => _asInt(item[_F.incidentType])),
    ].where((type) => type > 0).toList();

    for (final type in directTypes) {
      if (_isSupportedTimelineIncidentType(type)) return type;
    }

    // IR = IncidentReason per tutorial – check text fields
    final combined = [
      _readNestedDisplayValue(event, const [
        _F.incidentReason, 'Txt', 'txt', 'Desc', 'desc', 'Detail', 'detail',
        'Reason', 'reason', 'StatusText', 'statusText',
      ], ''),
      if (primaryNode != null)
        _readNestedDisplayValue(primaryNode, const [
          _F.incidentReason, 'Txt', 'txt', 'Desc', 'desc', 'Detail', 'detail',
          'Reason', 'reason', 'StatusText', 'statusText',
        ], ''),
      ...nestedMaps.map(
            (item) => _readNestedDisplayValue(item, const [
          _F.incidentReason, 'Txt', 'txt', 'Desc', 'desc', 'Detail', 'detail',
          'Reason', 'reason', 'StatusText', 'statusText',
        ], ''),
      ),
    ].join(' ').toLowerCase();

    if (combined.contains('second yellow') || combined.contains('second yellow card')) return _F.itSecondYellow;
    if (combined.contains('yellow card') || combined.contains('yellow') || combined.contains('yc')) return _F.itYellowCard;
    if (combined.contains('red card') || combined.contains('red') || combined.contains('rc')) return _F.itRedCard;
    if (combined.contains('missed penalty')) return _F.itMissedPenalty;
    if (combined.contains('own goal')) return _F.itOwnGoal;
    if (combined.contains('penalty goal')) return _F.itPenalty;
    if (combined.contains('goal')) return _F.itRegularGoal;

    final iconHeuristicType = _resolveTimelineIncidentTypeByIconHeuristics([
      event,
      if (primaryNode != null) primaryNode,
      ...nestedMaps,
    ]);
    if (iconHeuristicType != 0) return iconHeuristicType;

    final bucketFallback = _timelineIncidentTypeFromBucket(incidentBucketKey);
    if (bucketFallback != 0) return bucketFallback;

    return _asInt((primaryNode ?? event)[_F.incidentType]);
  }

  int _timelineIncidentTypeFromBucket(String bucketKey) {
    switch (bucketKey) {
      case '1': return _F.itRegularGoal;
      case '2': return _F.itYellowCard;
      case '3': return _F.itRedCard;
      case '4': return _F.itYellowCard;
      case '5': return _F.itMissedPenalty;
      case '6': return _F.itOwnGoal;
      case '7': return _F.itYellowCard;
      case '8': return _F.itSecondYellow;
      case '9': return 49;
      default:  return 0;
    }
  }

  bool _isSupportedTimelineIncidentType(int type) {
    switch (type) {
      case _F.itRegularGoal:
      case _F.itPenalty:
      case _F.itMissedPenalty:
      case _F.itOwnGoal:
      case _F.itYellowCard:
      case _F.itSecondYellow:
      case _F.itRedCard:
      case _F.itUnknownCard:
      case _F.itExtraTimeGoal:
      case _F.itExtraTimeMissed:
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

  /// Pn = PlayerName (IncidentParser) per tutorial; also Shnm = PlayerFullName
  String _timelinePersonName(Map<String, dynamic> node) {
    return _readNestedDisplayValue(node, const [
      // Tutorial primary fields
      _F.playerFullNm,      // Shnm = Player Full Name
      _F.playerNameInc,     // Pn = Player Name (IncidentParser)
      // Fallbacks
      'pn', 'PlayerName', 'playerName', _F.playerStatName,
      'name', _F.participantNm, 'nm',
      'Player.Nm', 'Player.Pn', 'Player.name',
      'Person.Pn', 'Person.name',
    ], _fullTimelinePersonName(node));
  }

  String _fullTimelinePersonName(Map<String, dynamic> node) {
    final first = (node[_F.playerFirstNm] ?? '').toString().trim();
    final last = (node[_F.playerLastNm] ?? '').toString().trim();
    return '$first $last'.trim();
  }

  String _timelineIncidentLabel(int type) {
    switch (type) {
      case _F.itRegularGoal:    return 'Goal';
      case _F.itPenalty:        return 'Penalty Goal';
      case _F.itMissedPenalty:  return 'Missed Penalty';
      case _F.itOwnGoal:        return 'Own Goal';
      case _F.itYellowCard:     return 'Yellow Card';
      case _F.itSecondYellow:   return 'Second Yellow';
      case _F.itRedCard:        return 'Red Card';
      case _F.itExtraTimeGoal:  return 'Goal ET';
      default:                  return 'Event';
    }
  }

  /// IR = IncidentReason is the primary text field per tutorial
  String _buildTimelineIncidentSubtitle({
    required int incidentType,
    required String scoreText,
    required Map<String, dynamic> event,
    Map<String, dynamic>? primaryNode,
    required String assistName,
  }) {
    final source = primaryNode ?? event;
    // IR = IncidentReason (primary), then fallbacks
    final explicit = _readNestedDisplayValue(source, const [
      _F.incidentReason,    // IR = IncidentReason per tutorial
      'Txt', 'txt', 'Desc', 'desc', 'Detail', 'detail',
      'Reason', 'reason', 'St', 'st', 'StatusText', 'statusText',
    ], '');

    final normalizedExplicit = explicit.toLowerCase();
    if (normalizedExplicit.contains('var') ||
        normalizedExplicit.contains('review') ||
        normalizedExplicit.contains('not on pitch')) {
      return explicit;
    }

    if (assistName.trim().isNotEmpty &&
        (incidentType == _F.itRegularGoal ||
            incidentType == _F.itPenalty ||
            incidentType == _F.itExtraTimeGoal)) {
      return assistName.trim();
    }

    final fallbackLabel = _timelineIncidentLabel(incidentType);
    if (scoreText.isNotEmpty &&
        (incidentType == _F.itRegularGoal ||
            incidentType == _F.itPenalty ||
            incidentType == _F.itOwnGoal ||
            incidentType == _F.itExtraTimeGoal)) {
      return '$fallbackLabel $scoreText';
    }

    if (incidentType == _F.itYellowCard ||
        incidentType == _F.itSecondYellow ||
        incidentType == _F.itRedCard) {
      return explicit;
    }

    if (explicit.isNotEmpty) return explicit;
    return fallbackLabel;
  }

  /// IR = IncidentReason as primary badge text indicator per tutorial
  String _timelineBadgeLabel({
    required Map<String, dynamic> event,
    Map<String, dynamic>? primaryNode,
    required int incidentType,
  }) {
    final combined = [
      // IR = IncidentReason per tutorial
      _readNestedDisplayValue(event, const [
        _F.incidentReason, 'Txt', 'txt', 'Desc', 'desc',
        'Detail', 'detail', 'StatusText', 'statusText',
      ], ''),
      if (primaryNode != null)
        _readNestedDisplayValue(primaryNode, const [
          _F.incidentReason, 'Txt', 'txt', 'Desc', 'desc',
          'Detail', 'detail', 'StatusText', 'statusText',
        ], ''),
    ].join(' ').toLowerCase();

    if (combined.contains('var') || combined.contains('review')) return 'VAR';
    if (incidentType == _F.itMissedPenalty) return 'MISS';
    return '';
  }

  String _timelineIconFromIncidentType(int type) {
    switch (type) {
      case _F.itRegularGoal:   return 'goal';
      case _F.itPenalty:       return 'penalty_goal';
      case _F.itMissedPenalty: return 'missed_penalty';
      case _F.itOwnGoal:       return 'own_goal';
      case _F.itYellowCard:
      case _F.itSecondYellow:
      case _F.itUnknownCard:
      case _F.itExtraTimeMissed:
        return 'yellow';
      case _F.itRedCard:
      case 49:
      case 50:
        return 'red';
      case _F.itExtraTimeGoal: return 'goal';
      default:                 return 'default';
    }
  }

  Color _timelineIconColor(String iconType, Color accentColor) {
    switch (iconType) {
      case 'goal':            return const Color(0xFF22C55E);
      case 'penalty_goal':    return const Color(0xFF15803D);
      case 'missed_penalty':  return const Color(0xFFEF4444);
      case 'own_goal':        return const Color(0xFFDC2626);
      case 'yellow':          return const Color(0xFFFACC15);
      case 'red':             return const Color(0xFFEF4444);
      default:                return accentColor;
    }
  }

  String _timelineIconSymbol(String iconType) {
    switch (iconType) {
      case 'goal':            return '⚽';
      case 'penalty_goal':    return '⚽P';
      case 'missed_penalty':  return '✖P';
      case 'own_goal':        return 'OG';
      case 'yellow':
      case 'red':             return '█';
      default:                return '';
    }
  }

  String _formatTimelineMinute(int minute, int minuteExtra) {
    if (minute <= 0 && minuteExtra <= 0) return '';
    if (minuteExtra > 0) return '$minute+$minuteExtra\'';
    return '$minute\'';
  }

  int _timelineSortKey(int minute, int minuteExtra) => (minute * 100) + minuteExtra;

  int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  void _collectTimelineNodes(
      dynamic current,
      List<Map<String, dynamic>> candidates,
      ) {
    if (current is Map<String, dynamic>) {
      if (_looksLikeTimelineNode(current)) candidates.add(current);
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
      _F.minute, 'min', 'Minute', 'minute', 'Time', 'time', 'Tm', 'tm',
    ], '');
    final title = _buildTimelineTitle(node);
    final subtitle = _buildTimelineSubtitle(node);
    return minute.isNotEmpty && (title.isNotEmpty || subtitle.isNotEmpty);
  }

  /// Shnm = PlayerFullName, Pn = PlayerName per tutorial
  String _buildTimelineTitle(Map<String, dynamic> node) {
    final playerName = _readNestedDisplayValue(node, const [
      _F.playerFullNm,    // Shnm = Player Full Name per tutorial
      _F.playerNameInc,   // Pn = Player Name (IncidentParser) per tutorial
      'pn', 'PlayerName', 'playerName', _F.playerStatName,
      'name', 'Player.Nm', 'Player.Pn', 'Player.name',
      'Person.Pn', 'Person.name',
    ], '');
    if (playerName.isNotEmpty) return playerName;

    final first = _readNestedDisplayValue(node, const [_F.playerFirstNm, 'fn'], '');
    final last = _readNestedDisplayValue(node, const [_F.playerLastNm, 'ln'], '');
    final fullName = '$first $last'.trim();
    if (fullName.isNotEmpty) return fullName;

    return _readNestedDisplayValue(node, const [
      'Title', 'title', 'Text', 'text', 'Event', 'event',
      'TypeNm', 'typeName', 'IncidentType', 'incidentType',
      'Type', 'type', 'Desc', 'desc', 'Detail', 'detail',
      'Reason', 'reason', 'StatusText', 'statusText',
    ], '');
  }

  bool _looksLikeNumericTimelineTitle(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    return int.tryParse(trimmed) != null;
  }

  /// IR = IncidentReason (primary text field per tutorial)
  String _buildTimelineSubtitle(Map<String, dynamic> node) {
    final primary = _readNestedDisplayValue(node, const [
      _F.incidentReason,  // IR = IncidentReason per tutorial (primary)
      'Desc', 'desc', 'Text', 'text', 'Type', 'type',
      'TypeNm', 'typeName', 'IncidentType', 'incidentType',
      'Detail', 'detail', 'Reason', 'reason', 'StatusText', 'statusText',
    ], '');
    final team = _readNestedDisplayValue(node, const [
      _F.teamName, 'tnm', 'TeamName', 'teamName', 'CompetitorName', 'competitorName',
    ], '');
    final score = _readNestedDisplayValue(node, const [
      'Score', 'score', 'Scr', 'scr', 'Result', 'result',
    ], '');

    final parts = <String>[];
    if (primary.isNotEmpty) parts.add(primary);
    if (team.isNotEmpty && !parts.any((part) => part.toLowerCase().contains(team.toLowerCase()))) {
      parts.add(team);
    }
    if (score.isNotEmpty && !parts.any((part) => part.toLowerCase().contains(score.toLowerCase()))) {
      parts.add(score);
    }

    return parts.join(' • ');
  }

  String _inferTimelineSide(Map<String, dynamic> node) {
    final raw = _readNestedDisplayValue(node, const [
      'Side', 'side', 'TeamSide', 'teamSide', 'Team', 'team',
      'Competitor', 'competitor', 'CompetitorName', 'competitorName',
      'TeamName', 'teamName', _F.teamName, 'tnm', _F.teamId, 'tid',
    ], '').toLowerCase();

    if (raw.contains('home') || raw == 'h' || raw == 'hometeam' ||
        raw == 'local' || raw == '1' || raw == widget.match.homeTeamId.toLowerCase()) {
      return 'home';
    }
    if (raw.contains('away') || raw == 'a' || raw == 'awayteam' ||
        raw == 'visitor' || raw == '2' || raw == widget.match.awayTeamId.toLowerCase()) {
      return 'away';
    }
    if (raw.contains(widget.match.homeTeam.toLowerCase())) return 'home';
    if (raw.contains(widget.match.awayTeam.toLowerCase())) return 'away';

    return 'neutral';
  }

  /// IR = IncidentReason is the primary icon inference field per tutorial
  String _inferTimelineIcon(Map<String, dynamic> node, String subtitle) {
    final fieldsList = [
      subtitle,
      _readNestedDisplayValue(node, const [
        _F.incidentReason,  // IR = IncidentReason per tutorial (primary)
        'Type', 'type', 'IncidentType', 'incidentType',
        'Desc', 'desc', 'Txt', 'txt', 'Text', 'text',
        'TypeName', 'typeName', 'TypeNm', 'typeNm',
        'CardType', 'cardType', 'Card', 'card',
        'Period', 'period', 'Label', 'label',
      ], ''),
    ];

    final combined = fieldsList.join(' ').toLowerCase();

    if (combined.contains('second yellow') || combined.contains('second yellow card')) return 'yellow';
    if (combined.contains('yellow card') || combined.contains('yellow') ||
        combined.contains('yc') || combined.contains('card 2')) {
      return 'yellow';
    }
    if (combined.contains('red card') || combined.contains('red') ||
        combined.contains('rc') || combined.contains('card 1')) {
      return 'red';
    }
    if (combined.contains('missed penalty')) return 'missed_penalty';
    if (combined.contains('own goal')) return 'own_goal';
    if (combined.contains('penalty goal') || combined.contains('penalty')) return 'penalty_goal';
    if (combined.contains('goal')) return 'goal';

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

  // ─────────────────────────────────────────────────────────────────────────
  // Status helpers (expanded per tutorial Eps / Esid mappings)
  // ─────────────────────────────────────────────────────────────────────────

  /// Maps Eps string values per tutorial BasicMatchParser
  String _statusLabel(String status) {
    const statusMap = {
      'NS':    'Not Started',
      '1H':    '1st Half',
      'HT':    'Half Time',
      '2H':    '2nd Half',
      'ET':    'Extra Time',
      'EH':    'Extra Time 1st Half',
      'EHT':   'Extra Time Half Time',
      'E2H':   'Extra Time 2nd Half',
      'PEN':   'Penalties',
      'FT':    'Full Time',
      'AET':   'After Extra Time',
      'AP':    'After Penalties',
      'Postp': 'Postponed',
      'Cancl': 'Cancelled',
      'Susp':  'Suspended',
      'Awd':   'Awarded',
      'WO':    'Walkover',
      'Aban':  'Abandoned',
      'LIVE':  'Live',
    };
    return statusMap[status] ?? status;
  }

  /// Maps Esid numeric values per tutorial
  String _esidLabel(int esid) {
    switch (esid) {
      case _F.esidNotStarted: return 'Not Started';
      case _F.esidFirstHalf:  return '1st Half';
      case _F.esidHalfTime:   return 'Half Time';
      case _F.esidSecondHalf: return '2nd Half';
      case _F.esidETFirst:    return 'Extra Time 1st Half';
      case _F.esidETHalfTime: return 'Extra Time HT';
      case _F.esidETSecond:   return 'Extra Time 2nd Half';
      case _F.esidPenalties:  return 'Penalties';
      case _F.esidFullTime:   return 'Full Time';
      case _F.esidPostponed:  return 'Postponed';
      case _F.esidCancelled:  return 'Cancelled';
      case _F.esidAbandoned:  return 'Abandoned';
      case _F.esidSuspended:  return 'Suspended';
      default:                return 'Unknown';
    }
  }

  Color _getStatusColor() {
    switch (widget.match.status) {
      case '1H':
      case '2H':
      case 'ET':
      case 'EH':
      case 'E2H':
      case 'PEN':
      case 'LIVE':
        return Colors.red.shade400;
      case 'HT':
      case 'EHT':
        return Colors.orange.shade400;
      case 'FT':
      case 'AET':
      case 'AP':
        return Colors.green.shade400;
      default:
        return Colors.white.withOpacity(0.6);
    }
  }

  String _getStatusBadgeText() {
    switch (widget.match.status) {
      case 'NS':    return 'UPCOMING';
      case '1H':    return 'LIVE · 1H';
      case 'HT':    return 'HALF TIME';
      case '2H':    return 'LIVE · 2H';
      case 'ET':
      case 'EH':
      case 'E2H':   return 'LIVE · ET';
      case 'EHT':   return 'ET HALF TIME';
      case 'PEN':   return 'LIVE · PEN';
      case 'FT':    return 'ENDED';
      case 'AET':   return 'ENDED · AET';
      case 'AP':    return 'ENDED · AP';
      case 'LIVE':  return 'LIVE';
      case 'Postp': return 'POSTPONED';
      case 'Cancl': return 'CANCELLED';
      case 'Susp':  return 'SUSPENDED';
      case 'Aban':  return 'ABANDONED';
      default:      return widget.match.status;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Lineups tab
  // ─────────────────────────────────────────────────────────────────────────

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
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Match ID: ${widget.match.eid}',
                    style: TextStyle(color: Colors.yellow.shade600, fontSize: 11, fontFamily: 'monospace'),
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
                        Icon(Icons.info_outline, color: Colors.orange.shade400, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'No lineup data',
                          style: TextStyle(color: Colors.orange.shade400, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Lineup information is not available for this match yet.',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• The match hasn\'t started yet\n• The API doesn\'t have lineup data\n• The match ended without recording lineups',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
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
                            style: TextStyle(color: Colors.yellow.shade600, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Match ID: ${widget.match.eid}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
                          ),
                          Text(
                            'Category: ${widget.category}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
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
              aspectRatio: MediaQuery.of(context).size.width < 760 ? 9 / 16 : 16 / 9,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 760;
                  final fieldSize = Size(constraints.maxWidth, constraints.maxHeight);
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: FootballFieldPainter(isCompact: isCompact),
                        ),
                      ),
                      ..._buildTeamFormationNodes(homeTeam, isHome: true, fieldSize: fieldSize, isCompact: isCompact),
                      ..._buildTeamFormationNodes(awayTeam, isHome: false, fieldSize: fieldSize, isCompact: isCompact),
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

  Map<String, dynamic> _parseTeamLineup(Map<String, dynamic> lineups, bool isHome) {
    // Tutorial: Lu = Lineups array; try structured parse first
    if (lineups[_F.lineups] is List<dynamic>) {
      final parsed = _parseStructuredTeamLineup(lineups, isHome);
      if (parsed.isNotEmpty) return parsed;
    }

    final starters = <Map<String, dynamic>>[];
    final bench = <Map<String, dynamic>>[];
    final injuries = <Map<String, dynamic>>[];
    final everyone = <Map<String, dynamic>>[];

    if (lineups.containsKey('pl') && lineups['pl'] is List) {
      final allPlayers = lineups['pl'] as List<dynamic>;
      for (final p in allPlayers) {
        if (p is Map<String, dynamic>) {
          if (_playerBelongsToTeam(p, isHome)) everyone.add(p);
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
    final dedupedBench = _dedupePlayers(bench)
        .where((player) => !_containsPlayer(dedupedStarters, player))
        .toList();
    final dedupedInjuries = _dedupePlayers(injuries)
        .where((player) =>
    !_containsPlayer(dedupedStarters, player) &&
        !_containsPlayer(dedupedBench, player))
        .toList();

    String? formationStr;
    if (lineups.containsKey(isHome ? 'homeFormation' : 'awayFormation')) {
      formationStr = lineups[isHome ? 'homeFormation' : 'awayFormation']?.toString();
    }

    return {
      'players': dedupedStarters,
      'bench': dedupedBench,
      'injuries': dedupedInjuries,
      'rows': _buildFormationRows(dedupedStarters, formationStr ?? ''),
      'formation': formationStr ?? '',
    };
  }

  /// Lu = Lineups, Ps = Players, Fo = StandingFormations (primary per tutorial)
  /// IS = InjuredSuspended, PosA = PlayerActualPosition per tutorial
  Map<String, dynamic> _parseStructuredTeamLineup(
      Map<String, dynamic> lineups,
      bool isHome,
      ) {
    // Tutorial: Lu = Lineups array
    final lu = lineups[_F.lineups];
    if (lu is! List<dynamic> || lu.length < 2) return const {};

    final index = isHome ? 0 : 1;
    final team = lu[index];
    if (team is! Map<String, dynamic>) return const {};

    // Ps = Players per tutorial
    final allPlayers = _extractPlayerMapsFromDynamic(team[_F.lineupPs]);

    // PosA = PlayerActualPosition (primary), Pos = PlayerPosition (fallback)
    // Pos == 5 means bench per API convention
    final starters = allPlayers.where((player) {
      final pos = _asInt((player[_F.playerPos] ?? '0').toString());
      return pos != 5;
    }).toList();

    final bench = allPlayers.where((player) {
      final pos = _asInt((player[_F.playerPos] ?? '0').toString());
      return pos == 5;
    }).toList();

    // IS = InjuredSuspended per tutorial
    final injuries = _extractPlayerMapsFromDynamic(team[_F.lineupIS]);

    // Fo = StandingFormations per tutorial (primary); fallback to other keys
    // Replace the formation reading block:
    String formation;
    final foRaw = team[_F.lineupFo];
    if (foRaw is List) {
      // Fo = [4, 3, 3] array per API
      final counts = foRaw
          .map((e) => _asInt(e))
          .where((v) => v > 0)
          .toList();
      formation = counts.isNotEmpty
          ? counts.join('-')
          : _inferFormationFromPlayers(starters);
    } else if (foRaw is String && foRaw.isNotEmpty) {
      formation = foRaw;
    } else {
      formation = _inferFormationFromPlayers(starters);
    }

    final subsHistory = _buildLineupSubHistory(lineups, isHome: isHome);
    final starterCopies = starters.take(11).map(_copyPlayerMap).toList();
    final benchCopies = bench.map(_copyPlayerMap).toList();
    final injuryCopies = injuries.map(_copyPlayerMap).toList();

    for (final player in starterCopies) {
      final subOutMin = _getStarterSubOutTime(player, subsHistory);
      if (subOutMin != null) player['subOutMin'] = subOutMin;
    }

    for (final player in benchCopies) {
      final subInData = _getBenchSubInData(player, subsHistory);
      if (subInData != null) player.addAll(subInData);
    }

    return {
      'players': starterCopies,
      'bench': benchCopies,
      'injuries': injuryCopies,
      'rows': _buildFormationRows(starterCopies, formation),
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
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (alignEnd)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  teamName,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                if (formation.trim().isNotEmpty)
                  Text(
                    formation,
                    style: TextStyle(color: Colors.white.withOpacity(0.68), fontSize: 11),
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
              style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w800),
            ),
          )
              : Image.network(
            teamImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Center(
              child: Text(
                _initials(teamName),
                style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w800),
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
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                if (formation.trim().isNotEmpty)
                  Text(
                    formation,
                    style: TextStyle(color: Colors.white.withOpacity(0.68), fontSize: 11),
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
        (teamData['players'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

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
            style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ];
    }

    final List<List<Map<String, dynamic>>> rows = (() {
      final raw = teamData['rows'];
      if (raw is List && raw.isNotEmpty) {
        return raw
            .whereType<List>()
            .map((row) => row.whereType<Map<String, dynamic>>().toList())
            .where((row) => row.isNotEmpty)
            .toList();
      }
      return _buildFormationRows(players, teamData['formation']?.toString() ?? '');
    })();

    final totalRows = math.max(rows.length, 1);
    final widgets = <Widget>[];

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final rowPlayers = rows[rowIndex];
      // Remove depthT here — it's not used in compact left calculation

      for (var playerIndex = 0; playerIndex < rowPlayers.length; playerIndex++) {
        final player = rowPlayers[playerIndex];
        final spreadFactor = rowPlayers.length == 1
            ? 0.5
            : (playerIndex + 1) / (rowPlayers.length + 1);

        const cardWidth = 80.0;

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
                ? (0.08 + (0.36 * (totalRows == 1 ? 0.5 : rowIndex / (totalRows - 1))))
                : (0.92 - (0.36 * (totalRows == 1 ? 0.5 : rowIndex / (totalRows - 1))))) -
            (cardWidth / 2));

        widgets.add(
          Positioned(
            left: left,
            top: top,
            width: cardWidth,
            child: _buildFormationPlayerCard(
              player,
              isHome: isHome,
              subOutMin: (player['subOutMin'] ?? '').toString().trim().isEmpty
                  ? null
                  : (player['subOutMin'] ?? '').toString().trim(),
            ),
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

    // Home: rows go from 5% → 47% of field height (GK near top, FWD near center)
    // Away: rows go from 95% → 53% of field height (GK near bottom, FWD near center)
    final depth = isHome
        ? (0.12 + (0.35 * depthT))
        : (0.95 - (0.35 * depthT));

    return (fieldHeight * depth) - 36;
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
    if (players.isEmpty) return const [];

    List<int> counts = formation      // <-- List<int> not final, so skip() works
        .split(RegExp(r'[^0-9]+'))
        .where((part) => part.trim().isNotEmpty)
        .map((part) => int.tryParse(part) ?? 0)
        .where((value) => value > 0)
        .toList();

    // If Fo includes the goalkeeper as '1' (e.g. "1-4-3-3"), drop it —
    // GK row is always built separately as [players.first]
    // More precise GK strip — only drop if sum of remaining still covers all outfield
    if (counts.isNotEmpty && counts.first == 1 && players.length > 1) {
      final remaining = counts.skip(1).toList();
      final remainingSum = remaining.fold<int>(0, (s, v) => s + v);
      // Only drop the leading 1 if the rest accounts for the outfield players
      if (remainingSum >= players.length - 1) {
        counts = remaining;
      }
    }

    final rows = <List<Map<String, dynamic>>>[[players.first]];
    final outfield = players.skip(1).toList();

    if (outfield.isEmpty) return rows;

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
      normalizedCounts[normalizedCounts.length - 1] += outfield.length - assigned;
    }

    var cursor = 0;
    for (final count in normalizedCounts) {
      if (cursor >= outfield.length) break;
      rows.add(outfield.skip(cursor).take(count).toList());
      cursor += count;
    }

    if (cursor < outfield.length) rows.add(outfield.skip(cursor).toList());

    return rows.where((row) => row.isNotEmpty).toList();
  }


// 1. Update _buildTeamFormationNodes to pass subOutMin as separate param

  Widget _buildFormationPlayerCard(
      Map<String, dynamic> player, {
        required bool isHome,
        String? subOutMin,
      }) {
    final shortName = _lineupPlayerShortName(player);
    final number = _lineupPlayerNumber(player);
    final rating = _lineupPlayerRating(player);
    final shirtColor = isHome ? const Color(0xFFFFC31A) : const Color(0xFF3B2A63);
    final numberColor = isHome ? Colors.black : Colors.white;
    final numberLength = number.trim().length;
    final badgeSize = numberLength >= 3 ? 28.0 : 32.0;
    final numberFontSize = numberLength >= 3 ? 8.0 : 10.0;

    final hasRating = rating.isNotEmpty && rating != '0';
    final ratingValue = double.tryParse(rating) ?? 0;
    final ratingColor = ratingValue >= 7
        ? const Color(0xFF16A34A)
        : ratingValue < 6
        ? const Color(0xFFEF4444)
        : const Color(0xFFF97316);

    final hasSubOut = subOutMin != null && subOutMin.isNotEmpty;

    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circle with rating badge overlapping top-right
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Shirt circle
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
                      blurRadius: 6,
                      offset: const Offset(0, 3),
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

              // Rating badge — overlaps top of circle
              if (hasRating)
                Positioned(
                  top: -8,
                  right: isHome ? -4 : null,
                  left: isHome ? null : -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: ratingColor,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.white, width: 0.5),
                    ),
                    child: Text(
                      rating,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 3),

          // Name — plain white text, no background box
          Text(
            shortName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                ),
              ],
            ),
          ),

          // Sub-out badge — sits below name
          if (hasSubOut) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red.shade500,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_downward_rounded, size: 7, color: Colors.white),
                  const SizedBox(width: 1),
                  Text(
                    "+$subOutMin'",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
          (homeTeam['bench'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
          awayPlayers:
          (awayTeam['bench'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
        ),
        const SizedBox(height: 16),
        _buildLineupSplitSection(
          title: 'INJURIES',
          homeLabel: 'HOME',
          awayLabel: 'AWAY',
          homePlayers:
          (homeTeam['injuries'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
          awayPlayers:
          (awayTeam['injuries'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
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
              label: homeLabel, players: homePlayers, isHome: true, emptyLabel: emptyLabel,
            );
            final awayColumn = _buildLineupDetailColumn(
              label: awayLabel, players: awayPlayers, isHome: false, emptyLabel: emptyLabel,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0),
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
                        height: math.max(240, math.max(homePlayers.length, awayPlayers.length) * 56).toDouble(),
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
      crossAxisAlignment: isHome ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.9),
        ),
        const SizedBox(height: 10),
        if (players.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              emptyLabel,
              textAlign: isHome ? TextAlign.left : TextAlign.right,
              style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12),
            ),
          )
        else
          Column(
            children: players.map((player) => _buildLineupDetailRow(player, isHome: isHome)).toList(),
          ),
      ],
    );
  }

  Widget _buildLineupDetailRow(Map<String, dynamic> player, {required bool isHome}) {
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
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );

    final textBlock = Expanded(
      child: Column(
        crossAxisAlignment: isHome ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            name,
            textAlign: isHome ? TextAlign.left : TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          if (position.isNotEmpty)
            Text(
              position,
              textAlign: isHome ? TextAlign.left : TextAlign.right,
              style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 10, fontWeight: FontWeight.w600),
            ),
          if (details.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                details,
                textAlign: isHome ? TextAlign.left : TextAlign.right,
                style: TextStyle(color: Colors.greenAccent.shade400, fontSize: 10, fontWeight: FontWeight.w700),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Statistics tab
  // ─────────────────────────────────────────────────────────────────────────

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
                  Text('Error loading statistics', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  const SizedBox(height: 16),
                  Text('Match ID: ${widget.match.eid}', style: TextStyle(color: Colors.yellow.shade600, fontSize: 11, fontFamily: 'monospace')),
                ],
              ),
            ),
          );
        }

        final statistics = snapshot.data ?? {};
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
                        Icon(Icons.info_outline, color: Colors.orange.shade400, size: 20),
                        const SizedBox(width: 8),
                        Text('No statistics data available yet', style: TextStyle(color: Colors.orange.shade400, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Match statistics are not available for this match yet.', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                    const SizedBox(height: 8),
                    Text('• The match is still in progress\n• The match hasn\'t started yet\n• The API doesn\'t have statistics data', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Debug Info', style: TextStyle(color: Colors.yellow.shade600, fontSize: 10, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Match ID: ${widget.match.eid}', style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
                          Text('Category: ${widget.category}', style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
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
          children: [_buildStatisticsSection(statistics), const SizedBox(height: 24)],
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
            const Text('Match Statistics', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text('No statistics data available yet', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
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
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Match Statistics',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0),
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: statRows.map((stat) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildMatchStatBarRow(stat),
              )).toList(),
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
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
            ),
            Expanded(
              child: Text(
                _formatStatDisplayValue(awayText),
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
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

  /// Full stat key set per tutorial Match Stats keys
  List<Map<String, String>> _extractMatchStatComparisonRows(
      Map<String, dynamic> statistics,
      ) {
    // Per tutorial: Pss=Possession, Shon=ShotsOnTarget, Shof=ShotsOffTarget,
    // Sht=TotalShots, Cos=Corners, Fls=Fouls, Ycs=YellowCards, YRcs=RedCards,
    // Ofs=Offsides, Svs=Saves, Atk=Attacks, Dngs=DangerousAttacks
    final selectedKeys = <String, String>{
      _F.statPossession:    'Possession (%)',
      _F.statShotsOn:       'Shots on Target',
      _F.statShotsOff:      'Shots off Target',
      _F.statTotalShots:    'Total Shots',
      _F.statCorners:       'Corners',
      _F.statFouls:         'Fouls',
      _F.statYellowCards:   'Yellow Cards',
      _F.statRedCards:      'Red Cards',
      _F.statOffsides:      'Offsides',
      _F.statSaves:         'Saves',
      _F.statAttacks:       'Attacks',
      _F.statDangerousAtk:  'Dangerous Attacks',
    };

    final statList = _extractStatisticsTeamStatNodes(statistics);
    if (statList.length < 2) return const [];

    final homeStats = statList[0];
    final awayStats = statList[1];

    return selectedKeys.entries
        .map((entry) => {
      'label': entry.value,
      'home': _readDisplayValue(homeStats, [entry.key], '0'),
      'away': _readDisplayValue(awayStats, [entry.key], '0'),
    })
    // Filter rows where both values are 0
        .where((row) {
      final h = double.tryParse(row['home'] ?? '0') ?? 0;
      final a = double.tryParse(row['away'] ?? '0') ?? 0;
      return h != 0 || a != 0;
    })
        .toList();
  }

  String _formatStatDisplayValue(String raw) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? '0' : trimmed;
  }

  Widget _buildPlayerStatsTab() {
    final hasAnyTeamId =
        widget.match.homeTeamId.trim().isNotEmpty || widget.match.awayTeamId.trim().isNotEmpty;

    if (!hasAnyTeamId) {
      return _buildInlineInfoCard(
        title: 'Player Stats',
        message: 'This match does not include team IDs, so player stats cannot be loaded.',
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
        final homePayload = payloads.isNotEmpty ? payloads[0] : const <String, dynamic>{};
        final awayPayload = payloads.length > 1 ? payloads[1] : const <String, dynamic>{};
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
                Expanded(child: Text(teamName, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          if (players.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(fallbackMessage, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
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
                            width: 28, height: 28,
                            decoration: BoxDecoration(color: accentColor.withOpacity(0.18), borderRadius: BorderRadius.circular(8)),
                            alignment: Alignment.center,
                            child: Text(rank, style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w800)),
                          ),
                        if (rank.isNotEmpty) const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                              if (secondary.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(secondary, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(value.isEmpty ? '-' : value, style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.w800)),
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

  /// Pnm = PlayerName, Rnk = PlayerRank per CompetitionStatsParser tutorial
  List<Map<String, String>> _extractPlayerStatRows(Map<String, dynamic> payload) {
    final candidates = <Map<String, dynamic>>[];
    _collectPlayerStatNodes(payload, candidates);

    final seen = <String>{};
    final rows = <Map<String, String>>[];

    for (final node in candidates) {
      // Tutorial CompetitionStatsParser: Pnm = PlayerName (primary), Nm = fallback
      final name = _readNestedDisplayValue(node, const [
        _F.playerStatName,  // Pnm = PlayerName per tutorial
        _F.participantNm,   // Nm = Name fallback
        'nm', 'name', 'PlayerName', 'playerName', 'player.name',
      ], '');
      final value = _readNestedDisplayValue(node, const [
        'Stat', 'stat', 'Value', 'value', 'Val', 'val',
        'Total', 'total', 'Cnt', 'cnt', 'S', 's',
        // Tutorial: Scrs = PlayerPointsList
        'Scrs', 'scrs',
      ], '');

      if (name.isEmpty || value.isEmpty) continue;

      // Tutorial: Rnk = PlayerRank per CompetitionStatsParser
      final rank = _readNestedDisplayValue(node, const [
        _F.playerRank,      // Rnk = PlayerRank per tutorial
        'Rank', 'rank', 'Pos', 'pos',
      ], '');
      final secondary = _readNestedDisplayValue(node, const [
        'Position', 'position', 'Team', 'team', 'Role', 'role', 'player.position',
        _F.teamName,        // Tnm = TeamName per tutorial
      ], '');

      final identity = '${name.toLowerCase()}|${value.toLowerCase()}|${rank.toLowerCase()}';
      if (!seen.add(identity)) continue;

      rows.add({'label': name, 'value': value, 'rank': rank, 'secondary': secondary});
    }

    rows.sort((a, b) {
      final aRank = int.tryParse(a['rank'] ?? '') ?? 9999;
      final bRank = int.tryParse(b['rank'] ?? '') ?? 9999;
      if (aRank != bRank) return aRank.compareTo(bRank);
      final aValue = num.tryParse(a['value'] ?? '') ?? -1;
      final bValue = num.tryParse(b['value'] ?? '') ?? -1;
      return bValue.compareTo(aValue);
    });

    return rows;
  }

  void _collectPlayerStatNodes(dynamic current, List<Map<String, dynamic>> candidates) {
    if (current is Map<String, dynamic>) {
      if (_looksLikePlayerStatNode(current)) candidates.add(current);
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
      _F.playerStatName, _F.participantNm, 'nm', 'name', 'PlayerName', 'playerName', 'player.name',
    ], '');
    final value = _readNestedDisplayValue(node, const [
      'Stat', 'stat', 'Value', 'value', 'Val', 'val', 'Total', 'total', 'Cnt', 'cnt', 'S', 's',
    ], '');
    return name.isNotEmpty && value.isNotEmpty;
  }

  Widget _buildTeamStatsTab() {
    final hasAnyTeamId =
        widget.match.homeTeamId.trim().isNotEmpty || widget.match.awayTeamId.trim().isNotEmpty;

    if (!hasAnyTeamId) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInlineInfoCard(
            title: 'Team Stats',
            message: 'This match does not include team IDs, so team stats cannot be loaded.',
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
        final homePayload = payloads.isNotEmpty ? payloads[0] : const <String, dynamic>{};
        final awayPayload = payloads.length > 1 ? payloads[1] : const <String, dynamic>{};
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

        final mergedLabels = <String>{...homeStats.keys, ...awayStats.keys}.toList()..sort();

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
                        Expanded(child: _buildTeamStatsHeader(teamName: widget.match.homeTeam, teamImage: widget.match.homeTeamImage, accentColor: Colors.yellow.shade600, alignEnd: false)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTeamStatsHeader(teamName: widget.match.awayTeam, teamImage: widget.match.awayTeamImage, accentColor: Colors.blue.shade300, alignEnd: true)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Expanded(child: Text(homeValue, style: TextStyle(color: Colors.yellow.shade600, fontSize: 13, fontWeight: FontWeight.w700))),
                              Expanded(child: Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.76), fontSize: 12, fontWeight: FontWeight.w600))),
                              Expanded(child: Text(awayValue, textAlign: TextAlign.right, style: TextStyle(color: Colors.blue.shade300, fontSize: 13, fontWeight: FontWeight.w700))),
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
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (alignEnd)
          Expanded(child: Text(teamName, textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
        if (alignEnd) const SizedBox(width: 10),
        _buildMiniTeamBadge(teamName, teamImage, accentColor),
        if (!alignEnd) const SizedBox(width: 10),
        if (!alignEnd)
          Expanded(child: Text(teamName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
      ],
    );
  }

  Map<String, String> _extractTeamStatRows(Map<String, dynamic> payload) {
    final candidates = <Map<String, dynamic>>[];
    _collectTeamStatNodes(payload, candidates);

    final rows = <String, String>{};
    for (final node in candidates) {
      final label = _readNestedDisplayValue(node, const [
        _F.participantNm, 'nm', 'name', 'StatName', 'statName', 'Label', 'label', 'Ttl', 'ttl',
      ], '');
      final value = _readNestedDisplayValue(node, const [
        'Stat', 'stat', 'Value', 'value', 'Val', 'val', 'Total', 'total', 'Cnt', 'cnt', 'S', 's',
      ], '');
      if (label.isEmpty || value.isEmpty) continue;
      rows.putIfAbsent(label, () => value);
    }
    return rows;
  }

  void _collectTeamStatNodes(dynamic current, List<Map<String, dynamic>> candidates) {
    if (current is Map<String, dynamic>) {
      if (_looksLikeTeamStatNode(current)) candidates.add(current);
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
      _F.participantNm, 'nm', 'name', 'StatName', 'statName', 'Label', 'label', 'Ttl', 'ttl',
    ], '');
    final value = _readNestedDisplayValue(node, const [
      'Stat', 'stat', 'Value', 'value', 'Val', 'val', 'Total', 'total', 'Cnt', 'cnt', 'S', 's',
    ], '');
    return label.isNotEmpty && value.isNotEmpty;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // H2H tab
  // ─────────────────────────────────────────────────────────────────────────

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
                  Text('Error loading H2H history', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  const SizedBox(height: 16),
                  Text('Match ID: ${widget.match.eid}', style: TextStyle(color: Colors.yellow.shade600, fontSize: 11, fontFamily: 'monospace')),
                ],
              ),
            ),
          );
        }

        final h2h = snapshot.data ?? {};
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
                        Icon(Icons.info_outline, color: Colors.orange.shade400, size: 20),
                        const SizedBox(width: 8),
                        Text('No H2H data available', style: TextStyle(color: Colors.orange.shade400, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Head-to-head history is not available for this match.', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                    const SizedBox(height: 8),
                    Text('• These teams haven\'t played each other\n• The API doesn\'t have H2H data\n• This is a new matchup', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Debug Info', style: TextStyle(color: Colors.yellow.shade600, fontSize: 10, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Match ID: ${widget.match.eid}', style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
                          Text('Category: ${widget.category}', style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
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

        // Tutorial: CompN = CompetitionName, CompD = CompetitionDescription,
        //           CompST = CompetitionSubTitle, Cnm = CountryName, Snm = LeagueName
        final competitionName = _readDisplayValue(table, const [
          _F.competitionName, _F.stageName, 'Sdn',
        ], 'League Table');
        final competitionSubtitle = _readDisplayValue(table, const [
          _F.competitionDesc, _F.competitionSub, _F.countryName,
        ], widget.match.country);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.yellow.shade700.withOpacity(0.16), Colors.blue.shade400.withOpacity(0.08)],
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
                  Text(competitionName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(competitionSubtitle, style: TextStyle(color: Colors.white.withOpacity(0.68), fontSize: 13)),
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

  /// H2H = H2HEvents per tutorial (primary key)
  Widget _buildH2HSection(Map<String, dynamic> h2hData) {
    List<Map<String, dynamic>> matches = [];

    // Tutorial: H2H = H2HEvents (primary key per HeadToHeadParser)
    if (h2hData.containsKey(_F.h2hEvents) && h2hData[_F.h2hEvents] is List) {
      matches = (h2hData[_F.h2hEvents] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
    } else if (h2hData.containsKey('h2h') && h2hData['h2h'] is List) {
      matches = (h2hData['h2h'] as List<dynamic>).whereType<Map<String, dynamic>>().toList();
    } else if (h2hData.containsKey('headToHead') && h2hData['headToHead'] is List) {
      matches = (h2hData['headToHead'] as List<dynamic>).whereType<Map<String, dynamic>>().toList();
    } else if (h2hData.containsKey('events') && h2hData['events'] is List) {
      matches = (h2hData['events'] as List<dynamic>).whereType<Map<String, dynamic>>().toList();
    } else if (h2hData.containsKey('E') && h2hData['E'] is List) {
      matches = (h2hData['E'] as List<dynamic>).whereType<Map<String, dynamic>>().toList();
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
            const Text('Head to Head', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text('No previous matches found', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      children: matches
          .map((match) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildH2HMatchCard(match),
      ))
          .toList(),
    );
  }

  /// HeadToHeadParser per tutorial:
  /// T1/T2 = HomeTeam/AwayTeam, Tr1/Tr2 = scores, Esd = MatchStartDate,
  /// Stg = Stage (contains Snm = LeagueName)
  Widget _buildH2HMatchCard(Map<String, dynamic> match) {
    // Stg = Stage per tutorial HeadToHeadParser
    final stage = match[_F.stageGroup] as Map<String, dynamic>?;
    // T1/T2 = HomeTeam/AwayTeam (list of participant) per tutorial
    final homeTeamData = _extractH2HTeam(match[_F.homeTeam]);
    final awayTeamData = _extractH2HTeam(match[_F.awayTeam]);
    // Tr1/Tr2 = HomeTeamScore/AwayTeamScore per tutorial
    final homeScore = _readNestedDisplayValue(match, const [
      _F.homeScore, 'T1Sc', 'homeScore',
    ], '-');
    final awayScore = _readNestedDisplayValue(match, const [
      _F.awayScore, 'T2Sc', 'awayScore',
    ], '-');
    // Stg.Snm = LeagueName per tutorial
    final stageName = _readNestedDisplayValue(stage ?? const {}, const [
      _F.stageName,   // Snm = LeagueName per tutorial
      'snm', _F.participantNm, 'name',
    ], 'League');
    // Esd = MatchStartDate (yyyyMMddHHmmss format per tutorial)
    final formattedDate = _formatH2HDate(
      _readNestedDisplayValue(match, const [_F.matchStartDate, 'esd', 'date'], ''),
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
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
                      const Icon(Icons.emoji_events_outlined, size: 12, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          stageName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 11, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.4),
                    ),
                  ],
                ),
              ],
            ),
            Container(margin: const EdgeInsets.symmetric(vertical: 10), height: 1, color: Colors.white.withOpacity(0.08)),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          homeTeamData['name'] ?? 'Home',
                          maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,
                          style: TextStyle(
                            color: _h2HWinningTextColor(homeScore, awayScore, true),
                            fontSize: 13, fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildH2HTeamLogo(homeTeamData['image'] ?? '', 'Home Team'),
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
                        child: Text('-', style: TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                      _buildH2HScoreBox(awayScore, homeScore),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildH2HTeamLogo(awayTeamData['image'] ?? '', 'Away Team'),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          awayTeamData['name'] ?? 'Away',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _h2HWinningTextColor(awayScore, homeScore, true),
                            fontSize: 13, fontWeight: FontWeight.w700,
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

  /// Nm = TeamName, Img = TeamBadgeID per HeadToHeadParser tutorial
  Map<String, String> _extractH2HTeam(dynamic raw) {
    if (raw is List<dynamic> && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
      final team = raw.first as Map<String, dynamic>;
      return {
        // Nm = Name per tutorial
        'name': _readNestedDisplayValue(team, const [_F.participantNm, 'name', _F.teamName], 'Unknown'),
        // Img = BadgeID per tutorial
        'image': _readNestedDisplayValue(team, const [_F.badgeId, 'img'], ''),
      };
    }

    if (raw is Map<String, dynamic>) {
      return {
        'name': _readNestedDisplayValue(raw, const [_F.participantNm, 'name', _F.teamName], 'Unknown'),
        'image': _readNestedDisplayValue(raw, const [_F.badgeId, 'img'], ''),
      };
    }

    return {'name': raw?.toString() ?? 'Unknown', 'image': ''};
  }

  Widget _buildH2HTeamLogo(String imagePath, String semanticLabel) {
    final imageUrl = _teamImageUrl(imagePath);
    return Container(
      width: 32, height: 32,
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
        errorBuilder: (_, __, ___) => const Icon(Icons.shield_outlined, size: 16, color: Colors.white70),
      ),
    );
  }

  Widget _buildH2HScoreBox(String score, String opponentScore) {
    final colors = _h2HScoreColors(score, opponentScore);
    return Container(
      width: 28, height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors['background']!,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors['border']!),
      ),
      child: Text(
        score,
        style: TextStyle(color: colors['text']!, fontSize: 13, fontWeight: FontWeight.w800),
      ),
    );
  }

  Map<String, Color> _h2HScoreColors(String score, String opponentScore) {
    final current = int.tryParse(score) ?? 0;
    final other = int.tryParse(opponentScore) ?? 0;
    if (current > other) {
      return {'background': const Color(0xFFDCFCE7), 'text': Colors.black, 'border': const Color(0xFFBBF7D0)};
    }
    if (current < other) {
      return {'background': const Color(0xFFFEE2E2), 'text': Colors.black, 'border': const Color(0xFFFECACA)};
    }
    return {'background': const Color(0xFF9CA3AF), 'text': Colors.white, 'border': const Color(0xFF6B7280)};
  }

  Color _h2HWinningTextColor(String score, String opponentScore, bool emphasis) {
    final current = int.tryParse(score) ?? 0;
    final other = int.tryParse(opponentScore) ?? 0;
    if (current > other && emphasis) return Colors.white;
    return Colors.white70;
  }

  /// Handles yyyyMMddHHmmss format (14 chars) per tutorial WatchParser
  /// as well as 8-char date-only format
  String _formatH2HDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length >= 14) {
      // yyyyMMddHHmmss per tutorial
      final year  = trimmed.substring(0, 4);
      final month = trimmed.substring(4, 6);
      final day   = trimmed.substring(6, 8);
      final hour  = trimmed.substring(8, 10);
      final min   = trimmed.substring(10, 12);
      return '$day/$month/$year $hour:$min';
    }
    if (trimmed.length >= 8) {
      final year  = trimmed.substring(0, 4);
      final month = trimmed.substring(4, 6);
      final day   = trimmed.substring(6, 8);
      return '$day/$month/$year';
    }
    return '-';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Error / info widgets
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            const Text('Failed to load match details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _reloadAllData,
              style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.yellow.shade600)),
              child: Text('Retry', style: TextStyle(color: Colors.yellow.shade600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader() {
    final showScores = widget.match.homeScore.isNotEmpty && widget.match.awayScore.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Text(widget.match.competition, style: TextStyle(color: Colors.yellow.shade600, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(widget.match.country, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTeamBadge(widget.match.homeTeam, widget.match.homeTeamImage),
                    const SizedBox(height: 8),
                    Text(widget.match.homeTeam, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    if (showScores) ...[
                      const SizedBox(height: 8),
                      Text(widget.match.homeScore, style: TextStyle(color: Colors.yellow.shade600, fontSize: 28, fontWeight: FontWeight.w800)),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(_statusLabel(widget.match.status), style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(_getStatusBadgeText(), style: TextStyle(color: _getStatusColor(), fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTeamBadge(widget.match.awayTeam, widget.match.awayTeamImage),
                    const SizedBox(height: 8),
                    Text(widget.match.awayTeam, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    if (showScores) ...[
                      const SizedBox(height: 8),
                      Text(widget.match.awayScore, style: TextStyle(color: Colors.yellow.shade600, fontSize: 28, fontWeight: FontWeight.w800)),
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
      width: 56, height: 56,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? _buildTeamInitials(teamName)
          : Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildTeamInitials(teamName),
      ),
    );
  }

  Widget _buildTeamInitials(String teamName) {
    return Center(
      child: Text(_initials(teamName), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
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
            child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          Padding(padding: const EdgeInsets.all(16), child: _buildDetailItems(detail)),
        ],
      ),
    );
  }

  Widget _buildDetailItems(Map<String, dynamic> detail) {
    final items = <Widget>[];
    final matchInfo = detail['m'] as Map<String, dynamic>? ?? {};

    if (widget.match.startTime != null) {
      items.add(_buildDetailItem('Scheduled Time', _formatDateTime(widget.match.startTime!)));
      items.add(const Divider(color: Color(0xFF262626), height: 1));
    }

    if (matchInfo.containsKey('Venue')) {
      items.add(_buildDetailItem('Venue', matchInfo['Venue']?.toString() ?? 'N/A'));
      items.add(const Divider(color: Color(0xFF262626), height: 1));
    }

    // Eps = MatchStatus per tutorial
    items.add(_buildDetailItem('Status (Eps)', _statusLabel(widget.match.status)));
    items.add(const Divider(color: Color(0xFF262626), height: 1));
    // Eid = Match/Team ID per tutorial
    items.add(_buildDetailItem('Match ID (Eid)', widget.match.eid));

    return Column(children: items);
  }

  Widget _buildTeamDetailsSection() {
    final hasAnyTeamId =
        widget.match.homeTeamId.trim().isNotEmpty || widget.match.awayTeamId.trim().isNotEmpty;

    if (!hasAnyTeamId) return const SizedBox.shrink();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait([_homeTeamDetailFuture, _awayTeamDetailFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MatchListLoadingSkeleton(cardCount: 2, showHeader: false);
        }

        final details = snapshot.data ?? const <Map<String, dynamic>>[];
        final homeDetail = details.isNotEmpty ? details[0] : const <String, dynamic>{};
        final awayDetail = details.length > 1 ? details[1] : const <String, dynamic>{};

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
                child: Text('Team Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
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
              Expanded(child: Text(teamName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  List<Widget> _buildTeamDetailRows(Map<String, dynamic> detail, {required String fallbackTeamId}) {
    // Tutorial: ID = ParticipantID, Nm = Name, Img = BadgeID
    final resolvedTeamId = _readNestedDisplayValue(detail, const [
      _F.participantId, 'Id', 'id', _F.teamId, 'team.id', 'team.ID',
    ], fallbackTeamId.trim());
    final displayName = _readNestedDisplayValue(detail, const [
      'Name', 'name', _F.participantNm, _F.teamName, 'team.name', 'team.Name',
    ], '');
    final shortName = _readNestedDisplayValue(detail, const [
      _F.stageName, 'shortName', 'ShortName', 'team.shortName',
    ], '');
    final country = _readNestedDisplayValue(detail, const [
      'Country', 'country', _F.countryName, 'CountryName', 'team.country', 'team.country.name',
    ], 'N/A');
    final city = _readNestedDisplayValue(detail, const ['City', 'city', 'team.city', 'team.City'], '');
    final stadium = _readNestedDisplayValue(detail, const [
      'Stadium', 'stadium', 'Venue', 'venue', 'Ven', 'Stdm',
      'team.stadium', 'team.venue', 'team.stadium.name', 'team.venue.name',
    ], 'N/A');
    final founded = _readNestedDisplayValue(detail, const [
      'Founded', 'founded', 'YearFounded', 'yearFounded', 'team.founded',
    ], 'N/A');
    final manager = _readNestedDisplayValue(detail, const [
      'Manager', 'manager', 'Coach', 'coach', 'ManagerName', 'CoachName',
      'team.manager.name', 'team.coach.name',
    ], 'N/A');
    final website = _readNestedDisplayValue(detail, const ['Website', 'website', 'team.website'], '');

    final values = <MapEntry<String, String>>[];
    if (resolvedTeamId.isNotEmpty) values.add(MapEntry('Team ID', resolvedTeamId));
    if (displayName.isNotEmpty) values.add(MapEntry('Name', displayName));
    if (shortName.isNotEmpty) values.add(MapEntry('Short Name', shortName));
    if (country.isNotEmpty && country != 'N/A') values.add(MapEntry('Country', country));
    if (city.isNotEmpty) values.add(MapEntry('City', city));
    if (stadium.isNotEmpty && stadium != 'N/A') values.add(MapEntry('Stadium', stadium));
    if (founded.isNotEmpty && founded != 'N/A') values.add(MapEntry('Founded', founded));
    if (manager.isNotEmpty && manager != 'N/A') values.add(MapEntry('Manager', manager));
    if (website.isNotEmpty) values.add(MapEntry('Website', website));

    if (values.isEmpty) {
      values.add(MapEntry('Team ID', resolvedTeamId.isEmpty ? 'N/A' : resolvedTeamId));
    }

    return values.map((entry) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(entry.key, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(entry.value, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  String? _teamImageUrl(String imagePath) {
    final trimmed = imagePath.trim();
    if (trimmed.isEmpty) return null;
    final sourceUrl = trimmed.startsWith('http')
        ? trimmed
        : 'https://storage.livescore.com/images/team/medium/$trimmed';
    return 'https://getimage.membertsd.workers.dev/?url=' + Uri.encodeComponent(sourceUrl);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  String _formatDateTime(DateTime dateTime) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
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
              Text(title, style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text(message, style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 13, height: 1.4)),
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
          Text(title, style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildTableBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$label  ', style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11, fontWeight: FontWeight.w600)),
            TextSpan(text: value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
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

  /// Uses Tid = TeamID, Tnm = TeamName, Img = TeamBadge per tutorial
  Widget _buildLeagueRow(Map<String, dynamic> row) {
    // Tutorial: Tid = TeamID, Tnm = TeamName, Img = TeamBadge
    final teamId = _readDisplayValue(row, const [_F.teamId, 'teamId', _F.participantId], '');
    final teamName = _readDisplayValue(row, const [_F.teamName, _F.participantNm, 'name'], 'Unknown');
    final rank = _readDisplayValue(row, const ['rnk', 'rank', 'pos'], '-');
    final played = _readDisplayValue(row, const ['pld', 'played'], '-');
    final wins = _readDisplayValue(row, const ['win', 'winn', 'wins'], '-');
    final draws = _readDisplayValue(row, const ['drw', 'drwn', 'draws'], '-');
    final losses = _readDisplayValue(row, const ['lst', 'lstn', 'losses'], '-');
    final goalDifference = _readDisplayValue(row, const ['gd', 'goalDifference'], '-');
    final points = _readDisplayValue(row, const ['ptsn', 'pts', 'points'], '-');
    // Img = TeamBadge per tutorial
    final teamImage = _readDisplayValue(row, const [_F.badgeId, 'img'], '');

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
        color: isHighlighted ? accentColor.withOpacity(0.12) : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isHighlighted ? accentColor.withOpacity(0.45) : Colors.transparent),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(rank, style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w800)),
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
                      Text(teamName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      if (isHighlighted)
                        Text(
                          isHomeTeam ? 'Home side' : 'Away side',
                          style: TextStyle(color: accentColor.withOpacity(0.92), fontSize: 10, fontWeight: FontWeight.w600),
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

  Widget _buildMiniTeamBadge(String teamName, String imagePath, Color accentColor) {
    final imageUrl = _teamImageUrl(imagePath);
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl, width: 28, height: 28, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildMiniFallbackBadge(teamName, accentColor),
        ),
      );
    }
    return _buildMiniFallbackBadge(teamName, accentColor);
  }

  Widget _buildMiniFallbackBadge(String teamName, Color accentColor) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: accentColor.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
      alignment: Alignment.center,
      child: Text(_initials(teamName), style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w800)),
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

  List<Map<String, dynamic>> _extractPlayerMapsFromDynamic(dynamic value) {
    if (value is List<dynamic>) return value.whereType<Map<String, dynamic>>().toList();
    return const [];
  }

  Map<String, dynamic> _copyPlayerMap(Map<String, dynamic> source) =>
      Map<String, dynamic>.from(source);

  // ─────────────────────────────────────────────────────────────────────────
  // Lineup player helpers (tutorial field names)
  // ─────────────────────────────────────────────────────────────────────────

  /// PosA = PlayerActualPosition (primary) per tutorial
  int _lineupPlayerPos(Map<String, dynamic> player) {
    // PosA = PlayerActualPosition (primary per tutorial)
    // Pos = PlayerPosition (fallback)
    return int.tryParse(
      _readNestedDisplayValue(player, const [
        _F.playerActPos,  // PosA primary per tutorial
        _F.playerPos,     // Pos fallback
        'pos', 'position',
      ], ''),
    ) ??
        0;
  }

  String _lineupPositionLabelFromPos(int pos) {
    switch (pos) {
      case 1: return 'GK';
      case 2: return 'DEF';
      case 3: return 'MID';
      case 4: return 'FW';
      default: return 'BENCH';
    }
  }

  String _inferFormationFromPlayers(List<Map<String, dynamic>> players) {
    final defs = players.where((p) => _lineupPlayerPos(p) == 2).length;
    final mids = players.where((p) => _lineupPlayerPos(p) == 3).length;
    final fws  = players.where((p) => _lineupPlayerPos(p) == 4).length;
    return [defs, mids, fws].where((v) => v > 0).map((v) => '$v').join('-');
  }

  List<List<Map<String, dynamic>>> _buildStructuredFormationRows(
      List<Map<String, dynamic>> players,
      ) {
    if (players.isEmpty) return const [];

    final goalkeepers = players.where((p) => _lineupPlayerPos(p) == 1).toList();
    final defenders   = players.where((p) => _lineupPlayerPos(p) == 2).toList();
    final midfielders = players.where((p) => _lineupPlayerPos(p) == 3).toList();
    final forwards    = players.where((p) => _lineupPlayerPos(p) == 4).toList();
    final unknown     = players.where((p) => ![1,2,3,4].contains(_lineupPlayerPos(p))).toList();

    final rows = <List<Map<String, dynamic>>>[];
    if (goalkeepers.isNotEmpty) rows.add([goalkeepers.first]);
    if (defenders.isNotEmpty)   rows.add(defenders);
    if (midfielders.isNotEmpty) rows.add(midfielders);
    if (forwards.isNotEmpty)    rows.add(forwards);
    if (unknown.isNotEmpty)     rows.add(unknown);

    return rows.isNotEmpty ? rows : [players];
  }

  /// Subs = Substitutions, Min = SubstituteMinutes per tutorial LineupsParser
  List<Map<String, dynamic>> _buildLineupSubHistory(
      Map<String, dynamic> lineups, {
        required bool isHome,
      }) {
    final subs = lineups[_F.lineupSubs];
    if (subs is! List<dynamic> || subs.length < 3 || subs[2] is! List<dynamic>) {
      return const [];
    }

    final teamNum = isHome ? '1' : '2';
    final allEntries = (subs[2] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .where((item) {
      final tnb = _readNestedDisplayValue(item, const ['Tnb', 'Nm', 'nm'], '');
      return tnb == teamNum;
    })
        .toList();

    allEntries.sort((a, b) {
      final aMin = _asInt(a[_F.minute]);
      final bMin = _asInt(b[_F.minute]);
      return aMin.compareTo(bMin);
    });

    final outs = allEntries.where((e) => _asInt(e[_F.incidentType]) == _F.itSubstitutionOut).toList();
    final ins  = allEntries.where((e) => _asInt(e[_F.incidentType]) == _F.itSubstitutionIn).toList();

    final usedIn = <int>{};
    final history = <Map<String, dynamic>>[];

    for (final out in outs) {
      final outId  = (out['Aid'] ?? out['ID'] ?? '').toString().trim();
      final outIdo = (out['IDo'] ?? '').toString().trim();

      // manually track index instead of using (element, index) lambda
      int matchIndex = -1;
      for (var i = 0; i < ins.length; i++) {
        if (usedIn.contains(i)) continue;
        final inn   = ins[i];
        final inId  = (inn['Aid'] ?? inn['ID'] ?? '').toString().trim();
        final inIdo = (inn['IDo'] ?? '').toString().trim();
        if (inId == outIdo || inIdo == outId) {
          matchIndex = i;
          break;
        }
      }

      if (matchIndex != -1) {
        usedIn.add(matchIndex);
        final minute = _firstNonEmpty([
          (out[_F.minute] ?? '').toString().trim(),
          (ins[matchIndex][_F.minute] ?? '').toString().trim(),
        ]);
        history.add({
          'min': minute,
          'out': out,
          'in': ins[matchIndex],
        });
      }
    }

    return history;
  }

  String? _getStarterSubOutTime(
      Map<String, dynamic> player,
      List<Map<String, dynamic>> history,
      ) {
    // Aid = PLAYER_ID primary, ID = SUBSTITUTE_ID fallback
    final aid = (player['Aid'] ?? player['ID'] ?? '').toString().trim();
    if (aid.isEmpty) return null;

    for (final event in history) {
      final out = event['out'];
      if (out is Map<String, dynamic>) {
        final outAid = (out['Aid'] ?? out['ID'] ?? '').toString().trim();
        if (outAid == aid) {
          final minute = event['min']?.toString().trim() ?? '';
          return minute.isEmpty ? null : minute;
        }
      }
    }
    return null;
  }

  Map<String, dynamic>? _getBenchSubInData(
      Map<String, dynamic> player,
      List<Map<String, dynamic>> history,
      ) {
    final aid = (player['Aid'] ?? player['ID'] ?? '').toString().trim();
    if (aid.isEmpty) return null;

    for (final event in history) {
      final incoming = event['in'];
      final outgoing = event['out'];
      if (incoming is Map<String, dynamic>) {
        final inAid = (incoming['Aid'] ?? incoming['ID'] ?? '').toString().trim();
        if (inAid == aid) {
          final minute = event['min']?.toString().trim() ?? '';
          return {
            'subInMin': minute,
            'subOutName': outgoing is Map<String, dynamic>
                ? _lineupPlayerShortName(outgoing)
                : '',
          };
        }
      }
    }
    return null;
  }

  bool _playerBelongsToTeam(Map<String, dynamic> player, bool isHome) {
    final raw = _readNestedDisplayValue(player, const [
      't', 'team', 'teamId', 'teamName', 'tid', _F.teamId, 'tm', 'side',
    ], '').toLowerCase();
    final targetId = (isHome ? widget.match.homeTeamId : widget.match.awayTeamId).toLowerCase();
    final targetName = (isHome ? widget.match.homeTeam : widget.match.awayTeam).toLowerCase();
    final sideLabel = isHome ? 'home' : 'away';
    return raw == targetId || raw == targetName ||
        raw.contains(sideLabel) || raw.contains(targetName);
  }

  bool _isStarterPlayer(Map<String, dynamic> player) {
    final raw = _readNestedDisplayValue(player, const [
      'starter', 'isStarter', 'st', 'xi', 'starting', 'lineup', 'first11', 'status',
    ], '').toLowerCase();
    return raw == '1' || raw == 'true' || raw == 'yes' ||
        raw == 'starter' || raw == 'starting' || raw == 'xi';
  }

  /// Rt = PlayerStatus, Rs = PlayerStatusReason per tutorial (primary checks)
  bool _isInjuryPlayer(Map<String, dynamic> player) {
    // Tutorial: Rt = PlayerStatus, Rs = PlayerStatusReason (primary per BasicPlayersParser)
    final statusReason = (player[_F.playerStatusRs] ?? '').toString().toLowerCase();
    final status       = (player[_F.playerStatus]   ?? '').toString().toLowerCase();

    if (statusReason.isNotEmpty) {
      if (statusReason.contains('injur') || statusReason.contains('knock') ||
          statusReason.contains('out') || statusReason.contains('doubt') ||
          statusReason.contains('hamstring') || statusReason.contains('cruciate') ||
          statusReason.contains('achilles') || statusReason.contains('absent')) {
        return true;
      }
    }

    if (status.isNotEmpty) {
      if (status.contains('injur') || status.contains('knock') || status.contains('out')) {
        return true;
      }
    }

    // Fallback generic fields
    final raw = _readNestedDisplayValue(player, const [
      'injury', 'injuryType', 'availability', 'reason', 'desc',
    ], '').toLowerCase();
    return raw.contains('injur') || raw.contains('knock') || raw.contains('out') ||
        raw.contains('doubt') || raw.contains('absent') ||
        raw.contains('hamstring') || raw.contains('cruciate') || raw.contains('achilles');
  }

  List<Map<String, dynamic>> _dedupePlayers(List<Map<String, dynamic>> players) {
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];
    for (final player in players) {
      final key = '${_lineupPlayerNumber(player)}|${_lineupPlayerName(player).toLowerCase()}';
      if (seen.add(key)) result.add(player);
    }
    return result;
  }

  bool _containsPlayer(List<Map<String, dynamic>> players, Map<String, dynamic> target) {
    final targetKey = '${_lineupPlayerNumber(target)}|${_lineupPlayerName(target).toLowerCase()}';
    for (final player in players) {
      final key = '${_lineupPlayerNumber(player)}|${_lineupPlayerName(player).toLowerCase()}';
      if (key == targetKey) return true;
    }
    return false;
  }

  /// Aid = PlayerID (primary), Pid = PlayerExternalID (secondary) per tutorial
  String _lineupPlayerId(Map<String, dynamic> player) {
    return _readNestedDisplayValue(player, const [
      'Aid',  // PLAYER_ID primary per LineUpsParser
      'ID',   // SUBSTITUTE_ID per LineUpsParser
      'Pid',  // PLAYER_EXTERNAL_ID fallback
      'id',
    ], '');
  }

  String _lineupPlayerName(Map<String, dynamic> player) {
    // Shnm = PLAYER_FULL_NAME primary
    final full = (player['Shnm'] ?? '').toString().trim();
    if (full.isNotEmpty) return full;

    // Fn + Ln fallback
    final fn = (player['Fn'] ?? '').toString().trim();
    final ln = (player['Ln'] ?? '').toString().trim();
    final composed = [fn, ln].where((s) => s.isNotEmpty).join(' ');
    if (composed.isNotEmpty) return composed;

    return (player['Nm'] ?? 'Unknown').toString().trim();
  }

// Short name for pitch display — last name only
  String _lineupPlayerShortName(Map<String, dynamic> player) {
    final ln = (player['Ln'] ?? '').toString().trim();
    if (ln.isNotEmpty) return ln;
    final shnm = (player['Shnm'] ?? '').toString().trim();
    if (shnm.isNotEmpty) return shnm;
    return (player['Fn'] ?? '?').toString().trim();
  }

  /// Snu = PlayerNumber per tutorial
  String _lineupPlayerNumber(Map<String, dynamic> player) {
    return _readNestedDisplayValue(player, const [
      _F.playerNumber,  // Snu = PlayerNumber per tutorial
      'shirtNumber', 'num', 'shirtnumber', 'No', 'number',
    ], '?');
  }

  /// PosA = PlayerActualPosition (primary per tutorial)
  String _lineupPlayerPosition(Map<String, dynamic> player) {
    final posVal = _asInt(_readNestedDisplayValue(player, const [
      _F.playerActPos,  // PosA primary
      _F.playerPos,     // Pos fallback
    ], '0'));

    // pos == 5 means bench — show nothing
    if (posVal == 5) return '';
    if (posVal > 0) return _lineupPositionLabelFromPos(posVal);

    // fallback to text fields
    final explicit = _readNestedDisplayValue(player, const [
      'pos', 'position', 'role', 'Position',
    ], '').toUpperCase();
    return explicit;
  }

  String _lineupPlayerRating(Map<String, dynamic> player) {
    return _readNestedDisplayValue(player, const ['Rate', 'rating', 'rate', 'rt', 'Rating'], '');
  }

  /// Rs = PlayerStatusReason, Rt = PlayerStatus per tutorial
  String _lineupPlayerEvent(Map<String, dynamic> player) {
    // Set by _getStarterSubOutTime into player map as 'subOutMin'
    final subOutMin = (player['subOutMin'] ?? '').toString().trim();
    if (subOutMin.isNotEmpty) return subOutMin;
    return '';
  }

  /// Rs = PlayerStatusReason, Rt = PlayerStatus per tutorial
  String _lineupPlayerDetailText(Map<String, dynamic> player) {
    final subInMin = _readNestedDisplayValue(player, const ['subInMin'], '');
    final subOutName = _readNestedDisplayValue(player, const ['subOutName'], '');
    if (subInMin.isNotEmpty) {
      return subOutName.isNotEmpty ? "$subInMin'  for $subOutName" : "$subInMin'";
    }

    final minute = _readNestedDisplayValue(player, const ['minute', 'min', 'Time', 'tm'], '');
    final relation = _readNestedDisplayValue(player, const [
      'for', 'replacement', 'replaced', 'substituteFor', 'playerOut', 'out',
    ], '');
    // Tutorial: Rs = PlayerStatusReason (primary), Rt = PlayerStatus (fallback)
    final status = _readNestedDisplayValue(player, const [
      _F.playerStatusRs,  // Rs primary per tutorial
      _F.playerStatus,    // Rt fallback
      'injury', 'injuryType', 'reason', 'desc', 'status',
    ], '');

    final segments = <String>[];
    if (minute.isNotEmpty) segments.add("$minute'");
    if (relation.isNotEmpty) {
      segments.add('for $relation');
    } else if (status.isNotEmpty) {
      segments.add(status);
    }

    return segments.join('  ');
  }

  Color _lineupRatingColor(String rating) {
    final parsed = double.tryParse(rating);
    if (parsed == null) return const Color(0xFF1FAA59);
    if (parsed >= 7.0)  return const Color(0xFF12B95C);
    if (parsed >= 6.0)  return const Color(0xFFFF9F1A);
    return const Color(0xFFE64C3C);
  }

  Color _lineupEventColor(String eventText) => const Color(0xFFE44141);

  // ─────────────────────────────────────────────────────────────────────────
  // Generic read helpers
  // ─────────────────────────────────────────────────────────────────────────

  String _readDisplayValue(Map<String, dynamic> source, List<String> keys, String fallback) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
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
      if (current == null) continue;
      final text = current.toString().trim();
      if (text.isNotEmpty) return text;
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
    const stripeCount = 10;
    final stripeWidth = isCompact ? size.height / stripeCount : size.width / stripeCount;
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

    canvas.drawRect(Rect.fromLTWH(14, 14, size.width - 28, size.height - 28), linePaint);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (isCompact ? size.width : size.height) * 0.10,
      linePaint,
    );
    canvas.drawLine(
      isCompact ? Offset(14, size.height / 2) : Offset(size.width / 2, 14),
      isCompact ? Offset(size.width - 14, size.height / 2) : Offset(size.width / 2, size.height - 14),
      linePaint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      3,
      Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.fill,
    );

    if (isCompact) {
      final boxWidth = size.width * 0.30;
      final goalBoxWidth = size.width * 0.16;
      final penaltyHeight = size.height * 0.12;
      final goalBoxHeight = size.height * 0.06;
      final left = (size.width - boxWidth) / 2;
      final goalLeft = (size.width - goalBoxWidth) / 2;

      canvas.drawRect(Rect.fromLTWH(left, 14, boxWidth, penaltyHeight), linePaint);
      canvas.drawRect(Rect.fromLTWH(left, size.height - 14 - penaltyHeight, boxWidth, penaltyHeight), linePaint);
      canvas.drawRect(Rect.fromLTWH(goalLeft, 14, goalBoxWidth, goalBoxHeight), linePaint);
      canvas.drawRect(Rect.fromLTWH(goalLeft, size.height - 14 - goalBoxHeight, goalBoxWidth, goalBoxHeight), linePaint);
      canvas.drawCircle(Offset(size.width / 2, 14 + (penaltyHeight * 0.62)), 2.4,
          Paint()..color = Colors.white.withOpacity(0.72)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(size.width / 2, size.height - 14 - (penaltyHeight * 0.62)), 2.4,
          Paint()..color = Colors.white.withOpacity(0.72)..style = PaintingStyle.fill);
    } else {
      final boxHeight = size.height * 0.30;
      final goalBoxHeight = size.height * 0.16;
      final penaltyWidth = size.width * 0.12;
      final goalBoxWidth = size.width * 0.06;
      final top = (size.height - boxHeight) / 2;
      final goalTop = (size.height - goalBoxHeight) / 2;

      canvas.drawRect(Rect.fromLTWH(14, top, penaltyWidth, boxHeight), linePaint);
      canvas.drawRect(Rect.fromLTWH(size.width - 14 - penaltyWidth, top, penaltyWidth, boxHeight), linePaint);
      canvas.drawRect(Rect.fromLTWH(14, goalTop, goalBoxWidth, goalBoxHeight), linePaint);
      canvas.drawRect(Rect.fromLTWH(size.width - 14 - goalBoxWidth, goalTop, goalBoxWidth, goalBoxHeight), linePaint);
      canvas.drawCircle(Offset(14 + (penaltyWidth * 0.62), size.height / 2), 2.4,
          Paint()..color = Colors.white.withOpacity(0.72)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(size.width - 14 - (penaltyWidth * 0.62), size.height / 2), 2.4,
          Paint()..color = Colors.white.withOpacity(0.72)..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(FootballFieldPainter oldDelegate) => oldDelegate.isCompact != isCompact;
}