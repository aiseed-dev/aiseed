import 'package:shared_preferences/shared_preferences.dart';

/// AI連携モード
enum AiMode {
  /// 無料版: プロンプトコピー方式
  free,
  /// AI連携版: サーバー自動生成
  aiConnected,
}

/// アプリ設定サービス
class SettingsService {
  static const _keyAiMode = 'ai_mode';
  static const _keyServerUrl = 'server_url';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  /// AI連携モードを取得
  AiMode get aiMode {
    final value = _prefs.getString(_keyAiMode);
    if (value == 'aiConnected') {
      return AiMode.aiConnected;
    }
    return AiMode.free;
  }

  /// AI連携モードを設定
  Future<void> setAiMode(AiMode mode) async {
    await _prefs.setString(_keyAiMode, mode.name);
  }

  /// サーバーURLを取得
  String get serverUrl {
    return _prefs.getString(_keyServerUrl) ?? 'http://localhost:8000';
  }

  /// サーバーURLを設定
  Future<void> setServerUrl(String url) async {
    await _prefs.setString(_keyServerUrl, url);
  }

  /// AI連携が有効か
  bool get isAiConnected => aiMode == AiMode.aiConnected;
}
