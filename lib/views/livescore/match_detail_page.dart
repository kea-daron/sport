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
    print('DEBUG: Match = ${widget.match.homeTeam} vs ${widget.match.awayTeam}');

    _detailFuture = _liveScoreService.fetchMatchDetail(
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
      return await _liveScoreService.fetchTeamPlayerStats(teamId: normalizedTeamId);
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
              Expanded(
                child: _buildTabContent(detail),
              ),
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
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Match Summary',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Summary data will be populated from the API response',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
        
        // Debug: Show response info
        print('DEBUG Lineups Tab: Response keys = ${lineups.keys.toList()}, Empty = ${lineups.isEmpty}, EID = ${widget.match.eid}');
        
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
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildTacticalFormationField(Map<String, dynamic> lineups) {
    // Parse home and away team lineups
    final homeTeam = _parseTeamLineup(lineups, true);
    final awayTeam = _parseTeamLineup(lineups, false);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1B5E3F), // Football field green
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          // Score and Match Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.match.homeTeam,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (homeTeam['formation'] != null)
                      Text(
                        homeTeam['formation']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.match.awayTeam,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (awayTeam['formation'] != null)
                      Text(
                        awayTeam['formation']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Football Field with Players
          CustomPaint(
            painter: FootballFieldPainter(),
            size: const Size(double.infinity, 500),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Home Team (Top)
                  _buildTeamFormationView(homeTeam, isHome: true),
                  // Center Line
                  const SizedBox(height: 20),
                  // Away Team (Bottom)
                  _buildTeamFormationView(awayTeam, isHome: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _parseTeamLineup(Map<String, dynamic> lineups, bool isHome) {
    final players = <Map<String, dynamic>>[];

    // Try different response structures
    if (lineups.containsKey('pl') && lineups['pl'] is List) {
      final allPlayers = lineups['pl'] as List<dynamic>;
      for (final p in allPlayers) {
        if (p is Map<String, dynamic>) {
          final teamId = p['t']?.toString() ?? p['team']?.toString() ?? '';
          final isHomeTeam = isHome ? (teamId == widget.match.homeTeam || teamId.contains('home') || teamId.contains(widget.match.homeTeam)) : (teamId == widget.match.awayTeam || teamId.contains('away') || teamId.contains(widget.match.awayTeam));
          if (isHomeTeam) {
            players.add(p);
          }
        }
      }
    } else if (lineups.containsKey('teams') && lineups['teams'] is Map) {
      final teams = lineups['teams'] as Map<String, dynamic>;
      final teamKey = isHome ? 'home' : 'away';
      if (teams.containsKey(teamKey)) {
        final teamData = teams[teamKey] as Map<String, dynamic>?;
        if (teamData?.containsKey('players') ?? false) {
          players.addAll((teamData!['players'] as List<dynamic>).whereType<Map<String, dynamic>>());
        }
      }
    }

    // Get formation string if available
    String? formationStr;
    if (lineups.containsKey(isHome ? 'homeFormation' : 'awayFormation')) {
      formationStr = lineups[isHome ? 'homeFormation' : 'awayFormation']?.toString();
    }

    return {
      'players': players.take(11).toList(),
      'formation': formationStr ?? 'Formation',
    };
  }

  Widget _buildTeamFormationView(Map<String, dynamic> teamData, {required bool isHome}) {
    final players = (teamData['players'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    if (players.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'No lineup data',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
          ),
        ),
      );
    }

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: players.map((player) {
            final name = player['nm'] ?? player['name'] ?? 'Unknown';
            final number = player['shirtNumber'] ?? player['num'] ?? '?';
            final rating = player['rating'] ?? player['rate'];

            return Column(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isHome ? Colors.yellow : const Color(0xFF2C3E50),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: TextStyle(
                        color: isHome ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 50,
                  child: Text(
                    name.toString(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                    ),
                  ),
                ),
                if (rating != null) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      rating.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ]
              ],
            );
          }).toList(),
        ),
      ],
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
        
        // Debug: Show response info
        print('DEBUG Statistics Tab: Response keys = ${statistics.keys.toList()}, Empty = ${statistics.isEmpty}, EID = ${widget.match.eid}');
        
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
    // Parse statistics data based on API response structure
    List<Map<String, dynamic>> stats = [];

    // Try different response structures
    if (statistics.containsKey('stats') && statistics['stats'] is List) {
      stats = (statistics['stats'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
    } else if (statistics.containsKey('statistics') && statistics['statistics'] is List) {
      stats = (statistics['statistics'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
    } else if (statistics.containsKey('teams') && statistics['teams'] is Map) {
      // Extract stats from teams object
      final teams = statistics['teams'] as Map<String, dynamic>;
      for (final teamData in teams.values.whereType<Map<String, dynamic>>()) {
        if (teamData.containsKey('statistics') && teamData['statistics'] is List) {
          stats.addAll((teamData['statistics'] as List<dynamic>)
              .whereType<Map<String, dynamic>>());
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
            Text(
              'Match Statistics',
              style: const TextStyle(
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

    // Build statistics display - group by team if possible
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
              'Match Statistics',
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
            child: Column(
              children: stats.take(10).map((stat) {
                final statName = stat['name'] ?? stat['N'] ?? stat['nm'] ?? 'Stat';
                final homeValue = stat['home'] ?? stat['T1'] ?? stat['v1'] ?? '-';
                final awayValue = stat['away'] ?? stat['T2'] ?? stat['v2'] ?? '-';

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
    final hasAnyTeamId = widget.match.homeTeamId.trim().isNotEmpty ||
        widget.match.awayTeamId.trim().isNotEmpty;

    if (!hasAnyTeamId) {
      return _buildInlineInfoCard(
        title: 'Player Stats',
        message: 'This match does not include team IDs, so player stats cannot be loaded.',
        accentColor: Colors.orange.shade400,
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait([
        _homePlayerStatsFuture,
        _awayPlayerStatsFuture,
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.yellow.shade600),
          );
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

  List<Map<String, String>> _extractPlayerStatRows(Map<String, dynamic> payload) {
    final candidates = <Map<String, dynamic>>[];
    _collectPlayerStatNodes(payload, candidates);

    final seen = <String>{};
    final rows = <Map<String, String>>[];

    for (final node in candidates) {
      final name = _readNestedDisplayValue(
        node,
        const [
          'Nm',
          'nm',
          'name',
          'PlayerName',
          'playerName',
          'player.name',
          'Pnm',
        ],
        '',
      );
      final value = _readNestedDisplayValue(
        node,
        const [
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
        ],
        '',
      );

      if (name.isEmpty || value.isEmpty) {
        continue;
      }

      final rank = _readNestedDisplayValue(
        node,
        const ['Rank', 'rank', 'Rnk', 'rnk', 'Pos', 'pos'],
        '',
      );
      final secondary = _readNestedDisplayValue(
        node,
        const [
          'Position',
          'position',
          'Team',
          'team',
          'Role',
          'role',
          'player.position',
        ],
        '',
      );

      final identity = '${name.toLowerCase()}|${value.toLowerCase()}|${rank.toLowerCase()}';
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
    final name = _readNestedDisplayValue(
      node,
      const [
        'Nm',
        'nm',
        'name',
        'PlayerName',
        'playerName',
        'player.name',
        'Pnm',
      ],
      '',
    );
    final value = _readNestedDisplayValue(
      node,
      const [
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
      ],
      '',
    );

    return name.isNotEmpty && value.isNotEmpty;
  }

  Widget _buildTeamStatsTab() {
    final hasAnyTeamId = widget.match.homeTeamId.trim().isNotEmpty ||
        widget.match.awayTeamId.trim().isNotEmpty;

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
      future: Future.wait([
        _homeTeamStatsFuture,
        _awayTeamStatsFuture,
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.yellow.shade600),
          );
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

        final mergedLabels = <String>{
          ...homeStats.keys,
          ...awayStats.keys,
        }.toList()
          ..sort();

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
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
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
      final label = _readNestedDisplayValue(
        node,
        const [
          'Nm',
          'nm',
          'name',
          'StatName',
          'statName',
          'Label',
          'label',
          'Ttl',
          'ttl',
        ],
        '',
      );
      final value = _readNestedDisplayValue(
        node,
        const [
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
        ],
        '',
      );

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
    final label = _readNestedDisplayValue(
      node,
      const [
        'Nm',
        'nm',
        'name',
        'StatName',
        'statName',
        'Label',
        'label',
        'Ttl',
        'ttl',
      ],
      '',
    );
    final value = _readNestedDisplayValue(
      node,
      const [
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
      ],
      '',
    );

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
        
        // Debug: Show response info
        print('DEBUG H2H Tab: Response keys = ${h2h.keys.toList()}, Empty = ${h2h.isEmpty}, EID = ${widget.match.eid}');
        
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
          children: [
            _buildH2HSection(h2h),
            const SizedBox(height: 24),
          ],
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

        final competitionName =
            _readDisplayValue(table, const ['CompN', 'Snm', 'Sdn'], 'League Table');
        final competitionSubtitle = _readDisplayValue(
          table,
          const ['CompD', 'CompST', 'Cnm'],
          widget.match.country,
        );

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
    // Parse H2H history based on API response structure
    List<Map<String, dynamic>> matches = [];

    // Try different response structures
    if (h2hData.containsKey('h2h') && h2hData['h2h'] is List) {
      matches = (h2hData['h2h'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
    } else if (h2hData.containsKey('headToHead') && h2hData['headToHead'] is List) {
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
            Text(
              'Head to Head',
              style: const TextStyle(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Head to Head History',
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
            child: Column(
              children: matches.take(5).map((match) {
                final homeTeam = match['T1'] ?? match['t1'] ?? match['homeTeam'] ?? 'Home';
                final awayTeam = match['T2'] ?? match['t2'] ?? match['awayTeam'] ?? 'Away';
                final homeScore = match['Tr1'] ?? match['T1Sc'] ?? match['homeScore'] ?? '-';
                final awayScore = match['Tr2'] ?? match['T2Sc'] ?? match['awayScore'] ?? '-';
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
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
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
    final showScores = widget.match.homeScore.isNotEmpty &&
        widget.match.awayScore.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          // Competition Info
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

          // Teams and Score
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTeamBadge(widget.match.homeTeam, widget.match.homeTeamImage),
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
                    ]
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
                    _buildTeamBadge(widget.match.awayTeam, widget.match.awayTeamImage),
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
                    ]
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

    // Extract common match detail fields
    final matchInfo = detail['m'] as Map<String, dynamic>? ?? {};

    // Match Time/Date
    if (widget.match.startTime != null) {
      items.add(
        _buildDetailItem(
          'Scheduled Time',
          _formatDateTime(widget.match.startTime!),
        ),
      );
      items.add(const Divider(color: Color(0xFF262626), height: 1));
    }

    // Venue (if available in API response)
    if (matchInfo.containsKey('Venue')) {
      items.add(
        _buildDetailItem('Venue', matchInfo['Venue']?.toString() ?? 'N/A'),
      );
      items.add(const Divider(color: Color(0xFF262626), height: 1));
    }

    // Status
    items.add(
      _buildDetailItem('Status', widget.match.status),
    );
    items.add(const Divider(color: Color(0xFF262626), height: 1));

    // Reference ID
    items.add(
      _buildDetailItem('Match ID', widget.match.eid),
    );

    return Column(children: items);
  }

  Widget _buildTeamDetailsSection() {
    final hasAnyTeamId = widget.match.homeTeamId.trim().isNotEmpty ||
        widget.match.awayTeamId.trim().isNotEmpty;

    if (!hasAnyTeamId) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait([
        _homeTeamDetailFuture,
        _awayTeamDetailFuture,
      ]),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Team Details',
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
    final resolvedTeamId = _readNestedDisplayValue(
      detail,
      const ['ID', 'Id', 'id', 'Tid', 'team.id', 'team.ID'],
      fallbackTeamId.trim(),
    );
    final country = _readNestedDisplayValue(
      detail,
      const [
        'Country',
        'country',
        'Cnm',
        'team.country',
        'team.country.name',
      ],
      'N/A',
    );
    final stadium = _readNestedDisplayValue(
      detail,
      const [
        'Stadium',
        'stadium',
        'Venue',
        'venue',
        'team.stadium',
        'team.venue',
      ],
      'N/A',
    );
    final founded = _readNestedDisplayValue(
      detail,
      const [
        'Founded',
        'founded',
        'YearFounded',
        'yearFounded',
        'team.founded',
      ],
      'N/A',
    );
    final manager = _readNestedDisplayValue(
      detail,
      const [
        'Manager',
        'manager',
        'Coach',
        'coach',
        'team.manager.name',
        'team.coach.name',
      ],
      'N/A',
    );

    final values = <MapEntry<String, String>>[
      MapEntry('Team ID', resolvedTeamId.isEmpty ? 'N/A' : resolvedTeamId),
      MapEntry('Country', country),
      MapEntry('Stadium', stadium),
      MapEntry('Founded', founded),
      MapEntry('Manager', manager),
    ];

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
      'Dec'
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
    final teamName = _readDisplayValue(
      row,
      const ['Tnm', 'Nm', 'name'],
      'Unknown',
    );
    final rank = _readDisplayValue(row, const ['rnk', 'rank', 'pos'], '-');
    final played = _readDisplayValue(row, const ['pld', 'played'], '-');
    final wins = _readDisplayValue(row, const ['win', 'winn', 'wins'], '-');
    final draws = _readDisplayValue(row, const ['drw', 'drwn', 'draws'], '-');
    final losses = _readDisplayValue(row, const ['lst', 'lstn', 'losses'], '-');
    final goalDifference =
        _readDisplayValue(row, const ['gd', 'goalDifference'], '-');
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

  Widget _buildMiniTeamBadge(String teamName, String imagePath, Color accentColor) {
    final imageUrl = _teamImageUrl(imagePath);
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          width: 28,
          height: 28,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildMiniFallbackBadge(teamName, accentColor),
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

  List<Map<String, dynamic>> _extractLeagueTableRows(Map<String, dynamic> tableData) {
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
  @override
  void paint(Canvas canvas, Size size) {
    final fieldPaint = Paint()
      ..color = const Color(0xFF1B5E3F)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw field
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      fieldPaint,
    );

    // Draw center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      30,
      linePaint,
    );

    // Draw center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      linePaint,
    );

    // Draw center dot
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      3,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.fill,
    );

    // Draw goal areas
    final goalLength = size.height * 0.2;
    final goalWidth = size.width * 0.3;

    // Home goal area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalWidth) / 2,
        0,
        goalWidth,
        goalLength,
      ),
      linePaint,
    );

    // Away goal area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalWidth) / 2,
        size.height - goalLength,
        goalWidth,
        goalLength,
      ),
      linePaint,
    );

    // Draw penalty areas
    final penaltyLength = size.height * 0.1;

    // Home penalty area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalWidth * 1.2) / 2,
        0,
        goalWidth * 1.2,
        penaltyLength,
      ),
      linePaint,
    );

    // Away penalty area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalWidth * 1.2) / 2,
        size.height - penaltyLength,
        goalWidth * 1.2,
        penaltyLength,
      ),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(FootballFieldPainter oldDelegate) => false;
}

