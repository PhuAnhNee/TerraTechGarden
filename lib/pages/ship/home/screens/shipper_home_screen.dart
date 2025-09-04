// screens/shipper_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/ship_bloc.dart';
import '../bloc/ship_event.dart';
import '../bloc/ship_state.dart';
import '../widgets/transport_cart.dart';
import '../../history/screens/transport_history.dart';

class ShipperHomeScreen extends StatefulWidget {
  final String token;

  const ShipperHomeScreen({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<ShipperHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ShipperHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  // Cache the counts to persist across state changes
  int _ordersCount = 0;
  int _transportsCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    // Load both orders and transports initially to populate stats cards
    context.read<ShipBloc>().add(LoadAvailableOrdersEvent(token: widget.token));
    context.read<ShipBloc>().add(LoadTransportsEvent(token: widget.token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildUserWelcome(),
          _buildStatsCards(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersTab(),
                _buildTransportsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2a2a2a),
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 41, 150, 45),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Terra Shipping',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF2a2a2a),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'history',
              onTap: () {
                // Navigate to transport history
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => ShipBloc(),
                      child: TransportHistoryScreen(token: widget.token),
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Lịch sử vận chuyển',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'profile',
              onTap: () {
                // Navigate to profile
                Navigator.pushReplacementNamed(context, '/profile');
              },
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Hồ sơ', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              onTap: () {
                // Navigate to login
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserWelcome() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting = 'Chào buổi sáng';

    if (hour >= 12 && hour < 18) {
      greeting = 'Chào buổi chiều';
    } else if (hour >= 18) {
      greeting = 'Chào buổi tối';
    }

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 41, 150, 45),
            const Color.fromARGB(255, 35, 125, 38),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 41, 150, 45).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Shipper', // Fixed: removed dependency on userInfo
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  // Fixed: Use default locale instead of 'vi_VN'
                  DateFormat('EEEE, dd/MM/yyyy').format(now),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // Fixed _buildStatsCards method - always shows API data
  Widget _buildStatsCards() {
    return BlocListener<ShipBloc, ShipState>(
      listener: (context, state) {
        // Update cached counts when states change
        if (state is OrdersLoaded) {
          _ordersCount = state.orders.length;
        }
        if (state is TransportsLoaded) {
          _transportsCount = state.transports.length;
        } else if (state is TransportHistoryLoaded) {
          _transportsCount = state.transports.length;
        }
      },
      child: BlocBuilder<ShipBloc, ShipState>(
        builder: (context, state) {
          // Use cached counts or current state counts
          int currentOrdersCount = _ordersCount;
          int currentTransportsCount = _transportsCount;

          // Update from current state if available
          if (state is OrdersLoaded) {
            currentOrdersCount = state.orders.length;
          }
          if (state is TransportsLoaded) {
            currentTransportsCount = state.transports.length;
          } else if (state is TransportHistoryLoaded) {
            currentTransportsCount = state.transports.length;
          }

          return Container(
            height: 120,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Đơn hàng',
                    '$currentOrdersCount',
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Vận đơn',
                    '$currentTransportsCount',
                    Icons.local_shipping,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return BlocBuilder<ShipBloc, ShipState>(
      builder: (context, state) {
        if (state is ShipLoading) {
          return _buildLoadingWidget('Đang tải đơn hàng...');
        }

        if (state is ShipError) {
          return _buildErrorWidget(state.message, () {
            context
                .read<ShipBloc>()
                .add(LoadAvailableOrdersEvent(token: widget.token));
          });
        }

        if (state is OrdersLoaded) {
          if (state.orders.isEmpty) {
            return _buildEmptyWidget(
              Icons.shopping_cart_outlined,
              'Không có đơn hàng',
              'Chưa có đơn hàng nào cần xử lý',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<ShipBloc>()
                  .add(LoadAvailableOrdersEvent(token: widget.token));
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                final address = state.addresses[order.addressId];
                return _buildOrderCard(order, address);
              },
            ),
          );
        }

        return _buildEmptyWidget(
          Icons.refresh,
          'Kéo để tải lại',
          'Vuốt xuống để tải đơn hàng mới',
        );
      },
    );
  }

  Widget _buildTransportsTab() {
    return TransportCart(
      token: widget.token,
    );
  }

  Widget _buildOrderCard(dynamic order, dynamic address) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF2a2a2a),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 41, 150, 45),
            width: 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 41, 150, 45)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_cart,
                      color: const Color.fromARGB(255, 41, 150, 45),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đơn hàng #${order.orderId}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          dateFormatter.format(order.orderDate),
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 41, 150, 45)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.paymentStatus ?? 'Chờ xử lý',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 41, 150, 45),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Customer Information
              if (address != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1a1a),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person,
                              color: const Color.fromARGB(255, 41, 150, 45),
                              size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Thông tin khách hàng',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 41, 150, 45),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      _buildOrderInfoRow(
                          Icons.person_outline, address.receiverName),
                      _buildOrderInfoRow(Icons.phone, address.receiverPhone),
                      _buildOrderInfoRow(
                          Icons.location_on, address.receiverAddress,
                          isAddress: true),
                    ],
                  ),
                ),
                SizedBox(height: 12),
              ],

              // Order Total
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a1a),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng tiền:',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${formatter.format(order.totalAmount)} VNĐ',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 41, 150, 45),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateTransportDialog(order),
                  icon: Icon(Icons.local_shipping),
                  label: Text(
                    'TẠO VẬN ĐƠN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 41, 150, 45),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoRow(IconData icon, String text,
      {bool isAddress = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment:
            isAddress ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 14),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              maxLines: isAddress ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color.fromARGB(255, 41, 150, 45),
            ),
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh),
            label: Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 41, 150, 45),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(IconData icon, String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFF2a2a2a),
        selectedItemColor: const Color.fromARGB(255, 41, 150, 45),
        unselectedItemColor: Colors.grey.shade400,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _tabController.animateTo(index);
          _loadTabData(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Vận đơn',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _refreshCurrentTab,
      backgroundColor: const Color.fromARGB(255, 41, 150, 45),
      child: Icon(Icons.refresh, color: Colors.white),
    );
  }

  // Helper methods
  int _getTotalOrdersCount(ShipState state) {
    if (state is OrdersLoaded && _selectedIndex == 0) {
      return state.orders.length;
    }
    return 0;
  }

  int _getTotalTransportsCount(ShipState state) {
    if (state is TransportsLoaded && _selectedIndex == 1) {
      return state.transports.length;
    }
    return 0;
  }

  int _getCompletedOrdersCount(ShipState state) {
    if (state is TransportsLoaded) {
      return state.transports.where((t) => t.status == 'completed').length;
    }
    return 0;
  }

  void _loadTabData(int index) {
    switch (index) {
      case 0:
        context
            .read<ShipBloc>()
            .add(LoadAvailableOrdersEvent(token: widget.token));
        break;
      case 1:
        context.read<ShipBloc>().add(LoadTransportsEvent(token: widget.token));
        break;
    }
  }

  void _refreshCurrentTab() {
    _loadTabData(_selectedIndex);
  }

  void _showCreateTransportDialog(dynamic order) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Tạo vận đơn',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đơn hàng #${order.orderId}',
              style: TextStyle(
                color: const Color.fromARGB(255, 41, 150, 45),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Ghi chú vận chuyển:',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: noteController,
              maxLines: 3,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nhập ghi chú cho vận đơn...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: const Color.fromARGB(255, 41, 150, 45), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ShipBloc>().add(
                    CreateTransportEvent(
                      token: widget.token,
                      orderId: order.orderId,
                      userId: order.userId, // Fixed: use order.userId
                      orderDate: order.orderDate,
                      note: noteController.text.trim(),
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 41, 150, 45),
            ),
            child: Text(
              'Tạo vận đơn',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder methods for menu actions and notifications
  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thông báo sẽ được triển khai sau'),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }
}
