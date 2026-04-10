import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:news_app/domain/repository/failure.dart';
import 'package:news_app/domain/repository/news_repository.dart';
import 'package:news_app/domain/entity/article.dart';

class SearchArticles {
  final INewsRepository repository;

  SearchArticles(this.repository);

  Future<Either<Failure, List<Article>>> call(SearchArticlesParams params) {
    return repository.searchArticles(query: params.query, page: params.page);
  }
}

class SearchArticlesParams extends Equatable {
  final String query;
  final int page;

  const SearchArticlesParams({required this.query, this.page = 1});

  @override
  List<Object?> get props => [query, page];
}
