abstract class CategoryEvent {}

class LoadCategoriesEvent extends CategoryEvent {}

class LoadCategoryByIdEvent extends CategoryEvent {
  final String id;
  LoadCategoryByIdEvent(this.id);
}
