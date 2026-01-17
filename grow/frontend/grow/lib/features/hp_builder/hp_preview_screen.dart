import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'services/hp_repository.dart';
import 'widgets/voice_input_button.dart';
import 'services/prompt_generator.dart';

/// HTMLプレビュー画面
class HpPreviewScreen extends StatefulWidget {
  final String html;
  final String prompt;
  final String? existingId;

  const HpPreviewScreen({
    super.key,
    required this.html,
    required this.prompt,
    this.existingId,
  });

  @override
  State<HpPreviewScreen> createState() => _HpPreviewScreenState();
}

class _HpPreviewScreenState extends State<HpPreviewScreen> {
  late WebViewController _webViewController;
  late HpRepository _repository;
  bool _isLoading = true;
  bool _showModificationInput = false;
  final TextEditingController _modificationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initWebView();
    _initRepository();
  }

  @override
  void dispose() {
    _modificationController.dispose();
    super.dispose();
  }

  Future<void> _initRepository() async {
    final prefs = await SharedPreferences.getInstance();
    _repository = HpRepository(prefs);
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(widget.html);
  }

  Future<void> _saveHtml() async {
    final nameController = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ホームページを保存'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '名前',
            hintText: '例: 山田農園HP v1',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (name == null || name.trim().isEmpty) return;

    try {
      await _repository.save(
        id: widget.existingId,
        name: name.trim(),
        html: widget.html,
        prompt: widget.prompt,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _shareHtml() async {
    try {
      final filePath = await _repository.exportForPreview(widget.html);
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        subject: 'ホームページHTML',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('共有に失敗しました: $e')),
        );
      }
    }
  }

  void _toggleModificationInput() {
    setState(() {
      _showModificationInput = !_showModificationInput;
    });
  }

  void _generateModificationPrompt() {
    final request = _modificationController.text.trim();
    if (request.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('修正内容を入力してください')),
      );
      return;
    }

    final prompt = HpPromptGenerator.generateModificationPrompt(
      currentHtml: widget.html,
      modificationRequest: request,
    );

    // 新しいプロンプト画面へ
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => _ModificationPromptScreen(prompt: prompt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('プレビュー'),
        actions: [
          IconButton(
            onPressed: _saveHtml,
            icon: const Icon(Icons.save),
            tooltip: '保存',
          ),
          IconButton(
            onPressed: _shareHtml,
            icon: const Icon(Icons.share),
            tooltip: '共有',
          ),
        ],
      ),
      body: Column(
        children: [
          // WebView
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),

          // 修正入力パネル
          if (_showModificationInput)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '修正の指示',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleModificationInput,
                        icon: const Icon(Icons.close),
                        iconSize: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _modificationController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: '例: 色をもう少し緑っぽく、文字を大きく',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: VoiceInputButton(
                          onResult: (text) {
                            setState(() {
                              _modificationController.text = text;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _generateModificationPrompt,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('修正プロンプトを生成'),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: _showModificationInput
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _toggleModificationInput,
                        icon: const Icon(Icons.edit),
                        label: const Text('修正を指示'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          _saveHtml();
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('保存して完了'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// 修正プロンプト表示画面
class _ModificationPromptScreen extends StatefulWidget {
  final String prompt;

  const _ModificationPromptScreen({required this.prompt});

  @override
  State<_ModificationPromptScreen> createState() => _ModificationPromptScreenState();
}

class _ModificationPromptScreenState extends State<_ModificationPromptScreen> {
  final TextEditingController _htmlController = TextEditingController();

  @override
  void dispose() {
    _htmlController.dispose();
    super.dispose();
  }

  Future<void> _copyPrompt() async {
    await Clipboard.setData(ClipboardData(text: widget.prompt));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('プロンプトをコピーしました')),
      );
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

    Navigator.of(context).pushReplacement(
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
        title: const Text('修正プロンプト'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // プロンプト表示
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
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

            const SizedBox(height: 24),

            Text(
              '修正後のHTMLを貼り付け',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _htmlController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'AIが生成した修正後のHTMLをここに貼り付け...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerLowest,
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
    );
  }
}
