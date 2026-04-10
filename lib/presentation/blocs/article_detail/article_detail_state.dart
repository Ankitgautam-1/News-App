part of 'article_detail_bloc.dart';

abstract class ArticleDetailState extends Equatable {
  const ArticleDetailState();

  @override
  List<Object?> get props => [];
}

class ArticleDetailInitial extends ArticleDetailState {
  const ArticleDetailInitial();
}

class ArticleDetailLoading extends ArticleDetailState {
  const ArticleDetailLoading();
}

class ArticleDetailLoaded extends ArticleDetailState {
  final Article article;
  final bool favoriteUpdated;

  const ArticleDetailLoaded({
    required this.article,
    this.favoriteUpdated = false,
  });

  @override
  List<Object?> get props => [article, favoriteUpdated];
}

class ArticleDetailError extends ArticleDetailState {
  final String message;
  final Article? article;

  const ArticleDetailError(this.message, {this.article});

  @override
  List<Object?> get props => [message, article];
}
