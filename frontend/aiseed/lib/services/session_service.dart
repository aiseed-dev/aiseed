import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// セッション管理サービス
class SessionService {
  static const String _sessionIdKey = 'aiseed_session_id';
  static const String _sessionExpiryKey = 'aiseed_session_expiry';

  static String? _sessionId;
  static DateTime? _sessionExpiry;

  /// セッションIDを取得（なければ作成）
  static Future<String> getSessionId() async {
    // メモリにあればそれを返す
    if (_sessionId != null && _sessionExpiry != null) {
      if (DateTime.now().isBefore(_sessionExpiry!)) {
        return _sessionId!;
      }
    }

    // ストレージから読み込み
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString(_sessionIdKey);
    final storedExpiry = prefs.getInt(_sessionExpiryKey);

    if (storedId != null && storedExpiry != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(storedExpiry);
      if (DateTime.now().isBefore(expiry)) {
        _sessionId = storedId;
        _sessionExpiry = expiry;
        return storedId;
      }
    }

    // 新規セッション作成
    return await _createNewSession();
  }

  /// 新規セッション作成
  static Future<String> _createNewSession() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.sessionEndpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sessionId = data['session_id'] as String;
        final expiresIn = data['expires_in'] as int? ?? 86400;

        // 保存
        await _saveSession(sessionId, expiresIn);
        return sessionId;
      }
    } catch (e) {
      // サーバーに接続できない場合はローカルIDを生成
    }

    // フォールバック: ローカルセッションID
    final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    await _saveSession(localId, 86400);
    return localId;
  }

  /// セッション保存
  static Future<void> _saveSession(String sessionId, int expiresIn) async {
    final expiry = DateTime.now().add(Duration(seconds: expiresIn));

    _sessionId = sessionId;
    _sessionExpiry = expiry;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionIdKey, sessionId);
    await prefs.setInt(_sessionExpiryKey, expiry.millisecondsSinceEpoch);
  }

  /// レスポンスからセッションIDを更新
  static Future<void> updateFromResponse(http.Response response) async {
    final newSessionId = response.headers['x-session-id'];
    if (newSessionId != null && newSessionId != _sessionId) {
      await _saveSession(newSessionId, 86400);
    }
  }

  /// セッションクリア
  static Future<void> clearSession() async {
    _sessionId = null;
    _sessionExpiry = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionIdKey);
    await prefs.remove(_sessionExpiryKey);
  }
}
