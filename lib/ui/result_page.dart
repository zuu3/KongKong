import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/bid.dart';
import '../models/asset.dart';
import '../models/owned_asset.dart';
import '../ui/bid_page.dart';
import '../notifier/owned_asset_notifier.dart';
import 'widgets/liquid_glass.dart';

class ResultPage extends StatefulWidget {
  final String assetTitle;
  final int userBid;
  final int winningBid;
  final bool isWin;
  final int totalBidders;
  final int userRank;
  final List<Bid> allBids;
  final Map<String, int>? aiStrategies;
  final List<Bid>? bidLogs;
  final Asset? asset; // 재도전을 위해 필요
  final bool hasSecondChance; // 재도전권 보유 여부

  const ResultPage({
    super.key,
    required this.assetTitle,
    required this.userBid,
    required this.winningBid,
    required this.isWin,
    required this.totalBidders,
    required this.userRank,
    required this.allBids,
    this.aiStrategies,
    this.bidLogs,
    this.asset,
    this.hasSecondChance = false,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.decimalPattern();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.isWin
                ? [Colors.green.shade400, Colors.green.shade700]
                : [Colors.red.shade400, Colors.red.shade700],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 애니메이션 아이콘
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isWin ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                        size: 80,
                        color: widget.isWin ? Colors.amber : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 결과 텍스트
                  Text(
                    widget.isWin ? '🎉 대박났어요! 🎉' : '😭 돈 아까워...',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isWin ? '낙찰 성공! 🤑' : '유찰... 💸',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 요약 정보 카드
                  LiquidGlass(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 20,
                    child: Column(
                      children: [
                        Text(
                          widget.assetTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Divider(height: 32, color: Colors.white24),
                        _buildInfoRow(
                          '전체 입찰자',
                          '${widget.totalBidders}명',
                          Icons.people,
                          Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          '내 순위',
                          '${widget.userRank}위',
                          Icons.military_tech,
                          widget.isWin ? Colors.amber : Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          '낙찰가',
                          '${f.format(widget.winningBid)}원',
                          Icons.gavel,
                          Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          '내 입찰가',
                          '${f.format(widget.userBid)}원',
                          Icons.person,
                          widget.isWin ? Colors.green : Colors.red,
                        ),
                        if (!widget.isWin) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb, color: Colors.orange.shade200),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '아깝다! ${f.format(widget.winningBid - widget.userBid)}원만 더 썼으면 내거였는데... 😤',
                                    style: TextStyle(
                                      color: Colors.orange.shade100,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 전체 입찰 현황
                  LiquidGlass(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.format_list_numbered, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              '전체 입찰 현황',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...widget.allBids.asMap().entries.map((entry) {
                          final rank = entry.key + 1;
                          final bid = entry.value;
                          final isWinner = rank == 1;
                          final isUser = bid.isUser;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Colors.blue.withValues(alpha: 0.1)
                                  : isWinner
                                  ? Colors.amber.withValues(alpha: 0.1)
                                  : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isUser
                                    ? Colors.blue
                                    : isWinner
                                    ? Colors.amber
                                    : Colors.transparent,
                                width: isUser || isWinner ? 2 : 0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isWinner
                                        ? Colors.amber
                                        : Colors.white.withValues(alpha: 0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$rank',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isWinner ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            bid.bidderName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isUser ? Colors.blue : Colors.white,
                                            ),
                                          ),
                                          if (isUser) ...[
                                            const SizedBox(width: 4),
                                            const Icon(Icons.person, size: 16, color: Colors.blue),
                                          ],
                                          if (isWinner) ...[
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.emoji_events,
                                              size: 16,
                                              color: Colors.amber,
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        DateFormat('HH:mm:ss').format(bid.bidTime),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${f.format(bid.bidAmount)}원',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isWinner ? Colors.greenAccent : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  if (widget.aiStrategies != null) ...[
                    const SizedBox(height: 16),
                    LiquidGlass(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.groups, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                '경쟁자 전략 분포',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.aiStrategies!.entries.map((e) {
                              return Chip(
                                label: Text('${e.key}: ${e.value}명'),
                                backgroundColor: Colors.white.withValues(alpha: 0.7),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (widget.bidLogs != null) ...[
                    const SizedBox(height: 16),
                    LiquidGlass(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.history, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                '실시간 입찰 로그',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...widget.bidLogs!.map((bid) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: bid.isUser ? Colors.blue : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${DateFormat('HH:mm:ss').format(bid.bidTime)} - ${bid.bidderName}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${f.format(bid.bidAmount)}원',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // 버튼들
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/assets'),
                      icon: const Icon(Icons.refresh),
                      label: const Text('다음 공매 도전하기', style: TextStyle(fontSize: 18)),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: widget.isWin ? Colors.green : Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 재도전 버튼 (유찰 + 재도전권 보유 시)
                  if (!widget.isWin && widget.hasSecondChance && widget.asset != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => BidPage(asset: widget.asset!)),
                          );
                        },
                        icon: const Icon(Icons.replay),
                        label: const Text('재도전권 사용하기', style: TextStyle(fontSize: 18)),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed('/history'),
                            icon: const Icon(Icons.receipt_long),
                            label: const Text('입찰 내역'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed('/stats'),
                            icon: const Icon(Icons.bar_chart),
                            label: const Text('통계 보기'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
