import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../navigation/routes.dart';

class TerrariumAppBar extends StatelessWidget {
  final Map<String, dynamic> terrarium;
  final int selectedImageIndex;
  final VoidCallback onShare;

  const TerrariumAppBar({
    super.key,
    required this.terrarium,
    required this.selectedImageIndex,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final images = terrarium['terrariumImages'] as List<dynamic>? ?? [];

    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1D7020),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: onShare,
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, Routes.cart);
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildBackgroundImage(images),
      ),
    );
  }

  Widget _buildBackgroundImage(List<dynamic> images) {
    if (images.isNotEmpty &&
        selectedImageIndex < images.length &&
        images[selectedImageIndex]['imageUrl'] != null) {
      return CachedNetworkImage(
        imageUrl: images[selectedImageIndex]['imageUrl'] as String,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFF1D7020),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade300,
          child: const Icon(
            Icons.broken_image,
            size: 50,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey.shade300,
      child: const Icon(
        Icons.image_not_supported,
        size: 50,
        color: Colors.grey,
      ),
    );
  }
}
