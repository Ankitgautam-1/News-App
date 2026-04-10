import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app/domain/entity/article.dart';
import 'package:news_app/domain/usecases/favorites_usecase.dart';
import 'package:news_app/utils/error/error_handling.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavorites getFavoritesUseCase;
  final RemoveFromFavorites removeFromFavoritesUseCase;

  FavoritesBloc({
    required this.getFavoritesUseCase,
    required this.removeFromFavoritesUseCase,
  }) : super(const FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<RemoveFavorite>(_onRemoveFavorite);
    on<ClearAllFavorites>(_onClearAllFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());

    final result = await getFavoritesUseCase();

    result.fold(
      (failure) {
        emit(FavoritesError(ErrorHandler.getErrorMessage(failure)));
      },
      (articles) {
        if (articles.isEmpty) {
          emit(const FavoritesEmpty('No favorite articles yet'));
        } else {
          emit(FavoritesLoaded(articles: articles));
        }
      },
    );
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;

    if (currentState is FavoritesLoaded) {
      final result = await removeFromFavoritesUseCase(
        RemoveFromFavoritesParams(event.articleId),
      );

      result.fold(
        (failure) {
          emit(FavoritesError(ErrorHandler.getErrorMessage(failure)));
        },
        (_) {
          final updatedArticles = currentState.articles
              .where((a) => a.id != event.articleId)
              .toList();

          if (updatedArticles.isEmpty) {
            emit(const FavoritesEmpty('No favorite articles yet'));
          } else {
            emit(FavoritesLoaded(articles: updatedArticles));
          }
        },
      );
    }
  }

  Future<void> _onClearAllFavorites(
    ClearAllFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;

    if (currentState is FavoritesLoaded) {
      // Remove all favorites one by one
      // In production, consider batch delete in datasource
      for (final article in currentState.articles) {
        await removeFromFavoritesUseCase(
          RemoveFromFavoritesParams(article.id ?? ''),
        );
      }

      emit(const FavoritesEmpty('Favorites cleared'));
    }
  }
}
