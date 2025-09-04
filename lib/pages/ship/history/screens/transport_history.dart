// screens/transport_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../home/bloc/ship_bloc.dart';
import '../../home/bloc/ship_event.dart';
import '../../home/bloc/ship_state.dart';

class TransportHistoryScreen extends StatefulWidget {
  final String token;

  const TransportHistoryScreen({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<TransportHistoryScreen> createState() => _TransportHistoryScreenState();
}

class _TransportHistoryScreenState extends State<TransportHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadTransportHistory();
  }

  void _loadTransportHistory() {
    context
        .read<ShipBloc>()
        .add(LoadTransportHistoryEvent(token: widget.token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: _buildAppBar(),
      body: BlocBuilder<ShipBloc, ShipState>(
        builder: (context, state) {
          if (state is ShipLoading) {
            return _buildLoadingWidget();
          }

          if (state is ShipError) {
            return _buildErrorWidget(state.message);
          }

          if (state is TransportHistoryLoaded) {
            if (state.transports.isEmpty) {
              return _buildEmptyWidget();
            }

            return RefreshIndicator(
              onRefresh: () async => _loadTransportHistory(),
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: state.transports.length,
                itemBuilder: (context, index) {
                  final transport = state.transports[index];
                  final address = state.addresses[transport.orderId];
                  return _buildTransportHistoryCard(transport, address);
                },
              ),
            );
          }

          return _buildEmptyWidget();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2a2a2a),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 41, 150, 45),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.history,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Lịch sử vận chuyển',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadTransportHistory,
        ),
      ],
    );
  }

  Widget _buildTransportHistoryCard(dynamic transport, dynamic address) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
    final isCompleted = transport.status == 'completed';
    final isFailed = transport.status == 'failed';

    Color statusColor = isCompleted
        ? Colors.green
        : isFailed
            ? Colors.red
            : Colors.orange;

    String statusText = isCompleted
        ? 'Đã giao thành công'
        : isFailed
            ? 'Giao thất bại'
            : transport.status;

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
            color: statusColor.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transport Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : isFailed
                              ? Icons.error
                              : Icons.local_shipping,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vận đơn #${transport.transportId}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Đơn hàng #${transport.orderId}',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Delivery Information
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
                          Icon(Icons.location_on,
                              color: const Color.fromARGB(255, 41, 150, 45),
                              size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Thông tin giao hàng',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 41, 150, 45),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      _buildInfoRow(Icons.person_outline, address.receiverName),
                      _buildInfoRow(Icons.phone, address.receiverPhone),
                      _buildInfoRow(Icons.location_on, address.receiverAddress,
                          isAddress: true),
                    ],
                  ),
                ),
                SizedBox(height: 12),
              ],

              // Transport Details
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a1a),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Hiển thị ngày tạo (ưu tiên createdDate, fallback là createdAt)
                    if (transport.createdDate != null)
                      _buildDetailRow('Ngày tạo:',
                          dateFormatter.format(transport.createdDate!))
                    else if (transport.createdAt != null)
                      _buildDetailRow('Ngày tạo:',
                          dateFormatter.format(transport.createdAt!)),

                    // SỬA: Sử dụng property estimatedDelivery từ model
                    if (transport.estimatedDelivery != null)
                      _buildDetailRow('Dự kiến hoàn thành:',
                          dateFormatter.format(transport.estimatedDelivery!))
                    else if (transport.createdDate != null)
                      // Fallback: tính từ createdDate + 12 giờ nếu không có estimatedDelivery
                      _buildDetailRow(
                          'Dự kiến hoàn thành:',
                          dateFormatter.format(
                              transport.createdDate!.add(Duration(hours: 12))))
                    else if (transport.createdAt != null)
                      // Fallback: tính từ createdAt + 12 giờ
                      _buildDetailRow(
                          'Dự kiến hoàn thành:',
                          dateFormatter.format(
                              transport.createdAt!.add(Duration(hours: 12)))),

                    if (transport.completedAt != null)
                      _buildDetailRow('Ngày hoàn thành:',
                          dateFormatter.format(transport.completedAt!)),
                    if (transport.contactFailNumber != null &&
                        transport.contactFailNumber > 0)
                      _buildDetailRow('Số lần liên hệ thất bại:',
                          transport.contactFailNumber.toString()),
                    if (transport.note != null && transport.note!.isNotEmpty)
                      _buildDetailRow('Ghi chú:', transport.note!,
                          isNote: true),
                  ],
                ),
              ),

              // Image if available
              if (transport.imagePath != null &&
                  transport.imagePath!.isNotEmpty) ...[
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade600),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      transport.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade800,
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey.shade400,
                            size: 50,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade800,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color.fromARGB(255, 41, 150, 45),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isAddress = false}) {
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

  Widget _buildDetailRow(String label, String value, {bool isNote = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            isNote ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              maxLines: isNote ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
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
            'Đang tải lịch sử...',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
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
            onPressed: _loadTransportHistory,
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

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Chưa có lịch sử vận chuyển',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Các đơn hàng đã giao sẽ hiển thị tại đây',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadTransportHistory,
            icon: Icon(Icons.refresh),
            label: Text('Tải lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 41, 150, 45),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
