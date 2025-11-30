import '../models/owned_asset.dart';
import 'dart:math';

class MarketService {
  static final _random = Random();

  /// Calculate current market price for an owned asset
  /// Formula: purchasePrice * (1 + 0.05 * daysHeld + randomFluctuation)
  /// where randomFluctuation is between -10% to +30%
  static int calculateMarketPrice(OwnedAsset asset) {
    final now = DateTime.now();
    final daysHeld = now.difference(asset.acquiredAt).inDays;
    
    // Base appreciation: 5% per day
    final timeAppreciation = 0.05 * daysHeld;
    
    // Random market fluctuation: -10% to +30%
    final fluctuation = -0.1 + (_random.nextDouble() * 0.4);
    
    // Total multiplier (minimum 0.8x to avoid too much loss)
    final multiplier = max(0.8, 1.0 + timeAppreciation + fluctuation);
    
    return (asset.winningBid * multiplier).round();
  }

  /// Get profit/loss amount
  static int getProfit(OwnedAsset asset, int marketPrice) {
    return marketPrice - asset.winningBid;
  }

  /// Get profit/loss percentage
  static double getProfitPercentage(OwnedAsset asset, int marketPrice) {
    return ((marketPrice - asset.winningBid) / asset.winningBid) * 100;
  }
}
