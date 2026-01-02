import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'grow_chat_screen.dart';

/// Grow開始画面 - 栽培・料理サポート
class GrowIntroScreen extends StatelessWidget {
  const GrowIntroScreen({super.key});

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
              const Text('🌱', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),

              Text('Grow', style: AppTextStyles.headline),
              const SizedBox(height: 8),
              Text(
                '栽培・伝統野菜・料理',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.naturalistic,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'AIと一緒に育てて、料理して、学ぶ',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 機能カード
              _buildFeatureCard(
                icon: '🥬',
                title: '栽培アドバイス',
                description: '何を植えたらいい？水やりは？',
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: '📚',
                title: '伝統野菜辞典',
                description: '地域の野菜の歴史と育て方',
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: '🍳',
                title: '料理レシピ',
                description: '採れた野菜をどう料理する？',
              ),

              const SizedBox(height: 40),

              // 開始ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GrowChatScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naturalistic,
                  ),
                  child: const Text('会話を始める'),
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
        border: Border.all(color: AppColors.naturalistic.withOpacity(0.2)),
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
}
