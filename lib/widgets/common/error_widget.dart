import 'package:flutter/material.dart';

/// Error widget for displaying errors with retry option
class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  
  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.red,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  
  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      message: 'Network error. Please check your internet connection.',
      onRetry: onRetry,
      icon: Icons.wifi_off,
    );
  }
}

/// Server error widget
class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  
  const ServerErrorWidget({
    super.key,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      message: 'Server error. Please try again later.',
      onRetry: onRetry,
      icon: Icons.cloud_off,
    );
  }
}

/// Validation error widget
class ValidationErrorWidget extends StatelessWidget {
  final String message;
  
  const ValidationErrorWidget({
    super.key,
    required this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      message: message,
      icon: Icons.warning_amber_rounded,
    );
  }
}

