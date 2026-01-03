// Copyright (c) 2026 AIseed.dev
// Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
// Dual-licensed with a Commercial License. See LICENSE for details.

import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// 観察タスク - 画像の気になる場所をタップ
class TaskObserve extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic>) onComplete;

  const TaskObserve({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  State<TaskObserve> createState() => _TaskObserveState();
}

class _TaskObserveState extends State<TaskObserve> {
  Offset? _tapPosition;
  bool _showConfirm = false;

  @override
  Widget build(BuildContext context) {
    final instruction = widget.task['instruction'] ?? '';

    return Column(
      children: [
        // 説明
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            instruction,
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),

        // 画像エリア
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTapDown: (details) {
                final box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                final size = box.size;

                setState(() {
                  _tapPosition = Offset(
                    localPosition.dx / size.width,
                    localPosition.dy / size.height,
                  );
                  _showConfirm = true;
                });
              },
              child: Stack(
                children: [
                  // 森の画像（プレースホルダー）
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2D5016),
                          Color(0xFF4A7C23),
                          Color(0xFF1B3A0B),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // 木々のシルエット
                        Positioned(
                          left: 20,
                          bottom: 50,
                          child: _buildTree(80, const Color(0xFF1B3A0B)),
                        ),
                        Positioned(
                          left: 80,
                          bottom: 30,
                          child: _buildTree(120, const Color(0xFF234512)),
                        ),
                        Positioned(
                          right: 60,
                          bottom: 40,
                          child: _buildTree(100, const Color(0xFF1B3A0B)),
                        ),
                        Positioned(
                          right: 20,
                          bottom: 60,
                          child: _buildTree(70, const Color(0xFF2D5016)),
                        ),
                        // 鳥
                        const Positioned(
                          top: 40,
                          right: 80,
                          child: Text('🐦', style: TextStyle(fontSize: 24)),
                        ),
                        // 花
                        const Positioned(
                          bottom: 20,
                          left: 40,
                          child: Text('🌸', style: TextStyle(fontSize: 20)),
                        ),
                        const Positioned(
                          bottom: 15,
                          right: 100,
                          child: Text('🌼', style: TextStyle(fontSize: 16)),
                        ),
                        // 蝶
                        const Positioned(
                          top: 100,
                          left: 100,
                          child: Text('🦋', style: TextStyle(fontSize: 20)),
                        ),
                        // 光
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 100,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.yellow.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // タップ位置マーカー
                  if (_tapPosition != null)
                    Positioned(
                      left: (_tapPosition!.dx *
                              (MediaQuery.of(context).size.width - 32)) -
                          20,
                      top: (_tapPosition!.dy * 300) - 20,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // 確認ボタン
        if (_showConfirm)
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  widget.onComplete({
                    'tap_position': {
                      'x': _tapPosition!.dx,
                      'y': _tapPosition!.dy,
                    },
                    'hesitation_count': 0,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.musical,
                ),
                child: const Text('これにする'),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '気になったところをタップしてね',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTree(double height, Color color) {
    return Container(
      width: 40,
      height: height,
      child: CustomPaint(
        painter: _TreePainter(color),
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  final Color color;

  _TreePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // 木の幹
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.4, size.height * 0.6, size.width * 0.2, size.height * 0.4),
      paint..color = const Color(0xFF3D2914),
    );

    // 木の葉（三角形）
    final path = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height * 0.7)
      ..lineTo(0, size.height * 0.7)
      ..close();

    canvas.drawPath(path, paint..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
