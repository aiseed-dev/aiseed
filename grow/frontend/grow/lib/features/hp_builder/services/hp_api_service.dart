import 'dart:convert';
import 'package:http/http.dart' as http;

/// HP Builder APIサービス
///
/// サーバーと通信してHTMLを生成する
class HpApiService {
  final String baseUrl;

  HpApiService({required this.baseUrl});

  /// ホームページHTMLを生成
  Future<HpApiResponse> generateHp({
    String? farmName,
    List<String> farmingMethods = const [],
    List<Map<String, dynamic>> plants = const [],
    required String userRequest,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/hp/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'farm_name': farmName,
          'farming_methods': farmingMethods,
          'plants': plants,
          'user_request': userRequest,
        }),
      ).timeout(const Duration(minutes: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HpApiResponse(
          html: data['html'] ?? '',
          success: data['success'] ?? false,
          error: data['error'],
        );
      } else {
        return HpApiResponse(
          html: '',
          success: false,
          error: 'サーバーエラー: ${response.statusCode}',
        );
      }
    } catch (e) {
      return HpApiResponse(
        html: '',
        success: false,
        error: '通信エラー: $e',
      );
    }
  }

  /// ホームページHTMLを修正
  Future<HpApiResponse> modifyHp({
    required String currentHtml,
    required String modificationRequest,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/hp/modify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'current_html': currentHtml,
          'modification_request': modificationRequest,
        }),
      ).timeout(const Duration(minutes: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HpApiResponse(
          html: data['html'] ?? '',
          success: data['success'] ?? false,
          error: data['error'],
        );
      } else {
        return HpApiResponse(
          html: '',
          success: false,
          error: 'サーバーエラー: ${response.statusCode}',
        );
      }
    } catch (e) {
      return HpApiResponse(
        html: '',
        success: false,
        error: '通信エラー: $e',
      );
    }
  }

  /// ヘルスチェック
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// APIレスポンス
class HpApiResponse {
  final String html;
  final bool success;
  final String? error;

  HpApiResponse({
    required this.html,
    required this.success,
    this.error,
  });
}
