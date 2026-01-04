import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Cloudflare Pagesデプロイガイド画面
class CloudflareGuideScreen extends StatelessWidget {
  const CloudflareGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloudflareで公開'),
        backgroundColor: AppColors.spatial.withOpacity(0.1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Center(
              child: Column(
                children: [
                  const Text('☁️', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    '5分で無料公開',
                    style: AppTextStyles.headline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cloudflare Pagesを使えば\n無料でWebサイトを公開できます',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // メリット
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.naturalistic.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.naturalistic.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cloudflare Pagesの特徴',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBenefit('💰', '完全無料', '月間無制限のリクエスト'),
                  _buildBenefit('⚡', '高速', '世界中のCDNで配信'),
                  _buildBenefit('🔒', '安全', '自動HTTPS・DDoS対策'),
                  _buildBenefit('🎯', '簡単', 'ドラッグ&ドロップでデプロイ'),
                  _buildBenefit('🌐', 'カスタムドメイン', '独自ドメインも設定可能'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 手順
            Text(
              'デプロイ手順',
              style: AppTextStyles.headline.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 20),

            _buildStep(
              context,
              number: '1',
              title: 'Cloudflareアカウントを作成',
              description: '無料で作成できます。メールアドレスだけでOK。',
              action: 'アカウント作成ページを開く',
              onTap: () => _launchUrl('https://dash.cloudflare.com/sign-up'),
            ),

            _buildStep(
              context,
              number: '2',
              title: 'ダッシュボードにログイン',
              description: '作成したアカウントでログインします。',
              action: 'ダッシュボードを開く',
              onTap: () => _launchUrl('https://dash.cloudflare.com'),
            ),

            _buildStep(
              context,
              number: '3',
              title: 'Pagesを開く',
              description: '左メニューから「Workers & Pages」→「Pages」タブを選択。',
            ),

            _buildStep(
              context,
              number: '4',
              title: 'プロジェクトを作成',
              description: '「Create a project」→「Direct Upload」を選択。\nプロジェクト名を入力します（これがURLの一部になります）。',
            ),

            _buildStep(
              context,
              number: '5',
              title: 'HTMLファイルをアップロード',
              description: '生成したHTMLをテキストエディタで「index.html」として保存。\nそのファイルをドラッグ&ドロップでアップロード。',
            ),

            _buildStep(
              context,
              number: '6',
              title: '公開完了！',
              description: 'デプロイが完了すると、\nhttps://[プロジェクト名].pages.dev\nでアクセスできるようになります。',
              isLast: true,
            ),

            const SizedBox(height: 32),

            // QRコードの活用
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.spatial.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.spatial.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📱', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        'QRコードを作成',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '公開したURLからQRコードを作成できます。',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '無料のQRコード生成サービス:',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQRServiceChip(context, 'QRのススメ'),
                      _buildQRServiceChip(context, 'QRコード作成'),
                      _buildQRServiceChip(context, 'Canva'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ヘルプ
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.help_outline, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        '困ったら',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '「Create」の「AIに相談する」から、\n分からないことを質問できます。',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(String icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
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
        ],
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
    String? action,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
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
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: AppColors.spatial.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (action != null && onTap != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(action),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.spatial,
                  ),
                ),
              ],
              SizedBox(height: isLast ? 0 : 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQRServiceChip(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        name,
        style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
