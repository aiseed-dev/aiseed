import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/services/settings_service.dart';
import '../../shared/theme/colors.dart';

/// 設定画面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsService _settings;
  bool _isLoading = true;

  final TextEditingController _serverUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = SettingsService(prefs);
    _serverUrlController.text = _settings.serverUrl;
    setState(() => _isLoading = false);
  }

  Future<void> _setAiMode(AiMode mode) async {
    await _settings.setAiMode(mode);
    setState(() {});
  }

  Future<void> _saveServerUrl() async {
    await _settings.setServerUrl(_serverUrlController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('サーバーURLを保存しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // AI連携セクション
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'AI連携',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: GrowColors.deepGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // 無料版
                RadioListTile<AiMode>(
                  value: AiMode.free,
                  groupValue: _settings.aiMode,
                  onChanged: (value) => _setAiMode(value!),
                  title: const Text('無料版'),
                  subtitle: const Text('プロンプトをコピーして外部AIに貼り付け'),
                  secondary: const Icon(Icons.content_copy),
                ),

                // AI連携版
                RadioListTile<AiMode>(
                  value: AiMode.aiConnected,
                  groupValue: _settings.aiMode,
                  onChanged: (value) => _setAiMode(value!),
                  title: const Text('AI連携'),
                  subtitle: const Text('サーバー経由で自動生成'),
                  secondary: const Icon(Icons.cloud),
                ),

                const Divider(),

                // サーバー設定（AI連携時のみ）
                if (_settings.aiMode == AiMode.aiConnected) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'サーバー設定',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: GrowColors.deepGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _serverUrlController,
                      decoration: InputDecoration(
                        labelText: 'サーバーURL',
                        hintText: 'http://localhost:8000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          onPressed: _saveServerUrl,
                          icon: const Icon(Icons.save),
                          tooltip: '保存',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '内部テスト用のサーバーURLを入力してください',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // バージョン情報
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Grow v1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}
