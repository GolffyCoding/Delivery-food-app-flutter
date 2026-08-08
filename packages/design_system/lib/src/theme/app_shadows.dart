import 'package:flutter/material.dart';

/// Application shadow constants.
abstract final class AppShadows {
  static const BoxShadow sm = BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1));
  static const BoxShadow md = BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2));
  static const BoxShadow lg = BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 4));
  static const BoxShadow xl = BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 8));

  static const List<BoxShadow> smList = [sm];
  static const List<BoxShadow> mdList = [md];
  static const List<BoxShadow> lgList = [lg];
  static const List<BoxShadow> xlList = [xl];
}
