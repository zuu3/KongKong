import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/asset_repository.dart';
import '../models/asset.dart';

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  return AssetRepository();
});

final assetFilterProvider = StateProvider<String>((ref) => '전체');

final assetListProvider = FutureProvider<List<Asset>>((ref) async {
  final repo = ref.watch(assetRepositoryProvider);
  final filter = ref.watch(assetFilterProvider);
  return repo.fetchAssets(category: filter == '전체' ? null : filter);
});
