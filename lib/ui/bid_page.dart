import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/asset.dart';
import '../notifier/bid_notifier.dart';
import '../notifier/asset_notifier.dart';
import 'result_page.dart';
import '../notifier/wallet_notifier.dart';
import '../notifier/user_stats_notifier.dart';
import '../notifier/inventory_notifier.dart';
import '../models/item.dart';
import 'widgets/liquid_glass.dart';
import 'widgets/lucky_charm_dialog.dart';

class BidPage extends ConsumerStatefulWidget {
  final Asset asset;
  const BidPage({super.key, required this.asset});

  @override
  ConsumerState<BidPage> createState() => _BidPageState();
}

class _BidPageState extends ConsumerState<BidPage> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();
  int _countdown = 60;
  Timer? _timer;
  bool _isTimerActive = false;
  bool _isSubmitting = false;
  String _bidChance = '';
  double _luckBoost = 0.0; // 행운의 참 효과 (0.1 = 10% 부스트)
  bool _priceFreeze = false; // 가격 동결 효과
  bool _hasSecondChance = false; // 재도전권 보유 여부

  @override
  void initState() {
    super.initState();
    _startTimer();
    _updateRecommendation();
  }

  void _updateRecommendation() {
    final repo = ref.read(assetRepositoryProvider);
    final recommended = repo.getRecommendedBid(widget.asset);
    _ctrl.text = recommended.toString();
    _updateBidChance();
  }

  void _updateBidChance() {
    final text = _ctrl.text.replaceAll(',', '');
    if (text.isEmpty) return;
    final amount = int.tryParse(text);
    if (amount == null) return;
    
    final repo = ref.read(assetRepositoryProvider);
    setState(() {
      _bidChance = repo.analyzeBidChance(widget.asset, amount);
    });
  }

  void _startTimer() {
    _isTimerActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _isTimerActive = false;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.decimalPattern();
    final balanceState = ref.watch(walletProvider);
    final balance = balanceState.value ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.asset.title,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: LiquidGlass(
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 18, color: Colors.black87),
                  const SizedBox(width: 4),
                  Text(
                    '$_countdown초',
                    style: TextStyle(
                      color: _countdown <= 10 ? Colors.redAccent : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _openInventory,
            icon: const Icon(Icons.backpack_outlined, color: Colors.black87),
            tooltip: '아이템 가방',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                LiquidGlass(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('내 잔액', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                          if (balanceState is AsyncLoading)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Text(
                              '${f.format(balance)}원',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIconForCategory(widget.asset.category),
                              color: Colors.black87,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '카테고리',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.asset.category,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.asset.title,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32, color: Colors.black12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '최저입찰가',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
                          ),
                          Text(
                            '${f.format(widget.asset.minPrice)}원',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 20, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '기준가 ±2% 범위 내 입찰 시 낙찰!',
                                style: TextStyle(fontSize: 14, color: Colors.amber.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Luck Boost Indicator
                if (_luckBoost > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('🍀', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '행운의 참 활성화!',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                '낙찰 확률 +${(_luckBoost * 100).toInt()}% 증가',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.auto_awesome, color: Colors.white),
                      ],
                    ),
                  ),

                // Price Freeze Indicator
                if (_priceFreeze)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('❄️', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '가격 동결 활성화!',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'AI 입찰가 20% 감소',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.ac_unit, color: Colors.white),
                      ],
                    ),
                  ),

                const Text(
                  '입찰 금액을 입력하세요',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  onChanged: (_) => _updateBidChance(),
                  decoration: InputDecoration(
                    labelText: '입찰 금액',
                    hintText: '예: ${widget.asset.minPrice}',
                    prefixIcon: const Icon(Icons.attach_money, size: 32, color: Colors.black54),
                    suffixText: '원',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    labelStyle: const TextStyle(color: Colors.black54),
                    hintStyle: const TextStyle(color: Colors.black45),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '입찰 금액을 입력하세요';
                    final n = int.tryParse(v.replaceAll(',', ''));
                    if (n == null || n <= 0) return '유효한 금액을 입력하세요';
                    if (n < widget.asset.minPrice * 0.8) {
                      return '최저가의 80% 이상만 입찰 가능합니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                if (_bidChance.isNotEmpty)
                  LiquidGlass(
                    borderRadius: 12,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.psychology, color: _getBidChanceColor()),
                        const SizedBox(width: 8),
                        const Text(
                          'AI 분석 낙찰 확률: ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Text(
                          _bidChance,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getBidChanceColor(),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // 빠른 입찰 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('빠른 입찰', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    TextButton.icon(
                      onPressed: _updateRecommendation,
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: const Text('AI 추천'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickBidButton(
                      label: '최저가',
                      onPressed: () {
                        _ctrl.text = widget.asset.minPrice.toString();
                        _updateBidChance();
                      },
                    ),
                    _QuickBidButton(
                      label: '+5%',
                      onPressed: () {
                        final amount = (widget.asset.minPrice * 1.05).round();
                        _ctrl.text = amount.toString();
                        _updateBidChance();
                      },
                    ),
                    _QuickBidButton(
                      label: '+10%',
                      onPressed: () {
                        final amount = (widget.asset.minPrice * 1.10).round();
                        _ctrl.text = amount.toString();
                        _updateBidChance();
                      },
                    ),
                    _QuickBidButton(
                      label: '+15%',
                      onPressed: () {
                        final amount = (widget.asset.minPrice * 1.15).round();
                        _ctrl.text = amount.toString();
                        _updateBidChance();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 입찰하기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton.icon(
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.gavel, size: 28),
                    label: Text(
                      _isSubmitting ? '입찰 처리 중...' : '입찰하기',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _isTimerActive && !_isSubmitting
                        ? () async {
                            if (!_formKey.currentState!.validate()) return;

                            setState(() {
                              _isSubmitting = true;
                            });

                            try {
                              final amount = int.parse(_ctrl.text.replaceAll(',', ''));
                              if (balance < amount) {
                                setState(() {
                                  _isSubmitting = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('잔액이 부족합니다. 돈 벌기 미션으로 충전하세요!')),
                                );
                                return;
                              }
                              final notifier = ref.read(bidHistoryProvider.notifier);
                              final result = await notifier.placeBid(
                                widget.asset,
                                amount,
                                luckBoost: _luckBoost,
                                priceFreeze: _priceFreeze,
                              );

                              if (!mounted) return;
                              if (!context.mounted) return;

                              _timer?.cancel();
                              _isTimerActive = false;

                              // 낙찰 시에만 실제 비용 차감
                              if (result['isWin'] as bool) {
                                await ref.read(walletProvider.notifier).spend(amount);
                                await ref.read(assetRepositoryProvider).removeAsset(widget.asset.id);
                                // 낙찰 성공 시 XP 보상 (100 XP)
                                await ref.read(userStatsProvider.notifier).gainXp(100);
                              }

                              if (!mounted) return;
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => ResultPage(
                                    assetTitle: widget.asset.title,
                                    userBid: amount,
                                    winningBid: result['winningBid'] as int,
                                    isWin: result['isWin'] as bool,
                                    totalBidders: result['totalBidders'] as int,
                                    userRank: result['userRank'] as int,
                                    allBids: (result['allBids'] as List).cast(),
                                    aiStrategies: (result['aiStrategies'] as Map<String, int>?),
                                    bidLogs: (result['bidLogs'] as List?)?.cast(),
                                    asset: widget.asset,
                                    hasSecondChance: _hasSecondChance,
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              setState(() {
                                _isSubmitting = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString().replaceAll('Exception: ', '')),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0A84FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                if (!_isTimerActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        '입찰 시간이 종료되었습니다',
                        style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openInventory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 높이 조절 가능하도록 설정
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final inventory = ref.watch(inventoryProvider);
          final items = ShopItem.allItems;
          
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.backpack, size: 24),
                    SizedBox(width: 8),
                    Text('아이템 가방', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                if (inventory.isEmpty || inventory.values.every((count) => count == 0))
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('보유한 아이템이 없습니다. 상점에서 구매하세요!')),
                  )
                else
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6, // 화면 높이의 60%까지만 확장
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final count = inventory[item.type] ?? 0;
                      if (count == 0) return const SizedBox.shrink();
                      
                      return ListTile(
                        leading: Text(item.emoji, style: const TextStyle(fontSize: 32)),
                        title: Text(item.name),
                        subtitle: Text(item.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('x$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () => _useItem(item),
                              child: const Text('사용'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _useItem(ShopItem item) async {
    final success = await ref.read(inventoryProvider.notifier).useItem(item.type);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('아이템이 없습니다')));
      return;
    }
    
    if (!mounted) return;
    Navigator.pop(context); // Close inventory

    switch (item.type) {
      case ItemType.magnifyingGlass:
        // Reveal competitor count (mock: 3-15)
        final competitors = 3 + DateTime.now().millisecond % 12;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('${item.emoji} ${item.name}'),
            content: Text('현재 이 물건을 노리는 경쟁자는 약 $competitors명입니다!'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인'))],
          ),
        );
        break;
        
      case ItemType.timeFreezer:
        if (!_isTimerActive) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이미 종료된 경매입니다')));
          return;
        }
        _timer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.emoji} 10초간 시간이 멈춥니다!')));
        await Future.delayed(const Duration(seconds: 10));
        if (mounted && _countdown > 0) {
          _startTimer();
        }
        break;
        
      case ItemType.luckyCharm:
        setState(() {
          _luckBoost = 0.1; // 10% 확률 증가
        });
        // 화려한 이펙트
        _showLuckyCharmEffect();
        break;
        
      case ItemType.priceFreeze:
        setState(() {
          _priceFreeze = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❄️ 가격 동결! AI 입찰가 20% 감소'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
        break;
        
      case ItemType.secondChance:
        setState(() {
          _hasSecondChance = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔄 재도전권 활성화! 유찰 시 한 번 더 기회'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        break;
    }
  }

  void _showLuckyCharmEffect() {
    // 화려한 다이얼로그 효과
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LuckyCharmDialog(),
    );
    
    // 2초 후 자동으로 닫기
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case '부동산':
        return Icons.home;
      case '차량':
        return Icons.directions_car;
      case '물품':
        return Icons.inventory_2;
      default:
        return Icons.category;
    }
  }

  Color _getBidChanceColor() {
    if (_bidChance.contains('매우 높음')) return Colors.green;
    if (_bidChance.contains('높음')) return Colors.lightGreen;
    if (_bidChance.contains('보통')) return Colors.orange;
    if (_bidChance.contains('낮음')) return Colors.red;
    return Colors.grey;
  }
}

class _QuickBidButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickBidButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Colors.black12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label),
    );
  }
}
