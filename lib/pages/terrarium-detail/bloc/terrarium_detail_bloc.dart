import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'terrarium_detail_event.dart';
import 'terrarium_detail_state.dart';
import '../../../api/terra_api.dart';

class TerrariumDetailBloc
    extends Bloc<TerrariumDetailEvent, TerrariumDetailState> {
  TerrariumDetailBloc() : super(TerrariumDetailInitial()) {
    on<FetchTerrariumDetail>((event, emit) async {
      developer.log('Fetching terrarium detail for ID: ${event.terrariumId}',
          name: 'TerrariumDetailBloc');
      emit(TerrariumDetailLoading());
      try {
        final response = await http.get(
          Uri.parse(TerraApi.getTerrariumById(event.terrariumId)),
          headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
        );

        developer.log('API Response: ${response.statusCode} - ${response.body}',
            name: 'TerrariumDetailBloc');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 200 && data['data'] is Map<String, dynamic>) {
            emit(TerrariumDetailLoaded(data['data']));
          } else {
            emit(TerrariumDetailError(
                'Invalid response format: Expected status 200, got ${data['status']}'));
          }
        } else {
          emit(TerrariumDetailError(
              'Failed to load terrarium detail: ${response.statusCode}'));
        }
      } catch (e) {
        developer.log('Exception during fetch: $e',
            name: 'TerrariumDetailBloc');
        emit(TerrariumDetailError('Failed to load terrarium detail: $e'));
      }
    });
  }
}
