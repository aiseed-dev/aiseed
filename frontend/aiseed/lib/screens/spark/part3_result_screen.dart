import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Part3 結果画面 - 会話から発見した強み
class Part3ResultScreen extends StatelessWidget {
  final Map<String, double> previousScores;
  final List<Map<String, dynamic>> conversationHistory;

  const Part3ResultScreen({
    super.key,
    required this.previousScores,
    required this.conversationHistory,
  });

  @override
  Widget build(BuildContext context) {
    // 会話から強みを分析（簡易版）
    final strengths = _analyzeStrengths();

    return Scaffold(
      appBar: AppBar(
        title: const Text('発見した強み'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ヘッダー
              const Text('✨', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),

              Text('あなたの強み', style: AppTextStyles.headline),
              const SizedBox(height: 8),

              Text(
                '会話から見つかった能力と「らしさ」',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // 能力
              _buildSection('💪 発見した能力', strengths['abilities'] ?? []),

              const SizedBox(height: 24),

              // らしさ
              _buildSection('🌟 あなたらしさ', strengths['personality'] ?? []),

              const SizedBox(height: 40),

              // 完了ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('完了'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              '会話データから分析中...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? '',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (item['evidence'] != null)
                            Text(
                              item['evidence'],
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _analyzeStrengths() {
    // 簡易分析（オフライン用）
    // 実際はサーバーで分析
    final userMessages = conversationHistory
        .where((m) => m['role'] == 'user')
        .map((m) => m['content'] as String)
        .toList();

    List<Map<String, dynamic>> abilities = [];
    List<Map<String, dynamic>> personality = [];

    // キーワード分析（簡易版）
    final allText = userMessages.join(' ');

    if (allText.contains('考え') ||
        allText.contains('思う') ||
        allText.contains('理由')) {
      abilities.add({'name': '論理的思考', 'evidence': '理由を考えて説明する傾向があります'});
    }

    if (allText.contains('相手') ||
        allText.contains('人') ||
        allText.contains('気持ち')) {
      abilities.add({'name': '共感力', 'evidence': '人の気持ちを考える姿勢が見られます'});
    }

    if (allText.contains('解決') ||
        allText.contains('対応') ||
        allText.contains('方法')) {
      abilities.add({'name': '問題解決力', 'evidence': '解決策を考える傾向があります'});
    }

    if (allText.contains('好き') ||
        allText.contains('楽しい') ||
        allText.contains('興味')) {
      personality.add({'name': '好奇心旺盛', 'evidence': '興味関心の幅が広いです'});
    }

    if (allText.contains('大切') ||
        allText.contains('大事') ||
        allText.contains('価値')) {
      personality.add({'name': '価値観が明確', 'evidence': '自分なりの基準を持っています'});
    }

    // デフォルト
    if (abilities.isEmpty) {
      abilities.add({'name': 'コミュニケーション力', 'evidence': '会話を通じて考えを伝えられています'});
    }
    if (personality.isEmpty) {
      personality.add({'name': '誠実さ', 'evidence': '素直に自分の考えを話しています'});
    }

    return {'abilities': abilities, 'personality': personality};
  }
}
