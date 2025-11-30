import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/item.dart';
import '../notifier/inventory_notifier.dart';
import '../notifier/wallet_notifier.dart';
import 'widgets/liquid_glass.dart';

class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceState = ref.watch(walletProvider);
    final balance = balanceState.value ?? 0;
    final inventory = ref.watch(inventoryProvider);
    final fMoney = NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('아이템 상점', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Balance Display
            Padding(
              padding: const EdgeInsets.all(16),
              child: LiquidGlass(
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 28, color: Color(0xFF0066CC)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('내 잔액', style: TextStyle(fontSize: 14, color: Colors.black54)),
                          Text(
                            '${fMoney.format(balance)}원',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Shop Items
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ShopItem.allItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final item = ShopItem.allItems[i];
                  final owned = inventory[item.type] ?? 0;
                  return _ShopItemCard(
                    item: item,
                    owned: owned,
                    balance: balance,
                    fMoney: fMoney,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopItemCard extends ConsumerWidget {
  final ShopItem item;
  final int owned;
  final int balance;
  final NumberFormat fMoney;

  const _ShopItemCard({
    required this.item,
    required this.owned,
    required this.balance,
    required this.fMoney,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAfford = balance >= item.price;

    return LiquidGlass(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LiquidGlass(
                borderRadius: 12,
                padding: EdgeInsets.zero,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0066CC), Color(0xFF00B4D8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '보유: $owned',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('가격', style: TextStyle(fontSize: 12, color: Colors.black45)),
                    Text(
                      '${fMoney.format(item.price)}원',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: canAfford ? const Color(0xFF0066CC) : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: canAfford
                    ? () => _showPurchaseDialog(context, ref)
                    : null,
                icon: const Icon(Icons.shopping_cart),
                label: const Text('구매하기'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0066CC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${item.emoji} ${item.name} 구매'),
        content: Text('${fMoney.format(item.price)}원에 구매하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(walletProvider.notifier).spend(item.price);
              await ref.read(inventoryProvider.notifier).addItem(item.type, 1);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.emoji} ${item.name} 구매 완료!')),
                );
              }
            },
            child: const Text('구매'),
          ),
        ],
      ),
    );
  }
}
