import 'asset.dart';

class OwnedAsset {
  final Asset asset;
  final int winningBid;
  final DateTime acquiredAt;

  const OwnedAsset({
    required this.asset,
    required this.winningBid,
    required this.acquiredAt,
  });

  factory OwnedAsset.fromMap(Map<String, dynamic> map) => OwnedAsset(
        asset: Asset.fromMap(map['asset'] as Map<String, dynamic>),
        winningBid: map['winningBid'] as int,
        acquiredAt: DateTime.parse(map['acquiredAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        'asset': asset.toMap(),
        'winningBid': winningBid,
        'acquiredAt': acquiredAt.toIso8601String(),
      };
}
