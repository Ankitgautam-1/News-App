import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/utils/error/exceptions.dart';
import 'package:news_app/data/models/news_article_model.dart';

/// Local data source for managing favorites using Hive
abstract class LocalNewsDataSource {
  /// Get favorite articles from local storage
  Future<List<ArticleModel>> getFavorites();

  /// Save article to favorites
  Future<void> addToFavorites(ArticleModel article);

  /// Remove article from favorites
  Future<void> removeFromFavorites(String articleId);

  /// Check if article is favorited
  Future<bool> isFavorited(String articleId);

  /// Clear all favorites
  Future<void> clearFavorites();

  /// Initialize local storage (Hive)
  Future<void> initialize();
}

/// Implementation of LocalNewsDataSource using Hive
class LocalNewsDataSourceImpl implements LocalNewsDataSource {
  late Box<ArticleModel> _favoritesBox;

  @override
  Future<void> initialize() async {
    try {
      // Register ArticleModel adapter for Hive
      // Note: This assumes ArticleModel is registered as a Hive type
      // For now, we'll store as Map<String, dynamic> converted to JSON
      _favoritesBox = await Hive.openBox<ArticleModel>(
        AppConstants.favoritesBoxName,
      );
    } catch (e) {
      throw CacheException('Failed to initialize local storage: $e');
    }
  }

  @override
  Future<List<ArticleModel>> getFavorites() async {
    try {
      final articles = _favoritesBox.values.toList();
      return articles;
    } catch (e) {
      throw CacheException('Failed to get favorites: $e');
    }
  }

  @override
  Future<void> addToFavorites(ArticleModel article) async {
    try {
      log("Adding to favorites: ${article.id}");
      await _favoritesBox.put(article.id, article);
    } catch (e) {
      throw CacheException('Failed to add favorite: $e');
    }
  }

  @override
  Future<void> removeFromFavorites(String articleId) async {
    try {
      await _favoritesBox.delete(articleId);
    } catch (e) {
      throw CacheException('Failed to remove favorite: $e');
    }
  }

  @override
  Future<bool> isFavorited(String articleId) async {
    try {
      return _favoritesBox.containsKey(articleId);
    } catch (e) {
      throw CacheException('Failed to check favorite status: $e');
    }
  }

  @override
  Future<void> clearFavorites() async {
    try {
      await _favoritesBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear favorites: $e');
    }
  }
}
