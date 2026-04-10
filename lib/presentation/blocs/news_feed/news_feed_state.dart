part of 'news_feed_bloc.dart';

abstract class NewsFeedState extends Equatable {
  const NewsFeedState();

  @override
  List<Object?> get props => [];
}

class NewsFeedInitial extends NewsFeedState {
  const NewsFeedInitial();
}

class NewsFeedLoading extends NewsFeedState {
  const NewsFeedLoading();
}

class NewsFeedLoaded extends NewsFeedState {
  final List<Article> articles;
  final int currentPage;
  final bool hasMoreData;
  final String? category;

  const NewsFeedLoaded({
    required this.articles,
    this.currentPage = 1,
    this.hasMoreData = true,
    this.category,
  });

  @override
  List<Object?> get props => [articles, currentPage, hasMoreData, category];
}

class NewsFeedRefreshing extends NewsFeedState {
  final List<Article> articles;

  const NewsFeedRefreshing({required this.articles});

  @override
  List<Object?> get props => [articles];
}

class NewsFeedError extends NewsFeedState {
  final Failure failure;

  const NewsFeedError(this.failure);

  @override
  List<Object?> get props => [failure];
}

class NewsFeedPaginationError extends NewsFeedState {
  final String message;
  final List<Article> articles;

  const NewsFeedPaginationError({
    required this.message,
    required this.articles,
  });

  @override
  List<Object?> get props => [message, articles];
}

class NewsFeedEmpty extends NewsFeedState {
  final String message;

  const NewsFeedEmpty(this.message);

  @override
  List<Object?> get props => [message];
}
