import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:news_app/domain/repository/news_repository.dart';
import 'package:news_app/domain/repository/failure.dart';
import 'package:news_app/domain/entity/article.dart';
import 'package:news_app/data/datasources/remote/news_api_data_source.dart';
import 'package:news_app/data/datasources/local/favorites_local_data_source.dart';
import 'package:news_app/data/models/news_article_model.dart';
import 'package:news_app/utils/error/error_handling.dart';

/// Implementation of INewsRepository
class NewsRepositoryImpl implements INewsRepository {
  final RemoteNewsDataSource remoteDataSource;
  final LocalNewsDataSource localDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Article>>> getTopHeadlines({
    String? country,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final articles = await remoteDataSource.getTopHeadlines(
        country: country,
        category: category,
        page: page,
      );

      // Enrich articles with favorite status
      final enrichedArticles = await _enrichArticlesWithFavoriteStatus(
        articles.map((model) => model).toList(),
      );

      return Right(enrichedArticles);
    } catch (e) {
      log('Error fetching top headlines: ${e.toString()}');
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Article>>> searchArticles({
    required String query,
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final articles = await remoteDataSource.searchArticles(
        query: query,
        page: page,
      );

      // Enrich articles with favorite status
      final enrichedArticles = await _enrichArticlesWithFavoriteStatus(
        articles.map((model) => model).toList(),
      );

      return Right(enrichedArticles);
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Article>>> getFavorites() async {
    try {
      final articles = await localDataSource.getFavorites();
      final articleList = articles.map((model) => model).toList();
      return Right(articleList);
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(Article article) async {
    try {
      final model = ArticleModel(
        id: article.id,
        source: article.source,
        sourceName: article.sourceName,
        author: article.author,
        title: article.title,
        description: article.description,
        url: article.url,
        urlToImage: article.urlToImage,
        publishedAt: article.publishedAt,
        content: article.content,
        isFavorite: true,
      );
      await localDataSource.addToFavorites(model);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(String articleId) async {
    try {
      await localDataSource.removeFromFavorites(articleId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorited(String articleId) async {
    try {
      final isFavorited = await localDataSource.isFavorited(articleId);
      return Right(isFavorited);
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  /// Enrich articles with favorite status from local storage
  Future<List<Article>> _enrichArticlesWithFavoriteStatus(
    List<Article> articles,
  ) async {
    final enrichedArticles = <Article>[];

    for (final article in articles) {
      final isFavorite = await localDataSource.isFavorited(article.id ?? '');
      enrichedArticles.add(article.copyWith(isFavorite: isFavorite));
    }

    return enrichedArticles;
  }
}
