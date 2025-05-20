import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Custom exception class for API errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? response;

  ApiException({
    required this.message,
    this.statusCode,
    this.response,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status code: $statusCode)';
  }
}

/// A middleware for handling API responses and standardizing error handling.
class NetworkInterceptor {
  /// Processes an HTTP response and returns the data if successful
  /// or throws an ApiException if the request failed.
  ///
  /// [response] - The HTTP response to process.
  /// [expectedStatusCode] - The expected status code for a successful response, defaults to 200.
  static dynamic processResponse(
    http.Response response, {
    int expectedStatusCode = 200,
  }) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    // Check if request was successful based on status code
    if (statusCode >= 200 && statusCode < 300) {
      // If body is empty but request was successful, return empty map
      if (responseBody.isEmpty) {
        return {};
      }

      try {
        // Try to parse response as JSON
        return json.decode(responseBody);
      } catch (e) {
        // If response is not valid JSON but status code is success,
        // just return the raw body
        return responseBody;
      }
    } else {
      // Try to parse error response as JSON to get error message
      Map<String, dynamic>? errorResponse;
      String errorMessage;
      
      try {
        errorResponse = json.decode(responseBody) as Map<String, dynamic>;
        errorMessage = errorResponse['message'] ?? errorResponse['error'] ?? 
                     'Request failed with status code: $statusCode';
      } catch (e) {
        errorMessage = 'Request failed with status code: $statusCode';
      }

      // Handle specific status codes
      switch (statusCode) {
        case 400:
          throw ApiException(
            message: 'Bad request: $errorMessage',
            statusCode: statusCode,
            response: errorResponse,
          );
        case 401:
          throw ApiException(
            message: 'Unauthorized: $errorMessage',
            statusCode: statusCode,
            response: errorResponse,
          );
        case 403:
          throw ApiException(
            message: 'Forbidden: $errorMessage',
            statusCode: statusCode,
            response: errorResponse,
          );
        case 404:
          throw ApiException(
            message: 'Not found: $errorMessage',
            statusCode: statusCode,
            response: errorResponse,
          );
        case 408:
          throw ApiException(
            message: 'Request timeout: $errorMessage',
            statusCode: statusCode,
            response: errorResponse,
          );
        case 429:
          throw ApiException(
            message: 'Too many requests: $errorMessage',
            statusCode: statusCode,
            response: errorResponse,
          );
        case 500:
        case 501:
        case 502:
        case 503:
        case 504:
          throw ApiException(
            message: 'Server error: $errorMessage',
            statusCode: statusCode,
            response: errorResponse,
          );
        default:
          throw ApiException(
            message: 'Request failed: $errorMessage',
            statusCode: statusCode,
            response: errorResponse,
          );
      }
    }
  }

  /// Safely executes an HTTP request function and handles common exceptions
  /// like SocketExceptions, TimeoutExceptions, etc.
  ///
  /// [requestFunction] - The async function that performs the HTTP request.
  static Future<dynamic> safeApiCall(Future<dynamic> Function() requestFunction) async {
    try {
      return await requestFunction();
    } on SocketException catch (e) {
      throw ApiException(
        message: 'No internet connection. Please check your network.',
        statusCode: null,
      );
    } on HttpException catch (e) {
      throw ApiException(
        message: 'HTTP error: ${e.message}',
        statusCode: null,
      );
    } on FormatException catch (e) {
      throw ApiException(
        message: 'Invalid response format: ${e.message}',
        statusCode: null,
      );
    } on TimeoutException catch (e) {
      throw ApiException(
        message: 'Request timed out. Please try again.',
        statusCode: null,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      
      throw ApiException(
        message: 'Unexpected error: $e',
        statusCode: null,
      );
    }
  }
}