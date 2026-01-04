import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Create チャット画面 - Web制作AI対話
class CreateChatScreen extends StatefulWidget {
  const CreateChatScreen({super.key});

  @override
  State<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addAIMessage(
      'こんにちは！🎨\n\n'
      '農家・食品店のWebサイト作成をお手伝いします。\n\n'
      '例えば：\n'
      '• 「野菜の直売所のページを作りたい」\n'
      '• 「パン屋のホームページが欲しい」\n'
      '• 「マルシェ出店用のページを作りたい」\n'
      '• 「QRコードから見れるページが欲しい」\n'
      '• 「Cloudflareへのデプロイ方法を教えて」\n\n'
      'お気軽にご相談ください！',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 Create'),
        backgroundColor: AppColors.spatial.withOpacity(0.1),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.spatial.withOpacity(0.2),
              child: const Text('🎨', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.spatial : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: Text(
                message.text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isUser ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.spatial.withOpacity(0.2),
            child: const Text('🎨', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('...', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'どんなサイトを作りたい？',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _isLoading ? null : _sendMessage,
            icon: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isLoading ? AppColors.divider : AppColors.spatial,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _addAIMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await _callServer(text);
      _addAIMessage(response);
    } catch (e) {
      _addAIMessage(_getOfflineResponse(text));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _callServer(String userMessage) async {
    final history = _messages
        .map(
          (m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text},
        )
        .toList();

    final sessionId = await SessionService.getSessionId();

    final response = await http
        .post(
          Uri.parse(ApiConfig.createConversation),
          headers: {
            'Content-Type': 'application/json',
            'X-Session-ID': sessionId,
          },
          body: jsonEncode({
            'user_message': userMessage,
            'conversation_history': history,
          }),
        )
        .timeout(const Duration(seconds: 60));

    await SessionService.updateFromResponse(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['ai_message'] ?? '続けてお話しください。';
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  String _getOfflineResponse(String userMessage) {
    final lowerMsg = userMessage.toLowerCase();

    // 農家・野菜関連
    if (lowerMsg.contains('農家') || lowerMsg.contains('野菜') || lowerMsg.contains('農園')) {
      return '農家さんのサイトですね！🌾\n\n'
          '素敵です！教えてください：\n\n'
          '1. どんな野菜を育てていますか？\n'
          '2. 直売所や配達はしていますか？\n'
          '3. こだわりのポイントは？（無農薬、有機など）\n\n'
          '「サイトを作る」画面から、フォーム入力でも作成できます！';
    }
    // 直売所
    else if (lowerMsg.contains('直売') || lowerMsg.contains('産直')) {
      return '直売所のサイトですね！🏪\n\n'
          'QRコードから見れるシンプルなページ、いいですね！\n\n'
          '載せたい情報を教えてください：\n'
          '• 場所・アクセス\n'
          '• 営業日・時間\n'
          '• 取扱商品\n'
          '• こだわり・特徴';
    }
    // パン屋
    else if (lowerMsg.contains('パン')) {
      return 'パン屋さんのサイトですね！🍞\n\n'
          '良いですね！教えてください：\n\n'
          '1. お店の名前と場所は？\n'
          '2. おすすめのパンは？\n'
          '3. 営業日・時間は？\n'
          '4. こだわり（国産小麦、天然酵母など）は？';
    }
    // お菓子・スイーツ
    else if (lowerMsg.contains('お菓子') || lowerMsg.contains('スイーツ') || lowerMsg.contains('ケーキ')) {
      return 'お菓子屋さんのサイトですね！🍰\n\n'
          '素敵です！教えてください：\n\n'
          '1. どんなお菓子を作っていますか？\n'
          '2. 店舗はありますか？通販は？\n'
          '3. こだわりのポイントは？';
    }
    // マルシェ
    else if (lowerMsg.contains('マルシェ') || lowerMsg.contains('市場') || lowerMsg.contains('出店')) {
      return 'マルシェ出店用のページですね！🎪\n\n'
          'QRコードを置いて、次回出店情報を案内できますね！\n\n'
          '教えてください：\n'
          '• あなた（お店）の紹介\n'
          '• 主な商品\n'
          '• SNSアカウント\n'
          '• 次回の出店予定';
    }
    // QRコード
    else if (lowerMsg.contains('qr') || lowerMsg.contains('キューアール')) {
      return 'QRコード用のページですね！📱\n\n'
          'QRコードからアクセスしやすいシンプルなページを作れます。\n\n'
          '使い方の例：\n'
          '• 野菜の袋に貼る → 生産者紹介へ\n'
          '• 店頭POPに表示 → お店情報へ\n'
          '• 名刺に印刷 → プロフィールへ\n\n'
          'どんな用途で使いたいですか？';
    }
    // Cloudflare・デプロイ
    else if (lowerMsg.contains('cloudflare') || lowerMsg.contains('デプロイ') || lowerMsg.contains('公開')) {
      return 'Cloudflare Pagesでの公開ですね！☁️\n\n'
          '5分で無料公開できます：\n\n'
          '1. Cloudflareアカウント作成（無料）\n'
          '2. Pages → Create project\n'
          '3. Direct Upload を選択\n'
          '4. HTMLファイルをアップロード\n'
          '5. 完了！ your-site.pages.dev で公開\n\n'
          '詳しくは「Cloudflareで公開」画面をご覧ください！';
    }
    // お店一般
    else if (lowerMsg.contains('お店') || lowerMsg.contains('店舗') || lowerMsg.contains('ホームページ')) {
      return 'お店のホームページですね！🏪\n\n'
          '良いですね！教えてください：\n\n'
          '1. どんなお店ですか？\n'
          '2. 営業時間やアクセス情報は必要？\n'
          '3. メニューや商品一覧は載せたい？\n\n'
          '「サイトを作る」画面から、フォーム入力でも作成できます！';
    }
    // ポートフォリオ
    else if (lowerMsg.contains('ポートフォリオ')) {
      return 'ポートフォリオサイトですね！✨\n\n'
          '素敵です！いくつか質問させてください：\n\n'
          '1. どんなお仕事や作品を載せたいですか？\n'
          '2. シンプル or カラフル どちらがお好み？\n'
          '3. 連絡フォームは必要ですか？';
    }
    // その他
    else {
      return 'なるほど！😊\n\n'
          'もう少し具体的に教えてもらえますか？\n\n'
          '例えば：\n'
          '• 農家・直売所のサイト\n'
          '• パン屋・お菓子屋のサイト\n'
          '• マルシェ出店用のページ\n'
          '• QRコードから見れるページ\n\n'
          'どんなサイトを作りたいですか？';
    }
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
