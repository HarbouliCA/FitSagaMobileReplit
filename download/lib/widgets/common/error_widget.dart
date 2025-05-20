import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';

/// A reusable widget for displaying error messages
class CustomErrorWidget extends StatelessWidget {
  /// The error message to display
  final String message;
  
  /// An optional title for the error
  final String? title;
  
  /// The icon to display above the error message
  final IconData icon;
  
  /// Callback function for the retry button
  final VoidCallback? onRetry;
  
  /// Text for the retry button
  final String retryText;
  
  /// Whether to show the retry button
  final bool showRetry;
  
  /// Creates a custom error widget
  const CustomErrorWidget({
    Key? key,
    required this.message,
    this.title,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.retryText = 'Try Again',
    this.showRetry = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.errorColor,
              size: 64,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingSmall),
            ],
            Text(
              message,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeRegular,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (showRetry && onRetry != null) ...[
              const SizedBox(height: AppTheme.spacingLarge),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingLarge,
                    vertical: AppTheme.paddingRegular,
                  ),
                ),
                child: Text(retryText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying a network connection error
class NetworkErrorWidget extends StatelessWidget {
  /// Callback function for the retry button
  final VoidCallback? onRetry;
  
  /// Custom message (optional)
  final String? message;
  
  /// Creates a network error widget
  const NetworkErrorWidget({
    Key? key,
    this.onRetry,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Connection Error',
      message: message ?? 
          'Unable to connect to the server. Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

/// Widget for displaying an empty state with optional action
class EmptyStateWidget extends StatelessWidget {
  /// The message to display
  final String message;
  
  /// An optional title
  final String? title;
  
  /// The icon to display above the message
  final IconData icon;
  
  /// Callback function for the action button
  final VoidCallback? onAction;
  
  /// Text for the action button
  final String actionText;
  
  /// Whether to show the action button
  final bool showAction;
  
  /// Creates an empty state widget
  const EmptyStateWidget({
    Key? key,
    required this.message,
    this.title,
    this.icon = Icons.inbox,
    this.onAction,
    this.actionText = 'Add New',
    this.showAction = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.textLightColor,
              size: 64,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingSmall),
            ],
            Text(
              message,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeRegular,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (showAction && onAction != null) ...[
              const SizedBox(height: AppTheme.spacingLarge),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingLarge,
                    vertical: AppTheme.paddingRegular,
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

/// Widget for displaying a permission denied error
class PermissionDeniedWidget extends StatelessWidget {
  /// Callback function for the go back button
  final VoidCallback? onGoBack;
  
  /// Custom message (optional)
  final String? message;
  
  /// Creates a permission denied widget
  const PermissionDeniedWidget({
    Key? key,
    this.onGoBack,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Access Denied',
      message: message ?? 
          'You do not have permission to access this feature. Please contact an administrator if you believe this is an error.',
      icon: Icons.no_accounts,
      onRetry: onGoBack,
      retryText: 'Go Back',
    );
  }
}

/// Widget for displaying a maintenance mode message
class MaintenanceWidget extends StatelessWidget {
  /// Callback function for the refresh button
  final VoidCallback? onRefresh;
  
  /// Custom message (optional)
  final String? message;
  
  /// Creates a maintenance mode widget
  const MaintenanceWidget({
    Key? key,
    this.onRefresh,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Under Maintenance',
      message: message ?? 
          'This feature is currently under maintenance. Please try again later.',
      icon: Icons.construction,
      onRetry: onRefresh,
      retryText: 'Refresh',
    );
  }
}