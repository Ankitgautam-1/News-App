import 'package:news_app/domain/entity/article.dart';

class NewsArticlesModel {
  String? status;
  int? totalResults;
  List<ArticleModel>? articles;

  NewsArticlesModel({this.status, this.totalResults, this.articles});

  NewsArticlesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    totalResults = json['totalResults'];
    if (json['articles'] != null) {
      articles = <ArticleModel>[];
      json['articles'].forEach((v) {
        articles!.add(new ArticleModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['totalResults'] = this.totalResults;
    if (this.articles != null) {
      data['articles'] = this.articles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ArticleModel extends Article {
  const ArticleModel({
    super.id,
    super.source,
    super.sourceName,
    super.author,
    super.title,
    super.description,
    super.url,
    super.urlToImage,
    super.publishedAt,
    super.content,
    super.isFavorite,
  });

  ArticleModel.fromJson(Map<String, dynamic> json)
    : super(
        id: json['id'],
        source: json['source'] != null
            ? Source.fromJson(json['source']).name
            : null,
        sourceName: json['source'] != null
            ? Source.fromJson(json['source']).name
            : null,
        author: json['author'],
        title: json['title'],
        description: json['description'],
        url: json['url'],
        urlToImage: json['urlToImage'],
        publishedAt: json['publishedAt'] != null
            ? DateTime.parse(json['publishedAt'])
            : null,
        content: json['content'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['source'] = this.source != null ? {'name': this.source} : null;
    data['author'] = this.author;
    data['title'] = this.title;
    data['description'] = this.description;
    data['url'] = this.url;
    data['urlToImage'] = this.urlToImage;
    data['publishedAt'] = this.publishedAt?.toIso8601String();
    data['content'] = this.content;
    return data;
  }
}

class Source {
  String? id;
  String? name;

  Source({this.id, this.name});

  Source.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
