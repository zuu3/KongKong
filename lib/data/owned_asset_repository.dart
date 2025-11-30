import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/owned_asset.dart';

class OwnedAssetRepository {
  static const _key = 'owned_assets';
  List<OwnedAsset> _cache = [];
  bool _loaded = false;

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_key);
      if (str != null) {
        final list = (jsonDecode(str) as List)
            .map((e) => OwnedAsset.fromMap(e as Map<String, dynamic>))
            .toList();
        _cache = list;
      }
    } catch (_) {}
    _loaded = true;
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(_cache.map((e) => e.toMap()).toList()),
      );
    } catch (_) {}
  }

  Future<List<OwnedAsset>> fetchAll() async {
    await _load();
    return List.from(_cache);
  }

  Future<void> add(OwnedAsset asset) async {
    await _load();
    _cache.insert(0, asset);
    await _save();
  }

  Future<void> removeAt(int index) async {
    await _load();
    if (index >= 0 && index < _cache.length) {
      _cache.removeAt(index);
      await _save();
    }
  }

  Future<void> clear() async {
    _cache.clear();
    await _save();
  }
}
