import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage.dart';
import 'auth_provider.dart';

/// Best result of one minigame.
@immutable
class GameRecord {
  const GameRecord({this.bestPoints = 0, this.bestStars = 0, this.plays = 0});

  final int bestPoints;
  final int bestStars;
  final int plays;

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
    bestPoints: json['best'] as int? ?? 0,
    bestStars: json['stars'] as int? ?? 0,
    plays: json['plays'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'best': bestPoints,
    'stars': bestStars,
    'plays': plays,
  };
}

/// Minigame records, XP earned playing and the daily-challenge streak.
@immutable
class GameRecords {
  const GameRecords({
    this.games = const {},
    this.xp = 0,
    this.dailyStreak = 0,
    this.lastDaily,
  });

  final Map<String, GameRecord> games;
  final int xp;
  final int dailyStreak;

  /// `yyyy-mm-dd` of the last daily challenge played.
  final String? lastDaily;

  GameRecord of(String slug) => games[slug] ?? const GameRecord();

  bool get playedDailyToday => lastDaily == _day(DateTime.now());

  /// Streak still alive today (played today or yesterday).
  int get liveStreak {
    if (lastDaily == null) return 0;
    final now = DateTime.now();
    final yesterday = _day(now.subtract(const Duration(days: 1)));
    return lastDaily == _day(now) || lastDaily == yesterday ? dailyStreak : 0;
  }

  factory GameRecords.fromJson(Map<String, dynamic> json) => GameRecords(
    games: {
      for (final e in (json['games'] as Map<String, dynamic>? ?? {}).entries)
        e.key: GameRecord.fromJson(e.value as Map<String, dynamic>),
    },
    xp: json['xp'] as int? ?? 0,
    dailyStreak: json['streak'] as int? ?? 0,
    lastDaily: json['daily'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'games': {for (final e in games.entries) e.key: e.value.toJson()},
    'xp': xp,
    'streak': dailyStreak,
    'daily': lastDaily,
  };

  static String _day(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

/// What a finished play earned.
@immutable
class GameReward {
  const GameReward({
    required this.xp,
    required this.isRecord,
    required this.previousBest,
  });

  final int xp;
  final bool isRecord;
  final int previousBest;
}

/// Local-only, per signed-in user (same model as `ProgressNotifier`).
class GameRecordsNotifier extends Notifier<GameRecords> {
  String? _userId;

  static String _key(String userId) => 'voxlab_game_records_$userId';

  @override
  GameRecords build() {
    _userId = ref.watch(authProvider.select((s) => s.user?.id));
    if (_userId != null) Future.microtask(_load);
    return const GameRecords();
  }

  Future<void> _load() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      final raw = await ref
          .read(secureStorageProvider)
          .readString(_key(userId));
      if (raw == null || raw.isEmpty || _userId != userId) return;
      state = GameRecords.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('GameRecords load error: $e');
    }
  }

  /// XP: 2 for trying, 10/15/20 for 1/2/3 stars, +5 for a new record.
  static int xpFor(int stars, {required bool isRecord}) {
    final base = switch (stars) {
      >= 3 => 20,
      2 => 15,
      1 => 10,
      _ => 2,
    };
    return base + (isRecord ? 5 : 0);
  }

  GameReward record({
    required String slug,
    required int points,
    required int stars,
    bool daily = false,
  }) {
    final previous = state.of(slug);
    final isRecord = previous.plays > 0 && points > previous.bestPoints;
    final xp = xpFor(stars, isRecord: isRecord);

    var streak = state.dailyStreak;
    var lastDaily = state.lastDaily;
    if (daily && !state.playedDailyToday) {
      streak = state.liveStreak + 1;
      lastDaily = GameRecords._day(DateTime.now());
    }

    state = GameRecords(
      games: {
        ...state.games,
        slug: GameRecord(
          bestPoints: points > previous.bestPoints
              ? points
              : previous.bestPoints,
          bestStars: stars > previous.bestStars ? stars : previous.bestStars,
          plays: previous.plays + 1,
        ),
      },
      xp: state.xp + xp,
      dailyStreak: streak,
      lastDaily: lastDaily,
    );
    _persist();
    return GameReward(
      xp: xp,
      isRecord: isRecord,
      previousBest: previous.bestPoints,
    );
  }

  Future<void> _persist() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await ref
          .read(secureStorageProvider)
          .writeString(_key(userId), jsonEncode(state.toJson()));
    } catch (e) {
      debugPrint('GameRecords persist error: $e');
    }
  }
}

final gameRecordsProvider = NotifierProvider<GameRecordsNotifier, GameRecords>(
  GameRecordsNotifier.new,
);
