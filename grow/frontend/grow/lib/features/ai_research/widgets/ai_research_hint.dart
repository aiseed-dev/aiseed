import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/data/ai_research_prompts.dart';
import '../ai_research_guide_screen.dart';

/// AIリサーチヒントウィジェット
///
/// 責務: 各入力フィールドに添えるAIリサーチへの誘導
class AIResearchHint extends StatelessWidget {
  final String hintText;
  final ResearchCategory category;
  final Map<String, String>? initialValues;

  const AIResearchHint({
    super.key,
    required this.hintText,
    required this.category,
    this.initialValues,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openResearchGuide(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: GrowColors.paleGreen.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: GrowColors.lifeGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤖', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                hintText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: GrowColors.deepGreen,
                    ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: GrowColors.deepGreen,
            ),
          ],
        ),
      ),
    );
  }

  void _openResearchGuide(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIResearchGuideScreen(
          initialCategory: category,
          initialValues: initialValues,
        ),
      ),
    );
  }
}

/// AIリサーチバナー（より目立つバージョン）
class AIResearchBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final ResearchCategory? category;
  final Map<String, String>? initialValues;

  const AIResearchBanner({
    super.key,
    this.title = 'AIで調べてみよう',
    this.subtitle = 'ChatGPTやClaudeで詳しい情報を調べられます',
    this.category,
    this.initialValues,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openResearchGuide(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              GrowColors.paleGreen,
              GrowColors.paleGreen.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GrowColors.lifeGreen),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: GrowColors.deepGreen,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: GrowColors.drySoil,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: GrowColors.deepGreen,
            ),
          ],
        ),
      ),
    );
  }

  void _openResearchGuide(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIResearchGuideScreen(
          initialCategory: category,
          initialValues: initialValues,
        ),
      ),
    );
  }
}

/// 特定のプロンプトへのショートカット
class AIResearchShortcut extends StatelessWidget {
  final String promptId;
  final String label;
  final Map<String, String>? initialValues;

  const AIResearchShortcut({
    super.key,
    required this.promptId,
    required this.label,
    this.initialValues,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _openResearchGuide(context),
      icon: const Text('🤖', style: TextStyle(fontSize: 16)),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: GrowColors.deepGreen,
        side: const BorderSide(color: GrowColors.lifeGreen),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _openResearchGuide(BuildContext context) {
    // プロンプトIDからカテゴリを特定
    final prompt = AIResearchPrompts.all.firstWhere(
      (p) => p.id == promptId,
      orElse: () => AIResearchPrompts.all.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIResearchGuideScreen(
          initialCategory: prompt.category,
          initialValues: initialValues,
        ),
      ),
    );
  }
}
