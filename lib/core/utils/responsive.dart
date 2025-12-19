import 'package:flutter/material.dart';
import '../config/responsive_config.dart';

// ============================================
// Enums for Size Types
// ============================================

/// Icon size presets
enum IconSize {
  small,
  medium,
  large,
  extraLarge,
}

/// Font size presets
enum FontSize {
  small,
  body,
  medium,
  large,
  extraLarge,
  display,
}

/// Spacing size presets
enum SpacingSize {
  xs,
  small,
  medium,
  large,
  xl,
  xxl,
}

/// Button size presets
enum ButtonSize {
  small,
  medium,
  large,
}

/// Border radius size presets
enum BorderRadiusSize {
  small,
  medium,
  large,
}

/// Responsive design utility class
/// Provides adaptive spacing, sizing, and layout helpers for mobile and desktop
/// Uses centralized configuration from ResponsiveConfig for consistency
/// Dynamically adapts based on live screen dimensions from MediaQuery
class Responsive {
  /// Breakpoints for different screen sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Get MediaQuery instance for live screen dimensions
  static MediaQueryData _mediaQuery(BuildContext context) {
    return MediaQuery.of(context);
  }

  /// Get live screen width from MediaQuery
  static double screenWidth(BuildContext context) {
    return _mediaQuery(context).size.width;
  }

  /// Get live screen height from MediaQuery
  static double screenHeight(BuildContext context) {
    return _mediaQuery(context).size.height;
  }

  /// Get screen size (width x height)
  static Size screenSize(BuildContext context) {
    return _mediaQuery(context).size;
  }

  /// Get screen aspect ratio
  static double aspectRatio(BuildContext context) {
    final size = screenSize(context);
    return size.width / size.height;
  }

  /// Get screen orientation
  static Orientation orientation(BuildContext context) {
    return _mediaQuery(context).orientation;
  }

  /// Check if screen is mobile based on live dimensions
  static bool isMobile(BuildContext context) {
    return screenWidth(context) < mobileBreakpoint;
  }

