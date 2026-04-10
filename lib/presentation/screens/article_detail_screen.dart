import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/core/service_locator.dart';
import 'package:news_app/domain/entity/article.dart';
import 'package:news_app/presentation/blocs/article_detail/article_detail_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String articleId;
  final Article? article;

  const ArticleDetailScreen({Key? key, required this.articleId, this.article})
    : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late ArticleDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator<ArticleDetailBloc>();

    // Load article detail if we have an article
    if (widget.article != null) {
      _bloc.add(LoadArticleDetail(widget.article!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article'), elevation: 0),
      body: BlocBuilder<ArticleDetailBloc, ArticleDetailState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is ArticleDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ArticleDetailLoaded) {
            final article = state.article;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Article image
                  if (article.urlToImage != null &&
                      article.urlToImage!.isNotEmpty)
                    Image.network(
                      article.urlToImage!,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 64),
                          ),
                        );
                      },
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Source and date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              article.sourceName ?? 'Unknown',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            if (article.publishedAt != null)
                              Text(
                                _formatDate(article.publishedAt!),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          article.title ?? 'No Title',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        // Author
                        if (article.author != null)
                          Text(
                            'By ${article.author!}',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                ),
                          ),
                        const SizedBox(height: 16),
                        // Description
                        if (article.description != null)
                          Text(
                            article.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        const SizedBox(height: 16),
                        // Content
                        if (article.content != null)
                          Text(
                            article.content!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        const SizedBox(height: 24),
                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Favorite button
                            ElevatedButton.icon(
                              onPressed: () {
                                _bloc.add(const ToggleArticleFavorite());
                              },
                              icon: Icon(
                                article.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              label: Text(
                                article.isFavorite
                                    ? 'Favorited'
                                    : 'Add to Favorites',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: article.isFavorite
                                    ? Colors.red
                                    : Colors.grey[300],
                                foregroundColor: article.isFavorite
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            // Read full article button
                            if (article.url != null)
                              ElevatedButton.icon(
                                onPressed: () {
                                  _launchUrl(article.url!);
                                },
                                icon: const Icon(Icons.open_in_new),
                                label: const Text('Read Full'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ArticleDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  /// Format date to display
  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  /// Launch URL in browser
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not launch URL')));
    }
  }
}
