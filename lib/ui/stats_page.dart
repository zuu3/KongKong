import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../notifier/bid_notifier.dart';
import 'widgets/liquid_glass.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(bidHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('나의 통계', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: history.when(
          data: (bids) {
            if (bids.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 100, color: Colors.black26),
                    SizedBox(height: 16),
                    Text('아직 입찰 내역이 없습니다', style: TextStyle(fontSize: 18, color: Colors.black45)),
                  ],
                ),
              );
            }

            final totalBids = bids.length;
            final wonBids = bids.where((b) => b.result == '낙찰').length;
            final lostBids = totalBids - wonBids;
            final winRate = (wonBids / totalBids * 100);
            final avgBid = bids.map((b) => b.bidAmount).reduce((a, b) => a + b) / totalBids;
            final maxBid = bids.map((b) => b.bidAmount).reduce((a, b) => a > b ? a : b);
            final minBid = bids.map((b) => b.bidAmount).reduce((a, b) => a < b ? a : b);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(context, totalBids, wonBids, lostBids, winRate),
                  const SizedBox(height: 24),

                  _buildWinRateChart(context, wonBids, lostBids),
                  const SizedBox(height: 24),

                  _buildBidAmountStats(context, avgBid, maxBid, minBid),
                  const SizedBox(height: 24),

                  _buildAchievements(context, totalBids, wonBids, winRate),
                  const SizedBox(height: 24),

                  if (bids.length >= 3) _buildRecentTrend(context, bids),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('에러: $e', style: const TextStyle(color: Colors.black87))),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, int total, int won, int lost, double winRate) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.format_list_numbered,
            title: '총 입찰',
            value: '$total건',
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_events,
            title: '낙찰',
            value: '$won건',
            color: Colors.greenAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.percent,
            title: '승률',
            value: '${winRate.toStringAsFixed(1)}%',
            color: Colors.orangeAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildWinRateChart(BuildContext context, int won, int lost) {
    return LiquidGlass(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('낙찰 vs 유찰', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: won.toDouble(),
                    title: '낙찰\n$won건',
                    color: Colors.greenAccent,
                    radius: 80,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: lost.toDouble(),
                    title: '유찰\n$lost건',
                    color: Colors.redAccent,
                    radius: 80,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidAmountStats(BuildContext context, double avg, int max, int min) {
    final f = NumberFormat.compact(locale: 'ko_KR');
    return LiquidGlass(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('입찰 금액 분석', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          _buildStatRow('평균 입찰가', '${f.format(avg)}원', Icons.analytics),
          const Divider(color: Colors.white24),
          _buildStatRow('최고 입찰가', '${f.format(max)}원', Icons.arrow_upward),
          const Divider(color: Colors.white24),
          _buildStatRow('최저 입찰가', '${f.format(min)}원', Icons.arrow_downward),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black45),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54))),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext context, int total, int won, double winRate) {
    final achievements = <Map<String, dynamic>>[];

    if (total >= 1) {
      achievements.add({
        'icon': Icons.star,
        'title': '입문자',
        'desc': '첫 입찰 완료',
        'color': Colors.amber,
      });
    }
    if (total >= 5) {
      achievements.add({
        'icon': Icons.military_tech,
        'title': '초보 입찰자',
        'desc': '5회 입찰 달성',
        'color': Colors.blue,
      });
    }
    if (total >= 10) {
      achievements.add({
        'icon': Icons.workspace_premium,
        'title': '베테랑',
        'desc': '10회 입찰 달성',
        'color': Colors.purple,
      });
    }
    if (won >= 1) {
      achievements.add({
        'icon': Icons.emoji_events,
        'title': '첫 낙찰',
        'desc': '첫 낙찰 성공',
        'color': Colors.green,
      });
    }
    if (winRate >= 50 && total >= 3) {
      achievements.add({
        'icon': Icons.psychology,
        'title': '고수',
        'desc': '승률 50% 달성',
        'color': Colors.orange,
      });
    }
    if (winRate >= 70 && total >= 5) {
      achievements.add({
        'icon': Icons.diamond,
        'title': '마스터',
        'desc': '승률 70% 달성',
        'color': Colors.red,
      });
    }

    if (achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🏆 획득한 업적', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: achievements.map((achievement) {
            return Container(
              width: (MediaQuery.of(context).size.width - 56) / 2,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [achievement['color'], achievement['color'].withValues(alpha: 0.6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(achievement['icon'], size: 40, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    achievement['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement['desc'],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentTrend(BuildContext context, List bids) {
    final recent = bids.take(10).toList().reversed.toList();
    return LiquidGlass(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('최근 입찰 추이', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt() + 1}', style: const TextStyle(fontSize: 10, color: Colors.black87));
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true, border: const Border.symmetric(horizontal: BorderSide(color: Colors.white24))),
                lineBarsData: [
                  LineChartBarData(
                    spots: recent
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.result == '낙찰' ? 1 : 0))
                        .toList(),
                    isCurved: true,
                    color: Colors.greenAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
