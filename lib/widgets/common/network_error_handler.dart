import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';

/// A widget that displays a network error and provides a retry option
class NetworkErrorWidget extends StatelessWidget {
  /// Whether to show a retry button
  final bool showRetryButton;
  
  /// Callback for when the retry button is pressed
  final VoidCallback? onRetry;
  
  /// Whether the error should take up the full screen
  final bool fullScreen;
  
  /// Custom message to show (if not provided, a default will be used)
  final String? message;
  
  /// Create a network error widget
  const NetworkErrorWidget({
    Key? key,
    this.showRetryButton = true,
    this.onRetry,
    this.fullScreen = false,
    this.message,
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
            Image.asset(
              'assets/images/no_connection.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image is not available
                return Icon(
                  Icons.wifi_off,
                  size: 100,
                  color: Colors.grey[400],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              message ?? 'No Internet Connection',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please check your internet connection and try again.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Connection'),
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

/// A widget that shows different content based on connectivity status
class ConditionalNetworkWidget extends StatelessWidget {
  /// Whether the device is connected to the network
  final bool isConnected;
  
  /// The widget to show when connected
  final Widget connectedWidget;
  
  /// Optional callback when retry is pressed
  final VoidCallback? onRetry;
  
  /// Custom error message
  final String? errorMessage;
  
  /// Create a conditional network widget
  const ConditionalNetworkWidget({
    Key? key,
    required this.isConnected,
    required this.connectedWidget,
    this.onRetry,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isConnected) {
      return connectedWidget;
    }
    
    return NetworkErrorWidget(
      fullScreen: true,
      showRetryButton: onRetry != null,
      onRetry: onRetry,
      message: errorMessage,
    );
  }
}