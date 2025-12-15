import 'package:flutter/material.dart';
import '../../core/animations/animation_utils.dart';

/// Animated button with ripple and scale effects
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? elevation;
  final bool isLoading;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.isLoading = false,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationUtils.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onPressed != null && !widget.isLoading) {
      Future.delayed(const Duration(milliseconds: 100), widget.onPressed!);
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading
          ? _handleTapDown
          : null,
      onTapUp: widget.onPressed != null && !widget.isLoading
          ? _handleTapUp
          : null,
      onTapCancel: widget.onPressed != null && !widget.isLoading
          ? _handleTapCancel
          : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: widget.onPressed == null || widget.isLoading ? 0.6 : 1.0,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onPressed,
                style: (widget.style ?? ElevatedButton.styleFrom()).copyWith(
                  backgroundColor: widget.backgroundColor != null
                      ? WidgetStateProperty.all(widget.backgroundColor)
                      : null,
                  foregroundColor: widget.foregroundColor != null
                      ? WidgetStateProperty.all(widget.foregroundColor)
                      : null,
                  padding: widget.padding != null
                      ? WidgetStateProperty.all(widget.padding)
                      : null,
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: widget.borderRadius ??
                          BorderRadius.circular(12),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(widget.elevation ?? 2),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

