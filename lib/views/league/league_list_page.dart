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
          'Choose League',
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
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.yellow.shade600,
                      ),
                    ),
                  ),
                ],
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

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeroHeader(leagues.length),
                const SizedBox(height: 20),
                ...leagues.map(_buildLeagueCard),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroHeader(int count) {
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
          Text(
            'LEAGUES',
            style: TextStyle(
              color: Colors.yellow.shade600,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '$count available league views',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'These league codes come from the working list-by-date response, so they are safer than hardcoded examples.',
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

  Widget _buildLeagueCard(LeagueOption league) {
    final suffix = league.scd.isEmpty ? '' : ' ? ${league.scd}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LeagueMatchesPage(league: league),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1A0E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.yellow.shade600),
                ),
                child: Icon(
                  Icons.emoji_events_outlined,
                  color: Colors.yellow.shade600,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      league.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${league.subtitle}$suffix',
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
