import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/news_item.dart';
import '../../services/live_score_service.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final LiveScoreService _liveScoreService = const LiveScoreService();

  static const String _sportCategoryId = '20210209133211500030'; // Soccer category ID
  
  final List<_NewsBannerItem> _bannerItems = const [
    _NewsBannerItem(
      image: 'https://wallpapers.com/images/featured/soccer-y8vz4oxbfbc5t6lr.jpg',
      title: 'Football headlines and transfer talk from around the world',
    ),
    _NewsBannerItem(
      image: 'https://images5.alphacoders.com/995/995260.jpg',
      title: 'Basketball spotlight: the biggest stories from today',
    ),
    _NewsBannerItem(
      image: 'https://wallpapersok.com/images/hd/soccer-teams-fc-barcelona-and-real-madrid-cf-u78rrvtgn14nbzz4.jpg',
      title: 'Championship pressure rises as teams battle for every point',
    ),
    _NewsBannerItem(
      image: 'https://assets.fiba.basketball/image/upload/v1722790482/i3n5qmg4nlp1mome7paw.jpg',
      title: 'Tennis stars prepare for another dramatic week on tour',
    ),
    _NewsBannerItem(
      image: 'https://images2.alphacoders.com/138/thumb-1920-1388695.jpg',
      title: 'Matchday stories, tactical shifts, and breakout performers',
    ),
    _NewsBannerItem(
      image: 'https://wallpapers.com/images/hd/nick-kyrgios-in-a-tennis-match-5lhkuvgoxgag2c5w.jpg',
      title: 'Basketball rivalries heat up with playoff hopes on the line',
    ),
    _NewsBannerItem(
      image: 'https://pbs.twimg.com/media/FUwgT9IWYAITRpr.jpg',
      title: 'Football form guide: who is rising and who is fading',
    ),
    _NewsBannerItem(
      image: 'https://www.mancity.com/meta/media/eufgytr1/tf300516-f-1920x1080-52dc979.jpg?width=1620',
      title: 'Top athletes, strong finishes, and headlines worth watching',
    ),
    _NewsBannerItem(
      image: 'https://images4.alphacoders.com/139/1394952.png',
      title: 'Latest sports reactions, momentum swings, and key moments',
    ),
    _NewsBannerItem(
      image: 'https://upload.wikimedia.org/wikipedia/commons/0/06/Steph_Curry_%2851915116957%29.jpg',
      title: 'Every sport, one feed: the stories setting the pace today',
    ),
  ];

  late Future<List<NewsItem>> _newsFuture;
  late PageController _bannerController;
  late Timer _bannerTimer;
  int _currentBannerIndex = 0;
  int _currentPage = 1;
  List<NewsItem> _allNews = [];
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _newsFuture = _loadNews().then((news) {
      _allNews = news;
      return news;
    });
    _bannerController = PageController();
    _startBannerAnimation();
  }

  Future<List<NewsItem>> _loadNews() async {
    try {
      final news = await _liveScoreService.fetchNewsBySport(
        categoryId: _sportCategoryId,
        page: _currentPage,
      );
      
      // If new endpoint returns empty, fall back to old news API
      if (news.isEmpty && _currentPage == 1) {
        print('DEBUG: New news endpoint returned empty, falling back to old endpoint');
        return await _liveScoreService.fetchNews();
      }
      
      return news;
    } catch (e) {
      print('DEBUG: Error loading news from new endpoint: $e, falling back to old endpoint');
      // Fall back to old news endpoint on error
      if (_currentPage == 1) {
        return await _liveScoreService.fetchNews();
      }
      return [];
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final moreNews = await _liveScoreService.fetchNewsBySport(
        categoryId: _sportCategoryId,
        page: _currentPage,
      );
      
      // If new endpoint returns nothing, try old endpoint
      final news = moreNews.isNotEmpty ? moreNews : await _liveScoreService.fetchNews();
      
      setState(() {
        _allNews.addAll(news);
      });
    } catch (e) {
      _currentPage--;
      print('DEBUG: Error loading more news: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more news: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _refreshNews() async {
    _currentPage = 1;
    _allNews = [];
    final future = _loadNews().then((news) {
      _allNews = news;
      return news;
    });
    setState(() {
      _newsFuture = future;
    });
    await future;
  }

  void _startBannerAnimation() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_bannerController.hasClients || _bannerItems.isEmpty) {
        return;
      }

      _currentBannerIndex = (_currentBannerIndex + 1) % _bannerItems.length;
      _bannerController.animateToPage(
        _currentBannerIndex,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'News',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.yellow.shade600,
        backgroundColor: const Color(0xFF1E1E1E),
        onRefresh: _refreshNews,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildFeaturedBanner(),
            const SizedBox(height: 18),
            _buildHeroHeader(),
            const SizedBox(height: 18),
            FutureBuilder<List<NewsItem>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 220,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white70),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildNewsPlaceholder('Unable to load news right now.');
                }

                final newsItems = snapshot.data ?? const <NewsItem>[];
                if (newsItems.isEmpty) {
                  return _buildNewsPlaceholder(
                    'No news articles available right now.',
                  );
                }

                // Show all accumulated news from all pages
                final visibleNews = _allNews.isNotEmpty ? _allNews : newsItems;
                final hasMoreNews = _allNews.isNotEmpty; // Always show button if we loaded from API

                return Column(
                  children: [
                    ...visibleNews.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: entry.key.isEven
                            ? _buildNewsPosterCard(item: entry.value)
                            : _buildNewsSplitCard(item: entry.value),
                      ),
                    ),
                    if (hasMoreNews) _buildShowMoreNewsButton(visibleNews.length),
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

  Widget _buildFeaturedBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 240,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: PageView.builder(
              controller: _bannerController,
              itemCount: _bannerItems.length,
              onPageChanged: (index) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final item = _bannerItems[index];

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.image,
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
                            Colors.black.withOpacity(0.82),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 22,
                      child: Text(
                        item.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _bannerItems.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? Colors.yellow.shade600
                    : Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
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
          colors: [Color(0xFF1A1A1A), Color(0xFF191B10)],
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
              'LATEST STORIES',
              style: TextStyle(
                color: Colors.yellow.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Catch up on the latest sports headlines and match stories.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Pull to refresh anytime and load more stories as you browse.',
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

  Widget _buildShowMoreNewsButton(int totalNews) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoadingMore ? null : _loadMoreNews,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: _isLoadingMore 
                ? Colors.yellow.shade600.withOpacity(0.5)
                : Colors.yellow.shade600,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoadingMore
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.yellow.shade600),
                ),
              )
            : Text(
                'Show More',
                style: TextStyle(
                  color: Colors.yellow.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildNewsPosterCard({
    required NewsItem item,
  }) {
    final accent = _newsAccent(item.category);
    final meta = _formatNewsMeta(item);

    return Container(
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
    );
  }

  Widget _buildNewsSplitCard({
    required NewsItem item,
  }) {
    final meta = _formatNewsMeta(item);

    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 150,
            height: double.infinity,
            child: item.imageUrl.isEmpty
                ? _buildImageFallback(background: const Color(0xFF303030))
                : Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImageFallback(
                        background: const Color(0xFF303030),
                      );
                    },
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.headline,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.source.isEmpty ? 'LiveScore' : item.source,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 26,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        color: Colors.white.withOpacity(0.14),
                      ),
                      Text(
                        _compactPublishedAt(item.publishedAt),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.42),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
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
      decoration: const BoxDecoration(
        color: Color(0xFFF5F3EF),
      ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1D),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: Colors.white.withOpacity(0.78),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildImageFallback({
    Color background = const Color(0xFF1B1B1B),
    IconData icon = Icons.broken_image_outlined,
  }) {
    return Container(
      color: background,
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: Colors.white54,
        size: 36,
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

  String _compactPublishedAt(String value) {
    final formatted = _formatPublishedAt(value);
    return formatted.isEmpty ? 'Just now' : formatted;
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

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.yellow.shade600,
      unselectedItemColor: Colors.white60,
      currentIndex: 1,
      onTap: (index) {
        if (index == 1) {
          return;
        }

        if (index == 0) {
          Navigator.of(context).pushReplacementNamed('/home');
          return;
        }

        if (index == 2) {
          Navigator.of(context).pushReplacementNamed('/livescore');
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

class _NewsBannerItem {
  final String image;
  final String title;

  const _NewsBannerItem({
    required this.image,
    required this.title,
  });
}
