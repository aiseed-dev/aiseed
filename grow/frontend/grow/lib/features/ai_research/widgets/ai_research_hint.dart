import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/data/ai_research_prompts.dart';
import '../ai_research_guide_screen.dart';

/// AIリサーチヒントウィジェット（クイックコピー付き）
///
/// 責務: 各入力フィールドに添えるAIリサーチへの誘導 + ワンタップコピー
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GrowColors.paleGreen.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GrowColors.lifeGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー行
          Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hintText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: GrowColors.deepGreen,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ボタン行
          Row(
            children: [
              // クイックコピーボタン
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _quickCopy(context),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('プロンプトをコピー'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GrowColors.deepGreen,
                    side: const BorderSide(color: GrowColors.lifeGreen),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 詳細ボタン
              OutlinedButton(
                onPressed: () => _openResearchGuide(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: GrowColors.drySoil,
                  side: const BorderSide(color: GrowColors.lightSoil),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('詳しく'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// カテゴリの最初のプロンプトをクイックコピー
  void _quickCopy(BuildContext context) {
    final prompts = AIResearchPrompts.byCategory[category] ?? [];
    if (prompts.isEmpty) return;

    final prompt = prompts.first;
    final values = initialValues ?? {};

    // 未入力のプレースホルダーにはヒントを入れる
    final filledValues = <String, String>{};
    for (final placeholder in prompt.placeholders) {
      if (values.containsKey(placeholder) && values[placeholder]!.isNotEmpty) {
        filledValues[placeholder] = values[placeholder]!;
      } else {
        filledValues[placeholder] = '【ここに${_getPlaceholderLabel(placeholder)}を入力】';
      }
    }

    final generatedPrompt = prompt.generatePrompt(locale: 'ja', values: filledValues);
    Clipboard.setData(ClipboardData(text: generatedPrompt));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'コピーしました！\nChatGPTやClaudeに貼り付けてください',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: GrowColors.lifeGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getPlaceholderLabel(String placeholder) {
    final labels = {
      'location': '場所',
      'plant': '植物名',
      'color': '土の色',
      'texture': '土の手触り',
      'drainage': '水はけ',
      'other': 'その他',
      'symptoms': '症状',
      'pest_description': '虫や病斑の特徴',
      'farming_method': '農法',
      'weather': '天候',
      'environment': '環境',
      'sunlight': '日当たり',
      'wind': '風通し',
    };
    return labels[placeholder] ?? placeholder;
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

/// AIリサーチバナー（クイックコピー付き）
class AIResearchBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final ResearchCategory? category;
  final Map<String, String>? initialValues;
  /// クイックコピー用のデフォルトプロンプトID（省略時はカテゴリの最初）
  final String? defaultPromptId;

  const AIResearchBanner({
    super.key,
    this.title = 'AIで調べてみよう',
    this.subtitle = 'ChatGPTやClaudeで詳しい情報を調べられます',
    this.category,
    this.initialValues,
    this.defaultPromptId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
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
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: GrowColors.drySoil,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // クイックコピーボタン群
          _buildQuickCopyButtons(context),
        ],
      ),
    );
  }

  Widget _buildQuickCopyButtons(BuildContext context) {
    // 主要なプロンプトのクイックアクセス
    final quickPrompts = [
      (SoilResearchPrompts.basic, '土壌を調べる'),
      (ClimateResearchPrompts.growingCalendar, '栽培カレンダー'),
      (PlantCareResearchPrompts.naturalFarming, '自然農法の育て方'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...quickPrompts.map((item) => _QuickCopyChip(
          prompt: item.$1,
          label: item.$2,
          initialValues: initialValues,
        )),
        // 「もっと見る」ボタン
        ActionChip(
          avatar: const Icon(Icons.more_horiz, size: 18),
          label: const Text('もっと見る'),
          onPressed: () => _openResearchGuide(context),
          backgroundColor: Colors.white,
          side: const BorderSide(color: GrowColors.lightSoil),
        ),
      ],
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

/// クイックコピーチップ
class _QuickCopyChip extends StatelessWidget {
  final ResearchPrompt prompt;
  final String label;
  final Map<String, String>? initialValues;

  const _QuickCopyChip({
    required this.prompt,
    required this.label,
    this.initialValues,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.copy, size: 16, color: GrowColors.deepGreen),
      label: Text(label),
      onPressed: () => _copyPrompt(context),
      backgroundColor: Colors.white,
      side: const BorderSide(color: GrowColors.lifeGreen),
      labelStyle: const TextStyle(
        color: GrowColors.deepGreen,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void _copyPrompt(BuildContext context) {
    final values = initialValues ?? {};

    // 未入力のプレースホルダーにはヒントを入れる
    final filledValues = <String, String>{};
    for (final placeholder in prompt.placeholders) {
      if (values.containsKey(placeholder) && values[placeholder]!.isNotEmpty) {
        filledValues[placeholder] = values[placeholder]!;
      } else {
        filledValues[placeholder] = '【ここに${_getPlaceholderLabel(placeholder)}を入力】';
      }
    }

    final generatedPrompt = prompt.generatePrompt(locale: 'ja', values: filledValues);
    Clipboard.setData(ClipboardData(text: generatedPrompt));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '「$label」のプロンプトをコピーしました',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    'ChatGPTやClaudeに貼り付けてください',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: GrowColors.lifeGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getPlaceholderLabel(String placeholder) {
    final labels = {
      'location': '場所',
      'plant': '植物名',
      'color': '土の色',
      'texture': '土の手触り',
      'drainage': '水はけ',
      'other': 'その他',
      'symptoms': '症状',
      'pest_description': '虫や病斑の特徴',
      'farming_method': '農法',
      'weather': '天候',
      'environment': '環境',
      'sunlight': '日当たり',
      'wind': '風通し',
    };
    return labels[placeholder] ?? placeholder;
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

/// シンプルなコピーボタン（テキストフィールドの横に配置用）
class AIPromptCopyButton extends StatelessWidget {
  final ResearchPrompt prompt;
  final Map<String, String>? initialValues;
  final String? tooltip;

  const AIPromptCopyButton({
    super.key,
    required this.prompt,
    this.initialValues,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _copyPrompt(context),
      icon: const Icon(Icons.smart_toy_outlined),
      tooltip: tooltip ?? 'AIで調べるプロンプトをコピー',
      color: GrowColors.lifeGreen,
    );
  }

  void _copyPrompt(BuildContext context) {
    final values = initialValues ?? {};

    final filledValues = <String, String>{};
    for (final placeholder in prompt.placeholders) {
      if (values.containsKey(placeholder) && values[placeholder]!.isNotEmpty) {
        filledValues[placeholder] = values[placeholder]!;
      } else {
        filledValues[placeholder] = '【入力してください】';
      }
    }

    final generatedPrompt = prompt.generatePrompt(locale: 'ja', values: filledValues);
    Clipboard.setData(ClipboardData(text: generatedPrompt));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('プロンプトをコピーしました'),
        backgroundColor: GrowColors.lifeGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
