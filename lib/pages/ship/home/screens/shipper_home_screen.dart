import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../navigation/routes.dart';
import '../../delivery/screens/delivery_screen.dart';
import '../bloc/ship_bloc.dart';
import '../bloc/ship_event.dart';
import '../bloc/ship_state.dart';
import '../../../../components/ship_detail.dart';

class ShipperHomeScreen extends StatefulWidget {
  final String? token;

  const ShipperHomeScreen({super.key, this.token});

  @override
  State<ShipperHomeScreen> createState() => _ShipperHomeScreenState();
}

class _ShipperHomeScreenState extends State<ShipperHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ShipBloc>().add(FetchOrders());
  }

  Widget _progressStep(String title, bool isActive, bool isEnabled) {
    return GestureDetector(
      onTap: isEnabled
          ? () {
              if (title == "Delivered") {
                _showPhotoConfirmation(title);
              } else {
                _updateOrderStep(title);
              }
            }
          : null,
      child: Column(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green
                  : (isEnabled ? Colors.grey : Colors.grey[600]),
              shape: BoxShape.circle,
            ),
            child: isActive
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isActive
                  ? Colors.green
                  : (isEnabled ? Colors.grey : Colors.grey[600]),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressLine(bool isActive) {
    return Container(
      height: 2,
      color: isActive ? Colors.green : Colors.grey[600],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        title: Row(
          children: const [
            Text(
              "Active ",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              "Shipments",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none,
                    color: Colors.white, size: 28),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 16,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ShipBloc, ShipState>(
        builder: (context, state) {
          if (state is ShipLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ShipLoaded) {
            final orders = state.orders;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ShipBloc>().add(FetchOrders());
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2a2a2a),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.grey, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Search",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                          Icon(Icons.tune, color: Colors.grey, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...orders
                        .where((order) =>
                            order['status'] != 'available' &&
                            order['status'] != 'cancelled')
                        .map((order) => _activeShipmentItem(order))
                        .toList(),
                    if (orders
                        .where((order) => order['status'] == 'available')
                        .isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Recent Shipping",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "See all",
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    Expanded(
                      child: ListView.builder(
                        itemCount: orders
                            .where((order) => order['status'] == 'available')
                            .length,
                        itemBuilder: (context, index) {
                          final availableOrders = orders
                              .where((order) => order['status'] == 'available')
                              .toList();
                          final order = availableOrders[index];
                          return _availableOrderItem(order);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ShipError) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message,
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ShipBloc>().add(FetchOrders());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ));
          }
          return const Center(
              child: Text("No data available",
                  style: TextStyle(color: Colors.white)));
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF1D7020),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF1a1a1a),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, Routes.delivery);
          } else if (index == 2) {
            Navigator.pushNamed(context, Routes.profile);
          }
        },
      ),
    );
  }

  Widget _activeShipmentItem(Map<String, dynamic> order) {
    return GestureDetector(
      onTap: () {
        final userId = order['userId'] as int?;
        if (userId != null && userId != 0) {
          showDialog(
            context: context,
            builder: (context) => ShipDetail(userId: userId),
          );
        } else {
          _showOrderDetails(order);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: _getStatusColor(order['status']?.toString() ?? 'unknown'),
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order['orderId']?.toString() ?? 'Unknown Order',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                        order['status']?.toString() ?? 'unknown'),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order['status']?.toString().toUpperCase() ?? 'UNKNOWN',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress steps row
            Row(
              children: [
                _progressStep(
                    "Picked", order['steps']?['picked'] ?? false, true),
                Expanded(
                    child: _progressLine(order['steps']?['picked'] ?? false)),
                _progressStep(
                    "Delivering",
                    order['steps']?['delivering'] ?? false,
                    order['steps']?['picked'] ?? false),
                Expanded(
                    child:
                        _progressLine(order['steps']?['delivering'] ?? false)),
                _progressStep(
                    "Delivered",
                    order['steps']?['delivered'] ?? false,
                    order['steps']?['delivering'] ?? false),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order['customerName']?.toString() ?? 'Unknown Customer',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.grey, size: 16),
                const SizedBox(width: 6),
                Text(
                  order['receiverPhone']?.toString() ?? 'Unknown Phone',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order['customerAddress']?.toString() ?? 'Unknown Address',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      order['date']?.toString() ?? 'Unknown Date',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                if (order['totalAmount'] != null)
                  Text(
                    '${_formatCurrency(order['totalAmount'])} VND',
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Navigation button row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Get location from order data
                      final location = order['location'] as LatLng?;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeliveryScreen(
                            destinationLatLng: location,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Navigate to Delivery",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                if (order['steps']?['picked'] == true &&
                    order['steps']?['delivering'] == true &&
                    order['status'] != 'cancelled') ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _showCancelOrderDialog(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Hủy đơn",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _availableOrderItem(Map<String, dynamic> order) {
    return GestureDetector(
      onTap: () {
        final userId = order['userId'] as int?;
        if (userId != null && userId != 0) {
          showDialog(
            context: context,
            builder: (context) => ShipDetail(userId: userId),
          );
        } else {
          _showOrderDetails(order);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor(order['status']?.toString() ?? 'unknown'),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order['orderId']?.toString() ?? 'Unknown Order',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                        order['status']?.toString() ?? 'unknown'),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order['status']?.toString().toUpperCase() ?? 'UNKNOWN',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order['customerName']?.toString() ?? 'Unknown Customer',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.grey, size: 16),
                const SizedBox(width: 6),
                Text(
                  order['receiverPhone']?.toString() ?? 'Unknown Phone',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order['customerAddress']?.toString() ?? 'Unknown Address',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      order['date']?.toString() ?? 'Unknown Date',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                if (order['totalAmount'] != null)
                  Text(
                    '${_formatCurrency(order['totalAmount'])} VND',
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showCancelOrderDialog(order),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showAcceptOrderDialog(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Accept",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.blue;
      case 'picked':
        return Colors.orange;
      case 'delivering':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  'Order ID:', order['orderId']?.toString() ?? 'Unknown'),
              const SizedBox(height: 8),
              _buildDetailRow(
                  'Customer:', order['customerName']?.toString() ?? 'Unknown'),
              const SizedBox(height: 8),
              _buildDetailRow(
                  'Phone:', order['receiverPhone']?.toString() ?? 'Unknown'),
              const SizedBox(height: 8),
              _buildDetailRow('Address:',
                  order['customerAddress']?.toString() ?? 'Unknown'),
              const SizedBox(height: 8),
              _buildDetailRow('Date:', order['date']?.toString() ?? 'Unknown'),
              const SizedBox(height: 8),
              _buildDetailRow('Status:',
                  order['status']?.toString().toUpperCase() ?? 'Unknown'),
              if (order['totalAmount'] != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                    'Amount:', '${_formatCurrency(order['totalAmount'])} VND',
                    valueColor: Colors.green),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 14,
              fontWeight:
                  valueColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  void _showAcceptOrderDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2a2a2a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Xác nhận nhận đơn hàng",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  'Mã đơn:', order['orderId']?.toString() ?? 'Unknown'),
              const SizedBox(height: 8),
              _buildDetailRow('Khách hàng:',
                  order['customerName']?.toString() ?? 'Unknown'),
              const SizedBox(height: 8),
              _buildDetailRow('Địa chỉ:',
                  order['customerAddress']?.toString() ?? 'Unknown'),
              if (order['totalAmount'] != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                    'Số tiền:', '${_formatCurrency(order['totalAmount'])} VND',
                    valueColor: Colors.green),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  order['status'] = 'picked';
                  order['steps']['picked'] = true;
                });
                _showSuccessSnackBar('Đã nhận đơn hàng thành công');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child:
                  const Text("Xác nhận", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCancelOrderDialog(Map<String, dynamic> order) {
    String? selectedReason;
    final TextEditingController _reasonController = TextEditingController();
    final List<String> reasons = [
      'Không đủ thời gian giao hàng',
      'Địa chỉ không hợp lệ',
      'Khách hàng yêu cầu hủy',
      'Lý do khác'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2a2a2a),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                "Hủy đơn hàng",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                        'Mã đơn:', order['orderId']?.toString() ?? 'Unknown'),
                    const SizedBox(height: 8),
                    _buildDetailRow('Khách hàng:',
                        order['customerName']?.toString() ?? 'Unknown'),
                    const SizedBox(height: 8),
                    _buildDetailRow('Địa chỉ:',
                        order['customerAddress']?.toString() ?? 'Unknown'),
                    const SizedBox(height: 16),
                    const Text(
                      "Lý do hủy:",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF2a2a2a),
                      value: selectedReason,
                      hint: const Text(
                        "Chọn lý do",
                        style: TextStyle(color: Colors.grey),
                      ),
                      items: reasons.map((String reason) {
                        return DropdownMenuItem<String>(
                          value: reason,
                          child: Text(
                            reason,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedReason = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFF3a3a3a),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reasonController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Nhập lý do chi tiết (nếu có)",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFF3a3a3a),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child:
                      const Text("Hủy", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          setState(() {
                            order['status'] = 'cancelled';
                            order['cancelReason'] = selectedReason;
                            order['cancelDetails'] = _reasonController.text;
                          });
                          _showSuccessSnackBar('Đã hủy đơn hàng');
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    "Xác nhận",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _updateOrderStep(String step) {
    setState(() {
      context.read<ShipBloc>().add(FetchOrders());
    });
  }

  void _showPhotoConfirmation(String step) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2a2a2a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Xác nhận đã giao hàng",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Vui lòng chụp ảnh xác nhận đã giao hàng thành công",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              Icon(
                Icons.camera_alt,
                color: Colors.green,
                size: 48,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  context.read<ShipBloc>().add(FetchOrders());
                });
                _showSuccessSnackBar('Đã chụp ảnh xác nhận');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child:
                  const Text("Chụp ảnh", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
