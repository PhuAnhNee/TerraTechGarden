import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'terrarium_variant_event.dart';
import 'terrarium_variant_state.dart';
import '../../../config/config.dart';

class TerrariumVariantBloc
    extends Bloc<TerrariumVariantEvent, TerrariumVariantState> {
  TerrariumVariantBloc() : super(TerrariumVariantInitial()) {
    on<FetchTerrariumVariants>(_onFetchTerrariumVariants);
    on<SelectVariant>(_onSelectVariant);
    on<FetchAccessoryDetails>(_onFetchAccessoryDetails);
  }

  Future<void> _onFetchTerrariumVariants(
    FetchTerrariumVariants event,
    Emitter<TerrariumVariantState> emit,
  ) async {
    developer.log('Fetching terrarium variants for ID: ${event.terrariumId}',
        name: 'TerrariumVariantBloc');

    emit(TerrariumVariantLoading());

    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.apiBaseUrl}/api/TerrariumVariant/get-VariantByTerrarium/${event.terrariumId}'),
        headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
      );

      developer.log(
          'Variants API Response: ${response.statusCode} - ${response.body}',
          name: 'TerrariumVariantBloc');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 200 && data['data'] is List) {
          final variants = List<Map<String, dynamic>>.from(data['data']);

          if (variants.isNotEmpty) {
            emit(TerrariumVariantLoaded(variants: variants));

            // Fetch accessory details for the first variant
            _fetchAccessoriesForVariant(variants[0]);
          } else {
            emit(const TerrariumVariantError('No variants found'));
          }
        } else {
          emit(TerrariumVariantError(
              'Invalid response format: Expected status 200, got ${data['status']}'));
        }
      } else {
        emit(TerrariumVariantError(
            'Failed to load variants: ${response.statusCode}'));
      }
    } catch (e) {
      developer.log('Exception during variants fetch: $e',
          name: 'TerrariumVariantBloc');
      emit(TerrariumVariantError('Failed to load variants: $e'));
    }
  }

  void _onSelectVariant(
    SelectVariant event,
    Emitter<TerrariumVariantState> emit,
  ) {
    if (state is TerrariumVariantLoaded) {
      final currentState = state as TerrariumVariantLoaded;
      final variantIndex = currentState.variants.indexWhere(
        (variant) => variant['terrariumVariantId'] == event.variantId,
      );

      if (variantIndex != -1) {
        emit(currentState.copyWith(selectedVariantIndex: variantIndex));

        // Fetch accessory details for the selected variant
        _fetchAccessoriesForVariant(currentState.variants[variantIndex]);
      }
    }
  }

  Future<void> _onFetchAccessoryDetails(
    FetchAccessoryDetails event,
    Emitter<TerrariumVariantState> emit,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.apiBaseUrl}/api/Accessory/get/${event.accessoryId}'),
        headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
      );

      developer.log(
          'Accessory ${event.accessoryId} API Response: ${response.statusCode} - ${response.body}',
          name: 'TerrariumVariantBloc');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        developer.log('Raw accessory response: ${response.body}',
            name: 'TerrariumVariantBloc');
        developer.log('Parsed accessory data: $data',
            name: 'TerrariumVariantBloc');

        if (data['status'] == 200 && data['data'] is Map<String, dynamic>) {
          final accessoryData = data['data'] as Map<String, dynamic>;
          developer.log('Accessory data keys: ${accessoryData.keys.toList()}',
              name: 'TerrariumVariantBloc');

          // Log image-related fields
          developer.log('urlImage field: ${accessoryData['urlImage']}',
              name: 'TerrariumVariantBloc');
          developer.log('imageUrl field: ${accessoryData['imageUrl']}',
              name: 'TerrariumVariantBloc');
          developer.log(
              'accessoryImages field: ${accessoryData['accessoryImages']}',
              name: 'TerrariumVariantBloc');

          if (state is TerrariumVariantLoaded) {
            final currentState = state as TerrariumVariantLoaded;
            final updatedAccessoryDetails = Map<int, Map<String, dynamic>>.from(
                currentState.accessoryDetails);
            updatedAccessoryDetails[event.accessoryId] = accessoryData;

            emit(currentState.copyWith(
                accessoryDetails: updatedAccessoryDetails));

            developer.log(
                'Updated accessory details for ID ${event.accessoryId}',
                name: 'TerrariumVariantBloc');
          }
        } else {
          developer.log('Invalid accessory response format: ${data['status']}',
              name: 'TerrariumVariantBloc');
        }
      } else {
        developer.log(
            'Failed to fetch accessory ${event.accessoryId}: ${response.statusCode}',
            name: 'TerrariumVariantBloc');
      }
    } catch (e) {
      developer.log('Exception during accessory fetch: $e',
          name: 'TerrariumVariantBloc');
    }
  }

  void _fetchAccessoriesForVariant(Map<String, dynamic> variant) {
    final accessories =
        variant['terrariumVariantAccessories'] as List<dynamic>? ?? [];

    developer.log(
        'Fetching accessories for variant: ${accessories.length} items',
        name: 'TerrariumVariantBloc');

    for (final accessory in accessories) {
      final accessoryId = accessory['accessoryId'] as int?;
      developer.log('Processing accessory ID: $accessoryId',
          name: 'TerrariumVariantBloc');

      if (accessoryId != null) {
        add(FetchAccessoryDetails(accessoryId));
      }
    }
  }
}
