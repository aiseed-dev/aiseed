import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'create_chat_screen.dart';

/// Create開始画面 - AI版WordPress（Web制作）
class CreateIntroScreen extends StatelessWidget {
  const CreateIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ヘッダー
              const Text('🎨', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),

              Text('Create', style: AppTextStyles.headline),
              const SizedBox(height: 8),
              Text(
                'AI版WordPress',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.spatial,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'AIと会話するだけで\nWebサイトが作れる',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 特徴
              _buildFeatureCard(
                icon: '💬',
                title: '会話で作成',
                description: 'コード不要、AIに話すだけ',
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: '🎨',
                title: 'デザイン自動生成',
                description: 'モダンで美しいサイト',
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: '🚀',
                title: 'ワンクリック公開',
                description: 'すぐにインターネットへ',
              ),

              const SizedBox(height: 40),

              // 作れるサイト例
              _buildExamplesSection(),

              const SizedBox(height: 40),

              // 開始ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateChatScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.spatial,
                  ),
                  child: const Text('サイトを作る'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.spatial.withOpacity(0.2)),
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
        ],
      ),
    );
  }

  Widget _buildExamplesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('作れるサイトの例', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildExampleChip('ポートフォリオ'),
            _buildExampleChip('ブログ'),
            _buildExampleChip('お店のHP'),
            _buildExampleChip('イベントページ'),
            _buildExampleChip('ランディングページ'),
          ],
        ),
      ],
    );
  }

  Widget _buildExampleChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.spatial.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: AppColors.spatial),
      ),
    );
  }
}
