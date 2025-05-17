import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'cart_page.dart';
import 'product_model.dart';
import 'product_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Danh sách sản phẩm mẫu với hình ảnh thật
  final List<Product> products = const [
    Product(
      name: 'Mini Forest Terrarium',
      price: 29.99,
      description: 'A small terrarium with lush greenery.',
      imageUrl:
          'https://i.pinimg.com/736x/bf/3f/bf/bf3fbf03bbab3488c1558bb83165f1a5.jpg',
    ),
    Product(
      name: 'Desert Oasis Terrarium',
      price: 39.99,
      description: 'A desert-themed terrarium with cacti.',
      imageUrl:
          'https://i.pinimg.com/736x/35/34/d5/3534d5689d929f162f37bde27e0f09d2.jpg',
    ),
    Product(
      name: 'Tropical Paradise Terrarium',
      price: 49.99,
      description: 'A vibrant tropical terrarium.',
      imageUrl:
          'https://i.pinimg.com/736x/1b/c0/8d/1bc08d6c1304def838178b71e7b9e483.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TerraTech Garden'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cart.items.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cart.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            child: ListTile(
              leading: Image.network(
                product.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 50);
                },
              ),
              title: Text(product.name),
              subtitle: Text('${product.description}\n\$${product.price}'),
              isThreeLine: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(product: product),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
