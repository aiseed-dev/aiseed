import 'package:flutter/material.dart';

/// Grow アプリのカラーパレット
/// デザインコンセプトに基づく土と緑の色彩
class GrowColors {
  GrowColors._();

  // ==================== 土（Earth）- メインカラー ====================

  /// 深い土色 - テキスト、重要要素
  static const Color darkSoil = Color(0xFF3E2723);

  /// 豊かな土色 - ヘッダー、アクセント
  static const Color richSoil = Color(0xFF5D4037);

  /// 乾いた土色 - セカンダリ
  static const Color drySoil = Color(0xFF8D6E63);

  /// 薄い土色 - 背景、境界線
  static const Color lightSoil = Color(0xFFD7CCC8);

  /// とても薄い土色 - 背景
  static const Color paleSoil = Color(0xFFEFEBE9);

  // ==================== 緑（Green）- アクセントカラー ====================

  /// 深い緑 - 成功、成長
  static const Color deepGreen = Color(0xFF2E7D32);

  /// 生命の緑 - ボタン、強調
  static const Color lifeGreen = Color(0xFF4CAF50);

  /// 若葉色 - ホバー、選択
  static const Color youngLeaf = Color(0xFF81C784);

  /// 淡い緑 - 背景アクセント
  static const Color paleGreen = Color(0xFFC8E6C9);

  // ==================== セマンティックカラー ====================

  /// 注意（日焼け、水切れ）
  static const Color warning = Color(0xFFFF8F00);

  /// 問題（病気、害虫）
  static const Color error = Color(0xFFD32F2F);

  /// 水（水やり、雨）
  static const Color water = Color(0xFF1976D2);

  /// 収穫
  static const Color harvest = Color(0xFF7B1FA2);

  // ==================== ダークモード ====================

  /// ダーク背景
  static const Color darkBackground = Color(0xFF121212);

  /// ダークカード
  static const Color darkCard = Color(0xFF1E1E1E);

  /// ダーク入力欄
  static const Color darkInput = Color(0xFF2D2D2D);

  /// ダークテキスト
  static const Color darkText = Color(0xFFE0E0E0);
}

/// ライトテーマ用のColorScheme
ColorScheme get growLightColorScheme => const ColorScheme(
  brightness: Brightness.light,
  primary: GrowColors.lifeGreen,
  onPrimary: Colors.white,
  primaryContainer: GrowColors.paleGreen,
  onPrimaryContainer: GrowColors.deepGreen,
  secondary: GrowColors.richSoil,
  onSecondary: Colors.white,
  secondaryContainer: GrowColors.lightSoil,
  onSecondaryContainer: GrowColors.darkSoil,
  tertiary: GrowColors.water,
  onTertiary: Colors.white,
  error: GrowColors.error,
  onError: Colors.white,
  surface: Colors.white,
  onSurface: GrowColors.darkSoil,
  surfaceContainerHighest: GrowColors.paleSoil,
  outline: GrowColors.lightSoil,
  outlineVariant: GrowColors.paleSoil,
);

/// ダークテーマ用のColorScheme
ColorScheme get growDarkColorScheme => const ColorScheme(
  brightness: Brightness.dark,
  primary: GrowColors.youngLeaf,
  onPrimary: GrowColors.darkSoil,
  primaryContainer: GrowColors.deepGreen,
  onPrimaryContainer: GrowColors.paleGreen,
  secondary: GrowColors.drySoil,
  onSecondary: Colors.white,
  secondaryContainer: GrowColors.richSoil,
  onSecondaryContainer: GrowColors.lightSoil,
  tertiary: GrowColors.water,
  onTertiary: Colors.white,
  error: GrowColors.error,
  onError: Colors.white,
  surface: GrowColors.darkCard,
  onSurface: GrowColors.darkText,
  surfaceContainerHighest: GrowColors.darkInput,
  outline: GrowColors.drySoil,
  outlineVariant: GrowColors.darkInput,
);
