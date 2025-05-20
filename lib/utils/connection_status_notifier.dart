import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// A notifier class that monitors the network connection status
/// and provides updates when the status changes.
class ConnectionStatusNotifier extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  
  bool _isConnected = true;
  bool _isInitialized = false;
  ConnectivityResult _lastResult = ConnectivityResult.none;
  
  /// Whether the device is currently connected to any network
  bool get isConnected => _isConnected;
  
  /// Whether the initialization of connection monitoring has completed
  bool get isInitialized => _isInitialized;
  
  /// The last known connection result (wifi, mobile, none, etc.)
  ConnectivityResult get lastResult => _lastResult;
  
  /// Creates a new instance and starts monitoring connectivity
  ConnectionStatusNotifier() {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  /// Initialize connectivity monitoring and get initial connection status
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      _isInitialized = true;
    } catch (e) {
      // If connectivity check fails, assume we're not connected
      _isConnected = false;
      _lastResult = ConnectivityResult.none;
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  /// Update the connection status based on the connectivity result
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    _lastResult = result;
    _isConnected = result != ConnectivityResult.none;
    notifyListeners();
  }
  
  /// Force a manual check of current connectivity status
  Future<void> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      // If connectivity check fails, assume we're not connected
      _isConnected = false;
      _lastResult = ConnectivityResult.none;
      notifyListeners();
    }
  }
  
  /// Cancel the connectivity subscription when disposing
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}