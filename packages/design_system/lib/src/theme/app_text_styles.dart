import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Application text styles.
///
/// Re-themed to the "Coupang UI V5" spec: NotoSansKR, tighter letter
/// spacing, and bolder weights on headings/prices than the previous Inter
/// scale. `titleLarge`/`headlineSmall` map to the spec's h1 (22/w800);
/// `titleMedium` maps to h2 (18/w700); `price`/`discount` below match
/// CpText.price / CpText.discount exactly.
abstract final class AppTextStyles {
  static TextTheme get textTheme => GoogleFonts.notoSansKrTextTheme(_baseTextTheme);

  static const TextTheme _baseTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, letterSpacing: 0),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
    headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0),
  );

  static TextStyle get heading1 => textTheme.headlineLarge!;
  static TextStyle get heading2 => textTheme.headlineMedium!;
  static TextStyle get heading3 => textTheme.headlineSmall!;
  static TextStyle get title => textTheme.titleLarge!;
  static TextStyle get subtitle => textTheme.titleMedium!;
  static TextStyle get body => textTheme.bodyLarge!;
  static TextStyle get bodySmall => textTheme.bodyMedium!;
  static TextStyle get caption => textTheme.bodySmall!;
  static TextStyle get button => textTheme.labelLarge!;
  static TextStyle get label => textTheme.labelMedium!;

  static TextStyle get price => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.neutral900,
        letterSpacing: -0.3,
      );

  static TextStyle get discount => textTheme.labelLarge!.copyWith(
        color: AppColors.error,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get rating => textTheme.labelMedium!.copyWith(color: AppColors.neutral700);
}
