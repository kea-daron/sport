import 'package:flutter/material.dart';

import '../../models/search_result.dart';
import '../../services/live_score_service.dart';
import '../league/league_matches_page.dart';
import '../livescore/match_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final LiveScoreService _liveScoreService = const LiveScoreService();
  final TextEditingController _queryController = TextEditingController();

  static const List<_SearchCategory> _categories = [
    _SearchCategory(label: 'Soccer', apiValue: 'soccer', icon: Icons.sports_soccer),
    _SearchCategory(label: 'Cricket', apiValue: 'cricket', icon: Icons.sports_cricket),
    _SearchCategory(label: 'Basketball', apiValue: 'basketball', icon: Icons.sports_basketball),
    _SearchCategory(label: 'Tennis', apiValue: 'tennis', icon: Icons.sports_tennis),
    _SearchCategory(label: 'Hockey', apiValue: 'hockey', icon: Icons.sports_hockey),
  ];

  late _SearchCategory _selectedCategory;
  Future<List<SearchResult>>? _resultsFuture;
  String _submittedQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _queryController.text.trim();
    setState(() {
      _submittedQuery = query;
      _resultsFuture = query.isEmpty
          ? null
          : _liveScoreService.fetchSearchResults(
              category: _selectedCategory.apiValue,
              query: query,
            );
    });
  }

  void _changeCategory(_SearchCategory category) {
    if (_selectedCategory == category) {
      return;
    }

    setState(() {
      _selectedCategory = category;
      if (_submittedQuery.isNotEmpty) {
        _resultsFuture = _liveScoreService.fetchSearchResults(
          category: _selectedCategory.apiValue,
          query: _submittedQuery,
        );
      }
    });
  }

  void _openResult(SearchResult result) {
    if (result.canOpenMatch) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MatchDetailPage(
            match: result.toMatchItem(),
            category: result.category,
          ),
        ),
      );
      return;
    }

    if (result.canOpenLeague) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LeagueMatchesPage(league: result.toLeagueOption()),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This result does not include enough data to open.'),
      ),
    );
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
          'Search',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildSearchBox(),
          const SizedBox(height: 16),
          _buildCategoryPicker(),
          const SizedBox(height: 20),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      controller: _queryController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _submitSearch(),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search teams, leagues, or matches',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: const Color(0xFF141414),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        suffixIcon: IconButton(
          onPressed: _submitSearch,
          icon: Icon(Icons.arrow_forward, color: Colors.yellow.shade600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.yellow.shade600),
        ),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) {
        final isSelected = category == _selectedCategory;
        return InkWell(
          onTap: () => _changeCategory(category),
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.yellow.shade600 : const Color(0xFF141414),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? Colors.yellow.shade600
                    : Colors.white.withOpacity(0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 18,
                  color: isSelected ? Colors.black : Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  category.label,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBody() {
    if (_resultsFuture == null) {
      return _buildMessageCard(
        title: 'Start a search',
        subtitle: 'Pick a sport and search for a team, league, or match keyword.',
      );
    }

    return FutureBuilder<List<SearchResult>>(
      future: _resultsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _buildMessageCard(
            title: 'Unable to search right now',
            subtitle: '${snapshot.error}',
          );
        }

        final results = snapshot.data ?? const <SearchResult>[];
        if (results.isEmpty) {
          return _buildMessageCard(
            title: 'No results found',
            subtitle: 'No matches were found for "$_submittedQuery" in ${_selectedCategory.label}.',
          );
        }

        return Column(
          children: results.map(_buildResultCard).toList(),
        );
      },
    );
  }

  Widget _buildResultCard(SearchResult result) {
    final canOpen = result.canOpenMatch || result.canOpenLeague;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: canOpen ? () => _openResult(result) : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              _buildLeading(result),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    if (result.homeTeam.isNotEmpty || result.awayTeam.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${result.homeTeam}${result.awayTeam.isNotEmpty ? ' vs ${result.awayTeam}' : ''}',
                        style: TextStyle(
                          color: Colors.yellow.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildTypeBadge(result.type),
                  const SizedBox(height: 10),
                  Icon(
                    canOpen ? Icons.arrow_forward_ios : Icons.info_outline,
                    size: 16,
                    color: canOpen ? Colors.yellow.shade600 : Colors.white38,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(SearchResult result) {
    if (result.imageUrl.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          result.imageUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(),
        ),
      );
    }

    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF292929), Color(0xFF1A1A1A)],
        ),
      ),
      child: Icon(Icons.sports, color: Colors.yellow.shade600),
    );
  }

  Widget _buildTypeBadge(String type) {
    final normalized = type.trim().isEmpty ? 'item' : type;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalized.toUpperCase(),
        style: TextStyle(
          color: Colors.yellow.shade600,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
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
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchCategory {
  final String label;
  final String apiValue;
  final IconData icon;

  const _SearchCategory({
    required this.label,
    required this.apiValue,
    required this.icon,
  });
}
