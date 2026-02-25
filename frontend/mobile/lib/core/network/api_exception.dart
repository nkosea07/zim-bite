import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final DioException? dioException;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.dioException,
  });

  /// Wraps a [DioException] into a user-friendly [ApiException].
  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timed out. Please check your internet and try again.',
          dioException: error,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Unable to connect to the server. Please check your internet connection.',
          dioException: error,
        );

      case DioExceptionType.badResponse:
        return _fromStatusCode(
          error.response?.statusCode,
          error.response?.data,
          error,
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          dioException: error,
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Secure connection could not be established.',
          dioException: error,
        );

      case DioExceptionType.unknown:
        return ApiException(
          message: 'An unexpected error occurred. Please try again.',
          dioException: error,
        );
    }
  }

  static ApiException _fromStatusCode(
    int? statusCode,
    dynamic data,
    DioException error,
  ) {
    final serverMessage = _extractServerMessage(data);

    final String message;
    switch (statusCode) {
      case 401:
        message = 'Your session has expired. Please log in again.';
      case 403:
        message = 'You do not have permission to perform this action.';
      case 404:
        message = 'The requested resource was not found.';
      case 422:
        message = serverMessage ?? 'The submitted data is invalid. Please review and try again.';
      case 429:
        message = 'Too many requests. Please wait a moment and try again.';
      case final code when code != null && code >= 500:
        message = 'Something went wrong on our end. Please try again later.';
      default:
        message = serverMessage ?? 'An unexpected error occurred (code $statusCode).';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
      dioException: error,
    );
  }

  /// Tries to pull a human-readable message from the server response body.
  static String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }
    return null;
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 422;
  bool get isServerError => (statusCode ?? 0) >= 500;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
