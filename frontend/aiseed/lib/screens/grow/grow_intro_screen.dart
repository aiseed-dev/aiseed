import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'grow_chat_screen.dart';
import 'shipment_screen.dart';

/// Grow開始画面 - 栽培・料理サポート + 出荷情報
class GrowIntroScreen extends StatelessWidget {
  const GrowIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grow'),
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
                    const Text('🌱', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text('Grow', style: AppTextStyles.headline),
                    const SizedBox(height: 8),
                    Text(
                      '育てる・届ける',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.naturalistic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 出荷情報（メイン機能）
              _buildMainFeatureCard(
                context,
                icon: '📦',
                title: '出荷情報を投稿',
                description: '今日の出荷をお知らせ\n登録者に自動で通知が届きます',
                buttonText: '投稿する',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ShipmentScreen()),
                ),
              ),

              const SizedBox(height: 24),

              // 機能カード
              Text(
                'AIサポート',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildFeatureCard(
                context,
                icon: '🥬',
                title: '栽培アドバイス',
                description: '何を植えたらいい？水やりは？',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GrowChatScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                context,
                icon: '📚',
                title: '伝統野菜辞典',
                description: '地域の野菜の歴史と育て方',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GrowChatScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                context,
                icon: '🍳',
                title: '料理レシピ',
                description: '採れた野菜をどう料理する？',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GrowChatScreen()),
                ),
              ),

              const SizedBox(height: 32),

              // 出荷情報の活用例
              Container(
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
                        const Text('💡', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          '出荷情報の活用',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildUseCaseItem(
                      '簡単投稿',
                      '「今日10時に道の駅にトマト100円」と入力するだけ',
                    ),
                    _buildUseCaseItem(
                      '自動通知',
                      '登録者にメールやプッシュ通知が届く',
                    ),
                    _buildUseCaseItem(
                      'QRコードで登録',
                      '直売所やPOPにQRを貼って購読者を増やす',
                    ),
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
            AppColors.naturalistic.withOpacity(0.15),
            AppColors.naturalistic.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.naturalistic.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
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
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.naturalistic,
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

  Widget _buildFeatureCard(
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
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildUseCaseItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20, color: AppColors.naturalistic),
          const SizedBox(width: 8),
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
