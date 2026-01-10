import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';

/// 挨拶セクション
///
/// 責務: 時間帯に応じた挨拶と励ましの言葉を表示
class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    final message = _getMessage();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GrowColors.paleGreen.withValues(alpha: 0.5),
            GrowColors.paleSoil,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                greeting.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting.text,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: GrowColors.drySoil,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 時間帯に応じた挨拶を取得
  _Greeting _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 10) {
      return const _Greeting('🌅', 'おはようございます');
    } else if (hour >= 10 && hour < 17) {
      return const _Greeting('☀️', 'こんにちは');
    } else if (hour >= 17 && hour < 21) {
      return const _Greeting('🌇', 'こんばんは');
    } else {
      return const _Greeting('🌙', 'お疲れさまです');
    }
  }

  /// 励ましのメッセージを取得
  String _getMessage() {
    final messages = [
      '今日も観察を楽しみましょう',
      '植物たちは何を見せてくれるかな？',
      '小さな変化を見つけてみよう',
      '自然の声に耳を傾けて',
      '今日はどんな発見があるかな？',
    ];

    // 日付に基づいてメッセージを選択（毎日同じメッセージ）
    final dayOfYear = DateTime.now().difference(
      DateTime(DateTime.now().year, 1, 1),
    ).inDays;

    return messages[dayOfYear % messages.length];
  }
}

class _Greeting {
  final String emoji;
  final String text;

  const _Greeting(this.emoji, this.text);
}
