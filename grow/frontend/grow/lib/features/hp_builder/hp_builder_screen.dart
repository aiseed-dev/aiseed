import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/plant.dart';
import '../../shared/models/observation.dart';
import '../../shared/models/field.dart';
import '../../shared/services/plant_repository.dart';
import '../../shared/services/observation_repository.dart';
import '../../shared/services/field_repository.dart';
import 'widgets/voice_input_button.dart';
import 'widgets/plant_summary_card.dart';
import 'services/prompt_generator.dart';
import 'hp_prompt_screen.dart';

/// ホームページ作成画面
///
/// 音声またはテキストで指示を入力し、プロンプトを生成する
class HpBuilderScreen extends StatefulWidget {
  const HpBuilderScreen({super.key});

  @override
  State<HpBuilderScreen> createState() => _HpBuilderScreenState();
}

class _HpBuilderScreenState extends State<HpBuilderScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _farmNameController = TextEditingController();

  List<Plant> _plants = [];
  List<Observation> _observations = [];
  List<Field> _fields = [];
  bool _isLoading = true;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _textController.dispose();
    _farmNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final plantRepo = PlantRepository(prefs);
      final observationRepo = ObservationRepository(prefs);
      final fieldRepo = FieldRepository(prefs);

      final plants = await plantRepo.getAll();
      final observations = await observationRepo.getAll();
      final fields = await fieldRepo.getAll();

      // 観察記録に植物名を付与
      final plantsMap = {for (var p in plants) p.id: p};
      final observationsWithNames = observations.map((obs) {
        final plant = plantsMap[obs.plantId];
        return obs.copyWith(plantName: plant?.name);
      }).toList();

      setState(() {
        _plants = plants;
        _observations = observationsWithNames;
        _fields = fields;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('データの読み込みに失敗しました: $e')),
        );
      }
    }
  }

  void _onVoiceResult(String text) {
    setState(() {
      // 既存のテキストに追加
      if (_textController.text.isNotEmpty) {
        _textController.text = '${_textController.text}\n$text';
      } else {
        _textController.text = text;
      }
    });
  }

  void _generatePrompt() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('要望を入力してください')),
      );
      return;
    }

    final prompt = HpPromptGenerator.generate(
      plants: _plants,
      observations: _observations,
      fields: _fields,
      userRequest: _textController.text.trim(),
      farmName: _farmNameController.text.trim().isNotEmpty
          ? _farmNameController.text.trim()
          : null,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HpPromptScreen(prompt: prompt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ホームページ作成'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 栽培記録サマリー
                  PlantSummaryCard(plants: _plants),

                  const SizedBox(height: 24),

                  // 農園名入力
                  TextField(
                    controller: _farmNameController,
                    decoration: InputDecoration(
                      labelText: '農園名（任意）',
                      hintText: '例: 山田農園',
                      prefixIcon: const Icon(Icons.store),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 指示入力セクション
                  Text(
                    'どんなホームページにしますか？',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '音声またはテキストで要望を入力してください',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // テキスト入力
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          '例:\n・シンプルでおしゃれなデザイン\n・イタリア野菜をメインに\n・自然栽培のこだわりを伝えたい',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLowest,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 音声入力ボタン
                  Center(
                    child: VoiceInputButton(
                      onResult: _onVoiceResult,
                      onListeningStart: () => setState(() => _isListening = true),
                      onListeningStop: () => setState(() => _isListening = false),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // プロンプト生成ボタン
                  FilledButton.icon(
                    onPressed: _isListening ? null : _generatePrompt,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('プロンプトを生成'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ヒント
                  Card(
                    color: colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ヒント',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '音声入力の例:\n'
                            '「イタリア風のおしゃれなデザインで」\n'
                            '「トマトとズッキーニをメインに」\n'
                            '「自然栽培のこだわりを伝えたい」\n'
                            '「シンプルで読みやすいページに」',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
