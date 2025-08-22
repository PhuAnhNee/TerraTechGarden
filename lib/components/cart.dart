import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../pages/cart/bloc/cart_bloc.dart';
import '../pages/cart/bloc/cart_state.dart';
import '../pages/cart/bloc/cart_event.dart';
import '../../../api/terra_api.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  Map<String, String> accessoryImages = {}; // Cache for accessory images

  String _formatCurrency(double amount) {
    // Format currency for VND (Vietnamese Dong)
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount.toInt())} VNĐ';
  }

  Future<void> _fetchAccessoryImage(String accessoryId) async {
    if (accessoryImages.containsKey(accessoryId)) {
      return; // Already cached
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

      developer.log(
          'API Response for accessory $accessoryId: ${response.statusCode} - ${response.data}',
          name: 'Cart');

      if (response.statusCode == 200 && response.data['status'] == 200) {
        final data = response.data['data'] as Map<String, dynamic>?;
        if (data != null) {
          final imageUrl = data['imageUrl']?.toString() ?? '';
          developer.log(
              'Extracted imageUrl for accessory $accessoryId: $imageUrl',
              name: 'Cart');

          setState(() {
            accessoryImages[accessoryId] = imageUrl.isNotEmpty ? imageUrl : '';
          });
        } else {
          setState(() {
            accessoryImages[accessoryId] = '';
          });
        }
      } else {
        developer.log(
            'Invalid response for accessory $accessoryId: status ${response.data['status']}',
            name: 'Cart');
        setState(() {
          accessoryImages[accessoryId] = '';
        });
      }
    } catch (e, stackTrace) {
      developer.log('Error fetching image for accessory $accessoryId: $e',
          name: 'Cart', error: e, stackTrace: stackTrace);
      setState(() {
        accessoryImages[accessoryId] = '';
      });
    }
  }

  String _getAccessoryImageUrl(dynamic item) {
    final accessoryId =
        item['accessoryId']?.toString() ?? item['id']?.toString();
    if (accessoryId == null) return '';

    // If image is already cached, return it
    if (accessoryImages.containsKey(accessoryId)) {
      return accessoryImages[accessoryId] ?? '';
    }

    // Otherwise, fetch the image
    _fetchAccessoryImage(accessoryId);
    return ''; // Return empty until image is loaded
  }

  void _showDeleteConfirmDialog(BuildContext context, dynamic itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text(
              'Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<CartBloc>().add(DeleteCartItem(itemId.toString()));
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is CartError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
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
                      final originalPrice =
                          item['originalPrice'] ?? item['price'];
                      final discountedPrice = item['price'];
                      final defaultImageUrl =
                          'https://i.pinimg.com/1200x/d1/d5/1f/d1d51f814f974cc6b9bb438c1c790d59.jpg';

                      // Get the image URL from API or use cached version
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
                                    // Description (if available)
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
                                                        context
                                                            .read<CartBloc>()
                                                            .add(
                                                              UpdateCartItem(
                                                                item['cartItemId']
                                                                    .toString(),
                                                                {
                                                                  'accessoryQuantity':
                                                                      newQuantity
                                                                },
                                                              ),
                                                            );
                                                      } else {
                                                        _showDeleteConfirmDialog(
                                                            context,
                                                            item['cartItemId']);
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
                                                      context
                                                          .read<CartBloc>()
                                                          .add(
                                                            UpdateCartItem(
                                                              item['cartItemId']
                                                                  .toString(),
                                                              {
                                                                'accessoryQuantity':
                                                                    currentQuantity +
                                                                        1
                                                              },
                                                            ),
                                                          );
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
                                  _showDeleteConfirmDialog(
                                      context, item['cartItemId']);
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
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/checkout',
                              arguments:
                                  state.cartData['total']?.toDouble() ?? 0.0,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Thanh toán (${state.cartData['totalCartQuantity'] ?? 0} sản phẩm)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Clear Cart Button
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
