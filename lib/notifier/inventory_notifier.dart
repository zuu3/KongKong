import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';

final inventoryProvider = StateNotifierProvider<InventoryNotifier, Map<ItemType, int>>((ref) {
  return InventoryNotifier();
});

class InventoryNotifier extends StateNotifier<Map<ItemType, int>> {
  InventoryNotifier() : super({}) {
    _loadInventory();
  }

  static const _key = 'user_inventory';

  Future<void> _loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      state = data.map((key, value) => MapEntry(
            ItemType.values[int.parse(key)],
            value as int,
          ));
    }
  }

  Future<void> _saveInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((key, value) => MapEntry(key.index.toString(), value));
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<void> addItem(ItemType type, int count) async {
    state = {...state, type: (state[type] ?? 0) + count};
    await _saveInventory();
  }

  Future<bool> useItem(ItemType type) async {
    final current = state[type] ?? 0;
    if (current <= 0) return false;

    state = {...state, type: current - 1};
    await _saveInventory();
    return true;
  }

  int getItemCount(ItemType type) {
    return state[type] ?? 0;
  }
}
