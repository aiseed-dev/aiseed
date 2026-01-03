// Copyright (c) 2026 AIseed.dev
// Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
// Dual-licensed with a Commercial License. See LICENSE for details.

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// 配置タスク - 図形を好きなように並べる
class TaskArrange extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic>) onComplete;

  const TaskArrange({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  State<TaskArrange> createState() => _TaskArrangeState();
}

class _TaskArrangeState extends State<TaskArrange> {
  final Map<String, Offset> _positions = {};
  final Map<String, GlobalKey> _keys = {};
  bool _hasArranged = false;

  final List<Map<String, dynamic>> _defaultItems = [
    {'id': 'circle', 'shape': 'circle', 'color': '#FF6B6B'},
    {'id': 'square', 'shape': 'square', 'color': '#4ECDC4'},
    {'id': 'triangle', 'shape': 'triangle', 'color': '#45B7D1'},
    {'id': 'star', 'shape': 'star', 'color': '#96CEB4'},
    {'id': 'heart', 'shape': 'heart', 'color': '#FFEAA7'},
  ];

  @override
  void initState() {
    super.initState();
    final items = List<Map<String, dynamic>>.from(
      widget.task['items'] ?? _defaultItems,
    );

    // 初期位置を設定（画面下部に横並び）
    for (int i = 0; i < items.length; i++) {
      final id = items[i]['id'] as String;
      _positions[id] = Offset(
        60.0 + (i * 60),
        400.0,
      );
      _keys[id] = GlobalKey();
    }
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    final instruction = widget.task['instruction'] ?? '好きなように並べてみて';
    final items = List<Map<String, dynamic>>.from(
      widget.task['items'] ?? _defaultItems,
    );

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

        // 配置エリア
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.divider,
                width: 2,
              ),
            ),
            child: Stack(
              children: items.map((item) {
                final id = item['id'] as String;
                final shape = item['shape'] as String;
                final color = _parseColor(item['color'] as String);
                final position = _positions[id] ?? Offset.zero;

                return Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: Draggable<String>(
                    data: id,
                    feedback: _buildShape(shape, color, 60, isDragging: true),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _buildShape(shape, color, 50),
                    ),
                    onDragEnd: (details) {
                      final box = context.findRenderObject() as RenderBox;
                      final localPosition = box.globalToLocal(details.offset);

                      setState(() {
                        _positions[id] = Offset(
                          localPosition.dx.clamp(0, box.size.width - 50),
                          localPosition.dy.clamp(0, box.size.height - 50),
                        );
                        _hasArranged = true;
                      });
                    },
                    child: _buildShape(shape, color, 50),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // 確認ボタン
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _hasArranged ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.musical,
              ),
              child: Text(_hasArranged ? 'これでいい' : '図形を動かしてね'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShape(String shape, Color color, double size, {bool isDragging = false}) {
    final boxDecoration = BoxDecoration(
      boxShadow: isDragging
          ? [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );

    switch (shape) {
      case 'circle':
        return Container(
          width: size,
          height: size,
          decoration: boxDecoration.copyWith(
            color: color,
            shape: BoxShape.circle,
          ),
        );

      case 'square':
        return Container(
          width: size,
          height: size,
          decoration: boxDecoration.copyWith(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        );

      case 'triangle':
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _TrianglePainter(color),
          ),
        );

      case 'star':
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _StarPainter(color),
          ),
        );

      case 'heart':
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _HeartPainter(color),
          ),
        );

      default:
        return Container(
          width: size,
          height: size,
          color: color,
        );
    }
  }

  void _submit() {
    final arranged = _positions.entries.map((e) {
      final box = context.findRenderObject() as RenderBox;
      return {
        'id': e.key,
        'x': e.value.dx / box.size.width,
        'y': e.value.dy / box.size.height,
      };
    }).toList();

    widget.onComplete({
      'arranged_positions': arranged,
      'hesitation_count': 0,
    });
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;
    final path = Path();

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * pi / 180;
      final innerAngle = ((i * 72 + 36) - 90) * pi / 180;

      final outerPoint = Offset(
        center.dx + outerRadius * cos(outerAngle),
        center.dy + outerRadius * sin(outerAngle),
      );
      final innerPoint = Offset(
        center.dx + innerRadius * cos(innerAngle),
        center.dy + innerRadius * sin(innerAngle),
      );

      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeartPainter extends CustomPainter {
  final Color color;
  _HeartPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w / 2, h * 0.25);
    path.cubicTo(w * 0.2, h * 0.1, -w * 0.25, h * 0.6, w / 2, h);
    path.moveTo(w / 2, h * 0.25);
    path.cubicTo(w * 0.8, h * 0.1, w * 1.25, h * 0.6, w / 2, h);

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
