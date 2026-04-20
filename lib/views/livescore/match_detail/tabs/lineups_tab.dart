import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../models/match_item.dart';
import '../../../../widgets/app_skeleton.dart';
import '../match_detail_fields.dart';
import '../match_detail_helpers.dart';

class LineupsTab extends StatelessWidget {
  final MatchItem match;
  final String category;
  final Future<Map<String, dynamic>> lineupsFuture;

  const LineupsTab({
    super.key,
    required this.match,
    required this.category,
    required this.lineupsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: lineupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MatchListLoadingSkeleton(cardCount: 3, showHeader: true);
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading lineups',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  const SizedBox(height: 16),
                  Text('Match ID: ${match.eid}',
                      style: TextStyle(color: Colors.yellow.shade600, fontSize: 11, fontFamily: 'monospace')),
                ],
              ),
            ),
          );
        }

        final lineups = snapshot.data ?? {};
        if (lineups.isEmpty) return _buildEmptyState();

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _buildTacticalFormationField(context, lineups),
            const SizedBox(height: 16),
            _buildLineupDetailsSection(lineups),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.5)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.info_outline, color: Colors.orange.shade400, size: 20),
                const SizedBox(width: 8),
                Text('No lineup data',
                    style: TextStyle(color: Colors.orange.shade400, fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 12),
              Text('Lineup information is not available for this match yet.',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              const SizedBox(height: 8),
              Text(
                  '• The match hasn\'t started yet\n• The API doesn\'t have lineup data\n• The match ended without recording lineups',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Debug Info', style: TextStyle(color: Colors.yellow.shade600, fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Match ID: ${match.eid}', style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
                  Text('Category: $category', style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Formation field ────────────────────────────────────────────────────────

  Widget _buildTacticalFormationField(BuildContext context, Map<String, dynamic> lineups) {
    final homeTeam = _parseTeamLineup(lineups, true);
    final awayTeam = _parseTeamLineup(lineups, false);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF101010),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildLineupTeamHeader(
                    teamName: match.homeTeam,
                    teamImage: match.homeTeamImage,
                    formation: homeTeam['formation']?.toString() ?? '',
                    accentColor: Colors.amber.shade500,
                    alignEnd: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLineupTeamHeader(
                    teamName: match.awayTeam,
                    teamImage: match.awayTeamImage,
                    formation: awayTeam['formation']?.toString() ?? '',
                    accentColor: const Color(0xFF8D78FF),
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: MediaQuery.of(context).size.width < 760 ? 9 / 16 : 16 / 9,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 760;
                  final fieldSize = Size(constraints.maxWidth, constraints.maxHeight);
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: FootballFieldPainter(isCompact: isCompact)),
                      ),
                      ..._buildTeamFormationNodes(homeTeam, isHome: true, fieldSize: fieldSize, isCompact: isCompact),
                      ..._buildTeamFormationNodes(awayTeam, isHome: false, fieldSize: fieldSize, isCompact: isCompact),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineupTeamHeader({
    required String teamName,
    required String teamImage,
    required String formation,
    required Color accentColor,
    required bool alignEnd,
  }) {
    final url = H.teamImageUrl(teamImage);
    return Row(
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (alignEnd)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(teamName, textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                if (formation.trim().isNotEmpty)
                  Text(formation, style: TextStyle(color: Colors.white.withOpacity(0.68), fontSize: 11)),
              ],
            ),
          ),
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accentColor.withOpacity(0.30)),
          ),
          clipBehavior: Clip.antiAlias,
          child: url == null
              ? Center(child: Text(H.initials(teamName), style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w800)))
              : Image.network(url, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(child: Text(H.initials(teamName), style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w800)))),
        ),
        if (!alignEnd) const SizedBox(width: 10),
        if (!alignEnd)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(teamName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                if (formation.trim().isNotEmpty)
                  Text(formation, style: TextStyle(color: Colors.white.withOpacity(0.68), fontSize: 11)),
              ],
            ),
          ),
        if (alignEnd) const SizedBox(width: 10),
      ],
    );
  }

  List<Widget> _buildTeamFormationNodes(
      Map<String, dynamic> teamData, {
        required bool isHome,
        required Size fieldSize,
        required bool isCompact,
      }) {
    final players = (teamData['players'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    if (players.isEmpty) {
      return [
        Positioned(
          left: isCompact
              ? fieldSize.width * 0.25
              : (isHome ? fieldSize.width * 0.14 : fieldSize.width * 0.64),
          top: isCompact
              ? (isHome ? fieldSize.height * 0.18 : fieldSize.height * 0.72)
              : fieldSize.height * 0.44,
          width: isCompact ? fieldSize.width * 0.50 : fieldSize.width * 0.22,
          child: Text('No lineup data',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ];
    }

    final rows = (() {
      final raw = teamData['rows'];
      if (raw is List && raw.isNotEmpty) {
        return raw.whereType<List>()
            .map((r) => r.whereType<Map<String, dynamic>>().toList())
            .where((r) => r.isNotEmpty).toList();
      }
      return _buildFormationRows(players, teamData['formation']?.toString() ?? '');
    })();

    final totalRows = math.max(rows.length, 1);
    final widgets = <Widget>[];

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final rowPlayers = rows[rowIndex];
      for (var pi = 0; pi < rowPlayers.length; pi++) {
        final player = rowPlayers[pi];
        final spreadFactor = rowPlayers.length == 1 ? 0.5 : (pi + 1) / (rowPlayers.length + 1);
        const cardWidth = 80.0;

        final top = isCompact
            ? _compactFormationTop(rowIndex: rowIndex, totalRows: totalRows, isHome: isHome, fieldHeight: fieldSize.height)
            : (fieldSize.height * spreadFactor) - 48;

        final left = isCompact
            ? (fieldSize.width * spreadFactor) - (cardWidth / 2)
            : (fieldSize.width *
            (isHome
                ? (0.08 + (0.36 * (totalRows == 1 ? 0.5 : rowIndex / (totalRows - 1))))
                : (0.92 - (0.36 * (totalRows == 1 ? 0.5 : rowIndex / (totalRows - 1))))) -
            (cardWidth / 2));

        widgets.add(Positioned(
          left: left, top: top, width: cardWidth,
          child: _buildFormationPlayerCard(player, isHome: isHome,
              subOutMin: (player['subOutMin'] ?? '').toString().trim().isEmpty
                  ? null : (player['subOutMin'] ?? '').toString().trim()),
        ));
      }
    }
    return widgets;
  }

  double _compactFormationTop({
    required int rowIndex,
    required int totalRows,
    required bool isHome,
    required double fieldHeight,
  }) {
    final depthT = totalRows == 1 ? 0.5 : rowIndex / (totalRows - 1);
    final depth = isHome ? (0.12 + (0.35 * depthT)) : (0.95 - (0.35 * depthT));
    return (fieldHeight * depth) - 36;
  }

  Widget _buildFormationPlayerCard(Map<String, dynamic> player, {required bool isHome, String? subOutMin}) {
    final shortName = _lineupPlayerShortName(player);
    final number = _lineupPlayerNumber(player);
    final rating = _lineupPlayerRating(player);
    final shirtColor = isHome ? const Color(0xFFFFC31A) : const Color(0xFF3B2A63);
    final numberColor = isHome ? Colors.black : Colors.white;
    final numLen = number.trim().length;
    final badgeSize = numLen >= 3 ? 28.0 : 32.0;
    final numFontSize = numLen >= 3 ? 8.0 : 10.0;
    final hasRating = rating.isNotEmpty && rating != '0';
    final ratingValue = double.tryParse(rating) ?? 0;
    final ratingColor = ratingValue >= 7
        ? const Color(0xFF16A34A)
        : ratingValue < 6 ? const Color(0xFFEF4444) : const Color(0xFFF97316);
    final hasSubOut = subOutMin != null && subOutMin.isNotEmpty;

    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: badgeSize, height: badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: shirtColor,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 6, offset: const Offset(0, 3))],
                ),
                alignment: Alignment.center,
                child: Text(number, style: TextStyle(color: numberColor, fontWeight: FontWeight.w800, fontSize: numFontSize)),
              ),
              if (hasRating)
                Positioned(
                  top: -8,
                  right: isHome ? -4 : null,
                  left: isHome ? null : -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: ratingColor,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.white, width: 0.5),
                    ),
                    child: Text(rating, style: const TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.w700, height: 1.2)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(shortName, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
          if (hasSubOut) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red.shade500,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.arrow_downward_rounded, size: 7, color: Colors.white),
                const SizedBox(width: 1),
                Text("+$subOutMin'", style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w800, height: 1)),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  // ── Lineup details section (bench + injuries) ─────────────────────────────

  Widget _buildLineupDetailsSection(Map<String, dynamic> lineups) {
    final homeTeam = _parseTeamLineup(lineups, true);
    final awayTeam = _parseTeamLineup(lineups, false);

    return Column(
      children: [
        _buildLineupSplitSection(
          title: 'SUBSTITUTIONS',
          homePlayers: (homeTeam['bench'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
          awayPlayers: (awayTeam['bench'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
        ),
        const SizedBox(height: 16),
        _buildLineupSplitSection(
          title: 'INJURIES',
          homePlayers: (homeTeam['injuries'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
          awayPlayers: (awayTeam['injuries'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
          emptyLabel: 'No injury data available',
        ),
      ],
    );
  }

  Widget _buildLineupSplitSection({
    required String title,
    required List<Map<String, dynamic>> homePlayers,
    required List<Map<String, dynamic>> awayPlayers,
    String emptyLabel = 'No player details available',
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 760;
            final homeColumn = _buildLineupDetailColumn(label: 'HOME', players: homePlayers, isHome: true, emptyLabel: emptyLabel);
            final awayColumn = _buildLineupDetailColumn(label: 'AWAY', players: awayPlayers, isHome: false, emptyLabel: emptyLabel);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                ),
                const SizedBox(height: 16),
                if (isCompact) ...[
                  homeColumn, const SizedBox(height: 16), awayColumn,
                ] else
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: homeColumn),
                    Container(
                      width: 1,
                      height: math.max(240, math.max(homePlayers.length, awayPlayers.length) * 56).toDouble(),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.white.withOpacity(0.08),
                    ),
                    Expanded(child: awayColumn),
                  ]),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLineupDetailColumn({
    required String label,
    required List<Map<String, dynamic>> players,
    required bool isHome,
    required String emptyLabel,
  }) {
    return Column(
      crossAxisAlignment: isHome ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.9)),
        const SizedBox(height: 10),
        if (players.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(emptyLabel,
                textAlign: isHome ? TextAlign.left : TextAlign.right,
                style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
          )
        else
          Column(children: players.map((p) => _buildLineupDetailRow(p, isHome: isHome)).toList()),
      ],
    );
  }

  Widget _buildLineupDetailRow(Map<String, dynamic> player, {required bool isHome}) {
    final number = _lineupPlayerNumber(player);
    final name = _lineupPlayerName(player);
    final position = _lineupPlayerPosition(player);
    final details = _lineupPlayerDetailText(player);

    final numberBubble = Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      alignment: Alignment.center,
      child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );

    final textBlock = Expanded(
      child: Column(
        crossAxisAlignment: isHome ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(name, textAlign: isHome ? TextAlign.left : TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          if (position.isNotEmpty)
            Text(position, textAlign: isHome ? TextAlign.left : TextAlign.right,
                style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 10, fontWeight: FontWeight.w600)),
          if (details.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(details, textAlign: isHome ? TextAlign.left : TextAlign.right,
                  style: TextStyle(color: Colors.greenAccent.shade400, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: isHome
            ? [numberBubble, const SizedBox(width: 10), textBlock]
            : [textBlock, const SizedBox(width: 10), numberBubble],
      ),
    );
  }

  // ── Lineup parsing ─────────────────────────────────────────────────────────

  Map<String, dynamic> _parseTeamLineup(Map<String, dynamic> lineups, bool isHome) {
    if (lineups[F.lineups] is List<dynamic>) {
      final parsed = _parseStructuredTeamLineup(lineups, isHome);
      if (parsed.isNotEmpty) return parsed;
    }

    final starters = <Map<String, dynamic>>[];
    final bench = <Map<String, dynamic>>[];
    final injuries = <Map<String, dynamic>>[];
    final everyone = <Map<String, dynamic>>[];

    if (lineups['teams'] is Map) {
      final teams = lineups['teams'] as Map<String, dynamic>;
      final teamKey = isHome ? 'home' : 'away';
      final teamData = teams[teamKey] as Map<String, dynamic>?;
      everyone.addAll(_extractPlayerMaps(teamData?['players']));
      everyone.addAll(_extractPlayerMaps(teamData?['startingXI']));
      bench.addAll(_extractPlayerMaps(teamData?['substitutes']));
      bench.addAll(_extractPlayerMaps(teamData?['subs']));
      injuries.addAll(_extractPlayerMaps(teamData?['injuries']));
    }

    for (final player in everyone) {
      if (_isInjuryPlayer(player)) injuries.add(player);
      else if (_isStarterPlayer(player)) starters.add(player);
      else bench.add(player);
    }

    if (starters.isEmpty && everyone.isNotEmpty) {
      starters.addAll(everyone.take(11));
      bench.addAll(everyone.skip(11));
    }

    final dedupedStarters = _dedupePlayers(starters).take(11).toList();
    final dedupedBench = _dedupePlayers(bench).where((p) => !_containsPlayer(dedupedStarters, p)).toList();
    final dedupedInjuries = _dedupePlayers(injuries)
        .where((p) => !_containsPlayer(dedupedStarters, p) && !_containsPlayer(dedupedBench, p))
        .toList();

    return {
      'players': dedupedStarters,
      'bench': dedupedBench,
      'injuries': dedupedInjuries,
      'rows': _buildFormationRows(dedupedStarters, ''),
      'formation': '',
    };
  }

  Map<String, dynamic> _parseStructuredTeamLineup(Map<String, dynamic> lineups, bool isHome) {
    final lu = lineups[F.lineups];
    if (lu is! List<dynamic> || lu.length < 2) return const {};

    final team = lu[isHome ? 0 : 1];
    if (team is! Map<String, dynamic>) return const {};

    final allPlayers = _extractPlayerMaps(team[F.lineupPs]);
    final starters = allPlayers.where((p) => H.asInt((p[F.playerPos] ?? '0').toString()) != 5).toList();
    final bench    = allPlayers.where((p) => H.asInt((p[F.playerPos] ?? '0').toString()) == 5).toList();
    final injuries = _extractPlayerMaps(team[F.lineupIS]);

    String formation;
    final foRaw = team[F.lineupFo];
    if (foRaw is List) {
      final counts = foRaw.map((e) => H.asInt(e)).where((v) => v > 0).toList();
      formation = counts.isNotEmpty ? counts.join('-') : _inferFormation(starters);
    } else if (foRaw is String && foRaw.isNotEmpty) {
      formation = foRaw;
    } else {
      formation = _inferFormation(starters);
    }

    final subsHistory = _buildLineupSubHistory(lineups, isHome: isHome);
    final starterCopies = starters.take(11).map((p) => Map<String, dynamic>.from(p)).toList();
    final benchCopies   = bench.map((p) => Map<String, dynamic>.from(p)).toList();
    final injuryCopies  = injuries.map((p) => Map<String, dynamic>.from(p)).toList();

    for (final player in starterCopies) {
      final subOutMin = _getStarterSubOutTime(player, subsHistory);
      if (subOutMin != null) player['subOutMin'] = subOutMin;
    }
    for (final player in benchCopies) {
      final subInData = _getBenchSubInData(player, subsHistory);
      if (subInData != null) player.addAll(subInData);
    }

    return {
      'players': starterCopies,
      'bench': benchCopies,
      'injuries': injuryCopies,
      'rows': _buildFormationRows(starterCopies, formation),
      'formation': formation,
    };
  }

  List<List<Map<String, dynamic>>> _buildFormationRows(List<Map<String, dynamic>> players, String formation) {
    if (players.isEmpty) return const [];

    List<int> counts = formation
        .split(RegExp(r'[^0-9]+'))
        .where((p) => p.trim().isNotEmpty)
        .map((p) => int.tryParse(p) ?? 0)
        .where((v) => v > 0)
        .toList();

    if (counts.isNotEmpty && counts.first == 1 && players.length > 1) {
      final remaining = counts.skip(1).toList();
      final remainingSum = remaining.fold<int>(0, (s, v) => s + v);
      if (remainingSum >= players.length - 1) counts = remaining;
    }

    final rows = <List<Map<String, dynamic>>>[[players.first]];
    final outfield = players.skip(1).toList();
    if (outfield.isEmpty) return rows;

    if (counts.isEmpty) {
      final chunkSize = (outfield.length / 3).ceil();
      for (var i = 0; i < outfield.length; i += chunkSize) {
        rows.add(outfield.skip(i).take(chunkSize).toList());
      }
      return rows;
    }

    final normalizedCounts = List<int>.from(counts);
    final assigned = normalizedCounts.fold<int>(0, (s, i) => s + i);
    if (assigned < outfield.length) normalizedCounts[normalizedCounts.length - 1] += outfield.length - assigned;

    var cursor = 0;
    for (final count in normalizedCounts) {
      if (cursor >= outfield.length) break;
      rows.add(outfield.skip(cursor).take(count).toList());
      cursor += count;
    }
    if (cursor < outfield.length) rows.add(outfield.skip(cursor).toList());

    return rows.where((r) => r.isNotEmpty).toList();
  }

  // ── Substitution history ──────────────────────────────────────────────────

  List<Map<String, dynamic>> _buildLineupSubHistory(Map<String, dynamic> lineups, {required bool isHome}) {
    final subs = lineups[F.lineupSubs];
    if (subs is! List<dynamic> || subs.length < 3 || subs[2] is! List<dynamic>) return const [];

    final teamNum = isHome ? '1' : '2';
    final allEntries = (subs[2] as List<dynamic>).whereType<Map<String, dynamic>>()
        .where((item) => H.readNested(item, const ['Tnb', 'Nm', 'nm'], '') == teamNum)
        .toList()
      ..sort((a, b) => H.asInt(a[F.minute]).compareTo(H.asInt(b[F.minute])));

    final outs = allEntries.where((e) => H.asInt(e[F.incidentType]) == F.itSubstitutionOut).toList();
    final ins  = allEntries.where((e) => H.asInt(e[F.incidentType]) == F.itSubstitutionIn).toList();

    final usedIn = <int>{};
    final history = <Map<String, dynamic>>[];

    for (final out in outs) {
      final outId  = (out['Aid'] ?? out['ID'] ?? '').toString().trim();
      final outIdo = (out['IDo'] ?? '').toString().trim();
      int matchIndex = -1;
      for (var i = 0; i < ins.length; i++) {
        if (usedIn.contains(i)) continue;
        final inn   = ins[i];
        final inId  = (inn['Aid'] ?? inn['ID'] ?? '').toString().trim();
        final inIdo = (inn['IDo'] ?? '').toString().trim();
        if (inId == outIdo || inIdo == outId) { matchIndex = i; break; }
      }
      if (matchIndex != -1) {
        usedIn.add(matchIndex);
        final minute = H.firstNonEmpty([
          (out[F.minute] ?? '').toString().trim(),
          (ins[matchIndex][F.minute] ?? '').toString().trim(),
        ]);
        history.add({'min': minute, 'out': out, 'in': ins[matchIndex]});
      }
    }
    return history;
  }

  String? _getStarterSubOutTime(Map<String, dynamic> player, List<Map<String, dynamic>> history) {
    final aid = (player['Aid'] ?? player['ID'] ?? '').toString().trim();
    if (aid.isEmpty) return null;
    for (final event in history) {
      final out = event['out'];
      if (out is Map<String, dynamic>) {
        final outAid = (out['Aid'] ?? out['ID'] ?? '').toString().trim();
        if (outAid == aid) {
          final minute = event['min']?.toString().trim() ?? '';
          return minute.isEmpty ? null : minute;
        }
      }
    }
    return null;
  }

  Map<String, dynamic>? _getBenchSubInData(Map<String, dynamic> player, List<Map<String, dynamic>> history) {
    final aid = (player['Aid'] ?? player['ID'] ?? '').toString().trim();
    if (aid.isEmpty) return null;
    for (final event in history) {
      final incoming = event['in'];
      final outgoing = event['out'];
      if (incoming is Map<String, dynamic>) {
        final inAid = (incoming['Aid'] ?? incoming['ID'] ?? '').toString().trim();
        if (inAid == aid) {
          final minute = event['min']?.toString().trim() ?? '';
          return {
            'subInMin': minute,
            'subOutName': outgoing is Map<String, dynamic> ? _lineupPlayerShortName(outgoing) : '',
          };
        }
      }
    }
    return null;
  }

  // ── Player field helpers ───────────────────────────────────────────────────

  String _lineupPlayerName(Map<String, dynamic> player) {
    final full = (player['Shnm'] ?? '').toString().trim();
    if (full.isNotEmpty) return full;
    final fn = (player['Fn'] ?? '').toString().trim();
    final ln = (player['Ln'] ?? '').toString().trim();
    final composed = [fn, ln].where((s) => s.isNotEmpty).join(' ');
    if (composed.isNotEmpty) return composed;
    return (player['Nm'] ?? 'Unknown').toString().trim();
  }

  String _lineupPlayerShortName(Map<String, dynamic> player) {
    final ln = (player['Ln'] ?? '').toString().trim();
    if (ln.isNotEmpty) return ln;
    final shnm = (player['Shnm'] ?? '').toString().trim();
    if (shnm.isNotEmpty) return shnm;
    return (player['Fn'] ?? '?').toString().trim();
  }

  String _lineupPlayerNumber(Map<String, dynamic> player) =>
      H.readNested(player, const [F.playerNumber, 'shirtNumber', 'num', 'No', 'number'], '?');

  String _lineupPlayerPosition(Map<String, dynamic> player) {
    final posVal = H.asInt(H.readNested(player, const [F.playerActPos, F.playerPos], '0'));
    if (posVal == 5) return '';
    if (posVal > 0) {
      switch (posVal) {
        case 1: return 'GK';
        case 2: return 'DEF';
        case 3: return 'MID';
        case 4: return 'FW';
        default: return 'BENCH';
      }
    }
    return H.readNested(player, const ['pos', 'position', 'role', 'Position'], '').toUpperCase();
  }

  String _lineupPlayerRating(Map<String, dynamic> player) =>
      H.readNested(player, const ['Rate', 'rating', 'rate', 'rt', 'Rating'], '');

  String _lineupPlayerDetailText(Map<String, dynamic> player) {
    final subInMin  = H.readNested(player, const ['subInMin'], '');
    final subOutName = H.readNested(player, const ['subOutName'], '');
    if (subInMin.isNotEmpty) return subOutName.isNotEmpty ? "$subInMin'  for $subOutName" : "$subInMin'";

    final minute   = H.readNested(player, const ['minute', 'min', 'Time', 'tm'], '');
    final relation = H.readNested(player, const ['for', 'replacement', 'replaced', 'substituteFor', 'playerOut', 'out'], '');
    final status   = H.readNested(player, const [F.playerStatusRs, F.playerStatus, 'injury', 'injuryType', 'reason', 'desc', 'status'], '');

    final segments = <String>[];
    if (minute.isNotEmpty) segments.add("$minute'");
    if (relation.isNotEmpty) segments.add('for $relation');
    else if (status.isNotEmpty) segments.add(status);
    return segments.join('  ');
  }

  // ── Utility methods ───────────────────────────────────────────────────────

  List<Map<String, dynamic>> _extractPlayerMaps(dynamic value) {
    if (value is List<dynamic>) return value.whereType<Map<String, dynamic>>().toList();
    return const [];
  }

  String _inferFormation(List<Map<String, dynamic>> players) {
    int pos(Map<String, dynamic> p) => H.asInt(H.readNested(p, const [F.playerActPos, F.playerPos, 'pos', 'position'], ''));
    final defs = players.where((p) => pos(p) == 2).length;
    final mids = players.where((p) => pos(p) == 3).length;
    final fws  = players.where((p) => pos(p) == 4).length;
    return [defs, mids, fws].where((v) => v > 0).map((v) => '$v').join('-');
  }

  bool _isStarterPlayer(Map<String, dynamic> player) {
    final raw = H.readNested(player, const ['starter', 'isStarter', 'st', 'xi', 'starting', 'lineup', 'first11', 'status'], '').toLowerCase();
    return raw == '1' || raw == 'true' || raw == 'yes' || raw == 'starter' || raw == 'starting' || raw == 'xi';
  }

  bool _isInjuryPlayer(Map<String, dynamic> player) {
    final statusReason = (player[F.playerStatusRs] ?? '').toString().toLowerCase();
    final status       = (player[F.playerStatus]   ?? '').toString().toLowerCase();
    const injuryKeywords = ['injur', 'knock', 'doubt', 'hamstring', 'cruciate', 'achilles', 'absent'];
    for (final kw in injuryKeywords) {
      if (statusReason.contains(kw) || status.contains(kw)) return true;
    }
    if (statusReason.contains('out') || status.contains('out')) return true;
    return false;
  }

  List<Map<String, dynamic>> _dedupePlayers(List<Map<String, dynamic>> players) {
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];
    for (final p in players) {
      final key = '${_lineupPlayerNumber(p)}|${_lineupPlayerName(p).toLowerCase()}';
      if (seen.add(key)) result.add(p);
    }
    return result;
  }

  bool _containsPlayer(List<Map<String, dynamic>> players, Map<String, dynamic> target) {
    final targetKey = '${_lineupPlayerNumber(target)}|${_lineupPlayerName(target).toLowerCase()}';
    return players.any((p) => '${_lineupPlayerNumber(p)}|${_lineupPlayerName(p).toLowerCase()}' == targetKey);
  }
}

// ── Football field painter ─────────────────────────────────────────────────

class FootballFieldPainter extends CustomPainter {
  final bool isCompact;
  FootballFieldPainter({this.isCompact = false});

  @override
  void paint(Canvas canvas, Size size) {
    final fieldPaint = Paint()
      ..shader = const LinearGradient(
          colors: [Color(0xFF3C9646), Color(0xFF348C42)]).createShader(
          Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.72)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fieldPaint);

    final stripePaint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..style = PaintingStyle.fill;
    const stripeCount = 10;
    final stripeWidth = isCompact ? size.height / stripeCount : size.width / stripeCount;
    for (var i = 0; i < stripeCount; i++) {
      if (i.isEven) {
        canvas.drawRect(
          isCompact
              ? Rect.fromLTWH(0, i * stripeWidth, size.width, stripeWidth)
              : Rect.fromLTWH(i * stripeWidth, 0, stripeWidth, size.height),
          stripePaint,
        );
      }
    }

    canvas.drawRect(Rect.fromLTWH(14, 14, size.width - 28, size.height - 28), linePaint);
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        (isCompact ? size.width : size.height) * 0.10, linePaint);
    canvas.drawLine(
        isCompact ? Offset(14, size.height / 2) : Offset(size.width / 2, 14),
        isCompact ? Offset(size.width - 14, size.height / 2) : Offset(size.width / 2, size.height - 14),
        linePaint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3,
        Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.fill);

    if (isCompact) {
      final boxWidth     = size.width * 0.30;
      final goalBoxWidth = size.width * 0.16;
      final penH  = size.height * 0.12;
      final goalH = size.height * 0.06;
      final left  = (size.width - boxWidth) / 2;
      final goalLeft = (size.width - goalBoxWidth) / 2;

      canvas.drawRect(Rect.fromLTWH(left, 14, boxWidth, penH), linePaint);
      canvas.drawRect(Rect.fromLTWH(left, size.height - 14 - penH, boxWidth, penH), linePaint);
      canvas.drawRect(Rect.fromLTWH(goalLeft, 14, goalBoxWidth, goalH), linePaint);
      canvas.drawRect(Rect.fromLTWH(goalLeft, size.height - 14 - goalH, goalBoxWidth, goalH), linePaint);
      canvas.drawCircle(Offset(size.width / 2, 14 + (penH * 0.62)), 2.4,
          Paint()..color = Colors.white.withOpacity(0.72)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(size.width / 2, size.height - 14 - (penH * 0.62)), 2.4,
          Paint()..color = Colors.white.withOpacity(0.72)..style = PaintingStyle.fill);
    } else {
      final boxH     = size.height * 0.30;
      final goalBoxH = size.height * 0.16;
      final penW  = size.width * 0.12;
      final goalW = size.width * 0.06;
      final top   = (size.height - boxH) / 2;
      final goalTop = (size.height - goalBoxH) / 2;

      canvas.drawRect(Rect.fromLTWH(14, top, penW, boxH), linePaint);
      canvas.drawRect(Rect.fromLTWH(size.width - 14 - penW, top, penW, boxH), linePaint);
      canvas.drawRect(Rect.fromLTWH(14, goalTop, goalW, goalBoxH), linePaint);
      canvas.drawRect(Rect.fromLTWH(size.width - 14 - goalW, goalTop, goalW, goalBoxH), linePaint);
      canvas.drawCircle(Offset(14 + (penW * 0.62), size.height / 2), 2.4,
          Paint()..color = Colors.white.withOpacity(0.72)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(size.width - 14 - (penW * 0.62), size.height / 2), 2.4,
          Paint()..color = Colors.white.withOpacity(0.72)..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(FootballFieldPainter old) => old.isCompact != isCompact;
}