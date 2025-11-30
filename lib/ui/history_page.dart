import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../notifier/bid_notifier.dart';
import '../models/bid.dart';
import 'widgets/liquid_glass.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(bidHistoryProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('입찰 내역', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => ref.read(bidHistoryProvider.notifier).clearAll(),
            icon: const Icon(Icons.delete_forever, color: Colors.black87),
            tooltip: '전체 삭제',
          ),
        ],
      ),
      body: SafeArea(
        child: history.when(
          data: (list) {
            if (list.isEmpty) {
              return const Center(
                child: Text('입찰 내역이 없습니다.', style: TextStyle(color: Colors.black54)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _BidTile(bid: list[i]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('에러: $e', style: const TextStyle(color: Colors.black87))),
        ),
      ),
    );
  }
}

class _BidTile extends ConsumerWidget {
  final Bid bid;
  const _BidTile({required this.bid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fMoney = NumberFormat.decimalPattern();
    final fTime = DateFormat('yyyy.MM.dd HH:mm');
    return Dismissible(
      key: ValueKey(bid.id ?? '${bid.assetId}-${bid.bidTime.toIso8601String()}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        if (bid.id != null) {
          ref.read(bidHistoryProvider.notifier).delete(bid.id!);
        }
      },
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      child: LiquidGlass(
        borderRadius: 16,
        padding: EdgeInsets.zero,
        child: ListTile(
          title: Text(
            bid.assetTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('입찰가: ${fMoney.format(bid.bidAmount)}원', style: const TextStyle(color: Colors.black54)),
              Text('입찰일: ${fTime.format(bid.bidTime)}', style: const TextStyle(color: Colors.black45)),
            ],
          ),
          trailing: Chip(
            label: Text(bid.result ?? '대기중'),
            labelStyle: const TextStyle(color: Colors.black87),
            backgroundColor: bid.result == '낙찰'
                ? Colors.green.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.15),
          ),
        ),
      ),
    );
  }
}
