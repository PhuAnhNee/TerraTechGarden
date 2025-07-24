import 'package:flutter/material.dart';
import '../../../navigation/routes.dart';

class AccessoryScreen extends StatefulWidget {
  const AccessoryScreen({super.key});

  @override
  State<AccessoryScreen> createState() => _AccessoryScreenState();
}

class _AccessoryScreenState extends State<AccessoryScreen> {
  final int itemsPerPage = 6;
  int currentPage = 1;
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _allAccessories = List.generate(20, (index) {
    return {
      'name': 'Phụ kiện ${index + 1}',
      'price': (index + 1) * 10000.0,
      'image':
          'https://bizweb.dktcdn.net/thumb/grande/100/351/129/products/snag-498c5f7.png',
      'description':
          'Mô tả chi tiết cho phụ kiện ${index + 1}. Đây là sản phẩm chất lượng cao cho terrarium.',
      'isNew': index % 2 == 0, // Example: every other item is "new"
    };
  });

  List<Map<String, dynamic>> _filteredAccessories = [];

  @override
  void initState() {
    super.initState();
    _filteredAccessories =
        List.from(_allAccessories); // Initialize with all accessories
  }

  // Apply filter to accessories
  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredAccessories = List.from(_allAccessories);
      } else if (filter == 'New') {
        _filteredAccessories =
            _allAccessories.where((a) => a['isNew'] == true).toList();
      } else if (filter == 'Price: Low to High') {
        _filteredAccessories = List.from(_allAccessories)
          ..sort((a, b) => a['price'].compareTo(b['price']));
      } else if (filter == 'Price: High to Low') {
        _filteredAccessories = List.from(_allAccessories)
          ..sort((a, b) => b['price'].compareTo(a['price']));
      }
    });
  }

  // Show modal bottom sheet with accessory details
  void _showAccessoryDetails(
      BuildContext context, Map<String, dynamic> accessory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    accessory['image'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  accessory['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D7020),
                  ),
                ),
                const SizedBox(height: 8),
                // Price
                Text(
                  '${accessory['price'].toStringAsFixed(0)} đ',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D7020),
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  accessory['description'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Learn More Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.blog);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D7020),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Tìm hiểu thêm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int start = (currentPage - 1) * itemsPerPage;
    int end = (start + itemsPerPage).clamp(0, _filteredAccessories.length);
    List<Map<String, dynamic>> currentItems =
        _filteredAccessories.sublist(start, end);
    int totalPages = (_filteredAccessories.length / itemsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D7020),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Phụ kiện chăm sóc',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('New'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Price: Low to High'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Price: High to Low'),
                ],
              ),
            ),
          ),
          // Accessory Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: currentItems.length,
                itemBuilder: (context, index) {
                  return _buildAccessoryCard(context, currentItems[index]);
                },
              ),
            ),
          ),
          // Pagination
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalPages, (index) {
                int pageNum = index + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentPage = pageNum;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentPage == pageNum
                          ? const Color(0xFF1D7020)
                          : Colors.white,
                      foregroundColor: currentPage == pageNum
                          ? Colors.white
                          : const Color(0xFF1D7020),
                      side: const BorderSide(color: Color(0xFF1D7020)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(40, 40),
                    ),
                    child: Text('$pageNum'),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color:
              _selectedFilter == label ? Colors.white : const Color(0xFF1D7020),
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: _selectedFilter == label,
      selectedColor: const Color(0xFF1D7020),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFF1D7020)),
      onSelected: (selected) {
        if (selected) {
          _applyFilter(label);
        }
      },
    );
  }

  Widget _buildAccessoryCard(
      BuildContext context, Map<String, dynamic> accessory) {
    return GestureDetector(
      onTap: () => _showAccessoryDetails(context, accessory),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      accessory['image'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (accessory['isNew'] == true)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8D426),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Mới',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accessory['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${accessory['price'].toStringAsFixed(0)} đ',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D7020),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
