import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'part3_chat_screen.dart';

/// Part3開始画面 - 対話による強み発見
class Part3IntroScreen extends StatelessWidget {
  final Map<String, double> previousScores;

  const Part3IntroScreen({super.key, required this.previousScores});

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
              const Text('💬', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),

              Text('Part 3: 対話で発見', style: AppTextStyles.headline),
              const SizedBox(height: 12),

              Text(
                '自然な会話の中から\nあなたの強みを見つけます',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 説明カード
              _buildExplanationCard(),

              const SizedBox(height: 24),

              // 特徴
              _buildFeatureList(),

              const SizedBox(height: 40),

              // 開始ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _startPart3(context),
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

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'テストではありません',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            'リラックスして、普段通りにお話しください。\n正解も不正解もありません。\nあなたらしい対話から、強みを発見します。',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      ('🎯', '自然な会話', 'テストの緊張感なし'),
      ('✨', '強みを発見', '能力と「らしさ」を見つける'),
      ('🤖', 'AI対話', 'パーソナライズされた会話'),
    ];

    return Column(
      children: features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(f.$1, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.$2,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          f.$3,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  void _startPart3(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Part3ChatScreen(previousScores: previousScores),
      ),
    );
  }
}
