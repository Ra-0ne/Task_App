import 'package:flutter/material.dart';

/// Breakpoint-aware helpers built on top of [MediaQuery] / [LayoutBuilder].
///
/// Convention used in this app:
///   * < 600   → mobile  (1 column)
///   * 600–899 → tablet  (2 columns)
///   * >= 900  → desktop (3 columns)
enum DeviceType { mobile, tablet, desktop }

class Responsive {
  const Responsive._();

  static DeviceType device(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) return DeviceType.desktop;
    if (width >= 600) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  /// Number of grid columns to use for the tasks list / stat cards.
  static int gridColumns(BuildContext context) {
    switch (device(context)) {
      case DeviceType.desktop:
        return 3;
      case DeviceType.tablet:
        return 2;
      case DeviceType.mobile:
        return 1;
    }
  }

  /// Stat cards row count — fit more on wider screens.
  static int statColumns(BuildContext context) {
    switch (device(context)) {
      case DeviceType.desktop:
        return 4;
      case DeviceType.tablet:
        return 4;
      case DeviceType.mobile:
        return 2;
    }
  }

  /// Max content width — keeps the UI from stretching on huge screens.
  static double maxContentWidth(BuildContext context) {
    switch (device(context)) {
      case DeviceType.desktop:
        return 1100;
      case DeviceType.tablet:
        return 720;
      case DeviceType.mobile:
        return double.infinity;
    }
  }

  /// Horizontal padding around the screen body.
  static double screenPadding(BuildContext context) {
    switch (device(context)) {
      case DeviceType.desktop:
        return 32;
      case DeviceType.tablet:
        return 24;
      case DeviceType.mobile:
        return 16;
    }
  }

  /// True when running on tablet or desktop.
  static bool isWide(BuildContext context) =>
      device(context) != DeviceType.mobile;
}

/// Helper that wraps content in a centered [ConstrainedBox] so the app
/// looks good on tablets, desktop and web.
class CenteredConstrained extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  const CenteredConstrained({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final w = maxWidth ?? Responsive.maxContentWidth(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: w),
        child: child,
      ),
    );
  }
}
