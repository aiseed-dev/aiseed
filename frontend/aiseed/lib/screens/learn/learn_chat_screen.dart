import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Learn チャット画面 - AIと一緒にAIの使い方を学ぶ
class LearnChatScreen extends StatefulWidget {
  const LearnChatScreen({super.key});

  @override
  State<LearnChatScreen> createState() => _LearnChatScreenState();
}

class _LearnChatScreenState extends State<LearnChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addAIMessage(
      'こんにちは！🤖\n\n'
      'AIの使い方を一緒に学びましょう。\n\n'
      '何から始めますか？\n'
      '• AIって何？（基礎から知りたい）\n'
      '• プロンプトの書き方を学びたい\n'
      '• ChatGPTやClaudeの使い分け\n'
      '• 画像生成AIを使ってみたい',
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
        title: const Text('💻 Learn'),
        backgroundColor: AppColors.logical.withOpacity(0.1),
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
              backgroundColor: AppColors.logical.withOpacity(0.2),
              child: const Text('🤖', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.logical : AppColors.surface,
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
            backgroundColor: AppColors.logical.withOpacity(0.2),
            child: const Text('🤖', style: TextStyle(fontSize: 18)),
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
                hintText: 'AIについて質問...',
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
                color: _isLoading ? AppColors.divider : AppColors.logical,
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
          Uri.parse(ApiConfig.learnConversation),
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

    if (lowerMsg.contains('初心者') || lowerMsg.contains('始め') || lowerMsg.contains('基礎')) {
      return 'AI初心者ですね！🤖\n\n'
          'AIは「人工知能」の略で、人間のように考えたり学んだりするコンピュータプログラムです。\n\n'
          '最近話題のChatGPTやClaudeは「大規模言語モデル（LLM）」と呼ばれ、'
          '文章を理解して返答することができます。\n\n'
          '何か具体的に知りたいことはありますか？';
    } else if (lowerMsg.contains('プロンプト')) {
      return 'プロンプトの書き方ですね！✍️\n\n'
          'プロンプトとは、AIへの指示文のことです。\n\n'
          'コツは3つ：\n'
          '1. 具体的に書く\n'
          '2. 役割を与える（「あなたは〇〇の専門家です」）\n'
          '3. 出力形式を指定する\n\n'
          '試しに何か聞いてみますか？';
    } else if (lowerMsg.contains('chatgpt') || lowerMsg.contains('claude')) {
      return 'AIツールの使い分けですね！🔧\n\n'
          '• ChatGPT: 汎用性が高い、プラグイン豊富\n'
          '• Claude: 長文が得意、日本語も自然\n'
          '• Gemini: Google連携が便利\n\n'
          '用途によって使い分けるのがオススメです！';
    } else if (lowerMsg.contains('画像') || lowerMsg.contains('生成')) {
      return '画像生成AIですね！🎨\n\n'
          '代表的なツール：\n'
          '• DALL-E 3: ChatGPTから使える\n'
          '• Midjourney: アート向け、高品質\n'
          '• Stable Diffusion: 無料で使える\n\n'
          'どんな画像を作りたいですか？';
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
