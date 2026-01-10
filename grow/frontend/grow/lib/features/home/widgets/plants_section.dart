import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/models/plant.dart';
import '../../../shared/services/plant_repository.dart';
import '../../plant/plant_registration_screen.dart';

/// 植物セクション
///
/// 責務: 登録済み植物のカードを横スクロールで表示
class PlantsSection extends StatefulWidget {
  const PlantsSection({super.key});

  @override
  State<PlantsSection> createState() => _PlantsSectionState();
}

class _PlantsSectionState extends State<PlantsSection> {
  final PlantRepository _repository = PlantRepository();
  List<Plant> _plants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final plants = await _repository.getAll();
      if (mounted) {
        setState(() {
          _plants = plants;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToRegistration() async {
    final result = await Navigator.push<Plant>(
      context,
      MaterialPageRoute(
        builder: (context) => const PlantRegistrationScreen(),
      ),
    );

    // 植物が登録されたら再読み込み
    if (result != null) {
      _loadPlants();
    }
  }

  @override
  Widget build(BuildContext context) {
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
              if (_plants.isNotEmpty)
                TextButton(
                  onPressed: () {
                    // TODO: 植物一覧画面へ遷移
                  },
                  child: const Text('すべて見る'),
                ),
            ],
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_plants.isEmpty)
          _buildEmptyState(context)
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _plants.length + 1, // +1 for add button
              itemBuilder: (context, index) {
                if (index == _plants.length) {
                  return _AddPlantCard(onTap: _navigateToRegistration);
                }
                return _PlantCard(plant: _plants[index]);
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
            onPressed: _navigateToRegistration,
            icon: const Icon(Icons.add),
            label: const Text('植物を登録'),
          ),
        ],
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Plant plant;

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
                  child: plant.latestPhotoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            plant.latestPhotoUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Text(
                            '🌱',
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

/// 植物追加カード
class _AddPlantCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPlantCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: GrowColors.paleGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: GrowColors.deepGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '植物を追加',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: GrowColors.deepGreen,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
