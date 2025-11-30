import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/wallet_repository.dart';

/// 간단한 지갑 상태: 사용 가능 잔액만 관리
final walletProvider = StateNotifierProvider<WalletNotifier, AsyncValue<int>>((ref) {
  return WalletNotifier(WalletRepository())..load();
});

class WalletNotifier extends StateNotifier<AsyncValue<int>> {
  WalletNotifier(this._repo) : super(const AsyncValue.loading());
  final WalletRepository _repo;
  final _rand = Random();
  static const _seed = 200000000; // 초기 시드 머니
  static const _penaltyMin = 100000; // 가끔 패널티

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final saved = await _repo.loadBalance();
      final balance = saved ?? _seed;
      state = AsyncValue.data(balance);
      // 최초 실행 시 시드 머니도 저장해 다음 실행에 반영
      if (saved == null) {
        await _repo.saveBalance(balance);
      }
    } catch (e, st) {
      state = const AsyncValue.data(_seed);
    }
  }

  Future<void> _persist(int balance) async {
    state = AsyncValue.data(balance);
    await _repo.saveBalance(balance);
  }

  /// 수입 추가 (예: 미션 보상)
  Future<void> earn(int amount) async {
    final current = state.value ?? _seed;
    await _persist(current + amount);
  }

  /// 정해진 금액 적립
  Future<void> earnExact(int amount) async {
    await earn(amount);
  }

  /// delta를 그대로 적용 (음수 포함, 0 이하로는 내려가지 않음)
  Future<void> applyDelta(int delta) async {
    final current = state.value ?? _seed;
    final next = (current + delta).clamp(0, 1 << 31);
    await _persist(next);
  }

  /// 랜덤한 퀘스트 보상 (5,000,000~20,000,000)
  Future<int> earnRandom() async {
    final mission = WalletRepository.missions[_rand.nextInt(WalletRepository.missions.length)];
    final min = mission['min'] as int;
    final max = mission['max'] as int;
    final reward = min + _rand.nextInt(max - min + 1);
    // 10% 확률로 소액 패널티
    if (_rand.nextInt(100) < 10) {
      final penalty = _penaltyMin + _rand.nextInt(300000);
      final current = state.value ?? _seed;
      await _persist((current + reward - penalty).clamp(0, 1 << 31));
      return reward - penalty;
    }
    await earn(reward);
    return reward;
  }

  /// 지출: 잔액이 부족하면 false
  Future<bool> spend(int amount) async {
    final current = state.value ?? _seed;
    if (current < amount) return false;
    await _persist(current - amount);
    return true;
  }

  /// 행운 뽑기: 70% 큰 보상, 20% 중간 보상, 10% 페널티
  Future<int> playLuckyDraw() async {
    final roll = _rand.nextInt(100);
    int delta;
    if (roll < 70) {
      delta = 100000000 + _rand.nextInt(400000001); // 1억~5억
    } else if (roll < 90) {
      delta = 50000000 + _rand.nextInt(50000001); // 5천만~1억
    } else {
      delta = -(20000000 + _rand.nextInt(30000001)); // -2천만~-5천만
    }
    await applyDelta(delta);
    return delta;
  }
}
