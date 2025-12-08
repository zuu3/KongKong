import 'dart:math';
import 'package:flutter/material.dart'; // Added for @required, though not strictly necessary for the change, it was in the original context.
import 'database_helper.dart';
import '../models/asset.dart';
import '../models/bid.dart';

class BidRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // AI 입찰자 이름 목록
  static final List<String> _aiBidders = [
    '김철수',
    '이영희',
    '박민수',
    '최지원',
    '정수진',
    '강동원',
    '윤서연',
    '임하늘',
    '송민호',
    '한지민',
    '조성훈',
    '권나라',
    '신동엽',
    '배수지',
    '오정세',
    '문채원',
    '서인국',
    '안보현',
    '김다미',
    '남주혁',
  ];

  /// 실제 공매 방식: 여러 사람이 입찰하고, 가장 높은 가격을 제시한 사람이 낙찰
  Future<Map<String, dynamic>> placeBid({
    required Asset asset,
    required int bidAmount,
    required String bidderName,
    bool isUser = true,
    bool isMatchMode = false,
    double luckBoost = 0.0,
    bool priceFreeze = false,
  }) async {
    // 최저가의 80% 미만은 입찰 불가
    if (bidAmount < asset.minPrice * 0.8) {
      throw Exception('최저가의 80% 이상만 입찰 가능합니다');
    }

    final now = DateTime.now();
    final rand = Random();

    // 처리 중 시뮬레이션 (1~2초)
    await Future.delayed(Duration(milliseconds: 1000 + rand.nextInt(1000)));

    final Map<String, int> aiStrategyCount = {'보수적': 0, '일반': 0, '공격적': 0, '초공격': 0};

    // 사용자 입찰 생성
    final userBid = Bid(
      id: 0, // DB에서 자동 생성
      assetId: asset.id,
      assetTitle: asset.title,
      bidderName: bidderName,
      bidAmount: bidAmount,
      bidTime: now,
      isUser: isUser,
    );

    // 입찰자 생성
    final aiCount = isMatchMode ? 2 + rand.nextInt(3) : 3 + rand.nextInt(5);
    final List<Bid> allBids = [userBid];
    final usedNames = <String>{};

    for (int i = 0; i < aiCount; i++) {
      String aiName;
      do {
        aiName = _aiBidders[rand.nextInt(_aiBidders.length)];
      } while (usedNames.contains(aiName));
      usedNames.add(aiName);

      double bidRate;
      final strategy = rand.nextInt(100);
      String strategyLabel;

      if (strategy < 30) {
        bidRate = 0.85 + rand.nextDouble() * 0.10;
        strategyLabel = '보수적';
      } else if (strategy < 70) {
        bidRate = 0.95 + rand.nextDouble() * 0.15;
        strategyLabel = '일반';
      } else if (strategy < 90) {
        bidRate = 1.10 + rand.nextDouble() * 0.15;
        strategyLabel = '공격적';
      } else {
        bidRate = 1.25 + rand.nextDouble() * 0.15;
        strategyLabel = '초공격';
      }

      if (priceFreeze) {
        bidRate *= 0.8;
      }
      aiStrategyCount[strategyLabel] = (aiStrategyCount[strategyLabel] ?? 0) + 1;

      final aiBidAmount = (asset.minPrice * bidRate).round();
      final aiBid = Bid(
        id: 0,
        assetId: asset.id,
        assetTitle: asset.title,
        bidderName: aiName,
        bidAmount: aiBidAmount,
        bidTime: now.add(Duration(seconds: rand.nextInt(10))),
        isUser: false,
      );

      allBids.add(aiBid);
    }

    // 낙찰자 결정 로직
    final scores = <Bid, double>{};
    double calcScore(Bid bid) {
      final ratio = bid.bidAmount / asset.minPrice;
      double factor;
      if (ratio > 10.0)
        factor = 0.05;
      else if (ratio > 6.0)
        factor = 0.15;
      else if (ratio > 3.5)
        factor = 0.35;
      else if (ratio > 3.0)
        factor = 0.6;
      else if (ratio > 2.5)
        factor = 0.78;
      else if (ratio > 1.8)
        factor = 0.9;
      else if (ratio > 1.3)
        factor = 0.96;
      else
        factor = 1.0;

      final jitter = 0.94 + rand.nextDouble() * 0.12;
      double score = bid.bidAmount * factor * jitter;

      if (bid.isUser && luckBoost > 0) {
        score *= (1.0 + luckBoost);
      }
      return score;
    }

    for (final b in allBids) {
      scores[b] = calcScore(b);
    }

    // 점수 내림차순 정렬
    allBids.sort((a, b) => scores[b]!.compareTo(scores[a]!));

    final winner = allBids.first;
    final isWin = winner.isUser;
    final userRank = allBids.indexWhere((b) => b.isUser) + 1;

    // DB에 저장 (결과 반영하여 저장)
    for (final bid in allBids) {
      // 낙찰 여부 설정
      final result = (bid == winner) ? '낙찰' : '유찰';
      final bidWithResult = bid.copyWith(result: result);

      // 사용자 입찰만 저장하거나, 전체 저장 후 쿼리에서 필터링 (여기선 전체 저장)
      await _dbHelper.insertBid(bidWithResult);
    }

    return {
      'isWin': isWin,
      'winningBid': winner.bidAmount,
      'userRank': userRank,
      'totalBidders': allBids.length,
      'allBids': allBids, // 결과 페이지용 (일시적)
      'aiStrategies': aiStrategyCount,
      'bidLogs': allBids,
      'mode': isMatchMode ? '실시간 매칭(인간+AI)' : 'AI 시뮬레이션',
    };
  }

  Future<List<Bid>> fetchBids() async {
    return await _dbHelper.fetchAllBids();
  }

  Future<List<Bid>> fetchUserBids() async {
    return await _dbHelper.fetchUserBids();
  }

  Future<List<Bid>> fetchBidsByAsset(int assetId) async {
    final allBids = await _dbHelper.fetchAllBids();
    return allBids.where((b) => b.assetId == assetId).toList();
  }

  Future<int> deleteBid(int id) async {
    return await _dbHelper.deleteBid(id);
  }

  Future<void> clearAll() async {
    await _dbHelper.clearBids();
  }
}
