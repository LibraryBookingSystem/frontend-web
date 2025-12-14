import 'package:flutter/material.dart';
import '../../core/animations/animation_utils.dart';
import 'animated_card.dart';

/// Enhanced section widget with vibrant colors and gradients
class EnhancedSection extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? titleIcon;
  final EdgeInsetsGeometry? padding;
  final bool showGradient;
  final Color? gradientColor;

  const EnhancedSection({
    super.key,
    required this.child,
    this.title,
    this.titleIcon,
    this.padding,
    this.showGradient = true,
    this.gradientColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = gradientColor ?? Theme.of(context).primaryColor;

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: showGradient
          ? BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.15),
                        color.withValues(alpha: 0.08),
                        color.withValues(alpha: 0.05),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.08),
                        color.withValues(alpha: 0.03),
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
              border: isDark
                  ? Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1.5,
                    )
                  : null,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (titleIcon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? LinearGradient(
                              colors: [
                                color.withValues(alpha: 0.3),
                                color.withValues(alpha: 0.2),
                              ],
                            )
                          : null,
                      color: isDark
                          ? null
                          : color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      titleIcon,
                      color: isDark ? color : color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? color : null,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );

    return AnimationUtils.fadeIn(child: content);
  }
}

/// Enhanced card with vibrant styling
class EnhancedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const EnhancedCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? Theme.of(context).primaryColor;

    return AnimatedCard(
      onTap: onTap,
      margin: margin,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardColor.withValues(alpha: 0.2),
                    cardColor.withValues(alpha: 0.12),
                    cardColor.withValues(alpha: 0.08),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardColor.withValues(alpha: 0.08),
                    cardColor.withValues(alpha: 0.04),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(
                  color: cardColor.withValues(alpha: 0.25),
                  width: 1.5,
                )
              : null,
        ),
        child: child,
      ),
    );
  }
}

