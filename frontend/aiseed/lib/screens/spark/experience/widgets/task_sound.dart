// Copyright (c) 2026 AIseed.dev
// Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
// Dual-licensed with a Commercial License. See LICENSE for details.

import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// 音連想タスク - 音を聞いて思い浮かべたものを選ぶ
class TaskSound extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic>) onComplete;

  const TaskSound({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  State<TaskSound> createState() => _TaskSoundState();
}

class _TaskSoundState extends State<TaskSound> {
  String? _selectedOption;
  bool _isPlayingSound = true;
  final TextEditingController _otherController = TextEditingController();

  final Map<String, String> _optionIcons = {
    'umbrella': '☂️',
    'window': '🪟',
    'forest': '🌲',
    'sea': '🌊',
  };

  @override
  void initState() {
    super.initState();
    // 音再生のシミュレーション
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isPlayingSound = false);
      }
    });
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instruction = widget.task['instruction'] ?? '';
    final options = List<Map<String, dynamic>>.from(widget.task['options'] ?? []);
    final allowOther = widget.task['allow_other'] ?? false;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 音再生エリア
            _buildSoundPlayer(),

            const SizedBox(height: 24),

            // 説明
            Text(
              instruction,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // 選択肢グリッド
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: options.map((option) {
                final id = option['id'] ?? '';
                final label = option['label'] ?? '';
                final isSelected = _selectedOption == id;

                return GestureDetector(
                  onTap: () => setState(() => _selectedOption = id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.musical.withOpacity(0.2)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.musical
                            : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _optionIcons[id] ?? '❓',
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? AppColors.musical
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // その他オプション
            if (allowOther) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setState(() => _selectedOption = 'other'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedOption == 'other'
                        ? AppColors.musical.withOpacity(0.2)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedOption == 'other'
                          ? AppColors.musical
                          : AppColors.divider,
                      width: _selectedOption == 'other' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('💭', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _selectedOption == 'other'
                            ? TextField(
                                controller: _otherController,
                                decoration: const InputDecoration(
                                  hintText: '何を思い浮かべた？',
                                  border: InputBorder.none,
                                ),
                                autofocus: true,
                              )
                            : Text(
                                'その他...',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // 確認ボタン
            if (_selectedOption != null)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onComplete({
                      'selected_option': _selectedOption,
                      'other_text': _selectedOption == 'other'
                          ? _otherController.text
                          : null,
                      'hesitation_count': 0,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.musical,
                  ),
                  child: const Text('これにする'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundPlayer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.musical.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            _isPlayingSound ? '🔊 雨の音...' : '🔊 聞けたかな？',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.musical,
            ),
          ),
          const SizedBox(height: 12),
          if (_isPlayingSound)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 200 + i * 100),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 4,
                  height: 20 + (i % 3) * 10,
                  decoration: BoxDecoration(
                    color: AppColors.musical,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            )
          else
            Text(
              '（実際の音は準備中）',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
