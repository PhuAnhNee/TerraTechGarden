import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../navigation/routes.dart';
import '../../delivery/screens/delivery_screen.dart';

class ShipperHomeScreen extends StatefulWidget {
  const ShipperHomeScreen({super.key});

  @override
  State<ShipperHomeScreen> createState() => _ShipperHomeScreenState();
}

class _ShipperHomeScreenState extends State<ShipperHomeScreen> {
  final List<Map<String, dynamic>> orders = [
    {
      'orderId': 'JAM478549',
      'customerName': 'Nguyễn Văn A',
      'customerAddress': '123 Lê Lợi, Quận 1, TP.HCM',
      'location': const LatLng(10.7769, 106.7009),
      'status': 'available',
      'date': '10 May 26',
      'steps': {
        'picked': false,
        'delivering': false,
        'delivered': false,
      }
    },
    {
      'orderId': 'JAM478550',
      'customerName': 'Trần Thị B',
      'customerAddress': '456 Nguyễn Thị Thập, Quận 7, TP.HCM',
      'location': const LatLng(10.7295, 106.7218),
      'status': 'available',
      'date': '10 May 26',
      'steps': {
        'picked': false,
        'delivering': false,
        'delivered': false,
      }
    },
    {
      'orderId': 'JAM478551',
      'customerName': 'Phạm Văn C',
      'customerAddress': '789 Phạm Văn Đồng, Bình Thạnh, TP.HCM',
      'location': const LatLng(10.8206, 106.6798),
      'status': 'available',
      'date': '10 May 26',
      'steps': {
        'picked': false,
        'delivering': false,
        'delivered': false,
      }
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        title: Row(
          children: [
            const Text(
              "Active ",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const Text(
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2a2a2a),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Search",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.tune, color: Colors.grey, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...orders
                .where((order) =>
                    order['status'] != 'available' &&
                    order['status'] != 'cancelled')
                .map((order) {
              return _activeShipmentItem(order);
            }).toList(),
            if (orders
                .where((order) => order['status'] == 'available')
                .isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Shipping",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "See all",
                      style: TextStyle(color: Colors.green),
                    ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['orderId'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order['status'] == 'cancelled'
                      ? Colors.red
                      : Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order['status'] == 'cancelled' ? 'Cancelled' : 'Placed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _progressStep("Picked", order['steps']['picked'], true),
              Expanded(child: _progressLine(order['steps']['picked'])),
              _progressStep("Delivering", order['steps']['delivering'],
                  order['steps']['picked']),
              Expanded(child: _progressLine(order['steps']['delivering'])),
              _progressStep("Delivered", order['steps']['delivered'],
                  order['steps']['delivering']),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['date'],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                order['date'],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeliveryScreen(
                          destinationLatLng: order['location'],
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
              if (order['steps']['picked'] &&
                  order['steps']['delivering'] &&
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
    );
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

  Widget _availableOrderItem(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['orderId'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order['customerAddress'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showAcceptOrderDialog(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              "Nhận đơn",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showAcceptOrderDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2a2a2a),
          title: const Text(
            "Xác nhận nhận đơn hàng",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mã đơn: ${order['orderId']}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "Khách hàng: ${order['customerName']}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "Địa chỉ: ${order['customerAddress']}",
                style: const TextStyle(color: Colors.white),
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
                  order['status'] = 'picked';
                  order['steps']['picked'] = true;
                  print(
                      'Order ${order['orderId']} accepted and marked as picked');
                });
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
              title: const Text(
                "Hủy đơn hàng",
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mã đơn: ${order['orderId']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Khách hàng: ${order['customerName']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Địa chỉ: ${order['customerAddress']}",
                      style: const TextStyle(color: Colors.white),
                    ),
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
                            print(
                                'Order ${order['orderId']} cancelled with reason: $selectedReason');
                          });
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

  void _updateOrderStep(String step) {
    setState(() {
      for (var order in orders) {
        if (order['status'] != 'available' && order['status'] != 'cancelled') {
          if (step == "Picked") {
            order['steps']['picked'] = true;
            order['status'] = 'picked';
            print('Order ${order['orderId']} marked as picked');
          } else if (step == "Delivering") {
            order['steps']['delivering'] = true;
            order['status'] = 'delivering';
            print('Order ${order['orderId']} marked as delivering');
          }
        }
      }
    });
  }

  void _showPhotoConfirmation(String step) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2a2a2a),
          title: const Text(
            "Xác nhận đã giao hàng",
            style: TextStyle(color: Colors.white),
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
                  for (var order in orders) {
                    if (order['status'] != 'available' &&
                        order['status'] != 'cancelled') {
                      order['steps']['delivered'] = true;
                      order['status'] = 'delivered';
                      print('Order ${order['orderId']} marked as delivered');
                    }
                  }
                });
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
