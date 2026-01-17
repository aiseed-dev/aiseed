import 'package:flutter/material.dart';
import '../../../shared/models/plant.dart';

/// 植物サマリーカード
///
/// HP作成画面で栽培記録の概要を表示する
class PlantSummaryCard extends StatelessWidget {
  final List<Plant> plants;
  final VoidCallback? onTap;

  const PlantSummaryCard({
    super.key,
    required this.plants,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (plants.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '栽培記録がありません\nまずは植物を登録してください',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.eco,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '栽培記録から読み込み済み',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${plants.length}種類',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: plants.take(6).map((plant) {
                  return Chip(
                    avatar: plant.latestPhotoUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(plant.latestPhotoUrl!),
                          )
                        : null,
                    label: Text(plant.name),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }).toList(),
              ),
              if (plants.length > 6) ...[
                const SizedBox(height: 8),
                Text(
                  '他${plants.length - 6}種類...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
