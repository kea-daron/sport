import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/match_item.dart';
import '../../models/news_item.dart';
import '../../services/live_score_service.dart';
import '../../theme/app_palette.dart';
import '../../widgets/app_skeleton.dart';
import '../league/league_list_page.dart';
import '../livescore/livescore_page.dart';
import '../livescore/match_detail_page.dart';
import '../news/news_page.dart';
import '../news/news_detail_page.dart';
import '../search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LiveScoreService _liveScoreService = const LiveScoreService();
  static const int _initialNewsCount = 5;
  static const int _newsPageSize = 5;
  static const int _matchesPerLeague = 5;
  static const double _teamLogoScrollStep = 1.2;

  int _selectedIndex = 0;
  late PageController _bannerController;
  late ScrollController _teamLogoScrollController;
  int _currentBannerIndex = 0;
  late Timer _bannerTimer;
  Timer? _teamLogoTimer;
  late Future<List<MatchItem>> _matchesFuture;
  late Future<List<NewsItem>> _newsFuture;
  int _visibleNewsCount = _initialNewsCount;
  int _visibleLeaguesCount = 1;

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
      image:
          'https://content.api.news/v3/images/bin/03d3123947edf8a43abbc6df89405722',
      title: 'Top performers shine in league-wide victories',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _teamLogoScrollController = ScrollController();
    _matchesFuture = _loadMatches();
    _newsFuture = _loadNews();
    _startBannerAnimation();
    _startTeamLogoAnimation();
  }

  Future<List<MatchItem>> _loadMatches() {
    return _liveScoreService.fetchMatchesByDate(
      category: 'soccer',
      date: DateTime.now(),
      timezone: -7,
    );
  }

  Future<List<NewsItem>> _loadNews() {
    return _liveScoreService.fetchNews();
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

  void _startTeamLogoAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _teamLogoTimer?.cancel();
      _teamLogoTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
        if (!mounted || !_teamLogoScrollController.hasClients) {
          return;
        }

        final position = _teamLogoScrollController.position;
        if (!position.hasPixels || position.maxScrollExtent <= 0) {
          return;
        }
        final nextOffset = position.pixels + _teamLogoScrollStep;
        if (nextOffset >= position.maxScrollExtent) {
          _teamLogoScrollController.jumpTo(0);
        } else {
          _teamLogoScrollController.jumpTo(nextOffset);
        }
      });
    });
  }

  Future<void> _refreshMatches() async {
    final matchesFuture = _loadMatches();
    final newsFuture = _loadNews();
    setState(() {
      _matchesFuture = matchesFuture;
      _newsFuture = newsFuture;
      _visibleNewsCount = _initialNewsCount;
      _visibleLeaguesCount = 1;
    });
    await Future.wait([matchesFuture, newsFuture]);
  }

  void _showMoreLeagues() {
    setState(() {
      _visibleLeaguesCount += 1;
    });
  }

  @override
  void dispose() {
    _bannerTimer.cancel();
    _bannerController.dispose();
    _teamLogoTimer?.cancel();
    _teamLogoScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.pageBackground,
      body: RefreshIndicator(
        color: AppPalette.accent,
        backgroundColor: AppPalette.surfaceMuted,
        onRefresh: _refreshMatches,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeaturedSection(),
              const SizedBox(height: 1),
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
    return SizedBox(
      height: 330,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 300,
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
                        Positioned.fill(
                          child: Image.network(
                            bannerList[index].image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImageFallback();
                            },
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
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMatch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Scores Today',
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
                icon: Icon(
                  Icons.refresh,
                  color: Colors.yellow.shade600,
                  size: 18,
                ),
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
                  title: 'No matches scheduled today',
                  subtitle: 'Try another refresh or check back later today.',
                );
              }

              final groupedMatches = _groupMatchesByCompetition(matches);
              final allLeagues = groupedMatches.keys.toList();
              final visibleLeagues = allLeagues
                  .take(_visibleLeaguesCount)
                  .toList();
              final hasMoreLeagues = allLeagues.length > visibleLeagues.length;

              return Column(
                children: [
                  ...visibleLeagues.map(
                    (league) => _buildLeagueSection(
                      competition: league,
                      matches: groupedMatches[league]!,
                    ),
                  ),
                  if (hasMoreLeagues) _buildShowMoreLeaguesButton(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShowMoreLeaguesButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _showMoreLeagues,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.yellow.shade600),
            padding: const EdgeInsets.symmetric(vertical: 1),
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
    return const MatchListLoadingSkeleton(cardCount: 3, showHeader: false);
  }

  Widget _buildMatchesMessage({
    required String title,
    required String subtitle,
  }) {
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
    final visibleMatches = matches.take(_matchesPerLeague).toList();

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
          ...visibleMatches.map(
            (match) => GestureDetector(
              onTap: () => _navigateToMatchDetail(match),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _buildSimpleMatchCard(match),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMatchDetail(MatchItem match) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MatchDetailPage(match: match, category: 'soccer'),
      ),
    );
  }

  void _openNewsDetail(NewsItem item) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => NewsDetailPage(item: item)));
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

  Widget _buildTeamRow({
    required String teamName,
    required String teamImage,
    required int redCards,
    required String score,
  }) {
    return Row(
      children: [
        _buildTeamBadge(teamName: teamName, teamImage: teamImage),
        const SizedBox(width: 6),
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
                    fontSize: 11,
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

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
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
    const double logoSize = 66;
    final teams = [
      'assets/logo_sport/1.png',
      'assets/logo_sport/2.png',
      'assets/logo_sport/3.png',
      'assets/logo_sport/7.png',
      'assets/logo_sport/28.png',
      'assets/logo_sport/27.png',
      'assets/logo_sport/26.png',
      'assets/logo_sport/24.png',
      'assets/logo_sport/21.png',
      'assets/logo_sport/22.png',
      'assets/logo_sport/23.png',
      'assets/logo_sport/24.png',
    ];
    final marqueeTeams = [...teams, ...teams];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _teamLogoScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: marqueeTeams.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: logoSize,
              child: Center(
                child: SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: Image.asset(
                    marqueeTeams[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.shield_outlined,
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedHighlights() {
    final highlightItems = [
      (
        title: 'Nebraska takes lead with 2.2 seconds left...',
        meta: '5h ago',
        image:
            'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=900&fit=crop',
      ),
      (
        title: '... and wins when Vandy\'s last-second heave JUST misses',
        meta: '6h ago . 2m read',
        image:
            'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=900&fit=crop',
      ),
      (
        title: 'Durant passes Jordan for NBA\'s scoring mark',
        meta: '6h ago',
        image:
            'https://images.unsplash.com/photo-1519861531473-9200262188bf?w=900&fit=crop',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Video Highlights',
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
          SizedBox(
            height: 320,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: highlightItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                final item = highlightItems[index];
                return _buildHighlightVideoCard(
                  title: item.title,
                  meta: item.meta,
                  imageUrl: item.image,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightVideoCard({
    required String title,
    required String meta,
    required String imageUrl,
  }) {
    return SizedBox(
      width: 288,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFF1B1B1B),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageFallback();
                  },
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.14),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.95),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            meta,
            style: TextStyle(
              color: Colors.white.withOpacity(0.68),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return FutureBuilder<List<NewsItem>>(
      future: _newsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: NewsFeedLoadingSkeleton(),
          );
        }

        if (snapshot.hasError) {
          return _buildNewsPlaceholder('Unable to load news right now.');
        }

        final newsItems = snapshot.data ?? const <NewsItem>[];
        if (newsItems.isEmpty) {
          return _buildNewsPlaceholder('No news articles available right now.');
        }

        final visibleNews = newsItems.take(_visibleNewsCount).toList();
        final hasMoreNews = newsItems.length > visibleNews.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'News',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...visibleNews.map(
              (item) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: _buildNewsPosterCard(item: item),
              ),
            ),
            if (hasMoreNews) _buildShowMoreNewsButton(newsItems.length),
          ],
        );
      },
    );
  }

  Widget _buildShowMoreNewsButton(int totalNews) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              final nextCount = _visibleNewsCount + _newsPageSize;
              _visibleNewsCount = nextCount > totalNews ? totalNews : nextCount;
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

  Widget _buildNewsPosterCard({required NewsItem item}) {
    final accent = _newsAccent(item.category);
    final meta = _formatNewsMeta(item);

    return InkWell(
      onTap: () => _openNewsDetail(item),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D1D),
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNewsPosterArtwork(
              accent: accent,
              label: item.category.toUpperCase(),
              imageUrl: item.imageUrl,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.headline,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  if (item.summary.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    meta,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsPosterArtwork({
    required Color accent,
    required String label,
    required String imageUrl,
  }) {
    return Container(
      height: 270,
      decoration: const BoxDecoration(color: Color(0xFFF5F3EF)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isEmpty)
            _buildImageFallback(
              background: accent.withOpacity(0.2),
              icon: Icons.image_not_supported_outlined,
            )
          else
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImageFallback(
                  background: accent.withOpacity(0.2),
                  icon: Icons.image_not_supported_outlined,
                );
              },
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.08),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
          Positioned(
            top: 18,
            left: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.newspaper_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsPlaceholder(String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D1D),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.white.withOpacity(0.78), fontSize: 14),
        ),
      ),
    );
  }

  String _formatNewsMeta(NewsItem item) {
    final parts = <String>[];
    if (item.source.isNotEmpty) {
      parts.add(item.source);
    }

    final published = _formatPublishedAt(item.publishedAt);
    if (published.isNotEmpty) {
      parts.add(published);
    }

    return parts.isEmpty ? 'LiveScore News' : parts.join(' . ');
  }

  String _formatPublishedAt(String value) {
    if (value.trim().isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }

    final now = DateTime.now();
    final difference = now.difference(parsed.toLocal());
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes.clamp(1, 59);
      return '${minutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inDays}d ago';
  }

  Color _newsAccent(String category) {
    switch (category.toLowerCase()) {
      case 'transfer':
        return const Color(0xFF0F7B63);
      case 'breaking':
        return const Color(0xFFB3261E);
      case 'match report':
        return const Color(0xFF6F4B00);
      default:
        return const Color(0xFF0E4DAA);
    }
  }

  Widget _buildImageFallback({
    Color background = const Color(0xFF1B1B1B),
    IconData icon = Icons.broken_image_outlined,
  }) {
    return Container(
      color: background,
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white54, size: 36),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_outlined,
              label: 'Home',
              onTap: () {
                setState(() => _selectedIndex = 0);
              },
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.description_outlined,
              label: 'News',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NewsPage()),
                );
              },
            ),
            _buildSearchNavItem(),
            _buildNavItem(
              index: 3,
              icon: Icons.sports_soccer_outlined,
              label: 'Sports',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LiveScorePage()),
                );
              },
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.format_list_bulleted_outlined,
              label: 'Leagues',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LeagueListPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.yellow.shade600 : Colors.white54,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.yellow.shade600 : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchNavItem() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SearchPage()),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.yellow.shade600.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.yellow.shade600.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search,
                  color: Colors.yellow.shade600,
                  size: 26,
                ),
                const SizedBox(height: 1),
                Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.yellow.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BannerData {
  final String image;
  final String title;

  BannerData({required this.image, required this.title});
}
