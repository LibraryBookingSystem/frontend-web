import 'package:flutter/material.dart';
import '../../../widgets/common/animated_card.dart';
import '../../../core/animations/animation_utils.dart';

/// Action card widget for quick actions on the home screen
class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final int? index;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              color,
              color.withValues(alpha: 0.8), // More vibrant in dark mode
              color.withValues(alpha: 0.6),
            ]
          : [
              color,
              color.withValues(alpha: 0.7),
            ],
    );

    Widget card = AnimatedCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive sizes based on available space
            final availableHeight = constraints.maxHeight;
            final availableWidth = constraints.maxWidth;

            // Determine if we're in a constrained space (small card)
            // More aggressive threshold to prevent overflow
            final isConstrained = availableHeight < 80 || availableWidth < 120;

            // Responsive padding - reduce more aggressively for small cards
            final padding = isConstrained ? 6.0 : 16.0;

            // Responsive icon size - make it smaller for constrained space
            final iconSize = isConstrained ? 32.0 : 56.0;
            final iconInnerSize = isConstrained ? 20.0 : 32.0;

            // Responsive spacing - minimal spacing when constrained
            final spacing = isConstrained ? 2.0 : 8.0;

            // Responsive font size
            final fontSize = isConstrained ? 9.0 : 12.0;

            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(icon, size: iconInnerSize, color: Colors.white),
                    ),
                    SizedBox(height: spacing),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: isConstrained ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                    ),
                  ],
                ),
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
