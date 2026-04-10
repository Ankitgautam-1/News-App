/// Application-wide constants for the News App
class AppConstants {
  AppConstants._();
  static const String newsApiBaseUrl = 'https://newsapi.org/v2/';

  /// NewsAPI key is injected at build time.
  ///
  /// Run with:
  /// - `flutter run --dart-define=NEWS_API_KEY=your_key_here`
  /// - `flutter test --dart-define=NEWS_API_KEY=your_key_here` (only if needed)
  static const String newsApiKey = String.fromEnvironment('NEWS_API_KEY');

  static const String topHeadlinesEndpoint = '/top-headlines';
  static const String everythingEndpoint = '/everything';
  static const String sourcesEndpoint = '/sources';

  static const String countryQueryParam = 'country';
  static const String categoryQueryParam = 'category';
  static const String pageQueryParam = 'page';
  static const String pageSizeQueryParam = 'pageSize';
  static const String searchQueryParam = 'q';
  static const String apiKeyQueryParam = 'apiKey';

  static const int pageSize = 20;
  static const int initialPage = 1;

  // Categories
  static const List<String> categories = [
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology',
  ];

  // Countries (ISO 3166-1 alpha-2 codes)
  static const String defaultCountry = 'us';
  static const Map<String, String> countries = {
    'us': 'United States',
    'gb': 'United Kingdom',
    'ca': 'Canada',
    'au': 'Australia',
    'de': 'Germany',
    'fr': 'France',
    'in': 'India',
  };

  // Local Storage Keys
  static const String favoritesBoxName = 'favorites_box';
  static const String favoritesKey = 'favorite_articles';
  static const String settingsBoxName = 'settings_box';
  static const String lastCategoryKey = 'last_category';

  // Error Messages
  static const String unknownErrorMessage =
      'An unexpected error occurred. Please try again.';
  static const String networkErrorMessage =
      'Network error. Please check your internet connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String cacheErrorMessage = 'Failed to load cached data.';
  static const String noDataMessage = 'No articles found.';

  // Timeouts (in seconds)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;
}
