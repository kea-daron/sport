import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/match_item.dart';
import '../../services/live_score_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LiveScoreService _liveScoreService = const LiveScoreService();
  static const int _initialMatchesCount = 5;
  static const int _matchesPageSize = 5;

  int _selectedIndex = 0;
  late PageController _bannerController;
  int _currentBannerIndex = 0;
  late Timer _bannerTimer;
  late Future<List<MatchItem>> _matchesFuture;
  int _visibleMatchesCount = _initialMatchesCount;

  final List<BannerData> bannerList = [
    BannerData(
      image: 'https://cdn.wallpapersafari.com/11/39/2BwJ7I.jpg',
      title: 'Round of 32 takeaways: Nebraska survives Vandy prayer',
    ),
    BannerData(
      image: 'https://images5.alphacoders.com/995/995260.jpg',
      title: 'Championship Finals: The most thrilling moments',
    ),
    BannerData(
      image: 'https://content.api.news/v3/images/bin/03d3123947edf8a43abbc6df89405722',
      title: 'Top performers shine in league-wide victories',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _matchesFuture = _loadMatches();
    _startBannerAnimation();
  }

  Future<List<MatchItem>> _loadMatches() {
    return _liveScoreService.fetchMatchesByDate(
      category: 'soccer',
      date: DateTime.now(),
      timezone: -7,
    );
  }

  void _startBannerAnimation() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % bannerList.length;
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
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
  void dispose() {
    _bannerTimer.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: RefreshIndicator(
        color: Colors.yellow.shade600,
        backgroundColor: const Color(0xFF1E1E1E),
        onRefresh: _refreshMatches,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeaturedSection(),
              const SizedBox(height: 24),
              _buildLiveMatch(),
              const SizedBox(height: 24),
              _buildTeamLogos(),
              const SizedBox(height: 24),
              _buildFeaturedHighlights(),
              const SizedBox(height: 24),
              _buildNewsSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: bannerList.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(bannerList[index].image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      children: [
                        _buildTopIcon(Icons.search),
                        const SizedBox(width: 12),
                        _buildTopIcon(Icons.notifications_outlined),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FEATURED',
                              style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bannerList[index].title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              bannerList.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _currentBannerIndex ? 24 : 8,
                height: 3,
                decoration: BoxDecoration(
                  color: index == _currentBannerIndex
                      ? Colors.yellow.shade600
                      : Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopIcon(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildLiveMatch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Scores',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _matchesFuture = _loadMatches();
                  });
                },
                icon: Icon(Icons.refresh, color: Colors.yellow.shade600, size: 18),
                label: Text(
                  'Refresh',
                  style: TextStyle(
                    color: Colors.yellow.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<MatchItem>>(
            future: _matchesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildMatchesLoading();
              }

              if (snapshot.hasError) {
                return _buildMatchesMessage(
                  title: 'Unable to load matches',
                  subtitle: '${snapshot.error}',
                );
              }

              final matches = snapshot.data ?? const <MatchItem>[];
              if (matches.isEmpty) {
                return _buildMatchesMessage(
                  title: 'No soccer matches found',
                  subtitle: 'Try again later or pull down to refresh.',
                );
              }

              final visibleMatches = matches.take(_visibleMatchesCount).toList();
              final hasMoreMatches = matches.length > visibleMatches.length;

              return Column(
                children: [
                  ...visibleMatches.map(_buildMatchCard),
                  if (hasMoreMatches) _buildShowMoreButton(matches.length),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShowMoreButton(int totalMatches) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
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
              borderRadius: BorderRadius.circular(14),
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

  Widget _buildMatchesLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFC857)),
      ),
    );
  }

  Widget _buildMatchesMessage({required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
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
    if (imagePath.trim().isEmpty) {
      return null;
    }

    final sourceUrl = Uri.encodeComponent(
      'https://storage.livescore.com/images/team/medium/$imagePath',
    );
    return 'https://getimage.membertsd.workers.dev/?url=$sourceUrl';
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

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return '--';
    }
    if (parts.length == 1) {
      final end = parts.first.length < 2 ? parts.first.length : 2;
      return parts.first.substring(0, end).toUpperCase();
    }

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _buildTeamLogos() {
    final teams = [
      'assets/logo_sport/2.png',
      'assets/logo_sport/2.png',
      'assets/logo_sport/2.png',
      'assets/logo_sport/2.png',
      'assets/logo_sport/2.png',
      'assets/logo_sport/2.png',
      'assets/logo_sport/2.png',
      'assets/logo_sport/2.png',
      'assets/logo_sport/2.png',
      'assets/logo_sport/2.png',
      'assets/logo_sport/2.png',
      'assets/logo_sport/2.png',
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: teams.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 60,
              child: Center(
                child: Image.asset(teams[index], width: 80, height: 80),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedHighlights() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'See All',
                style: TextStyle(
                  color: Colors.yellow.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightPoster(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 16, 18, 6),
                  child: Text(
                    'March Madness Round of 32: Best bets, survivor picks for Sunday',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    '6h ago . 5m read',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: Row(
                    children: [
                      _buildMetaStat(Icons.favorite_border, '123k'),
                      const SizedBox(width: 18),
                      _buildMetaStat(Icons.mode_comment_outlined, '92'),
                      const Spacer(),
                      Icon(
                        Icons.more_horiz,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightPoster() {
    return Container(
      height: 245,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F3EF),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 190,
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0E4DAA), Color(0xFF2481F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -10,
            child: Transform.rotate(
              angle: -0.75,
              child: Container(
                width: 170,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFF2481F1),
                ),
              ),
            ),
          ),
          Positioned(
            left: 145,
            top: -10,
            child: Transform.rotate(
              angle: 0.78,
              child: Container(
                width: 140,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF2481F1),
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 16,
            child: Text(
              '........',
              style: TextStyle(
                color: const Color(0xFFF5F3EF).withOpacity(0.95),
                letterSpacing: 4,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Positioned(
            right: 18,
            top: 22,
            child: Text(
              'ALDENAIRE & PARTNERS',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    'FOOTBALL',
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width < 380 ? 54 : 64,
                      height: 0.95,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            right: 22,
            bottom: 22,
            child: Text(
              'HIGHLIGHT',
              style: TextStyle(
                color: Color(0xFF0E4DAA),
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: SizedBox(
              width: 190,
              height: 170,
              child: Image.asset(
                'assets/images/1.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 76,
            child: Text(
              '....\n....',
              style: TextStyle(
                color: const Color(0xFF0E4DAA).withOpacity(0.9),
                height: 0.8,
                letterSpacing: 4,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            left: 120,
            bottom: 10,
            child: Text(
              '.............',
              style: TextStyle(
                color: const Color(0xFF0E4DAA).withOpacity(0.9),
                letterSpacing: 4,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.88), size: 20),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            'News',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1556228578898-c89b6b1bac34?w=800&fit=crop',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade700,
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ALLIANZ & PARTNERS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      selectedItemColor: Colors.yellow.shade600,
      unselectedItemColor: Colors.white60,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
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

class BannerData {
  final String image;
  final String title;

  BannerData({
    required this.image,
    required this.title,
  });
}
