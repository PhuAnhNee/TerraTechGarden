import 'package:equatable/equatable.dart';

abstract class BlogState extends Equatable {
  const BlogState();

  @override
  List<Object?> get props => [];
}

class BlogInitial extends BlogState {}

class BlogLoading extends BlogState {}

class BlogLoaded extends BlogState {
  final List<Map<String, dynamic>> blogs;
  final int totalPages;
  final int currentPage;
  final int totalItems;

  const BlogLoaded(this.blogs,
      {this.totalPages = 1, this.currentPage = 1, this.totalItems = 0});

  @override
  List<Object?> get props => [blogs, totalPages, currentPage, totalItems];
}

class BlogError extends BlogState {
  final String message;

  const BlogError(this.message);

  @override
  List<Object?> get props => [message];
}
