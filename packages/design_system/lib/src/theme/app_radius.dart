import 'package:flutter/material.dart';

/// Application border radius constants.
abstract final class AppRadius {
  static const Radius xxs = Radius.circular(2);
  static const Radius xs = Radius.circular(4);
  static const Radius sm = Radius.circular(8);
  static const Radius md = Radius.circular(12);
  static const Radius lg = Radius.circular(16);
  static const Radius xl = Radius.circular(20);
  static const Radius xxl = Radius.circular(24);
  static const Radius full = Radius.circular(100);

  static const BorderRadius xxsBorder = BorderRadius.all(xxs);
  static const BorderRadius xsBorder = BorderRadius.all(xs);
  static const BorderRadius smBorder = BorderRadius.all(sm);
  static const BorderRadius mdBorder = BorderRadius.all(md);
  static const BorderRadius lgBorder = BorderRadius.all(lg);
  static const BorderRadius xlBorder = BorderRadius.all(xl);
  static const BorderRadius xxlBorder = BorderRadius.all(xxl);
  static const BorderRadius fullBorder = BorderRadius.all(full);
}
