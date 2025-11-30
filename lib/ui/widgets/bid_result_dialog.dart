import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BidResultDialog extends StatelessWidget {
  final bool isWin;
  final int userBid;
  final int targetPrice;
  final String assetTitle;
  const BidResultDialog({
    super.key,
    required this.isWin,
    required this.userBid,
    required this.targetPrice,
    required this.assetTitle,
  });

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.decimalPattern();
    return AlertDialog(
      title: Text(isWin ? '🎉 낙찰!' : '😢 유찰'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('내 입찰가: ${f.format(userBid)}원'),
          Text('기준가(시뮬레이션): ${f.format(targetPrice)}원'),
          const SizedBox(height: 8),
          Text(isWin ? '축하합니다! 기준가 ±2%에 들어왔어요.' : '다음 라운드에서 다시 도전해보세요.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(
              '/result',
              arguments: {
                'isWin': isWin,
                'userBid': userBid,
                'targetPrice': targetPrice,
                'assetTitle': assetTitle,
              },
            );
          },
          child: const Text('결과 페이지'),
        ),
        FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인')),
      ],
    );
  }
}
