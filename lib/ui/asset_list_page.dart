import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../notifier/asset_notifier.dart';
import '../notifier/wallet_notifier.dart';
import '../notifier/user_stats_notifier.dart';
import 'widgets/asset_card.dart';
import '../data/wallet_repository.dart';
import 'widgets/liquid_glass.dart';

class AssetListPage extends ConsumerStatefulWidget {
  const AssetListPage({super.key});

  @override
  ConsumerState<AssetListPage> createState() => _AssetListPageState();
}

class _AssetListPageState extends ConsumerState<AssetListPage> {
  final _rand = Random();
  late Map<String, dynamic> _mission;
  final _answerCtrl = TextEditingController();
  late int _quizAnswer;
  late int _quizA;
  late int _quizB;

  @override
  void initState() {
    super.initState();
    _setNextMission();
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  void _setNextMission() {
    final missions = WalletRepository.missions;
    _mission = missions[_rand.nextInt(missions.length)];
    _generateQuiz();
  }

  void _generateQuiz() {
    _quizA = 10 + _rand.nextInt(90);
    _quizB = 5 + _rand.nextInt(45);
    _quizAnswer = _quizA + _quizB;
    _answerCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(assetListProvider);
    final filter = ref.watch(assetFilterProvider);
    final balanceState = ref.watch(walletProvider);
    final userStats = ref.watch(userStatsProvider);
    final balance = balanceState.value ?? 0;
    final fMoney = NumberFormat.compactCurrency(locale: 'ko_KR', symbol: '₩');
    final missionTitle = _mission['title'] as String;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('공매 자산 목록', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            initialValue: filter,
            onSelected: (v) => ref.read(assetFilterProvider.notifier).state = v,
            itemBuilder: (context) => const [
              PopupMenuItem(value: '전체', child: Text('전체')),
              PopupMenuItem(value: '부동산', child: Text('부동산')),
              PopupMenuItem(value: '차량', child: Text('차량')),
              PopupMenuItem(value: '물품', child: Text('물품')),
            ],
            icon: const Icon(Icons.filter_list, color: Colors.black87),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: LiquidGlass(
                borderRadius: 16,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '내 잔액: ${fMoney.format(balance)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                        SizedBox(
                          height: 44,
                          child: FilledButton.tonalIcon(
                            onPressed: balanceState is AsyncLoading
                                ? null
                                : () => _openMissionSheet(context, fMoney),
                            icon: balanceState is AsyncLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.lightbulb_outline),
                            label: Text(
                              missionTitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0066CC), Color(0xFF00B4D8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Lv.${userStats.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: userStats.currentXp / userStats.requiredXp,
                              backgroundColor: Colors.black.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0066CC)),
                              minHeight: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${userStats.currentXp}/${userStats.requiredXp}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: assets.when(
                data: (list) => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final a = list[i];
                    return AssetCard(
                      asset: a,
                      onTap: () => Navigator.of(context).pushNamed('/bid', arguments: a),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('에러: $e', style: const TextStyle(color: Colors.black87)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMissionSheet(BuildContext context, NumberFormat fMoney) {
    final min = _mission['min'] as int;
    final max = _mission['max'] as int;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _mission['title'] as String,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                '정답을 맞추면 ${fMoney.format(min)} ~ ${fMoney.format(max)} 랜덤 보상!',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Text('퀴즈: $_quizA + $_quizB = ?', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _answerCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '정답 입력',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final answer = int.tryParse(_answerCtrl.text.trim());
                        if (answer == _quizAnswer) {
                          final reward = min + _rand.nextInt(max - min + 1);
                          await ref.read(walletProvider.notifier).earnExact(reward);
                          final leveledUp = await ref.read(userStatsProvider.notifier).gainXp(50);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('정답! +${fMoney.format(reward)} 적립 (+50 XP)')),
                          );
                          if (leveledUp) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('🎉 레벨 업!'),
                                content: Text('축하합니다! Lv.${ref.read(userStatsProvider).level}에 도달했습니다!'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('확인'),
                                  ),
                                ],
                              ),
                            );
                          }
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('앗, 오답입니다. 다시 도전!')),
                          );
                        }
                        if (mounted) Navigator.pop(context);
                        setState(_setNextMission);
                      },
                      child: const Text('정답 제출'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(_generateQuiz);
                    },
                  icon: const Icon(Icons.refresh),
                  tooltip: '문제 새로고침',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            LiquidGlass(
              borderRadius: 12,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('행운 뽑기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('70% 1~5억, 20% 5천만~1억, 10% -2천만~-5천만', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () async {
                        final delta = await ref.read(walletProvider.notifier).playLuckyDraw();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              delta >= 0
                                  ? '행운! +${fMoney.format(delta)} 적립'
                                  : '불운... ${fMoney.format(delta)}',
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.casino),
                      label: const Text('행운 뽑기 실행'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
  }
}
