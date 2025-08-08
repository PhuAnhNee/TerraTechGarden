import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'cart_event.dart';
import 'cart_state.dart';
import '../../../api/terra_api.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final String? _storedToken;

  CartBloc({String? storedToken})
      : _storedToken = storedToken,
        super(CartInitial()) {
    on<FetchCart>(_onFetchCart);
    on<AddCartItems>(_onAddCartItems);
    on<UpdateCartItem>(_onUpdateCartItem);
    on<DeleteCartItem>(_onDeleteCartItem);
    on<DeleteAllCartItems>(_onDeleteAllCartItems);
  }

  Dio _getDio() {
    final dio = Dio();
    if (_storedToken != null) {
      dio.options.headers['Authorization'] = 'Bearer $_storedToken';
      developer.log('Authorization header set: Bearer $_storedToken',
          name: 'CartBloc');
    } else {
      developer.log('No token provided for Authorization', name: 'CartBloc');
    }
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = '*/*';
    return dio;
  }

  Future<void> _onFetchCart(FetchCart event, Emitter<CartState> emit) async {
    developer.log('Fetching cart...', name: 'CartBloc');
    emit(CartLoading());
    try {
      final response = await _getDio().get(TerraApi.getCart());
      developer.log(
          'Cart API Response: ${response.statusCode} - ${response.data}',
          name: 'CartBloc');

      final data = response.data;

      if (data is Map<String, dynamic> && data['status'] == 200) {
        final cartData = data['data'] as Map<String, dynamic>;
        final total = (cartData['totalCartPrice'] ?? 0.0).toDouble();
        final totalCartQuantity = (cartData['totalCartQuantity'] ?? 0) as int;
        final rawCartItems = cartData['cartItems'] as List<dynamic>? ?? [];

        developer.log('Raw cartItems: $rawCartItems', name: 'CartBloc');

        // Fetch detailed information for each cart item
        final List<Map<String, dynamic>> items = [];

        for (final cartItem in rawCartItems) {
          developer.log('Processing cart item: $cartItem', name: 'CartBloc');

          final cartItemId = (cartItem['cartItemId'] ?? '0').toString();
          final accessoryId = cartItem['accessoryId'];
          final itemList = cartItem['item'] as List<dynamic>? ?? [];
          final itemDetails = itemList.isNotEmpty
              ? itemList.first as Map<String, dynamic>
              : <String, dynamic>{};

          // Fetch accessory details using accessoryId
          if (accessoryId != null) {
            try {
              final accessoryResponse = await _getDio()
                  .get(TerraApi.getAccessoryById(accessoryId.toString()));
              developer.log(
                  'Accessory API Response: ${accessoryResponse.statusCode} - ${accessoryResponse.data}',
                  name: 'CartBloc');

              if (accessoryResponse.statusCode == 200) {
                final accessoryData = accessoryResponse.data;
                String imageUrl =
                    'https://i.pinimg.com/1200x/d1/d5/1f/d1d51f814f974cc6b9bb438c1c790d59.jpg'; // Default image

                if (accessoryData is Map<String, dynamic> &&
                    accessoryData['status'] == 200) {
                  final accessoryDetails =
                      accessoryData['data'] as Map<String, dynamic>? ?? {};
                  final accessoryImages =
                      accessoryDetails['accessoryImages'] as List<dynamic>? ??
                          [];

                  // Get first image if available
                  if (accessoryImages.isNotEmpty) {
                    final firstImage =
                        accessoryImages.first as Map<String, dynamic>;
                    imageUrl = firstImage['imageUrl'] ?? imageUrl;
                  }

                  items.add({
                    'id': cartItemId,
                    'accessoryId': accessoryId,
                    'accessoryName': accessoryDetails['accessoryName'] ??
                        itemDetails['productName'] ??
                        'Unknown Item',
                    'accessoryQuantity': itemDetails['quantity'] ?? 1,
                    'price': (itemDetails['price'] ?? 0.0).toDouble(),
                    'originalPrice': (accessoryDetails['price'] ??
                            itemDetails['price'] ??
                            0.0)
                        .toDouble(),
                    'imageUrl': imageUrl,
                    'totalPrice': (itemDetails['totalPrice'] ?? 0.0).toDouble(),
                    'description': accessoryDetails['description'] ?? '',
                  });
                } else {
                  // Fallback to cart item data if accessory API fails
                  items.add({
                    'id': cartItemId,
                    'accessoryId': accessoryId,
                    'accessoryName':
                        itemDetails['productName'] ?? 'Unknown Item',
                    'accessoryQuantity': itemDetails['quantity'] ?? 1,
                    'price': (itemDetails['price'] ?? 0.0).toDouble(),
                    'originalPrice': (itemDetails['price'] ?? 0.0).toDouble(),
                    'imageUrl': imageUrl,
                    'totalPrice': (itemDetails['totalPrice'] ?? 0.0).toDouble(),
                  });
                }
              }
            } catch (e) {
              developer.log(
                  'Error fetching accessory details for id $accessoryId: $e',
                  name: 'CartBloc');
              // Fallback to cart item data if accessory API fails
              items.add({
                'id': cartItemId,
                'accessoryId': accessoryId,
                'accessoryName': itemDetails['productName'] ?? 'Unknown Item',
                'accessoryQuantity': itemDetails['quantity'] ?? 1,
                'price': (itemDetails['price'] ?? 0.0).toDouble(),
                'originalPrice': (itemDetails['price'] ?? 0.0).toDouble(),
                'imageUrl':
                    'https://i.pinimg.com/1200x/d1/d5/1f/d1d51f814f974cc6b9bb438c1c790d59.jpg',
                'totalPrice': (itemDetails['totalPrice'] ?? 0.0).toDouble(),
              });
            }
          } else {
            // No accessoryId, use cart item data
            items.add({
              'id': cartItemId,
              'accessoryName': itemDetails['productName'] ?? 'Unknown Item',
              'accessoryQuantity': itemDetails['quantity'] ?? 1,
              'price': (itemDetails['price'] ?? 0.0).toDouble(),
              'originalPrice': (itemDetails['price'] ?? 0.0).toDouble(),
              'imageUrl':
                  'https://i.pinimg.com/1200x/d1/d5/1f/d1d51f814f974cc6b9bb438c1c790d59.jpg',
              'totalPrice': (itemDetails['totalPrice'] ?? 0.0).toDouble(),
            });
          }
        }

        developer.log('Final mapped items: $items', name: 'CartBloc');

        // Calculate saved amount based on original price vs current price
        double saved = 0.0;
        for (final item in items) {
          final originalPrice = item['originalPrice'] as double;
          final currentPrice = item['price'] as double;
          final quantity = item['accessoryQuantity'] as int;
          if (originalPrice > currentPrice) {
            saved += (originalPrice - currentPrice) * quantity;
          }
        }

        emit(CartLoaded({
          'items': items,
          'total': total,
          'saved': saved,
          'totalCartQuantity': totalCartQuantity,
        }));
      } else {
        developer.log('Invalid cart response format: $data', name: 'CartBloc');
        emit(CartError(
            'Invalid response format from server: ${data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      developer.log('Error fetching cart: $e', name: 'CartBloc');
      emit(CartError('Failed to fetch cart: $e'));
    }
  }

  Future<void> _onAddCartItems(
      AddCartItems event, Emitter<CartState> emit) async {
    developer.log('Adding items to cart: ${event.items}', name: 'CartBloc');
    emit(CartLoading());
    try {
      final response = await _getDio().post(
        TerraApi.addMultipleCartItems(),
        data: event.items,
      );
      developer.log(
          'Add items response: ${response.statusCode} - ${response.data}',
          name: 'CartBloc');

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CartOperationSuccess('Items added to cart successfully'));
        add(FetchCart());
      } else {
        emit(CartError(
            'Failed to add items: ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      developer.log('Error adding items to cart: $e', name: 'CartBloc');
      if (e is DioException) {
        developer.log('Dio error: ${e.response?.data}', name: 'CartBloc');
        emit(CartError(
            'Failed to add items to cart: ${e.response?.data['message'] ?? e.message}'));
      } else {
        emit(CartError('Failed to add items to cart: $e'));
      }
    }
  }

  Future<void> _onUpdateCartItem(
      UpdateCartItem event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final response = await _getDio().put(
        TerraApi.updateCartItem(event.itemId),
        data: {
          'accessoryQuantity': event.itemData['accessoryQuantity'],
        },
      );
      developer.log(
          'Update item response: ${response.statusCode} - ${response.data}',
          name: 'CartBloc');
      emit(CartOperationSuccess('Cart item updated successfully'));
      add(FetchCart());
    } catch (e) {
      developer.log('Error updating cart item: $e', name: 'CartBloc');
      emit(CartError('Failed to update cart item: $e'));
    }
  }

  Future<void> _onDeleteCartItem(
      DeleteCartItem event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final response =
          await _getDio().delete(TerraApi.deleteCartItem(event.itemId));
      developer.log(
          'Delete item response: ${response.statusCode} - ${response.data}',
          name: 'CartBloc');
      emit(CartOperationSuccess('Cart item deleted successfully'));
      add(FetchCart());
    } catch (e) {
      developer.log('Error deleting cart item: $e', name: 'CartBloc');
      emit(CartError('Failed to delete cart item: $e'));
    }
  }

  Future<void> _onDeleteAllCartItems(
      DeleteAllCartItems event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final response = await _getDio().delete(TerraApi.deleteAllCartItems());
      developer.log(
          'Delete all items response: ${response.statusCode} - ${response.data}',
          name: 'CartBloc');
      emit(CartOperationSuccess('All cart items deleted successfully'));
      add(FetchCart());
    } catch (e) {
      developer.log('Error deleting all cart items: $e', name: 'CartBloc');
      emit(CartError('Failed to delete all cart items: $e'));
    }
  }
}
