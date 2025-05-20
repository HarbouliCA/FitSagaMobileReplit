import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';

/// A customizable error widget that can be used throughout the app
class CustomErrorWidget extends StatelessWidget {
  /// The error message to display
  final String message;
  
  /// Whether to show a retry button
  final bool showRetryButton;
  
  /// Callback for when the retry button is pressed
  final VoidCallback? onRetry;
  
  /// Whether the error should take up the full screen
  final bool fullScreen;
  
  /// The icon to display
  final IconData icon;
  
  /// Create a custom error widget
  const CustomErrorWidget({
    Key? key,
    required this.message,
    this.showRetryButton = true,
    this.onRetry,
    this.fullScreen = false,
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullScreen ? double.infinity : null,
      height: fullScreen ? double.infinity : null,
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}