import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/transport.dart';

class TransportDetailDialog extends StatelessWidget {
  final Transport transport;

  const TransportDetailDialog({Key? key, required this.transport})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2a2a2a),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Chi tiết vận đơn #${transport.transportId}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          _buildStatusChip(transport.status),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Đơn hàng', '#${transport.orderId}'),
            if (transport.estimatedDelivery != null)
              _buildDetailRow(
                'Dự kiến giao',
                DateFormat('dd/MM/yyyy HH:mm')
                    .format(transport.estimatedDelivery!),
              ),
            if (transport.completedAt != null)
              _buildDetailRow(
                'Hoàn thành',
                DateFormat('dd/MM/yyyy HH:mm').format(transport.completedAt!),
              ),
            if (transport.note != null && transport.note!.isNotEmpty)
              _buildDetailRow('Ghi chú', transport.note!),
            _buildDetailRow('Tạo bởi', transport.createdBy ?? 'Unknown'),
            _buildDetailRow(
              'Tạo lúc',
              DateFormat('dd/MM/yyyy HH:mm')
                  .format(transport.createdDate ?? DateTime.now()),
            ),
            if (transport.contactFailNumber != null &&
                transport.contactFailNumber! > 0)
              _buildDetailRow('Số lần liên hệ thất bại',
                  transport.contactFailNumber.toString()),
            if (transport.isRefund != null)
              _buildDetailRow(
                  'Hoàn tiền', transport.isRefund! ? 'Có' : 'Không'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Đóng',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                  color: Colors.grey.shade400, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    String displayText;

    switch (status) {
      case 'inWarehouse':
        backgroundColor = Colors.orange.withOpacity(0.2);
        displayText = 'Trong kho';
        break;
      case 'shipping':
        backgroundColor = Colors.blue.withOpacity(0.2);
        displayText = 'Đang giao';
        break;
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.2);
        displayText = 'Hoàn thành';
        break;
      case 'inCustomer':
        backgroundColor = Colors.purple.withOpacity(0.2);
        displayText = 'Tại khách';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        displayText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: status == 'inWarehouse'
              ? Colors.orange
              : status == 'shipping'
                  ? Colors.blue
                  : status == 'completed'
                      ? Colors.green
                      : status == 'inCustomer'
                          ? Colors.purple
                          : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
