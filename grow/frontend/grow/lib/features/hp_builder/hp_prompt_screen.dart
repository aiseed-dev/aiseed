import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'hp_preview_screen.dart';

/// プロンプト表示・HTMLペースト画面
class HpPromptScreen extends StatefulWidget {
  final String prompt;

  const HpPromptScreen({
    super.key,
    required this.prompt,
  });

  @override
  State<HpPromptScreen> createState() => _HpPromptScreenState();
}

class _HpPromptScreenState extends State<HpPromptScreen> {
  final TextEditingController _htmlController = TextEditingController();
  bool _showHtmlInput = false;

  @override
  void dispose() {
    _htmlController.dispose();
    super.dispose();
  }

  Future<void> _copyPrompt() async {
    await Clipboard.setData(ClipboardData(text: widget.prompt));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('プロンプトをコピーしました'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() => _showHtmlInput = true);
    }
  }

  Future<void> _pasteHtml() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _htmlController.text = data!.text!;
      });
    }
  }

  void _previewHtml() {
    final html = _htmlController.text.trim();
    if (html.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('HTMLを入力してください')),
      );
      return;
    }

    // HTMLの基本的なバリデーション
    if (!html.contains('<html') && !html.contains('<!DOCTYPE')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('有効なHTMLを入力してください')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HpPreviewScreen(
          html: html,
          prompt: widget.prompt,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AIへのプロンプト'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ステップ1: プロンプトをコピー
            _buildStepHeader(
              context,
              step: 1,
              title: 'プロンプトをコピー',
              isActive: !_showHtmlInput,
            ),
            const SizedBox(height: 8),

            // プロンプト表示
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  widget.prompt,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: _copyPrompt,
              icon: const Icon(Icons.copy),
              label: const Text('プロンプトをコピー'),
            ),

            const SizedBox(height: 8),

            // 外部AIへの案内
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.open_in_new,
                          size: 20,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '次のステップ',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Claude または ChatGPT を開く\n'
                      '2. コピーしたプロンプトを貼り付ける\n'
                      '3. 生成されたHTMLをコピーする\n'
                      '4. 下のボックスに貼り付ける',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ステップ2: HTMLをペースト
            _buildStepHeader(
              context,
              step: 2,
              title: 'AIが生成したHTMLを貼り付け',
              isActive: _showHtmlInput,
            ),
            const SizedBox(height: 8),

            // HTML入力
            AnimatedOpacity(
              opacity: _showHtmlInput ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  TextField(
                    controller: _htmlController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: 'AIが生成したHTMLをここに貼り付けてください...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLowest,
                      suffixIcon: IconButton(
                        onPressed: _pasteHtml,
                        icon: const Icon(Icons.paste),
                        tooltip: 'クリップボードから貼り付け',
                      ),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pasteHtml,
                          icon: const Icon(Icons.paste),
                          label: const Text('貼り付け'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _previewHtml,
                          icon: const Icon(Icons.visibility),
                          label: const Text('プレビュー'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader(
    BuildContext context, {
    required int step,
    required String title,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          ),
          child: Center(
            child: Text(
              '$step',
              style: theme.textTheme.labelLarge?.copyWith(
                color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isActive ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
