import 'package:fpdart/fpdart.dart';
import 'package:news_app/domain/repository/failure.dart';
import 'package:news_app/domain/entity/article.dart';

abstract class INewsRepository {
  Future<Either<Failure, List<Article>>> getTopHeadlines({
    String? country,
    String? category,
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, List<Article>>> searchArticles({
    required String query,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, List<Article>>> getFavorites();

  Future<Either<Failure, void>> addToFavorites(Article article);

  Future<Either<Failure, void>> removeFromFavorites(String articleId);

  Future<Either<Failure, bool>> isFavorited(String articleId);
}
