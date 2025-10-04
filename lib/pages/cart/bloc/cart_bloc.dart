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
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    if (_storedToken != null && _storedToken!.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $_storedToken';
      developer.log(
          'Authorization header set: Bearer ${_storedToken!.substring(0, 20)}...',
          name: 'CartBloc');
    } else {
      developer.log('NO TOKEN PROVIDED - This will cause 401/500 errors!',
          name: 'CartBloc');
    }

    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = '*/*';

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log('REQUEST: ${options.method} ${options.path}',
            name: 'CartBloc');
        developer.log('Headers: ${options.headers}', name: 'CartBloc');
        if (options.data != null) {
          developer.log('Data: ${options.data}', name: 'CartBloc');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log(
            'RESPONSE: ${response.statusCode} ${response.statusMessage}',
            name: 'CartBloc');
        developer.log('Response data: ${response.data}', name: 'CartBloc');
        handler.next(response);
      },
      onError: (error, handler) {
        developer.log('ERROR: ${error.response?.statusCode} ${error.message}',
            name: 'CartBloc');
        developer.log('Error response: ${error.response?.data}',
            name: 'CartBloc');
        handler.next(error);
      },
    ));

    return dio;
  }

  bool _isValidUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          uri.hasAuthority; // Ensures scheme (http/https) and host are present
    } catch (e) {
      return false;
    }
  }

  // Fetch Cart method giữ nguyên
  Future<void> _onFetchCart(FetchCart event, Emitter<CartState> emit) async {
    developer.log('Starting to fetch cart...', name: 'CartBloc');

    if (_storedToken == null || _storedToken!.isEmpty) {
      developer.log('Cannot fetch cart: No authentication token!',
          name: 'CartBloc');
      emit(CartError('Authentication required. Please log in again.'));
      return;
    }

    emit(CartLoading());
    try {
      final response = await _getDio().get(TerraApi.getCart());

      developer.log('Response Status: ${response.statusCode}',
          name: 'CartBloc');

      final responseData = response.data;

      if (responseData is Map<String, dynamic> &&
          responseData['status'] == 200 &&
          responseData.containsKey('data')) {
        final cartData = responseData['data'] as Map<String, dynamic>;

        final bundleItems = cartData['bundleItems'] as List<dynamic>? ?? [];
        final singleItems = cartData['singleItems'] as List<dynamic>? ?? [];
        final serverTotal = _safeToDouble(cartData['totalCartPrice']);
        final serverTotalQuantity = _safeToInt(cartData['totalCartQuantity']);

        developer.log(
            'Processing ${bundleItems.length} bundle items and ${singleItems.length} single items',
            name: 'CartBloc');

        final List<Map<String, dynamic>> items = [];
        double calculatedTotal = 0.0;
        int calculatedTotalQuantity = 0;
        double saved = 0.0;

        // Default placeholder image URL
        const String defaultImageUrl =
            'https://via.placeholder.com/150'; // Replace with your own placeholder image

        // Process bundle items
        for (int bundleIndex = 0;
            bundleIndex < bundleItems.length;
            bundleIndex++) {
          final bundleItem =
              bundleItems[bundleIndex] as Map<String, dynamic>? ?? {};
          final bundleAccessories =
              bundleItem['bundleAccessories'] as List<dynamic>? ?? [];

          for (int accIndex = 0;
              accIndex < bundleAccessories.length;
              accIndex++) {
            final accessory =
                bundleAccessories[accIndex] as Map<String, dynamic>? ?? {};
            final itemList = accessory['item'] as List<dynamic>? ?? [];

            if (itemList.isEmpty) continue;

            final itemData = itemList.first as Map<String, dynamic>? ?? {};
            if (itemData.isEmpty) continue;

            final cartItemId = accessory['cartItemId'];
            final accessoryId = accessory['accessoryId'];
            final accessoryName = itemData['productName'] ?? 'Unknown Item';
            final quantity = _safeToInt(itemData['quantity']);
            final price = _safeToDouble(itemData['price']);
            final totalPrice = _safeToDouble(itemData['totalPrice']);
            final imageUrl = itemData['imageUrl']?.toString() ?? '';

            // Validate imageUrl and use default if invalid
            final validImageUrl =
                _isValidUrl(imageUrl) ? imageUrl : defaultImageUrl;

            if (imageUrl.isEmpty || !_isValidUrl(imageUrl)) {
              developer.log(
                  'Invalid or missing imageUrl for bundle item $accessoryName (cartItemId: $cartItemId): "$imageUrl". Using default: $defaultImageUrl',
                  name: 'CartBloc');
            }

            items.add({
              'id': cartItemId ?? '$bundleIndex-$accIndex',
              'cartItemId': cartItemId ?? '$bundleIndex-$accIndex',
              'accessoryId': accessoryId,
              'accessoryName': accessoryName,
              'accessoryQuantity': quantity,
              'price': price,
              'originalPrice': price,
              'imageUrl': validImageUrl, // Use validated URL
              'totalPrice': totalPrice,
              'description': '',
            });

            calculatedTotal += totalPrice;
            calculatedTotalQuantity += quantity;

            developer.log(
                'Added bundle accessory: $accessoryName (qty: $quantity, total: $totalPrice, cartItemId: $cartItemId)',
                name: 'CartBloc');
          }
        }

        // Process single items
        for (int singleIndex = 0;
            singleIndex < singleItems.length;
            singleIndex++) {
          final singleItem =
              singleItems[singleIndex] as Map<String, dynamic>? ?? {};
          final itemList = singleItem['item'] as List<dynamic>? ?? [];

          if (itemList.isEmpty) continue;

          final itemData = itemList.first as Map<String, dynamic>? ?? {};
          if (itemData.isEmpty) continue;

          final cartItemId = singleItem['cartItemId'];
          final accessoryId = singleItem['accessoryId'];
          final accessoryName = itemData['productName'] ?? 'Unknown Item';
          final quantity = _safeToInt(itemData['quantity']);
          final price = _safeToDouble(itemData['price']);
          final totalPrice = _safeToDouble(itemData['totalPrice']);
          final imageUrl = itemData['imageUrl']?.toString() ?? '';

          // Validate imageUrl and use default if invalid
          final validImageUrl =
              _isValidUrl(imageUrl) ? imageUrl : defaultImageUrl;

          if (imageUrl.isEmpty || !_isValidUrl(imageUrl)) {
            developer.log(
                'Invalid or missing imageUrl for single item $accessoryName (cartItemId: $cartItemId): "$imageUrl". Using default: $defaultImageUrl',
                name: 'CartBloc');
          }

          items.add({
            'id': cartItemId ?? 'single-$singleIndex',
            'cartItemId': cartItemId ?? 'single-$singleIndex',
            'accessoryId': accessoryId,
            'accessoryName': accessoryName,
            'accessoryQuantity': quantity,
            'price': price,
            'originalPrice': price,
            'imageUrl': validImageUrl, // Use validated URL
            'totalPrice': totalPrice,
            'description': '',
          });

          calculatedTotal += totalPrice;
          calculatedTotalQuantity += quantity;

          developer.log(
              'Added single item: $accessoryName (qty: $quantity, total: $totalPrice, cartItemId: $cartItemId)',
              name: 'CartBloc');
        }

        final finalTotal = serverTotal > 0 ? serverTotal : calculatedTotal;
        final finalTotalQuantity = serverTotalQuantity > 0
            ? serverTotalQuantity
            : calculatedTotalQuantity;

        developer.log(
            'FINAL RESULT: ${items.length} items, Total: $finalTotal, TotalQty: $finalTotalQuantity',
            name: 'CartBloc');

        emit(CartLoaded({
          'items': items,
          'total': finalTotal,
          'saved': saved,
          'totalCartQuantity': finalTotalQuantity,
        }));
      } else {
        developer.log(
            'Invalid response format. Expected {status: 200, data: {...}}',
            name: 'CartBloc');
        developer.log('Actual response: $responseData', name: 'CartBloc');
        emit(CartError('Invalid response format from server'));
      }
    } catch (e) {
      developer.log('Critical error fetching cart: $e', name: 'CartBloc');
      if (e is DioException) {
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

  int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Add Cart Items method giữ nguyên
  Future<void> _onAddCartItems(
      AddCartItems event, Emitter<CartState> emit) async {
    if (_storedToken == null || _storedToken!.isEmpty) {
      emit(CartError('Authentication required. Please log in again.'));
      return;
    }

    developer.log('Adding items to cart: ${event.items}', name: 'CartBloc');
    emit(CartLoading());

    try {
      for (final item in event.items) {
        final accessoryId = int.tryParse(item['accessoryId'].toString()) ?? 0;
        final accessoryQuantity = (item['accessoryQuantity'] ?? 1).toInt();

        if (accessoryId <= 0) {
          emit(CartError('Invalid accessory ID provided'));
          return;
        }

        final requestData = {
          'accessoryId': accessoryId,
          'accessoryQuantity': accessoryQuantity,
        };

        developer.log('Adding single item: $requestData', name: 'CartBloc');

        final response = await _getDio().post(
          TerraApi.addMultipleCartItems(),
          data: requestData,
        );

        developer.log(
            'Add item response: ${response.statusCode} - ${response.data}',
            name: 'CartBloc');

        if (response.statusCode != 200 && response.statusCode != 201) {
          final errorMsg = response.data is Map<String, dynamic>
              ? response.data['message'] ?? 'Unknown error'
              : 'Unknown error';
          emit(CartError('Failed to add item: $errorMsg'));
          return;
        }
      }

      emit(CartOperationSuccess('Items added to cart successfully'));
      add(FetchCart());
    } catch (e) {
      developer.log('Error adding items to cart: $e', name: 'CartBloc');
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(CartError('Authentication failed. Please log in again.'));
        } else {
          final errorMsg = e.response?.data is Map<String, dynamic>
              ? e.response!.data['message'] ?? e.message
              : e.message;
          emit(CartError('Failed to add items: $errorMsg'));
        }
      } else {
        emit(CartError('Failed to add items: $e'));
      }
    }
  }

  // Update Cart Item method - Fixed to handle integer conversion
  Future<void> _onUpdateCartItem(
      UpdateCartItem event, Emitter<CartState> emit) async {
    if (_storedToken == null || _storedToken!.isEmpty) {
      emit(CartError('Authentication required. Please log in again.'));
      return;
    }

    if (state is! CartLoaded) {
      emit(CartError('Cart data not loaded. Please try again.'));
      return;
    }

    final currentState = state as CartLoaded;
    final updatedItems =
        List<Map<String, dynamic>>.from(currentState.cartData['items'] ?? []);

    final itemIndex = updatedItems.indexWhere(
        (item) => item['cartItemId'].toString() == event.itemId.toString());
    if (itemIndex == -1) {
      emit(CartError('Item not found in cart.'));
      return;
    }

    final newQuantityRaw = event.itemData['accessoryQuantity'];
    int newQuantity;

    if (newQuantityRaw == null) {
      emit(CartError('Invalid quantity. Please enter a positive number.'));
      return;
    }

    if (newQuantityRaw is int) {
      newQuantity = newQuantityRaw;
    } else if (newQuantityRaw is num) {
      newQuantity = newQuantityRaw.toInt();
    } else {
      emit(CartError('Invalid quantity. Please enter a positive number.'));
      return;
    }

    if (newQuantity <= 0) {
      emit(CartError('Invalid quantity. Please enter a positive number.'));
      return;
    }

    emit(CartLoading());
    try {
      final item = Map<String, dynamic>.from(updatedItems[itemIndex]);
      final unitPrice = item['price'] as double;

      item['accessoryQuantity'] = newQuantity;
      item['totalPrice'] = unitPrice * newQuantity;
      updatedItems[itemIndex] = item;

      double newTotal = 0.0;
      int newTotalQuantity = 0;
      double saved = 0.0;

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

      emit(CartLoaded({
        'items': updatedItems,
        'total': newTotal,
        'saved': saved,
        'totalCartQuantity': newTotalQuantity,
      }));

      // Convert itemId to integer for API call
      final itemIdInt = int.tryParse(event.itemId.toString());
      if (itemIdInt == null) {
        emit(CartError('Invalid item ID format for update.'));
        return;
      }

      final response = await _getDio().put(
        TerraApi.updateCartItem(itemIdInt.toString()),
        data: {
          'accessoryQuantity': newQuantity,
        },
      );

      if (response.statusCode == 200) {
        add(FetchCart());
      } else {
        final errorMsg = response.data is Map<String, dynamic>
            ? response.data['message'] ?? 'Unknown error'
            : 'Unknown error';
        emit(CartError('Failed to update item: $errorMsg'));
      }
    } catch (e) {
      developer.log('Error updating cart item: $e', name: 'CartBloc');
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(CartError('Authentication failed. Please log in again.'));
        } else {
          final errorMsg = e.response?.data is Map<String, dynamic>
              ? e.response!.data['message'] ?? e.message
              : e.message;
          emit(CartError('Failed to update item: $errorMsg'));
        }
      } else {
        emit(CartError('Failed to update item: $e'));
      }
    }
  }

  // FIXED DELETE METHOD - Đây là phần quan trọng nhất
  Future<void> _onDeleteCartItem(
      DeleteCartItem event, Emitter<CartState> emit) async {
    developer.log('=== DELETE CART ITEM EVENT RECEIVED ===', name: 'CartBloc');
    developer.log('Event itemId: ${event.itemId}', name: 'CartBloc');
    developer.log('Event itemId type: ${event.itemId.runtimeType}',
        name: 'CartBloc');

    if (_storedToken == null || _storedToken!.isEmpty) {
      developer.log('ERROR: No token available!', name: 'CartBloc');
      emit(CartError('Authentication required. Please log in again.'));
      return;
    }

    developer.log('Token available: ${_storedToken!.substring(0, 20)}...',
        name: 'CartBloc');

    emit(CartLoading());

    try {
      // Convert ID to string for URL
      final itemIdStr = event.itemId.toString().trim();
      developer.log('Item ID as string: "$itemIdStr"', name: 'CartBloc');

      if (itemIdStr.isEmpty || itemIdStr == 'null') {
        developer.log('ERROR: Invalid item ID string', name: 'CartBloc');
        emit(CartError('Invalid item ID'));
        return;
      }

      // Build delete URL
      final deleteUrl = TerraApi.deleteCartItem(itemIdStr);
      developer.log('DELETE URL: $deleteUrl', name: 'CartBloc');

      // Create dio with debug
      final dio = Dio();
      dio.options.headers = {
        'Authorization': 'Bearer $_storedToken',
        'accept': '*/*',
      };
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      // Add interceptor for detailed logging
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          developer.log('=== MAKING DELETE REQUEST ===', name: 'CartBloc');
          developer.log('Method: ${options.method}', name: 'CartBloc');
          developer.log('URL: ${options.uri}', name: 'CartBloc');
          developer.log('Headers: ${options.headers}', name: 'CartBloc');
          handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log('=== DELETE RESPONSE RECEIVED ===', name: 'CartBloc');
          developer.log('Status Code: ${response.statusCode}',
              name: 'CartBloc');
          developer.log('Status Message: ${response.statusMessage}',
              name: 'CartBloc');
          developer.log('Response Headers: ${response.headers}',
              name: 'CartBloc');
          developer.log('Response Data: ${response.data}', name: 'CartBloc');
          handler.next(response);
        },
        onError: (error, handler) {
          developer.log('=== DELETE REQUEST ERROR ===', name: 'CartBloc');
          developer.log('Error Type: ${error.type}', name: 'CartBloc');
          developer.log('Error Message: ${error.message}', name: 'CartBloc');
          developer.log('Status Code: ${error.response?.statusCode}',
              name: 'CartBloc');
          developer.log('Error Response: ${error.response?.data}',
              name: 'CartBloc');
          handler.next(error);
        },
      ));

      developer.log('About to send DELETE request...', name: 'CartBloc');

      final response = await dio.delete(deleteUrl);

      developer.log('Delete request completed!', name: 'CartBloc');

      // Handle response based on your API example
      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          final status = responseData['status'];
          final message = responseData['message'];

          developer.log('API Status: $status', name: 'CartBloc');
          developer.log('API Message: $message', name: 'CartBloc');

          if (status == 200) {
            developer.log('DELETE SUCCESSFUL!', name: 'CartBloc');
            emit(CartOperationSuccess(message ?? 'Item removed from cart'));

            // Refresh cart
            developer.log('Refreshing cart...', name: 'CartBloc');
            add(FetchCart());
          } else {
            developer.log('API returned error status: $status',
                name: 'CartBloc');
            emit(CartError(message ?? 'Failed to delete item'));
          }
        } else {
          developer.log(
              'Unexpected response format: ${responseData.runtimeType}',
              name: 'CartBloc');
          emit(CartError('Unexpected response format'));
        }
      } else {
        developer.log('HTTP error status: ${response.statusCode}',
            name: 'CartBloc');
        emit(CartError('HTTP error: ${response.statusCode}'));
      }
    } catch (e, stackTrace) {
      developer.log('=== EXCEPTION IN DELETE ===', name: 'CartBloc');
      developer.log('Exception: $e', name: 'CartBloc');
      developer.log('Stack trace: $stackTrace', name: 'CartBloc');

      if (e is DioException) {
        developer.log('DioException type: ${e.type}', name: 'CartBloc');
        developer.log('DioException message: ${e.message}', name: 'CartBloc');
        developer.log('DioException response: ${e.response}', name: 'CartBloc');

        String errorMessage = 'Failed to delete item';
        if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication failed';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Item not found';
          // Consider this success since item is gone
          emit(CartOperationSuccess('Item removed from cart'));
          add(FetchCart());
          return;
        } else if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        }

        emit(CartError(errorMessage));
      } else {
        emit(CartError('Network error: $e'));
      }
    }
  }

  // Delete All Cart Items method giữ nguyên
  Future<void> _onDeleteAllCartItems(
      DeleteAllCartItems event, Emitter<CartState> emit) async {
    if (_storedToken == null || _storedToken!.isEmpty) {
      emit(CartError('Authentication required. Please log in again.'));
      return;
    }

    emit(CartLoading());
    try {
      developer.log('Deleting all cart items...', name: 'CartBloc');

      final response = await _getDio().delete(
        TerraApi.deleteAllCartItems(),
      );

      developer.log(
          'Delete all response: ${response.statusCode} - ${response.data}',
          name: 'CartBloc');

      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(CartOperationSuccess('Cart cleared successfully'));
        add(FetchCart());
      } else {
        final errorMsg = response.data is Map<String, dynamic>
            ? response.data['message'] ?? 'Unknown error'
            : 'Unknown error';
        emit(CartError('Failed to clear cart: $errorMsg'));
      }
    } catch (e) {
      developer.log('Error clearing cart: $e', name: 'CartBloc');
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(CartError('Authentication failed. Please log in again.'));
        } else {
          final errorMsg = e.response?.data is Map<String, dynamic>
              ? e.response!.data['message'] ?? e.message
              : e.message;
          emit(CartError('Failed to clear cart: $errorMsg'));
        }
      } else {
        emit(CartError('Failed to clear cart: $e'));
      }
    }
  }
}
