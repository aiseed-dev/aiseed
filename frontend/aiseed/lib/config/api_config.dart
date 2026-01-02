/// API設定
class ApiConfig {
  /// 本番サーバーURL
  static const String baseUrl = 'https://api.aiseed.dev';

  /// 各サービスのエンドポイント（Public API）
  static String get sparkConversation => '$baseUrl/public/conversation';
  static String get growConversation => '$baseUrl/public/conversation';
  static String get learnConversation => '$baseUrl/public/conversation';
  static String get createConversation => '$baseUrl/public/conversation';

  /// 認証付きAPI（v1）
  static String v1Endpoint(String service) => '$baseUrl/v1/$service/conversation';

  /// ヘルスチェック
  static String get health => '$baseUrl/health';
}
