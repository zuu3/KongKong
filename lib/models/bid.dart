class Bid {
  final int? id;
  final int assetId;
  final String assetTitle;
  final String bidderName; // 입찰자 이름
  final int bidAmount;
  final DateTime bidTime; // 입찰 시간 (동일가 판정용)
  final String? result; // "낙찰" or "유찰" or null (아직 미정)
  final bool isUser; // 사용자의 입찰인지 여부

  const Bid({
    this.id,
    required this.assetId,
    required this.assetTitle,
    required this.bidderName,
    required this.bidAmount,
    required this.bidTime,
    this.result,
    this.isUser = false,
  });

  Bid copyWith({int? id, String? result}) => Bid(
    id: id ?? this.id,
    assetId: assetId,
    assetTitle: assetTitle,
    bidderName: bidderName,
    bidAmount: bidAmount,
    bidTime: bidTime,
    result: result ?? this.result,
    isUser: isUser,
  );

  factory Bid.fromMap(Map<String, dynamic> map) => Bid(
    id: map['id'] as int?,
    assetId: map['assetId'] as int,
    assetTitle: map['assetTitle'] as String,
    bidderName: map['bidderName'] as String,
    bidAmount: map['bidAmount'] as int,
    bidTime: DateTime.parse(map['bidTime'] as String),
    result: map['result'] as String?,
    isUser: _parseIsUser(map['isUser']),
  );

  static bool _parseIsUser(dynamic raw) {
    if (raw is int) return raw == 1;
    if (raw is bool) return raw;
    return false;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'assetId': assetId,
    'assetTitle': assetTitle,
    'bidderName': bidderName,
    'bidAmount': bidAmount,
    'bidTime': bidTime.toIso8601String(),
    'result': result,
    'isUser': isUser ? 1 : 0,
  };
}
