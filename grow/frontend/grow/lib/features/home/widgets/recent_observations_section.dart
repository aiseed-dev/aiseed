import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';

/// 最近の観察セクション
///
/// 責務: 最近の観察記録をリスト表示
class RecentObservationsSection extends StatelessWidget {
  const RecentObservationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 実際のデータはリポジトリから取得
    final observations = _getMockObservations();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    '📝',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '最近の観察',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              if (observations.isNotEmpty)
                TextButton(
                  onPressed: () {
                    // TODO: 観察一覧画面へ遷移
                  },
                  child: const Text('すべて見る'),
                ),
            ],
          ),
        ),
        if (observations.isEmpty)
          _buildEmptyState(context)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: observations.length,
            itemBuilder: (context, index) {
              return _ObservationCard(observation: observations[index]);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GrowColors.lightSoil,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '📷',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            '最初の観察を記録しましょう',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '下の📷ボタンをタップして観察を始めましょう',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: GrowColors.drySoil,
            ),
          ),
        ],
      ),
    );
  }

  List<_ObservationData> _getMockObservations() {
    // デモ用のモックデータ
    return [
      _ObservationData(
        plantName: 'ミニトマト',
        note: '葉の色がやや黄色がかっている。水はけが悪いのかもしれない。',
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
        weather: '☀️',
        temperature: 12,
        tags: ['💧水やり', '🌱成長'],
      ),
      _ObservationData(
        plantName: 'バジル',
        note: '新しい葉が出てきた！香りも良い。',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        weather: '⛅',
        temperature: 15,
        tags: ['🌱成長'],
      ),
      _ObservationData(
        plantName: 'きゅうり',
        note: '最初の花が咲いた。蜂が来ていた。',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        weather: '☀️',
        temperature: 18,
        tags: ['🌸開花'],
      ),
    ];
  }
}

class _ObservationCard extends StatelessWidget {
  final _ObservationData observation;

  const _ObservationCard({required this.observation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: 観察詳細画面へ遷移
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー（植物名、日時、天気）
              Row(
                children: [
                  // 写真サムネイル
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: GrowColors.paleGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('📷', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          observation.plantName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatDateTime(observation.dateTime),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: GrowColors.drySoil,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 天気・気温
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        observation.weather,
                        style: const TextStyle(fontSize: 20),
                      ),
                      if (observation.temperature != null)
                        Text(
                          '${observation.temperature}°C',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: GrowColors.drySoil,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 観察メモ
              Text(
                observation.note,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // タグ
              if (observation.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: observation.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: GrowColors.paleGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: GrowColors.deepGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 24) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes}分前';
      }
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

class _ObservationData {
  final String plantName;
  final String note;
  final DateTime dateTime;
  final String weather;
  final int? temperature;
  final List<String> tags;

  _ObservationData({
    required this.plantName,
    required this.note,
    required this.dateTime,
    required this.weather,
    this.temperature,
    this.tags = const [],
  });
}
