import 'package:flutter/material.dart';

/// 間距 token（design D4）。不隨主題變，所以是常數而非 ThemeExtension。
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// 插畫尺寸 token，讓空狀態在各頁保持一致。
abstract final class AppIllustrationSize {
  static const double emptyState = 192;
  static const double splash = 220;
}

/// 圓角 token。
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;

  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(lg),
  );
  static const BorderRadius field = BorderRadius.all(Radius.circular(md));
}

/// 動畫時長與曲線。
abstract final class AppDurations {
  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration long = Duration(milliseconds: 400);
  static const Curve curve = Curves.easeOutCubic;
}
