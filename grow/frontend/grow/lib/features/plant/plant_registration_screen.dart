import 'package:flutter/material.dart';
import '../../shared/theme/colors.dart';
import '../../shared/models/models.dart';
import '../../shared/services/plant_repository.dart';
import '../../shared/services/field_repository.dart';
import '../field/field_registration_screen.dart';

/// 植物登録画面
///
/// 責務: 新しい植物の登録フォームを表示・処理
/// 農法・土壌は畑側で設定するため、ここでは植物固有の情報のみ
class PlantRegistrationScreen extends StatefulWidget {
  final Field? preselectedField;  // 畑が事前に選択されている場合

  const PlantRegistrationScreen({super.key, this.preselectedField});

  @override
  State<PlantRegistrationScreen> createState() => _PlantRegistrationScreenState();
}

class _PlantRegistrationScreenState extends State<PlantRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _varietyController = TextEditingController();
  final _notesController = TextEditingController();

  final FieldRepository _fieldRepository = FieldRepository();

  List<Field> _fields = [];
  Field? _selectedField;
  DateTime _plantedAt = DateTime.now();
  bool _isLoading = false;
  bool _isLoadingFields = true;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    setState(() {
      _isLoadingFields = true;
    });

    try {
      final fields = await _fieldRepository.getAll();
      if (mounted) {
        setState(() {
          _fields = fields;
          _selectedField = widget.preselectedField ??
              (fields.isNotEmpty ? fields.first : null);
          _isLoadingFields = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFields = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _varietyController.dispose();
    _notesController.dispose();
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
      body: _isLoadingFields
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 栽培場所が未登録の場合の案内
                  if (_fields.isEmpty) ...[
                    _buildNoFieldsCard(),
                    const SizedBox(height: 24),
                  ] else ...[
                    // 栽培場所選択
                    _buildSectionTitle('栽培場所を選択', required: true),
                    const SizedBox(height: 8),
                    _buildFieldSelector(),
                    const SizedBox(height: 24),
                  ],

                  // 植物名（必須）
                  _buildSectionTitle('植物名', required: true),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: '例: ミニトマト、バジル、きゅうり',
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
                      hintText: '例: アイコ、スイートバジル',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 栽培開始日
                  _buildSectionTitle('栽培開始日'),
                  const SizedBox(height: 8),
                  _buildDateSelector(),
                  const SizedBox(height: 24),

                  // メモ（任意）
                  _buildSectionTitle('メモ'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: '種の購入先、特記事項など',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // 登録ボタン
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading || (_fields.isEmpty && _selectedField == null)
                          ? null
                          : _handleSubmit,
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

  Widget _buildNoFieldsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GrowColors.paleGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GrowColors.youngLeaf),
      ),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'まず栽培場所を登録しましょう',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ベランダ、プランター、畑など\n栽培場所ごとに設定できます。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: GrowColors.deepGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _navigateToFieldRegistration,
            icon: const Icon(Icons.add),
            label: const Text('栽培場所を登録する'),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSelector() {
    return Column(
      children: [
        // 栽培場所選択ドロップダウン
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GrowColors.lightSoil),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Field>(
              value: _selectedField,
              isExpanded: true,
              hint: const Text('栽培場所を選択'),
              items: _fields.map((field) {
                return DropdownMenuItem<Field>(
                  value: field,
                  child: Row(
                    children: [
                      Text(field.placeType.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(field.name),
                            if (field.address != null)
                              Text(
                                field.address!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: GrowColors.drySoil,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Field? newValue) {
                setState(() {
                  _selectedField = newValue;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 新しい栽培場所を追加
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _navigateToFieldRegistration,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('新しい栽培場所を追加'),
          ),
        ),
        // 選択中の栽培場所情報
        if (_selectedField != null) ...[
          const SizedBox(height: 8),
          _buildSelectedFieldInfo(),
        ],
      ],
    );
  }

  Widget _buildSelectedFieldInfo() {
    final field = _selectedField!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GrowColors.paleSoil,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(field.placeType.emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                field.placeType.nameJa,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: GrowColors.deepGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (field.farmingMethod != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Text(field.farmingMethod!.emoji, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  field.farmingMethod!.nameJa,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: GrowColors.deepGreen,
                  ),
                ),
              ],
            ),
          ],
          if (field.soilType != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('🪴', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  field.soilType!.nameJa,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: GrowColors.drySoil,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _navigateToFieldRegistration() async {
    final result = await Navigator.push<Field>(
      context,
      MaterialPageRoute(
        builder: (context) => const FieldRegistrationScreen(),
      ),
    );

    if (result != null) {
      await _loadFields();
      setState(() {
        _selectedField = result;
      });
    }
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

    if (_selectedField == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('栽培場所を選択してください'),
          backgroundColor: GrowColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final plant = Plant(
        id: now.millisecondsSinceEpoch.toString(),
        fieldId: _selectedField!.id,
        name: _nameController.text,
        variety: _varietyController.text.isNotEmpty ? _varietyController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        plantedAt: _plantedAt,
        createdAt: now,
        updatedAt: now,
      );

      // リポジトリに保存
      final repository = PlantRepository();
      final savedPlant = await repository.save(plant);

      // 成功メッセージを表示して戻る
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${savedPlant.name}を登録しました'),
            backgroundColor: GrowColors.lifeGreen,
          ),
        );
        Navigator.pop(context, savedPlant);
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
