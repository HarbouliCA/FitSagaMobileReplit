import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool fullScreen;
  final IconData icon;
  final String? actionText;

  const CustomErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.fullScreen = false,
    this.icon = Icons.error_outline,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: fullScreen ? 64 : 48,
          color: AppTheme.errorColor,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fullScreen ? 18 : 16,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(actionText ?? 'Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Scaffold(
        body: Center(
          child: errorWidget,
        ),
      );
    }

    return Center(
      child: errorWidget,
    );
  }
}

class NoDataWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const NoDataWidget({
    Key? key,
    required this.message,
    this.icon = Icons.sentiment_dissatisfied,
    this.onAction,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool fullScreen;

  const NetworkErrorWidget({
    Key? key,
    this.onRetry,
    this.fullScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: 'Unable to connect to the network. Please check your internet connection and try again.',
      onRetry: onRetry,
      fullScreen: fullScreen,
      icon: Icons.wifi_off,
      actionText: 'Retry Connection',
    );
  }
}

class PermissionErrorWidget extends StatelessWidget {
  final VoidCallback? onAction;
  final bool fullScreen;

  const PermissionErrorWidget({
    Key? key,
    this.onAction,
    this.fullScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: 'You do not have permission to access this content. Please login or contact an administrator.',
      onRetry: onAction,
      fullScreen: fullScreen,
      icon: Icons.no_accounts,
      actionText: 'Login',
    );
  }
}

class MaintenanceErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool fullScreen;

  const MaintenanceErrorWidget({
    Key? key,
    this.onRetry,
    this.fullScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: 'The service is temporarily unavailable due to maintenance. Please try again later.',
      onRetry: onRetry,
      fullScreen: fullScreen,
      icon: Icons.engineering,
      actionText: 'Check Status',
    );
  }
}