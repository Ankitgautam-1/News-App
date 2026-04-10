part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

class SelectCategory extends CategoryEvent {
  final String? category;

  const SelectCategory(this.category);

  @override
  List<Object?> get props => [category];
}
