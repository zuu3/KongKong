import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'ui/bid_page.dart';
import 'ui/result_page.dart';
import 'models/asset.dart';
import 'ui/root_page.dart';
import 'ui/portfolio_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: GongmaeApp()));
}

class GongmaeApp extends StatelessWidget {
  const GongmaeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '공매의 정석',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 웹에서는 시스템 폰트 사용, 모바일에서는 Google Fonts 사용
        textTheme: kIsWeb
            ? ThemeData.light().textTheme.apply(
                fontFamily:
                    '-apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans KR", sans-serif',
              )
            : GoogleFonts.notoSansKrTextTheme(),
        fontFamily: kIsWeb ? null : GoogleFonts.notoSansKr().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066CC),
          secondary: const Color(0xFF00B4D8),
          tertiary: const Color(0xFF90E0EF),
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      routes: {
        '/': (context) => const RootPage(),
        '/assets': (context) => const RootPage(initialIndex: 1),
        '/history': (context) => const RootPage(initialIndex: 2),
        '/stats': (context) => const RootPage(initialIndex: 3),
        '/portfolio': (context) => const PortfolioPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/bid') {
          final asset = settings.arguments as Asset;
          return MaterialPageRoute(builder: (_) => BidPage(asset: asset));
        }
        if (settings.name == '/result') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ResultPage(
              assetTitle: args['assetTitle'] as String,
              userBid: args['userBid'] as int,
              winningBid: args['winningBid'] as int,
              isWin: args['isWin'] as bool,
              totalBidders: args['totalBidders'] as int,
              userRank: args['userRank'] as int,
              allBids: args['allBids'],
            ),
          );
        }
        return null;
      },
    );
  }
}
