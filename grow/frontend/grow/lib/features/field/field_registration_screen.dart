import 'package:flutter/material.dart';
import '../../shared/theme/colors.dart';
import '../../shared/models/models.dart';
import '../../shared/data/ai_research_prompts.dart';
import '../../shared/services/field_repository.dart';
import '../ai_research/widgets/ai_research_hint.dart';
import '../plant/widgets/farming_method_selector.dart';
import '../plant/widgets/soil_type_selector.dart';
import 'widgets/place_type_selector.dart';

/// 栽培場所登録画面
///
/// 責務: 新しい栽培場所の登録フォームを表示・処理
class FieldRegistrationScreen extends StatefulWidget {
  final Field? existingField;  // 編集時は既存データを渡す

  const FieldRegistrationScreen({super.key, this.existingField});

  @override
  State<FieldRegistrationScreen> createState() => _FieldRegistrationScreenState();
}

class _FieldRegistrationScreenState extends State<FieldRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _soilPhysicalController = TextEditingController();
  final _soilBiologicalController = TextEditingController();
  final _soilChemicalController = TextEditingController();
  final _soilNotesController = TextEditingController();
  final _farmingNotesController = TextEditingController();

  PlaceType _selectedPlaceType = PlaceType.ground;
  FarmingMethod? _selectedFarmingMethod;
  SoilType? _selectedSoilType;

  bool _isLoading = false;
  bool get _isEditing => widget.existingField != null;
  bool get _showFarmingMethod => _selectedPlaceType.requiresFarmingMethod;

  @override
  void initState() {
    super.initState();
    if (widget.existingField != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final field = widget.existingField!;
    _nameController.text = field.name;
    _addressController.text = field.address ?? '';
    _soilPhysicalController.text = field.soilPhysical ?? '';
    _soilBiologicalController.text = field.soilBiological ?? '';
    _soilChemicalController.text = field.soilChemical ?? '';
    _soilNotesController.text = field.soilNotes ?? '';
    _farmingNotesController.text = field.farmingMethodNotes ?? '';
    _selectedPlaceType = field.placeType;
    _selectedFarmingMethod = field.farmingMethod;
    _selectedSoilType = field.soilType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _soilPhysicalController.dispose();
    _soilBiologicalController.dispose();
    _soilChemicalController.dispose();
    _soilNotesController.dispose();
    _farmingNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '栽培場所を編集' : '栽培場所を登録'),
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
            // 説明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GrowColors.paleGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(_selectedPlaceType.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '栽培場所を登録しましょう',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ベランダ、畑、プランターなど\n栽培場所ごとに設定できます',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: GrowColors.deepGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 栽培場所タイプ（必須）
            _buildSectionTitle('栽培場所タイプ', required: true),
            const SizedBox(height: 8),
            PlaceTypeSelector(
              selectedType: _selectedPlaceType,
              onChanged: (type) {
                setState(() {
                  _selectedPlaceType = type;
                  // 畑以外の場合は農法をクリア
                  if (!type.requiresFarmingMethod) {
                    _selectedFarmingMethod = null;
                  } else if (_selectedFarmingMethod == null) {
                    // 畑を選択したらデフォルトの農法を設定
                    _selectedFarmingMethod = FarmingMethod.naturalCultivation;
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            // 栽培場所の名前（必須）
            _buildSectionTitle('名前', required: true),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '例: ${_selectedPlaceType.nameJa}A、メインの${_selectedPlaceType.nameJa}',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '名前を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 場所（任意）
            _buildSectionTitle('場所'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: '例: 神奈川県横浜市、自宅ベランダ',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '場所を入力すると気候データを取得できます',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: GrowColors.drySoil,
              ),
            ),
            const SizedBox(height: 24),

            // 農法セクション（畑の場合のみ表示）
            if (_showFarmingMethod) ...[
              // 区切り線
              const Divider(),
              const SizedBox(height: 16),

              // 農法（必須）
              _buildSectionTitle('農法', required: true),
              const SizedBox(height: 8),
              FarmingMethodSelector(
                selectedMethod: _selectedFarmingMethod ?? FarmingMethod.naturalCultivation,
                onChanged: (method) {
                  setState(() {
                    _selectedFarmingMethod = method;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _farmingNotesController,
                decoration: const InputDecoration(
                  hintText: '農法についてのメモ（任意）',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
            ],

            // 区切り線
            const Divider(),
            const SizedBox(height: 16),

            // 土壌
            _buildSectionTitle('土壌'),
            const SizedBox(height: 8),
            AIResearchHint(
              hintText: 'AIで土壌を調べる',
              category: ResearchCategory.soil,
              initialValues: {
                'location': _addressController.text,
                if (_selectedFarmingMethod != null)
                  'farming_method': _selectedFarmingMethod!.nameJa,
              },
            ),
            const SizedBox(height: 16),

            // 土壌分類
            Text(
              '土壌分類',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SoilTypeSelector(
              selectedSoilType: _selectedSoilType,
              onChanged: (soilType) {
                setState(() {
                  _selectedSoilType = soilType;
                });
              },
            ),
            const SizedBox(height: 16),

            // 土壌3要素
            _buildSoilPropertyInput(
              title: '物理性',
              hint: '土性（砂質/壌土/粘土質）、排水性、団粒構造など',
              controller: _soilPhysicalController,
              emoji: '🪨',
            ),
            const SizedBox(height: 12),
            _buildSoilPropertyInput(
              title: '生物性',
              hint: '微生物、ミミズ、有機物、土の匂いなど',
              controller: _soilBiologicalController,
              emoji: '🐛',
            ),
            const SizedBox(height: 12),
            _buildSoilPropertyInput(
              title: '化学性',
              hint: 'pH、養分、過去の施肥歴など',
              controller: _soilChemicalController,
              emoji: '⚗️',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _soilNotesController,
              decoration: const InputDecoration(
                hintText: 'その他のメモ',
              ),
              maxLines: 2,
            ),
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
                    : Text(_isEditing ? '更新する' : '登録する'),
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

  Widget _buildSoilPropertyInput({
    required String title,
    required String hint,
    required TextEditingController controller,
    required String emoji,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: GrowColors.drySoil,
            ),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final field = Field(
        id: widget.existingField?.id ?? now.millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        placeType: _selectedPlaceType,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        soilType: _selectedSoilType,
        soilPhysical: _soilPhysicalController.text.isNotEmpty ? _soilPhysicalController.text : null,
        soilBiological: _soilBiologicalController.text.isNotEmpty ? _soilBiologicalController.text : null,
        soilChemical: _soilChemicalController.text.isNotEmpty ? _soilChemicalController.text : null,
        soilNotes: _soilNotesController.text.isNotEmpty ? _soilNotesController.text : null,
        farmingMethod: _selectedFarmingMethod,
        farmingMethodNotes: _farmingNotesController.text.isNotEmpty ? _farmingNotesController.text : null,
        createdAt: widget.existingField?.createdAt ?? now,
        updatedAt: now,
      );

      // リポジトリに保存
      final repository = FieldRepository();
      final savedField = await repository.save(field);

      // 成功メッセージを表示して戻る
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? '${savedField.name}を更新しました' : '${savedField.name}を登録しました'),
            backgroundColor: GrowColors.lifeGreen,
          ),
        );
        Navigator.pop(context, savedField);
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
