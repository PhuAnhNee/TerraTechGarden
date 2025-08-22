import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../bloc/terrarium_detail_bloc.dart';
import '../bloc/terrarium_detail_event.dart';
import '../bloc/terrarium_detail_state.dart';
import '../../cart/bloc/cart_bloc.dart';
import '../../cart/bloc/cart_event.dart';
import '../../../navigation/routes.dart';
import '../widgets/terrarium_content.dart';
import '../widgets/terrarium_floating_buttons.dart';
import '../widgets/add_accessory_popup.dart';
import '../widgets/terrarium_app_bar.dart';
import '../widgets/terrarium_loading_state.dart';
import '../widgets/terrarium_error_state.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
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

  void _onShare(Map<String, dynamic>? terrarium) {
    if (terrarium != null) {
      final name = terrarium['terrariumName'] ?? 'Terrarium';
      final price = TerrariumHelper.formatCurrency(
          (terrarium['minPrice'] ?? 0.0).toDouble());
      final shareText = 'Check out this $name for $price!';
      Share.share(shareText);
    }
  }

  void _onImageSelected(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
  }

  void _onFavoriteToggle() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TerrariumDetailBloc()..add(FetchTerrariumDetail(widget.terrariumId)),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: BlocBuilder<TerrariumDetailBloc, TerrariumDetailState>(
          builder: (context, state) {
            if (state is TerrariumDetailLoading) {
              return const TerrariumLoadingState();
            } else if (state is TerrariumDetailLoaded) {
              return _buildLoadedContent(state.terrarium);
            } else if (state is TerrariumDetailError) {
              return TerrariumErrorState(
                message: state.message,
                onRetry: () => context
                    .read<TerrariumDetailBloc>()
                    .add(FetchTerrariumDetail(widget.terrariumId)),
              );
            }
            return const SizedBox();
          },
        ),
        floatingActionButton:
            BlocBuilder<TerrariumDetailBloc, TerrariumDetailState>(
          builder: (context, state) {
            if (state is TerrariumDetailLoaded) {
              return TerrariumFloatingButtons(
                terrarium: state.terrarium,
                onAddToCart: () => _handleAddToCart(state.terrarium),
                onBuyNow: () => _handleBuyNow(state.terrarium),
              );
            }
            return const SizedBox();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildLoadedContent(Map<String, dynamic> terrarium) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          TerrariumAppBar(
            terrarium: terrarium,
            selectedImageIndex: _selectedImageIndex,
            onShare: () => _onShare(terrarium),
          ),
        ];
      },
      body: TerrariumContent(
        terrarium: terrarium,
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
        selectedImageIndex: _selectedImageIndex,
        isFavorite: _isFavorite,
        onImageSelected: _onImageSelected,
        onFavoriteToggle: _onFavoriteToggle,
      ),
    );
  }

  void _handleAddToCart(Map<String, dynamic> terrarium) {
    final accessories = terrarium['accessories'] as List<dynamic>? ?? [];

    if (accessories.isEmpty) {
      _showNoAccessoriesMessage();
      return;
    }

    _showAddAccessoryPopup(terrarium, accessories, isAddToCart: true);
  }

  void _handleBuyNow(Map<String, dynamic> terrarium) {
    final accessories = terrarium['accessories'] as List<dynamic>? ?? [];

    if (accessories.isEmpty) {
      _showNoAccessoriesMessage();
      return;
    }

    _showAddAccessoryPopup(terrarium, accessories, isAddToCart: false);
  }

  void _showNoAccessoriesMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No accessories found in this terrarium'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAddAccessoryPopup(
    Map<String, dynamic> terrarium,
    List<dynamic> accessories, {
    required bool isAddToCart,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AddAccessoryPopup(
          terrarium: terrarium,
          accessories: accessories.cast<Map<String, dynamic>>(),
          onConfirm: (selectedItems) =>
              _confirmAddToCart(terrarium, selectedItems, isAddToCart),
        );
      },
    );
  }

  void _confirmAddToCart(
    Map<String, dynamic> terrarium,
    List<Map<String, dynamic>> cartItems,
    bool isAddToCart,
  ) {
    context.read<CartBloc>().add(AddCartItems(cartItems));

    final itemCount = cartItems.length;
    final terrariumName = terrarium['terrariumName'] ?? 'Terrarium';

    if (isAddToCart) {
      _showSuccessSnackBar(itemCount, terrariumName, showViewCart: true);
    } else {
      _showSuccessSnackBar(itemCount, terrariumName, showViewCart: false);
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.pushNamed(context, Routes.cart);
      });
    }
  }

  void _showSuccessSnackBar(int itemCount, String terrariumName,
      {required bool showViewCart}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('$itemCount accessories from $terrariumName added to cart!'),
        backgroundColor: const Color(0xFF1D7020),
        duration: Duration(seconds: showViewCart ? 3 : 2),
        action: showViewCart
            ? SnackBarAction(
                label: 'View Cart',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, Routes.cart);
                },
              )
            : null,
      ),
    );
  }
}

// Helper class for shared utilities
class TerrariumHelper {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount.toInt())} VNĐ';
  }
}
