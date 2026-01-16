import 'package:flutter/material.dart';
import '../../shared/models/farming_method.dart';
import '../../shared/data/cultivation_method_details.dart';

/// 栽培方法の詳細説明画面
class CultivationMethodDetailScreen extends StatelessWidget {
  final CultivationMethod method;

  const CultivationMethodDetailScreen({
    super.key,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    final detail = getMethodDetail(method);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${method.emoji} ${method.nameJa}'),
      ),
      body: detail == null
          ? const Center(child: Text('詳細情報がありません'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ヘッダー
                  _buildHeader(context, detail),
                  const SizedBox(height: 24),

                  // 概要
                  _buildSummaryCard(context, detail),
                  const SizedBox(height: 16),

                  // 考え方・哲学
                  _buildSection(
                    context,
                    title: '考え方・哲学',
                    icon: Icons.lightbulb_outline,
                    child: Text(
                      detail.philosophy.trim(),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 基本原則
                  _buildSection(
                    context,
                    title: '基本原則',
                    icon: Icons.rule,
                    child: _buildBulletList(context, detail.keyPrinciples),
                  ),
                  const SizedBox(height: 16),

                  // 実践方法
                  _buildSection(
                    context,
                    title: '実践方法',
                    icon: Icons.agriculture,
                    child: _buildBulletList(context, detail.practices),
                  ),
                  const SizedBox(height: 16),

                  // メリット
                  _buildSection(
                    context,
                    title: 'メリット',
                    icon: Icons.thumb_up_outlined,
                    child: _buildBulletList(
                      context,
                      detail.benefits,
                      bulletColor: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 課題・注意点
                  _buildSection(
                    context,
                    title: '課題・注意点',
                    icon: Icons.warning_outlined,
                    child: _buildBulletList(
                      context,
                      detail.challenges,
                      bulletColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // こんな人におすすめ
                  _buildSection(
                    context,
                    title: 'こんな人におすすめ',
                    icon: Icons.person_outline,
                    child: _buildBulletList(
                      context,
                      detail.suitableFor,
                      bulletColor: Colors.blue,
                    ),
                  ),

                  // 参考文献
                  if (detail.references.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      title: '参考文献・資料',
                      icon: Icons.book_outlined,
                      child: _buildBulletList(
                        context,
                        detail.references,
                        bulletColor: Colors.grey,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, CultivationMethodDetail detail) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 英語名
        Text(
          method.nameEn,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        // 発祥・提唱者
        if (detail.founder != null || detail.origin != null)
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (detail.founder != null)
                _buildInfoChip(
                  context,
                  icon: Icons.person,
                  label: detail.founder!,
                ),
              if (detail.origin != null)
                _buildInfoChip(
                  context,
                  icon: Icons.place,
                  label: detail.origin!,
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    CultivationMethodDetail detail,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Text(
        detail.summary,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildBulletList(
    BuildContext context,
    List<String> items, {
    Color? bulletColor,
  }) {
    final theme = Theme.of(context);
    final color = bulletColor ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
