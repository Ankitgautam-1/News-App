import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/network/network_helper.dart';
import 'package:news_app/domain/repository/failure.dart';
import 'package:news_app/utils/error/exceptions.dart';
import 'package:news_app/core/network/api_client.dart';
import 'package:news_app/data/models/news_article_model.dart';

/// Remote data source for fetching news articles from NewsAPI.org
abstract class RemoteNewsDataSource {
  /// Fetch top headlines
  Future<List<ArticleModel>> getTopHeadlines({
    String? country,
    String? category,
    int page = 1,
  });

  /// Search articles
  Future<List<ArticleModel>> searchArticles({
    required String query,
    int page = 1,
  });
}

/// Implementation of RemoteNewsDataSource using Dio
class RemoteNewsDataSourceImpl implements RemoteNewsDataSource {
  final ApiClient apiClient;

  RemoteNewsDataSourceImpl({required this.apiClient});

  @override
  Future<List<ArticleModel>> getTopHeadlines({
    String? country,
    String? category,
    int page = 1,
  }) async {
    try {
      if (!await NetworkHelper.checkConnectivity()) {
        log('Device is offline. Cannot fetch data from API.');
        throw NetworkException('No internet connection');
      }

      final response = await apiClient.get(
        '/top-headlines',
        queryParameters: {
          // Use default country if neither country nor category is provided
          'country': country ?? AppConstants.defaultCountry,
          if (category != null) 'category': category,
          'page': page,
          'pageSize': 20,
        },
      );

      final articles = (response.data['articles'] as List)
          .map((json) => ArticleModel.fromJson(json))
          .toList();

      return articles;
    } on DioException catch (e) {
      log('e: ${e.message}');
      throw NetworkException(e.message ?? 'Network error occurred');
    } catch (e) {
      if (e is NetworkException ||
          e is CacheException ||
          e is UnknownException) {
        rethrow;
      }
      log('error: ${e.runtimeType}');

      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<ArticleModel>> searchArticles({
    required String query,
    int page = 1,
  }) async {
    try {
      final response = await apiClient.get(
        '/everything',
        queryParameters: {
          'q': query,
          'page': page,
          'pageSize': 20,
          'sortBy': 'publishedAt',
        },
      );

      final articles = (response.data['articles'] as List)
          .map((json) => ArticleModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return articles;
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
