import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../error/exceptions.dart';

/// Network client wrapper around Dio for handling HTTP requests,
/// timeouts, and error mappings for public endpoints.
class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.baseUrl,
                connectTimeout: AppConfig.connectTimeout,
                receiveTimeout: AppConfig.receiveTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  /// Sends a GET request and handles errors appropriately.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: 'Unexpected network error: $e');
    }
  }

  AppException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timed out. Please check your internet connection.',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'Unable to connect to the server. Please verify your internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String message = 'Server error occurred.';

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          message = responseData['message'] as String;
        } else if (statusCode == 404) {
          message = 'The requested title was not found.';
        }

        return ServerException(
          message: message,
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return const ServerException(message: 'Request was cancelled.');
      default:
        return ServerException(
          message: e.message ?? 'An unknown network error occurred.',
        );
    }
  }
}
