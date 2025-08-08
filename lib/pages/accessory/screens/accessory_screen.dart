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

class _AccessoryScreenState extends State<AccessoryScreen> {
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AccessoryBloc>().add(FetchAccessories(page: currentPage));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _changePage(int newPage) {
    if (newPage != currentPage) {
      setState(() {
        currentPage = newPage;
      });
      context.read<AccessoryBloc>().add(FetchAccessories(page: newPage));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Widget _buildPaginationButton(int page, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        elevation: isActive ? 4 : 1,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isActive ? null : () => _changePage(page),
          child: Container(
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

  Widget _buildPaginationControls(int totalPages) {
    if (totalPages <= 1) return const SizedBox();

    List<Widget> paginationItems = [];
    paginationItems.add(
      Container(
        margin: const EdgeInsets.only(right: 8),
        child: Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: currentPage > 1 ? () => _changePage(currentPage - 1) : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                Icons.chevron_left,
                color: currentPage > 1 ? const Color(0xFF1D7020) : Colors.grey,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );

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
        paginationItems.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('...', style: TextStyle(color: Colors.grey)),
          ),
        );
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      paginationItems
          .add(_buildPaginationButton(i, isActive: i == currentPage));
    }

    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        paginationItems.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('...', style: TextStyle(color: Colors.grey)),
          ),
        );
      }
      paginationItems.add(_buildPaginationButton(totalPages));
    }

    paginationItems.add(
      Container(
        margin: const EdgeInsets.only(left: 8),
        child: Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: currentPage < totalPages
                ? () => _changePage(currentPage + 1)
                : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                Icons.chevron_right,
                color: currentPage < totalPages
                    ? const Color(0xFF1D7020)
                    : Colors.grey,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: paginationItems,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Trang $currentPage / $totalPages',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessoryCard(Map<String, dynamic> accessory) {
    final imageUrl = accessory['accessoryImages'] != null &&
            (accessory['accessoryImages'] as List).isNotEmpty
        ? (accessory['accessoryImages'] as List).first['imageUrl'] ??
            'https://via.placeholder.com/150'
        : 'https://via.placeholder.com/150';
    final name = accessory['accessoryName'] ?? 'Unnamed Accessory';
    final price = accessory['price'] ?? 'N/A';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  imageUrl,
                  height:
                      constraints.maxHeight * 0.45, // 45% of available height
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    developer.log('Image load error for $name: $error',
                        name: 'AccessoryScreen');
                    return Container(
                      height: constraints.maxHeight * 0.45,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Price: $price',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(), // Pushes button to bottom
                      SizedBox(
                        width: double.infinity,
                        height: 36, // Fixed height for button
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D7020),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            minimumSize: Size.zero,
                          ),
                          onPressed: () {
                            // Placeholder button, no action
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_cart, size: 16),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Thêm vào giỏ',
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D7020),
        foregroundColor: Colors.white,
        title: const Text('Phụ Kiện'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccessoryCart(cartItems: []),
                  ),
                );
              },
              child: Row(
                children: const [
                  Icon(Icons.shopping_cart, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Giỏ hàng', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AccessoryBloc, AccessoryState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is AccessoryLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1D7020)));
          } else if (state is AccessoryLoaded) {
            final accessories = state.accessories;

            if (accessories.isEmpty) {
              return const Center(
                  child: Text('Không có phụ kiện nào',
                      style: TextStyle(color: Color(0xFF1D7020))));
            }

            return Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75, // Adjusted aspect ratio
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: accessories.length,
                    itemBuilder: (context, index) {
                      return _buildAccessoryCard(accessories[index]);
                    },
                  ),
                ),
                _buildPaginationControls(state.totalPages),
              ],
            );
          } else if (state is AccessoryError) {
            return Center(
                child:
                    Text(state.message, style: TextStyle(color: Colors.red)));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
