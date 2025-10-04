import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/accessory_bloc.dart';
import '../bloc/accessory_event.dart';
import '../bloc/accessory_state.dart';
import 'dart:developer' as developer;

class AccessoryScreen extends StatefulWidget {
  const AccessoryScreen({super.key});

  @override
  State<AccessoryScreen> createState() => _AccessoryScreenState();
}

class _AccessoryScreenState extends State<AccessoryScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccessoryBloc>().add(const FetchAccessories(page: 1));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<AccessoryBloc>().add(const RefreshAccessories());
  }

  Widget _buildLoadingShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8, // Tăng tỷ lệ vì bỏ nút thêm vào giỏ
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10)),
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        width: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(4),
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

  Widget _buildAccessoryCard(Map<String, dynamic> accessory) {
    final images =
        accessory['accessoryImages'] as List<Map<String, dynamic>>? ?? [];
    final imageUrl = images.isNotEmpty
        ? images.first['imageUrl'] ??
            'https://via.placeholder.com/300x300?text=No+Image'
        : 'https://via.placeholder.com/300x300?text=No+Image';

    final name = accessory['accessoryName'] ?? 'Chưa có tên';
    final price = accessory['price']?.toString() ?? 'Liên hệ';
    final stock = accessory['stock'] ?? 0;
    final size = accessory['size']?.toString() ?? '';
    final quantitative = accessory['quantitative']?.toString() ?? '';
    final purchaseCount = accessory['purchaseCount'] ?? 0;
    final averageRating = accessory['averageRating'] ?? 0;

    // Hiển thị size hoặc quantitative nếu có
    String additionalInfo = '';
    if (size.isNotEmpty) {
      additionalInfo = size;
    } else if (quantitative.isNotEmpty) {
      additionalInfo = quantitative;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // TODO: Navigate to detail page
          developer.log('Tapped on: $name (ID: ${accessory['id']})');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Hero(
                    tag: 'accessory_${accessory['id']}',
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(10)),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
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
                  // Badge hiển thị số lượt mua nếu có
                  if (purchaseCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Đã bán $purchaseCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (additionalInfo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        additionalInfo,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(
                        color: Color(0xFF1D7020),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: stock > 0
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: stock > 0
                                ? Colors.green.shade200
                                : Colors.red.shade200),
                      ),
                      child: Text(
                        stock > 0 ? 'Còn $stock' : 'Hết hàng',
                        style: TextStyle(
                          color: stock > 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Hiển thị rating nếu có
                    if (averageRating > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
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
        // Đã bỏ phần actions chứa giỏ hàng
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
                        .add(const FetchAccessories(page: 1));
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
            return GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Đồng bộ tỷ lệ
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: state.previousState.accessories.length,
              itemBuilder: (context, index) {
                return Opacity(
                  opacity: 0.6,
                  child: _buildAccessoryCard(
                      state.previousState.accessories[index]),
                );
              },
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
                            const SizedBox(height: 12),
                            Text(
                              'Không có phụ kiện',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Kéo để làm mới',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
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
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8, // Tăng tỷ lệ để card nhỏ gọn hơn
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: accessories.length,
                itemBuilder: (context, index) {
                  return _buildAccessoryCard(accessories[index]);
                },
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
                          const SizedBox(height: 12),
                          Text(
                            'Lỗi',
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              context
                                  .read<AccessoryBloc>()
                                  .add(const FetchAccessories(page: 1));
                            },
                            icon: const Icon(Icons.refresh, size: 20),
                            label: const Text('Thử lại'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D7020),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
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

          return const Center(child: Text('Trạng thái không xác định'));
        },
      ),
    );
  }
}
