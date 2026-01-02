import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'part3_result_screen.dart';

/// Part3 チャット画面 - AIとの自然な対話
class Part3ChatScreen extends StatefulWidget {
  final Map<String, double> previousScores;

  const Part3ChatScreen({super.key, required this.previousScores});

  @override
  State<Part3ChatScreen> createState() => _Part3ChatScreenState();
}

class _Part3ChatScreenState extends State<Part3ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 最初のAIメッセージ
    _addAIMessage(
      'こんにちは！😊\n\nリラックスしてお話しましょう。\n\nまず教えてください、最近どんなことをしていますか？仕事でも趣味でも、なんでも大丈夫です。',
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
        title: const Text('対話で発見'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(context),
        ),
        actions: [
          if (_messages.where((m) => m.isUser).length >= 3)
            TextButton(
              onPressed: _finishConversation,
              child: const Text('結果を見る'),
            ),
        ],
      ),
      body: Column(
        children: [
          // チャット履歴
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
          // 入力エリア
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
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Text('🤖', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isUser ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
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
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Text('🤖', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + index * 200),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(0.3 + 0.4 * value),
            shape: BoxShape.circle,
          ),
        );
      },
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
                hintText: '思ったことを書いてください...',
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
                color: _isLoading ? AppColors.divider : AppColors.primary,
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
      // オフラインモード: シンプルな応答
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

    final response = await http
        .post(
          Uri.parse(ApiConfig.sparkConversation),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_message': userMessage,
            'conversation_history': history,
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['ai_message'] ?? '続けてお話しください。';
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  String _getOfflineResponse(String userMessage) {
    // オフラインフォールバック
    final userMsgCount = _messages.where((m) => m.isUser).length;

    if (userMsgCount == 1) {
      return 'なるほど！それは興味深いですね。\n\nもう少し詳しく教えてもらえますか？どんなところが好きですか？';
    } else if (userMsgCount == 2) {
      return 'いいですね！😊\n\nそういう時、困ったことがあったらどうしますか？';
    } else if (userMsgCount == 3) {
      return '素晴らしい対応ですね。\n\nでは最後に、あなたが一番大切にしていることは何ですか？';
    } else {
      return 'ありがとうございます！\n\nとても参考になりました。「結果を見る」ボタンから、発見した強みを確認できます。';
    }
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('会話を終了しますか？'),
        content: const Text('途中で終了すると、結果が表示されません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('続ける'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }

  void _finishConversation() {
    // 会話履歴を結果画面に渡す
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => Part3ResultScreen(
          previousScores: widget.previousScores,
          conversationHistory: _messages
              .map(
                (m) => {
                  'role': m.isUser ? 'user' : 'assistant',
                  'content': m.text,
                },
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
