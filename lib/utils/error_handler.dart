import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';

/// A utility class for handling errors in a consistent way throughout the app.
class ErrorHandler {
  /// Handles an error and returns an appropriate error message.
  /// 
  /// This method analyzes different types of errors and translates them
  /// into user-friendly error messages.
  static String handleError(dynamic error) {
    if (error is SocketException || error.toString().contains('SocketException')) {
      return 'Network connection error. Please check your internet connection and try again.';
    } else if (error is HttpException || error.toString().contains('HttpException')) {
      return 'Unable to complete the request. Please try again later.';
    } else if (error is FormatException || error.toString().contains('FormatException')) {
      return 'Invalid data format. Please try again later.';
    } else if (error.toString().contains('permission')) {
      return 'Permission denied. You may not have the necessary permissions to perform this action.';
    } else if (error.toString().contains('timeout')) {
      return 'Connection timeout. Please check your internet connection and try again.';
    } else if (error.toString().contains('authentication') || 
               error.toString().contains('auth') || 
               error.toString().contains('login')) {
      return 'Authentication error. Please login again.';
    } else {
      return 'An unexpected error occurred. Please try again later. ${error.toString()}';
    }
  }
  
  /// Shows an error dialog with the given error message.
  /// 
  /// [context] is the BuildContext to show the dialog.
  /// [error] is the error to display. It will be passed to [handleError].
  /// [onRetry] is an optional callback to invoke when the user wants to retry.
  /// [defaultMessage] is an optional default message to show if [error] is null.
  static Future<void> showErrorDialog(
    BuildContext context, 
    dynamic error, {
    VoidCallback? onRetry,
    String defaultMessage = 'An error occurred',
  }) async {
    final errorMessage = error != null ? handleError(error) : defaultMessage;
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(errorMessage),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            if (onRetry != null)
              TextButton(
                child: const Text('Retry'),
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
              ),
          ],
        );
      },
    );
  }
  
  /// Shows an error snackbar with the given error message.
  /// 
  /// [context] is the BuildContext to show the snackbar.
  /// [error] is the error to display. It will be passed to [handleError].
  /// [onRetry] is an optional callback to invoke when the user wants to retry.
  /// [defaultMessage] is an optional default message to show if [error] is null.
  static void showErrorSnackBar(
    BuildContext context, 
    dynamic error, {
    VoidCallback? onRetry,
    String defaultMessage = 'An error occurred',
  }) {
    final errorMessage = error != null ? handleError(error) : defaultMessage;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                onPressed: onRetry,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }
  
  /// Builds an error widget for the given error.
  /// 
  /// [error] is the error to display. It will be passed to [handleError].
  /// [onRetry] is an optional callback to invoke when the user wants to retry.
  /// [defaultMessage] is an optional default message to show if [error] is null.
  /// [fullScreen] indicates whether the error widget should be displayed fullscreen.
  static Widget buildErrorWidget(
    dynamic error, {
    VoidCallback? onRetry,
    String defaultMessage = 'An error occurred',
    bool fullScreen = false,
  }) {
    final errorMessage = error != null ? handleError(error) : defaultMessage;
    
    if (error is SocketException || error.toString().contains('SocketException')) {
      return NetworkErrorWidget(
        onRetry: onRetry,
        fullScreen: fullScreen,
      );
    } else if (error.toString().contains('permission') || 
               error.toString().contains('denied') || 
               error.toString().contains('unauthorized')) {
      return PermissionErrorWidget(
        onAction: onRetry,
        fullScreen: fullScreen,
      );
    } else if (error.toString().contains('maintenance') || 
               error.toString().contains('unavailable') || 
               error.toString().contains('503')) {
      return MaintenanceErrorWidget(
        onRetry: onRetry,
        fullScreen: fullScreen,
      );
    }
    
    return CustomErrorWidget(
      message: errorMessage,
      onRetry: onRetry,
      fullScreen: fullScreen,
    );
  }
}