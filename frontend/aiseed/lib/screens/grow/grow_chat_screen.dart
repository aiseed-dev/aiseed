import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Grow チャット画面 - 栽培・料理のAI対話
class GrowChatScreen extends StatefulWidget {
  const GrowChatScreen({super.key});

  @override
  State<GrowChatScreen> createState() => _GrowChatScreenState();
}

class _GrowChatScreenState extends State<GrowChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  static const String _serverUrl = 'http://localhost:8000';

  @override
  void initState() {
    super.initState();
    _addAIMessage(
      'こんにちは！🌱\n\n栽培や料理についてお話しましょう。\n\n'
      '何でも聞いてください：\n'
      '• 何を植えたらいい？\n'
      '• この野菜の育て方は？\n'
      '• 収穫したらどう料理する？',
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
        title: const Text('🌱 Grow'),
        backgroundColor: AppColors.naturalistic.withOpacity(0.1),
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
              backgroundColor: AppColors.naturalistic.withOpacity(0.2),
              child: const Text('🌱', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.naturalistic : AppColors.surface,
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
            backgroundColor: AppColors.naturalistic.withOpacity(0.2),
            child: const Text('🌱', style: TextStyle(fontSize: 18)),
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
                hintText: '栽培や料理について質問...',
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
                color: _isLoading ? AppColors.divider : AppColors.naturalistic,
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

    final response = await http
        .post(
          Uri.parse('$_serverUrl/grow/conversation'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_message': userMessage,
            'conversation_history': history,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['ai_message'] ?? '続けてお話しください。';
    } else {
      throw Exception('Server error');
    }
  }

  String _getOfflineResponse(String userMessage) {
    final lowerMsg = userMessage.toLowerCase();

    if (lowerMsg.contains('植え') || lowerMsg.contains('育て')) {
      return '栽培についてですね！🌱\n\n'
          '今の季節だと、葉物野菜が育てやすいですよ。\n'
          'まずは小松菜やほうれん草から始めてみませんか？\n\n'
          '具体的にどんな野菜に興味がありますか？';
    } else if (lowerMsg.contains('料理') || lowerMsg.contains('レシピ')) {
      return '料理についてですね！🍳\n\n'
          'どんな食材で作りたいですか？\n'
          '採れたての野菜があれば、シンプルな調理が一番美味しいですよ。';
    } else {
      return '面白いですね！\n\nもう少し詳しく教えてもらえますか？';
    }
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
