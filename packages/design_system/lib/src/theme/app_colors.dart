import 'package:flutter/material.dart';

/// Application color palette.
///
/// Re-themed to the "Coupang UI V5" spec (see the design-spec conversation):
/// tokens keep their existing semantic names so every screen that already
/// references AppColors.brandPrimary / .error / .starFilled etc. picks up
/// the new look automatically — no per-screen edits needed.
abstract final class AppColors {
  static const Color brandPrimary = Color(0xFF346AFF); // Cp: blue
  static const Color brandPrimaryLight = Color(0xFF6E92FF);
  static const Color brandPrimaryDark = Color(0xFF1E4FD6);
  static const Color brandSecondary = Color(0xFFFF6B35); // Cp: orange
  static const Color brandSecondaryLight = Color(0xFFFF9868);
  static const Color brandSecondaryDark = Color(0xFFC64A1F);
  static const Color brandAccent = Color(0xFFE8F4FD); // Cp: blueLight

  static const Color success = Color(0xFF34A853); // Cp: green
  static const Color successLight = Color(0xFFE8F5E9); // Cp: greenLight
  static const Color warning = Color(0xFFED6C02);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE02020); // Cp: red
  static const Color errorLight = Color(0xFFFFF0F0); // Cp: redLight
  static const Color info = Color(0xFF3182F6); // Cp: rocketBlue
  static const Color infoLight = Color(0xFFE8F4FD); // Cp: rocketBg

  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5); // Cp: bg
  static const Color neutral200 = Color(0xFFF0F0F0); // Cp: bgGray
  static const Color neutral300 = Color(0xFFE5E5E5); // Cp: border
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF999999); // Cp: textMuted
  static const Color neutral600 = Color(0xFF666666); // Cp: textSub
  static const Color neutral700 = Color(0xFF333333); // Cp: textBody
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF111111); // Cp: textMain

  static const Color starFilled = Color(0xFFFFB800); // Cp: star
  static const Color starEmpty = Color(0xFFE0E0E0);

  static const Color statusPreparing = Color(0xFFFF9800);
  static const Color statusOnTheWay = Color(0xFF2196F3);
  static const Color statusDelivered = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFF44336);

  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: brandPrimary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDCE6FF),
    onPrimaryContainer: Color(0xFF0D2E8C),
    secondary: brandSecondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFDDCC),
    onSecondaryContainer: Color(0xFF7A2E0A),
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
    outline: neutral500,
    outlineVariant: neutral300,
  );

  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: brandPrimaryLight,
    onPrimary: Color(0xFF0D2E8C),
    primaryContainer: Color(0xFF1E4FD6),
    onPrimaryContainer: Color(0xFFDCE6FF),
    secondary: brandSecondaryLight,
    onSecondary: Color(0xFF7A2E0A),
    secondaryContainer: Color(0xFFC64A1F),
    onSecondaryContainer: Color(0xFFFFDDCC),
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
