import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TerrariumProductInfo extends StatelessWidget {
  final Map<String, dynamic> terrarium;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const TerrariumProductInfo({
    super.key,
    required this.terrarium,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount.toInt())} VNĐ';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            terrarium['terrariumName'] ?? 'No Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency((terrarium['minPrice'] ?? 0.0).toDouble()),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D7020),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: onFavoriteToggle,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${terrarium['averageRating']?.toString() ?? '0'} (Reviews: ${terrarium['feedbackCount'] ?? 0})',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.inventory,
                size: 20,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Stock: ${terrarium['stock']?.toString() ?? 'Available'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
