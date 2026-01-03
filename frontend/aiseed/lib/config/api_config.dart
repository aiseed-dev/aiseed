/// API設定
class ApiConfig {
  /// 本番サーバーURL
  static const String baseUrl = 'https://api.aiseed.dev';

  /// セッション作成エンドポイント
  static String get sessionEndpoint => '$baseUrl/public/session';

  /// 各サービスのエンドポイント（Public API）
  static String get sparkConversation => '$baseUrl/public/conversation';
  static String get growConversation => '$baseUrl/public/conversation';
  static String get createConversation => '$baseUrl/public/conversation';

  /// Spark体験タスクAPI
  static String get experienceStart => '$baseUrl/public/spark/experience/start';
  static String get experienceTasks => '$baseUrl/public/spark/experience/tasks';
  static String experienceTask(String taskId) =>
      '$baseUrl/public/spark/experience/task/$taskId';
  static String get experienceSubmit => '$baseUrl/public/spark/experience/submit';

  /// 認証付きAPI（v1）
  static String v1Endpoint(String service) => '$baseUrl/v1/$service/conversation';

  /// ヘルスチェック
  static String get health => '$baseUrl/health';
}
