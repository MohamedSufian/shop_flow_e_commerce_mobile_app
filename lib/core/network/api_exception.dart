import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const ApiException('No internet connection.');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final msg = e.response?.data is Map ? e.response?.data['message'] : null;
        return ApiException(msg?.toString() ?? 'Server error ($code).', statusCode: code);
      case DioExceptionType.cancel:
        return const ApiException('Request cancelled.');
      default:
        return const ApiException('Something went wrong. Please try again.');
    }
  }

  @override
  String toString() => message;
}
