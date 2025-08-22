import 'package:flutter/material.dart';

class TerrariumDetails extends StatelessWidget {
  final Map<String, dynamic> terrarium;

  const TerrariumDetails({
    super.key,
    required this.terrarium,
  });

  @override
  Widget build(BuildContext context) {
    final bodyHTML = terrarium['bodyHTML']?.toString();
    if (bodyHTML == null || bodyHTML.isEmpty) return const SizedBox();

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
                Icons.info_outline,
                color: const Color(0xFF1D7020),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bodyHTML.replaceAll(RegExp(r'<[^>]+>'), ''),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
