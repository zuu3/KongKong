import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/asset.dart';
import '../models/bid.dart';

class BidRepository {
  // 웹 지원을 위해 메모리 기반 스토리지 사용
  static final List<Bid> _memoryStorage = [];
  static int _nextId = 1;
  static bool _loaded = false;
  static const _prefsKey = 'bids_storage';

  // AI 입찰자 이름 목록 (더 다양하게)
  static final List<String> _aiBidders = [
    '김철수', '이영희', '박민수', '최지원', '정수진',
    '강동원', '윤서연', '임하늘', '송민호', '한지민',
    '조성훈', '권나라', '신동엽', '배수지', '오정세',
    '문채원', '서인국', '안보현', '김다미', '남주혁',
  ];

  /// 실제 공매 방식: 여러 사람이 입찰하고, 가장 높은 가격을 제시한 사람이 낙찰
  /// 동일 금액이면 먼저 입찰한 사람이 낙찰
  Future<Map<String, dynamic>> placeBid({
    required Asset asset,
    required int bidAmount,
    required String bidderName,
    bool isUser = true,
    bool isMatchMode = false,
    double luckBoost = 0.0, // 0.0 ~ 1.0, 행운의 참 사용 시 0.1
    bool priceFreeze = false, // 가격 동결 사용 시 true
  }) async {
    await _ensureLoaded();
    // 최저가의 80% 미만은 입찰 불가
    if (bidAmount < asset.minPrice * 0.8) {
      throw Exception('최저가의 80% 이상만 입찰 가능합니다');
    }

    final now = DateTime.now();
    final rand = Random();

    // 처리 중 시뮬레이션 (1~2초)
    await Future.delayed(Duration(milliseconds: 1000 + rand.nextInt(1000)));

    final Map<String, int> aiStrategyCount = {
      '보수적': 0,
      '일반': 0,
      '공격적': 0,
      '초공격': 0,
    };

    // 사용자 입찰 저장
    final userBid = Bid(
      id: _nextId++,
      assetId: asset.id,
      assetTitle: asset.title,
      bidderName: bidderName,
      bidAmount: bidAmount,
      bidTime: now,
      isUser: isUser,
    );
    _memoryStorage.insert(0, userBid);

    // 입찰자 생성
    final aiCount = isMatchMode ? 2 + rand.nextInt(3) : 3 + rand.nextInt(5); // 실시간 매칭은 조금 더 타이트
    final List<Bid> allBids = [userBid];
    final usedNames = <String>{};

    for (int i = 0; i < aiCount; i++) {
      // 중복되지 않는 이름 선택
      String aiName;
      do {
        aiName = _aiBidders[rand.nextInt(_aiBidders.length)];
      } while (usedNames.contains(aiName));
      usedNames.add(aiName);

      // AI 입찰 패턴을 더 현실적으로
      double bidRate;
      final strategy = rand.nextInt(100);
      String strategyLabel;

      if (strategy < 30) {
        // 30%: 보수적 입찰 (85~95%)
        bidRate = 0.85 + rand.nextDouble() * 0.10;
        strategyLabel = '보수적';
      } else if (strategy < 70) {
        // 40%: 일반적 입찰 (95~110%)
        bidRate = 0.95 + rand.nextDouble() * 0.15;
        strategyLabel = '일반';
      } else if (strategy < 90) {
        // 20%: 공격적 입찰 (110~125%)
        bidRate = 1.10 + rand.nextDouble() * 0.15;
        strategyLabel = '공격적';
      } else {
        // 10%: 초공격적 입찰 (125~140%)
        bidRate = 1.25 + rand.nextDouble() * 0.15;
        strategyLabel = '초공격';
      }
      
      // 가격 동결 효과: AI 입찰가를 20% 감소
      if (priceFreeze) {
        bidRate *= 0.8;
      }
      aiStrategyCount[strategyLabel] = (aiStrategyCount[strategyLabel] ?? 0) + 1;

      final aiBidAmount = (asset.minPrice * bidRate).round();

      // AI 입찰 시간은 사용자보다 전후 5분 이내
      final timeOffset = rand.nextInt(isMatchMode ? 300 : 600) - (isMatchMode ? 120 : 300); // 매칭 모드는 범위 축소
      final aiTime = now.add(Duration(seconds: timeOffset));

      final aiBid = Bid(
        id: _nextId++,
        assetId: asset.id,
        assetTitle: asset.title,
        bidderName: aiName,
        bidAmount: aiBidAmount,
        bidTime: aiTime,
        isUser: false,
      );

      allBids.add(aiBid);
      _memoryStorage.insert(0, aiBid);
    }

    // 낙찰자 결정: 점수 기반 (과도한 고가 입찰은 페널티, 약간의 랜덤성)
    final scores = <int, double>{}; // bid.id -> score
    double calcScore(Bid bid) {
      final ratio = bid.bidAmount / asset.minPrice;
      double factor;
      if (ratio > 10.0) {
        factor = 0.05; // 극단적
      } else if (ratio > 6.0) {
        factor = 0.15;
      } else if (ratio > 3.5) {
        factor = 0.35;
      } else if (ratio > 3.0) {
        factor = 0.6;
      } else if (ratio > 2.5) {
        factor = 0.78;
      } else if (ratio > 1.8) {
        factor = 0.9;
      } else if (ratio > 1.3) {
        factor = 0.96;
      } else {
        factor = 1.0;
      }
      final jitter = 0.94 + rand.nextDouble() * 0.12; // 0.94~1.06
      double score = bid.bidAmount * factor * jitter;
      // 사용자의 행운 부스트 적용
      if (bid.isUser && luckBoost > 0) {
        score *= (1.0 + luckBoost);
      }
      return score;
    }

    for (final b in allBids) {
      scores[b.id!] = calcScore(b);
    }

    allBids.sort((a, b) {
      final scoreCompare = (scores[b.id!]!).compareTo(scores[a.id!]!);
      if (scoreCompare != 0) return scoreCompare;
      // 점수가 같으면 더 높은 금액, 금액도 같으면 빠른 시간
      final amountCompare = b.bidAmount.compareTo(a.bidAmount);
      if (amountCompare != 0) return amountCompare;
      return a.bidTime.compareTo(b.bidTime);
    });

    final winner = allBids.first;
    final isWin = winner.id == userBid.id;

    // 결과 업데이트
    for (var bid in allBids) {
      final updatedBid = bid.copyWith(result: bid.id == winner.id ? '낙찰' : '유찰');
      final index = _memoryStorage.indexWhere((b) => b.id == bid.id);
      if (index != -1) {
        _memoryStorage[index] = updatedBid;
      }
    }

    await _persist();

    // 시간 순 로그
    final bidLogs = List<Bid>.from(allBids)
      ..sort((a, b) => a.bidTime.compareTo(b.bidTime));

    return {
      'isWin': isWin,
      'winningBid': winner.bidAmount,
      'totalBidders': allBids.length,
      'userRank': allBids.indexWhere((b) => b.id == userBid.id) + 1,
      'allBids': allBids,
      'aiStrategies': aiStrategyCount,
      'bidLogs': bidLogs,
      'mode': isMatchMode ? '실시간 매칭(인간+AI)' : 'AI 시뮬레이션',
    };
  }

