import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

/// Grow アプリのテーマ設定
class GrowTheme {
  GrowTheme._();

  /// ライトテーマ
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: growLightColorScheme,
    textTheme: GrowTypography.lightTextTheme,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: GrowColors.darkSoil,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: GrowColors.darkSoil,
      ),
    ),

    // Scaffold
    scaffoldBackgroundColor: GrowColors.paleSoil,

    // Card
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: GrowColors.darkSoil.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: GrowColors.lifeGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: GrowColors.lifeGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // OutlinedButton
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: GrowColors.lifeGreen,
        side: const BorderSide(color: GrowColors.lifeGreen),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // FloatingActionButton（撮影ボタン）
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: GrowColors.lifeGreen,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
      sizeConstraints: BoxConstraints.tightFor(width: 64, height: 64),
    ),

    // InputDecoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: GrowColors.lightSoil),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: GrowColors.lightSoil),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: GrowColors.lifeGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: GrowColors.error),
      ),
      hintStyle: const TextStyle(
        color: GrowColors.drySoil,
        fontSize: 14,
      ),
    ),

    // BottomNavigationBar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: GrowColors.lifeGreen,
      unselectedItemColor: GrowColors.drySoil,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Chip（タグ用）
    chipTheme: ChipThemeData(
      backgroundColor: GrowColors.paleGreen,
      labelStyle: const TextStyle(
        color: GrowColors.deepGreen,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: GrowColors.lightSoil,
      thickness: 1,
      space: 1,
    ),

    // ListTile
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  /// ダークテーマ
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: growDarkColorScheme,
    textTheme: GrowTypography.darkTextTheme,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: GrowColors.darkCard,
      foregroundColor: GrowColors.darkText,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: GrowColors.darkText,
      ),
    ),

    // Scaffold
    scaffoldBackgroundColor: GrowColors.darkBackground,

    // Card
    cardTheme: CardThemeData(
      color: GrowColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: GrowColors.youngLeaf,
        foregroundColor: GrowColors.darkSoil,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: GrowColors.youngLeaf,
      foregroundColor: GrowColors.darkSoil,
      elevation: 4,
      shape: CircleBorder(),
      sizeConstraints: BoxConstraints.tightFor(width: 64, height: 64),
    ),

    // InputDecoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GrowColors.darkInput,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: GrowColors.youngLeaf, width: 2),
      ),
      hintStyle: const TextStyle(
        color: GrowColors.drySoil,
        fontSize: 14,
      ),
    ),

    // BottomNavigationBar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: GrowColors.darkCard,
      selectedItemColor: GrowColors.youngLeaf,
      unselectedItemColor: GrowColors.drySoil,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: GrowColors.deepGreen.withValues(alpha: 0.3),
      labelStyle: const TextStyle(
        color: GrowColors.youngLeaf,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: GrowColors.darkInput,
      thickness: 1,
      space: 1,
    ),
  );
}
