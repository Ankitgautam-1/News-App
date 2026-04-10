import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/domain/entity/article.dart';
import 'package:news_app/domain/repository/failure.dart';
import 'package:news_app/domain/repository/news_repository.dart';
import 'package:news_app/domain/usecases/get_top_headlines.dart';

class _MockNewsRepository extends Mock implements INewsRepository {}

void main() {
  group('GetTopHeadlines', () {
    test('delegates to repository with correct params', () async {
      final repo = _MockNewsRepository();
      final usecase = GetTopHeadlines(repo);

      const params = GetTopHeadlinesParams(country: 'us', category: 'business', page: 2);
      final articles = [
        const Article(id: 'a1', title: 't1'),
        const Article(id: 'a2', title: 't2'),
      ];

      when(
        () => repo.getTopHeadlines(country: 'us', category: 'business', page: 2),
      ).thenAnswer((_) async => Right(articles));

      final result = await usecase(params);

      expect(result, Right<Failure, List<Article>>(articles));
      verify(() => repo.getTopHeadlines(country: 'us', category: 'business', page: 2)).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}

