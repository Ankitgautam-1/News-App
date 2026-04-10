part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {
  const LoadFavorites();
}

class RemoveFavorite extends FavoritesEvent {
  final String articleId;

  const RemoveFavorite(this.articleId);

  @override
  List<Object?> get props => [articleId];
}

class ClearAllFavorites extends FavoritesEvent {
  const ClearAllFavorites();
}
