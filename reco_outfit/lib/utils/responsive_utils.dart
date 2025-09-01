import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
class ResponsiveUtils {
  /// Screen size breakpoints
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  static const double largeDesktopBreakpoint = 1440;

  ResponsiveUtils(BuildContext context);

  /// Get current device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return DeviceType.smallMobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.mobile;
    } else if (width < desktopBreakpoint) {
      return DeviceType.tablet;
    } else if (width < largeDesktopBreakpoint) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// Check if device is mobile (including small mobile)
  static bool isMobile(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.smallMobile || deviceType == DeviceType.mobile;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if device is desktop or larger
  static bool isDesktop(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop;
  }

  /// Get responsive value based on device type
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.smallMobile:
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }

  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: const EdgeInsets.symmetric(horizontal: 16),
      tablet: const EdgeInsets.symmetric(horizontal: 24),
      desktop: const EdgeInsets.symmetric(horizontal: 32),
    );
  }

  /// Get responsive border radius
  static BorderRadius getResponsiveBorderRadius(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: BorderRadius.circular(12),
      tablet: BorderRadius.circular(16),
      desktop: BorderRadius.circular(20),
    );
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double base,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: base,
      tablet: tablet ?? base * 1.1,
      desktop: desktop ?? tablet ?? base * 1.2,
    );
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 20,
      tablet: 24,
      desktop: 28,
    );
  }

  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 56,
      tablet: 64,
      desktop: 72,
    );
  }

  /// Get number of columns for grid layouts
  static int getGridColumns(BuildContext context, {int? forceColumns}) {
    if (forceColumns != null) return forceColumns;
    
    return getResponsiveValue(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
      largeDesktop: 5,
    );
  }

  /// Get responsive grid spacing
  static double getGridSpacing(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 12,
      tablet: 16,
      desktop: 20,
    );
  }

  /// Get responsive elevation
  static double getResponsiveElevation(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 4,
      tablet: 6,
      desktop: 8,
    );
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 48,
      tablet: 56,
      desktop: 64,
    );
  }

  /// Get responsive card aspect ratio
  static double getCardAspectRatio(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 0.75,
      tablet: 0.8,
      desktop: 0.85,
    );
  }

  /// Get maximum content width for better readability
  static double getMaxContentWidth(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: double.infinity,
      tablet: 600,
      desktop: 800,
      largeDesktop: 1000,
    );
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive bottom navigation bar height
  static double getBottomNavHeight(BuildContext context) {
    final padding = getSafeAreaPadding(context);
    return getResponsiveValue(
      context,
      mobile: 60 + padding.bottom,
      tablet: 70 + padding.bottom,
      desktop: 80 + padding.bottom,
    );
  }
}

/// Device types for responsive design
enum DeviceType {
  smallMobile,  // < 480px
  mobile,       // 480-768px
  tablet,       // 768-1024px
  desktop,      // 1024-1440px
  largeDesktop, // > 1440px
}

/// Responsive widget that adapts based on screen size
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
}

/// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? forceColumns;
  final double? aspectRatio;
  final EdgeInsets? padding;
  final double? spacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.forceColumns,
    this.aspectRatio,
    this.padding,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getGridColumns(context, forceColumns: forceColumns);
    final gridSpacing = spacing ?? ResponsiveUtils.getGridSpacing(context);
    final ratio = aspectRatio ?? ResponsiveUtils.getCardAspectRatio(context);

    return Padding(
      padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: ratio,
          crossAxisSpacing: gridSpacing,
          mainAxisSpacing: gridSpacing,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

/// Responsive container with maximum width
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);

    return Container(
      width: double.infinity,
      padding: responsivePadding,
      child: centerContent
          ? Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            )
          : ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
    );
  }
}
