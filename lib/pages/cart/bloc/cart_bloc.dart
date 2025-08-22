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

    // Debug token on initialization
    _debugToken();
  }

  void _debugToken() {
    if (_storedToken != null && _storedToken!.isNotEmpty) {
      developer.log(
          'CartBloc initialized with token: ${_storedToken!.substring(0, 20)}...',
          name: 'CartBloc');
    } else {
      developer.log('CartBloc initialized WITHOUT token!', name: 'CartBloc');
    }
  }

  Dio _getDio() {
    final dio = Dio();

    // Enhanced token debugging
    if (_storedToken != null && _storedToken!.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $_storedToken';
      developer.log(
          '✅ Authorization header set: Bearer ${_storedToken!.substring(0, 20)}...',
          name: 'CartBloc');
    } else {
      developer.log('❌ NO TOKEN PROVIDED - This will cause 401/500 errors!',
          name: 'CartBloc');
    }

    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = '*/*';

    // Add interceptor to log all requests
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log('🚀 REQUEST: ${options.method} ${options.path}',
            name: 'CartBloc');
        developer.log('📋 Headers: ${options.headers}', name: 'CartBloc');
        if (options.data != null) {
          developer.log('📤 Data: ${options.data}', name: 'CartBloc');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log(
            '✅ RESPONSE: ${response.statusCode} ${response.statusMessage}',
            name: 'CartBloc');
        developer.log('📥 Response data: ${response.data}', name: 'CartBloc');
        handler.next(response);
      },
      onError: (error, handler) {
        developer.log('❌ ERROR: ${error.response?.statusCode} ${error.message}',
            name: 'CartBloc');
        developer.log('📥 Error response: ${error.response?.data}',
            name: 'CartBloc');
        handler.next(error);
      },
    ));

    return dio;
  }

  Future<void> _onFetchCart(FetchCart event, Emitter<CartState> emit) async {
    developer.log('🛒 Starting to fetch cart...', name: 'CartBloc');
    developer.log(
        '🔑 Token status: ${_storedToken != null ? "EXISTS (${_storedToken!.length} chars)" : "NULL"}',
        name: 'CartBloc');

    if (_storedToken == null || _storedToken!.isEmpty) {
      developer.log('❌ Cannot fetch cart: No authentication token!',
          name: 'CartBloc');
      emit(CartError('Authentication required. Please log in again.'));
      return;
    }

    emit(CartLoading());
    try {
      final response = await _getDio().get(TerraApi.getCart());

      developer.log('🔍 Response Status: ${response.statusCode}',
          name: 'CartBloc');
      developer.log('🔍 Response Type: ${response.data.runtimeType}',
          name: 'CartBloc');

      final responseData = response.data;

      // Handle the new API response format
      if (responseData is Map<String, dynamic> &&
          responseData['status'] == 200 &&
          responseData.containsKey('data')) {
        final cartData = responseData['data'] as Map<String, dynamic>;
        developer.log('🔍 Cart Data Keys: ${cartData.keys.toList()}',
            name: 'CartBloc');

        // Get bundle items and single items
        final bundleItems = cartData['bundleItems'] as List<dynamic>? ?? [];
        final singleItems = cartData['singleItems'] as List<dynamic>? ?? [];
        final serverTotal = (cartData['totalCartPrice'] ?? 0.0).toDouble();
        final serverTotalQuantity = (cartData['totalCartQuantity'] ?? 0) is int
            ? cartData['totalCartQuantity'] ?? 0
            : (cartData['totalCartQuantity'] ?? 0).toInt();

        developer.log(
            '📦 Processing ${bundleItems.length} bundle items and ${singleItems.length} single items',
            name: 'CartBloc');

        final List<Map<String, dynamic>> items = [];
        double calculatedTotal = 0.0;
        num calculatedTotalQuantity =
            0; // Change to num to handle both int and double
        double saved = 0.0;

        // Process bundle items
        for (int index = 0; index < bundleItems.length; index++) {
          final bundleItem = bundleItems[index] as Map<String, dynamic>? ?? {};
          final mainItem =
              bundleItem['mainItem'] as Map<String, dynamic>? ?? {};
          final bundleAccessories =
              bundleItem['bundleAccessories'] as List<dynamic>? ?? [];
          final totalBundlePrice =
              (bundleItem['totalBundlePrice'] ?? 0.0).toDouble();
          final totalBundleQuantity = bundleItem['totalBundleQuantity'] ?? 0;

          developer.log(
              '🔍 Bundle item $index: accessories=${bundleAccessories.length}, price=$totalBundlePrice, qty=$totalBundleQuantity',
              name: 'CartBloc');

          // Skip empty bundle items (no accessories and no price)
          if (bundleAccessories.isEmpty && totalBundlePrice == 0.0) {
            developer.log('⏭️ Skipping empty bundle item $index',
                name: 'CartBloc');
            continue;
          }

          // Process each accessory in the bundle
          for (int accIndex = 0;
              accIndex < bundleAccessories.length;
              accIndex++) {
            final accessory =
                bundleAccessories[accIndex] as Map<String, dynamic>? ?? {};
            final accessoryItems = accessory['item'] as List<dynamic>? ?? [];

            if (accessoryItems.isEmpty) {
              developer.log('⏭️ Skipping accessory with no items',
                  name: 'CartBloc');
              continue;
            }

            final itemData =
                accessoryItems.first as Map<String, dynamic>? ?? {};
            if (itemData.isEmpty) {
              developer.log('⏭️ Skipping empty item data', name: 'CartBloc');
              continue;
            }

            final cartItemId = accessory['cartItemId'];
            final accessoryName = itemData['productName'] ?? 'Unknown Item';
            final quantity = (itemData['quantity'] ?? 1).toInt();
            final price = (itemData['price'] ?? 0.0).toDouble();
            final totalPrice = (itemData['totalPrice'] ?? 0.0).toDouble();
            final imageUrl = itemData['imageUrl'] ??
                'https://i.pinimg.com/1200x/bd/5d/a3/bd5da34fd926c2593a8bf3f4a6d042b0.jpg/200x200?text=No+Image';

            items.add({
              'id': cartItemId ?? '$index-$accIndex',
              'cartItemId': cartItemId ?? '$index-$accIndex',
              'accessoryId': accessory['accessoryId'],
              'accessoryName': accessoryName,
              'accessoryQuantity': quantity,
              'price': price,
              'originalPrice': price, // Assuming no discount for now
              'imageUrl': imageUrl,
              'totalPrice': totalPrice,
              'description': '',
            });

            calculatedTotal += totalPrice;
            calculatedTotalQuantity += quantity;

            developer.log(
                '✅ Added accessory: $accessoryName (qty: $quantity, total: $totalPrice)',
                name: 'CartBloc');
          }
        }

        // Process single items (if any)
        for (int index = 0; index < singleItems.length; index++) {
          final singleItem = singleItems[index] as Map<String, dynamic>? ?? {};
          // Process single items similar to accessories
          // (Implementation depends on single item structure)
          developer.log('🔍 Single item $index: $singleItem', name: 'CartBloc');
        }

        // Use server totals if available, otherwise use calculated
        final finalTotal = serverTotal > 0 ? serverTotal : calculatedTotal;
        final finalTotalQuantity = serverTotalQuantity > 0
            ? serverTotalQuantity
            : calculatedTotalQuantity.toInt();

        developer.log(
            '🎯 FINAL RESULT: ${items.length} items, Total: $finalTotal (server: $serverTotal, calc: $calculatedTotal), TotalQty: $finalTotalQuantity',
            name: 'CartBloc');

        emit(CartLoaded({
          'items': items,
          'total': finalTotal,
          'saved': saved,
          'totalCartQuantity': finalTotalQuantity,
        }));
      } else {
        developer.log(
            '❌ Invalid response format. Expected {status: 200, data: {...}}',
            name: 'CartBloc');
        developer.log('❌ Actual response: $responseData', name: 'CartBloc');
        emit(CartError('Invalid response format from server'));
      }
    } catch (e) {
      developer.log('💥 Critical error fetching cart: $e', name: 'CartBloc');
      if (e is DioException) {
        developer.log('📋 Error status: ${e.response?.statusCode}',
            name: 'CartBloc');
        developer.log('📋 Error response: ${e.response?.data}',
            name: 'CartBloc');

        if (e.response?.statusCode == 401) {
          emit(CartError('Authentication failed. Please log in again.'));
        } else if (e.response?.statusCode == 500) {
          emit(CartError(
              'Server error. Please check your authentication token.'));
        } else {
          String errorMessage = 'Network error';
          if (e.response?.data != null &&
              e.response!.data is Map<String, dynamic>) {
            errorMessage =
                e.response!.data['message'] ?? e.message ?? errorMessage;
          } else if (e.message != null) {
            errorMessage = e.message!;
          }
          emit(CartError(errorMessage));
        }
      } else {
        emit(CartError('Failed to fetch cart: $e'));
      }
    }
  }

  Future<void> _onAddCartItems(
      AddCartItems event, Emitter<CartState> emit) async {
    if (_storedToken == null || _storedToken!.isEmpty) {
      emit(CartError('Authentication required. Please log in again.'));
      return;
    }

    developer.log('➕ Adding items to cart: ${event.items}', name: 'CartBloc');
    emit(CartLoading());
    try {
      final cartItems = event.items.map((item) {
        return {
          'terrariumId': 0,
          'totalPrice': 0,
          'bundleAccessories': [
            {
              'accessoryId': int.tryParse(item['accessoryId'].toString()) ?? 0,
              'quantity': item['accessoryQuantity'] ?? 1,
            }
          ],
        };
      }).toList();

      // Validate accessory IDs safely
      if (cartItems.any((item) {
        final bundleAccessories = item['bundleAccessories'] as List<dynamic>?;
        if (bundleAccessories == null || bundleAccessories.isEmpty) {
          return true; // Treat as invalid if bundleAccessories is null or empty
        }
        final firstAccessory = bundleAccessories[0] as Map<String, dynamic>?;
        return firstAccessory == null ||
            firstAccessory['accessoryId'] == null ||
            firstAccessory['accessoryId'] == 0;
      })) {
        emit(CartError('Invalid accessory ID provided'));
        return;
      }

      final response = await _getDio().post(
        TerraApi.addMultipleCartItems(),
        data: cartItems,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CartOperationSuccess('Items added to cart successfully'));
        add(FetchCart());
      } else {
        emit(CartError(
            'Failed to add items: ${response.data != null && response.data is Map<String, dynamic> ? response.data['message'] ?? 'Unknown error' : 'Unknown error'}'));
      }
    } catch (e) {
      developer.log('💥 Error adding items to cart: $e', name: 'CartBloc');
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(CartError('Authentication failed. Please log in again.'));
        } else {
          emit(CartError(
              'Failed to add items: ${e.response?.data != null && e.response!.data is Map<String, dynamic> ? e.response!.data['message'] ?? e.message : e.message}'));
        }
      } else {
        emit(CartError('Failed to add items: $e'));
      }
    }
  }

  Future<void> _onUpdateCartItem(
      UpdateCartItem event, Emitter<CartState> emit) async {
    if (_storedToken == null || _storedToken!.isEmpty) {
      emit(CartError('Authentication required. Please log in again.'));
      return;
    }

    // Get current state
    if (state is! CartLoaded) {
      emit(CartError('Cart data not loaded. Please try again.'));
      return;
    }
    final currentState = state as CartLoaded;
    final updatedItems =
        List<Map<String, dynamic>>.from(currentState.cartData['items'] ?? []);

    // Validate itemId
    final itemIndex = updatedItems.indexWhere(
        (item) => item['cartItemId'].toString() == event.itemId.toString());
    if (itemIndex == -1) {
      emit(CartError('Item not found in cart.'));
      return;
    }

    // Validate accessoryQuantity
    final newQuantity = event.itemData['accessoryQuantity'];
    if (newQuantity == null || newQuantity is! int || newQuantity <= 0) {
      emit(CartError('Invalid quantity. Please enter a positive number.'));
      return;
    }

    emit(CartLoading());
    try {
      final item = Map<String, dynamic>.from(updatedItems[itemIndex]);
      final unitPrice = item['price'] as double;

      // Update UI immediately
      item['accessoryQuantity'] = newQuantity;
      item['totalPrice'] = unitPrice * newQuantity;
      updatedItems[itemIndex] = item;

      // Declare and initialize variables
      double newTotal = 0.0;
      int newTotalQuantity = 0;
      double saved = 0.0;

      // Recalculate totals
      for (final cartItem in updatedItems) {
        newTotal += (cartItem['totalPrice'] as double);
        newTotalQuantity += (cartItem['accessoryQuantity'] as int);
        final originalPrice = cartItem['originalPrice'] as double;
        final currentPrice = cartItem['price'] as double;
        final quantity = cartItem['accessoryQuantity'] as int;
        if (originalPrice > currentPrice) {
          saved += (originalPrice - currentPrice) * quantity;
        }
      }

      // Emit updated state immediately
      emit(CartLoaded({
        'items': updatedItems,
        'total': newTotal,
        'saved': saved,
        'totalCartQuantity': newTotalQuantity,
      }));

      // Then make the API call in background
      final response = await _getDio().put(
        TerraApi.updateCartItem(event.itemId.toString()),
        data: {
          'accessoryQuantity': newQuantity,
        },
      );

      if (response.statusCode == 200) {
        // Quietly refresh the cart data to sync with server
        final refreshResponse = await _getDio().get(TerraApi.getCart());
        final data = refreshResponse.data;

        if (data is Map<String, dynamic> && data['status'] == 200) {
          final cartData = data['data'] as Map<String, dynamic>;
          final total = (cartData['totalCartPrice'] ?? 0.0).toDouble();
          final totalCartQuantity = (cartData['totalCartQuantity'] ?? 0) as int;
          final rawCartItems = cartData['cartItems'] as List<dynamic>? ?? [];

          final List<Map<String, dynamic>> items = [];
          for (final cartItem in rawCartItems) {
            final cartItemId = cartItem['cartItemId'];
            final accessoryId = cartItem['accessoryId'];
            final itemList = cartItem['item'] as List<dynamic>? ?? [];
            final itemDetails = itemList.isNotEmpty
                ? itemList.first as Map<String, dynamic>
                : <String, dynamic>{};

            items.add({
              'id': cartItemId,
              'cartItemId': cartItemId,
              'accessoryId': accessoryId,
              'accessoryName': itemDetails['productName'] ?? 'Unknown Item',
              'accessoryQuantity': itemDetails['quantity'] ?? 1,
              'price': (itemDetails['price'] ?? 0.0).toDouble(),
              'originalPrice': (itemDetails['price'] ?? 0.0).toDouble(),
              'imageUrl':
                  'https://i.pinimg.com/1200x/d1/d5/1f/d1d51f814f974cc6b9bb438c1c790d59.jpg',
              'totalPrice': (itemDetails['totalPrice'] ?? 0.0).toDouble(),
              'description': '',
            });
          }

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
        }
      } else {
        emit(CartError(
            'Failed to update item: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      developer.log('💥 Error updating cart item: $e', name: 'CartBloc');
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(CartError('Authentication failed. Please log in again.'));
        } else {
          emit(CartError(
              'Failed to update item: ${e.response?.data['message'] ?? e.message}'));
        }
      } else {
        emit(CartError('Failed to update item: $e'));
      }
    }
  }

  Future<void> _onDeleteCartItem(
      DeleteCartItem event, Emitter<CartState> emit) async {
    if (_storedToken == null || _storedToken!.isEmpty) {
      emit(CartError('Authentication required. Please log in again.'));
      return;
    }

    emit(CartLoading());
    try {
      developer.log('🗑️ Deleting cart item: ID=${event.itemId}',
          name: 'CartBloc');
      final response = await _getDio().delete(
        TerraApi.deleteCartItem(event.itemId.toString()),
      );

      developer.log(
          '🗑️ Delete response: ${response.statusCode} - ${response.data}',
          name: 'CartBloc');
      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(CartOperationSuccess('Item removed from cart'));
        add(FetchCart()); // Refresh cart
      } else {
        emit(CartError(
            'Failed to delete item: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      developer.log('💥 Error deleting cart item: $e', name: 'CartBloc');
      if (e is DioException) {
        developer.log('📋 Error details: ${e.response?.data}',
            name: 'CartBloc');
        if (e.response?.statusCode == 401) {
          emit(CartError('Authentication failed. Please log in again.'));
        } else {
          emit(CartError(
              'Failed to delete item: ${e.response?.data['message'] ?? e.message}'));
        }
      } else {
        emit(CartError('Failed to delete item: $e'));
      }
    }
  }

  Future<void> _onDeleteAllCartItems(
      DeleteAllCartItems event, Emitter<CartState> emit) async {
    if (_storedToken == null || _storedToken!.isEmpty) {
      emit(CartError('Authentication required. Please log in again.'));
      return;
    }

    emit(CartLoading());
    try {
      developer.log('🗑️ Deleting all cart items...', name: 'CartBloc');
      final response = await _getDio().delete(
        TerraApi.deleteAllCartItems(),
      );

      developer.log(
          '🗑️ Delete all response: ${response.statusCode} - ${response.data}',
          name: 'CartBloc');
      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(CartOperationSuccess('Cart cleared successfully'));
        add(FetchCart()); // Refresh cart
      } else {
        emit(CartError(
            'Failed to clear cart: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      developer.log('💥 Error clearing cart: $e', name: 'CartBloc');
      if (e is DioException) {
        developer.log('📋 Error details: ${e.response?.data}',
            name: 'CartBloc');
        if (e.response?.statusCode == 401) {
          emit(CartError('Authentication failed. Please log in again.'));
        } else {
          emit(CartError(
              'Failed to clear cart: ${e.response?.data['message'] ?? e.message}'));
        }
      } else {
        emit(CartError('Failed to clear cart: $e'));
      }
    }
  }
}
