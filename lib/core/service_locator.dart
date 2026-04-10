import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_app/core/network/api_client.dart';
import 'package:news_app/data/datasources/local/favorites_local_data_source.dart';
import 'package:news_app/data/datasources/remote/news_api_data_source.dart';
import 'package:news_app/data/repositories/news_repository_impl.dart';
import 'package:news_app/domain/repository/news_repository.dart';
import 'package:news_app/domain/usecases/favorites_usecase.dart';
import 'package:news_app/domain/usecases/get_top_headlines.dart';
import 'package:news_app/domain/usecases/search_articles.dart';
import 'package:news_app/presentation/blocs/article_detail/article_detail_bloc.dart';
import 'package:news_app/presentation/blocs/category/category_bloc.dart';
import 'package:news_app/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:news_app/presentation/blocs/news_feed/news_feed_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  await Hive.initFlutter();

  serviceLocator.registerSingleton<ApiClient>(ApiClient());

  serviceLocator.registerSingleton<RemoteNewsDataSource>(
    RemoteNewsDataSourceImpl(apiClient: serviceLocator<ApiClient>()),
  );

  final localDataSource = LocalNewsDataSourceImpl();
  await localDataSource.initialize();
  serviceLocator.registerSingleton<LocalNewsDataSource>(localDataSource);

  serviceLocator.registerSingleton<INewsRepository>(
    NewsRepositoryImpl(
      remoteDataSource: serviceLocator<RemoteNewsDataSource>(),
      localDataSource: serviceLocator<LocalNewsDataSource>(),
    ),
  );

  serviceLocator.registerSingleton<GetTopHeadlines>(
    GetTopHeadlines(serviceLocator<INewsRepository>()),
  );

  serviceLocator.registerSingleton<SearchArticles>(
    SearchArticles(serviceLocator<INewsRepository>()),
  );

  serviceLocator.registerSingleton<GetFavorites>(
    GetFavorites(serviceLocator<INewsRepository>()),
  );

  serviceLocator.registerSingleton<AddToFavorites>(
    AddToFavorites(serviceLocator<INewsRepository>()),
  );

  serviceLocator.registerSingleton<RemoveFromFavorites>(
    RemoveFromFavorites(serviceLocator<INewsRepository>()),
  );

  serviceLocator.registerSingleton<IsFavorited>(
    IsFavorited(serviceLocator<INewsRepository>()),
  );

  serviceLocator.registerSingleton<NewsFeedBloc>(
    NewsFeedBloc(
      getTopHeadlinesUseCase: serviceLocator<GetTopHeadlines>(),
      addToFavoritesUseCase: serviceLocator<AddToFavorites>(),
      removeFromFavoritesUseCase: serviceLocator<RemoveFromFavorites>(),
      isFavoritedUseCase: serviceLocator<IsFavorited>(),
    ),
  );

  serviceLocator.registerSingleton<ArticleDetailBloc>(
    ArticleDetailBloc(
      addToFavoritesUseCase: serviceLocator<AddToFavorites>(),
      removeFromFavoritesUseCase: serviceLocator<RemoveFromFavorites>(),
      isFavoritedUseCase: serviceLocator<IsFavorited>(),
    ),
  );

  serviceLocator.registerSingleton<FavoritesBloc>(
    FavoritesBloc(
      getFavoritesUseCase: serviceLocator<GetFavorites>(),
      removeFromFavoritesUseCase: serviceLocator<RemoveFromFavorites>(),
    ),
  );

  serviceLocator.registerSingleton<CategoryBloc>(CategoryBloc());
}
