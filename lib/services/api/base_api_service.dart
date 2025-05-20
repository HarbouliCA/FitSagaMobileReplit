import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitsaga/services/api/network_interceptor.dart';
import 'package:fitsaga/providers/app_state_provider.dart';

/// Base class for all API services, providing common functionality
/// for making HTTP requests with error handling.
class BaseApiService {
  final http.Client _client;
  final AppStateProvider? appStateProvider;
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final int timeout;

  /// Creates a BaseApiService with the specified parameters.
  ///
  /// [client] - Optional HTTP client, useful for testing.
  /// [appStateProvider] - Optional app state provider for updating connection status.
  /// [baseUrl] - Base URL for API requests.
  /// [defaultHeaders] - Default headers to include in all requests.
  /// [timeout] - Timeout duration in seconds.
  BaseApiService({
    http.Client? client,
    this.appStateProvider,
    required this.baseUrl,
    Map<String, String>? defaultHeaders,
    this.timeout = 30,
  }) : 
    _client = client ?? http.Client(),
    defaultHeaders = defaultHeaders ?? {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

  /// Makes a GET request to the specified endpoint.
  ///
  /// [endpoint] - The API endpoint to call.
  /// [queryParams] - Optional query parameters.
  /// [headers] - Optional additional headers.
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    return NetworkInterceptor.safeApiCall(() async {
      final uri = _buildUri(endpoint, queryParams);
      final mergedHeaders = _mergeHeaders(headers);
      
      final response = await _client
          .get(uri, headers: mergedHeaders)
          .timeout(Duration(seconds: timeout));
      
      return NetworkInterceptor.processResponse(response);
    });
  }

  /// Makes a POST request to the specified endpoint.
  ///
  /// [endpoint] - The API endpoint to call.
  /// [body] - The request body.
  /// [queryParams] - Optional query parameters.
  /// [headers] - Optional additional headers.
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    return NetworkInterceptor.safeApiCall(() async {
      final uri = _buildUri(endpoint, queryParams);
      final mergedHeaders = _mergeHeaders(headers);
      
      final encodedBody = body != null ? json.encode(body) : null;
      
      final response = await _client
          .post(uri, headers: mergedHeaders, body: encodedBody)
          .timeout(Duration(seconds: timeout));
      
      return NetworkInterceptor.processResponse(response);
    });
  }

  /// Makes a PUT request to the specified endpoint.
  ///
  /// [endpoint] - The API endpoint to call.
  /// [body] - The request body.
  /// [queryParams] - Optional query parameters.
  /// [headers] - Optional additional headers.
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    return NetworkInterceptor.safeApiCall(() async {
      final uri = _buildUri(endpoint, queryParams);
      final mergedHeaders = _mergeHeaders(headers);
      
      final encodedBody = body != null ? json.encode(body) : null;
      
      final response = await _client
          .put(uri, headers: mergedHeaders, body: encodedBody)
          .timeout(Duration(seconds: timeout));
      
      return NetworkInterceptor.processResponse(response);
    });
  }

  /// Makes a DELETE request to the specified endpoint.
  ///
  /// [endpoint] - The API endpoint to call.
  /// [queryParams] - Optional query parameters.
  /// [headers] - Optional additional headers.
  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    return NetworkInterceptor.safeApiCall(() async {
      final uri = _buildUri(endpoint, queryParams);
      final mergedHeaders = _mergeHeaders(headers);
      
      final response = await _client
          .delete(uri, headers: mergedHeaders)
          .timeout(Duration(seconds: timeout));
      
      return NetworkInterceptor.processResponse(response);
    });
  }

  /// Makes a PATCH request to the specified endpoint.
  ///
  /// [endpoint] - The API endpoint to call.
  /// [body] - The request body.
  /// [queryParams] - Optional query parameters.
  /// [headers] - Optional additional headers.
  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    return NetworkInterceptor.safeApiCall(() async {
      final uri = _buildUri(endpoint, queryParams);
      final mergedHeaders = _mergeHeaders(headers);
      
      final encodedBody = body != null ? json.encode(body) : null;
      
      final response = await _client
          .patch(uri, headers: mergedHeaders, body: encodedBody)
          .timeout(Duration(seconds: timeout));
      
      return NetworkInterceptor.processResponse(response);
    });
  }

  /// Closes the HTTP client.
  void dispose() {
    _client.close();
  }

  /// Builds a URI from the base URL, endpoint, and query parameters.
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParams) {
    var path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    var url = '$baseUrl$path';
    
    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((entry) => '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}')
          .join('&');
      url = '$url?$queryString';
    }
    
    return Uri.parse(url);
  }

  /// Merges the default headers with the provided headers.
  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    final mergedHeaders = Map<String, String>.from(defaultHeaders);
    
    if (headers != null) {
      mergedHeaders.addAll(headers);
    }
    
    return mergedHeaders;
  }
}