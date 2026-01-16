import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/plant.dart';
import '../../shared/models/observation.dart';
import '../../shared/models/field.dart';
import '../../shared/services/plant_repository.dart';
import '../../shared/services/observation_repository.dart';
import '../../shared/services/field_repository.dart';
import '../../shared/services/settings_service.dart';
import 'widgets/voice_input_button.dart';
import 'widgets/plant_summary_card.dart';
import 'services/prompt_generator.dart';
import 'services/hp_api_service.dart';
import 'hp_prompt_screen.dart';
import 'hp_preview_screen.dart';

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
  bool _isGenerating = false;

  late SettingsService _settings;
  late HpApiService _apiService;

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
      _settings = SettingsService(prefs);
      _apiService = HpApiService(baseUrl: _settings.serverUrl);

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

  /// 無料版: プロンプトを生成して次の画面へ
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

  /// AI連携版: サーバーでHTML生成
  Future<void> _generateWithAi() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('要望を入力してください')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // 栽培方法を抽出
      final farmingMethods = <String>[];
      for (final field in _fields) {
        if (field.farmingMethod != null) {
          farmingMethods.add(field.farmingMethod!.nameJa);
        }
      }

      // 植物データを変換
      final plantsData = _plants.map((p) => {
        'name': p.name,
        'variety': p.variety,
        'days_growing': p.daysGrowing,
      }).toList();

      final response = await _apiService.generateHp(
        farmName: _farmNameController.text.trim().isNotEmpty
            ? _farmNameController.text.trim()
            : null,
        farmingMethods: farmingMethods,
        plants: plantsData,
        userRequest: _textController.text.trim(),
      );

      setState(() => _isGenerating = false);

      if (response.success && response.html.isNotEmpty) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HpPreviewScreen(
                html: response.html,
                prompt: _textController.text.trim(),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.error ?? '生成に失敗しました')),
          );
        }
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAiConnected = !_isLoading && _settings.isAiConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ホームページ作成'),
        actions: [
          // モード表示
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                avatar: Icon(
                  isAiConnected ? Icons.cloud : Icons.content_copy,
                  size: 16,
                ),
                label: Text(isAiConnected ? 'AI連携' : '無料版'),
                backgroundColor: isAiConnected
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isGenerating
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      Text(
                        'ホームページを生成中...',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '少々お待ちください',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
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

                      // 生成ボタン（モードに応じて変更）
                      if (isAiConnected)
                        FilledButton.icon(
                          onPressed: _isListening ? null : _generateWithAi,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('AIで自動生成'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        )
                      else
                        FilledButton.icon(
                          onPressed: _isListening ? null : _generatePrompt,
                          icon: const Icon(Icons.content_copy),
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
