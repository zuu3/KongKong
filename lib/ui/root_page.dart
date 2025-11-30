import 'package:flutter/material.dart';
import 'home_page.dart';
import 'asset_list_page.dart';
import 'history_page.dart';
import 'stats_page.dart';
import 'shop_page.dart';
import 'widgets/liquid_glass.dart';

/// 하단 탭을 가진 루트 페이지
class RootPage extends StatefulWidget {
  final int initialIndex;
  const RootPage({super.key, this.initialIndex = 0});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late int _index;
  final _pages = const [
    HomePage(),
    AssetListPage(),
    ShopPage(),
    HistoryPage(),
    StatsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: LiquidGlass(
          padding: EdgeInsets.zero,
          borderRadius: 24,
          child: NavigationBar(
            height: 70,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: Colors.white.withValues(alpha: 0.18),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '홈'),
              NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: '자산'),
              NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: '상점'),
              NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: '내역'),
              NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: '통계'),
            ],
          ),
        ),
      ),
    );
  }
}
