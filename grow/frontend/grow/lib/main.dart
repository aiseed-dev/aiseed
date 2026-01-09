import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'shared/theme/theme.dart';
import 'features/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ステータスバーの色を設定
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const GrowApp());
}

/// Grow - 自然派向け栽培記録アプリ
class GrowApp extends StatelessWidget {
  const GrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grow',
      debugShowCheckedModeBanner: false,

      // テーマ設定
      theme: GrowTheme.light,
      darkTheme: GrowTheme.dark,
      themeMode: ThemeMode.system,

      // ホーム画面
      home: const HomeScreen(),
    );
  }
}
