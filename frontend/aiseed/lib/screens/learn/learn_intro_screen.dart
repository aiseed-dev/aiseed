import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'learn_chat_screen.dart';

/// Learn開始画面 - プログラミング・BYOA開発スクール
class LearnIntroScreen extends StatelessWidget {
  const LearnIntroScreen({super.key});

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
              const Text('💻', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),

              Text('Learn', style: AppTextStyles.headline),
              const SizedBox(height: 8),
              Text(
                'プログラミング・BYOA開発',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.logical,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'AIと一緒にプログラミングを学ぶ\n自分のエージェントを作る',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // コース一覧
              _buildCourseCard(
                icon: '🐍',
                title: 'Python基礎',
                description: 'プログラミングの第一歩',
                level: '初心者',
              ),
              const SizedBox(height: 12),
              _buildCourseCard(
                icon: '📱',
                title: 'Flutterアプリ開発',
                description: 'スマホアプリを作る',
                level: '中級者',
              ),
              const SizedBox(height: 12),
              _buildCourseCard(
                icon: '🤖',
                title: 'BYOA開発',
                description: '自分のAIエージェントを作る',
                level: '応用',
              ),
              const SizedBox(height: 12),
              _buildCourseCard(
                icon: '🌐',
                title: 'Web制作',
                description: 'AIと一緒にサイトを作る',
                level: '全レベル',
              ),

              const SizedBox(height: 40),

              // 開始ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LearnChatScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.logical,
                  ),
                  child: const Text('学習を始める'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required String icon,
    required String title,
    required String description,
    required String level,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.logical.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.logical.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        level,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.logical,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
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
          Icon(Icons.chevron_right, color: AppColors.logical),
        ],
      ),
    );
  }
}
