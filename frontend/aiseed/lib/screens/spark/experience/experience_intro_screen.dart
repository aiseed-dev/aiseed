// Copyright (c) 2026 AIseed.dev
// Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
// Dual-licensed with a Commercial License. See LICENSE for details.

import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'experience_task_screen.dart';

/// 体験タスク開始画面
class ExperienceIntroScreen extends StatelessWidget {
  const ExperienceIntroScreen({super.key});

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
              const Text('🎮', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 24),

              Text('体験で発見', style: AppTextStyles.headline),
              const SizedBox(height: 12),

              Text(
                '言葉にしなくても大丈夫\n感じたままに動かしてみて',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 説明カード
              _buildExplanationCard(),

              const SizedBox(height: 32),

              // 体験リスト
              _buildExperienceList(),

              const SizedBox(height: 40),

              // 開始ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _startExperience(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.musical,
                  ),
                  child: const Text('はじめる'),
                ),
              ),

              const SizedBox(height: 16),

              // 戻るボタン
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '戻る',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.musical.withOpacity(0.1),
            AppColors.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.musical.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '正解も不正解もありません',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.musical,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'テストではありません。\n'
            'あなたの反応から、言葉にならない傾向を\n'
            '詩的に表現します。',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceList() {
    final experiences = [
      ('👀', '観察', '何が気になる？'),
      ('🔊', '音と連想', '何を思い浮かべた？'),
      ('🧩', '並べてみる', '好きなように'),
      ('🌱', '続きを選ぶ', '種が飛んで...'),
      ('🥁', 'リズム', '好きなようにタップ'),
      ('🎨', '色を選ぶ', '今日の気分は？'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            '6つの体験',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...experiences.asMap().entries.map((entry) {
          final index = entry.key;
          final exp = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.musical.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(exp.$1, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${exp.$2}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        exp.$3,
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
        }),
      ],
    );
  }

  void _startExperience(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ExperienceTaskScreen(),
      ),
    );
  }
}
