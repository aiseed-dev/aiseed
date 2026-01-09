import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// タグチップウィジェット
///
/// 責務: 観察記録のタグを統一スタイルで表示
class GrowTag extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool selected;

  const GrowTag({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = selected
        ? GrowColors.lifeGreen
        : (backgroundColor ?? GrowColors.paleGreen);
    final fgColor = selected
        ? Colors.white
        : (textColor ?? GrowColors.deepGreen);

    final container = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

/// 複数タグをラップ表示
class GrowTagList extends StatelessWidget {
  final List<String> tags;
  final double spacing;
  final double runSpacing;

  const GrowTagList({
    super.key,
    required this.tags,
    this.spacing = 8,
    this.runSpacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: tags.map((tag) => GrowTag(label: tag)).toList(),
    );
  }
}
