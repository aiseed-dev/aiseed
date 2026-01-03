// Copyright (c) 2026 AIseed.dev
// Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
// Dual-licensed with a Commercial License. See LICENSE for details.

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// リズムタスク - 自由にタップ
class TaskRhythm extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic>) onComplete;

  const TaskRhythm({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  State<TaskRhythm> createState() => _TaskRhythmState();
}

class _TaskRhythmState extends State<TaskRhythm> {
  final List<Map<String, dynamic>> _taps = [];
  bool _isRecording = false;
  bool _isFinished = false;
  Timer? _timer;
  int _remainingSeconds = 10;
  DateTime? _startTime;

  final List<_TapRipple> _ripples = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _startTime = DateTime.now();
      _taps.clear();
      _ripples.clear();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _finishRecording();
        }
      });
    });
  }

  void _finishRecording() {
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _isFinished = true;
    });
  }

  void _handleTap(TapDownDetails details) {
    if (!_isRecording) return;

    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final size = box.size;

    final tap = {
      'time_ms': DateTime.now().difference(_startTime!).inMilliseconds,
      'x': localPosition.dx / size.width,
      'y': localPosition.dy / size.height,
    };

    setState(() {
      _taps.add(tap);
      _ripples.add(_TapRipple(
        position: localPosition,
        color: _getRippleColor(_taps.length),
      ));
    });

    // リップルを削除
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _ripples.isNotEmpty) {
        setState(() {
          _ripples.removeAt(0);
        });
      }
    });
  }

  Color _getRippleColor(int index) {
    final colors = [
      AppColors.musical,
      AppColors.primary,
      AppColors.secondary,
      AppColors.interpersonal,
      AppColors.spatial,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final instruction = widget.task['instruction'] ?? '';

    return Column(
      children: [
        // 説明
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                instruction,
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_isRecording)
                Text(
                  '残り $_remainingSeconds 秒',
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.musical,
                  ),
                )
              else if (!_isFinished)
                Text(
                  'スタートを押してからタップしてね',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),

        // タップエリア
        Expanded(
          child: GestureDetector(
            onTapDown: _handleTap,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.musical.withOpacity(_isRecording ? 0.15 : 0.05),
                    AppColors.primary.withOpacity(_isRecording ? 0.1 : 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isRecording
                      ? AppColors.musical
                      : AppColors.divider,
                  width: _isRecording ? 3 : 2,
                ),
              ),
              child: Stack(
                children: [
                  // ヒント
                  if (!_isRecording && !_isFinished)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🥁', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          Text(
                            'ここをタップ',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // タップカウント
                  if (_isRecording)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.musical,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_taps.length} tap',
                          style: AppTextStyles.label.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // リップルエフェクト
                  ..._ripples.map((ripple) => Positioned(
                        left: ripple.position.dx - 30,
                        top: ripple.position.dy - 30,
                        child: _RippleWidget(color: ripple.color),
                      )),
                ],
              ),
            ),
          ),
        ),

        // 結果表示
        if (_isFinished)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.musical.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('タップ数', '${_taps.length}'),
                  _buildStat(
                    'テンポ',
                    _taps.length > 1
                        ? '${(10000 / _taps.length).round()} ms/tap'
                        : '-',
                  ),
                ],
              ),
            ),
          ),

        // ボタン
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isRecording
                  ? _finishRecording
                  : (_isFinished ? _submit : _startRecording),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording
                    ? AppColors.error
                    : AppColors.musical,
              ),
              child: Text(
                _isRecording
                    ? '終わる'
                    : (_isFinished ? 'これでいい' : 'スタート'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headline.copyWith(
            color: AppColors.musical,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _submit() {
    widget.onComplete({
      'tap_sequence': _taps,
      'hesitation_count': 0,
    });
  }
}

class _TapRipple {
  final Offset position;
  final Color color;

  _TapRipple({required this.position, required this.color});
}

class _RippleWidget extends StatefulWidget {
  final Color color;

  const _RippleWidget({required this.color});

  @override
  State<_RippleWidget> createState() => _RippleWidgetState();
}

class _RippleWidgetState extends State<_RippleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.5),
              ),
            ),
          ),
        );
      },
    );
  }
}
