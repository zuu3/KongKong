import 'database_helper.dart';
import '../models/owned_asset.dart';

class OwnedAssetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<OwnedAsset> _cache = [];

  Future<List<OwnedAsset>> fetchAll() async {
    _cache = await _dbHelper.fetchOwnedAssets();
    return List.from(_cache);
  }

  Future<void> add(OwnedAsset asset) async {
    await _dbHelper.insertOwnedAsset(asset);
    // Refresh cache
    _cache = await _dbHelper.fetchOwnedAssets();
  }

  Future<void> removeAt(int index) async {
    if (index >= 0 && index < _cache.length) {
      final asset = _cache[index];
      await _dbHelper.deleteOwnedAsset(asset.asset.id);
      _cache.removeAt(index);
    }
  }

  Future<void> clear() async {
    // 하나씩 삭제하거나 전체 삭제 메서드 구현 필요
    // 현재 DatabaseHelper에는 deleteOwnedAsset(id)만 있음
    // 전체 삭제를 위해 loop 돌거나 DatabaseHelper에 clear 추가
    // 여기서는 cache 기반으로 loop 삭제
    for (final asset in _cache) {
      await _dbHelper.deleteOwnedAsset(asset.asset.id);
    }
    _cache.clear();
  }
}
