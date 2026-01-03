// Copyright (c) 2026 AIseed.dev
// Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
// Dual-licensed with a Commercial License. See LICENSE for details.

import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// カラー選択タスク - 今日の気分の色を選ぶ
class TaskColorPicker extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic>) onComplete;

  const TaskColorPicker({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  State<TaskColorPicker> createState() => _TaskColorPickerState();
}

class _TaskColorPickerState extends State<TaskColorPicker> {
  Color? _selectedColor;
  double _hue = 0;
  double _saturation = 0.8;
  double _lightness = 0.5;

  // プリセットカラー
  final List<Color> _presetColors = const [
    Color(0xFFFF6B6B), // 赤
    Color(0xFFFF9F43), // オレンジ
    Color(0xFFFECA57), // 黄色
    Color(0xFF1DD1A1), // ミント
    Color(0xFF54A0FF), // 青
    Color(0xFF5F27CD), // 紫
    Color(0xFFFF9FF3), // ピンク
    Color(0xFF576574), // グレー
  ];

  Color get _currentColor => HSLColor.fromAHSL(
        1.0,
        _hue,
        _saturation,
        _lightness,
      ).toColor();

  @override
  Widget build(BuildContext context) {
    final instruction = widget.task['instruction'] ?? '';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 説明
            Text(
              instruction,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // 選択されている色のプレビュー
            _buildColorPreview(),

            const SizedBox(height: 32),

            // プリセットカラー
            _buildPresetColors(),

            const SizedBox(height: 24),

            // カスタムカラースライダー
            _buildColorSliders(),

            const SizedBox(height: 32),

            // 確認ボタン
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedColor != null ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor ?? AppColors.disabled,
                ),
                child: Text(
                  _selectedColor != null ? 'これにする' : '色を選んでね',
                  style: TextStyle(
                    color: _selectedColor != null
                        ? (_lightness > 0.6 ? Colors.black87 : Colors.white)
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPreview() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: _selectedColor ?? AppColors.divider,
        shape: BoxShape.circle,
        boxShadow: _selectedColor != null
            ? [
                BoxShadow(
                  color: _selectedColor!.withOpacity(0.5),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ]
            : null,
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
      ),
      child: _selectedColor == null
          ? Center(
              child: Text(
                '?',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildPresetColors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '選んでみて',
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _presetColors.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                  // HSLに変換してスライダーに反映
                  final hsl = HSLColor.fromColor(color);
                  _hue = hsl.hue;
                  _saturation = hsl.saturation;
                  _lightness = hsl.lightness;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 56 : 48,
                height: isSelected ? 56 : 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 28)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSliders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '自分で調整',
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // 色相スライダー
        Row(
          children: [
            const Text('🌈', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 12,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 14,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 24,
                  ),
                  trackShape: _GradientTrackShape(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF0000),
                        Color(0xFFFFFF00),
                        Color(0xFF00FF00),
                        Color(0xFF00FFFF),
                        Color(0xFF0000FF),
                        Color(0xFFFF00FF),
                        Color(0xFFFF0000),
                      ],
                    ),
                  ),
                ),
                child: Slider(
                  value: _hue,
                  min: 0,
                  max: 360,
                  onChanged: (value) {
                    setState(() {
                      _hue = value;
                      _selectedColor = _currentColor;
                    });
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 彩度スライダー
        Row(
          children: [
            const Text('💧', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Slider(
                value: _saturation,
                min: 0,
                max: 1,
                activeColor: _currentColor,
                inactiveColor: _currentColor.withOpacity(0.3),
                onChanged: (value) {
                  setState(() {
                    _saturation = value;
                    _selectedColor = _currentColor;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 明度スライダー
        Row(
          children: [
            const Text('☀️', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Slider(
                value: _lightness,
                min: 0.2,
                max: 0.8,
                activeColor: _currentColor,
                inactiveColor: _currentColor.withOpacity(0.3),
                onChanged: (value) {
                  setState(() {
                    _lightness = value;
                    _selectedColor = _currentColor;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submit() {
    if (_selectedColor == null) return;

    // 色を16進数に変換
    final hex =
        '#${_selectedColor!.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

    widget.onComplete({
      'selected_color': hex,
      'hesitation_count': 0,
    });
  }
}

class _GradientTrackShape extends SliderTrackShape {
  final Gradient gradient;

  _GradientTrackShape({required this.gradient});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      paint,
    );
  }
}
