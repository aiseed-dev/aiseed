import 'package:flutter/material.dart';
import 'colors.dart';

/// Grow アプリのタイポグラフィ
/// Noto Sans JP / Noto Sans をベースに
class GrowTypography {
  GrowTypography._();

  /// ライトテーマ用のTextTheme
  static TextTheme get lightTextTheme => const TextTheme(
    // 見出し1 - 植物名、画面タイトル
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: GrowColors.darkSoil,
      letterSpacing: 0,
    ),
    // 見出し2 - セクション
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: GrowColors.darkSoil,
      letterSpacing: 0,
    ),
    // 見出し3
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: GrowColors.darkSoil,
      letterSpacing: 0,
    ),
    // タイトル（カード内など）
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: GrowColors.darkSoil,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: GrowColors.darkSoil,
      letterSpacing: 0,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: GrowColors.darkSoil,
      letterSpacing: 0,
    ),
    // 本文 - 観察メモ
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: GrowColors.darkSoil,
      height: 1.6,
      letterSpacing: 0,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: GrowColors.darkSoil,
      height: 1.5,
      letterSpacing: 0,
    ),
    // 補助 - 日付、ラベル
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: GrowColors.drySoil,
      letterSpacing: 0,
    ),
    // ラベル（ボタンなど）
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: GrowColors.darkSoil,
      letterSpacing: 0,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: GrowColors.darkSoil,
      letterSpacing: 0,
    ),
    // 注釈 - ヒント、注意書き
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: GrowColors.drySoil,
      letterSpacing: 0,
    ),
  );

  /// ダークテーマ用のTextTheme
  static TextTheme get darkTextTheme => const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: GrowColors.darkText,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: GrowColors.darkText,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: GrowColors.darkText,
      letterSpacing: 0,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: GrowColors.darkText,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: GrowColors.darkText,
      letterSpacing: 0,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: GrowColors.darkText,
      letterSpacing: 0,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: GrowColors.darkText,
      height: 1.6,
      letterSpacing: 0,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: GrowColors.darkText,
      height: 1.5,
      letterSpacing: 0,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: GrowColors.drySoil,
      letterSpacing: 0,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: GrowColors.darkText,
      letterSpacing: 0,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: GrowColors.darkText,
      letterSpacing: 0,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: GrowColors.drySoil,
      letterSpacing: 0,
    ),
  );
}
