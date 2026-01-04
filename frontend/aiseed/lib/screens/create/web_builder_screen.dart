import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'web_preview_screen.dart';

/// Web制作画面 - 農家・食品店向けサイトビルダー
class WebBuilderScreen extends StatefulWidget {
  const WebBuilderScreen({super.key});

  @override
  State<WebBuilderScreen> createState() => _WebBuilderScreenState();
}

class _WebBuilderScreenState extends State<WebBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isGenerating = false;
  String? _generatedHtml;

  // フォームデータ
  final _businessNameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _feature1Controller = TextEditingController();
  final _feature2Controller = TextEditingController();
  final _feature3Controller = TextEditingController();
  final _addressController = TextEditingController();
  final _hoursController = TextEditingController();
  final _contactController = TextEditingController();
  final _instagramController = TextEditingController();
  final _lineController = TextEditingController();

  String _businessType = 'farm'; // farm, bakery, sweets, shop, market

  final List<Map<String, dynamic>> _businessTypes = [
    {'id': 'farm', 'label': '農家・農園', 'icon': '🌾'},
    {'id': 'bakery', 'label': 'パン屋', 'icon': '🍞'},
    {'id': 'sweets', 'label': 'お菓子屋', 'icon': '🍰'},
    {'id': 'shop', 'label': '食品店・直売所', 'icon': '🏪'},
    {'id': 'market', 'label': 'マルシェ出店', 'icon': '🎪'},
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _taglineController.dispose();
    _descriptionController.dispose();
    _feature1Controller.dispose();
    _feature2Controller.dispose();
    _feature3Controller.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    _contactController.dispose();
    _instagramController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Webサイトを作る'),
        backgroundColor: AppColors.spatial.withOpacity(0.1),
      ),
      body: _generatedHtml != null
          ? _buildResultView()
          : _isGenerating
              ? _buildLoadingView()
              : _buildFormView(),
    );
  }

  Widget _buildFormView() {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: _onStepContinue,
      onStepCancel: _onStepCancel,
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: details.onStepContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.spatial,
                ),
                child: Text(_currentStep == 3 ? 'サイトを生成' : '次へ'),
              ),
              if (_currentStep > 0) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('戻る'),
                ),
              ],
            ],
          ),
        );
      },
      steps: [
        // Step 1: 基本情報
        Step(
          title: const Text('お店の情報'),
          subtitle: const Text('名前と業種'),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          content: _buildStep1(),
        ),
        // Step 2: こだわり
        Step(
          title: const Text('こだわり'),
          subtitle: const Text('お客様に伝えたいこと'),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          content: _buildStep2(),
        ),
        // Step 3: アクセス・連絡先
        Step(
          title: const Text('アクセス'),
          subtitle: const Text('場所と連絡先'),
          isActive: _currentStep >= 2,
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          content: _buildStep3(),
        ),
        // Step 4: SNS
        Step(
          title: const Text('SNS'),
          subtitle: const Text('任意'),
          isActive: _currentStep >= 3,
          state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          content: _buildStep4(),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 業種選択
          Text('業種', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _businessTypes.map((type) {
              final isSelected = _businessType == type['id'];
              return ChoiceChip(
                label: Text('${type['icon']} ${type['label']}'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _businessType = type['id']);
                  }
                },
                selectedColor: AppColors.spatial.withOpacity(0.3),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 名前
          TextFormField(
            controller: _businessNameController,
            decoration: const InputDecoration(
              labelText: 'お店・農園の名前 *',
              hintText: '例: ひまわり農園',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.isEmpty == true ? '名前を入力してください' : null,
          ),
          const SizedBox(height: 16),

          // キャッチフレーズ
          TextFormField(
            controller: _taglineController,
            decoration: const InputDecoration(
              labelText: 'キャッチフレーズ',
              hintText: '例: 土と太陽の恵み、あなたの食卓へ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // 説明
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '紹介文',
              hintText: 'お店や農園について簡単に説明してください',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'こだわりを3つ教えてください',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _feature1Controller,
          decoration: const InputDecoration(
            labelText: 'こだわり 1',
            hintText: '例: 無農薬・有機栽培',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.eco),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _feature2Controller,
          decoration: const InputDecoration(
            labelText: 'こだわり 2',
            hintText: '例: 朝採れ新鮮野菜',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.wb_sunny),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _feature3Controller,
          decoration: const InputDecoration(
            labelText: 'こだわり 3',
            hintText: '例: 地域の伝統野菜',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.favorite),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: '住所・場所',
            hintText: '例: 東京都○○区○○1-2-3',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _hoursController,
          decoration: const InputDecoration(
            labelText: '営業日・時間',
            hintText: '例: 土日 9:00-15:00',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.access_time),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _contactController,
          decoration: const InputDecoration(
            labelText: '連絡先',
            hintText: '例: 090-xxxx-xxxx',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SNSがあれば入力してください（任意）',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _instagramController,
          decoration: const InputDecoration(
            labelText: 'Instagram',
            hintText: '@yourname',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.camera_alt),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _lineController,
          decoration: const InputDecoration(
            labelText: 'LINE公式アカウント',
            hintText: '@line-id',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.chat_bubble),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.spatial),
          const SizedBox(height: 24),
          Text(
            'サイトを生成中...',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'AIがあなたのサイトをデザインしています',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Column(
      children: [
        // 成功メッセージ
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: AppColors.naturalistic.withOpacity(0.1),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.naturalistic, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'サイトが完成しました!',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'プレビューで確認してから公開しましょう',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // プレビューボタン
                _buildActionCard(
                  icon: '👀',
                  title: 'プレビュー',
                  description: 'サイトを確認する',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WebPreviewScreen(html: _generatedHtml!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // HTMLコピー
                _buildActionCard(
                  icon: '📋',
                  title: 'HTMLをコピー',
                  description: 'クリップボードにコピー',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _generatedHtml!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('HTMLをコピーしました'),
                        backgroundColor: AppColors.naturalistic,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Cloudflareガイド
                _buildActionCard(
                  icon: '☁️',
                  title: 'Cloudflareで公開',
                  description: '無料でインターネットに公開',
                  onTap: () => _showCloudflareGuide(),
                ),

                const SizedBox(height: 32),

                // やり直し
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _generatedHtml = null;
                      _currentStep = 0;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('最初からやり直す'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _generateWebsite();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _generateWebsite() async {
    setState(() => _isGenerating = true);

    try {
      final prompt = _buildPrompt();
      final html = await _callAI(prompt);
      setState(() {
        _generatedHtml = html;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      // オフライン時はテンプレートを使用
      setState(() {
        _generatedHtml = _generateOfflineTemplate();
      });
    }
  }

  String _buildPrompt() {
    final typeInfo = _businessTypes.firstWhere((t) => t['id'] == _businessType);

    return '''
農家・食品店向けのシンプルなWebサイトを作成してください。

【基本情報】
- 業種: ${typeInfo['label']}
- 名前: ${_businessNameController.text}
- キャッチフレーズ: ${_taglineController.text.isNotEmpty ? _taglineController.text : 'なし'}
- 説明: ${_descriptionController.text.isNotEmpty ? _descriptionController.text : 'なし'}

【こだわり】
1. ${_feature1Controller.text.isNotEmpty ? _feature1Controller.text : '（未入力）'}
2. ${_feature2Controller.text.isNotEmpty ? _feature2Controller.text : '（未入力）'}
3. ${_feature3Controller.text.isNotEmpty ? _feature3Controller.text : '（未入力）'}

【アクセス情報】
- 住所: ${_addressController.text.isNotEmpty ? _addressController.text : '（未入力）'}
- 営業時間: ${_hoursController.text.isNotEmpty ? _hoursController.text : '（未入力）'}
- 連絡先: ${_contactController.text.isNotEmpty ? _contactController.text : '（未入力）'}

【SNS】
- Instagram: ${_instagramController.text.isNotEmpty ? _instagramController.text : 'なし'}
- LINE: ${_lineController.text.isNotEmpty ? _lineController.text : 'なし'}

【要件】
- QRコードからスマホでアクセスすることを想定
- シンプルな1ページサイト
- スマホファーストのレスポンシブデザイン
- 自然を感じる配色（緑、茶、ベージュ）
- 大きめの文字で読みやすく
- 完全なHTMLファイルを出力（CSS込み）
''';
  }

  Future<String> _callAI(String prompt) async {
    final sessionId = await SessionService.getSessionId();

    final response = await http
        .post(
          Uri.parse(ApiConfig.createConversation),
          headers: {
            'Content-Type': 'application/json',
            'X-Session-ID': sessionId,
          },
          body: jsonEncode({
            'user_message': prompt,
            'conversation_history': [],
          }),
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final aiMessage = data['ai_message'] ?? '';

      // HTMLを抽出
      final htmlMatch = RegExp(r'```html\n([\s\S]*?)\n```').firstMatch(aiMessage);
      if (htmlMatch != null) {
        return htmlMatch.group(1)!;
      }

      // HTMLタグがあればそのまま返す
      if (aiMessage.contains('<!DOCTYPE html>') || aiMessage.contains('<html')) {
        return aiMessage;
      }

      throw Exception('HTML not found in response');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  String _generateOfflineTemplate() {
    final typeInfo = _businessTypes.firstWhere((t) => t['id'] == _businessType);
    final icon = typeInfo['icon'];
    final name = _businessNameController.text.isNotEmpty
        ? _businessNameController.text
        : 'サンプル農園';
    final tagline = _taglineController.text.isNotEmpty
        ? _taglineController.text
        : '土と太陽の恵み';

    return '''
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$name</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: linear-gradient(135deg, #f5f0e6 0%, #e8f5e9 100%);
      color: #3e2723;
      line-height: 1.6;
    }
    .hero {
      text-align: center;
      padding: 60px 20px;
      background: linear-gradient(rgba(255,255,255,0.9), rgba(255,255,255,0.7));
    }
    .hero-icon { font-size: 64px; margin-bottom: 16px; }
    .hero h1 { font-size: 2rem; color: #2e7d32; margin-bottom: 8px; }
    .hero p { font-size: 1.1rem; color: #5d4037; }

    section { padding: 40px 20px; max-width: 600px; margin: 0 auto; }
    h2 {
      font-size: 1.3rem;
      color: #2e7d32;
      margin-bottom: 20px;
      padding-bottom: 8px;
      border-bottom: 2px solid #a5d6a7;
    }

    .feature-list { list-style: none; }
    .feature-list li {
      padding: 16px;
      background: white;
      border-radius: 12px;
      margin-bottom: 12px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    }
    .feature-list li::before {
      content: "✓ ";
      color: #4caf50;
      font-weight: bold;
    }

    .info-card {
      background: white;
      border-radius: 16px;
      padding: 24px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.08);
    }
    .info-item {
      display: flex;
      align-items: flex-start;
      margin-bottom: 16px;
    }
    .info-item:last-child { margin-bottom: 0; }
    .info-icon {
      width: 24px;
      margin-right: 12px;
      text-align: center;
    }

    .sns-links {
      display: flex;
      justify-content: center;
      gap: 16px;
      margin-top: 20px;
    }
    .sns-link {
      display: inline-flex;
      align-items: center;
      padding: 12px 24px;
      background: white;
      border-radius: 24px;
      text-decoration: none;
      color: #3e2723;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }

    footer {
      text-align: center;
      padding: 40px 20px;
      color: #8d6e63;
      font-size: 0.9rem;
    }
  </style>
</head>
<body>
  <header class="hero">
    <div class="hero-icon">$icon</div>
    <h1>$name</h1>
    <p>$tagline</p>
  </header>

  <section>
    <h2>こだわり</h2>
    <ul class="feature-list">
      ${_feature1Controller.text.isNotEmpty ? '<li>${_feature1Controller.text}</li>' : ''}
      ${_feature2Controller.text.isNotEmpty ? '<li>${_feature2Controller.text}</li>' : ''}
      ${_feature3Controller.text.isNotEmpty ? '<li>${_feature3Controller.text}</li>' : ''}
    </ul>
  </section>

  <section>
    <h2>アクセス</h2>
    <div class="info-card">
      ${_addressController.text.isNotEmpty ? '''
      <div class="info-item">
        <span class="info-icon">📍</span>
        <span>${_addressController.text}</span>
      </div>
      ''' : ''}
      ${_hoursController.text.isNotEmpty ? '''
      <div class="info-item">
        <span class="info-icon">🕐</span>
        <span>${_hoursController.text}</span>
      </div>
      ''' : ''}
      ${_contactController.text.isNotEmpty ? '''
      <div class="info-item">
        <span class="info-icon">📞</span>
        <span>${_contactController.text}</span>
      </div>
      ''' : ''}
    </div>

    ${_instagramController.text.isNotEmpty || _lineController.text.isNotEmpty ? '''
    <div class="sns-links">
      ${_instagramController.text.isNotEmpty ? '<a href="#" class="sns-link">📷 Instagram</a>' : ''}
      ${_lineController.text.isNotEmpty ? '<a href="#" class="sns-link">💬 LINE</a>' : ''}
    </div>
    ''' : ''}
  </section>

  <footer>
    <p>&copy; $name</p>
  </footer>
</body>
</html>
''';
  }

  void _showCloudflareGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('☁️', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Text(
                    'Cloudflareで公開',
                    style: AppTextStyles.headline,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '5分で無料でインターネットに公開できます',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildGuideStep('1', 'Cloudflareに登録',
                'dash.cloudflare.com にアクセスして無料アカウントを作成'),
              _buildGuideStep('2', 'Pagesを選択',
                '左メニューから「Workers & Pages」→「Pages」'),
              _buildGuideStep('3', 'プロジェクト作成',
                '「Create a project」→「Direct Upload」を選択'),
              _buildGuideStep('4', 'HTMLをアップロード',
                'コピーしたHTMLを index.html として保存し、アップロード'),
              _buildGuideStep('5', '公開完了!',
                'https://your-site.pages.dev でアクセス可能に'),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.naturalistic.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: AppColors.naturalistic),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cloudflare Pagesは完全無料で、高速・安全なホスティングサービスです',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.spatial,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
