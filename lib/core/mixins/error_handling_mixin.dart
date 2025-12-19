import 'package:flutter/material.dart';

/// Mixin providing centralized error handling capabilities
mixin ErrorHandlingMixin {
  /// Handle error and return user-friendly message
  String handleError(Object error, [StackTrace? stackTrace]) {
    // Extract user-friendly error message
    final errorMessage = _extractErrorMessage(error);

    return errorMessage;
  }

  /// Extract user-friendly error message from error object
  String _extractErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socketexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('network is unreachable')) {
      return 'Network error. Please check your internet connection.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    // HTTP errors
    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Authentication failed. Please login again.';
    }

    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'You do not have permission to perform this action.';
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Resource not found.';
    }

    if (errorString.contains('409') || errorString.contains('conflict')) {
      return 'A conflict occurred. The resource may have been modified.';
    }

    if (errorString.contains('500') ||
        errorString.contains('internal server error')) {
      return 'Server error. Please try again later.';
    }

    // Validation errors
    if (errorString.contains('validation') || errorString.contains('invalid')) {
      return 'Invalid input. Please check your data and try again.';
    }

    // Pending approval errors
    if (errorString.contains('pending approval')) {
      return 'Your account is pending approval. Please wait for an administrator to approve your registration.';
    }

    // Rejected account errors
    if (errorString.contains('rejected') &&
        errorString.contains('registration')) {
      return 'Your account registration was rejected. Please contact an administrator.';
    }

    // Default error message
    return 'An unexpected error occurred. Please try again.';
  }

  /// Show error snackbar to user
  void showErrorSnackBar(BuildContext context, String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show success snackbar to user
  void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error dialog to user
  Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Execute function with error handling
  Future<T?> executeWithErrorHandling<T>(
    BuildContext? context,
    Future<T> Function() function, {
    String? errorMessage,
    bool showError = true,
  }) async {
    try {
      return await function();
    } catch (error, stackTrace) {
      // Log the actual error for debugging
      debugPrint('❌ Error in executeWithErrorHandling:');
      debugPrint('Error: $error');
      debugPrint('StackTrace: $stackTrace');

      final message = errorMessage ?? handleError(error, stackTrace);

      // Also log the user-friendly message
      debugPrint('User-friendly message: $message');

      if (showError && context != null) {
        showErrorSnackBar(context, message);
      }

      return null;
    }
  }
}
