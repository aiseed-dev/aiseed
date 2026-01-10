import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/theme/colors.dart';
import '../../shared/data/ai_research_prompts.dart';

/// AIリサーチガイド画面
///
/// 責務: AIリサーチ用のプロンプトを表示・コピー機能を提供
class AIResearchGuideScreen extends StatefulWidget {
  /// 初期表示するカテゴリ
  final ResearchCategory? initialCategory;

  /// プレースホルダーの初期値（例：植物名）
  final Map<String, String>? initialValues;

  const AIResearchGuideScreen({
    super.key,
    this.initialCategory,
    this.initialValues,
  });

  @override
  State<AIResearchGuideScreen> createState() => _AIResearchGuideScreenState();
}

class _AIResearchGuideScreenState extends State<AIResearchGuideScreen> {
  ResearchCategory? _selectedCategory;
  ResearchPrompt? _selectedPrompt;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;

    // 初期値があればコントローラーを設定
    if (widget.initialValues != null) {
      for (final entry in widget.initialValues!.entries) {
        _controllers[entry.key] = TextEditingController(text: entry.value);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AIリサーチガイド'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _selectedPrompt != null
          ? _buildPromptDetail()
          : _selectedCategory != null
              ? _buildPromptList()
              : _buildCategoryList(),
    );
  }

  /// カテゴリ一覧
  Widget _buildCategoryList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(
          '調べたい内容を選んでください',
          'ChatGPT、Claude、Geminiなどお好みのAIに\nプロンプトをコピペして使えます',
        ),
        const SizedBox(height: 24),
        ...ResearchCategory.values.map((category) {
          final prompts = AIResearchPrompts.byCategory[category] ?? [];
          return _buildCategoryCard(category, prompts.length);
        }),
      ],
    );
  }

  Widget _buildCategoryCard(ResearchCategory category, int promptCount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(category.emoji, style: const TextStyle(fontSize: 32)),
        title: Text(
          category.nameJa,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('$promptCount種類のプロンプト'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  /// プロンプト一覧
  Widget _buildPromptList() {
    final prompts = AIResearchPrompts.byCategory[_selectedCategory!] ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 戻るボタン
        TextButton.icon(
          onPressed: () {
            setState(() {
              _selectedCategory = null;
            });
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text('カテゴリに戻る'),
        ),
        const SizedBox(height: 8),
        _buildHeader(
          '${_selectedCategory!.emoji} ${_selectedCategory!.nameJa}',
          '調べたい内容を選んでください',
        ),
        const SizedBox(height: 16),
        ...prompts.map(_buildPromptCard),
      ],
    );
  }

  Widget _buildPromptCard(ResearchPrompt prompt) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          prompt.titleJa,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(prompt.descriptionJa),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // プレースホルダー用のコントローラーを初期化
          for (final placeholder in prompt.placeholders) {
            if (!_controllers.containsKey(placeholder)) {
              _controllers[placeholder] = TextEditingController(
                text: widget.initialValues?[placeholder] ?? '',
              );
            }
          }
          setState(() {
            _selectedPrompt = prompt;
          });
        },
      ),
    );
  }

  /// プロンプト詳細
  Widget _buildPromptDetail() {
    final prompt = _selectedPrompt!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 戻るボタン
        TextButton.icon(
          onPressed: () {
            setState(() {
              _selectedPrompt = null;
            });
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text('一覧に戻る'),
        ),
        const SizedBox(height: 8),

        // タイトル
        Text(
          prompt.titleJa,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          prompt.descriptionJa,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: GrowColors.drySoil,
              ),
        ),
        const SizedBox(height: 24),

        // 入力フィールド
        if (prompt.placeholders.isNotEmpty) ...[
          _buildSectionTitle('📝 入力してください'),
          const SizedBox(height: 12),
          ...prompt.placeholders.map(_buildInputField),
          const SizedBox(height: 24),
        ],

        // プロンプト表示
        _buildSectionTitle('📋 AIにコピペするプロンプト'),
        const SizedBox(height: 12),
        _buildPromptBox(prompt),
        const SizedBox(height: 24),

        // 使い方
        _buildSectionTitle('💡 使い方'),
        const SizedBox(height: 12),
        _buildUsageSteps(),
        const SizedBox(height: 24),

        // 回答例
        _buildSectionTitle('📖 回答例'),
        const SizedBox(height: 12),
        _buildExampleBox(prompt),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: GrowColors.drySoil,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildInputField(String placeholder) {
    final labels = {
      'location': '場所（例：東京都、横浜市など）',
      'plant': '植物名（例：トマト、キュウリなど）',
      'color': '土の色',
      'texture': '土の手触り',
      'drainage': '水はけ',
      'other': 'その他の特徴',
      'symptoms': '症状の詳細',
      'pest_description': '虫・病斑の特徴',
      'farming_method': '農法',
      'weather': '最近の天候',
      'environment': '環境タイプ',
      'sunlight': '日当たり',
      'wind': '風通し',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _controllers[placeholder],
        decoration: InputDecoration(
          labelText: labels[placeholder] ?? placeholder,
          hintText: _getHint(placeholder),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  String _getHint(String placeholder) {
    final hints = {
      'location': '例：神奈川県横浜市',
      'plant': '例：ミニトマト',
      'color': '例：黒っぽい、茶色など',
      'texture': '例：さらさら、粘土質など',
      'drainage': '例：良い、悪いなど',
      'symptoms': '例：葉が黄色くなってきた',
    };
    return hints[placeholder] ?? '';
  }

  Widget _buildPromptBox(ResearchPrompt prompt) {
    // プレースホルダーを置換したプロンプトを生成
    final values = <String, String>{};
    for (final placeholder in prompt.placeholders) {
      final controller = _controllers[placeholder];
      values[placeholder] = controller?.text.isNotEmpty == true
          ? controller!.text
          : '【${_getHint(placeholder)}】';
    }
    final generatedPrompt = prompt.generatePrompt(locale: 'ja', values: values);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GrowColors.paleGreen.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GrowColors.lifeGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            generatedPrompt,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _copyToClipboard(generatedPrompt),
              icon: const Icon(Icons.copy),
              label: const Text('プロンプトをコピー'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageSteps() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GrowColors.lightSoil),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStep(1, '上の入力欄に必要な情報を入力'),
          _buildStep(2, '「プロンプトをコピー」ボタンをタップ'),
          _buildStep(3, 'お好みのAI（ChatGPT、Claudeなど）を開く'),
          _buildStep(4, 'プロンプトを貼り付けて送信'),
          _buildStep(5, '回答を参考に、アプリで土壌や農法を設定'),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: GrowColors.lifeGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleBox(ResearchPrompt prompt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GrowColors.lightSoil.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.input, size: 16, color: GrowColors.drySoil),
              const SizedBox(width: 8),
              Text(
                '入力例：${prompt.exampleInputJa}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: GrowColors.drySoil,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.output, size: 16, color: GrowColors.deepGreen),
              const SizedBox(width: 8),
              Text(
                'AIの回答例：',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: GrowColors.deepGreen,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            prompt.exampleOutputJa,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('コピーしました！AIに貼り付けてください'),
          ],
        ),
        backgroundColor: GrowColors.lifeGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
