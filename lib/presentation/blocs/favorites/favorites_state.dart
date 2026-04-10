part of 'favorites_bloc.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<Article> articles;

  const FavoritesLoaded({required this.articles});

  @override
  List<Object?> get props => [articles];
}

class FavoritesEmpty extends FavoritesState {
  final String message;

  const FavoritesEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}
