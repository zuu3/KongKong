import 'dart:math';
import '../models/asset.dart';

class AssetRepository {
  // 메모리 기반 자산 저장소 (유동적으로 추가/삭제 가능)
  static final _rand = Random();
  static final List<Asset> _assets = [];

  static int _nextId = 11;

  Future<List<Asset>> fetchAssets({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 250));

    // 마감된 물건은 자동으로 제거
    _assets.removeWhere((asset) {
      if (asset.deadline == null) return false;
      return asset.deadline!.isBefore(DateTime.now());
    });

    _ensureStock();

    if (category == null || category == '전체') return List.from(_assets);
    return _assets.where((a) => a.category == category).toList();
  }

  /// 새 공매 물건 추가
  Future<void> addAsset(Asset asset) async {
    _assets.add(asset.copyWith(id: _nextId++));
  }

  /// 공매 물건 삭제
  Future<void> removeAsset(int id) async {
    _assets.removeWhere((asset) => asset.id == id);
    _ensureStock();
  }

  /// 추천 입찰가 계산
  int getRecommendedBid(Asset asset) {
    final rand = Random();
    // 최저가의 90~110% 사이를 추천
    final recommendedRate = 0.90 + rand.nextDouble() * 0.20;
    return (asset.minPrice * recommendedRate).round();
  }

  /// 낙찰 예상 확률 계산
  String analyzeBidChance(Asset asset, int bidAmount) {
    final rate = bidAmount / asset.minPrice;

    if (rate < 0.8) return '매우 낮음 (입찰 불가)';
    if (rate < 0.95) return '낮음 (20%)';
    if (rate < 1.05) return '보통 (50%)';
    if (rate < 1.15) return '높음 (75%)';
    return '매우 높음 (90%)';
  }

  void _ensureStock() {
    // 초기 채우기
    if (_assets.isEmpty) {
      for (int i = 0; i < 10; i++) {
        _assets.add(_generateAsset());
      }
      return;
    }
    while (_assets.length < 10) {
      _assets.add(_generateAsset());
    }
  }

  Asset _generateAsset() {
    final categories = ['부동산', '차량', '물품'];
    final cat = categories[_rand.nextInt(categories.length)];

    String title;
    int minPrice;
    switch (cat) {
      case '부동산':
        const addresses = ['서울 강남구', '부산 해운대구', '인천 연수구', '대구 수성구', '경기 판교'];
        const types = [
          '오피스텔 (귀신 안나옴)',
          '상가 (옆집과 사이 안좋음)',
          '토지 (잡초 무성)',
          '주택 (벽지 아주 독특함)',
          '빌라 (계단 숨참)',
        ];
        title =
            '${addresses[_rand.nextInt(addresses.length)]} ${types[_rand.nextInt(types.length)]} ${100 + _rand.nextInt(900)}호';
        minPrice = 300000000 + _rand.nextInt(600000000);
        break;
      case '차량':
        const models = [
          '테슬라 모델3 (충전기 없음)',
          'BMW 520d (브레이크 있음)',
          '벤츠 E300 (에어컨 가끔 작동)',
          '쏘렌토 하이브리드 (진짜임)',
          '그랜저 IG (애증의)',
        ];
        title = '압류 차량 - ${models[_rand.nextInt(models.length)]} ${2018 + _rand.nextInt(6)}년식';
        minPrice = 20000000 + _rand.nextInt(30000000);
        break;
      default:
        const items = [
          '사무가구 일괄 (의자 하나 삐걱)',
          '카메라 장비 세트 (아재 감성)',
          '공작기계 2대 (작동법 모름)',
          '농기계 패키지 (녹슬었지만 멋짐)',
          '노트북 20대 (윈도우XP 장착)',
        ];
        title = items[_rand.nextInt(items.length)];
        minPrice = 5000000 + _rand.nextInt(20000000);
    }

    return Asset(
      id: _nextId++,
      title: title,
      minPrice: minPrice,
      category: cat,
      deadline: DateTime.now().add(Duration(minutes: 1 + _rand.nextInt(10))),
    );
  }
}
