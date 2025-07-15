import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../api/terra_api.dart';
import 'category_event.dart';
import 'category_state.dart';
import '../../authentication/bloc/auth_bloc.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final AuthBloc authBloc;

  CategoryBloc({required this.authBloc}) : super(CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<LoadCategoryByIdEvent>(_onLoadCategoryById);
    add(LoadCategoriesEvent());
  }

  Future<void> _onLoadCategories(
      LoadCategoriesEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final String? accessToken = authBloc.token;
      if (accessToken == null) {
        emit(CategoryError('Please log in to view categories'));
        return;
      }

      final response = await http.get(
        Uri.parse(TerraApi.getAllCategories()),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> categories = json.decode(response.body);
        emit(CategoryLoaded(
            categories.map((e) => Map<String, dynamic>.from(e)).toList()));
      } else {
        emit(CategoryError('Failed to load categories. Please try again.'));
      }
    } catch (e) {
      emit(CategoryError('An error occurred while loading categories.'));
    }
  }

  Future<void> _onLoadCategoryById(
      LoadCategoryByIdEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final String? accessToken = authBloc.token;
      if (accessToken == null) {
        emit(CategoryError('Please log in to view category details'));
        return;
      }

      final response = await http.get(
        Uri.parse(TerraApi.getCategoryById(event.id)),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        emit(CategoryDetailsLoaded(data));
      } else {
        emit(CategoryError(
            'Failed to load category details. Please try again.'));
      }
    } catch (e) {
      emit(CategoryError('An error occurred while loading category details.'));
    }
  }
}
