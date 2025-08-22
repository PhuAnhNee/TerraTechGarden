import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../../../components/cart.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(FetchCart());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D7020),
        title: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            final itemCount = state is CartLoaded
                ? (state.cartData['totalCartQuantity'] ?? 0)
                : 0;
            return Text(
              'Shopping Cart ($itemCount)',
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Sử dụng pop thay vì pushReplacementNamed để quay lại trang trước
            Navigator.pop(context);

            // Hoặc nếu bắt buộc phải dùng pushReplacementNamed, thêm arguments:
            // Navigator.pushReplacementNamed(
            //   context,
            //   '/terrarium-detail',
            //   arguments: 'your_terrarium_id_here', // Thêm ID cần thiết
            // );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Tương tự cho nút edit
              Navigator.pop(context);

              // Hoặc với arguments:
              // Navigator.pushReplacementNamed(
              //   context,
              //   '/terrarium-detail',
              //   arguments: 'your_terrarium_id_here',
              // );
            },
          ),
        ],
      ),
      body: const Cart(), // Use the Cart component
    );
  }
}
