import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/strings.dart';
import '../../../navigation/routes.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Cây Thủy Canh', 'icon': Icons.add},
    {'name': 'Terrarium', 'icon': Icons.add},
    {'name': 'Sứu Thị Thủy Tinh', 'icon': Icons.add},
    {'name': 'Vườn Nha Aquagarden', 'icon': Icons.add},
    {'name': 'Cây Không Khí - Air Plants', 'icon': Icons.add},
    {'name': 'Cây Cảnh Văn Phòng', 'icon': Icons.add},
    {'name': 'Decor Ban Công - Nhà Ở', 'icon': Icons.add},
    {'name': 'Nghệ Thuật Tranh Cây', 'icon': Icons.add},
  ];

  final List<Map<String, dynamic>> products = [
    {
      'name': 'Terrarium 01 - Enjoy The...',
      'price': '500.000đ',
      'discount': null,
      'image':
          'https://i.pinimg.com/736x/01/91/a3/0191a3a58258c086c39a948871890b17.jpg', // Replace with actual image URL or asset
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'lib/assets/icon/icon.png', // Replace with your logo asset
            height: 40.0,
          ),
          backgroundColor: Color(0xFF4CAF50),
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    color: Color(0xFF4CAF50),
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Bạn có tìm gì?',
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  // Categories
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DANH MỤC SẢN PHẨM',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(categories[index]['name']),
                              trailing: Icon(categories[index]['icon']),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Products Grid
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      products[index]['name'],
                                      style: TextStyle(fontSize: 14.0),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      products[index]['price'],
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    if (products[index]['discount'] != null)
                                      Text(
                                        products[index]['discount'],
                                        style: TextStyle(
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
                  // Logout Button
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        print('Logout button pressed'); // Debug
                        Navigator.pushReplacementNamed(context, Routes.login);
                        print('Navigated to login screen'); // Debug
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(Strings.logout,
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
