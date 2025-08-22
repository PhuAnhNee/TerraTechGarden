import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddAllConfirmDialog extends StatelessWidget {
  final Map<String, dynamic> terrarium;
  final List<Map<String, dynamic>> cartItems;
  final bool isAddToCart;
  final VoidCallback onConfirm;

  const AddAllConfirmDialog({
    super.key,
    required this.terrarium,
    required this.cartItems,
    required this.isAddToCart,
    required this.onConfirm,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount.toInt())} VNĐ';
  }

  @override
  Widget build(BuildContext context) {
    final accessories = terrarium['accessories'] as List<dynamic>? ?? [];
    final totalPrice = accessories.fold<double>(
        0.0, (sum, accessory) => sum + (accessory['price'] ?? 0.0).toDouble());

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            isAddToCart ? Icons.shopping_cart_outlined : Icons.flash_on,
            color: isAddToCart ? const Color(0xFF1D7020) : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAddToCart ? 'Add All to Cart' : 'Buy All Now',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add all accessories from "${terrarium['terrariumName'] ?? 'Terrarium'}" to cart?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Items to add: ${cartItems.length}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: accessories.length,
                itemBuilder: (context, index) {
                  final accessory = accessories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_box_outlined,
                          size: 16,
                          color: const Color(0xFF1D7020),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            accessory['accessoryName']?.toString() ??
                                accessory['name']?.toString() ??
                                'Accessory ${index + 1}',
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatCurrency(
                              (accessory['price'] ?? 0.0).toDouble()),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D7020),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatCurrency(totalPrice),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D7020),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isAddToCart ? const Color(0xFF1D7020) : Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(isAddToCart ? 'Add All' : 'Buy All'),
        ),
      ],
    );
  }
}
