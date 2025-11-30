import 'package:shared_preferences/shared_preferences.dart';

class WalletRepository {
  static const _key = 'wallet_balance';

  static const List<Map<String, dynamic>> missions = [
    {'title': '법원 앞 노점 알바', 'min': 100000000, 'max': 300000000},
    {'title': '압류물 운반 도우미', 'min': 200000000, 'max': 400000000},
    {'title': '매각 공고 번역 알바', 'min': 150000000, 'max': 350000000},
    {'title': '감정평가서 서류정리', 'min': 120000000, 'max': 300000000},
    {'title': '경매장 음료 서빙', 'min': 90000000, 'max': 200000000},
    {'title': '법정대리인 보조', 'min': 250000000, 'max': 500000000},
    {'title': '압류자산 촬영/편집', 'min': 180000000, 'max': 350000000},
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
