import 'package:flutter/material.dart';
import '../animations/animation_utils.dart';
import '../../constants/route_names.dart';
import '../../routes/app_router.dart';

/// Helper class for navigation with custom transitions
class NavigationHelper {
  NavigationHelper._();

  /// Navigate with slide transition from right
  static Future<T?> pushSlideRight<T extends Object?>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.push<T>(
      context,
      SlidePageRoute<T>(page: page, direction: SlideDirection.right),
    );
  }

  /// Navigate with slide transition from left
  static Future<T?> pushSlideLeft<T extends Object?>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.push<T>(
      context,
      SlidePageRoute<T>(page: page, direction: SlideDirection.left),
    );
  }

  /// Navigate with slide transition from bottom
  static Future<T?> pushSlideBottom<T extends Object?>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.push<T>(
      context,
      SlidePageRoute<T>(page: page, direction: SlideDirection.bottom),
    );
  }

  /// Navigate with scale transition
  static Future<T?> pushScale<T extends Object?>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.push<T>(
      context,
      ScalePageRoute<T>(page: page),
    );
  }

  /// Navigate with fade transition
  static Future<T?> pushFade<T extends Object?>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.push<T>(
      context,
      FadePageRoute<T>(page: page),
    );
  }

  /// Navigate with slide and fade transition
  static Future<T?> pushSlideFade<T extends Object?>(
    BuildContext context,
    Widget page, {
    SlideDirection direction = SlideDirection.right,
  }) {
    return Navigator.push<T>(
      context,
      SlideFadePageRoute<T>(page: page, direction: direction),
    );
  }

  /// Navigate by route name with appropriate transition
  static Future<T?> pushNamedWithTransition<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    SlideDirection direction = SlideDirection.right,
  }) {
    final routes = _getRouteMap(context);
    final builder = routes[routeName];
    
    if (builder == null) {
      return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
    }

    final page = builder(context);
    return pushSlideFade<T>(context, page, direction: direction);
  }

  /// Get route map for building pages
  static Map<String, WidgetBuilder> _getRouteMap(BuildContext context) {
    // Import routes dynamically - this is a simplified version
    // In a real app, you'd import from app_router
    return {};
  }

  /// Navigate with smart transition based on route
  static Future<T?> pushNamedSmart<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    // Determine transition based on route
    SlideDirection direction = SlideDirection.right;
    
    // Special cases for specific routes
    if (routeName == RouteNames.createBooking ||
        routeName == RouteNames.checkIn ||
        routeName == RouteNames.bookingDetails) {
      direction = SlideDirection.bottom;
    } else if (routeName == RouteNames.floorPlan) {
      direction = SlideDirection.left;
    }

    return pushNamedWithTransition<T>(
      context,
      routeName,
      arguments: arguments,
      direction: direction,
    );
  }
}

