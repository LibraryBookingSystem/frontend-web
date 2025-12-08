import 'package:flutter/material.dart';
import '../aspects/aspect_registry.dart';

/// Base View State mixin for MVC architecture
/// Integrates with AOP (registers view with AspectRegistry)
///
/// MVC Pattern:
/// - View: Represents UI components (Screens, Widgets)
/// - Uses Controllers for state management (via Provider)
/// - Uses AOP aspects for cross-cutting concerns (error handling, validation)
///
/// Usage:
/// ```dart
/// class MyScreen extends StatefulWidget {
///   @override
///   State<MyScreen> createState() => _MyScreenState();
/// }
///
/// class _MyScreenState extends State<MyScreen>
///     with BaseViewMixin, ErrorHandlingMixin, ValidationMixin {
///   @override
///   String get viewName => 'MyScreen';
///
///   @override
///   Widget build(BuildContext context) {
///     return Consumer<MyProvider>(
///       builder: (context, controller, _) {
///         return Scaffold(...);
///       },
///     );
///   }
/// }
/// ```
mixin BaseViewMixin<T extends StatefulWidget> on State<T> {
  /// View name for logging (must be implemented)
  String get viewName;

  @override
  void initState() {
    super.initState();
    // Register view with aspect registry (AOP)
    AspectRegistry.instance.registerAspect('view.$viewName', this);
  }

  @override
  void dispose() {
    // Unregister from aspect registry (AOP)
    AspectRegistry.instance.unregisterAspect('view.$viewName');
    super.dispose();
  }
}
