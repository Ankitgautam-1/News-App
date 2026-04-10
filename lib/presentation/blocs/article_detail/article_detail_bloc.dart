import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app/domain/entity/article.dart';
import 'package:news_app/domain/usecases/favorites_usecase.dart';
import 'package:news_app/utils/error/error_handling.dart';

part 'article_detail_event.dart';
part 'article_detail_state.dart';

class ArticleDetailBloc extends Bloc<ArticleDetailEvent, ArticleDetailState> {
  final AddToFavorites addToFavoritesUseCase;
  final RemoveFromFavorites removeFromFavoritesUseCase;
  final IsFavorited isFavoritedUseCase;

  ArticleDetailBloc({
    required this.addToFavoritesUseCase,
    required this.removeFromFavoritesUseCase,
    required this.isFavoritedUseCase,
  }) : super(const ArticleDetailInitial()) {
    on<LoadArticleDetail>(_onLoadArticleDetail);
    on<ToggleArticleFavorite>(_onToggleArticleFavorite);
  }

  Future<void> _onLoadArticleDetail(
    LoadArticleDetail event,
    Emitter<ArticleDetailState> emit,
  ) async {
    emit(const ArticleDetailLoading());

    final favResult = await isFavoritedUseCase(
      IsFavoritedParams(event.article.id ?? ''),
    );

    favResult.fold(
      (failure) {
        emit(
          ArticleDetailLoaded(
            article: event.article.copyWith(isFavorite: false),
          ),
        );
      },
      (isFavorited) {
        emit(
          ArticleDetailLoaded(
            article: event.article.copyWith(isFavorite: isFavorited),
          ),
        );
      },
    );
  }

  Future<void> _onToggleArticleFavorite(
    ToggleArticleFavorite event,
    Emitter<ArticleDetailState> emit,
  ) async {
    final currentState = state;

    if (currentState is ArticleDetailLoaded) {
      final article = currentState.article;
      final newFavoriteStatus = !article.isFavorite;

      if (newFavoriteStatus) {
        // Add to favorites
        final result = await addToFavoritesUseCase(
          AddToFavoritesParams(article.copyWith(isFavorite: true)),
        );

        result.fold(
          (failure) {
            emit(
              ArticleDetailError(
                ErrorHandler.getErrorMessage(failure),
                article: article,
              ),
            );
          },
          (_) {
            emit(
              ArticleDetailLoaded(
                article: article.copyWith(isFavorite: true),
                favoriteUpdated: true,
              ),
            );
          },
        );
      } else {
        final result = await removeFromFavoritesUseCase(
          RemoveFromFavoritesParams(article.id ?? ''),
        );

        result.fold(
          (failure) {
            emit(
              ArticleDetailError(
                ErrorHandler.getErrorMessage(failure),
                article: article,
              ),
            );
          },
          (_) {
            emit(
              ArticleDetailLoaded(
                article: article.copyWith(isFavorite: false),
                favoriteUpdated: true,
              ),
            );
          },
        );
      }
    }
  }
}
