import 'package:flutter/material.dart';
import '../../shared/theme/colors.dart';
import '../../shared/models/models.dart';
import 'widgets/weather_selector.dart';
import 'widgets/plant_selector.dart';
import 'widgets/photo_picker.dart';

/// 観察記録画面
///
/// 責務: 観察記録の入力フォームを表示・処理
class ObservationRecordingScreen extends StatefulWidget {
  /// 事前選択された植物（ホーム画面から遷移時）
  final Plant? selectedPlant;

  /// 事前選択された写真パス（カメラ/ギャラリーから）
  final String? initialPhotoPath;

  const ObservationRecordingScreen({
    super.key,
    this.selectedPlant,
    this.initialPhotoPath,
  });

  @override
  State<ObservationRecordingScreen> createState() =>
      _ObservationRecordingScreenState();
}

class _ObservationRecordingScreenState
    extends State<ObservationRecordingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _temperatureController = TextEditingController();

  Plant? _selectedPlant;
  List<String> _photoPaths = [];
  Weather? _selectedWeather;
  bool _watered = false;
  DateTime _observedAt = DateTime.now();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPlant = widget.selectedPlant;
    if (widget.initialPhotoPath != null) {
      _photoPaths = [widget.initialPhotoPath!];
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('観察を記録'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSubmit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('記録'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 写真セクション
            PhotoPicker(
              photoPaths: _photoPaths,
              onPhotosChanged: (paths) {
                setState(() {
                  _photoPaths = paths;
                });
              },
            ),
            const SizedBox(height: 24),

            // 植物選択
            _buildSectionTitle('観察する植物', required: true),
            const SizedBox(height: 8),
            PlantSelector(
              selectedPlant: _selectedPlant,
              onChanged: (plant) {
                setState(() {
                  _selectedPlant = plant;
                });
              },
            ),
            const SizedBox(height: 24),

            // 観察メモ
            _buildSectionTitle('何が起きていますか？'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: '葉の色、成長の様子、気づいたことなど',
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            // 天気
            _buildSectionTitle('天気'),
            const SizedBox(height: 8),
            WeatherSelector(
              selectedWeather: _selectedWeather,
              onChanged: (weather) {
                setState(() {
                  _selectedWeather = weather;
                });
              },
            ),
            const SizedBox(height: 16),

            // 気温
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('気温'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _temperatureController,
                        decoration: const InputDecoration(
                          hintText: '例: 25',
                          suffixText: '°C',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('水やり'),
                      const SizedBox(height: 8),
                      _buildWateringToggle(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 観察日時
            _buildSectionTitle('観察日時'),
            const SizedBox(height: 8),
            _buildDateTimeSelector(),
            const SizedBox(height: 32),

            // 記録ボタン
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
                    : const Text('記録する'),
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

  Widget _buildWateringToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GrowColors.lightSoil),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _watered = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: !_watered ? GrowColors.paleGreen : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(11),
                  ),
                ),
                child: Center(
                  child: Text(
                    'なし',
                    style: TextStyle(
                      color: !_watered ? GrowColors.deepGreen : GrowColors.drySoil,
                      fontWeight: !_watered ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _watered = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _watered ? GrowColors.water : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(11),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '💧',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'あり',
                        style: TextStyle(
                          color: _watered ? Colors.white : GrowColors.drySoil,
                          fontWeight: _watered ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    return InkWell(
      onTap: _selectDateTime,
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
            const Icon(Icons.access_time, color: GrowColors.drySoil),
            const SizedBox(width: 12),
            Text(
              _formatDateTime(_observedAt),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: GrowColors.drySoil),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final isToday = dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;

    if (isToday) {
      return '今日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _observedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ja'),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_observedAt),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _observedAt = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedPlant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('観察する植物を選択してください'),
          backgroundColor: GrowColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 実際のデータ保存処理
      final now = DateTime.now();
      final observation = Observation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        plantId: _selectedPlant!.id,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        photoUrls: _photoPaths,
        weather: _selectedWeather,
        temperature: _temperatureController.text.isNotEmpty
            ? double.tryParse(_temperatureController.text)
            : null,
        watered: _watered,
        observedAt: _observedAt,
        createdAt: now,
        updatedAt: now,
        plantName: _selectedPlant!.name,
      );

      // 成功メッセージを表示して戻る
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedPlant!.name}の観察を記録しました'),
            backgroundColor: GrowColors.lifeGreen,
          ),
        );
        Navigator.pop(context, observation);
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
