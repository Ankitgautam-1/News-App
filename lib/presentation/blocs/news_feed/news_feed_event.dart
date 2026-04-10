part of 'news_feed_bloc.dart';

abstract class NewsFeedEvent extends Equatable {
  const NewsFeedEvent();

  @override
  List<Object?> get props => [];
}

class GetTopHeadlinesEvent extends NewsFeedEvent {
  final String? country;
  final String? category;

  const GetTopHeadlinesEvent({this.country, this.category});

  @override
  List<Object?> get props => [country, category];
}

class LoadMoreHeadlinesEvent extends NewsFeedEvent {
  const LoadMoreHeadlinesEvent();
}

/// Event to refresh the news feed
class RefreshHeadlinesEvent extends NewsFeedEvent {
  const RefreshHeadlinesEvent();
}

class ChangeCategory extends NewsFeedEvent {
  final String? category;

  const ChangeCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class ToggleFavoriteEvent extends NewsFeedEvent {
  final Article article;

  const ToggleFavoriteEvent(this.article);

  @override
  List<Object?> get props => [article];
}
