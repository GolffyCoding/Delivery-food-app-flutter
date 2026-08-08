import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Centralized application theme configuration.
abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true).copyWith(
      textTheme: AppTextStyles.textTheme,
    );

    return base.copyWith(
      colorScheme: AppColors.lightColorScheme,
      scaffoldBackgroundColor: AppColors.neutral50,
      appBarTheme: _appBarTheme(base),
      cardTheme: _cardTheme(base),
      elevatedButtonTheme: _elevatedButtonTheme(base),
      filledButtonTheme: _filledButtonTheme(base),
      outlinedButtonTheme: _outlinedButtonTheme(base),
      textButtonTheme: _textButtonTheme(base),
      inputDecorationTheme: _inputDecorationTheme(base),
      bottomNavigationBarTheme: _bottomNavTheme(base),
      floatingActionButtonTheme: _fabTheme(base),
      chipTheme: _chipTheme(base),
      dividerTheme: _dividerTheme(base),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true).copyWith(
      textTheme: AppTextStyles.textTheme,
    );

    return base.copyWith(
      colorScheme: AppColors.darkColorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: _appBarTheme(base),
      cardTheme: _cardTheme(base),
      elevatedButtonTheme: _elevatedButtonTheme(base),
      filledButtonTheme: _filledButtonTheme(base),
      outlinedButtonTheme: _outlinedButtonTheme(base),
      textButtonTheme: _textButtonTheme(base),
      inputDecorationTheme: _inputDecorationTheme(base),
      bottomNavigationBarTheme: _bottomNavTheme(base),
      floatingActionButtonTheme: _fabTheme(base),
      chipTheme: _chipTheme(base),
      dividerTheme: _dividerTheme(base),
    );
  }

  static AppBarTheme _appBarTheme(ThemeData base) {
    return AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: base.colorScheme.surface,
      foregroundColor: base.colorScheme.onSurface,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: base.colorScheme.onSurface,
      ),
    );
  }

  static CardThemeData _cardTheme(ThemeData base) {
    return CardThemeData(
      elevation: 0,
      color: base.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
        side: BorderSide(color: base.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(ThemeData base) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        backgroundColor: base.colorScheme.primary,
        foregroundColor: base.colorScheme.onPrimary,
        textStyle: base.textTheme.labelLarge,
        padding: AppSpacing.buttonPadding,
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(ThemeData base) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        textStyle: base.textTheme.labelLarge,
        padding: AppSpacing.buttonPadding,
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ThemeData base) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        side: BorderSide(color: base.colorScheme.outline),
        textStyle: base.textTheme.labelLarge,
        padding: AppSpacing.buttonPadding,
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(ThemeData base) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        textStyle: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        padding: AppSpacing.buttonPadding,
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ThemeData base) {
    return InputDecorationTheme(
      filled: true,
      fillColor: base.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      contentPadding: AppSpacing.inputPadding,
      border: OutlineInputBorder(borderRadius: AppRadius.mdBorder, borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdBorder,
        borderSide: BorderSide(color: base.colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdBorder,
        borderSide: BorderSide(color: base.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdBorder,
        borderSide: BorderSide(color: base.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdBorder,
        borderSide: BorderSide(color: base.colorScheme.error, width: 2),
      ),
      hintStyle: base.textTheme.bodyMedium?.copyWith(color: base.colorScheme.outline),
      labelStyle: base.textTheme.bodyMedium?.copyWith(color: base.colorScheme.onSurfaceVariant),
    );
  }

  static BottomNavigationBarThemeData _bottomNavTheme(ThemeData base) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: base.colorScheme.surface,
      selectedItemColor: base.colorScheme.primary,
      unselectedItemColor: base.colorScheme.outline,
      selectedLabelStyle: base.textTheme.labelSmall,
      unselectedLabelStyle: base.textTheme.labelSmall,
      elevation: 8,
    );
  }

  static FloatingActionButtonThemeData _fabTheme(ThemeData base) {
    return FloatingActionButtonThemeData(
      backgroundColor: base.colorScheme.primary,
      foregroundColor: base.colorScheme.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
    );
  }

  static ChipThemeData _chipTheme(ThemeData base) {
    return ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.smBorder),
      labelStyle: base.textTheme.labelMedium,
      backgroundColor: base.colorScheme.surfaceContainerHighest,
    );
  }

  static DividerThemeData _dividerTheme(ThemeData base) {
    return DividerThemeData(color: base.colorScheme.outlineVariant, thickness: 1, space: 1);
  }
}
