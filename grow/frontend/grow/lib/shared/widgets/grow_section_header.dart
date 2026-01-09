import 'package:flutter/material.dart';

/// セクションヘッダーウィジェット
///
/// 責務: セクションのタイトルと「すべて見る」リンクを表示
class GrowSectionHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const GrowSectionHeader({
    super.key,
    required this.emoji,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
