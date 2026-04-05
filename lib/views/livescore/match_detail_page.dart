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
  late Future<Map<String, dynamic>> _h2hFuture;
  int _selectedTab = 0; // 0: Overview, 1: Summary, 2: Lineups, 3: Statistics, 4: H2H
  
  @override
  void initState() {
    super.initState();
    print('DEBUG: MatchDetailPage initialized with EID = ${widget.match.eid}, Category = ${widget.category}');
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
    _h2hFuture = _liveScoreService.fetchH2H(
      eid: widget.match.eid,
      category: widget.category,
    );
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
    final tabs = ['OVERVIEW', 'SUMMARY', 'LINEUPS', 'STATISTICS', 'H2H'];
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTab == index
                          ? Colors.yellow.shade600
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
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
    final formation = 'formation';
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
              onPressed: () {
                setState(() {
                  _detailFuture = _liveScoreService.fetchMatchDetail(
                    eid: widget.match.eid,
                    category: widget.category,
                  );
                });
              },
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

  Widget _buildLineupsSection(Map<String, dynamic> lineups) {
    // The API typically returns players under 'pl' key or 'teams' key
    List<dynamic> players = [];
    Map<String, dynamic> teams = {};
    
    // Try to extract players from various possible keys
    if (lineups.containsKey('pl') && lineups['pl'] is List) {
      players = lineups['pl'] as List<dynamic>;
    } else if (lineups.containsKey('players') && lineups['players'] is List) {
      players = lineups['players'] as List<dynamic>;
    } else if (lineups.containsKey('teams') && lineups['teams'] is Map) {
      teams = lineups['teams'] as Map<String, dynamic>;
    }

    // Check if we have any lineup data at all
    if ((players.isEmpty && teams.isEmpty) || lineups.isEmpty) {
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
              'Team Lineups',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Lineup data not yet available for this match',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // Display players from 'pl' format
    if (players.isNotEmpty) {
      return _buildPlayersLineupSection(players);
    }

    // Display teams format
    if (teams.isNotEmpty) {
      return _buildTeamsLineupSection(teams);
    }

    // Fallback - show no data
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
            'Team Lineups',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No lineup information available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersLineupSection(List<dynamic> players) {
    // Group players by team
    final teamsMap = <String, List<Map<String, dynamic>>>{};
    
    for (final player in players) {
      if (player is Map<String, dynamic>) {
        final teamName = player['t'] ?? player['team'] ?? 'Unknown';
        final teamStr = teamName.toString();
        
        if (!teamsMap.containsKey(teamStr)) {
          teamsMap[teamStr] = [];
        }
        teamsMap[teamStr]!.add(player);
      }
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
              'Team Lineups',
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
              children: teamsMap.entries.map((entry) {
                final teamName = entry.key;
                final teamPlayers = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teamName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: teamPlayers.take(11).map((player) {
                        final playerName = player['nm'] ?? player['name'] ?? 'Unknown';
                        final playerNumber = player['shirtNumber'] ?? player['num'] ?? '?';

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$playerNumber - $playerName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsLineupSection(Map<String, dynamic> teams) {
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
              'Team Lineups',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (teams.isNotEmpty)
            Divider(color: Colors.white.withOpacity(0.08), height: 1),
          if (teams.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: teams.entries.map((entry) {
                  final teamName = entry.key;
                  final teamData = entry.value as Map<String, dynamic>? ?? {};
                  final players = teamData['players'] as List<dynamic>? ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teamName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (players.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: players.take(11).map((player) {
                            final playerData = player as Map<String, dynamic>? ?? {};
                            final playerName = playerData['name'] ?? playerData['pn'] ?? 'Unknown';
                            final playerNumber = playerData['num'] ?? playerData['shirtNumber'] ?? '?';

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$playerNumber - $playerName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      else
                        Text(
                          'No player data available',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No team lineup data available',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
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

