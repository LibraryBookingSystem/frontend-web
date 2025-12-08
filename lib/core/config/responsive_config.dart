/// Centralized responsive design configuration
/// All sizing values for mobile, tablet, and desktop are defined here
/// This ensures consistency and makes it easy to adjust values across the app
library;

// ============================================
// Icon Sizes
// ============================================
class IconSizes {
  const IconSizes();

  // Small icons (e.g., action buttons, list items)
  final double smallMobile = 20.0;
  final double smallTablet = 24.0;
  final double smallDesktop = 28.0;

  // Medium icons (e.g., app icons, feature icons)
  final double mediumMobile = 24.0;
  final double mediumTablet = 28.0;
  final double mediumDesktop = 32.0;

  // Large icons (e.g., success indicators, hero icons)
  final double largeMobile = 56.0;
  final double largeTablet = 64.0;
  final double largeDesktop = 72.0;

  // Extra large icons (e.g., splash screens, empty states)
  final double extraLargeMobile = 80.0;
  final double extraLargeTablet = 96.0;
  final double extraLargeDesktop = 112.0;
}

// ============================================
// Font Sizes
// ============================================
class FontSizes {
  const FontSizes();

  // Body text
  final double bodyMobile = 14.0;
  final double bodyTablet = 15.0;
  final double bodyDesktop = 16.0;

  // Small text (captions, labels)
  final double smallMobile = 12.0;
  final double smallTablet = 13.0;
  final double smallDesktop = 14.0;

  // Medium text (subheadings)
  final double mediumMobile = 16.0;
  final double mediumTablet = 18.0;
  final double mediumDesktop = 20.0;

  // Large text (headings)
  final double largeMobile = 20.0;
  final double largeTablet = 22.0;
  final double largeDesktop = 24.0;

  // Extra large text (titles)
  final double extraLargeMobile = 24.0;
  final double extraLargeTablet = 28.0;
  final double extraLargeDesktop = 32.0;

  // Display text (hero titles)
  final double displayMobile = 32.0;
  final double displayTablet = 40.0;
  final double displayDesktop = 48.0;
}

// ============================================
// Spacing
// ============================================
class SpacingSizes {
  const SpacingSizes();

  // Extra small spacing (tight elements)
  final double xsMobile = 4.0;
  final double xsTablet = 6.0;
  final double xsDesktop = 8.0;

  // Small spacing (related elements)
  final double smallMobile = 8.0;
  final double smallTablet = 12.0;
  final double smallDesktop = 16.0;

  // Medium spacing (sections)
  final double mediumMobile = 12.0;
  final double mediumTablet = 16.0;
  final double mediumDesktop = 20.0;

  // Large spacing (major sections)
  final double largeMobile = 16.0;
  final double largeTablet = 20.0;
  final double largeDesktop = 24.0;

  // Extra large spacing (page sections)
  final double xlMobile = 20.0;
  final double xlTablet = 24.0;
  final double xlDesktop = 28.0;

  // XXL spacing (major page divisions)
  final double xxlMobile = 24.0;
  final double xxlTablet = 28.0;
  final double xxlDesktop = 32.0;
}

// ============================================
// Button Heights
// ============================================
class ButtonHeights {
  const ButtonHeights();

  final double smallMobile = 36.0;
  final double smallTablet = 40.0;
  final double smallDesktop = 44.0;

  final double mediumMobile = 48.0;
  final double mediumTablet = 52.0;
  final double mediumDesktop = 56.0;

  final double largeMobile = 56.0;
  final double largeTablet = 60.0;
  final double largeDesktop = 64.0;
}

// ============================================
// Padding
// ============================================
class PaddingSizes {
  const PaddingSizes();

  final double screenMobile = 16.0;
  final double screenTablet = 24.0;
  final double screenDesktop = 32.0;

  final double cardMobile = 16.0;
  final double cardTablet = 20.0;
  final double cardDesktop = 24.0;

  final double formMobile = 16.0;
  final double formTablet = 20.0;
  final double formDesktop = 24.0;
}

// ============================================
// Border Radius
// ============================================
class BorderRadiusSizes {
  const BorderRadiusSizes();

  final double smallMobile = 8.0;
  final double smallTablet = 10.0;
  final double smallDesktop = 12.0;

  final double mediumMobile = 12.0;
  final double mediumTablet = 16.0;
  final double mediumDesktop = 16.0;

  final double largeMobile = 16.0;
  final double largeTablet = 20.0;
  final double largeDesktop = 24.0;
}

// ============================================
// Grid Spacing
// ============================================
class GridSpacingSizes {
  const GridSpacingSizes();

  final double smallMobile = 8.0;
  final double smallTablet = 12.0;
  final double smallDesktop = 16.0;

  final double mediumMobile = 12.0;
  final double mediumTablet = 16.0;
  final double mediumDesktop = 20.0;

  final double largeMobile = 16.0;
  final double largeTablet = 20.0;
  final double largeDesktop = 24.0;
}

// ============================================
// Main Configuration Class
// ============================================
class ResponsiveConfig {
  ResponsiveConfig._(); // Private constructor to prevent instantiation

  static const IconSizes icon = IconSizes();
  static const FontSizes font = FontSizes();
  static const SpacingSizes spacing = SpacingSizes();
  static const ButtonHeights button = ButtonHeights();
  static const PaddingSizes padding = PaddingSizes();
  static const BorderRadiusSizes borderRadius = BorderRadiusSizes();
  static const GridSpacingSizes grid = GridSpacingSizes();
}
