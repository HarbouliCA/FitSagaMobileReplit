import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';

/// A reusable error widget with retry functionality
class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showIcon;
  final Widget? icon;
  final bool useScaffold;

  const CustomErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.showIcon = true,
    this.icon,
    this.useScaffold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorContent = Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showIcon)
            icon ??
                const Icon(
                  Icons.error_outline,
                  size: 72,
                  color: AppTheme.errorColor,
                ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeMedium,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppTheme.spacingLarge),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingLarge,
                  vertical: AppTheme.paddingMedium,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (useScaffold) {
      return Scaffold(
        body: Center(child: errorContent),
      );
    }

    return Center(child: errorContent);
  }
}

/// A smaller inline error message for form fields or small UI sections
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.errorColor,
                fontSize: AppTheme.fontSizeSmall,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: AppTheme.errorColor,
                size: 18,
              ),
              onPressed: onRetry,
              tooltip: 'Retry',
            ),
        ],
      ),
    );
  }
}

/// A full-page error state with illustration for critical errors
class FullPageErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? illustration;

  const FullPageErrorWidget({
    Key? key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.illustration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (illustration != null) ...[
                illustration!,
                const SizedBox(height: AppTheme.spacingXLarge),
              ] else ...[
                const Icon(
                  Icons.error_outline,
                  size: 100,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: AppTheme.spacingLarge),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeXLarge,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXLarge),
              if (onAction != null)
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.paddingMedium,
                      ),
                    ),
                    child: Text(actionLabel ?? 'Try Again'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}