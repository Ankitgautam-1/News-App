import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/data/datasources/local/favorites_local_data_source.dart';
import 'package:news_app/data/datasources/remote/news_api_data_source.dart';
import 'package:news_app/data/models/news_article_model.dart';
import 'package:news_app/data/repositories/news_repository_impl.dart';
import 'package:news_app/domain/entity/article.dart';
import 'package:news_app/domain/repository/failure.dart';
import 'package:news_app/utils/error/exceptions.dart';

class _MockRemoteDataSource extends Mock implements RemoteNewsDataSource {}

class _MockLocalDataSource extends Mock implements LocalNewsDataSource {}

void main() {
  group('NewsRepositoryImpl', () {
    test('getTopHeadlines enriches articles with favorite status', () async {
      final remote = _MockRemoteDataSource();
      final local = _MockLocalDataSource();
      final repo = NewsRepositoryImpl(remoteDataSource: remote, localDataSource: local);

      final models = <ArticleModel>[
        const ArticleModel(id: '1', title: 'One'),
        const ArticleModel(id: '2', title: 'Two'),
      ];

      when(() => remote.getTopHeadlines(country: any(named: 'country'), category: any(named: 'category'), page: any(named: 'page')))
          .thenAnswer((_) async => models);

      when(() => local.isFavorited('1')).thenAnswer((_) async => true);
      when(() => local.isFavorited('2')).thenAnswer((_) async => false);

      final result = await repo.getTopHeadlines(country: 'us', category: 'business', page: 1);

      expect(result.isRight(), isTrue);
      final list = (result as Right<Failure, List<Article>>).value;
      expect(list.map((a) => a.id), ['1', '2']);
      expect(list.map((a) => a.isFavorite), [true, false]);

      verify(() => remote.getTopHeadlines(country: 'us', category: 'business', page: 1)).called(1);
      verify(() => local.isFavorited('1')).called(1);
      verify(() => local.isFavorited('2')).called(1);
      verifyNoMoreInteractions(remote);
      verifyNoMoreInteractions(local);
    });

    test('getTopHeadlines maps NetworkException to NetworkFailure', () async {
      final remote = _MockRemoteDataSource();
      final local = _MockLocalDataSource();
      final repo = NewsRepositoryImpl(remoteDataSource: remote, localDataSource: local);

      when(() => remote.getTopHeadlines(country: any(named: 'country'), category: any(named: 'category'), page: any(named: 'page')))
          .thenThrow(NetworkException('No internet'));

      final result = await repo.getTopHeadlines(country: 'us', category: 'business', page: 1);

      expect(result.isLeft(), isTrue);
      final failure = (result as Left<Failure, List<Article>>).value;
      expect(failure, const NetworkFailure('No internet'));

      verify(() => remote.getTopHeadlines(country: 'us', category: 'business', page: 1)).called(1);
      verifyNoMoreInteractions(remote);
      verifyNoMoreInteractions(local);
    });

    test('getFavorites returns CacheFailure when local data source throws CacheException', () async {
      final remote = _MockRemoteDataSource();
      final local = _MockLocalDataSource();
      final repo = NewsRepositoryImpl(remoteDataSource: remote, localDataSource: local);

      when(() => local.getFavorites()).thenThrow(CacheException('boom'));

      final result = await repo.getFavorites();

      expect(result, const Left<Failure, List<Article>>(CacheFailure('boom')));
      verify(() => local.getFavorites()).called(1);
      verifyNoMoreInteractions(remote);
      verifyNoMoreInteractions(local);
    });
  });
}

