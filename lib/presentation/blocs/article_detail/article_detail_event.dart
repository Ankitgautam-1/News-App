part of 'article_detail_bloc.dart';

abstract class ArticleDetailEvent extends Equatable {
  const ArticleDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadArticleDetail extends ArticleDetailEvent {
  final Article article;

  const LoadArticleDetail(this.article);

  @override
  List<Object?> get props => [article];
}

class ToggleArticleFavorite extends ArticleDetailEvent {
  const ToggleArticleFavorite();
}
