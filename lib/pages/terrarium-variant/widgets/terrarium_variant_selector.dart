import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/terrarium_variant_bloc.dart';
import '../bloc/terrarium_variant_event.dart';
import '../bloc/terrarium_variant_state.dart';
import 'package:intl/intl.dart';

class TerrariumVariantSelector extends StatelessWidget {
  const TerrariumVariantSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TerrariumVariantBloc, TerrariumVariantState>(
      builder: (context, state) {
        if (state is TerrariumVariantLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24), // Tăng từ 16
              const Text(
                'Phân loại',
                style: TextStyle(
                  fontSize: 22, // Tăng từ 18
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5016),
                ),
              ),
              const SizedBox(height: 16), // Tăng từ 12

              // Variant Selection
              SizedBox(
                height: 120, // Tăng từ 80
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.variants.length,
                  itemBuilder: (context, index) {
                    final variant = state.variants[index];
                    final isSelected = index == state.selectedVariantIndex;

                    return Padding(
                      padding: const EdgeInsets.only(right: 16), // Tăng từ 12
                      child: GestureDetector(
                        onTap: () {
                          context.read<TerrariumVariantBloc>().add(
                                SelectVariant(variant['terrariumVariantId']),
                              );
                        },
                        child: Container(
                          width: 120, // Tăng từ 80
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2D5016)
                                  : Colors.grey.shade300,
                              width: isSelected ? 3 : 2, // Tăng từ 2:1
                            ),
                            borderRadius:
                                BorderRadius.circular(12), // Tăng từ 8
                            color: isSelected
                                ? const Color(0xFF2D5016).withOpacity(0.1)
                                : Colors.white,
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12), // Tăng từ 8
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: variant['urlImage'] ?? '',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                        size: 32, // Tăng từ 24
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                        size: 32, // Tăng từ 24
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6), // Tăng từ 4
                                child: Text(
                                  variant['variantName'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12, // Tăng từ 10
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? const Color(0xFF2D5016)
                                        : Colors.black87,
                                  ),
                                  maxLines: 2, // Tăng từ 1
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24), // Tăng từ 16

              // Selected Variant Details
              _buildSelectedVariantDetails(state),
            ],
          );
        } else if (state is TerrariumVariantLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32), // Tăng từ 20
              child: CircularProgressIndicator(
                color: Color(0xFF2D5016),
                strokeWidth: 4, // Thêm để tăng độ dày
              ),
            ),
          );
        } else if (state is TerrariumVariantError) {
          return Padding(
            padding: const EdgeInsets.all(20), // Tăng từ 16
            child: Text(
              'Error loading variants: ${state.message}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16, // Thêm size
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildSelectedVariantDetails(TerrariumVariantLoaded state) {
    final selectedVariant = state.selectedVariant;
    final accessories =
        selectedVariant['terrariumVariantAccessories'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(20), // Tăng từ 16
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Tăng từ 12
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Tăng opacity
            blurRadius: 15, // Tăng từ 10
            offset: const Offset(0, 4), // Tăng từ 2
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedVariant['variantName'] ?? 'Variant',
                  style: const TextStyle(
                    fontSize: 20, // Tăng từ 16
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5016),
                  ),
                ),
              ),
              Text(
                _formatCurrency(selectedVariant['price']?.toDouble() ?? 0.0),
                style: const TextStyle(
                  fontSize: 22, // Tăng từ 18
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE67E22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Tăng từ 8
          Row(
            children: [
              const Icon(
                Icons.inventory,
                size: 20, // Tăng từ 16
                color: Colors.grey,
              ),
              const SizedBox(width: 6), // Tăng từ 4
              Text(
                'Stock: ${selectedVariant['stockQuantity'] ?? 0}',
                style: TextStyle(
                  fontSize: 16, // Tăng từ 14
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Tăng từ 16
          const Text(
            'Phụ kiện bao gồm:',
            style: TextStyle(
              fontSize: 18, // Tăng từ 14
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5016),
            ),
          ),
          const SizedBox(height: 12), // Tăng từ 8
          ...accessories.map((accessory) =>
              _buildAccessoryItem(accessory, state.accessoryDetails)),
        ],
      ),
    );
  }

  Widget _buildAccessoryItem(Map<String, dynamic> accessory,
      Map<int, Map<String, dynamic>> accessoryDetails) {
    final accessoryId = accessory['accessoryId'] as int?;
    final accessoryDetail =
        accessoryId != null ? accessoryDetails[accessoryId] : null;

    // Extract image URL from accessoryDetail
    String? imageUrl;
    if (accessoryDetail != null) {
      final accessoryImages =
          accessoryDetail['accessoryImages'] as List<dynamic>?;
      if (accessoryImages != null && accessoryImages.isNotEmpty) {
        final firstImage = accessoryImages[0] as Map<String, dynamic>?;
        imageUrl = firstImage?['imageUrl'] as String?;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Tăng từ 12
      padding: const EdgeInsets.all(16), // Tăng từ 12
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16), // Tăng từ 12
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5, // Tăng từ 1
        ),
      ),
      child: Row(
        children: [
          // Accessory Image
          Container(
            width: 70, // Tăng từ 50
            height: 70, // Tăng từ 50
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14), // Tăng từ 10
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12), // Tăng opacity
                  blurRadius: 6, // Tăng từ 4
                  offset: const Offset(0, 3), // Tăng từ 2
                ),
              ],
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14), // Tăng từ 10
                    child: CachedNetworkImage(
                      imageUrl: imageUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.image,
                            color: Colors.grey, size: 28), // Tăng từ 20
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.broken_image,
                            color: Colors.grey, size: 28), // Tăng từ 20
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.category,
                        color: Colors.grey, size: 28), // Tăng từ 20
                  ),
          ),

          const SizedBox(width: 16), // Tăng từ 12

          // Accessory Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Use name from accessoryDetail if available, fallback to accessory data
                  accessoryDetail?['name'] ??
                      accessory['accessoryName'] ??
                      'Unknown Accessory',
                  style: const TextStyle(
                    fontSize: 16, // Tăng từ 14
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4), // Tăng từ 2
                if ((accessoryDetail?['description'] ??
                            accessory['accessoryDescription']) !=
                        null &&
                    (accessoryDetail?['description'] ??
                            accessory['accessoryDescription'])
                        .toString()
                        .isNotEmpty)
                  Text(
                    accessoryDetail?['description'] ??
                        accessory['accessoryDescription'],
                    style: TextStyle(
                      fontSize: 14, // Tăng từ 12
                      color: Colors.grey.shade600,
                      height: 1.4, // Tăng từ 1.3
                    ),
                    maxLines: 3, // Tăng từ 2
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8), // Tăng từ 4
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4), // Tăng từ 6:2
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D5016).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6), // Tăng từ 4
                      ),
                      child: Text(
                        'Số lượng: ${accessory['quantity'] ?? 1}',
                        style: const TextStyle(
                          fontSize: 13, // Tăng từ 11
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D5016),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatCurrency((accessoryDetail?['price'] ??
                                  accessory['accessoryPrice'])
                              ?.toDouble() ??
                          0.0),
                      style: const TextStyle(
                        fontSize: 16, // Tăng từ 14
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE67E22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount.toInt())} VNĐ';
  }
}
