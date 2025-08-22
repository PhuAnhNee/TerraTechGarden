import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../../../models/transport.dart';
import '../../../../models/address.dart';
import '../bloc/ship_bloc.dart';
import '../bloc/ship_event.dart';

class TransportCard extends StatefulWidget {
  final Transport transport;
  final Address? address;
  final VoidCallback? onTap;
  final String token;

  const TransportCard({
    Key? key,
    required this.transport,
    this.address,
    this.onTap,
    required this.token,
  }) : super(key: key);

  @override
  _TransportCardState createState() => _TransportCardState();
}

class _TransportCardState extends State<TransportCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showImagePickerDialog(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    String? selectedReason;
    XFile? pickedImage;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                'Xác nhận chạy đơn hàng #${widget.transport.transportId}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Lý do dropdown
                    Text(
                      'Chọn lý do:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedReason,
                        hint: Text(
                          'Chọn lý do',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        dropdownColor: Color(0xFF2A2A2A),
                        items: [
                          'Nhận đơn',
                          'Lấy hàng nhanh',
                          'Chạy đơn kép',
                        ].map((String reason) {
                          return DropdownMenuItem<String>(
                            value: reason,
                            child: Text(
                              reason,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedReason = newValue;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16),

                    // Chọn ảnh
                    Text(
                      'Chọn hình ảnh:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 80,
                              );
                              if (image != null) {
                                setState(() {
                                  pickedImage = image;
                                });
                              }
                            },
                            icon: Icon(Icons.camera_alt, size: 16),
                            label: Text('Chụp ảnh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                              );
                              if (image != null) {
                                setState(() {
                                  pickedImage = image;
                                });
                              }
                            },
                            icon: Icon(Icons.photo, size: 16),
                            label: Text('Chọn ảnh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Hiển thị ảnh đã chọn
                    if (pickedImage != null) ...[
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Ảnh đã chọn: ${pickedImage!.name}',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedReason != null && pickedImage != null
                            ? () {
                                context.read<ShipBloc>().add(
                                      UpdateTransportStatusEvent(
                                        transportId:
                                            widget.transport.transportId,
                                        status: 'shipping',
                                        token: widget.token,
                                        reason: selectedReason,
                                        imagePath: pickedImage!.path,
                                        contactFailNumber: '0706801385',
                                        assignToUserId: widget.transport.userId,
                                      ),
                                    );
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selectedReason != null && pickedImage != null
                                  ? Colors.blue
                                  : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text('Xác nhận'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToDelivery(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/delivery',
      arguments: {
        'transport': widget.transport,
        'address': widget.address,
        'token': widget.token,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transport.status != 'inWarehouse' &&
        widget.transport.status != 'shipping') {
      return SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 12),
                _buildOrderInfo(),
                if (widget.transport.estimatedDelivery != null) ...[
                  SizedBox(height: 8),
                  _buildEstimatedDelivery(),
                ],
                if (widget.transport.note != null &&
                    widget.transport.note!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  _buildNote(),
                ],
                if (widget.address != null) ...[
                  SizedBox(height: 12),
                  _buildAddressInfo(),
                ],
                SizedBox(height: 12),
                _buildCreatorInfo(),
                SizedBox(height: 16),
                _buildActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Đơn hàng #${widget.transport.transportId}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        _buildStatusChip(widget.transport.status),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Row(
      children: [
        Icon(
          Icons.receipt_outlined,
          color: Colors.grey.shade400,
          size: 16,
        ),
        SizedBox(width: 8),
        Text(
          'Đơn hàng #${widget.transport.orderId}',
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEstimatedDelivery() {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          color: Colors.grey.shade400,
          size: 16,
        ),
        SizedBox(width: 8),
        Text(
          'Dự kiến giao: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.transport.estimatedDelivery!)}',
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.note_outlined,
          color: Colors.grey.shade400,
          size: 16,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Ghi chú: ${widget.transport.note}',
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF252525),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin người nhận',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          _buildInfoRow('Tên: ${widget.address!.receiverName}'),
          SizedBox(height: 4),
          _buildInfoRow('SĐT: ${widget.address!.receiverPhone}'),
          SizedBox(height: 4),
          _buildInfoRow('Địa chỉ: ${widget.address!.receiverAddress}',
              maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text, {int maxLines = 1}) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade300,
        fontSize: 13,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCreatorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tạo bởi: ${widget.transport.createdBy ?? 'Unknown'}',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Tạo lúc: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.transport.createdDate ?? DateTime.now())}',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (widget.transport.status == 'inWarehouse') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showImagePickerDialog(context),
          icon: Icon(Icons.local_shipping, size: 18),
          label: Text('Chạy đơn hàng'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    } else if (widget.transport.status == 'shipping') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _navigateToDelivery(context),
          icon: Icon(Icons.location_on, size: 18),
          label: Text('Xem vị trí khách hàng'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'inWarehouse':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        displayText = 'Trong kho';
        break;
      case 'shipping':
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        displayText = 'Đang giao';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        displayText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
