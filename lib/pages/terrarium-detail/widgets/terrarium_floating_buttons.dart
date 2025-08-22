import 'package:flutter/material.dart';

class TerrariumFloatingButtons extends StatelessWidget {
  final Map<String, dynamic> terrarium;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const TerrariumFloatingButtons({
    super.key,
    required this.terrarium,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: FloatingActionButton.extended(
              heroTag: "add_to_cart",
              onPressed: onAddToCart,
              backgroundColor: const Color(0xFF1D7020),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text(
                'Add to Cart',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              elevation: 4,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FloatingActionButton.extended(
              heroTag: "buy_now",
              onPressed: onBuyNow,
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.flash_on),
              label: const Text(
                'Buy Now',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }
}
