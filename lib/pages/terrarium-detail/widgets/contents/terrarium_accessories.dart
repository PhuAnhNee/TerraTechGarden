import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TerrariumAccessories extends StatelessWidget {
  final Map<String, dynamic> terrarium;

  const TerrariumAccessories({
    super.key,
    required this.terrarium,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount.toInt())} VNĐ';
  }

  @override
  Widget build(BuildContext context) {
    final accessories = terrarium['accessories'] as List<dynamic>? ?? [];
    if (accessories.isEmpty) return const SizedBox();

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
          Row(
            children: [
              Icon(
                Icons.widgets,
                color: const Color(0xFF1D7020),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Accessories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...accessories.map<Widget>((accessory) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D7020).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_box_outlined,
                      color: const Color(0xFF1D7020),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          accessory['name']?.toString() ??
                              accessory['accessoryName']?.toString() ??
                              '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (accessory['description'] != null &&
                            accessory['description'].toString().isNotEmpty)
                          Text(
                            accessory['description'].toString(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency((accessory['price'] ?? 0.0).toDouble()),
                    style: const TextStyle(
                      color: Color(0xFF1D7020),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
