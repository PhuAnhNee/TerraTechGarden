import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/transport.dart';

class TransportDetailDialog extends StatelessWidget {
  final Transport transport;

  const TransportDetailDialog({Key? key, required this.transport})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
          maxWidth: 400,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a1a),
              Color(0xFF2d2d2d),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Elegant Header
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4A90E2).withOpacity(0.8),
                    Color(0xFF357ABD).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vận đơn',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '#${transport.transportId}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      _buildStatusChip(transport.status),
                    ],
                  ),
                ],
              ),
            ),

            // Content with better spacing
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInfoCard('Thông tin đơn hàng', [
                      _buildInfoItem(Icons.shopping_bag_outlined, 'Đơn hàng',
                          '#${transport.orderId}'),
                      if (transport.estimatedDelivery != null)
                        _buildInfoItem(
                            Icons.schedule_outlined,
                            'Dự kiến giao',
                            DateFormat('dd/MM/yyyy HH:mm')
                                .format(transport.estimatedDelivery!)),
                      if (transport.completedAt != null)
                        _buildInfoItem(
                            Icons.check_circle_outline,
                            'Hoàn thành',
                            DateFormat('dd/MM/yyyy HH:mm')
                                .format(transport.completedAt!)),
                    ]),
                    SizedBox(height: 16),
                    _buildInfoCard('Chi tiết khác', [
                      _buildInfoItem(Icons.person_outline, 'Tạo bởi',
                          transport.createdBy ?? 'Unknown'),
                      _buildInfoItem(
                          Icons.access_time_outlined,
                          'Tạo lúc',
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(transport.createdDate ?? DateTime.now())),
                      if (transport.contactFailNumber != null &&
                          transport.contactFailNumber! > 0)
                        _buildInfoItem(
                            Icons.phone_missed_outlined,
                            'Lần liên hệ thất bại',
                            transport.contactFailNumber.toString()),
                      if (transport.isRefund != null)
                        _buildInfoItem(Icons.money_off_outlined, 'Hoàn tiền',
                            transport.isRefund! ? 'Có' : 'Không'),
                    ]),
                    if (transport.note != null &&
                        transport.note!.isNotEmpty) ...[
                      SizedBox(height: 16),
                      _buildNoteCard(transport.note!),
                    ],
                  ],
                ),
              ),
            ),

            // Modern Action Button
            Container(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF333333).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                color: Color(0xFF4A90E2),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Color(0xFF4A90E2),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(String note) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF6B6B).withOpacity(0.1),
            Color(0xFFFF8E8E).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFFF6B6B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_alt_outlined,
                color: Color(0xFFFF6B6B),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Ghi chú',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            note,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    String displayText;
    IconData icon;

    switch (status) {
      case 'inWarehouse':
        backgroundColor = Color(0xFFFF9500).withOpacity(0.15);
        textColor = Color(0xFFFF9500);
        borderColor = Color(0xFFFF9500).withOpacity(0.3);
        displayText = 'Trong kho';
        icon = Icons.warehouse_outlined;
        break;
      case 'shipping':
        backgroundColor = Color(0xFF007AFF).withOpacity(0.15);
        textColor = Color(0xFF007AFF);
        borderColor = Color(0xFF007AFF).withOpacity(0.3);
        displayText = 'Đang giao';
        icon = Icons.local_shipping_outlined;
        break;
      case 'completed':
        backgroundColor = Color(0xFF34C759).withOpacity(0.15);
        textColor = Color(0xFF34C759);
        borderColor = Color(0xFF34C759).withOpacity(0.3);
        displayText = 'Hoàn thành';
        icon = Icons.check_circle_outline;
        break;
      case 'inCustomer':
        backgroundColor = Color(0xFFAF52DE).withOpacity(0.15);
        textColor = Color(0xFFAF52DE);
        borderColor = Color(0xFFAF52DE).withOpacity(0.3);
        displayText = 'Tại khách';
        icon = Icons.person_pin_circle_outlined;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.15);
        textColor = Colors.grey;
        borderColor = Colors.grey.withOpacity(0.3);
        displayText = status;
        icon = Icons.help_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          SizedBox(width: 6),
          Text(
            displayText,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
