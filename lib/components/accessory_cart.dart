import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class AccessoryCart extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;

  const AccessoryCart({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    double totalPrice =
        cartItems.fold(0, (sum, item) => sum + (item['price'] ?? 0));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D7020),
        foregroundColor: Colors.white,
        title: const Text('Giỏ Hàng'),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Giỏ hàng trống',
                style: TextStyle(
                  color: Color(0xFF1D7020),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final imageUrl = item['accessoryImages'] != null &&
                              (item['accessoryImages'] as List).isNotEmpty
                          ? (item['accessoryImages'] as List)
                                  .first['imageUrl'] ??
                              'https://via.placeholder.com/150'
                          : 'https://via.placeholder.com/150';
                      final name = item['accessoryName'] ?? 'Unnamed Accessory';
                      final price = item['price'] ?? 'N/A';

                      return Card(
                        elevation: 6,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    developer.log(
                                        'Image load error for $name: $error',
                                        name: 'AccessoryCart');
                                    return const Icon(Icons.error,
                                        color: Colors.red);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Price: $price VND',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Color(0xFF1D7020)),
                                          onPressed: () {
                                            developer.log(
                                                'Decrease quantity for $name',
                                                name: 'AccessoryCart');
                                          },
                                        ),
                                        const Text('1',
                                            style: TextStyle(fontSize: 16)),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.add_circle_outline,
                                              color: Color(0xFF1D7020)),
                                          onPressed: () {
                                            developer.log(
                                                'Increase quantity for $name',
                                                name: 'AccessoryCart');
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  developer.log('Remove item: $name',
                                      name: 'AccessoryCart');
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng: ${totalPrice.toStringAsFixed(0)} VND',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D7020),
                        ),
                      ),
                      SizedBox(
                        width: 150, // Fixed width for button
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D7020),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            // Placeholder button, no action
                            developer.log('Proceed to checkout',
                                name: 'AccessoryCart');
                          },
                          child: const Text(
                            'Thanh Toán',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
