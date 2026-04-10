import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:news_app/domain/repository/failure.dart';
import 'package:news_app/utils/error/exceptions.dart';

/// Error handling utilities
/// Converts exceptions to failures and provides error mapping
class ErrorHandler {
  static Failure mapExceptionToFailure(dynamic exception) {
    log("Mapping exception to failure: ${exception.toString()}");
    if (exception is DioException) {
      return _mapDioExceptionToFailure(exception);
    } else if (exception is StateError) {
      return UnknownFailure(exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is Exception) {
      return UnknownFailure(exception.toString());
    }
    return const UnknownFailure('An unexpected error occurred');
  }

  static Failure _mapDioExceptionToFailure(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkFailure('Connection timeout. Please try again.');
      case DioExceptionType.sendTimeout:
        return const NetworkFailure('Send timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Receive timeout. Please try again.');
      case DioExceptionType.badResponse:
        return _mapStatusCodeToFailure(
          dioException.response?.statusCode,
          dioException.message,
        );
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'No internet connection. Please check your network.',
        );
      case DioExceptionType.unknown:
        return NetworkFailure(
          dioException.message ?? 'An unexpected error occurred',
        );
      default:
        return NetworkFailure(dioException.message ?? 'Unknown error occurred');
    }
  }

  static Failure _mapStatusCodeToFailure(int? statusCode, String? message) {
    final errorMessage = message ?? 'Server error occurred';

    if (statusCode == null) {
      return UnknownFailure(errorMessage);
    }

    if (statusCode >= 500) {
      return ServerFailure(errorMessage);
    } else if (statusCode >= 400) {
      return NetworkFailure(errorMessage);
    }

    return UnknownFailure(errorMessage);
  }

  static String getErrorMessage(Failure failure) {
    return failure.message;
  }
}
