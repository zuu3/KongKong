import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../notifier/owned_asset_notifier.dart';
import '../notifier/wallet_notifier.dart';
import '../models/owned_asset.dart';
import '../data/market_service.dart';
import '../notifier/user_stats_notifier.dart';
import 'widgets/liquid_glass.dart';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owned = ref.watch(ownedAssetsProvider);
    final fMoney = NumberFormat.decimalPattern();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('내 보유 자산', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => ref.read(ownedAssetsProvider.notifier).clear(),
            icon: const Icon(Icons.delete_sweep, color: Colors.black87),
            tooltip: '모두 정리',
          ),
        ],
      ),
      body: SafeArea(
        child: owned.when(
          data: (list) {
            if (list.isEmpty) {
              return const Center(child: Text('보유 자산이 없습니다', style: TextStyle(color: Colors.black54)));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = list[i];
                return _OwnedCard(item: item, index: i, fMoney: fMoney);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('에러: $e', style: const TextStyle(color: Colors.black87))),
        ),
      ),
    );
  }
}

class _OwnedCard extends ConsumerWidget {
  final OwnedAsset item;
  final int index;
  final NumberFormat fMoney;

  const _OwnedCard({required this.item, required this.index, required this.fMoney});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketPrice = MarketService.calculateMarketPrice(item);
    final profit = MarketService.getProfit(item, marketPrice);
    final profitPercent = MarketService.getProfitPercentage(item, marketPrice);
    return LiquidGlass(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.asset.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text('${item.asset.category} · 획득가 ${fMoney.format(item.winningBid)}원',
                        style: const TextStyle(color: Colors.black54)),
                    Text('보유일: ${DateFormat('yyyy.MM.dd').format(item.acquiredAt)}',
                        style: const TextStyle(color: Colors.black45, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => ref.read(ownedAssetsProvider.notifier).removeAt(index),
                icon: const Icon(Icons.close),
                tooltip: '삭제',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Market Price Display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: profit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: profit >= 0 ? Colors.green.shade200 : Colors.red.shade200,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('시장 가격', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    Text(
                      '${fMoney.format(marketPrice)}원',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: profit >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('손익', style: TextStyle(fontSize: 12, color: Colors.black45)),
                    Text(
                      '${profit >= 0 ? '+' : ''}${fMoney.format(profit)}원 (${profitPercent.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: profit >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () => _showSellDialog(context, ref, index),
                  icon: const Icon(Icons.attach_money),
                  label: const Text('시장가 판매'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ref.read(ownedAssetsProvider.notifier).removeAt(index),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('삭제'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSellDialog(BuildContext context, WidgetRef ref, int index) {
    final item = ref.read(ownedAssetsProvider).value![index];
    final marketPrice = MarketService.calculateMarketPrice(item);
    final profit = MarketService.getProfit(item, marketPrice);
    final profitPercent = MarketService.getProfitPercentage(item, marketPrice);
    final fMoney = NumberFormat.decimalPattern();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('자산 판매 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.asset.title}을(를) 판매하시겠습니까?', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _InfoRow('구매가', '${fMoney.format(item.winningBid)}원'),
            _InfoRow('시장가', '${fMoney.format(marketPrice)}원'),
            const Divider(),
            _InfoRow(
              '예상 손익',
              '${profit >= 0 ? '+' : ''}${fMoney.format(profit)}원 (${profitPercent.toStringAsFixed(1)}%)',
              textColor: profit >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(walletProvider.notifier).earnExact(marketPrice);
              await ref.read(ownedAssetsProvider.notifier).removeAt(index);
              // Reward XP for selling (50 XP)
              await ref.read(userStatsProvider.notifier).gainXp(50);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('판매 완료! ${profit >= 0 ? '수익' : '손실'}: ${fMoney.format(profit)}원 (+50 XP)'),
                  ),
                );
              }
            },
            child: const Text('판매'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? textColor;

  const _InfoRow(this.label, this.value, {this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: textColor ?? Colors.black87)),
        ],
      ),
    );
  }
}
