import 'package:flutter/material.dart';
import '../../blog/screens/blog_screen.dart';
import '../../../navigation/routes.dart';

class TerrariumScreen extends StatefulWidget {
  const TerrariumScreen({super.key});

  @override
  State<TerrariumScreen> createState() => _TerrariumScreenState();
}

class _TerrariumScreenState extends State<TerrariumScreen> {
  // Sample terrarium data (same as home_screen.dart for consistency)
  final List<Map<String, dynamic>> _allTerrariums = [
    {
      'name': 'Terrarium 01 - Enjoy The...',
      'price': 500000.0,
      'image':
          'https://i.pinimg.com/736x/01/91/a3/0191a3a58258c086c39a948871890b17.jpg',
      'isNew': true,
      'description': 'A beautiful mini terrarium with vibrant plants.',
    },
    {
      'name': 'Terrarium 02 - Phía Trước...',
      'price': 350000.0,
      'image':
          'https://i.pinimg.com/736x/01/91/a3/0191a3a58258c086c39a948871890b17.jpg',
      'isNew': false,
      'description': 'A compact terrarium perfect for small spaces.',
    },
    {
      'name': 'Terrarium 03 - Bức Tranh...',
      'price': 999000.0,
      'image':
          'https://i.pinimg.com/736x/01/91/a3/0191a3a58258c086c39a948871890b17.jpg',
      'isNew': true,
      'description': 'An artistic terrarium with unique design elements.',
    },
  ];

  List<Map<String, dynamic>> _filteredTerrariums = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _filteredTerrariums =
        List.from(_allTerrariums); // Initialize with all terrariums
  }

  // Filter terrariums based on selected filter
  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredTerrariums = List.from(_allTerrariums);
      } else if (filter == 'New') {
        _filteredTerrariums =
            _allTerrariums.where((t) => t['isNew'] == true).toList();
      } else if (filter == 'Price: Low to High') {
        _filteredTerrariums = List.from(_allTerrariums)
          ..sort((a, b) => a['price'].compareTo(b['price']));
      } else if (filter == 'Price: High to Low') {
        _filteredTerrariums = List.from(_allTerrariums)
          ..sort((a, b) => b['price'].compareTo(a['price']));
      }
    });
  }

  // Show modal bottom sheet with terrarium details
  void _showTerrariumDetails(
      BuildContext context, Map<String, dynamic> terrarium) {
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
                    terrarium['image'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  terrarium['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D7020),
                  ),
                ),
                const SizedBox(height: 8),
                // Price
                Text(
                  '${terrarium['price'].toStringAsFixed(0)} đ',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D7020),
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  terrarium['description'],
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D7020),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Terrarium Mini Garden',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          // Terrarium Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: _filteredTerrariums.length,
                itemBuilder: (context, index) {
                  return _buildTerrariumCard(
                      context, _filteredTerrariums[index]);
                },
              ),
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

  Widget _buildTerrariumCard(
      BuildContext context, Map<String, dynamic> terrarium) {
    return GestureDetector(
      onTap: () => _showTerrariumDetails(context, terrarium),
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
                      terrarium['image'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (terrarium['isNew'] == true)
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
                          'Bán chạy',
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
                    terrarium['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${terrarium['price'].toStringAsFixed(0)} đ',
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
