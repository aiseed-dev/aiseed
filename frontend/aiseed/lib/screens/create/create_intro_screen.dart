import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'create_chat_screen.dart';
import 'web_builder_screen.dart';
import 'cloudflare_guide_screen.dart';

/// Create開始画面 - 農家・食品店向けWeb制作
class CreateIntroScreen extends StatelessWidget {
  const CreateIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Center(
                child: Column(
                  children: [
                    const Text('🎨', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text('Create', style: AppTextStyles.headline),
                    const SizedBox(height: 8),
                    Text(
                      'AIでWebサイトを作る',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.spatial,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // メイン機能: 農家・食品店向け
              _buildMainFeatureCard(
                context,
                icon: '🌾',
                title: '農家・食品店のWebサイト',
                description: 'QRコードからアクセスできる\nシンプルで効果的なサイト',
                features: [
                  '商品や直売所からQRで誘導',
                  'スマホ最適化デザイン',
                  'Cloudflareで無料公開',
                ],
                buttonText: 'サイトを作る',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WebBuilderScreen()),
                ),
              ),

              const SizedBox(height: 16),

              // デプロイガイド
              _buildSecondaryCard(
                context,
                icon: '☁️',
                title: 'Cloudflareで公開',
                description: '5分で無料公開',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CloudflareGuideScreen()),
                ),
              ),

              const SizedBox(height: 16),

              // 自由に相談
              _buildSecondaryCard(
                context,
                icon: '💬',
                title: 'AIに相談する',
                description: 'なんでも聞いて',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateChatScreen()),
                ),
              ),

              const SizedBox(height: 32),

              // 作れるサイト例
              Text(
                'こんなサイトが作れます',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildExampleChip('🥬 野菜農家'),
                  _buildExampleChip('🍞 パン屋さん'),
                  _buildExampleChip('🍰 お菓子屋'),
                  _buildExampleChip('🏪 直売所'),
                  _buildExampleChip('🎪 マルシェ出店'),
                  _buildExampleChip('🍎 果樹園'),
                ],
              ),

              const SizedBox(height: 32),

              // QRコード活用例
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.naturalistic.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.naturalistic.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📱', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          'QRコード活用アイデア',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildQRUseCase('野菜の袋に貼る', '生産者紹介・レシピへ'),
                    _buildQRUseCase('店頭POPに表示', 'お店の詳細情報へ'),
                    _buildQRUseCase('名刺に印刷', 'プロフィールページへ'),
                    _buildQRUseCase('マルシェのテントに', '次回出店情報へ'),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainFeatureCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required List<String> features,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.spatial.withOpacity(0.1),
            AppColors.naturalistic.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.spatial.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.spatial, size: 20),
                const SizedBox(width: 8),
                Text(f, style: AppTextStyles.bodyMedium),
              ],
            ),
          )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.spatial,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.spatial.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: AppColors.spatial),
      ),
    );
  }

  Widget _buildQRUseCase(String action, String result) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.qr_code, size: 20, color: AppColors.naturalistic),
          const SizedBox(width: 8),
          Text(action, style: AppTextStyles.bodyMedium),
          const Text(' → ', style: TextStyle(color: Colors.grey)),
          Text(
            result,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.naturalistic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
