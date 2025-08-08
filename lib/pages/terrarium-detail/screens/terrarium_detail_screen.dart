import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../bloc/terrarium_detail_bloc.dart';
import '../bloc/terrarium_detail_event.dart';
import '../bloc/terrarium_detail_state.dart';
import '../../cart/bloc/cart_bloc.dart';
import '../../cart/bloc/cart_event.dart';
import '../../../navigation/routes.dart';

class TerrariumDetailScreen extends StatefulWidget {
  final String terrariumId;
  const TerrariumDetailScreen({super.key, required this.terrariumId});

  @override
  State<TerrariumDetailScreen> createState() => _TerrariumDetailScreenState();
}

class _TerrariumDetailScreenState extends State<TerrariumDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isFavorite = false;
  int _selectedImageIndex = 0;
  int _quantity = 1;

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount.toInt())} VNĐ';
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TerrariumDetailBloc()..add(FetchTerrariumDetail(widget.terrariumId)),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(),
        body: BlocBuilder<TerrariumDetailBloc, TerrariumDetailState>(
          builder: (context, state) {
            if (state is TerrariumDetailLoading) {
              return _buildLoadingState();
            } else if (state is TerrariumDetailLoaded) {
              return _buildLoadedState(state.terrarium);
            } else if (state is TerrariumDetailError) {
              return _buildErrorState(state.message);
            }
            return const SizedBox();
          },
        ),
        floatingActionButton:
            BlocBuilder<TerrariumDetailBloc, TerrariumDetailState>(
          builder: (context, state) {
            if (state is TerrariumDetailLoaded) {
              return _buildFloatingActionButtons(state.terrarium);
            }
            return const SizedBox();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1D7020),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            BlocBuilder<TerrariumDetailBloc, TerrariumDetailState>(
              builder: (context, state) {
                if (state is TerrariumDetailLoaded) {
                  final terrarium = state.terrarium;
                  final name = terrarium['terrariumName'] ?? 'Terrarium';
                  final price = _formatCurrency(
                      (terrarium['minPrice'] ?? 0.0).toDouble());
                  final shareText = 'Check out this $name for $price!';
                  Share.share(shareText);
                }
                return const SizedBox();
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, Routes.cart);
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D7020), Color(0xFF2E8B32)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Loading terrarium details...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context
                    .read<TerrariumDetailBloc>()
                    .add(FetchTerrariumDetail(widget.terrariumId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D7020),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedState(Map<String, dynamic> terrarium) {
    final images = terrarium['terrariumImages'] as List<dynamic>? ?? [];
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(images),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildProductInfo(terrarium),
                  _buildImageThumbnails(images),
                  _buildDescription(terrarium),
                  _buildVariants(terrarium),
                  _buildAccessories(terrarium),
                  _buildDetails(terrarium),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(List<dynamic> images) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: images.isNotEmpty &&
                _selectedImageIndex < images.length &&
                images[_selectedImageIndex]['imageUrl'] != null
            ? CachedNetworkImage(
                imageUrl: images[_selectedImageIndex]['imageUrl'] as String,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
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
              )
            : Container(
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
      ),
    );
  }

  Widget _buildProductInfo(Map<String, dynamic> terrarium) {
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
                onTap: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.grey,
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

  Widget _buildImageThumbnails(List<dynamic> images) {
    if (images.isEmpty) return const SizedBox();

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedImageIndex = index;
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedImageIndex == index
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

  Widget _buildDescription(Map<String, dynamic> terrarium) {
    final description = terrarium['description']?.toString();
    if (description == null || description.isEmpty) return const SizedBox();
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
                Icons.description,
                color: const Color(0xFF1D7020),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Description',
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
            description,
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

  Widget _buildVariants(Map<String, dynamic> terrarium) {
    // No variants in the API response, so this section can be left as is or removed
    final variants = terrarium['terrariumVariants'] as List<dynamic>? ?? [];
    if (variants.isEmpty) return const SizedBox();
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
                Icons.tune,
                color: const Color(0xFF1D7020),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Variants',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...variants.map<Widget>((variant) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
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
                      Icons.category_outlined,
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
                          variant['variantName']?.toString() ?? 'Variant',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (variant['description'] != null &&
                            variant['description'].toString().isNotEmpty)
                          Text(
                            variant['description'].toString(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'Stock: ${variant['stockQuantity']?.toString() ?? '0'}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency((variant['price'] ?? 0.0).toDouble()),
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

  Widget _buildAccessories(Map<String, dynamic> terrarium) {
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

  Widget _buildDetails(Map<String, dynamic> terrarium) {
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

  Widget _buildFloatingActionButtons(Map<String, dynamic> terrarium) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: FloatingActionButton.extended(
              heroTag: "add_to_cart",
              onPressed: () {
                _showQuantityDialog(context, terrarium, isAddToCart: true);
              },
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
              onPressed: () {
                _showQuantityDialog(context, terrarium, isAddToCart: false);
              },
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

  void _showQuantityDialog(BuildContext context, Map<String, dynamic> terrarium,
      {required bool isAddToCart}) {
    final maxQuantity = terrarium['stock'] is int
        ? terrarium['stock'] as int
        : int.tryParse(terrarium['stock']?.toString() ?? '0') ?? 0;
    // Debug log to verify minPrice and maxPrice
    developer.log(
        'minPrice: ${terrarium['minPrice']}, maxPrice: ${terrarium['maxPrice']}',
        name: 'TerrariumDetailScreen');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        int quantity = _quantity.clamp(1, maxQuantity);
        return StatefulBuilder(
          builder: (builderContext, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    isAddToCart ? Icons.shopping_cart_outlined : Icons.flash_on,
                    color:
                        isAddToCart ? const Color(0xFF1D7020) : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(isAddToCart ? 'Add to Cart' : 'Quick Purchase'),
                ],
              ),
              content: SingleChildScrollView(
                // Added to handle overflow
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select quantity for ${terrarium['terrariumName'] ?? 'Terrarium'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatCurrency((terrarium['minPrice'] ?? 0.0).toDouble())} - ${_formatCurrency((terrarium['maxPrice'] ?? 0.0).toDouble())}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D7020),
                      ),
                      softWrap: true, // Ensure text wraps if too long
                      overflow: TextOverflow.visible, // Prevent clipping
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: quantity > 1
                              ? () {
                                  setState(() {
                                    quantity--;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: quantity < maxQuantity
                              ? () {
                                  setState(() {
                                    quantity++;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF1D7020).withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                    if (maxQuantity > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Available stock: $maxQuantity',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade300),
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
                          _formatCurrency(
                              (terrarium['minPrice'] ?? 0.0).toDouble() *
                                  quantity),
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
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    int accessoryId = terrarium['terrariumId'] is int
                        ? terrarium['terrariumId'] as int
                        : int.tryParse(terrarium['terrariumId'].toString()) ??
                            0;

                    if (accessoryId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Invalid terrarium ID'),
                          backgroundColor: Colors.red.shade400,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(dialogContext).pop();
                      return;
                    }

                    developer.log(
                        'Adding terrarium with ID: $accessoryId, quantity: $quantity',
                        name: 'TerrariumDetailScreen');

                    final cartItem = {
                      'accessoryId': accessoryId,
                      'accessoryQuantity': quantity,
                    };

                    if (isAddToCart) {
                      context.read<CartBloc>().add(AddCartItems([cartItem]));
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${terrarium['terrariumName'] ?? 'Terrarium'} added to cart!'),
                          backgroundColor: const Color(0xFF1D7020),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'View Cart',
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.pushNamed(context, Routes.cart);
                            },
                          ),
                        ),
                      );
                    } else {
                      context.read<CartBloc>().add(AddCartItems([cartItem]));
                      Navigator.of(dialogContext).pop();
                      Future.delayed(const Duration(milliseconds: 500), () {
                        Navigator.pushNamed(context, Routes.cart);
                      });
                    }
                    this._quantity = quantity;
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
                  child: Text(isAddToCart ? 'Add to Cart' : 'Buy Now'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