  Future<int> insertBid(Bid bid) async {
    await _ensureLoaded();
    final newBid = bid.copyWith(id: _nextId++);
    _memoryStorage.insert(0, newBid);
    await _persist();
    return newBid.id!;
  }

  Future<List<Bid>> fetchBids() async {
    await _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_memoryStorage);
  }

  /// 사용자의 입찰만 가져오기
  Future<List<Bid>> fetchUserBids() async {
    await _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 100));
    return _memoryStorage.where((bid) => bid.isUser).toList();
  }

  /// 특정 asset에 대한 모든 입찰 가져오기
  Future<List<Bid>> fetchBidsByAsset(int assetId) async {
    await _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 100));
    return _memoryStorage.where((bid) => bid.assetId == assetId).toList();
  }

  Future<int> deleteBid(int id) async {
    await _ensureLoaded();
    final index = _memoryStorage.indexWhere((b) => b.id == id);
    if (index != -1) {
      _memoryStorage.removeAt(index);
      await _persist();
      return 1;
    }
    return 0;
  }

  Future<int> clearAll() async {
    await _ensureLoaded();
    final count = _memoryStorage.length;
    _memoryStorage.clear();
    await _persist();
    return count;
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefsKey);
      if (jsonStr != null) {
        try {
          final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
          _memoryStorage
            ..clear()
            ..addAll(list.map((e) => Bid.fromMap(e as Map<String, dynamic>)));
          if (_memoryStorage.isNotEmpty) {
            _nextId = (_memoryStorage.map((b) => b.id ?? 0).reduce((a, b) => a > b ? a : b)) + 1;
          }
        } catch (_) {
          // ignore malformed cache
        }
      }
    } catch (_) {
      // shared_preferences가 없으면 메모리로만 동작
    } finally {
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_memoryStorage.map((e) => e.toMap()).toList());
      await prefs.setString(_prefsKey, encoded);
    } catch (_) {
      // 저장 실패는 무시 (웹 등)
    }
  }
}
