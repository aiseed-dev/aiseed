import 'package:flutter/material.dart';
import '../../shared/theme/colors.dart';
import '../../shared/models/models.dart';
import '../../shared/data/ai_research_prompts.dart';
import '../ai_research/widgets/ai_research_hint.dart';
import 'widgets/farming_method_selector.dart';
import 'widgets/soil_type_selector.dart';

/// 植物登録画面
///
/// 責務: 新しい植物の登録フォームを表示・処理
class PlantRegistrationScreen extends StatefulWidget {
  const PlantRegistrationScreen({super.key});

  @override
  State<PlantRegistrationScreen> createState() => _PlantRegistrationScreenState();
}

class _PlantRegistrationScreenState extends State<PlantRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _varietyController = TextEditingController();
  final _locationController = TextEditingController();
  final _soilNotesController = TextEditingController();

  FarmingMethod _selectedFarmingMethod = FarmingMethod.naturalCultivation;
  SoilType? _selectedSoilType;
  DateTime _plantedAt = DateTime.now();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _varietyController.dispose();
    _locationController.dispose();
    _soilNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('植物を登録'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // AIリサーチバナー
            AIResearchBanner(
              title: 'AIで栽培情報を調べる',
              subtitle: '土壌や育て方をAIで調べてみましょう',
              initialValues: {
                'plant': _nameController.text,
                'location': _locationController.text,
              },
            ),
            const SizedBox(height: 24),

            // 植物名（必須）
            _buildSectionTitle('植物名', required: true),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '例: ミニトマト',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '植物名を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 品種（任意）
            _buildSectionTitle('品種'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _varietyController,
              decoration: const InputDecoration(
                hintText: '例: アイコ',
              ),
            ),
            const SizedBox(height: 24),

            // 栽培場所（任意）
            _buildSectionTitle('栽培場所'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: '例: ベランダ、畑、プランター',
              ),
            ),
            const SizedBox(height: 24),

            // 農法（必須）
            _buildSectionTitle('農法', required: true),
            const SizedBox(height: 8),
            FarmingMethodSelector(
              selectedMethod: _selectedFarmingMethod,
              onChanged: (method) {
                setState(() {
                  _selectedFarmingMethod = method;
                });
              },
            ),
            const SizedBox(height: 24),

            // 土壌（任意）
            _buildSectionTitle('土壌'),
            const SizedBox(height: 8),
            AIResearchHint(
              hintText: 'わからない場合はAIで調べる',
              category: ResearchCategory.soil,
              initialValues: {
                'location': _locationController.text,
              },
            ),
            const SizedBox(height: 12),
            SoilTypeSelector(
              selectedSoilType: _selectedSoilType,
              onChanged: (soilType) {
                setState(() {
                  _selectedSoilType = soilType;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _soilNotesController,
              decoration: const InputDecoration(
                hintText: '土壌についてのメモ（任意）',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // 栽培開始日
            _buildSectionTitle('栽培開始日'),
            const SizedBox(height: 8),
            _buildDateSelector(),
            const SizedBox(height: 32),

            // 登録ボタン
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('登録する'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool required = false}) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (required) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: GrowColors.lifeGreen,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '必須',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
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
            const Icon(Icons.calendar_today, color: GrowColors.drySoil),
            const SizedBox(width: 12),
            Text(
              _formatDate(_plantedAt),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: GrowColors.drySoil),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _plantedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ja'),
    );
    if (picked != null) {
      setState(() {
        _plantedAt = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 実際のデータ保存処理
      final now = DateTime.now();
      final plant = Plant(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        variety: _varietyController.text.isNotEmpty ? _varietyController.text : null,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        farmingMethod: _selectedFarmingMethod,
        soilType: _selectedSoilType,
        soilNotes: _soilNotesController.text.isNotEmpty ? _soilNotesController.text : null,
        plantedAt: _plantedAt,
        createdAt: now,
        updatedAt: now,
      );

      // 成功メッセージを表示して戻る
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plant.name}を登録しました'),
            backgroundColor: GrowColors.lifeGreen,
          ),
        );
        Navigator.pop(context, plant);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: GrowColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
