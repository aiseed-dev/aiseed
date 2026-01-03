// Copyright (c) 2026 AIseed.dev
// Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
// Dual-licensed with a Commercial License. See LICENSE for details.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'experience_result_screen.dart';
import 'widgets/task_observe.dart';
import 'widgets/task_sound.dart';
import 'widgets/task_arrange.dart';
import 'widgets/task_story.dart';
import 'widgets/task_rhythm.dart';
import 'widgets/task_color.dart';

/// 体験タスク画面（メイン）
class ExperienceTaskScreen extends StatefulWidget {
  const ExperienceTaskScreen({super.key});

  @override
  State<ExperienceTaskScreen> createState() => _ExperienceTaskScreenState();
}

class _ExperienceTaskScreenState extends State<ExperienceTaskScreen> {
  String? _sessionId;
  int _currentTaskIndex = 0;
  Map<String, dynamic>? _currentTask;
  bool _isLoading = true;
  String? _error;

  final List<Map<String, dynamic>> _results = [];
  DateTime? _taskStartTime;

  // タスク順序（バックエンドと同期）
  static const List<String> taskOrder = [
    'observe',
    'sound',
    'arrange',
    'story',
    'rhythm',
    'color'
  ];

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  Future<void> _startSession() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = await SessionService.getUserId();

      final response = await http.post(
        Uri.parse(ApiConfig.experienceStart),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _sessionId = data['session_id'];
          _currentTask = data['first_task'];
          _isLoading = false;
          _taskStartTime = DateTime.now();
        });
      } else {
        throw Exception('Failed to start session');
      }
    } catch (e) {
      setState(() {
        _error = '接続エラー: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitResult(Map<String, dynamic> result) async {
    if (_sessionId == null || _currentTask == null) return;

    setState(() => _isLoading = true);

    final duration = DateTime.now().difference(_taskStartTime!).inMilliseconds;
    final userId = await SessionService.getUserId();

    final submitData = {
      'task_id': _currentTask!['id'],
      'user_id': userId,
      'session_id': _sessionId,
      'duration_ms': duration,
      ...result,
    };

    _results.add(submitData);

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.experienceSubmit),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(submitData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'continue') {
          setState(() {
            _currentTaskIndex = data['completed'];
            _currentTask = data['next_task'];
            _isLoading = false;
            _taskStartTime = DateTime.now();
          });
        } else if (data['status'] == 'completed') {
          // 全タスク完了
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ExperienceResultScreen(
                  feedback: data['feedback'],
                  suggestions: List<Map<String, dynamic>>.from(
                    data['suggestions'] ?? [],
                  ),
                ),
              ),
            );
          }
        }
      } else {
        throw Exception('Failed to submit result');
      }
    } catch (e) {
      setState(() {
        _error = 'エラー: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.musical),
              const SizedBox(height: 16),
              Text(
                _currentTaskIndex == 0 ? '準備中...' : '次の体験を準備中...',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😢', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(_error!, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _startSession,
                child: const Text('もう一度試す'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // プログレスバー
            _buildProgressBar(),

            // タスクコンテンツ
            Expanded(
              child: _buildTaskContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentTaskIndex + 1} / ${taskOrder.length}',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.musical,
                ),
              ),
              Text(
                _currentTask?['name'] ?? '',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentTaskIndex + 1) / taskOrder.length,
              backgroundColor: AppColors.musical.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(AppColors.musical),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskContent() {
    final taskId = _currentTask?['id'] ?? '';
    final taskType = _currentTask?['type'] ?? '';

    switch (taskId) {
      case 'observe':
        return TaskObserve(
          task: _currentTask!,
          onComplete: _submitResult,
        );
      case 'sound':
        return TaskSound(
          task: _currentTask!,
          onComplete: _submitResult,
        );
      case 'arrange':
        return TaskArrange(
          task: _currentTask!,
          onComplete: _submitResult,
        );
      case 'story':
        return TaskStory(
          task: _currentTask!,
          onComplete: _submitResult,
        );
      case 'rhythm':
        return TaskRhythm(
          task: _currentTask!,
          onComplete: _submitResult,
        );
      case 'color':
        return TaskColorPicker(
          task: _currentTask!,
          onComplete: _submitResult,
        );
      default:
        return Center(
          child: Text('Unknown task: $taskId ($taskType)'),
        );
    }
  }
}
