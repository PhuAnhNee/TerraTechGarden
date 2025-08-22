// widgets/order_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/ship_bloc.dart';
import '../bloc/ship_event.dart';
import '../bloc/ship_state.dart';
import '../../../../models/order.dart';
import '../../../../models/address.dart';

class OrderDetailDialog extends StatefulWidget {
  final Order order;
  final Address? address;
  final String token;

  const OrderDetailDialog({
    Key? key,
    required this.order,
    required this.address,
    required this.token,
  }) : super(key: key);

  @override
  State<OrderDetailDialog> createState() => _OrderDetailDialogState();
}

class _OrderDetailDialogState extends State<OrderDetailDialog> {
  final TextEditingController _noteController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
    final estimatedDate = widget.order.orderDate.add(Duration(hours: 12));

    return BlocListener<ShipBloc, ShipState>(
      listener: (context, state) {
        if (state is TransportCreated) {
          setState(() {
            _isCreating = false;
          });
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Transport created successfully!'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ShipError) {
          setState(() {
            _isCreating = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ShipLoading) {
          setState(() {
            _isCreating = true;
          });
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_shipping, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Order Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.white),
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Info
                      _buildInfoSection(
                        'Order Information',
                        [
                          _buildInfoRow('Order ID', '#${widget.order.orderId}'),
                          _buildInfoRow('Order Date',
                              dateFormatter.format(widget.order.orderDate)),
                          _buildInfoRow('Estimated Delivery',
                              dateFormatter.format(estimatedDate)),
                          _buildInfoRow(
                              'Status', widget.order.status.toUpperCase()),
                          _buildInfoRow(
                              'Payment Status', widget.order.paymentStatus),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Customer Info
                      if (widget.address != null)
                        _buildInfoSection(
                          'Customer Information',
                          [
                            _buildInfoRow('Name', widget.address!.receiverName),
                            _buildInfoRow(
                                'Phone', widget.address!.receiverPhone),
                            _buildInfoRow(
                                'Address', widget.address!.receiverAddress,
                                isAddress: true),
                          ],
                        ),

                      SizedBox(height: 20),

                      // Price Info
                      _buildInfoSection(
                        'Payment Information',
                        [
                          _buildPriceRow(
                              'Total Amount', widget.order.totalAmount,
                              isTotal: true),
                          if (widget.order.deposit > 0)
                            _buildPriceRow('Deposit', widget.order.deposit),
                          if (widget.order.discountAmount != null &&
                              widget.order.discountAmount! > 0)
                            _buildPriceRow(
                                'Discount', widget.order.discountAmount!,
                                isDiscount: true),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Note Input
                      Text(
                        'Shipping Note',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter shipping note (optional)...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Colors.blue.shade600, width: 2),
                          ),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isCreating
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _confirmOrder,
                        child: _isCreating
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Creating...'),
                                ],
                              )
                            : Text(
                                'Confirm Order',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAddress = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            isAddress ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + ':',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value,
      {bool isTotal = false, bool isDiscount = false}) {
    final formatter = NumberFormat('#,##0', 'vi_VN');

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + ':',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${isDiscount ? '-' : ''}${formatter.format(value)}đ',
              style: TextStyle(
                color: isTotal
                    ? Colors.green.shade700
                    : isDiscount
                        ? Colors.red.shade700
                        : Colors.grey.shade800,
                fontSize: 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmOrder() {
    context.read<ShipBloc>().add(
          CreateTransportEvent(
            token: widget.token,
            orderId: widget.order.orderId,
            userId: widget.order.userId,
            orderDate: widget.order.orderDate,
            note: _noteController.text.trim(),
          ),
        );
  }
}
