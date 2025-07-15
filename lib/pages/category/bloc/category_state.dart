abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Map<String, dynamic>> categories;
  CategoryLoaded(this.categories);
}

class CategoryDetailsLoaded extends CategoryState {
  final Map<String, dynamic> category;
  CategoryDetailsLoaded(this.category);
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}
