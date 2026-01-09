import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../plant/plant_registration_screen.dart';

/// 植物セクション
///
/// 責務: 登録済み植物のカードを横スクロールで表示
class PlantsSection extends StatelessWidget {
  const PlantsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 実際のデータはリポジトリから取得
    final plants = _getMockPlants();

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
                    '🌱',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'あなたの植物',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              if (plants.isNotEmpty)
                TextButton(
                  onPressed: () {
                    // TODO: 植物一覧画面へ遷移
                  },
                  child: const Text('すべて見る'),
                ),
            ],
          ),
        ),
        if (plants.isEmpty)
          _buildEmptyState(context)
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: plants.length,
              itemBuilder: (context, index) {
                return _PlantCard(plant: plants[index]);
              },
            ),
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
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '🌱',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            '植物を登録しましょう',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '最初の植物を登録して観察を始めましょう',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: GrowColors.drySoil,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlantRegistrationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('植物を登録'),
          ),
        ],
      ),
    );
  }

  List<_PlantData> _getMockPlants() {
    // デモ用のモックデータ
    return [
      _PlantData(
        name: 'ミニトマト',
        variety: 'アイコ',
        daysGrowing: 45,
        location: 'ベランダ',
        farmingMethod: '自然栽培',
      ),
      _PlantData(
        name: 'バジル',
        variety: 'スイートバジル',
        daysGrowing: 12,
        location: 'ベランダ',
        farmingMethod: '自然栽培',
      ),
      _PlantData(
        name: 'きゅうり',
        variety: '夏すずみ',
        daysGrowing: 30,
        location: '畑',
        farmingMethod: '炭素循環農法',
      ),
    ];
  }
}

class _PlantCard extends StatelessWidget {
  final _PlantData plant;

  const _PlantCard({required this.plant});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () {
            // TODO: 植物詳細画面へ遷移
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 写真プレースホルダー
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: GrowColors.paleGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '📷',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 植物名
                Text(
                  plant.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // 品種
                if (plant.variety != null)
                  Text(
                    plant.variety!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: GrowColors.drySoil,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const Spacer(),
                // 日数
                Row(
                  children: [
                    const Text('🌱', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${plant.daysGrowing}日目',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: GrowColors.deepGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantData {
  final String name;
  final String? variety;
  final int daysGrowing;
  final String location;
  final String farmingMethod;

  _PlantData({
    required this.name,
    this.variety,
    required this.daysGrowing,
    required this.location,
    required this.farmingMethod,
  });
}
