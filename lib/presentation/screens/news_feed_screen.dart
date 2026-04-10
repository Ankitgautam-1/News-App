import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/core/service_locator.dart';
import 'package:news_app/domain/repository/failure.dart';
import 'package:news_app/presentation/blocs/category/category_bloc.dart';
import 'package:news_app/presentation/blocs/news_feed/news_feed_bloc.dart';
import 'package:news_app/presentation/widgets/article_card.dart';
import 'package:news_app/presentation/widgets/category_chip.dart';

/// News Feed Screen - displays a list of news articles
class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  late ScrollController _scrollController;
  late NewsFeedBloc _newsFeedBloc;
  late CategoryBloc _categoryBloc;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _newsFeedBloc = serviceLocator<NewsFeedBloc>();
    _categoryBloc = serviceLocator<CategoryBloc>();

    _scrollController.addListener(_onScroll);
    _newsFeedBloc.add(const GetTopHeadlinesEvent());
    _categoryBloc.add(const LoadCategories());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _newsFeedBloc.add(const LoadMoreHeadlinesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News App'), elevation: 0),
      body: Column(
        children: [
          // Category filter
          BlocBuilder<CategoryBloc, CategoryState>(
            bloc: _categoryBloc,
            builder: (context, state) {
              if (state is CategoryLoaded) {
                return SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      CategoryChip(
                        label: 'All',
                        isSelected: state.selectedCategory == null,
                        onTap: () {
                          _categoryBloc.add(const SelectCategory(null));
                          _newsFeedBloc.add(const ChangeCategory(null));
                        },
                      ),
                      ...state.categories.map((category) {
                        return CategoryChip(
                          label: category,
                          isSelected: state.selectedCategory == category,
                          onTap: () {
                            _categoryBloc.add(SelectCategory(category));
                            _newsFeedBloc.add(ChangeCategory(category));
                          },
                        );
                      }),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // News list
          Expanded(
            child: BlocBuilder<NewsFeedBloc, NewsFeedState>(
              bloc: _newsFeedBloc,
              builder: (context, state) {
                if (state is NewsFeedLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is NewsFeedLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      _newsFeedBloc.add(const RefreshHeadlinesEvent());
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.articles.length + 1,
                      itemBuilder: (context, index) {
                        // Loading indicator at the end
                        if (index == state.articles.length) {
                          return state.hasMoreData
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }

                        final article = state.articles[index];
                        return ArticleCard(article: article);
                      },
                    ),
                  );
                } else if (state is NewsFeedEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                      ],
                    ),
                  );
                } else if (state is NewsFeedError) {
                  if (state.failure is NetworkFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(state.failure.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _newsFeedBloc.add(const GetTopHeadlinesEvent());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(state.failure.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _newsFeedBloc.add(const GetTopHeadlinesEvent());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(child: Text('Unknown state'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
