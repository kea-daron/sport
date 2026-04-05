import 'package:flutter/material.dart';

import '../../models/league_option.dart';
import '../../services/live_score_service.dart';
import 'league_matches_page.dart';

class LeagueListPage extends StatefulWidget {
  const LeagueListPage({super.key});

  @override
  State<LeagueListPage> createState() => _LeagueListPageState();
}

class _LeagueListPageState extends State<LeagueListPage> {
  final LiveScoreService _liveScoreService = const LiveScoreService();
  late Future<List<LeagueOption>> _leaguesFuture;

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
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'All Leagues',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.yellow.shade600,
        backgroundColor: const Color(0xFF1E1E1E),
        onRefresh: _refreshLeagues,
        child: FutureBuilder<List<LeagueOption>>(
          future: _leaguesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(12),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.95,
                children: List.generate(
                  6,
                  (index) => Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.yellow.shade600,
                      ),
                    ),
                  ),
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

            return GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(12),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.95,
              children: leagues.map((league) => _buildLeagueCard(league)).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeagueCard(LeagueOption league) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LeagueMatchesPage(league: league),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.02),
              Colors.white.withOpacity(0.01),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.yellow.shade600, width: 1),
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
                      size: 16,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                league.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                league.subtitle,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                ),
              ),
            ),
          ],
        ),
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
}
