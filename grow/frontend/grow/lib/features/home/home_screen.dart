import 'package:flutter/material.dart';
import '../../shared/theme/colors.dart';
import '../observation/observation_recording_screen.dart';
import '../hp_builder/hp_builder_screen.dart';
import '../settings/settings_screen.dart';
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
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
                    _navigateToObservationRecording(context);
                  },
                ),
                _buildCaptureOption(
                  context,
                  icon: Icons.photo_library,
                  label: '写真を選ぶ',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToObservationRecording(context);
                  },
                ),
                _buildCaptureOption(
                  context,
                  icon: Icons.edit_note,
                  label: 'メモのみ',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToObservationRecording(context);
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

  void _navigateToObservationRecording(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ObservationRecordingScreen(),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: GrowColors.deepGreen,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'Grow',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '栽培記録アプリ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('ホーム'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'ツール',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: GrowColors.darkSoil,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.web),
            title: const Text('ホームページ作成'),
            subtitle: const Text('音声でHPを作成'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HpBuilderScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.psychology),
            title: const Text('AIリサーチガイド'),
            subtitle: const Text('栽培の質問を作成'),
            onTap: () {
              Navigator.pop(context);
              // TODO: AIリサーチガイド画面へ
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('設定'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
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
