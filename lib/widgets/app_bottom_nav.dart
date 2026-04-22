import 'dart:ui';

import 'package:flutter/material.dart';

import '../views/league/league_list_page.dart';
import '../views/search/search_page.dart';

enum AppBottomNavTab { home, news, search, sports, leagues }

class AppBottomNav extends StatelessWidget {
  final AppBottomNavTab currentTab;

  const AppBottomNav({
    super.key,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              tab: AppBottomNavTab.home,
              icon: Icons.home_outlined,
              label: 'Home',
              onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
            ),
            _buildNavItem(
              context: context,
              tab: AppBottomNavTab.news,
              icon: Icons.description_outlined,
              label: 'News',
              onTap: () => Navigator.of(context).pushReplacementNamed('/news'),
            ),
            _buildSearchNavItem(context),
            _buildNavItem(
              context: context,
              tab: AppBottomNavTab.sports,
              icon: Icons.sports_soccer_outlined,
              label: 'Sports',
              onTap: () =>
                  Navigator.of(context).pushReplacementNamed('/livescore'),
            ),
            _buildNavItem(
              context: context,
              tab: AppBottomNavTab.leagues,
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
    required BuildContext context,
    required AppBottomNavTab tab,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = currentTab == tab;

    return GestureDetector(
      onTap: isSelected ? null : onTap,
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

  Widget _buildSearchNavItem(BuildContext context) {
    final isSelected = currentTab == AppBottomNavTab.search;

    return GestureDetector(
      onTap: isSelected
          ? null
          : () {
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
              color: Colors.yellow.shade300.withOpacity(0.25),
              borderRadius: BorderRadius.circular(30),
              
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search,
                  color: Colors.yellow.shade300,
                  size: 26,
                ),
                const SizedBox(height: 1),
                Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.yellow.shade300,
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
