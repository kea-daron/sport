import 'package:flutter/material.dart';

import '../../models/match_item.dart';
import '../../services/live_score_service.dart';
import '../news/news_page.dart';
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
    _SportOption(label: 'Football', apiValue: 'soccer', icon: Icons.sports_soccer),
    _SportOption(
      label: 'Basketball',
      apiValue: 'basketball',
      icon: Icons.sports_basketball,
    ),
    _SportOption(label: 'Tennis', apiValue: 'tennis', icon: Icons.sports_tennis),
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
        builder: (_) => MatchDetailPage(
          match: match,
          category: _selectedSport.apiValue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateOptions = List<DateTime>.generate(
      5,
      (index) => _stripTime(DateTime.now().add(Duration(days: index - 2))),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Live Scores',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.yellow.shade600,
        backgroundColor: const Color(0xFF1E1E1E),
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
            const SizedBox(height: 22),
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

                final visibleMatches = matches.take(_visibleMatchesCount).toList();
                final hasMoreMatches = matches.length > visibleMatches.length;

                return Column(
                  children: [
                    ...visibleMatches.map(
                      (match) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onTap: () => _navigateToMatchDetail(match),
                          child: _buildMatchCard(match),
                        ),
                      ),
                    ),
                    if (hasMoreMatches) _buildShowMoreButton(matches.length),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _selectedSport.label.toUpperCase(),
              style: TextStyle(
                color: Colors.yellow.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isLiveMode
                ? 'Pick a sport to track matches in real time.'
                : 'Pick a sport and day to browse match schedules.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _isLiveMode
                ? 'Fast filters, clean cards, and live scores powered by the same LiveScore API.'
                : 'Switch between LIVE and specific dates without leaving this page.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportChooser() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _sports.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final sport = _sports[index];
          final isSelected = sport == _selectedSport;

          return GestureDetector(
            onTap: () => _changeSport(sport),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E1A0E) : const Color(0xFF151515),
                borderRadius: BorderRadius.circular(18),
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
                    size: 18,
                    color: isSelected ? Colors.yellow.shade600 : Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    sport.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
      height: 78,
      child: Row(
        children: [
          _buildLivePill(),
          const SizedBox(width: 10),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = !_isLiveMode && _isSameDate(date, _selectedDate);

                return GestureDetector(
                  onTap: () => _changeDate(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 86,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1B1B1B)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _topDateLabel(date),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _bottomDateLabel(date),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.82),
                            fontSize: 13,
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
          const SizedBox(width: 10),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: const Icon(Icons.calendar_month_outlined, color: Colors.white),
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
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: _isLiveMode ? const Color(0xFF1B1B1B) : const Color(0xFF121212),
          borderRadius: BorderRadius.circular(18),
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
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: CircularProgressIndicator(color: Colors.yellow.shade600),
      ),
    );
  }

  Widget _buildMessageCard({
    required String title,
    required String subtitle,
  }) {
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

  Widget _buildMatchCard(MatchItem match) {
    final showScores = match.homeScore.isNotEmpty && match.awayScore.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.yellow.shade600, width: 2),
                ),
                child: Center(
                  child: Text(
                    _initials(match.competition),
                    style: TextStyle(
                      color: Colors.yellow.shade600,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.competition,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      match.country,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.yellow.shade600, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 44,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel(match),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(width: 1, height: 40, color: Colors.white24),
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
                      const SizedBox(height: 14),
                      _buildTeamRow(
                        teamName: match.awayTeam,
                        teamImage: match.awayTeamImage,
                        score: showScores ? match.awayScore : '',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.star_outline, color: Colors.white60, size: 20),
              ],
            ),
          ),
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
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            teamName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
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
      width: 28,
      height: 28,
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
          fontSize: 10,
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
    return 'https://getimage.membertsd.workers.dev/?url=' + Uri.encodeComponent(sourceUrl);
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

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.yellow.shade600,
      unselectedItemColor: Colors.white60,
      currentIndex: 2,
      onTap: (index) {
        if (index == 2) {
          return;
        }

        if (index == 0) {
          Navigator.of(context).pushReplacementNamed('/home');
          return;
        }

        if (index == 1) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const NewsPage()),
          );
          return;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          label: 'News',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_soccer_outlined),
          label: 'Sports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_outline),
          label: 'Videos',
        ),
      ],
    );
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








