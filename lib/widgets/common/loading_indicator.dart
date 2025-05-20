import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';

/// A customizable loading indicator that can be used throughout the app
class LoadingIndicator extends StatelessWidget {
  /// Size of the loading indicator
  final double size;
  
  /// Color of the loading indicator
  final Color? color;
  
  /// Whether to show text below the indicator
  final bool showText;
  
  /// Custom text to show below the indicator
  final String? text;
  
  /// Create a loading indicator
  const LoadingIndicator({
    Key? key,
    this.size = 24.0,
    this.color,
    this.showText = false,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppTheme.primaryColor,
            ),
            strokeWidth: size * 0.1,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            text ?? 'Loading...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ],
    );
  }
}

/// A loading screen that can be used as a placeholder while waiting for data
class LoadingScreen extends StatelessWidget {
  /// Custom message to display
  final String? message;
  
  /// Create a loading screen
  const LoadingScreen({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingIndicator(
              size: 50,
              showText: false,
            ),
            const SizedBox(height: 24),
            Text(
              message ?? 'Loading...',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A loading overlay that can be displayed over content
class LoadingOverlay extends StatelessWidget {
  /// The child widget to display under the loading overlay
  final Widget child;
  
  /// Whether to show the loading indicator
  final bool isLoading;
  
  /// Custom message to display
  final String? message;
  
  /// Create a loading overlay
  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LoadingIndicator(
                        size: 40,
                        showText: false,
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}