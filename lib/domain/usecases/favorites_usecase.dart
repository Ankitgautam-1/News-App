import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:news_app/domain/repository/failure.dart';
import 'package:news_app/domain/repository/news_repository.dart';
import 'package:news_app/domain/entity/article.dart';

class GetFavorites {
  final INewsRepository repository;

  GetFavorites(this.repository);

  Future<Either<Failure, List<Article>>> call() {
    return repository.getFavorites();
  }
}

class AddToFavorites {
  final INewsRepository repository;

  AddToFavorites(this.repository);

  Future<Either<Failure, void>> call(AddToFavoritesParams params) {
    return repository.addToFavorites(params.article);
  }
}

class AddToFavoritesParams extends Equatable {
  final Article article;

  const AddToFavoritesParams(this.article);

  @override
  List<Object?> get props => [article];
}

class RemoveFromFavorites {
  final INewsRepository repository;

  RemoveFromFavorites(this.repository);

  Future<Either<Failure, void>> call(RemoveFromFavoritesParams params) {
    return repository.removeFromFavorites(params.articleId);
  }
}

class RemoveFromFavoritesParams extends Equatable {
  final String articleId;

  const RemoveFromFavoritesParams(this.articleId);

  @override
  List<Object?> get props => [articleId];
}

class IsFavorited {
  final INewsRepository repository;

  IsFavorited(this.repository);

  Future<Either<Failure, bool>> call(IsFavoritedParams params) {
    return repository.isFavorited(params.articleId);
  }
}

class IsFavoritedParams extends Equatable {
  final String articleId;

  const IsFavoritedParams(this.articleId);

  @override
  List<Object?> get props => [articleId];
}
