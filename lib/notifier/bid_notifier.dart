import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/bid_repository.dart';
import '../models/asset.dart';
import '../models/bid.dart';

final bidRepositoryProvider = Provider<BidRepository>((ref) {
  return BidRepository();
});

final bidHistoryProvider = StateNotifierProvider<BidHistoryNotifier, AsyncValue<List<Bid>>>((ref) {
  return BidHistoryNotifier(ref.watch(bidRepositoryProvider))..load();
});

class BidHistoryNotifier extends StateNotifier<AsyncValue<List<Bid>>> {
  final BidRepository _repo;
  BidHistoryNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repo.fetchUserBids(); // 사용자 입찰만 표시
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 실제 공매 방식으로 입찰
  Future<Map<String, dynamic>> placeBid(
    Asset asset,
    int bidAmount, {
    bool isMatchMode = false,
    double luckBoost = 0.0,
    bool priceFreeze = false,
  }) async {
    final result = await _repo.placeBid(
      asset: asset,
      bidAmount: bidAmount,
      bidderName: '나', // 사용자 이름
      isUser: true,
      isMatchMode: isMatchMode,
      luckBoost: luckBoost,
      priceFreeze: priceFreeze,
    );
    await load();
    return result;
  }

  Future<void> delete(int id) async {
    await _repo.deleteBid(id);
    await load();
  }

  Future<void> clearAll() async {
    await _repo.clearAll();
    await load();
  }
}
