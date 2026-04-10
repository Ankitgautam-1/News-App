import 'package:equatable/equatable.dart';

/// Article entity - represents a news article
class Article extends Equatable {
  final String? id;
  final String? source;
  final String? sourceName;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;
  final bool isFavorite;

  const Article({
    this.id,
    this.source,
    this.sourceName,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.isFavorite = false,
  });

  /// Create a copy of this article with some fields replaced
  Article copyWith({
    String? id,
    String? source,
    String? sourceName,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    DateTime? publishedAt,
    String? content,
    bool? isFavorite,
  }) {
    return Article(
      id: id ?? this.id,
      source: source ?? this.source,
      sourceName: sourceName ?? this.sourceName,
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
    id,
    source,
    sourceName,
    author,
    title,
    description,
    url,
    urlToImage,
    publishedAt,
    content,
    isFavorite,
  ];
}
