import 'package:flutter/material.dart';
import '../../models/asset.dart';
import 'package:intl/intl.dart';
import 'liquid_glass.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onTap;
  const AssetCard({super.key, required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.decimalPattern();
    return LiquidGlass(
      padding: EdgeInsets.zero,
      borderRadius: 18,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 아이콘
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(asset.category),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _getCategoryColor(asset.category).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(_getIconForCategory(asset.category), color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                // 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(asset.category),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          asset.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        asset.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            '최저 ${f.format(asset.minPrice)}원',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (asset.deadline != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: _getDeadlineColor(asset.deadline!),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getDeadlineText(asset.deadline!),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getDeadlineColor(asset.deadline!),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // 화살표
                Icon(Icons.arrow_forward_ios, color: _getCategoryColor(asset.category), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case '부동산':
        return Colors.blue;
      case '차량':
        return Colors.green;
      case '물품':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getDeadlineText(DateTime deadline) {
    final now = DateTime.now();
    final diff = deadline.difference(now);
    
    if (diff.isNegative) return '마감';
    if (diff.inHours >= 24) return '${diff.inDays}일 남음';
    if (diff.inHours >= 1) return '${diff.inHours}시간 남음';
    return '${diff.inMinutes}분 남음';
  }

  Color _getDeadlineColor(DateTime deadline) {
    final now = DateTime.now();
    final diff = deadline.difference(now);
    
    if (diff.isNegative) return Colors.grey;
    if (diff.inHours < 1) return Colors.red;
    if (diff.inHours < 3) return Colors.orange;
    return Colors.green;
  }
}
