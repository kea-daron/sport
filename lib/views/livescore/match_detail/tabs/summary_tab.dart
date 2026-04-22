import 'package:flutter/material.dart';
import '../match_detail_helpers.dart';

class SummaryTab extends StatelessWidget {
  final dynamic match;
  final dynamic detail;
  final Future<dynamic> scoreboardFuture;
  final Future<Map<String, dynamic>> incidentsFuture;

  const SummaryTab({
    super.key,
    required this.match,
    required this.detail,
    required this.scoreboardFuture,
    required this.incidentsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: scoreboardFuture,
      builder: (context, scoreSnap) {
        if (scoreSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (scoreSnap.hasError) {
          return Center(child: Text("Error: ${scoreSnap.error}"));
        }
        if (!scoreSnap.hasData) return const SizedBox();

        final data = scoreSnap.data as Map<String, dynamic>;

        return FutureBuilder<Map<String, dynamic>>(
          future: incidentsFuture,
          builder: (context, incSnap) {
            final incidents = incSnap.data ?? {};

            print("🔍 Incs 1 players: ${(incidents['Incs']?['1'] as List?)?.map((e) => 'Nm:${e['Nm']} Player:${e['Pn']} IT:${e['IT']}').toList()}");
            print("🔍 Incs 2 players: ${(incidents['Incs']?['2'] as List?)?.map((e) => 'Nm:${e['Nm']} Player:${e['Pn']} IT:${e['IT']}').toList()}");
            // print("🃏 incidents keys: ${incidents.keys.toList()}");
            // print("🃏 incidents Incs: ${incidents['Incs']}");
            return SingleChildScrollView(
              child: Column(
                children: [
                  _ScoreHeader(data: data),
                  _TimelineIncidents(
                    data: data,
                    incidents: incidents,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// SCORE HEADER
// ─────────────────────────────────────────
class _ScoreHeader extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ScoreHeader({required this.data});

  Color _hexColor(String? hex) {
    if (hex == null) return Colors.white24;
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.white24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeTeam =
    (data['T1'] as List<dynamic>).first as Map<String, dynamic>;
    final awayTeam =
    (data['T2'] as List<dynamic>).first as Map<String, dynamic>;
    final homeScore = data['Tr1'] ?? '-';
    final awayScore = data['Tr2'] ?? '-';
    final matchStatus = data['Eps'] ?? '';
    final stageName = data['Stg']?['Snm'] ?? '';
    final homeColor = _hexColor(homeTeam['firstColor']);
    final awayColor = _hexColor(awayTeam['firstColor']);

    return Container(
      color: const Color.fromARGB(255, 0, 0, 0),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Text(stageName,
              style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  letterSpacing: 1.1)),
          const SizedBox(height: 6),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: matchStatus == 'FT'
                  ? Colors.white12
                  : Colors.greenAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              matchStatus,
              style: TextStyle(
                color: matchStatus == 'FT'
                    ? Colors.white54
                    : Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TeamColumn(team: homeTeam, color: homeColor),
              Row(
                children: [
                  Text(homeScore.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(':',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 44)),
                  ),
                  Text(awayScore.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              _TeamColumn(team: awayTeam, color: awayColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  final Map<String, dynamic> team;
  final Color color;
  const _TeamColumn({required this.team, required this.color});

  @override
  Widget build(BuildContext context) {
    final name = team['Nm'] ?? '';
    final rawImage = H.readNested(
      team,
      const [
        'Img.img',
        'Img',
        'img',
        'badge.img',
        'badge',
        'tsImg',
      ],
      '',
    );
    final teamLogoUrl = H.teamImageUrl(rawImage);

    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          ),
          child: ClipOval(
            child: teamLogoUrl != null
                ? Image.network(
              teamLogoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.shield, color: Colors.white54),
            )
                : const Icon(Icons.shield, color: Colors.white54),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(name,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// TIMELINE INCIDENTS
// ─────────────────────────────────────────
class _TimelineItem {
  final bool isDivider;
  final String? dividerLabel;
  final Map<String, dynamic>? incident;
  final Map<String, dynamic>? assist;

  const _TimelineItem.divider(this.dividerLabel)
      : isDivider = true,
        incident = null,
        assist = null;

  const _TimelineItem.incident(this.incident, this.assist)
      : isDivider = false,
        dividerLabel = null;
}

class _TimelineIncidents extends StatelessWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> incidents;

  const _TimelineIncidents({
    required this.data,
    required this.incidents,
  });

  static const _showTypes = {
    36, 37, 38, 39, 43, 44, 45, 47, 3, 4, 62,
  };

  List<Map<String, dynamic>> _flattenIncidents() {
    final List<Map<String, dynamic>> all = [];

    final incsS = data['Incs-s'] as Map<String, dynamic>?;
    final incs = (incidents['Incs'] ?? data['Incs']) as Map<String, dynamic>?;

    // ── Process Incs-s ──────────────────────────
    if (incsS != null) {
      for (final teamKey in ['1', '2']) {
        final teamItems = incsS[teamKey] as List<dynamic>? ?? [];
        for (final item in teamItems) {
          final itemMap = item as Map<String, dynamic>;
          final nestedIncs = itemMap['Incs'];
          if (nestedIncs is List && nestedIncs.isNotEmpty) {
            for (final inc in nestedIncs) {
              final incMap = Map<String, dynamic>.from(inc as Map);
              // ✅ Use Nm field: 1 = home (Chelsea), 2 = away (Man United)
              incMap['_isHome'] = incMap['Nm']?.toString() == '1';
              all.add(incMap);
            }
          } else if (itemMap['IT'] != null) {
            final incMap = Map<String, dynamic>.from(itemMap);
            incMap['_isHome'] = incMap['Nm']?.toString() == '1';
            all.add(incMap);
          }
        }
      }
    }

    // ── Process Incs ────────────────────────────
    if (incs != null) {
      for (final teamKey in ['1', '2']) {
        final teamItems = incs[teamKey] as List<dynamic>? ?? [];
        for (final item in teamItems) {
          final itemMap = item as Map<String, dynamic>;
          final nestedIncs = itemMap['Incs'];
          if (nestedIncs is List && nestedIncs.isNotEmpty) {
            for (final inc in nestedIncs) {
              final incMap = Map<String, dynamic>.from(inc as Map);
              // ✅ Use Nm field
              incMap['_isHome'] = incMap['Nm']?.toString() == '1';
              final dupe = all.any((e) =>
              e['ID']?.toString() == incMap['ID']?.toString() &&
                  e['IT']?.toString() == incMap['IT']?.toString());
              if (!dupe) all.add(incMap);
            }
          } else if (itemMap['IT'] != null) {
            final incMap = Map<String, dynamic>.from(itemMap);
            // ✅ Use Nm field
            incMap['_isHome'] = incMap['Nm']?.toString() == '1';
            final dupe = all.any((e) =>
            e['ID']?.toString() == incMap['ID']?.toString() &&
                e['IT']?.toString() == incMap['IT']?.toString());
            if (!dupe) all.add(incMap);
          }
        }
      }
    }

    all.sort((a, b) {
      final minA = int.tryParse(a['Min']?.toString() ?? '0') ?? 0;
      final minB = int.tryParse(b['Min']?.toString() ?? '0') ?? 0;
      if (minA != minB) return minA.compareTo(minB);
      final exA = int.tryParse(a['MinEx']?.toString() ?? '0') ?? 0;
      final exB = int.tryParse(b['MinEx']?.toString() ?? '0') ?? 0;
      return exA.compareTo(exB);
    });

    return all;
  }

  List<_TimelineItem> _buildTimeline() {
    final allIncs = _flattenIncidents();
    final homeScore = data['Tr1'] ?? '0';
    final awayScore = data['Tr2'] ?? '0';
    final htHome = data['Trh1'];
    final htAway = data['Trh2'];
    final matchStatus = data['Eps'] ?? '';

    final filtered = allIncs.where((inc) {
      final type = int.tryParse(inc['IT']?.toString() ?? '') ?? -1;
      return _showTypes.contains(type) && type != 63;
    }).toList();

    // Assist lookup by minute
    final assistMap = <String, Map<String, dynamic>>{};
    for (final inc in allIncs) {
      if (inc['IT']?.toString() == '63') {
        assistMap[inc['Min']?.toString() ?? ''] = inc;
      }
    }

    final List<_TimelineItem> items = [];

    // FT divider
    if (matchStatus == 'FT') {
      items.add(_TimelineItem.divider('FT ($homeScore-$awayScore)'));
    }

    // Second half — reversed (latest first)
    final secondHalf = filtered
        .where((i) => (int.tryParse(i['Min']?.toString() ?? '0') ?? 0) > 45)
        .toList()
        .reversed
        .toList();

    for (final inc in secondHalf) {
      final assist = assistMap[inc['Min']?.toString() ?? ''];
      items.add(_TimelineItem.incident(inc, assist));
    }

    // HT divider
    if (htHome != null) {
      items.add(_TimelineItem.divider('HT ($htHome-$htAway)'));
    }

    // First half — reversed (latest first)
    final firstHalf = filtered
        .where((i) => (int.tryParse(i['Min']?.toString() ?? '0') ?? 0) <= 45)
        .toList()
        .reversed
        .toList();

    for (final inc in firstHalf) {
      final assist = assistMap[inc['Min']?.toString() ?? ''];
      items.add(_TimelineItem.incident(inc, assist));
    }

    // KO divider
    final esd = data['Esd']?.toString() ?? '';
    String koTime = '';
    if (esd.length >= 12) {
      final hour = esd.substring(8, 10);
      final min = esd.substring(10, 12);
      koTime = '$hour:$min';
    }
    items.add(_TimelineItem.divider('KO - $koTime'));

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildTimeline();
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 50, 50, 49),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: items.map((item) {
          if (item.isDivider) {
            return _DividerRow(label: item.dividerLabel ?? '');
          }
          return _IncidentRow(incident: item.incident!, assist: item.assist);
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────
// DIVIDER ROW
// ─────────────────────────────────────────
class _DividerRow extends StatelessWidget {
  final String label;
  const _DividerRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          const Expanded(
              child: Divider(color: Colors.white12, thickness: 1)),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 10),
          const Expanded(
              child: Divider(color: Colors.white12, thickness: 1)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// INCIDENT ROW
// ─────────────────────────────────────────
class _IncidentRow extends StatelessWidget {
  final Map<String, dynamic> incident;
  final Map<String, dynamic>? assist;
  const _IncidentRow({required this.incident, this.assist});

  @override
  Widget build(BuildContext context) {
    final type = int.tryParse(incident['IT']?.toString() ?? '') ?? -1;
    final minute = incident['Min']?.toString() ?? '';
    final minuteEx = incident['MinEx']?.toString();
    final playerName = incident['Pn']?.toString() ?? '';
    final isHome = incident['_isHome'] == true;
    final minuteStr = minuteEx != null ? "$minute+$minuteEx'" : "$minute'";
    final isGoal = {36, 37, 39, 47}.contains(type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT (home)
          Expanded(
            child: isHome
                ? _EventContent(
              playerName: playerName,
              assistName: assist?['Pn']?.toString(),
              type: type,
              isHome: true,
            )
                : const SizedBox(),
          ),

          // CENTER minute bubble
          Container(
            width: 64,
            alignment: Alignment.center,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isGoal ? Colors.white : const Color(0xFF2A2A3E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                minuteStr,
                style: TextStyle(
                  color: isGoal ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // RIGHT (away)
          Expanded(
            child: !isHome
                ? _EventContent(
              playerName: playerName,
              assistName: assist?['Pn']?.toString(),
              type: type,
              isHome: false,
            )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// EVENT CONTENT
// ─────────────────────────────────────────
class _EventContent extends StatelessWidget {
  final String playerName;
  final String? assistName;
  final int type;
  final bool isHome;

  const _EventContent({
    required this.playerName,
    required this.type,
    required this.isHome,
    this.assistName,
  });

  Widget _buildIcon() {
    if (type == 43) {
      return Container(
          width: 14,
          height: 18,
          decoration: BoxDecoration(
              color: const Color(0xFFEEFF00),
              borderRadius: BorderRadius.circular(2)));
    }
    if (type == 44) {
      return Container(
          width: 14,
          height: 18,
          decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(2)));
    }
    if (type == 45) {
      return Container(
          width: 14,
          height: 18,
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(2)));
    }
    if ({36, 37, 47}.contains(type)) {
      return const Icon(Icons.sports_soccer, size: 20, color: Colors.white);
    }
    if (type == 39) {
      return const Icon(Icons.sports_soccer,
          size: 20, color: Colors.orangeAccent);
    }
    if (type == 38 || type == 62) {
      return const Icon(Icons.cancel_outlined,
          size: 20, color: Colors.redAccent);
    }
    if (type == 3 || type == 4) {
      return const Icon(Icons.swap_horiz,
          size: 20, color: Colors.lightBlueAccent);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final icon = _buildIcon();
    final nameWidget = Column(
      crossAxisAlignment:
      isHome ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          playerName,
          textAlign: isHome ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
        if (assistName != null && assistName!.isNotEmpty)
          Text(
            assistName!,
            textAlign: isHome ? TextAlign.right : TextAlign.left,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
      ],
    );

    return Row(
      mainAxisAlignment:
      isHome ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: isHome
          ? [nameWidget, const SizedBox(width: 8), icon]
          : [icon, const SizedBox(width: 8), nameWidget],
    );
  }
}
