import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/order_item_card.dart';
import '../widgets/transport_order_card.dart';
import '../widgets/order_detail_dialog.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi'),
        backgroundColor: const Color(0xFF1D7020),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải danh sách đơn hàng',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<OrderBloc>().add(LoadOrders()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          } else if (state is OrderLoadedWithTransport) {
            final hasAnyOrders = state.allOrders.isNotEmpty;

            if (!hasAnyOrders) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có đơn hàng nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy mua sắm để có đơn hàng đầu tiên!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrderBloc>().add(LoadOrders());
              },
              child: CustomScrollView(
                slivers: [
                  // Active Transport Orders Section
                  if (state.activeTransportOrders.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue[50]!,
                              Colors.blue[100]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Đơn hàng đang giao',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[700],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${state.activeTransportOrders.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final order = state.activeTransportOrders[index];
                          final transport =
                              state.getTransportForOrder(order.orderId);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TransportOrderCard(
                              order: order,
                              transport: transport,
                              onTap: () =>
                                  _showOrderDetail(context, order.orderId),
                            ),
                          );
                        },
                        childCount: state.activeTransportOrders.length,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ],

                  // Other Orders Section
                  if (state.completedTransportOrders.isNotEmpty ||
                      state.regularOrders.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history,
                              color: Colors.grey[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Lịch sử đơn hàng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 12),
                    ),
                  ],

                  // Completed Transport Orders
                  if (state.completedTransportOrders.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final order = state.completedTransportOrders[index];
                          final transport =
                              state.getTransportForOrder(order.orderId);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TransportOrderCard(
                              order: order,
                              transport: transport,
                              onTap: () =>
                                  _showOrderDetail(context, order.orderId),
                            ),
                          );
                        },
                        childCount: state.completedTransportOrders.length,
                      ),
                    ),

                  // Regular Orders (without transport)
                  if (state.regularOrders.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final order = state.regularOrders[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: OrderItemCard(
                              order: order,
                              onTap: () =>
                                  _showOrderDetail(context, order.orderId),
                            ),
                          );
                        },
                        childCount: state.regularOrders.length,
                      ),
                    ),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              ),
            );
          } else if (state is OrderLoaded) {
            // Fallback for old state
            if (state.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có đơn hàng nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrderBloc>().add(LoadOrders());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return OrderItemCard(
                    order: order,
                    onTap: () => _showOrderDetail(context, order.orderId),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showOrderDetail(BuildContext context, int orderId) {
    context.read<OrderBloc>().add(LoadOrderDetail(orderId));

    showDialog(
      context: context,
      builder: (context) => BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderDetailLoading) {
            return const Dialog(
              child: SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          } else if (state is OrderDetailLoaded) {
            return OrderDetailDialog(orderDetail: state.orderDetail);
          } else if (state is OrderError) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi tải chi tiết đơn hàng',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(state.message),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Dialog(
            child: SizedBox(
              height: 200,
              child: Center(child: Text('Đang tải...')),
            ),
          );
        },
      ),
    );
  }
}
