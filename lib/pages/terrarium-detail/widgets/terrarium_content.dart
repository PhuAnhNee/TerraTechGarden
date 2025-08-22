import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'contents/terrarium_product_info.dart';
import 'contents/terrarium_image_thumbnails.dart';
import 'contents/terrarium_description.dart';
import 'contents/terrarium_variants.dart';
import 'contents/terrarium_accessories.dart';
import 'contents/terrarium_details.dart';

class TerrariumContent extends StatelessWidget {
  final Map<String, dynamic> terrarium;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final int selectedImageIndex;
  final bool isFavorite;
  final Function(int) onImageSelected;
  final VoidCallback onFavoriteToggle;

  const TerrariumContent({
    super.key,
    required this.terrarium,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.selectedImageIndex,
    required this.isFavorite,
    required this.onImageSelected,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final images = terrarium['terrariumImages'] as List<dynamic>? ?? [];

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              TerrariumProductInfo(
                terrarium: terrarium,
                isFavorite: isFavorite,
                onFavoriteToggle: onFavoriteToggle,
              ),
              TerrariumImageThumbnails(
                images: images,
                selectedImageIndex: selectedImageIndex,
                onImageSelected: onImageSelected,
              ),
              TerrariumDescription(terrarium: terrarium),
              TerrariumVariants(terrarium: terrarium),
              TerrariumAccessories(terrarium: terrarium),
              TerrariumDetails(terrarium: terrarium),
            ],
          ),
        ),
      ),
    );
  }
}
