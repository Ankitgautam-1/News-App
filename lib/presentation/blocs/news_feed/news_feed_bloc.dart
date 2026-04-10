import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app/domain/entity/article.dart';
import 'package:news_app/domain/repository/failure.dart';
import 'package:news_app/domain/usecases/favorites_usecase.dart';
import 'package:news_app/domain/usecases/get_top_headlines.dart';
import 'package:news_app/utils/error/error_handling.dart';

part 'news_feed_event.dart';
part 'news_feed_state.dart';

class NewsFeedBloc extends Bloc<NewsFeedEvent, NewsFeedState> {
  final GetTopHeadlines getTopHeadlinesUseCase;
  final AddToFavorites addToFavoritesUseCase;
  final RemoveFromFavorites removeFromFavoritesUseCase;
  final IsFavorited isFavoritedUseCase;

  int _currentPage = 1;
  String? _currentCategory;
  final List<Article> _allArticles = [];

  NewsFeedBloc({
    required this.getTopHeadlinesUseCase,
    required this.addToFavoritesUseCase,
    required this.removeFromFavoritesUseCase,
    required this.isFavoritedUseCase,
  }) : super(const NewsFeedInitial()) {
    on<GetTopHeadlinesEvent>(_onGetTopHeadlines);
    on<LoadMoreHeadlinesEvent>(_onLoadMoreHeadlines);
    on<RefreshHeadlinesEvent>(_onRefreshHeadlines);
    on<ChangeCategory>(_onChangeCategory);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onGetTopHeadlines(
    GetTopHeadlinesEvent event,
    Emitter<NewsFeedState> emit,
  ) async {
    emit(const NewsFeedLoading());
    _currentPage = 1;
    _currentCategory = event.category;
    _allArticles.clear();

    final params = GetTopHeadlinesParams(
      country: event.country,
      category: event.category,
      page: _currentPage,
    );

    final result = await getTopHeadlinesUseCase(params);

    result.fold(
      (failure) {
        log('Error fetching top headlines: ${failure.toString()}');
        emit(NewsFeedError(failure));
      },
      (articles) {
        if (articles.isEmpty) {
          emit(const NewsFeedEmpty('No articles found'));
        } else {
          _allArticles.addAll(articles);
          emit(
            NewsFeedLoaded(
              articles: _allArticles,
              currentPage: _currentPage,
              hasMoreData: articles.length >= 20,
              category: _currentCategory,
            ),
          );
        }
      },
    );
  }

  Future<void> _onLoadMoreHeadlines(
    LoadMoreHeadlinesEvent event,
    Emitter<NewsFeedState> emit,
  ) async {
    final currentState = state;

    if (currentState is NewsFeedLoaded && currentState.hasMoreData) {
      _currentPage++;

      final params = GetTopHeadlinesParams(
        category: _currentCategory,
        page: _currentPage,
      );

      final result = await getTopHeadlinesUseCase(params);

      result.fold(
        (failure) {
          emit(
            NewsFeedPaginationError(
              message: ErrorHandler.getErrorMessage(failure),
              articles: _allArticles,
            ),
          );
        },
        (articles) {
          if (articles.isEmpty) {
            emit(
              NewsFeedLoaded(
                articles: _allArticles,
                currentPage: _currentPage,
                hasMoreData: false,
                category: _currentCategory,
              ),
            );
          } else {
            _allArticles.addAll(articles);
            emit(
              NewsFeedLoaded(
                articles: _allArticles,
                currentPage: _currentPage,
                hasMoreData: articles.length >= 20,
                category: _currentCategory,
              ),
            );
          }
        },
      );
    }
  }

  Future<void> _onRefreshHeadlines(
    RefreshHeadlinesEvent event,
    Emitter<NewsFeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is NewsFeedLoaded) {
      emit(NewsFeedRefreshing(articles: currentState.articles));
    }

    _currentPage = 1;
    _allArticles.clear();

    final params = GetTopHeadlinesParams(
      category: _currentCategory,
      page: _currentPage,
    );

    final result = await getTopHeadlinesUseCase(params);

    result.fold(
      (failure) {
        emit(NewsFeedError(failure));
      },
      (articles) {
        if (articles.isEmpty) {
          emit(const NewsFeedEmpty('No articles found'));
        } else {
          _allArticles.addAll(articles);
          emit(
            NewsFeedLoaded(
              articles: _allArticles,
              currentPage: _currentPage,
              hasMoreData: articles.length >= 20,
              category: _currentCategory,
            ),
          );
        }
      },
    );
  }

  Future<void> _onChangeCategory(
    ChangeCategory event,
    Emitter<NewsFeedState> emit,
  ) async {
    emit(const NewsFeedLoading());
    _currentPage = 1;
    _currentCategory = event.category;
    _allArticles.clear();

    final params = GetTopHeadlinesParams(
      category: event.category,
      page: _currentPage,
    );

    final result = await getTopHeadlinesUseCase(params);

    result.fold(
      (failure) {
        emit(NewsFeedError(failure));
      },
      (articles) {
        if (articles.isEmpty) {
          emit(const NewsFeedEmpty('No articles found for this category'));
        } else {
          _allArticles.addAll(articles);
          emit(
            NewsFeedLoaded(
              articles: _allArticles,
              currentPage: _currentPage,
              hasMoreData: articles.length >= 20,
              category: _currentCategory,
            ),
          );
        }
      },
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<NewsFeedState> emit,
  ) async {
    final currentState = state;

    if (currentState is NewsFeedLoaded) {
      // Check if article is already favorited
      final checkResult = await isFavoritedUseCase(
        IsFavoritedParams(event.article.id ?? ''),
      );

      await checkResult.fold(
        (failure) async {
          log('Error checking favorite status: ${failure.toString()}');
        },
        (isFavorited) async {
          log('Article ID: ${event.article.id}, Is Favorited: $isFavorited');
          if (isFavorited) {
            // Remove from favorites
            final removeResult = await removeFromFavoritesUseCase(
              RemoveFromFavoritesParams(event.article.id ?? ''),
            );

            log('Removing from favorites: ${event.article.id}');

            removeResult.fold(
              (failure) {
                log('Error removing from favorites: ${failure.toString()}');
              },
              (_) {
                // Update article in list
                _updateArticleInList(event.article.copyWith(isFavorite: false));
                emit(
                  NewsFeedLoaded(
                    articles: _allArticles,
                    currentPage: _currentPage,
                    hasMoreData: currentState.hasMoreData,
                    category: _currentCategory,
                  ),
                );
              },
            );
          } else {
            // Add to favorites
            final addResult = await addToFavoritesUseCase(
              AddToFavoritesParams(event.article.copyWith(isFavorite: true)),
            );

            addResult.fold(
              (failure) {
                log('Error adding to favorites: ${failure.toString()}');
              },
              (_) {
                // Update article in list
                _updateArticleInList(event.article.copyWith(isFavorite: true));
                emit(
                  NewsFeedLoaded(
                    articles: _allArticles,
                    currentPage: _currentPage,
                    hasMoreData: currentState.hasMoreData,
                    category: _currentCategory,
                  ),
                );
              },
            );
          }
        },
      );
    }
  }

  /// Update article in the articles list
  void _updateArticleInList(Article updatedArticle) {
    final index = _allArticles.indexWhere((a) => a.id == updatedArticle.id);
    if (index != -1) {
      _allArticles[index] = updatedArticle;
    }
  }
}
