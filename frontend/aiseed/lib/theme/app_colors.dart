import 'package:flutter/material.dart';

/// Sparkアプリのカラーパレット
class AppColors {
  AppColors._();

  // ===================
  // Primary Colors (Spark Gold)
  // ===================
  static const Color primary = Color(0xFFF59E0B);
  static const Color primaryLight = Color(0xFFFCD34D);
  static const Color primaryDark = Color(0xFFD97706);

  // ===================
  // Secondary Colors (Warm Orange)
  // ===================
  static const Color secondary = Color(0xFFF97316);
  static const Color secondaryLight = Color(0xFFFDBA74);
  static const Color secondaryDark = Color(0xFFEA580C);

  // ===================
  // 8つの知性カラー
  // ===================
  static const Color linguistic = Color(0xFF3B82F6); // 📝 言語的
  static const Color logical = Color(0xFF8B5CF6); // 🔢 論理・数学的
  static const Color spatial = Color(0xFFEC4899); // 🎨 空間的
  static const Color musical = Color(0xFFF59E0B); // 🎵 音楽的
  static const Color bodily = Color(0xFF10B981); // ⚽ 身体・運動的
  static const Color interpersonal = Color(0xFFF97316); // 🤝 対人的
  static const Color intrapersonal = Color(0xFF6366F1); // 🧘 内省的
  static const Color naturalistic = Color(0xFF14B8A6); // 🌿 博物的

  /// 知性IDからカラーを取得
  static Color getIntelligenceColor(String id) {
    switch (id) {
      case 'linguistic':
        return linguistic;
      case 'logical':
        return logical;
      case 'spatial':
        return spatial;
      case 'musical':
        return musical;
      case 'bodily':
        return bodily;
      case 'interpersonal':
        return interpersonal;
      case 'intrapersonal':
        return intrapersonal;
      case 'naturalistic':
        return naturalistic;
      default:
        return primary;
    }
  }

  /// 全知性カラーのリスト（レーダーチャート用）
  static const List<Color> intelligenceColors = [
    linguistic,
    logical,
    spatial,
    musical,
    bodily,
    interpersonal,
    intrapersonal,
    naturalistic,
  ];

  // ===================
  // Neutral Colors
  // ===================
  static const Color background = Color(0xFFFFFBEB); // 暖かみのある白
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFF78716C);
  static const Color divider = Color(0xFFE7E5E4);
  static const Color disabled = Color(0xFFD6D3D1);

  // ===================
  // Semantic Colors
  // ===================
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ===================
  // Gradients
  // ===================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
