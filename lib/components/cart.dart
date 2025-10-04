import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../pages/cart/bloc/cart_bloc.dart';
import '../pages/cart/bloc/cart_state.dart';
import '../pages/cart/bloc/cart_event.dart';
import '../../../api/terra_api.dart';
import '../../../config/config.dart'; // Import AppConfig để lấy token
import '../pages/authentication/bloc/auth_bloc.dart'; // Import AuthBloc
import '../pages/authentication/bloc/auth_state.dart'; // Import AuthState

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  Map<String, String> accessoryImages = {};
  bool _isProcessingCheckout = false;

  @override
  void initState() {
    super.initState();
  }

  // Lấy token từ AppConfig hoặc AuthBloc
  String? get _currentToken {
    // Thử lấy từ AppConfig trước
    if (AppConfig.accessToken != null && AppConfig.accessToken!.isNotEmpty) {
      return AppConfig.accessToken;
    }

    // Nếu không có, thử lấy từ AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.token != null) {
      return authState.token;
    }

    // Hoặc lấy trực tiếp từ AuthBloc
    return context.read<AuthBloc>().token;
  }

  Dio _getDio() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    final token = _currentToken;
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
      developer.log('Using token: ${token.substring(0, 20)}...', name: 'Cart');
    } else {
      developer.log('No token available!', name: 'Cart');
    }

    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = '*/*';

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log('REQUEST: ${options.method} ${options.path}',
            name: 'Cart');
        developer.log('Headers: ${options.headers}', name: 'Cart');
        handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log(
            'RESPONSE: ${response.statusCode} ${response.statusMessage}',
            name: 'Cart');
        developer.log('Response data: ${response.data}', name: 'Cart');
        handler.next(response);
      },
      onError: (error, handler) {
        developer.log('ERROR: ${error.response?.statusCode} ${error.message}',
            name: 'Cart');
        developer.log('Error response: ${error.response?.data}', name: 'Cart');

        // Nếu lỗi 401 (Unauthorized), có thể token đã hết hạn
        if (error.response?.statusCode == 401) {
          developer.log('Token expired or invalid, redirecting to login...',
              name: 'Cart');
          _handleTokenExpired();
        }

        handler.next(error);
      },
    ));

    return dio;
  }

  void _handleTokenExpired() {
    // Clear token và redirect về login
    AppConfig.accessToken = null;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'),
        backgroundColor: Colors.red,
      ),
    );

    // Navigate to login screen
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount.toInt())} VNĐ';
  }

  Future<void> _fetchAccessoryImage(String accessoryId) async {
    if (accessoryImages.containsKey(accessoryId)) {
      return;
    }

    try {
      developer.log('Fetching image for accessoryId: $accessoryId',
          name: 'Cart');
      final response = await Dio().get(
        TerraApi.getAccessoryImageById(accessoryId),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'accept': 'text/plain',
        }),
      );

      if (response.statusCode == 200 && response.data['status'] == 200) {
        final data = response.data['data'] as Map<String, dynamic>?;
        if (data != null) {
          final imageUrl = data['imageUrl']?.toString() ?? '';
          setState(() {
            accessoryImages[accessoryId] = imageUrl.isNotEmpty ? imageUrl : '';
          });
        } else {
          setState(() {
            accessoryImages[accessoryId] = '';
          });
        }
      } else {
        setState(() {
          accessoryImages[accessoryId] = '';
        });
      }
    } catch (e) {
      setState(() {
        accessoryImages[accessoryId] = '';
      });
    }
  }

  String _getAccessoryImageUrl(dynamic item) {
    final accessoryId =
        item['accessoryId']?.toString() ?? item['id']?.toString();
    if (accessoryId == null) return '';

    if (accessoryImages.containsKey(accessoryId)) {
      return accessoryImages[accessoryId] ?? '';
    }

    _fetchAccessoryImage(accessoryId);
    return '';
  }

  void _showDeleteConfirmDialog(BuildContext context, dynamic item) {
    developer.log('=== SHOWING DELETE DIALOG ===', name: 'Cart');

    // Try multiple ways to get the ID
    final cartItemId1 = item['cartItemId'];
    final cartItemId2 = item['id'];
    final accessoryId = item['accessoryId'];

    developer.log(
        'cartItemId option 1: $cartItemId1 (${cartItemId1.runtimeType})',
        name: 'Cart');
    developer.log(
        'cartItemId option 2: $cartItemId2 (${cartItemId2.runtimeType})',
        name: 'Cart');
    developer.log('accessoryId: $accessoryId (${accessoryId.runtimeType})',
        name: 'Cart');

    // Choose the best ID
    dynamic finalId;
    if (cartItemId1 != null && cartItemId1.toString() != 'null') {
      finalId = cartItemId1;
    } else if (cartItemId2 != null && cartItemId2.toString() != 'null') {
      finalId = cartItemId2;
    } else {
      developer.log('ERROR: No valid ID found!', name: 'Cart');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi: Không tìm thấy ID hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    developer.log('Final ID chosen: $finalId (${finalId.runtimeType})',
        name: 'Cart');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?'),
              const SizedBox(height: 8),
              // Debug info in dialog
              Text(
                'Debug: ID = $finalId',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                developer.log('User cancelled delete', name: 'Cart');
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                developer.log('=== USER CONFIRMED DELETE ===', name: 'Cart');
                developer.log('Sending delete request for ID: $finalId',
                    name: 'Cart');

                Navigator.of(context).pop();

                // Dispatch delete event
                context
                    .read<CartBloc>()
                    .add(DeleteCartItem(finalId.toString()));
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _proceedToCheckout(double totalAmount) async {
    if (_isProcessingCheckout) return;

    // Check if token is available
    final token = _currentToken;
    if (token == null || token.isEmpty) {
      _showSnackBar(
          'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.', Colors.red);
      _handleTokenExpired();
      return;
    }

    setState(() => _isProcessingCheckout = true);

    try {
      developer.log('Starting checkout process...', name: 'Cart');
      developer.log('Using token: ${token.substring(0, 20)}...', name: 'Cart');

      // Call the checkout cart API
      final response = await _getDio().post(TerraApi.checkoutCart());
      developer.log('Checkout API response: ${response.data}', name: 'Cart');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 201) {
          developer.log('Checkout successful, navigating to checkout screen...',
              name: 'Cart');

          // Extract order data from response
          final orderData = responseData['data'] as Map<String, dynamic>?;

          // Safely extract totalAmount
          double extractedTotal = 0.0;
          if (orderData != null && orderData['total'] != null) {
            final total = orderData['total'];
            if (total is num && total.isFinite && !total.isNaN) {
              extractedTotal = total.toDouble();
            } else if (total is String) {
              final parsed = double.tryParse(total);
              if (parsed != null && parsed.isFinite && !parsed.isNaN) {
                extractedTotal = parsed;
              }
            } else if (total is Map<String, dynamic>) {
              // Handle nested total, e.g., {"value": 100000, "currency": "VND"}
              final nestedKeys = [
                'value',
                'amount',
                'totalAmount',
                'finalAmount'
              ];
              for (String key in nestedKeys) {
                final nestedValue = total[key];
                if (nestedValue is num &&
                    nestedValue.isFinite &&
                    !nestedValue.isNaN) {
                  extractedTotal = nestedValue.toDouble();
                  break;
                } else if (nestedValue is String) {
                  final parsed = double.tryParse(nestedValue);
                  if (parsed != null && parsed.isFinite && !parsed.isNaN) {
                    extractedTotal = parsed;
                    break;
                  }
                }
              }
              if (extractedTotal == 0.0) {
                developer.log('Warning: Could not parse nested total: $total',
                    name: 'Cart');
              }
            }
          } else {
            // Fallback to provided totalAmount
            extractedTotal =
                totalAmount.isFinite && !totalAmount.isNaN ? totalAmount : 0.0;
            developer.log(
                'Warning: No total found in orderData, using fallback: $extractedTotal',
                name: 'Cart');
          }

          developer.log('Extracted total: $extractedTotal', name: 'Cart');

          // Navigate to checkout screen with validated totalAmount
          Navigator.pushNamed(
            context,
            '/checkout',
            arguments: {
              'totalAmount': extractedTotal,
              'orderData': orderData,
            },
          );

          // Refresh cart after checkout
          context.read<CartBloc>().add(FetchCart());
        } else {
          _showSnackBar(
              'Checkout thất bại: ${responseData['message'] ?? 'Unknown error'}',
              Colors.red);
        }
      } else {
        _showSnackBar('Không thể tiến hành checkout', Colors.red);
      }
    } catch (e) {
      developer.log('Checkout error: $e', name: 'Cart');

      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          _showSnackBar(
              'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.', Colors.red);
          _handleTokenExpired();
        } else {
          final errorMsg = e.response?.data is Map<String, dynamic>
              ? e.response!.data['message'] ?? e.message
              : e.message;
          _showSnackBar('Lỗi checkout: $errorMsg', Colors.red);
        }
      } else {
        _showSnackBar('Lỗi hệ thống: $e', Colors.red);
      }
    } finally {
      setState(() => _isProcessingCheckout = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        developer.log('=== CART STATE CHANGED ===', name: 'Cart');
        developer.log('New state: ${state.runtimeType}', name: 'Cart');

        if (state is CartOperationSuccess) {
          developer.log('Success message: ${state.message}', name: 'Cart');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is CartError) {
          developer.log('Error message: ${state.message}', name: 'Cart');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is CartLoading) {
          developer.log('Cart is loading...', name: 'Cart');
        } else if (state is CartLoaded) {
          developer.log(
              'Cart loaded with ${(state.cartData['items'] as List).length} items',
              name: 'Cart');
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1D7020),
              ),
            );
          } else if (state is CartLoaded) {
            final cartItems = state.cartData['items'] as List<dynamic>? ?? [];
            if (cartItems.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Giỏ hàng của bạn đang trống',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Thêm sản phẩm để bắt đầu mua sắm',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];

                      developer.log('Cart item $index: $item', name: 'Cart');
                      developer.log(
                          'Cart item ID: ${item['cartItemId']} (${item['cartItemId'].runtimeType})',
                          name: 'Cart');

                      final originalPrice =
                          item['originalPrice'] ?? item['price'];
                      final discountedPrice = item['price'];
                      final defaultImageUrl =
                          'https://i.pinimg.com/1200x/d1/d5/1f/d1d51f814f974cc6b9bb438c1c790d59.jpg';

                      final apiImageUrl = _getAccessoryImageUrl(item);
                      final imageUrl = apiImageUrl.isNotEmpty
                          ? apiImageUrl
                          : (item['imageUrl']?.isNotEmpty == true
                              ? item['imageUrl']
                              : defaultImageUrl);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Image.network(
                                        defaultImageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Name
                                    Text(
                                      item['accessoryName'] ??
                                          'Sản phẩm không xác định',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    // Description
                                    if (item['description'] != null &&
                                        item['description']
                                            .toString()
                                            .isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          item['description'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    // Price
                                    Row(
                                      children: [
                                        Text(
                                          _formatCurrency(
                                              discountedPrice.toDouble()),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF1D7020),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (originalPrice != discountedPrice)
                                          Text(
                                            _formatCurrency(
                                                originalPrice.toDouble()),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Quantity Controls
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                    color: Colors.grey[300]!),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      final currentQuantity =
                                                          item['accessoryQuantity'] ??
                                                              1;
                                                      final newQuantity =
                                                          currentQuantity - 1;

                                                      if (newQuantity > 0) {
                                                        // Convert to proper format for update
                                                        final cartItemIdRaw =
                                                            item['cartItemId'] ??
                                                                item['id'];
                                                        final cartItemId =
                                                            cartItemIdRaw is int
                                                                ? cartItemIdRaw
                                                                    .toString()
                                                                : cartItemIdRaw
                                                                    ?.toString();

                                                        if (cartItemId !=
                                                                null &&
                                                            cartItemId
                                                                .isNotEmpty &&
                                                            cartItemId !=
                                                                'null') {
                                                          context
                                                              .read<CartBloc>()
                                                              .add(
                                                                UpdateCartItem(
                                                                  cartItemId,
                                                                  {
                                                                    'accessoryQuantity':
                                                                        newQuantity
                                                                  },
                                                                ),
                                                              );
                                                        } else {
                                                          developer.log(
                                                              'Cannot update: Invalid cartItemId',
                                                              name: 'Cart');
                                                        }
                                                      } else {
                                                        _showDeleteConfirmDialog(
                                                            context, item);
                                                      }
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: const Icon(
                                                        Icons.remove,
                                                        size: 16,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                            minWidth: 40),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    child: Text(
                                                      '${item['accessoryQuantity'] ?? 1}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      final currentQuantity =
                                                          item['accessoryQuantity'] ??
                                                              1;
                                                      final cartItemId = item[
                                                                  'cartItemId']
                                                              ?.toString() ??
                                                          item['id']
                                                              ?.toString();

                                                      if (cartItemId != null &&
                                                          cartItemId
                                                              .isNotEmpty &&
                                                          cartItemId !=
                                                              'null') {
                                                        context
                                                            .read<CartBloc>()
                                                            .add(
                                                              UpdateCartItem(
                                                                cartItemId,
                                                                {
                                                                  'accessoryQuantity':
                                                                      currentQuantity +
                                                                          1
                                                                },
                                                              ),
                                                            );
                                                      } else {
                                                        developer.log(
                                                            'Cannot update: Invalid cartItemId',
                                                            name: 'Cart');
                                                      }
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: const Icon(
                                                        Icons.add,
                                                        size: 16,
                                                        color:
                                                            Color(0xFF1D7020),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Total price for this item
                                        Text(
                                          _formatCurrency(
                                              item['totalPrice']?.toDouble() ??
                                                  0.0),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1D7020),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Delete Button
                              IconButton(
                                onPressed: () {
                                  // Debug: Log toàn bộ item data
                                  developer.log('=== DELETE BUTTON CLICKED ===',
                                      name: 'Cart');
                                  developer.log(
                                      'Full item data: ${item.toString()}',
                                      name: 'Cart');
                                  developer.log(
                                      'cartItemId: ${item['cartItemId']}',
                                      name: 'Cart');
                                  developer.log(
                                      'cartItemId type: ${item['cartItemId'].runtimeType}',
                                      name: 'Cart');
                                  developer.log('id: ${item['id']}',
                                      name: 'Cart');
                                  developer.log(
                                      'id type: ${item['id'].runtimeType}',
                                      name: 'Cart');

                                  _showDeleteConfirmDialog(context, item);
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Summary and Checkout
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Summary details
                        if ((state.cartData['saved'] ?? 0.0) > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Bạn đã tiết kiệm',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatCurrency(
                                    state.cartData['saved']?.toDouble() ?? 0.0),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng cộng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatCurrency(
                                  state.cartData['total']?.toDouble() ?? 0.0),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D7020),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Checkout Button
                        ElevatedButton(
                          onPressed: _isProcessingCheckout
                              ? null
                              : () => _proceedToCheckout(
                                  state.cartData['total']?.toDouble() ?? 0.0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isProcessingCheckout
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Đang xử lý...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Thanh toán (${state.cartData['totalCartQuantity'] ?? 0} sản phẩm)',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is CartError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi tải giỏ hàng',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<CartBloc>().add(FetchCart());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D7020),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: Text(
              'Đã xảy ra lỗi',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
