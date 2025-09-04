import 'package:flutter/material.dart';
import 'dart:convert'; // Thêm import này

class TerrariumDetails extends StatelessWidget {
  final Map<String, dynamic> terrarium;

  const TerrariumDetails({
    super.key,
    required this.terrarium,
  });

  // Hàm để decode HTML entities và loại bỏ HTML tags
  String _decodeHtmlString(String htmlString) {
    // Bước 1: Loại bỏ HTML tags
    String withoutTags = htmlString.replaceAll(RegExp(r'<[^>]+>'), '');

    // Bước 2: Decode HTML entities
    String decoded = withoutTags
        .replaceAll('&aacute;', 'á')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&iacute;', 'í')
        .replaceAll('&oacute;', 'ó')
        .replaceAll('&uacute;', 'ú')
        .replaceAll('&Aacute;', 'Á')
        .replaceAll('&Eacute;', 'É')
        .replaceAll('&Iacute;', 'Í')
        .replaceAll('&Oacute;', 'Ó')
        .replaceAll('&Uacute;', 'Ú')
        .replaceAll('&agrave;', 'à')
        .replaceAll('&egrave;', 'è')
        .replaceAll('&igrave;', 'ì')
        .replaceAll('&ograve;', 'ò')
        .replaceAll('&ugrave;', 'ù')
        .replaceAll('&Agrave;', 'À')
        .replaceAll('&Egrave;', 'È')
        .replaceAll('&Igrave;', 'Ì')
        .replaceAll('&Ograve;', 'Ò')
        .replaceAll('&Ugrave;', 'Ù')
        .replaceAll('&acirc;', 'â')
        .replaceAll('&ecirc;', 'ê')
        .replaceAll('&icirc;', 'î')
        .replaceAll('&ocirc;', 'ô')
        .replaceAll('&ucirc;', 'û')
        .replaceAll('&Acirc;', 'Â')
        .replaceAll('&Ecirc;', 'Ê')
        .replaceAll('&Icirc;', 'Î')
        .replaceAll('&Ocirc;', 'Ô')
        .replaceAll('&Ucirc;', 'Û')
        .replaceAll('&atilde;', 'ã')
        .replaceAll('&etilde;', 'ẽ')
        .replaceAll('&itilde;', 'ĩ')
        .replaceAll('&otilde;', 'õ')
        .replaceAll('&utilde;', 'ũ')
        .replaceAll('&Atilde;', 'Ã')
        .replaceAll('&Etilde;', 'Ẽ')
        .replaceAll('&Itilde;', 'Ĩ')
        .replaceAll('&Otilde;', 'Õ')
        .replaceAll('&Utilde;', 'Ũ')
        .replaceAll('&auml;', 'ä')
        .replaceAll('&euml;', 'ë')
        .replaceAll('&iuml;', 'ï')
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&uuml;', 'ü')
        .replaceAll('&Auml;', 'Ä')
        .replaceAll('&Euml;', 'Ë')
        .replaceAll('&Iuml;', 'Ï')
        .replaceAll('&Ouml;', 'Ö')
        .replaceAll('&Uuml;', 'Ü')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—')
        .replaceAll('&hellip;', '…');

    return decoded.trim();
  }

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
            _decodeHtmlString(bodyHTML), // Sử dụng hàm decode
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
