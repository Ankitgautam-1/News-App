import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/domain/entity/article.dart';
import 'package:news_app/domain/repository/failure.dart';
import 'package:news_app/domain/repository/news_repository.dart';
import 'package:news_app/domain/usecases/search_articles.dart';

class _MockNewsRepository extends Mock implements INewsRepository {}

void main() {
  group('SearchArticles', () {
    test('delegates to repository with correct params', () async {
      final repo = _MockNewsRepository();
      final usecase = SearchArticles(repo);

      const params = SearchArticlesParams(query: 'flutter', page: 3);
      final articles = [const Article(id: 'a1', title: 'Flutter news')];

      when(() => repo.searchArticles(query: 'flutter', page: 3)).thenAnswer(
        (_) async => Right(articles),
      );

      final result = await usecase(params);

      expect(result, Right<Failure, List<Article>>(articles));
      verify(() => repo.searchArticles(query: 'flutter', page: 3)).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}

