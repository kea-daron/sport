import 'package:flutter/material.dart';

import '../../models/league_option.dart';
import '../../models/match_item.dart';
import '../../services/live_score_service.dart';
import '../../theme/app_palette.dart';
import '../../widgets/app_skeleton.dart';
import '../livescore/match_detail_page.dart';

class LeagueMatchesPage extends StatefulWidget {
  final LeagueOption league;

  const LeagueMatchesPage({required this.league, super.key});

  @override
  State<LeagueMatchesPage> createState() => _LeagueMatchesPageState();
}

class _LeagueMatchesPageState extends State<LeagueMatchesPage> {
  final LiveScoreService _liveScoreService = const LiveScoreService();
  static const int _initialMatchesCount = 8;
  static const int _matchesPageSize = 8;

  late Future<List<MatchItem>> _matchesFuture;
  int _visibleMatchesCount = _initialMatchesCount;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _loadMatches();
  }

  Future<List<MatchItem>> _loadMatches() {
    return _liveScoreService.fetchMatchesByLeague(
      category: widget.league.category,
      ccd: widget.league.ccd,
      scd: widget.league.scd,
      timezone: -7,
    );
  }

  Future<void> _refreshMatches() async {
    final future = _loadMatches();
    setState(() {
      _matchesFuture = future;
      _visibleMatchesCount = _initialMatchesCount;
    });
    await future;
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
          widget.league.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        color: AppPalette.accent,
        backgroundColor: AppPalette.surfaceMuted,
        onRefresh: _refreshMatches,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildHeroHeader(),
            const SizedBox(height: 22),
            FutureBuilder<List<MatchItem>>(
              future: _matchesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildMessageCard(
                    title: 'Unable to load league matches',
                    subtitle: '${snapshot.error}',
                  );
                }

                final matches = snapshot.data ?? const <MatchItem>[];
                if (matches.isEmpty) {
                  return _buildMessageCard(
                    title: 'No league matches found',
                    subtitle: 'Pull down to refresh this league view.',
                  );
                }

                final groupedMatches = _groupMatchesByStatus(matches);
                final allGroups = groupedMatches.entries.toList();
                final visibleGroups = allGroups
                    .take(_visibleMatchesCount)
                    .toList();
                final hasMoreMatches = allGroups.length > visibleGroups.length;

                return Column(
                  children: [
                    ...visibleGroups.map(
                      (entry) => _buildMatchStatusSection(
                        status: entry.key,
                        matches: entry.value,
                      ),
                    ),
                    if (hasMoreMatches) _buildShowMoreButton(allGroups.length),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    final groupText = widget.league.scd.isEmpty
        ? 'All league matches'
        : widget.league.scd.replaceAll('-', ' ').toUpperCase();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF26210F)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.league.title.toUpperCase(),
              style: TextStyle(
                color: Colors.yellow.shade600,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            groupText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.league.subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const MatchListLoadingSkeleton(cardCount: 4);
  }

  Widget _buildMessageCard({required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<MatchItem>> _groupMatchesByStatus(List<MatchItem> matches) {
    final grouped = <String, List<MatchItem>>{};

    // Separate upcoming and finished matches
    final upcoming = matches.where((m) => m.status == 'NS').toList();
    final finished = matches.where((m) => m.status != 'NS').toList();

    if (upcoming.isNotEmpty) {
      grouped['Upcoming'] = upcoming;
    }
    if (finished.isNotEmpty) {
      grouped['Finished'] = finished;
    }

    return grouped;
  }

  void _navigateToMatchDetail(MatchItem match) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            MatchDetailPage(match: match, category: widget.league.category),
      ),
    );
  }

  Widget _buildMatchStatusSection({
    required String status,
    required List<MatchItem> matches,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: status == 'Upcoming' ? Colors.blue : Colors.green,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      status == 'Upcoming'
                          ? Icons.schedule
                          : Icons.check_circle,
                      color: status == 'Upcoming' ? Colors.blue : Colors.green,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${matches.length} match${matches.length > 1 ? 'es' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Matches List
          ...matches.map(
            (match) => GestureDetector(
              onTap: () => _navigateToMatchDetail(match),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildMatchCard(match),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowMoreButton(int totalMatches) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              final nextCount = _visibleMatchesCount + _matchesPageSize;
              _visibleMatchesCount = nextCount > totalMatches
                  ? totalMatches
                  : nextCount;
            });
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.yellow.shade600),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'Show More',
            style: TextStyle(
              color: Colors.yellow.shade600,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard(MatchItem match) {
    final showScores = match.homeScore.isNotEmpty && match.awayScore.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _statusLabel(match),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 2, height: 40, color: Colors.white24),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _buildTeamRow(
                  teamName: match.homeTeam,
                  teamImage: match.homeTeamImage,
                  score: showScores ? match.homeScore : _scheduledTime(match),
                ),
                const SizedBox(height: 10),
                _buildTeamRow(
                  teamName: match.awayTeam,
                  teamImage: match.awayTeamImage,
                  score: showScores ? match.awayScore : '',
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.star_outline, color: Colors.white60, size: 20),
        ],
      ),
    );
  }

  Widget _buildTeamRow({
    required String teamName,
    required String teamImage,
    required String score,
  }) {
    return Row(
      children: [
        _buildTeamBadge(teamName: teamName, teamImage: teamImage),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            teamName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (score.isNotEmpty)
          Text(
            score,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  Widget _buildTeamBadge({
    required String teamName,
    required String teamImage,
  }) {
    final imageUrl = _teamImageUrl(teamImage);

    return Container(
      width: 18,
      height: 18,
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
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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

  String _statusLabel(MatchItem match) {
    if (match.status == 'NS') {
      return 'UP';
    }

    return match.status;
  }

  String _scheduledTime(MatchItem match) {
    final startTime = match.startTime;
    if (match.status != 'NS' || startTime == null) {
      return '';
    }

    final hour = startTime.hour.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _initials(String teamName) {
    final parts = teamName
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
}
