import 'package:flutter/material.dart';

import '../../models/match_item.dart';
import '../../services/live_score_service.dart';
import '../../theme/app_palette.dart';
import '../../widgets/app_skeleton.dart';
import '../../widgets/app_bottom_nav.dart';
import 'match_detail_page.dart';

class LiveScorePage extends StatefulWidget {
  const LiveScorePage({super.key});

  @override
  State<LiveScorePage> createState() => _LiveScorePageState();
}

class _LiveScorePageState extends State<LiveScorePage> {
  final LiveScoreService _liveScoreService = const LiveScoreService();
  static const int _initialMatchesCount = 5;
  static const int _matchesPageSize = 5;

  static const List<_SportOption> _sports = [
    _SportOption(
      label: 'Football',
      apiValue: 'soccer',
      icon: Icons.sports_soccer,
    ),
    _SportOption(
      label: 'Cricket',
      apiValue: 'cricket',
      icon: Icons.sports_cricket,
    ),
    _SportOption(
      label: 'Basketball',
      apiValue: 'basketball',
      icon: Icons.sports_basketball,
    ),
    _SportOption(
      label: 'Tennis',
      apiValue: 'tennis',
      icon: Icons.sports_tennis,
    ),
    _SportOption(
      label: 'Hockey',
      apiValue: 'hockey',
      icon: Icons.sports_hockey,
    ),
  ];

  late _SportOption _selectedSport;
  late DateTime _selectedDate;
  late Future<List<MatchItem>> _matchesFuture;
  bool _isLiveMode = true;
  int _visibleMatchesCount = _initialMatchesCount;

  @override
  void initState() {
    super.initState();
    _selectedSport = _sports.first;
    _selectedDate = _stripTime(DateTime.now());
    _matchesFuture = _loadMatches();
  }

