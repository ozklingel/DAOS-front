import 'package:dio/dio.dart';
import 'package:taskmail/core/errors/app_exception.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: queryParameters);
      return _parse(response.data, parser);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _parse(response.data, parser);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(path, data: data);
      return _parse(response.data, parser);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete<dynamic>(path);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  T _parse<T>(dynamic data, T Function(dynamic data)? parser) {
    if (parser != null) return parser(data);
    return data as T;
  }

  AppException _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = _extractMessage(e.response?.data);

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException(message ?? 'Connection timed out.');
    }

    if (statusCode == 401) {
      return UnauthorizedException(message ?? 'Session expired.');
    }

    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return ValidationException(message ?? 'Invalid request.');
    }

    return ServerException(message ?? 'Server error occurred.');
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String?;
    }
    return null;
  }
}
