import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/models/plant.dart';

/// 植物選択ウィジェット
///
/// 責務: 観察対象の植物を選択するUIを提供
class PlantSelector extends StatelessWidget {
  final Plant? selectedPlant;
  final ValueChanged<Plant?> onChanged;

  const PlantSelector({
    super.key,
    required this.selectedPlant,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPlantPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GrowColors.lightSoil),
        ),
        child: Row(
          children: [
            if (selectedPlant != null) ...[
              // 選択済みの植物を表示
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: GrowColors.paleGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('🌱', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedPlant!.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (selectedPlant!.variety != null)
                      Text(
                        selectedPlant!.variety!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: GrowColors.drySoil,
                        ),
                      ),
                  ],
                ),
              ),
            ] else ...[
              // 未選択状態
              const Icon(Icons.eco_outlined, color: GrowColors.drySoil, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '植物を選択',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: GrowColors.drySoil,
                  ),
                ),
              ),
            ],
            const Icon(Icons.chevron_right, color: GrowColors.drySoil),
          ],
        ),
      ),
    );
  }

  void _showPlantPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _PlantPickerSheet(
          selectedPlant: selectedPlant,
          scrollController: scrollController,
          onSelected: (plant) {
            onChanged(plant);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class _PlantPickerSheet extends StatelessWidget {
  final Plant? selectedPlant;
  final ScrollController scrollController;
  final ValueChanged<Plant> onSelected;

  const _PlantPickerSheet({
    required this.selectedPlant,
    required this.scrollController,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: 実際のデータはリポジトリから取得
    final plants = _getMockPlants();

    return Container(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '植物を選択',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          if (plants.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🌱', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      '植物がまだ登録されていません',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '先に植物を登録してください',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: GrowColors.drySoil,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: 植物登録画面へ遷移
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('植物を登録'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: plants.length,
                itemBuilder: (context, index) {
                  final plant = plants[index];
                  final isSelected = plant.id == selectedPlant?.id;
                  return ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: GrowColors.paleGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('🌱', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    title: Text(plant.name),
                    subtitle: Text(
                      [
                        if (plant.variety != null) plant.variety!,
                        '${plant.daysGrowing}日目',
                      ].join(' · '),
                      style: TextStyle(
                        color: GrowColors.drySoil,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: GrowColors.lifeGreen)
                        : null,
                    onTap: () => onSelected(plant),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // デモ用のモックデータ
  List<Plant> _getMockPlants() {
    final now = DateTime.now();
    return [
      Plant(
        id: '1',
        name: 'ミニトマト',
        variety: 'アイコ',
        location: 'ベランダ',
        farmingMethod: FarmingMethod.naturalCultivation,
        plantedAt: now.subtract(const Duration(days: 45)),
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now,
      ),
      Plant(
        id: '2',
        name: 'バジル',
        variety: 'スイートバジル',
        location: 'ベランダ',
        farmingMethod: FarmingMethod.naturalCultivation,
        plantedAt: now.subtract(const Duration(days: 12)),
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now,
      ),
      Plant(
        id: '3',
        name: 'きゅうり',
        variety: '夏すずみ',
        location: '畑',
        farmingMethod: FarmingMethod.carbonCyclingFarming,
        plantedAt: now.subtract(const Duration(days: 30)),
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
    ];
  }
}

// plant.dartをインポートするために必要
import '../../../shared/models/farming_method.dart';
