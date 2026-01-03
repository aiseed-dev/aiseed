// Copyright (c) 2026 AIseed.dev
// Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
// Dual-licensed with a Commercial License. See LICENSE for details.

import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// 体験タスク結果画面
class ExperienceResultScreen extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final List<Map<String, dynamic>> suggestions;

  const ExperienceResultScreen({
    super.key,
    required this.feedback,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    final summary = feedback['summary'] ?? '';
    final tendencies = List<String>.from(feedback['tendencies'] ?? []);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ヘッダー
              const Text('✨', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 24),

              Text(
                'お疲れさまでした！',
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 8),

              Text(
                'あなたのこと、少し見えてきました',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 40),

              // サマリーカード
              _buildSummaryCard(summary),

              const SizedBox(height: 24),

              // 傾向タグ
              if (tendencies.isNotEmpty) ...[
                _buildTendencies(tendencies),
                const SizedBox(height: 32),
              ],

              // 提案
              if (suggestions.isNotEmpty) ...[
                _buildSuggestions(context, suggestions),
                const SizedBox(height: 32),
              ],

              // 注意書き
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.divider,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('💭', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'これは可能性です。\n正解も不正解もありません。',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ホームに戻るボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('ホームに戻る'),
                ),
              ),

              const SizedBox(height: 16),

              // もう一度やるボタン
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // TODO: 再度体験を開始する処理
                },
                child: Text(
                  'もう一度やってみる',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.musical,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.musical.withOpacity(0.15),
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
          Text(
            summary,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTendencies(List<String> tendencies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'あなたの傾向',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: tendencies.where((t) => t.isNotEmpty).map((tendency) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.musical.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.musical.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                tendency,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.musical,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestions(
    BuildContext context,
    List<Map<String, dynamic>> suggestions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            '次はこれをやってみる？',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...suggestions.map((suggestion) {
          final service = suggestion['service'] ?? '';
          final title = suggestion['title'] ?? '';
          final description = suggestion['description'] ?? '';

          Color color;
          String icon;
          switch (service) {
            case 'grow':
              color = AppColors.naturalistic;
              icon = '🌱';
              break;
            case 'create':
              color = AppColors.spatial;
              icon = '🎨';
              break;
            default:
              color = AppColors.primary;
              icon = '✨';
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                  Icon(Icons.chevron_right, color: color),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
