import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'accessory_event.dart';
import 'accessory_state.dart';
import '../../../api/terra_api.dart';

class AccessoryBloc extends Bloc<AccessoryEvent, AccessoryState> {
  final Dio _dio = Dio();

  AccessoryBloc() : super(AccessoryInitial()) {
    on<FetchAccessories>((event, emit) async {
      developer.log('Fetching accessories for page: ${event.page}',
          name: 'AccessoryBloc');
      emit(AccessoryLoading());
      try {
        final response = await TerraApi.getAccessories(page: event.page);
        developer.log(
            'API Response (get-all): ${response['status']} - ${response}',
            name: 'AccessoryBloc');

        if (response['status'] == 200 &&
            response['data'] is Map<String, dynamic> &&
            response['data']['results'] is List) {
          final results = response['data']['results'] as List;
          developer.log('Results length: ${results.length}',
              name: 'AccessoryBloc');

          final totalItems = response['data']['totalItems'] ?? results.length;
          final pageSize = response['data']['pageSize'] ?? 10;
          final totalPages = response['data']['totalPages'] ??
              (results.length / pageSize).ceil();
          final accessories = results.cast<Map<String, dynamic>>();

          developer.log(
              'Emitting accessories for page ${event.page}: ${accessories.length} items',
              name: 'AccessoryBloc');
          if (accessories.isNotEmpty) {
            emit(AccessoryLoaded(
              accessories,
              totalPages: totalPages,
              currentPage: event.page,
              totalItems: totalItems,
            ));
          } else {
            emit(AccessoryError('No accessories found for page ${event.page}'));
          }
        } else {
          emit(AccessoryError(
              'Invalid response format from get-all: ${response['message'] ?? 'Unknown error'}'));
        }
      } catch (e) {
        developer.log('Exception during fetch: $e',
            name: 'AccessoryBloc', error: e);
        if (e is DioException) {
          emit(AccessoryError(
              'Dio Error: ${e.message} - ${e.response?.data ?? e.toString()}'));
        } else {
          emit(AccessoryError('Failed to load accessories: $e'));
        }
      }
    });
  }
}
