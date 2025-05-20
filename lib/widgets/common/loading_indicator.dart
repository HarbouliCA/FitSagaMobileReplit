import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';

/// A reusable loading indicator with a customizable message
class LoadingIndicator extends StatelessWidget {
  /// The message to display below the spinner
  final String message;
  
  /// The background color of the loading overlay
  final Color backgroundColor;
  
  /// Whether to show the message text
  final bool showMessage;
  
  /// The size of the circular progress indicator
  final double size;
  
  /// Creates a loading indicator with optional custom parameters
  const LoadingIndicator({
    Key? key,
    this.message = 'Loading...',
    this.backgroundColor = Colors.white,
    this.showMessage = true,
    this.size = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: size,
              width: size,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                strokeWidth: 4.0,
              ),
            ),
            if (showMessage) ...[
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                message,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                  color: AppTheme.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A loading indicator that shows over the entire screen
class FullScreenLoadingIndicator extends StatelessWidget {
  /// The message to display below the spinner
  final String message;
  
  /// Whether to allow tapping to dismiss
  final bool dismissible;
  
  /// Callback when the loading overlay is dismissed (if dismissible)
  final VoidCallback? onDismiss;
  
  /// Creates a full-screen loading indicator
  const FullScreenLoadingIndicator({
    Key? key,
    this.message = 'Loading...',
    this.dismissible = false,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => dismissible,
      child: GestureDetector(
        onTap: dismissible ? onDismiss : null,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      color: AppTheme.textPrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (dismissible) ...[
                    const SizedBox(height: AppTheme.spacingMedium),
                    Text(
                      'Tap anywhere to dismiss',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeSmall,
                        color: AppTheme.textLightColor.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A linear loading indicator for the top of the screen
class LinearLoadingIndicator extends StatelessWidget {
  /// The height of the loading bar
  final double height;
  
  /// Creates a horizontal loading indicator
  const LinearLoadingIndicator({
    Key? key,
    this.height = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const LinearProgressIndicator(
        backgroundColor: AppTheme.primaryLightColor,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
      ),
    );
  }
}