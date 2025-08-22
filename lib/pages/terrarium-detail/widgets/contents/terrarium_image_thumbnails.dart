import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TerrariumImageThumbnails extends StatelessWidget {
  final List<dynamic> images;
  final int selectedImageIndex;
  final Function(int) onImageSelected;

  const TerrariumImageThumbnails({
    super.key,
    required this.images,
    required this.selectedImageIndex,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox();

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onImageSelected(index),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedImageIndex == index
                      ? const Color(0xFF1D7020)
                      : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: images[index]['imageUrl']?.toString() ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1D7020),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
