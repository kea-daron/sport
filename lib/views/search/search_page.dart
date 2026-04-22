import 'package:flutter/material.dart';

import '../../models/search_result.dart';
import '../../services/live_score_service.dart';
import '../../theme/app_palette.dart';
import '../../widgets/app_skeleton.dart';
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
    _SearchCategory(
      label: 'Soccer',
      apiValue: 'soccer',
      icon: Icons.sports_soccer,
    ),
    _SearchCategory(
      label: 'Cricket',
      apiValue: 'cricket',
      icon: Icons.sports_cricket,
    ),
    _SearchCategory(
      label: 'Basketball',
      apiValue: 'basketball',
      icon: Icons.sports_basketball,
    ),
    _SearchCategory(
      label: 'Tennis',
      apiValue: 'tennis',
      icon: Icons.sports_tennis,
    ),
    _SearchCategory(
      label: 'Hockey',
      apiValue: 'hockey',
      icon: Icons.sports_hockey,
    ),
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
      backgroundColor: AppPalette.pageBackground,
      appBar: AppBar(
        backgroundColor: AppPalette.pageBackground,
        foregroundColor: AppPalette.textPrimary,
        elevation: 0,
        title: const Text(
          'Search',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _buildSearchBox(),
          const SizedBox(height: 20),
          _buildCategoryPicker(),
          const SizedBox(height: 24),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _queryController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _submitSearch(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search teams, leagues, or matches',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 14,
          ),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(
              Icons.search,
              color: Colors.white54,
              size: 28,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          suffixIcon: IconButton(
            onPressed: _submitSearch,
            icon: Icon(
              Icons.arrow_forward,
              color: Colors.white54,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.white38,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Sports',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _categories.map((category) {
            final isSelected = category == _selectedCategory;
            return InkWell(
              onTap: () => _changeCategory(category),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white12
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white38
                        : Colors.white12,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 20,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_resultsFuture == null) {
      return _buildMessageCard(
        title: 'Start a search',
        subtitle:
            'Pick a sport and search for a team, league, or match keyword.',
      );
    }

    return FutureBuilder<List<SearchResult>>(
      future: _resultsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SearchResultsLoadingSkeleton();
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
            subtitle:
                'No matches were found for "$_submittedQuery" in ${_selectedCategory.label}.',
          );
        }

        return Column(children: results.map(_buildResultCard).toList());
      },
    );
  }

  Widget _buildResultCard(SearchResult result) {
    final canOpen = result.canOpenMatch || result.canOpenLeague;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: canOpen ? () => _openResult(result) : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E1E1E),
                const Color(0xFF141414),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildLeading(result),
                const SizedBox(width: 14),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      if (result.homeTeam.isNotEmpty ||
                          result.awayTeam.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white12,
                            ),
                          ),
                          child: Text(
                            '${result.homeTeam}${result.awayTeam.isNotEmpty ? ' vs ${result.awayTeam}' : ''}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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
                    const SizedBox(height: 12),
                    Icon(
                      canOpen ? Icons.arrow_forward_ios : Icons.info_outline,
                      size: 18,
                      color: Colors.white54,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(SearchResult result) {
    if (result.imageUrl.trim().isNotEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white12,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          result.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(),
        ),
      );
    }

    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white12,
        border: Border.all(
          color: Colors.white12,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.sports,
          color: Colors.white54,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    final normalized = type.trim().isEmpty ? 'item' : type;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: Text(
        normalized.toUpperCase(),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildMessageCard({required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1E1E),
            const Color(0xFF141414),
          ],
        ),
        border: Border.all(
          color: Colors.white12,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 13,
                height: 1.5,
              ),
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
