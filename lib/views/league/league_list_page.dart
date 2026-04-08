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
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.08,
                          ),
                      itemCount: 6,
                      itemBuilder: (_, __) => _buildLeagueSkeletonCard(),
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
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    child: _buildLeagueHero(),
                  ),
                  GridView.builder(
                    padding: const EdgeInsets.all(14),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.08,
                        ),
                    itemCount: visibleLeagues.length,
                    itemBuilder: (context, index) =>
                        _buildLeagueCard(visibleLeagues[index]),
                  ),
                  if (hasMoreLeagues) _buildShowMoreButton(leagues.length),
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
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF181818), Color(0xFF221C08)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'SOCCER',
              style: TextStyle(
                color: Colors.yellow.shade600,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Browse Leagues',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Find competitions faster with clearer cards, stronger labels, and a cleaner league grid.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 9,
              height: 1.35,
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
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF151515),
              Colors.yellow.shade600.withOpacity(0.05),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.yellow.shade600.withOpacity(0.9),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.shade600.withOpacity(0.18),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      'https://getimage.membertsd.workers.dev/?url=https://storage.livescore.com/images/flag/${league.ccd}.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.yellow.shade600.withOpacity(0.2),
                          child: const Icon(
                            Icons.emoji_events_outlined,
                            color: Color(0xFFE3C75F),
                            size: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      color: Colors.yellow.shade600,
                      size: 10,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                league.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                league.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.68),
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [
                      Colors.yellow.shade600,
                      Colors.yellow.shade600.withOpacity(0.18),
                    ],
                  ),
                ),
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
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 70,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(999),
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
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBone(width: 68, height: 18, radius: 999),
          SizedBox(height: 12),
          SkeletonBone(width: 140, height: 14),
          SizedBox(height: 8),
          SkeletonBone(width: double.infinity, height: 10),
          SizedBox(height: 6),
          SkeletonBone(width: 190, height: 10),
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
