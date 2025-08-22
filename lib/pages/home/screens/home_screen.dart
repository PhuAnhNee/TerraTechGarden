import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/navbar.dart';
import '../../../widgets/footer.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../../../navigation/routes.dart';
import '../../terrarium/bloc/terrarium_bloc.dart';
import '../../terrarium/bloc/terrarium_event.dart';
import '../../terrarium/bloc/terrarium_state.dart';

class TerrariumCard extends StatelessWidget {
  final Map<String, dynamic> terrarium;
  final VoidCallback onTap;

  const TerrariumCard({
    super.key,
    required this.terrarium,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = terrarium['terrariumImages']?.isNotEmpty == true
        ? terrarium['terrariumImages'][0]['imageUrl']
        : 'https://res.cloudinary.com/dia8sg8u7/image/upload/v1753397462/terrariums/22/22.webp';

    final name = terrarium['terrariumName'] ?? 'No name';
    final minPrice = terrarium['minPrice'] ?? 0;
    final maxPrice = terrarium['maxPrice'] ?? 0;

    return GestureDetector(
      onTap: onTap,
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
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text(
                              'Image failed to load',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if ((terrarium['stock'] ?? 0) > 1000)
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
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$minPrice – $maxPrice đ',
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

Widget _buildProductCard(Map<String, dynamic> terrarium) {
  return TerrariumCard(
    terrarium: terrarium,
    onTap: () {
      // Navigate to detail if needed
    },
  );
}

Widget buildTerrariumGrid(BuildContext context) {
  return BlocBuilder<TerrariumBloc, TerrariumState>(
    builder: (context, state) {
      if (state is TerrariumLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is TerrariumLoaded) {
        final items = state.terrariums.take(6).toList(); // Limit to 6 items
        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildProductCard(items[index]);
              },
            ),
            if (state.terrariums.length >
                6) // Show "View More" only if more items exist
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.terrarium);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D7020),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Xem thêm',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  )),
          ],
        );
      } else if (state is TerrariumError) {
        return Center(child: Text(state.message));
      } else {
        return const SizedBox.shrink();
      }
    },
  );
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeBloc()..add(LoadHomeEvent()),
        ),
        BlocProvider(
          create: (context) => TerrariumBloc()..add(FetchTerrariums(page: 1)),
        ),
      ],
      child: Scaffold(
        drawer: const NavDrawer(),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1D7020),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'TerraTechGarden', // Replaced Image.asset with Text
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () => Navigator.pushReplacementNamed(context, '/cart'),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(context),
                _buildCategorySection(context),
                _buildProductSection(context),
                _buildInstagramSection(),
                _buildInfoSection(),
                const AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              children: [
                TextSpan(
                  text: 'Đem cây ',
                  style: TextStyle(color: Color(0xFF1D7020)),
                ),
                TextSpan(
                  text: 'tươi ',
                  style: TextStyle(color: Color(0xFFE8D426)),
                ),
                TextSpan(
                  text: 'về\nđể ',
                  style: TextStyle(color: Color(0xFF1D7020)),
                ),
                TextSpan(
                  text: 'vui',
                  style: TextStyle(color: Color(0xFFE8D426)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              'https://i.pinimg.com/1200x/7f/ba/98/7fba98487f5c5e004c775a3badbd3b3e.jpg',
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, Routes.terrarium); // Navigate to TerrariumScreen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1D7020),
                side: const BorderSide(color: Color(0xFF1D7020)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Các cây của TerraTech',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          _buildCategoryItem(
            context,
            'https://i.pinimg.com/1200x/e7/8b/6a/e78b6aa48b4492fc4e02e2d517231497.jpg',
            'Blog tham khảo',
            400,
            () {
              Navigator.pushNamed(context, Routes.blog); // Use Routes.blog
            },
          ),
          const SizedBox(height: 30),
          _buildCategoryItem(
            context,
            'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
            'Phụ kiện chăm sóc',
            300,
            () {
              Navigator.pushNamed(
                  context, Routes.accessory); // Use Routes.accessory
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String imageUrl, String title,
      double height, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 30,
            left: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D7020),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Các sản phẩm mới',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D7020),
            ),
          ),
          const SizedBox(height: 20),
          buildTerrariumGrid(context),
        ],
      ),
    );
  }

  Widget _buildInstagramSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            'Theo dõi TerraTech\ntrên Instagram',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D7020),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {},
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'TerraTech',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          Center(
            child: Column(
              children: [
                const Text(
                  'Tại sao chọn TerraTech?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D7020),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Color(0xFF1D7020),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Info cards
          Column(
            children: [
              _buildInfoCard(
                Icons.eco_outlined,
                'Hướng dẫn chăm sóc',
                'Mỗi sản phẩm cây của TerraTech đều đi kèm với thẻ hướng dẫn chăm sóc chi tiết.',
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                Icons.shopping_bag_outlined,
                'Mua hàng tiện lợi',
                'Trải nghiệm mua hàng nhanh chóng, thuận tiện với giao diện thân thiện.',
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                Icons.support_agent_outlined,
                'Luôn luôn đồng hành',
                'Đội ngũ tư vấn viên luôn sẵn sàng giải đáp thắc mắc về chăm sóc cây.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF1D7020).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Color(0xFF1D7020),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
