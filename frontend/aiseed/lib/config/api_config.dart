import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// API設定
class ApiConfig {
  /// ベースURL
  /// - Web: localhost
  /// - Android エミュレータ: 10.0.2.2
  /// - iOS シミュレータ: localhost
  /// - 実機: 環境変数または固定IP
  static String get baseUrl {
    // 本番環境（リリースビルド）
    const productionUrl = 'https://api.aiseed.dev';

    // 開発環境判定
    const isDebug = bool.fromEnvironment('dart.vm.product') == false;

    if (!isDebug) {
      return productionUrl;
    }

    // 開発環境
    if (kIsWeb) {
      return 'http://localhost:8000';
    }

    // モバイル
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000'; // Android エミュレータ
      }
      if (Platform.isIOS) {
        return 'http://localhost:8000'; // iOS シミュレータ
      }
    } catch (_) {}

    return 'http://localhost:8000';
  }

  /// 各サービスのエンドポイント
  static String get sparkConversation => '$baseUrl/public/conversation';
  static String get growConversation => '$baseUrl/public/conversation';
  static String get learnConversation => '$baseUrl/public/conversation';
  static String get createConversation => '$baseUrl/public/conversation';

  /// 認証付きAPI（v1）
  static String v1Endpoint(String service) => '$baseUrl/v1/$service/conversation';

  /// ヘルスチェック
  static String get health => '$baseUrl/health';
}
