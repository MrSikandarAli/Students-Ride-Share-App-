import 'package:flutter/material.dart';

/// Breakpoints follow common Material guidance:
/// mobile  < 600dp
/// tablet  600–1024dp
/// desktop > 1024dp
enum DeviceType { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static DeviceType deviceTypeOf(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= tabletBreakpoint) return DeviceType.desktop;
    if (width >= mobileBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isMobile(BuildContext context) =>
      deviceTypeOf(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      deviceTypeOf(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      deviceTypeOf(context) == DeviceType.desktop;

  /// Returns a value scaled to the current device type. Useful for
  /// font sizes, paddings, and spacing that should grow gently on
  /// larger screens instead of just stretching.
  static T value<T>(
      BuildContext context, {
        required T mobile,
        T? tablet,
        T? desktop,
      }) {
    switch (deviceTypeOf(context)) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// Clamps content width on large screens so text/forms/cards don't
  /// stretch edge-to-edge on tablets or the web.
  static double maxContentWidth(BuildContext context) {
    return value<double>(context, mobile: double.infinity, tablet: 640, desktop: 960);
  }

  /// Number of columns for grid-based layouts (e.g. ride list, profile stats).
  static int gridColumns(BuildContext context) {
    return value<int>(context, mobile: 1, tablet: 2, desktop: 3);
  }

  /// Standard horizontal page padding that widens slightly on bigger screens.
  static EdgeInsets pagePadding(BuildContext context) {
    final horizontal = value<double>(context, mobile: 16, tablet: 32, desktop: 64);
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: 16);
  }
}

/// Wraps a child in a centered, width-constrained container so pages
/// look correct on phones, tablets, and desktop/web without duplicating
/// layout logic in every screen.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ResponsiveCenter({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
        child: Padding(
          padding: padding ?? Responsive.pagePadding(context),
          child: child,
        ),
      ),
    );
  }
}

/// Builds a different widget tree per device type. Falls back to
/// [mobile] for tablet/desktop when those builders aren't supplied.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final type = Responsive.deviceTypeOf(context);
    switch (type) {
      case DeviceType.desktop:
        return (desktop ?? tablet ?? mobile)(context);
      case DeviceType.tablet:
        return (tablet ?? mobile)(context);
      case DeviceType.mobile:
        return mobile(context);
    }
  }
}
