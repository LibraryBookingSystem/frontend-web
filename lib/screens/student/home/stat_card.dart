import 'package:flutter/material.dart';
import '../../../widgets/common/animated_card.dart';
import '../../../core/animations/animation_utils.dart';
import '../../../theme/app_theme.dart';

/// Stat card widget for displaying statistics on the home screen
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int? index;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.index,
  });

  Color _getCardColor(BuildContext context) {
    if (label.toLowerCase().contains('upcoming')) {
      return AppTheme.infoColor; // Blue for upcoming bookings
    } else if (label.toLowerCase().contains('notification')) {
      return AppTheme.secondaryColor; // Pink for notifications
    }
    return Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = _getCardColor(context);

    Widget card = AnimatedCard(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    cardColor.withValues(alpha: 0.12),
                    cardColor.withValues(alpha: 0.08),
                    cardColor.withValues(alpha: 0.05),
                  ]
                : [
                    cardColor.withValues(alpha: 0.1),
                    cardColor.withValues(alpha: 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(
                  color: cardColor.withValues(alpha: 0.2),
                  width: 1,
                )
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Detect mobile size
            final isMobile = MediaQuery.of(context).size.width < 600;

            // Responsive padding - less on mobile
            final padding = isMobile ? 12.0 : 20.0;

            // Responsive icon size and padding
            final iconPadding = isMobile ? 8.0 : 12.0;
            final iconSize = isMobile ? 24.0 : 32.0;

            // Responsive spacing
            final spacing1 = isMobile ? 8.0 : 12.0;
            final spacing2 = isMobile ? 2.0 : 4.0;

            // Responsive font sizes
            final valueFontSize =
                isMobile ? 20.0 : null; // null uses theme default
            final labelFontSize = isMobile ? 11.0 : null;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(iconPadding),
                    decoration: BoxDecoration(
                      color: isDark
                          ? cardColor.withValues(alpha: 0.15)
                          : cardColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: cardColor,
                    ),
                  ),
                  SizedBox(height: spacing1),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cardColor,
                          fontSize: valueFontSize,
                        ),
                  ),
                  SizedBox(height: spacing2),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                          fontSize: labelFontSize,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    if (index != null) {
      return AnimationUtils.staggeredFadeIn(
        index: index!,
        child: card,
      );
    }

    return AnimationUtils.fadeIn(child: card);
  }
}
