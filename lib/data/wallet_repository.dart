import 'package:shared_preferences/shared_preferences.dart';

class WalletRepository {
  static const _key = 'wallet_balance';

  static const List<Map<String, dynamic>> missions = [
    {'title': '법원 앞 붕어빵 장사 🍞', 'min': 100000000, 'max': 300000000},
    {'title': '압류된 피아노 옮기다 허리 다침 💸', 'min': 200000000, 'max': 400000000},
    {'title': '판사님 커피 심부름 ☕', 'min': 150000000, 'max': 350000000},
    {'title': '경매장 CCTV 하루종일 모니터링 👀', 'min': 120000000, 'max': 300000000},
    {'title': '유찰된 물건 위로해주기 😢', 'min': 90000000, 'max': 200000000},
    {'title': '낙찰자들 축하 풍선 불어주기 🎈', 'min': 250000000, 'max': 500000000},
    {'title': '압류 스티커 1000장 붙이기 📋', 'min': 180000000, 'max': 350000000},
  ];

  /// 지갑 잔액을 로컬에 저장 (SharedPreferences)
  Future<void> saveBalance(int balance) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, balance);
    } catch (_) {
      // 웹 등 플러그인 미지원 환경에서는 무시
    }
  }

  /// 저장된 잔액 로드. 없으면 null
  Future<int?> loadBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_key);
    } catch (_) {
      return null;
    }
  }
}
