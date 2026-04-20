import 'package:flutter/material.dart';
import '../match_detail_helpers.dart';

// ── Team badge (28×28 with fallback initials) ─────────────────────────────

class MiniTeamBadge extends StatelessWidget {
  final String teamName;
  final String imagePath;
  final Color accentColor;

  const MiniTeamBadge({
    super.key,
    required this.teamName,
    required this.imagePath,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final url = H.teamImageUrl(imagePath);
    if (url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url, width: 28, height: 28, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(
      color: accentColor.withOpacity(0.18),
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.center,
    child: Text(H.initials(teamName),
        style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w800)),
  );
}

// ── Team badge circle (56×56 for match header) ────────────────────────────

class TeamBadgeCircle extends StatelessWidget {
  final String teamName;
  final String teamImage;
  final double size;

  const TeamBadgeCircle({
    super.key,
    required this.teamName,
    required this.teamImage,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final url = H.teamImageUrl(teamImage);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? _initials()
          : Image.network(url, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initials()),
    );
  }

  Widget _initials() => Center(
    child: Text(H.initials(teamName),
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
  );
}

// ── Info card (orange border, used when data is unavailable) ─────────────

class InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final Color accentColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.message,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.45)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: accentColor, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(message,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontSize: 13,
                  height: 1.4)),
        ],
      ),
    );
  }
}

// ── Simple full-page info state ────────────────────────────────────────────

class SimpleInfoState extends StatelessWidget {
  final String title;
  final String message;
  final Color accentColor;

  const SimpleInfoState({
    super.key,
    required this.title,
    required this.message,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [InfoCard(title: title, message: message, accentColor: accentColor)],
    );
  }
}