  Future<List<MatchItem>> _loadMatches() {
    if (_isLiveMode) {
      return _liveScoreService.fetchLiveMatches(
        category: _selectedSport.apiValue,
        timezone: -7,
      );
    }

    return _liveScoreService.fetchMatchesByDate(
      category: _selectedSport.apiValue,
      date: _selectedDate,
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

  void _changeSport(_SportOption sport) {
    if (_selectedSport == sport) {
      return;
    }

    setState(() {
      _selectedSport = sport;
      _matchesFuture = _loadMatches();
      _visibleMatchesCount = _initialMatchesCount;
    });
  }

  void _changeDate(DateTime date) {
    final normalized = _stripTime(date);
    if (_selectedDate == normalized && !_isLiveMode) {
      return;
    }

    setState(() {
      _selectedDate = normalized;
      _isLiveMode = false;
      _matchesFuture = _loadMatches();
      _visibleMatchesCount = _initialMatchesCount;
    });
  }

  void _showLiveMatches() {
    if (_isLiveMode) {
      return;
    }

    setState(() {
      _isLiveMode = true;
      _matchesFuture = _loadMatches();
      _visibleMatchesCount = _initialMatchesCount;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE3C75F),
              brightness: Brightness.dark,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF171717),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _changeDate(picked);
    }
  }

  void _navigateToMatchDetail(MatchItem match) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            MatchDetailPage(match: match, category: _selectedSport.apiValue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateOptions = List<DateTime>.generate(
      7,
      (index) => _stripTime(DateTime.now().add(Duration(days: index - 3))),
    );

    return Scaffold(
      backgroundColor: AppPalette.pageBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppPalette.pageBackground,
        foregroundColor: AppPalette.textPrimary,
        elevation: 0,
        title: const Text(
          'Live Scores',
          style: TextStyle(fontWeight: FontWeight.w700),
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
            const SizedBox(height: 18),
            _buildSportChooser(),
            const SizedBox(height: 18),
            _buildDateChooser(dateOptions),
            const SizedBox(height: 18),
            FutureBuilder<List<MatchItem>>(
              future: _matchesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildMessageCard(
                    title: 'Unable to load live scores',
                    subtitle: '${snapshot.error}',
                  );
                }

                final matches = snapshot.data ?? const <MatchItem>[];
                if (matches.isEmpty) {
                  return _buildMessageCard(
                    title: 'No matches found',
                    subtitle: _isLiveMode
                        ? 'Try another sport, or pull down to refresh.'
                        : 'Try another date or sport, or pull down to refresh.',
                  );
                }

                final groupedMatches = _groupMatchesByCompetition(matches);
                final allCompetitions = groupedMatches.keys.toList();
                final visibleCompetitions = allCompetitions
                    .take(_visibleMatchesCount)
                    .toList();
                final hasMoreMatches =
                    allCompetitions.length > visibleCompetitions.length;

                return Column(
                  children: [
                    ...visibleCompetitions.map(
                      (competition) => _buildLeagueSection(
                        competition: competition,
                        matches: groupedMatches[competition]!,
                      ),
                    ),
                    if (hasMoreMatches)
                      _buildShowMoreButton(allCompetitions.length),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(
        currentTab: AppBottomNavTab.sports,
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _selectedSport.label.toUpperCase(),
              style: TextStyle(
                color: Colors.yellow.shade600,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _isLiveMode
                ? 'Pick a sport to track matches in real time.'
                : 'Pick a sport and day to browse match schedules.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isLiveMode
                ? 'Fast filters, clean cards, and live scores powered by the same LiveScore API.'
                : 'Switch between LIVE and specific dates without leaving this page.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportChooser() {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _sports.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sport = _sports[index];
          final isSelected = sport == _selectedSport;

          return GestureDetector(
            onTap: () => _changeSport(sport),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1E1A0E)
                    : const Color(0xFF151515),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.yellow.shade600
                      : Colors.white.withOpacity(0.06),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    sport.icon,
                    size: 12,
                    color: isSelected ? Colors.yellow.shade600 : Colors.white70,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    sport.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateChooser(List<DateTime> dates) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          _buildLivePill(),
          const SizedBox(width: 6),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected =
                    !_isLiveMode && _isSameDate(date, _selectedDate);

                return GestureDetector(
                  onTap: () => _changeDate(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 50,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1B1B1B)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _topDateLabel(date),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _bottomDateLabel(date),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.82),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePill() {
    return GestureDetector(
      onTap: _showLiveMatches,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isLiveMode
              ? const Color(0xFF1B1B1B)
              : const Color(0xFF121212),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isLiveMode
                ? Colors.redAccent.withOpacity(0.7)
                : Colors.white12,
          ),
        ),
        child: const Center(
          child: Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const MatchListLoadingSkeleton(cardCount: 4);
  }

  Widget _buildMessageCard({required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 14,
              height: 1.4,
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

  Map<String, List<MatchItem>> _groupMatchesByCompetition(
    List<MatchItem> matches,
  ) {
    final grouped = <String, List<MatchItem>>{};
    for (final match in matches) {
      if (!grouped.containsKey(match.competition)) {
        grouped[match.competition] = [];
      }
      grouped[match.competition]!.add(match);
    }
    return grouped;
  }

  Widget _buildLeagueSection({
    required String competition,
    required List<MatchItem> matches,
  }) {
    if (matches.isEmpty) return const SizedBox.shrink();

    final firstMatch = matches.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // League Header
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Image.network(
                      'https://getimage.membertsd.workers.dev/?url=https://storage.livescore.com/images/flag/${firstMatch.countryCode}.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.yellow.shade600.withOpacity(0.2),
                          child: Center(
                            child: Text(
                              _initials(competition),
                              style: TextStyle(
                                color: Colors.yellow.shade600,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        competition,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        firstMatch.country,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 8,
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
            (match) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GestureDetector(
                onTap: () => _navigateToMatchDetail(match),
                child: _buildSimpleMatchCard(match),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMatchCard(MatchItem match) {
    final showScores = match.homeScore.isNotEmpty && match.awayScore.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _statusLabel(match),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 5),
                Container(width: 1.5, height: 32, color: Colors.white24),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                _buildTeamRow(
                  teamName: match.homeTeam,
                  teamImage: match.homeTeamImage,
                  redCards: match.homeRedCards,
                  score: showScores ? match.homeScore : _scheduledTime(match),
                ),
                const SizedBox(height: 6),
                _buildTeamRow(
                  teamName: match.awayTeam,
                  teamImage: match.awayTeamImage,
                  redCards: match.awayRedCards,
                  score: showScores ? match.awayScore : '',
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.star_outline, color: Colors.white60, size: 16),
        ],
      ),
    );
  }

  String _statusLabel(MatchItem match) {
    if (match.status == 'NS') {
      return 'UP';
    }
    return match.status;
  }

  Widget _buildTeamBadge({
    required String teamName,
    required String teamImage,
  }) {
    final imageUrl = _teamImageUrl(teamImage);

    return Container(
      width: 20,
      height: 20,
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

  Widget _buildTeamRow({
    required String teamName,
    required String teamImage,
    required int redCards,
    required String score,
  }) {
    return Row(
      children: [
        _buildTeamBadge(teamName: teamName, teamImage: teamImage),
        const SizedBox(width: 5),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  teamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (redCards > 0) ...[
                const SizedBox(width: 6),
                _buildRedCardBadge(redCards),
              ],
            ],
          ),
        ),
        if (score.isNotEmpty)
          Text(
            score,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  Widget _buildRedCardBadge(int count) {
    return Container(
      width: count > 1 ? 16 : 12,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.center,
      child: count > 1
          ? Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            )
          : null,
    );
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

  String _topDateLabel(DateTime date) {
    if (_isSameDate(date, _stripTime(DateTime.now()))) {
      return 'TODAY';
    }

    return _weekdayLabel(date);
  }

  String _bottomDateLabel(DateTime date) {
    final month = _monthLabel(date.month);
    return '${date.day} $month';
  }

  String _weekdayLabel(DateTime date) {
    const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return labels[date.weekday - 1];
  }

  String _monthLabel(int month) {
    const labels = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return labels[month - 1];
  }

  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

}

class _SportOption {
  final String label;
  final String apiValue;
  final IconData icon;

  const _SportOption({
    required this.label,
    required this.apiValue,
    required this.icon,
  });
}
