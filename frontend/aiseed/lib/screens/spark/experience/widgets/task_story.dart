// Copyright (c) 2026 AIseed.dev
// Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
// Dual-licensed with a Commercial License. See LICENSE for details.

import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// ストーリータスク - 物語の続きを選ぶ
class TaskStory extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic>) onComplete;

  const TaskStory({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  State<TaskStory> createState() => _TaskStoryState();
}

class _TaskStoryState extends State<TaskStory>
    with SingleTickerProviderStateMixin {
  String? _selectedOption;
  late AnimationController _animController;
  late Animation<double> _seedAnimation;

  final Map<String, String> _optionIcons = {
    'city': '🏙️',
    'mountain': '⛰️',
    'sea': '🌊',
  };

  final Map<String, Color> _optionColors = {
    'city': const Color(0xFF6366F1),
    'mountain': const Color(0xFF10B981),
    'sea': const Color(0xFF3B82F6),
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _seedAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    _animController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instruction = widget.task['instruction'] ?? '';
    final options = List<Map<String, dynamic>>.from(widget.task['options'] ?? []);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // アニメーション付き種のイラスト
            _buildSeedAnimation(),

            const SizedBox(height: 24),

            // ストーリーテキスト
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                instruction,
                style: AppTextStyles.titleMedium.copyWith(
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // 選択肢
            ...options.map((option) {
              final id = option['id'] ?? '';
              final label = option['label'] ?? '';
              final isSelected = _selectedOption == id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedOption = id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (_optionColors[id] ?? AppColors.musical)
                              .withOpacity(0.2)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? (_optionColors[id] ?? AppColors.musical)
                            : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _optionIcons[id] ?? '❓',
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: isSelected
                                      ? (_optionColors[id] ?? AppColors.musical)
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              Text(
                                _getDescription(id),
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: _optionColors[id] ?? AppColors.musical,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // 確認ボタン
            if (_selectedOption != null)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onComplete({
                      'selected_option': _selectedOption,
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

  Widget _buildSeedAnimation() {
    return SizedBox(
      height: 100,
      child: AnimatedBuilder(
        animation: _seedAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 風のライン
              Positioned(
                left: 20 + (_seedAnimation.value * 60),
                child: Opacity(
                  opacity: 0.3,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      width: 40,
                      height: 2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 50 + (_seedAnimation.value * 80),
                top: 20,
                child: Opacity(
                  opacity: 0.2,
                  child: Transform.rotate(
                    angle: -0.1,
                    child: Container(
                      width: 30,
                      height: 2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              // 種
              Positioned(
                left: 100 + (_seedAnimation.value * 100),
                top: 30 + (sin(_seedAnimation.value * 3.14) * 20),
                child: Transform.rotate(
                  angle: _seedAnimation.value * 0.5,
                  child: const Text('🌱', style: TextStyle(fontSize: 40)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getDescription(String id) {
    switch (id) {
      case 'city':
        return 'ビルの隙間から芽を出す';
      case 'mountain':
        return '静かな森で大きく育つ';
      case 'sea':
        return '波の音を聞きながら';
      default:
        return '';
    }
  }
}

double sin(double x) => x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
