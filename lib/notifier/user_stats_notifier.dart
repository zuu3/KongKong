import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';

final userStatsProvider = StateNotifierProvider<UserStatsNotifier, UserStats>((ref) {
  return UserStatsNotifier();
});

class UserStatsNotifier extends StateNotifier<UserStats> {
  UserStatsNotifier() : super(UserStats.initial()) {
    _loadStats();
  }

  static const _key = 'user_stats';

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      state = UserStats.fromJson(jsonDecode(jsonStr));
    }
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  Future<bool> gainXp(int amount) async {
    int newXp = state.currentXp + amount;
    int newLevel = state.level;
    int newRequiredXp = state.requiredXp;
    bool leveledUp = false;

    while (newXp >= newRequiredXp) {
      newXp -= newRequiredXp;
      newLevel++;
      newRequiredXp = (newLevel * 1000 * 1.2).round(); // Increase requirement by 20% each level
      leveledUp = true;
    }

    state = state.copyWith(
      level: newLevel,
      currentXp: newXp,
      requiredXp: newRequiredXp,
    );
    await _saveStats();
    return leveledUp;
  }
}