  /// Check if screen is tablet based on live dimensions
  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if screen is desktop based on live dimensions
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= tabletBreakpoint;
  }

  /// Get screen size category based on live dimensions
  /// Returns a value between 0.0 (mobile) and 1.0 (desktop) for interpolation
  static double getScreenSizeFactor(BuildContext context) {
    final width = screenWidth(context);
    if (width < mobileBreakpoint) {
      // Mobile: 0.0 to 0.5 (interpolate within mobile range)
      return (width / mobileBreakpoint) * 0.5;
    } else if (width < tabletBreakpoint) {
      // Tablet: 0.5 to 0.75 (interpolate within tablet range)
      const mobileRange = tabletBreakpoint - mobileBreakpoint;
      final position = (width - mobileBreakpoint) / mobileRange;
      return 0.5 + (position * 0.25);
    } else {
      // Desktop: 0.75 to 1.0 (interpolate within desktop range)
      const tabletRange = desktopBreakpoint - tabletBreakpoint;
      final position = (width - tabletBreakpoint) / tabletRange;
      return 0.75 + (position * 0.25).clamp(0.0, 0.25);
    }
  }

  /// Interpolate between two values based on screen size factor
  static double interpolate(
    BuildContext context,
    double mobileValue,
    double tabletValue,
    double desktopValue,
  ) {
    final factor = getScreenSizeFactor(context);
    if (factor < 0.5) {
      // Interpolate between mobile and tablet
      final t = (factor / 0.5);
      return mobileValue + (tabletValue - mobileValue) * t;
    } else if (factor < 0.75) {
      // Interpolate between tablet and desktop
      final t = ((factor - 0.5) / 0.25);
      return tabletValue + (desktopValue - tabletValue) * t;
    } else {
      // Use desktop value
      return desktopValue;
    }
  }

  /// Get adaptive size multiplier based on screen dimensions
  /// Returns a multiplier that scales smoothly with screen size
  static double getSizeMultiplier(BuildContext context) {
    final width = screenWidth(context);
    final height = screenHeight(context);
    final diagonal =
        (width * width + height * height) / (600 * 600 + 800 * 800);
    return diagonal.clamp(0.8, 1.5);
  }

  /// Get responsive padding
  /// Uses ResponsiveConfig.padding values
  /// Dynamically interpolates based on live screen dimensions
  static EdgeInsets getPadding(BuildContext context) {
    final padding = interpolate(
      context,
      ResponsiveConfig.padding.screenMobile,
      ResponsiveConfig.padding.screenTablet,
      ResponsiveConfig.padding.screenDesktop,
    );
    return EdgeInsets.all(padding);
  }

  /// Get responsive horizontal padding
  /// Dynamically interpolates based on live screen dimensions
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    final padding = interpolate(
      context,
      ResponsiveConfig.padding.screenMobile,
      ResponsiveConfig.padding.screenTablet,
      ResponsiveConfig.padding.screenDesktop,
    );
    return EdgeInsets.symmetric(horizontal: padding);
  }

  /// Get responsive vertical padding
  /// Dynamically interpolates based on live screen dimensions
  static EdgeInsets getVerticalPadding(BuildContext context) {
    final padding = interpolate(
      context,
      ResponsiveConfig.padding.screenMobile,
      ResponsiveConfig.padding.screenTablet,
      ResponsiveConfig.padding.screenDesktop,
    );
    return EdgeInsets.symmetric(vertical: padding);
  }

  /// Get responsive spacing
  /// Uses ResponsiveConfig.spacing values as defaults
  /// Dynamically interpolates between sizes based on live screen dimensions
  static double getSpacing(BuildContext context,
      {double? mobile,
      double? tablet,
      double? desktop,
      SpacingSize size = SpacingSize.medium}) {
    final config = _getSpacingFromConfig(size);

    // If explicit values provided, use interpolation
    if (mobile != null || tablet != null || desktop != null) {
      return interpolate(
        context,
        mobile ?? config.mobile,
        tablet ?? config.tablet,
        desktop ?? config.desktop,
      );
    }

    // Otherwise use smooth interpolation based on live screen dimensions
    return interpolate(context, config.mobile, config.tablet, config.desktop);
  }

  /// Helper to get spacing from config
  static ({double mobile, double tablet, double desktop}) _getSpacingFromConfig(
      SpacingSize size) {
    switch (size) {
      case SpacingSize.xs:
        return (
          mobile: ResponsiveConfig.spacing.xsMobile,
          tablet: ResponsiveConfig.spacing.xsTablet,
          desktop: ResponsiveConfig.spacing.xsDesktop,
        );
      case SpacingSize.small:
        return (
          mobile: ResponsiveConfig.spacing.smallMobile,
          tablet: ResponsiveConfig.spacing.smallTablet,
          desktop: ResponsiveConfig.spacing.smallDesktop,
        );
      case SpacingSize.medium:
        return (
          mobile: ResponsiveConfig.spacing.mediumMobile,
          tablet: ResponsiveConfig.spacing.mediumTablet,
          desktop: ResponsiveConfig.spacing.mediumDesktop,
        );
      case SpacingSize.large:
        return (
          mobile: ResponsiveConfig.spacing.largeMobile,
          tablet: ResponsiveConfig.spacing.largeTablet,
          desktop: ResponsiveConfig.spacing.largeDesktop,
        );
      case SpacingSize.xl:
        return (
          mobile: ResponsiveConfig.spacing.xlMobile,
          tablet: ResponsiveConfig.spacing.xlTablet,
          desktop: ResponsiveConfig.spacing.xlDesktop,
        );
      case SpacingSize.xxl:
        return (
          mobile: ResponsiveConfig.spacing.xxlMobile,
          tablet: ResponsiveConfig.spacing.xxlTablet,
          desktop: ResponsiveConfig.spacing.xxlDesktop,
        );
    }
  }

  /// Get responsive font size
  /// Uses ResponsiveConfig.font values as defaults
  /// Dynamically interpolates between sizes based on live screen dimensions
  static double getFontSize(BuildContext context,
      {double? mobile,
      double? tablet,
      double? desktop,
      FontSize size = FontSize.medium}) {
    final config = _getFontSizeFromConfig(size);

    // If explicit values provided, use interpolation
    if (mobile != null || tablet != null || desktop != null) {
      return interpolate(
        context,
        mobile ?? config.mobile,
        tablet ?? config.tablet,
        desktop ?? config.desktop,
      );
    }

    // Otherwise use smooth interpolation based on live screen dimensions
    return interpolate(context, config.mobile, config.tablet, config.desktop);
  }

  /// Helper to get font size from config
  static ({double mobile, double tablet, double desktop})
      _getFontSizeFromConfig(FontSize size) {
    switch (size) {
      case FontSize.small:
        return (
          mobile: ResponsiveConfig.font.smallMobile,
          tablet: ResponsiveConfig.font.smallTablet,
          desktop: ResponsiveConfig.font.smallDesktop,
        );
      case FontSize.body:
        return (
          mobile: ResponsiveConfig.font.bodyMobile,
          tablet: ResponsiveConfig.font.bodyTablet,
          desktop: ResponsiveConfig.font.bodyDesktop,
        );
      case FontSize.medium:
        return (
          mobile: ResponsiveConfig.font.mediumMobile,
          tablet: ResponsiveConfig.font.mediumTablet,
          desktop: ResponsiveConfig.font.mediumDesktop,
        );
      case FontSize.large:
        return (
          mobile: ResponsiveConfig.font.largeMobile,
          tablet: ResponsiveConfig.font.largeTablet,
          desktop: ResponsiveConfig.font.largeDesktop,
        );
      case FontSize.extraLarge:
        return (
          mobile: ResponsiveConfig.font.extraLargeMobile,
          tablet: ResponsiveConfig.font.extraLargeTablet,
          desktop: ResponsiveConfig.font.extraLargeDesktop,
        );
      case FontSize.display:
        return (
          mobile: ResponsiveConfig.font.displayMobile,
          tablet: ResponsiveConfig.font.displayTablet,
          desktop: ResponsiveConfig.font.displayDesktop,
        );
    }
  }

  /// Get responsive icon size
  /// Uses ResponsiveConfig.icon values as defaults
  static double getIconSize(BuildContext context,
      {double? mobile,
      double? tablet,
      double? desktop,
      IconSize size = IconSize.medium}) {
    final config = _getIconSizeFromConfig(size);
    if (isMobile(context)) {
      return mobile ?? config.mobile;
    } else if (isTablet(context)) {
      return tablet ?? config.tablet;
    } else {
      return desktop ?? config.desktop;
    }
  }

  /// Helper to get icon size from config
  static ({double mobile, double tablet, double desktop})
      _getIconSizeFromConfig(IconSize size) {
    switch (size) {
      case IconSize.small:
        return (
          mobile: ResponsiveConfig.icon.smallMobile,
          tablet: ResponsiveConfig.icon.smallTablet,
          desktop: ResponsiveConfig.icon.smallDesktop,
        );
      case IconSize.medium:
        return (
          mobile: ResponsiveConfig.icon.mediumMobile,
          tablet: ResponsiveConfig.icon.mediumTablet,
          desktop: ResponsiveConfig.icon.mediumDesktop,
        );
      case IconSize.large:
        return (
          mobile: ResponsiveConfig.icon.largeMobile,
          tablet: ResponsiveConfig.icon.largeTablet,
          desktop: ResponsiveConfig.icon.largeDesktop,
        );
      case IconSize.extraLarge:
        return (
          mobile: ResponsiveConfig.icon.extraLargeMobile,
          tablet: ResponsiveConfig.icon.extraLargeTablet,
          desktop: ResponsiveConfig.icon.extraLargeDesktop,
        );
    }
  }

  /// Get responsive card padding
  /// Uses ResponsiveConfig.padding values
  /// Dynamically interpolates based on live screen dimensions
  static EdgeInsets getCardPadding(BuildContext context) {
    final padding = interpolate(
      context,
      ResponsiveConfig.padding.cardMobile,
      ResponsiveConfig.padding.cardTablet,
      ResponsiveConfig.padding.cardDesktop,
    );
    return EdgeInsets.all(padding);
  }

  /// Get responsive form max width (centers form on desktop)
  static double getFormMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 500;
    } else {
      return 600;
    }
  }

  /// Get responsive content max width (centers content on desktop)
  static double getContentMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 800;
    } else {
      return 1200;
    }
  }

  /// Get responsive grid cross axis count
  static int getGridCrossAxisCount(BuildContext context,
      {int? mobile, int? tablet, int? desktop}) {
    if (isMobile(context)) {
      return mobile ?? 1;
    } else if (isTablet(context)) {
      return tablet ?? 2;
    } else {
      return desktop ?? 3;
    }
  }

  /// Get responsive child aspect ratio for grid
  static double getGridChildAspectRatio(BuildContext context,
      {double? mobile, double? tablet, double? desktop}) {
    if (isMobile(context)) {
      return mobile ?? 1.0;
    } else if (isTablet(context)) {
      return tablet ?? 1.2;
    } else {
      return desktop ?? 1.3;
    }
  }

  /// Get responsive button height
  /// Uses ResponsiveConfig.button values as defaults
  static double getButtonHeight(BuildContext context,
      {ButtonSize size = ButtonSize.medium}) {
    if (isMobile(context)) {
      switch (size) {
        case ButtonSize.small:
          return ResponsiveConfig.button.smallMobile;
        case ButtonSize.medium:
          return ResponsiveConfig.button.mediumMobile;
        case ButtonSize.large:
          return ResponsiveConfig.button.largeMobile;
      }
    } else if (isTablet(context)) {
      switch (size) {
        case ButtonSize.small:
          return ResponsiveConfig.button.smallTablet;
        case ButtonSize.medium:
          return ResponsiveConfig.button.mediumTablet;
        case ButtonSize.large:
          return ResponsiveConfig.button.largeTablet;
      }
    } else {
      switch (size) {
        case ButtonSize.small:
          return ResponsiveConfig.button.smallDesktop;
        case ButtonSize.medium:
          return ResponsiveConfig.button.mediumDesktop;
        case ButtonSize.large:
          return ResponsiveConfig.button.largeDesktop;
      }
    }
  }

  /// Get responsive border radius
  /// Uses ResponsiveConfig.borderRadius values as defaults
  /// Dynamically interpolates between sizes based on live screen dimensions
  static double getBorderRadius(BuildContext context,
      {double? mobile,
      double? tablet,
      double? desktop,
      BorderRadiusSize size = BorderRadiusSize.medium}) {
    double mobileValue, tabletValue, desktopValue;

    switch (size) {
      case BorderRadiusSize.small:
        mobileValue = ResponsiveConfig.borderRadius.smallMobile;
        tabletValue = ResponsiveConfig.borderRadius.smallTablet;
        desktopValue = ResponsiveConfig.borderRadius.smallDesktop;
        break;
      case BorderRadiusSize.medium:
        mobileValue = ResponsiveConfig.borderRadius.mediumMobile;
        tabletValue = ResponsiveConfig.borderRadius.mediumTablet;
        desktopValue = ResponsiveConfig.borderRadius.mediumDesktop;
        break;
      case BorderRadiusSize.large:
        mobileValue = ResponsiveConfig.borderRadius.largeMobile;
        tabletValue = ResponsiveConfig.borderRadius.largeTablet;
        desktopValue = ResponsiveConfig.borderRadius.largeDesktop;
        break;
    }

    // If explicit values provided, use interpolation
    if (mobile != null || tablet != null || desktop != null) {
      return interpolate(
        context,
        mobile ?? mobileValue,
        tablet ?? tabletValue,
        desktop ?? desktopValue,
      );
    }

    // Otherwise use smooth interpolation based on live screen dimensions
    return interpolate(context, mobileValue, tabletValue, desktopValue);
  }

  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isMobile(context)) {
      return kToolbarHeight;
    } else {
      return kToolbarHeight + 8;
    }
  }

  /// Get responsive drawer width
  static double getDrawerWidth(BuildContext context) {
    if (isMobile(context)) {
      return 280.0;
    } else {
      return 320.0;
    }
  }
}

/// Responsive widget builder
/// Builds different widgets based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (Responsive.isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// Responsive layout widget
/// Centers content on desktop, full-width on mobile
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final contentMaxWidth = maxWidth ?? Responsive.getContentMaxWidth(context);
    final contentPadding = padding ?? Responsive.getPadding(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: contentMaxWidth,
        ),
        child: Padding(
          padding: contentPadding,
          child: child,
        ),
      ),
    );
  }
}

/// Responsive form layout widget
/// Centers form on desktop, full-width on mobile
class ResponsiveFormLayout extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveFormLayout({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final formMaxWidth = maxWidth ?? Responsive.getFormMaxWidth(context);
    final formPadding = padding ?? Responsive.getPadding(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: formMaxWidth,
        ),
        child: Padding(
          padding: formPadding,
          child: child,
        ),
      ),
    );
  }
}

/// Responsive grid widget
/// Adapts grid columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing = 12.0, // Default medium spacing
    this.runSpacing = 12.0, // Default medium spacing
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = Responsive.getGridCrossAxisCount(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: Responsive.getGridChildAspectRatio(context),
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
