import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';

/// A wrapper widget that handles network errors and provides a consistent
/// user experience for data loading states.
///
/// This widget shows appropriate loading indicators, error messages, and
/// empty state messages based on the status of the data loading operation.
class NetworkErrorHandler<T> extends StatelessWidget {
  /// The data being loaded. If null, the widget assumes data is still loading.
  final T? data;
  
  /// Whether the data is currently being loaded.
  final bool isLoading;
  
  /// An error message to display if the data loading failed.
  final String? errorMessage;
  
  /// A function to retry the data loading operation if it failed.
  final VoidCallback? onRetry;
  
  /// The widget to display when data is successfully loaded.
  final Widget Function(T data) builder;
  
  /// A custom loading widget to show while data is being loaded.
  final Widget? loadingWidget;
  
  /// The message to display while data is being loaded.
  final String loadingMessage;
  
  /// A widget to display when the data is empty.
  final Widget? emptyWidget;
  
  /// The message to display when the data is empty.
  final String emptyMessage;
  
  /// Creates a [NetworkErrorHandler] widget.
  ///
  /// The [builder] parameter is required and is called when data is successfully loaded.
  /// The [data] parameter is the data being loaded.
  /// The [isLoading] parameter indicates whether data is currently being loaded.
  /// The [errorMessage] parameter is an error message to display if the data loading failed.
  /// The [onRetry] parameter is a function to retry the data loading operation if it failed.
  /// The [loadingWidget] parameter is a custom loading widget to show while data is being loaded.
  /// The [loadingMessage] parameter is the message to display while data is being loaded.
  /// The [emptyWidget] parameter is a widget to display when the data is empty.
  /// The [emptyMessage] parameter is the message to display when the data is empty.
  const NetworkErrorHandler({
    Key? key,
    required this.data,
    required this.isLoading,
    this.errorMessage,
    this.onRetry,
    required this.builder,
    this.loadingWidget,
    this.loadingMessage = 'Loading data...',
    this.emptyWidget,
    this.emptyMessage = 'No data available',
  }) : super(key: key);

  /// Helper method to determine if the data is empty
  bool _isDataEmpty() {
    if (data == null) return true;
    
    if (data is List) return (data as List).isEmpty;
    if (data is Map) return (data as Map).isEmpty;
    if (data is String) return (data as String).isEmpty;
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (isLoading) {
      return loadingWidget ?? _buildDefaultLoadingWidget();
    }
    
    // Show error state
    if (errorMessage != null) {
      if (errorMessage!.toLowerCase().contains('network') || 
          errorMessage!.toLowerCase().contains('connect')) {
        return NetworkErrorWidget(onRetry: onRetry);
      }
      
      return CustomErrorWidget(
        message: errorMessage!,
        onRetry: onRetry,
      );
    }
    
    // Show empty state
    if (data == null || _isDataEmpty()) {
      return emptyWidget ?? _buildDefaultEmptyWidget();
    }
    
    // Show successfully loaded data
    return builder(data as T);
  }
  
  /// Builds a default loading widget
  Widget _buildDefaultLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            loadingMessage,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Builds a default empty state widget
  Widget _buildDefaultEmptyWidget() {
    return NoDataWidget(
      message: emptyMessage,
      onAction: onRetry,
      actionText: onRetry != null ? 'Refresh' : null,
    );
  }
}

/// A specialized version of [NetworkErrorHandler] for handling list data.
class ListNetworkErrorHandler<T> extends StatelessWidget {
  /// The list data being loaded.
  final List<T>? data;
  
  /// Whether the data is currently being loaded.
  final bool isLoading;
  
  /// An error message to display if the data loading failed.
  final String? errorMessage;
  
  /// A function to retry the data loading operation if it failed.
  final VoidCallback? onRetry;
  
  /// The widget to display when data is successfully loaded.
  final Widget Function(List<T> data) builder;
  
  /// A custom loading widget to show while data is being loaded.
  final Widget? loadingWidget;
  
  /// The message to display while data is being loaded.
  final String loadingMessage;
  
  /// A widget to display when the list is empty.
  final Widget? emptyWidget;
  
  /// The message to display when the list is empty.
  final String emptyMessage;
  
  /// Creates a [ListNetworkErrorHandler] widget.
  const ListNetworkErrorHandler({
    Key? key,
    required this.data,
    required this.isLoading,
    this.errorMessage,
    this.onRetry,
    required this.builder,
    this.loadingWidget,
    this.loadingMessage = 'Loading data...',
    this.emptyWidget,
    this.emptyMessage = 'No items found',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NetworkErrorHandler<List<T>>(
      data: data,
      isLoading: isLoading,
      errorMessage: errorMessage,
      onRetry: onRetry,
      builder: builder,
      loadingWidget: loadingWidget,
      loadingMessage: loadingMessage,
      emptyWidget: emptyWidget,
      emptyMessage: emptyMessage,
    );
  }
}