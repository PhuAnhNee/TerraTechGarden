import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'terrarium_event.dart';
import 'terrarium_state.dart';
import '../../../api/terra_api.dart';

class TerrariumBloc extends Bloc<TerrariumEvent, TerrariumState> {
  TerrariumBloc() : super(TerrariumInitial()) {
    on<FetchTerrariums>((event, emit) async {
      developer.log('Fetching terrariums for page: ${event.page}',
          name: 'TerrariumBloc');
      emit(TerrariumLoading());
      try {
        final data = await TerraApi.getTerrariums(page: event.page);
        developer.log('API Response: $data', name: 'TerrariumBloc');

        if (data['status'] == 200 && data['data'] is Map<String, dynamic>) {
          final results = data['data']['results'] as List? ?? [];
          final totalPages =
              (results.length / 10).ceil(); // Calculate total pages client-side
          final totalItems = results.length;
          final pageSize = 10;
          final startIndex = (event.page - 1) * pageSize;
          final endIndex = startIndex + pageSize > results.length
              ? results.length
              : startIndex + pageSize;
          final terrariums = results
              .sublist(startIndex, endIndex)
              .cast<Map<String, dynamic>>();
          developer.log(
              'Emitting terrariums for page ${event.page}: ${terrariums.length} items',
              name: 'TerrariumBloc');
          if (terrariums.isNotEmpty) {
            emit(TerrariumLoaded(
              terrariums,
              totalPages: totalPages,
              currentPage: event.page,
              totalItems: totalItems,
            ));
          } else {
            emit(TerrariumError('No terrariums found for page ${event.page}'));
          }
        } else {
          emit(TerrariumError(
              'Invalid response format: Expected status 200, got ${data['status']}'));
        }
      } catch (e) {
        developer.log('Exception during fetch: $e', name: 'TerrariumBloc');
        emit(TerrariumError('Failed to load terrariums: $e'));
      }
    });

    on<FetchTerrariumReferences>((event, emit) async {
      developer.log('Fetching terrarium references', name: 'TerrariumBloc');
      emit(TerrariumLoading());
      try {
        final futures = await Future.wait([
          http.get(Uri.parse(TerraApi.getAllEnvironments()), headers: {
            'Content-Type': 'application/json',
            'accept': 'text/plain'
          }),
          http.get(Uri.parse(TerraApi.getAllShapes()), headers: {
            'Content-Type': 'application/json',
            'accept': 'text/plain'
          }),
          http.get(Uri.parse(TerraApi.getAllTankMethods()), headers: {
            'Content-Type': 'application/json',
            'accept': 'text/plain'
          }),
        ]);

        final environmentResponse = futures[0];
        final shapeResponse = futures[1];
        final tankMethodResponse = futures[2];

        developer.log(
            'Environment Response: ${environmentResponse.statusCode} - ${environmentResponse.body}',
            name: 'TerrariumBloc');
        developer.log(
            'Shape Response: ${shapeResponse.statusCode} - ${shapeResponse.body}',
            name: 'TerrariumBloc');
        developer.log(
            'TankMethod Response: ${tankMethodResponse.statusCode} - ${tankMethodResponse.body}',
            name: 'TerrariumBloc');

        if (environmentResponse.statusCode == 200 &&
            shapeResponse.statusCode == 200 &&
            tankMethodResponse.statusCode == 200) {
          List<Map<String, dynamic>> environments = [];
          List<Map<String, dynamic>> shapes = [];
          List<Map<String, dynamic>> tankMethods = [];

          final envData = jsonDecode(environmentResponse.body);
          if (envData['status'] == 200 &&
              envData['data'] is Map<String, dynamic> &&
              envData['data']['results'] is List) {
            environments = (envData['data']['results'] as List)
                .cast<Map<String, dynamic>>();
          } else {
            developer.log('Invalid envData structure: $envData',
                name: 'TerrariumBloc');
          }

          final shapeData = jsonDecode(shapeResponse.body);
          if (shapeData['status'] == 200 &&
              shapeData['data'] is Map<String, dynamic> &&
              shapeData['data']['results'] is List) {
            shapes = (shapeData['data']['results'] as List)
                .cast<Map<String, dynamic>>();
          } else {
            developer.log('Invalid shapeData structure: $shapeData',
                name: 'TerrariumBloc');
          }

          final tankData = jsonDecode(tankMethodResponse.body);
          if (tankData['status'] == 200 &&
              tankData['data'] is Map<String, dynamic> &&
              tankData['data']['results'] is List) {
            tankMethods = (tankData['data']['results'] as List)
                .cast<Map<String, dynamic>>();
          } else {
            developer.log('Invalid tankData structure: $tankData',
                name: 'TerrariumBloc');
          }

          emit(TerrariumReferencesLoaded(environments, shapes, tankMethods));
        } else {
          emit(TerrariumError(
              'Failed to load references: Env(${environmentResponse.statusCode}), Shape(${shapeResponse.statusCode}), Tank(${tankMethodResponse.statusCode})'));
        }
      } catch (e, stackTrace) {
        developer.log(
            'Exception during reference fetch: $e\nStackTrace: $stackTrace',
            name: 'TerrariumBloc');
        emit(TerrariumError('Failed to load references: $e'));
      }
    });

    on<FilterTerrariums>((event, emit) async {
      developer.log(
          'Filtering terrariums for page: ${event.page}, envName: ${event.environmentName}, shapeName: ${event.shapeName}, tankMethodType: ${event.tankMethodType}',
          name: 'TerrariumBloc');
      emit(TerrariumLoading());
      try {
        // Use pre-loaded references to get IDs
        final currentState = state;
        int? environmentId, shapeId, tankMethodId;

        if (currentState is TerrariumReferencesLoaded) {
          if (event.environmentName != null) {
            final env = currentState.environments.firstWhere(
              (e) => e['environmentName'] == event.environmentName,
              orElse: () => {},
            );
            environmentId =
                env.isNotEmpty ? env['environmentId'] as int? : null;
          }
          if (event.shapeName != null) {
            final shape = currentState.shapes.firstWhere(
              (s) => s['shapeName'] == event.shapeName,
              orElse: () => {},
            );
            shapeId = shape.isNotEmpty ? shape['shapeId'] as int? : null;
          }
          if (event.tankMethodType != null) {
            final tankMethod = currentState.tankMethods.firstWhere(
              (t) => t['tankMethodType'] == event.tankMethodType,
              orElse: () => {},
            );
            tankMethodId = tankMethod.isNotEmpty
                ? tankMethod['tankMethodId'] as int?
                : null;
          }
        }

        final response = await http.get(
          Uri.parse(TerraApi.filterTerrariums(
            page: event.page,
            pageSize: 10,
            environmentId: environmentId,
            shapeId: shapeId,
            tankMethodId: tankMethodId,
            includeProperties: 'TerrariumImages,Environment,Shape,TankMethod',
          )),
          headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
        );

        developer.log(
            'API Filter Response Status: ${response.statusCode}, Body: ${response.body}',
            name: 'TerrariumBloc');
        if (response.statusCode == 200) {
          final dynamic data = jsonDecode(response.body);
          if (data is Map<String, dynamic> &&
              data['data'] is Map<String, dynamic>) {
            final results = data['data']['results'] as List? ?? [];
            final totalPages = (data['data']['totalPages'] as int?) ??
                (results.length / 10).ceil();
            final totalItems =
                (data['data']['totalItems'] as int?) ?? results.length;
            final pageSize = 10;
            final startIndex = (event.page - 1) * pageSize;
            final endIndex = startIndex + pageSize > results.length
                ? results.length
                : startIndex + pageSize;
            final terrariums = results
                .sublist(startIndex, endIndex)
                .cast<Map<String, dynamic>>();
            developer.log(
                'Emitting filtered terrariums for page ${event.page}: ${terrariums.length} items',
                name: 'TerrariumBloc');
            if (terrariums.isNotEmpty) {
              emit(TerrariumLoaded(
                terrariums,
                totalPages: totalPages,
                currentPage: event.page,
                totalItems: totalItems,
              ));
            } else {
              emit(TerrariumError(
                  'No filtered terrariums found for page ${event.page}'));
            }
          } else {
            emit(TerrariumError(
                'Invalid filter response format: Expected data.results as a list, got $data'));
          }
        } else {
          emit(TerrariumError(
              'Failed to filter terrariums: ${response.statusCode} - ${response.body}'));
        }
      } catch (e) {
        developer.log('Exception during filter: $e', name: 'TerrariumBloc');
        emit(TerrariumError('Failed to filter terrariums: $e'));
      }
    });
  }
}
