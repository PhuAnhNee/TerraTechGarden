import 'package:equatable/equatable.dart';

abstract class BlogEvent extends Equatable {
  const BlogEvent();

  @override
  List<Object?> get props => [];
}

class FetchBlogs extends BlogEvent {
  final int page;

  const FetchBlogs({this.page = 1});

  @override
  List<Object?> get props => [page];
}
