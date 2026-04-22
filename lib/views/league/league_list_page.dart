import 'package:flutter/material.dart';

import '../../models/league_option.dart';
import '../../services/live_score_service.dart';
import '../../theme/app_palette.dart';
import '../../widgets/app_skeleton.dart';
import 'league_matches_page.dart';

class LeagueListPage extends StatefulWidget {
  const LeagueListPage({super.key});

  @override
  State<LeagueListPage> createState() => _LeagueListPageState();
}

class _LeagueListPageState extends State<LeagueListPage> {
  final LiveScoreService _liveScoreService = const LiveScoreService();
  late Future<List<LeagueOption>> _leaguesFuture;
  int _visibleLeaguesCount = 4;
  static const int _leaguesPageSize = 4;

  @override
  void initState() {
    super.initState();
    _leaguesFuture = _loadLeagues();
  }

  Future<List<LeagueOption>> _loadLeagues() {
    return _liveScoreService.fetchLeagueOptions(
      category: 'soccer',
      date: DateTime.now(),
      timezone: -7,
    );
  }

  Future<void> _refreshLeagues() async {
    final future = _loadLeagues();
    setState(() {
      _leaguesFuture = future;
      _visibleLeaguesCount = 4;
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
        title: const Text(
          'All Leagues',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        color: AppPalette.accent,
        backgroundColor: AppPalette.surfaceMuted,
        onRefresh: _refreshLeagues,
        child: FutureBuilder<List<LeagueOption>>(
          future: _leaguesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SkeletonShimmer(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                  children: [
                    _buildLeagueHeroSkeleton(),
                    const SizedBox(height: 14),
                    ...List.generate(
                      6,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildLeagueSkeletonCard(),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMessageCard(
                    title: 'Unable to load leagues',
                    subtitle: '${snapshot.error}',
                  ),
                ],
              );
            }

            final leagues = snapshot.data ?? const <LeagueOption>[];
            if (leagues.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMessageCard(
                    title: 'No leagues available',
                    subtitle: 'Pull down to refresh the league list.',
                  ),
                ],
              );
            }

            final visibleLeagues = leagues.take(_visibleLeaguesCount).toList();
            final hasMoreLeagues = leagues.length > _visibleLeaguesCount;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                    child: _buildLeagueHero(),
                  ),
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visibleLeagues.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _buildLeagueCard(visibleLeagues[index]),
                  ),
                  if (hasMoreLeagues) ...[
                    const SizedBox(height: 14),
                    _buildShowMoreButton(leagues.length),
                  ],
                  const SizedBox(height: 14),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeagueHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.yellow.shade600.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'SOCCER',
              style: TextStyle(
                color: Colors.yellow.shade600,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse Leagues',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Explore all available leagues and competitions',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueCard(LeagueOption league) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => LeagueMatchesPage(league: league)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          color: Colors.white.withOpacity(0.03),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Image.network(
                    'https://getimage.membertsd.workers.dev/?url=https://storage.livescore.com/images/flag/${league.ccd}.jpg',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white.withOpacity(0.08),
                        child: Icon(
                          Icons.emoji_events_outlined,
                          color: Colors.yellow.shade600,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      league.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      league.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.yellow.shade600,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeagueSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueHeroSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBone(width: 68, height: 20, radius: 6),
          SizedBox(height: 10),
          SkeletonBone(width: 140, height: 16),
          SizedBox(height: 8),
          SkeletonBone(width: double.infinity, height: 12),
          SizedBox(height: 6),
          SkeletonBone(width: 200, height: 12),
        ],
      ),
    );
  }

  Widget _buildShowMoreButton(int totalLeagues) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              final nextCount = _visibleLeaguesCount + _leaguesPageSize;
              _visibleLeaguesCount = nextCount > totalLeagues
                  ? totalLeagues
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
}
