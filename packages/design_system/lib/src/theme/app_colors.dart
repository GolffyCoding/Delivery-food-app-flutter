import 'package:flutter/material.dart';

/// Application color palette based on Material 3.
abstract final class AppColors {
  static const Color brandPrimary = Color(0xFF1B6B4A);
  static const Color brandPrimaryLight = Color(0xFF4E9D7C);
  static const Color brandPrimaryDark = Color(0xFF004D34);
  static const Color brandSecondary = Color(0xFFFF8C42);
  static const Color brandSecondaryLight = Color(0xFFFFB87A);
  static const Color brandSecondaryDark = Color(0xFFC65D00);
  static const Color brandAccent = Color(0xFFE8F5E9);

  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFED6C02);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFFE1F5FE);

  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  static const Color starFilled = Color(0xFFFFC107);
  static const Color starEmpty = Color(0xFFE0E0E0);

  static const Color statusPreparing = Color(0xFFFF9800);
  static const Color statusOnTheWay = Color(0xFF2196F3);
  static const Color statusDelivered = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFF44336);

  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: brandPrimary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFA5D6B5),
    onPrimaryContainer: Color(0xFF003D22),
    secondary: brandSecondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFDDB5),
    onSecondaryContainer: Color(0xFF5C3D00),
    tertiary: Color(0xFF4A6572),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFCCE4F0),
    onTertiaryContainer: Color(0xFF051F27),
    error: error,
    onError: Colors.white,
    errorContainer: errorLight,
    onErrorContainer: Color(0xFF8C1D18),
    surface: Colors.white,
    onSurface: neutral900,
    surfaceContainerHighest: neutral100,
    outline: neutral400,
    outlineVariant: neutral300,
  );

  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: brandPrimaryLight,
    onPrimary: Color(0xFF003D22),
    primaryContainer: Color(0xFF005234),
    onPrimaryContainer: Color(0xFFA5D6B5),
    secondary: brandSecondaryLight,
    onSecondary: Color(0xFF5C3D00),
    secondaryContainer: Color(0xFF8B4500),
    onSecondaryContainer: Color(0xFFFFDDB5),
    tertiary: Color(0xFFB1CCE0),
    onTertiary: Color(0xFF1A3440),
    tertiaryContainer: Color(0xFF334B58),
    onTertiaryContainer: Color(0xFFCCE4F0),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE6E1E5),
    surfaceContainerHighest: Color(0xFF2C2C2C),
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF4A464F),
  );
}
