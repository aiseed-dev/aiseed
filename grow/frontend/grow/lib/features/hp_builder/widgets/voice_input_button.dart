import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// 音声入力ボタンウィジェット
///
/// 音声入力をサポートし、認識結果をコールバックで返す。
/// 音声入力が利用できない環境ではボタンを無効化。
class VoiceInputButton extends StatefulWidget {
  final ValueChanged<String> onResult;
  final VoidCallback? onListeningStart;
  final VoidCallback? onListeningStop;
  final String locale;

  const VoiceInputButton({
    super.key,
    required this.onResult,
    this.onListeningStart,
    this.onListeningStop,
    this.locale = 'ja_JP',
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _currentText = '';

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeech();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );
    } catch (e) {
      _isAvailable = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _stopListening();
    }
  }

  void _onError(dynamic error) {
    _stopListening();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('音声認識でエラーが発生しました'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _startListening() async {
    if (!_isAvailable || _isListening) return;

    setState(() {
      _isListening = true;
      _currentText = '';
    });

    _animationController.repeat(reverse: true);
    widget.onListeningStart?.call();

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _currentText = result.recognizedWords;
        });
        if (result.finalResult) {
          widget.onResult(_currentText);
          _stopListening();
        }
      },
      localeId: widget.locale,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _stopListening() {
    if (!_isListening) return;

    _speech.stop();
    _animationController.stop();
    _animationController.reset();

    setState(() {
      _isListening = false;
    });

    widget.onListeningStop?.call();

    // 最終的なテキストがあれば送信
    if (_currentText.isNotEmpty) {
      widget.onResult(_currentText);
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 認識中のテキスト表示
        if (_isListening && _currentText.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentText,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

        // マイクボタン
        ScaleTransition(
          scale: _isListening ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: _isListening
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: FloatingActionButton.large(
              onPressed: _isAvailable ? _toggleListening : null,
              backgroundColor: _isListening
                  ? colorScheme.error
                  : _isAvailable
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                size: 36,
                color: _isAvailable
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ステータステキスト
        Text(
          _isListening
              ? '聞いています...'
              : _isAvailable
                  ? 'タップして話す'
                  : '音声入力を利用できません',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: _isListening
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
