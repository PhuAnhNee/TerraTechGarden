import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/accessory_bloc.dart';
import '../bloc/accessory_event.dart';
import '../bloc/accessory_state.dart';
import '../../../components/accessory_cart.dart';
import 'dart:developer' as developer;

class AccessoryScreen extends StatefulWidget {
  const AccessoryScreen({super.key});

  @override
  State<AccessoryScreen> createState() => _AccessoryScreenState();
}

class _AccessoryScreenState extends State<AccessoryScreen>
    with AutomaticKeepAliveClientMixin {
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccessoryBloc>().add(FetchAccessories(page: currentPage));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<AccessoryBloc>().add(const RefreshAccessories());
    setState(() {
      currentPage = 1;
    });
  }

  void _changePage(int newPage) {
    if (newPage != currentPage && newPage > 0) {
      setState(() {
        currentPage = newPage;
      });
      context.read<AccessoryBloc>().add(FetchAccessories(page: newPage));
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildLoadingShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6, // Số lượng shimmer items
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 32,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaginationButton(int page, {bool isActive = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        elevation: isActive ? 4 : 1,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isActive ? null : () => _changePage(page),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isActive ? const Color(0xFF1D7020) : Colors.white,
              border: Border.all(
                color:
                    isActive ? const Color(0xFF1D7020) : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Text(
              '$page',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade700,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages, bool isLoading) {
    if (totalPages <= 1) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          if (isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D7020)),
            ),
          const SizedBox(height: 8),
          _buildPaginationRow(totalPages),
          const SizedBox(height: 8),
          Text(
            'Trang $currentPage / $totalPages',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationRow(int totalPages) {
    List<Widget> paginationItems = [];

    // Previous button
    paginationItems.add(_buildNavButton(
      icon: Icons.chevron_left,
      onTap: currentPage > 1 ? () => _changePage(currentPage - 1) : null,
      enabled: currentPage > 1,
    ));

    // Page numbers logic
    int startPage = 1;
    int endPage = totalPages;

    if (totalPages > 5) {
      if (currentPage <= 3) {
        endPage = 5;
      } else if (currentPage >= totalPages - 2) {
        startPage = totalPages - 4;
      } else {
        startPage = currentPage - 2;
        endPage = currentPage + 2;
      }
    }

    if (startPage > 1) {
      paginationItems.add(_buildPaginationButton(1));
      if (startPage > 2) {
        paginationItems.add(_buildEllipsis());
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      paginationItems
          .add(_buildPaginationButton(i, isActive: i == currentPage));
    }

    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        paginationItems.add(_buildEllipsis());
      }
      paginationItems.add(_buildPaginationButton(totalPages));
    }

    // Next button
    paginationItems.add(_buildNavButton(
      icon: Icons.chevron_right,
      onTap:
          currentPage < totalPages ? () => _changePage(currentPage + 1) : null,
      enabled: currentPage < totalPages,
    ));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: paginationItems,
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool enabled,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(
              icon,
              color: enabled ? const Color(0xFF1D7020) : Colors.grey,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('...', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildAccessoryCard(Map<String, dynamic> accessory) {
    final images =
        accessory['accessoryImages'] as List<Map<String, dynamic>>? ?? [];
    final imageUrl = images.isNotEmpty
        ? images.first['imageUrl'] ??
            'https://via.placeholder.com/300x300?text=No+Image'
        : 'https://via.placeholder.com/300x300?text=No+Image';

    final name = accessory['accessoryName'] ?? 'Chưa có tên';
    final price = accessory['price'] ?? 'Liên hệ';
    final stock = accessory['stock'] ?? 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to detail page
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Hero(
                tag: 'accessory_${accessory['id']}',
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF1D7020),
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      developer.log('Image load error for $name: $error');
                      return Container(
                        color: Colors.grey[100],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported,
                                color: Colors.grey, size: 40),
                            SizedBox(height: 4),
                            Text('Không có ảnh',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            color: Color(0xFF1D7020),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (stock > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Text(
                              'Còn $stock',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              'Hết hàng',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: stock > 0
                              ? const Color(0xFF1D7020)
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: stock > 0 ? 2 : 0,
                        ),
                        onPressed: stock > 0
                            ? () {
                                context
                                    .read<AccessoryBloc>()
                                    .add(AddToCart(accessory));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã thêm $name vào giỏ hàng'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: const Color(0xFF1D7020),
                                  ),
                                );
                              }
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              stock > 0
                                  ? Icons.shopping_cart_outlined
                                  : Icons.block,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              stock > 0 ? 'Thêm vào giỏ' : 'Hết hàng',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D7020),
        foregroundColor: Colors.white,
        title: const Text('Phụ Kiện',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccessoryCart(cartItems: []),
                  ),
                );
              },
              icon:
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              label:
                  const Text('Giỏ hàng', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AccessoryBloc, AccessoryState>(
        listener: (context, state) {
          if (state is AccessoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Thử lại',
                  textColor: Colors.white,
                  onPressed: () {
                    context
                        .read<AccessoryBloc>()
                        .add(FetchAccessories(page: currentPage));
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AccessoryLoading) {
            return _buildLoadingShimmer();
          }

          if (state is AccessoryPageLoading) {
            // Hiện previous data với loading indicator
            final previousData = state.previousState;
            return Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: previousData.accessories.length,
                    itemBuilder: (context, index) {
                      return Opacity(
                        opacity: 0.6,
                        child: _buildAccessoryCard(
                            previousData.accessories[index]),
                      );
                    },
                  ),
                ),
                _buildPaginationControls(previousData.totalPages, true),
              ],
            );
          }

          if (state is AccessoryLoaded) {
            final accessories = state.accessories;

            if (accessories.isEmpty) {
              return RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _onRefresh,
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 80, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Không có phụ kiện nào',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kéo xuống để làm mới',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: accessories.length,
                      itemBuilder: (context, index) {
                        return _buildAccessoryCard(accessories[index]);
                      },
                    ),
                  ),
                  _buildPaginationControls(state.totalPages, false),
                ],
              ),
            );
          }

          if (state is AccessoryError) {
            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 80, color: Colors.red.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Có lỗi xảy ra',
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              context
                                  .read<AccessoryBloc>()
                                  .add(FetchAccessories(page: currentPage));
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D7020),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Trạng thái không xác định'),
          );
        },
      ),
    );
  }
}
