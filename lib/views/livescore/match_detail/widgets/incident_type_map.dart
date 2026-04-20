import 'package:flutter/material.dart';

// ── Icon type string constants ────────────────────────────────────────────

class IncidentIcon {
  static const String goal          = 'goal';
  static const String penaltyGoal   = 'penalty_goal';
  static const String missedPenalty = 'missed_penalty';
  static const String ownGoal       = 'own_goal';
  static const String yellow        = 'yellow';
  static const String secondYellow  = 'second_yellow';
  static const String red           = 'red';
  static const String defaultIcon   = 'default';
}

// ── Central incident definition ───────────────────────────────────────────

class IncidentDef {
  final String label;
  final String icon;
  final Color color;
  final bool isSupported;

  const IncidentDef({
    required this.label,
    required this.icon,
    required this.color,
    this.isSupported = true,
  });
}

// ── The single source of truth ────────────────────────────────────────────

const Map<int, IncidentDef> kIncidentTypeMap = {
  // Goals
  36: IncidentDef(label: 'Goal',               icon: IncidentIcon.goal,          color: Color(0xFF22C55E)),
  37: IncidentDef(label: 'Penalty Goal',        icon: IncidentIcon.penaltyGoal,   color: Color(0xFF15803D)),
  38: IncidentDef(label: 'Missed Penalty',      icon: IncidentIcon.missedPenalty, color: Color(0xFFEF4444)),
  39: IncidentDef(label: 'Own Goal',            icon: IncidentIcon.ownGoal,       color: Color(0xFFDC2626)),
  47: IncidentDef(label: 'Goal (ET)',           icon: IncidentIcon.goal,          color: Color(0xFF22C55E)),
  48: IncidentDef(label: 'Missed Penalty (ET)', icon: IncidentIcon.missedPenalty, color: Color(0xFFEF4444)),
  57: IncidentDef(label: 'Penalty Goal (ET)',   icon: IncidentIcon.penaltyGoal,   color: Color(0xFF15803D)),
  62: IncidentDef(label: 'Canceled Goal',       icon: IncidentIcon.defaultIcon,   color: Color(0xFF6B7280)),
  70: IncidentDef(label: 'Own Goal (ET)',       icon: IncidentIcon.ownGoal,       color: Color(0xFFDC2626)),

  // Cards
  43: IncidentDef(label: 'Yellow Card',   icon: IncidentIcon.yellow,       color: Color(0xFFFACC15)),
  44: IncidentDef(label: 'Second Yellow', icon: IncidentIcon.secondYellow, color: Color(0xFFFACC15)),
  45: IncidentDef(label: 'Red Card',      icon: IncidentIcon.red,          color: Color(0xFFEF4444)),
  46: IncidentDef(label: 'Unknown Card',  icon: IncidentIcon.yellow,       color: Color(0xFFFACC15)),
  49: IncidentDef(label: 'Red Card',      icon: IncidentIcon.red,          color: Color(0xFFEF4444)),
  50: IncidentDef(label: 'Red Card',      icon: IncidentIcon.red,          color: Color(0xFFEF4444)),

  // Unsupported
  40: IncidentDef(label: 'Shootout Missed',  icon: IncidentIcon.missedPenalty, color: Color(0xFFEF4444), isSupported: false),
  41: IncidentDef(label: 'Shootout Penalty', icon: IncidentIcon.penaltyGoal,   color: Color(0xFF15803D), isSupported: false),
};

// ── Fallback ──────────────────────────────────────────────────────────────

const IncidentDef kIncidentFallback = IncidentDef(
  label: 'Event',
  icon: IncidentIcon.defaultIcon,
  color: Color(0xFF6B7280),
  isSupported: false,
);

// ── Bucket fallback (Incs bucket key → IT int) ────────────────────────────

const Map<String, int> kBucketFallbackIT = {
  '1': 36,
  '2': 43,
  '3': 45,
  '4': 43,
  '5': 38,
  '6': 39,
  '7': 43,
  '8': 44,
};

// ── Badge label ───────────────────────────────────────────────────────────

const Map<int, String> kIncidentBadge = {
  38: 'MISS',
  48: 'MISS',
};

// ── Helper: get def safely ────────────────────────────────────────────────

IncidentDef incidentDef(int type) => kIncidentTypeMap[type] ?? kIncidentFallback;