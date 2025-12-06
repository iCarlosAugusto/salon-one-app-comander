import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Responsive utility class for adaptive layouts
class Responsive {
  Responsive._();

  /// Check if the screen is mobile size
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppConstants.tabletBreakpoint;

  /// Check if the screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.tabletBreakpoint &&
        width < AppConstants.desktopBreakpoint;
  }

  /// Check if the screen is desktop size
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConstants.desktopBreakpoint;

  /// Get the current device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= AppConstants.desktopBreakpoint) {
      return DeviceType.desktop;
    } else if (width >= AppConstants.tabletBreakpoint) {
      return DeviceType.tablet;
    }
    return DeviceType.mobile;
  }

  /// Get responsive value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// Get responsive spacing
  static double spacing(BuildContext context) {
    return value(
      context,
      mobile: AppConstants.spacingSm,
      tablet: AppConstants.spacingMd,
      desktop: AppConstants.spacingLg,
    );
  }

  /// Get responsive padding
  static EdgeInsets padding(BuildContext context) {
    final spacing = Responsive.spacing(context);
    return EdgeInsets.all(spacing);
  }

  /// Get responsive horizontal padding
  static EdgeInsets horizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: value(
        context,
        mobile: AppConstants.spacingMd,
        tablet: AppConstants.spacingLg,
        desktop: AppConstants.spacingXl,
      ),
    );
  }

  /// Get number of grid columns based on screen size
  static int gridColumns(BuildContext context) {
    return value(context, mobile: 1, tablet: 2, desktop: 3);
  }

  /// Get sidebar width
  static double sidebarWidth(BuildContext context) {
    return value(
      context,
      mobile: 0,
      tablet: 72, // Collapsed sidebar
      desktop: 256, // Expanded sidebar
    );
  }
}

/// Device type enum
enum DeviceType { mobile, tablet, desktop }

/// Responsive builder widget for adaptive layouts
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppConstants.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= AppConstants.tabletBreakpoint) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing,
    this.runSpacing,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double? spacing;
  final double? runSpacing;

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.value(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    final gap = spacing ?? Responsive.spacing(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: runSpacing ?? gap,
          children: children.map((child) {
            return SizedBox(width: itemWidth, child: child);
          }).toList(),
        );
      },
    );
  }
}
