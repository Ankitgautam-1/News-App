import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:news_app/domain/repository/failure.dart';
import 'package:news_app/domain/repository/news_repository.dart';
import 'package:news_app/domain/entity/article.dart';

class GetTopHeadlines {
  final INewsRepository repository;

  GetTopHeadlines(this.repository);

  Future<Either<Failure, List<Article>>> call(GetTopHeadlinesParams params) {
    return repository.getTopHeadlines(
      country: params.country,
      category: params.category,
      page: params.page,
    );
  }
}

class GetTopHeadlinesParams extends Equatable {
  final String? country;
  final String? category;
  final int page;

  const GetTopHeadlinesParams({this.country, this.category, this.page = 1});

  @override
  List<Object?> get props => [country, category, page];
}
