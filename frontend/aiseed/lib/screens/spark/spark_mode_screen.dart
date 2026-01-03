// Copyright (c) 2026 AIseed.dev
// Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
// Dual-licensed with a Commercial License. See LICENSE for details.

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'part3_intro_screen.dart';
import 'experience/experience_intro_screen.dart';

/// Sparkモード選択画面 - おしゃべり or 体験
class SparkModeScreen extends StatelessWidget {
  const SparkModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spark'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ヘッダー
              const Text('✨', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),

              Text('自分を知る', style: AppTextStyles.headline),
              const SizedBox(height: 8),

              Text(
                '2つのモードから選んでね',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 40),

              // モード選択カード
              _buildModeCard(
                context,
                icon: '💬',
                title: 'おしゃべりで発見',
                description: '自然な会話の中から\nあなたの強みと「らしさ」を見つけます',
                features: ['リラックスした対話', '質問に答えるだけ', 'AIがやさしく聞く'],
                color: AppColors.interpersonal,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const Part3IntroScreen(previousScores: {}),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _buildModeCard(
                context,
                icon: '🎮',
                title: '体験で発見',
                subtitle: 'NEW',
                description: '6つの簡単な体験から\n言葉にならない傾向を発見します',
                features: ['正解も不正解もなし', '直感で答えるだけ', '3分で完了'],
                color: AppColors.musical,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ExperienceIntroScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 補足
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '両方やってみると、より深く自分を知れるよ',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String icon,
    required String title,
    String? subtitle,
    required String description,
    required List<String> features,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                subtitle,
                                style: AppTextStyles.label.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: color, size: 28),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            // 特徴リスト
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: features.map((f) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    f,
                    style: AppTextStyles.label.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
