import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/owned_asset_repository.dart';
import '../models/owned_asset.dart';

final ownedAssetRepositoryProvider = Provider((ref) => OwnedAssetRepository());

final ownedAssetsProvider = StateNotifierProvider<OwnedAssetNotifier, AsyncValue<List<OwnedAsset>>>((ref) {
  return OwnedAssetNotifier(ref.read(ownedAssetRepositoryProvider))..load();
});

class OwnedAssetNotifier extends StateNotifier<AsyncValue<List<OwnedAsset>>> {
  OwnedAssetNotifier(this._repo) : super(const AsyncValue.loading());
  final OwnedAssetRepository _repo;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repo.fetchAll();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(OwnedAsset asset) async {
    await _repo.add(asset);
    await load();
  }

  Future<void> removeAt(int index) async {
    await _repo.removeAt(index);
    await load();
  }

  Future<void> clear() async {
    await _repo.clear();
    await load();
  }
}
