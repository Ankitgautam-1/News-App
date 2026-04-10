import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  static const List<String> newsCategories = [
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
    'general',
  ];

  CategoryBloc() : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<SelectCategory>(_onSelectCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 300));
    emit(
      const CategoryLoaded(categories: newsCategories, selectedCategory: null),
    );
  }

  Future<void> _onSelectCategory(
    SelectCategory event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is CategoryLoaded) {
      emit(
        CategoryLoaded(
          categories: currentState.categories,
          selectedCategory: event.category,
        ),
      );
    }
  }
}
