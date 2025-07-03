import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/strings.dart';
import '../../../navigation/routes.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../../widgets/navbar.dart';
import '../../../widgets/footer.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Cây Thủy Canh', 'icon': Icons.local_florist},
    {'name': 'Terrarium', 'icon': Icons.terrain},
    {'name': 'Sứu Thị Thủy Tinh', 'icon': Icons.local_drink},
    {'name': 'Vườn Nha Aquagarden', 'icon': Icons.local_florist},
    {'name': 'Cây Không Khí - Air Plants', 'icon': Icons.cloud},
    {'name': 'Cây Cảnh Văn Phòng', 'icon': Icons.desk},
    {'name': 'Decor Ban Công - Nhà Ở', 'icon': Icons.weekend},
    {'name': 'Nghệ Thuật Tranh Cây', 'icon': Icons.brush},
  ];

  final List<Map<String, dynamic>> products = [
    {
      'name': 'Terrarium 01 - Enjoy The...',
      'price': '500.000đ',
      'discount': null,
      'image':
          'https://i.pinimg.com/736x/01/91/a3/0191a3a58258c086c39a948871890b17.jpg',
    },
    {
      'name': 'Terrarium 01 - OM',
      'price': '1.000.000đ',
      'discount': null,
      'image':
          'https://i.pinimg.com/736x/01/91/a3/0191a3a58258c086c39a948871890b17.jpg',
    },
    {
      'name': 'Terrarium 02 - Phía Trước...',
      'price': '350.000đ',
      'discount': '-11%',
      'image':
          'https://i.pinimg.com/736x/01/91/a3/0191a3a58258c086c39a948871890b17.jpg',
    },
    {
      'name': 'Terrarium 03 - Bức Tranh...',
      'price': '999.000đ - 1.200.000đ',
      'discount': '-17%',
      'image':
          'https://i.pinimg.com/736x/01/91/a3/0191a3a58258c086c39a948871890b17.jpg',
    },
  ];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeEvent()),
      child: Scaffold(
        drawer: const NavDrawer(),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: false,
                snap: true,
                backgroundColor: const Color(0xFF1D7020),
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                title: Image.asset(
                  'lib/assets/icon/icon.png',
                  height: 40.0,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    'Terarium Shop',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Column(
                      children: [
                        Container(
                          color: const Color(0xFF1D7020),
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Bạn có tìm gì?',
                              prefixIcon:
                                  const Icon(Icons.search, color: Colors.white),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DANH MỤC SẢN PHẨM',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(categories[index]['name']),
                                    trailing: Icon(categories[index]['icon']),
                                    onTap: () {},
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 4.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        products[index]['image'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image,
                                                    size: 50),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            products[index]['name'],
                                            style:
                                                const TextStyle(fontSize: 14.0),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            products[index]['price'],
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          if (products[index]['discount'] !=
                                              null)
                                            Text(
                                              products[index]['discount'],
                                              style: const TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.orange,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: AppFooter(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
