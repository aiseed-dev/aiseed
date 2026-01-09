import 'package:flutter/material.dart';
import '../../shared/theme/colors.dart';
import 'widgets/greeting_section.dart';
import 'widgets/plants_section.dart';
import 'widgets/recent_observations_section.dart';

/// ホーム画面
///
/// 責務: アプリのメイン画面、植物一覧と最近の観察を表示
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // TODO: メニュー表示
          },
        ),
        title: Row(
          children: [
            const Icon(Icons.eco, color: GrowColors.lifeGreen, size: 28),
            const SizedBox(width: 8),
            Text(
              'Grow',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: GrowColors.lifeGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 通知
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: プロフィール
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              GreetingSection(),
              SizedBox(height: 24),
              PlantsSection(),
              SizedBox(height: 24),
              RecentObservationsSection(),
            ],
          ),
        ),
      ),
      // 撮影ボタン（FAB）
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: カメラ起動
          _showCaptureOptions(context);
        },
        child: const Icon(Icons.camera_alt, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // ボトムナビゲーション
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco_outlined),
            activeIcon: Icon(Icons.eco),
            label: '植物',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(width: 24), // FAB用のスペース
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: '統計',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }

  /// 撮影オプションを表示
  void _showCaptureOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: GrowColors.lightSoil,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '観察を記録',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCaptureOption(
                  context,
                  icon: Icons.camera_alt,
                  label: '写真を撮る',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: カメラ起動
                  },
                ),
                _buildCaptureOption(
                  context,
                  icon: Icons.photo_library,
                  label: '写真を選ぶ',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: ギャラリー起動
                  },
                ),
                _buildCaptureOption(
                  context,
                  icon: Icons.edit_note,
                  label: 'メモのみ',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: メモ入力画面
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: GrowColors.paleGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: GrowColors.deepGreen,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
