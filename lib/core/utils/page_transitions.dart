import 'package:flutter/material.dart';

/// Custom page route with fade transition
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

/// Custom page route with slide transition
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case SlideDirection.left:
                begin = const Offset(1.0, 0.0);
                break;
              case SlideDirection.right:
                begin = const Offset(-1.0, 0.0);
                break;
              case SlideDirection.top:
                begin = const Offset(0.0, 1.0);
                break;
              case SlideDirection.bottom:
                begin = const Offset(0.0, -1.0);
                break;
            }
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

/// Custom page route with scale transition
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScalePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                ),
              ),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
}

/// Custom page route with combined slide and fade transition
class SlideFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;

  SlideFadePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case SlideDirection.left:
                begin = const Offset(1.0, 0.0);
                break;
              case SlideDirection.right:
                begin = const Offset(-1.0, 0.0);
                break;
              case SlideDirection.top:
                begin = const Offset(0.0, 1.0);
                break;
              case SlideDirection.bottom:
                begin = const Offset(0.0, -1.0);
                break;
            }
            const end = Offset.zero;

            return SlideTransition(
              position: Tween(begin: begin, end: end).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                ),
              ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

/// Slide direction enum
enum SlideDirection {
  left,
  right,
  top,
  bottom,
}

/// Helper extension for navigation with custom transitions
extension NavigatorExtensions on NavigatorState {
  /// Navigate with fade transition
  Future<T?> pushFade<T>(Widget page) {
    return push<T>(FadePageRoute(page: page));
  }

  /// Navigate with slide transition
  Future<T?> pushSlide<T>(Widget page,
      {SlideDirection direction = SlideDirection.right}) {
    return push<T>(SlidePageRoute(page: page, direction: direction));
  }

  /// Navigate with scale transition
  Future<T?> pushScale<T>(Widget page) {
    return push<T>(ScalePageRoute(page: page));
  }

  /// Navigate with slide and fade transition
  Future<T?> pushSlideFade<T>(Widget page,
      {SlideDirection direction = SlideDirection.right}) {
    return push<T>(SlideFadePageRoute(page: page, direction: direction));
  }
}
