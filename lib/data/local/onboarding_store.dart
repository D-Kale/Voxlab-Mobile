import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/secure_storage.dart';

/// Answers from the first-run onboarding questions.
@immutable
class OnboardingProfile {
  const OnboardingProfile({
    required this.motivation,
    required this.level,
    required this.dailyGoalXp,
  });

  final String motivation;
  final String level;

  /// Daily XP target picked by the user (10, 20, 30 or 50).
  final int dailyGoalXp;

  static const defaultDailyGoalXp = 20;

  /// Daily goals offered in the onboarding and in Perfil.
  static const dailyGoals = {
    10: 'Casual',
    20: 'Normal',
    30: 'Serio',
    50: 'Intenso',
  };

  Map<String, dynamic> toJson() => {
    'motivation': motivation,
    'level': level,
    'daily_goal_xp': dailyGoalXp,
  };

  factory OnboardingProfile.fromJson(Map<String, dynamic> json) {
    return OnboardingProfile(
      motivation: json['motivation'] as String? ?? '',
      level: json['level'] as String? ?? '',
      dailyGoalXp:
          (json['daily_goal_xp'] as num?)?.toInt() ?? defaultDailyGoalXp,
    );
  }
}

/// Device-level first-run state: whether the onboarding questions and the
/// guided app tour were already shown, and the onboarding answers.
///
/// Reads never throw: when storage is unavailable the flags read as "seen",
/// so a broken keychain never traps the user in the onboarding or the tour.
class OnboardingStore {
  OnboardingStore(this._storage);

  final SecureStorage _storage;

  static const _onboardingSeenKey = 'voxlab_onboarding_seen';
  static const _tourSeenKey = 'voxlab_tour_seen';
  static const _profileKey = 'voxlab_onboarding_profile';

  Future<bool> isOnboardingSeen() => _readFlag(_onboardingSeenKey);

  Future<void> markOnboardingSeen() => _writeFlag(_onboardingSeenKey);

  Future<bool> isTourSeen() => _readFlag(_tourSeenKey);

  Future<void> markTourSeen() => _writeFlag(_tourSeenKey);

  Future<OnboardingProfile?> loadProfile() async {
    try {
      final raw = await _storage.readString(_profileKey);
      if (raw == null || raw.isEmpty) return null;
      return OnboardingProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('OnboardingStore loadProfile error: $e');
      return null;
    }
  }

  Future<void> saveProfile(OnboardingProfile profile) async {
    try {
      await _storage.writeString(_profileKey, jsonEncode(profile.toJson()));
    } catch (e) {
      debugPrint('OnboardingStore saveProfile error: $e');
    }
  }

  /// Changes only the daily goal, keeping the other answers.
  Future<void> updateDailyGoal(int xp) async {
    final current = await loadProfile();
    await saveProfile(
      OnboardingProfile(
        motivation: current?.motivation ?? '',
        level: current?.level ?? '',
        dailyGoalXp: xp,
      ),
    );
  }

  Future<bool> _readFlag(String key) async {
    try {
      return await _storage.readString(key) == 'true';
    } catch (e) {
      debugPrint('OnboardingStore read $key error: $e');
      return true;
    }
  }

  Future<void> _writeFlag(String key) async {
    try {
      await _storage.writeString(key, 'true');
    } catch (e) {
      debugPrint('OnboardingStore write $key error: $e');
    }
  }
}

final onboardingStoreProvider = Provider<OnboardingStore>((ref) {
  return OnboardingStore(ref.read(secureStorageProvider));
});

/// The saved onboarding answers, or null before the onboarding.
final onboardingProfileProvider = FutureProvider<OnboardingProfile?>((ref) {
  return ref.watch(onboardingStoreProvider).loadProfile();
});
