import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';

/// A reusable loading indicator widget with optional message
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool useScaffold;
  final double size;
  final double strokeWidth;
  final Color? color;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.useScaffold = false,
    this.size = 40.0,
    this.strokeWidth = 4.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loadingWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppTheme.primaryColor,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: AppTheme.fontSizeMedium,
            ),
          ),
        ],
      ],
    );

    if (useScaffold) {
      return Scaffold(
        body: Center(child: loadingWidget),
      );
    }

    return Center(child: loadingWidget);
  }
}