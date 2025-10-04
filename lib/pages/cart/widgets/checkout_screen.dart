import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;
import 'address.dart';
import '../../../api/terra_api.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;
  final Map<String, dynamic>?
      orderData; // Add this to receive order data from cart

  const CheckoutScreen({
    super.key,
    required this.totalAmount,
    this.orderData,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _voucherController = TextEditingController();
  double _discountAmount = 0.0;
  Address? _selectedAddress;
  List<Address> _addresses = [];
  bool _isLoadingAddresses = true;
  bool _isProcessingPayment = false;

  // Payment options
  String _selectedPaymentOption = 'full'; // 'full' or 'partial'
  String? _storedToken;

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount.toInt())} VND';
  }

  double get _finalAmount {
    double baseAmount = widget.totalAmount - _discountAmount;

    // Apply payment option discounts
    if (_selectedPaymentOption == 'full') {
      // 10% discount for full payment
      return baseAmount * 0.9;
    } else if (_selectedPaymentOption == 'partial') {
      // Pay 30% for partial payment
      return baseAmount * 0.3;
    }

    return baseAmount;
  }

  bool get _canProceedToPayment => _selectedAddress != null;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    _getStoredToken();
  }

  Future<void> _getStoredToken() async {
    try {
      // Replace with your actual token retrieval method
      _storedToken = "your_stored_token_here";
    } catch (e) {
      developer.log('Error getting token: $e', name: 'Checkout');
    }
  }

  Dio _getDio() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    if (_storedToken != null && _storedToken!.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $_storedToken';
    }

    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = '*/*';

    return dio;
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoadingAddresses = true);

    try {
      final addresses = await AddressService.getAddresses();
      setState(() {
        _addresses = addresses;
        _selectedAddress = addresses.firstWhere(
          (addr) => addr.isDefault,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tải danh sách địa chỉ'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoadingAddresses = false);
    }
  }

  void _showAddressSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AddressSelectionDialog(
        addresses: _addresses,
        selectedAddress: _selectedAddress,
        onAddressSelected: (address) {
          setState(() {
            _selectedAddress = address;
          });
        },
        onAddressAdded: (address) {
          setState(() {
            _addresses.add(address);
            _selectedAddress = address;
          });
        },
      ),
    );
  }

  void _applyVoucher() {
    final voucherCode = _voucherController.text.trim().toUpperCase();
    setState(() {
      switch (voucherCode) {
        case 'GIAM10':
          _discountAmount = widget.totalAmount * 0.1;
          _showSnackBar('Áp dụng voucher thành công! Giảm 10%', Colors.green);
          break;
        case 'FREESHIP':
          _discountAmount = 20000;
          _showSnackBar('Áp dụng voucher miễn phí ship!', Colors.green);
          break;
        case 'SAVE50K':
          _discountAmount = 50000;
          _showSnackBar('Áp dụng voucher giảm 50K!', Colors.green);
          break;
        default:
          _discountAmount = 0;
          if (voucherCode.isNotEmpty) {
            _showSnackBar('Mã voucher không hợp lệ', Colors.red);
          }
      }
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_canProceedToPayment) {
      _showSnackBar('Vui lòng chọn địa chỉ giao hàng', Colors.red);
      return;
    }

    if (_isProcessingPayment) return;

    setState(() => _isProcessingPayment = true);

    try {
      // Get orderId from the checkout response
      final orderId = widget.orderData?['orderId'];
      if (orderId == null) {
        _showSnackBar('Lỗi: Không tìm thấy orderId', Colors.red);
        return;
      }

      developer.log('Processing payment for orderId: $orderId',
          name: 'Checkout');
      developer.log('Final amount: $_finalAmount', name: 'Checkout');
      developer.log('Payment option: $_selectedPaymentOption',
          name: 'Checkout');

      // Call MoMo payment API
      final paymentData = {
        "orderId": orderId,
        "orderInfo": "Thanh toán đơn hàng #$orderId",
        "finalAmount": _finalAmount.toInt(),
        "voucherId": 0, // You can implement voucher ID logic here
        "payAll": _selectedPaymentOption == 'full',
      };

      developer.log('Payment request data: $paymentData', name: 'Checkout');

      final response = await _getDio().post(
        TerraApi
            .createMomoPayment(), // You need to add this to your TerraApi class
        data: paymentData,
      );

      developer.log('Payment response: ${response.data}', name: 'Checkout');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['payUrl'] != null) {
          final payUrl = responseData['payUrl'] as String;

          // Launch MoMo payment URL
          await _launchPaymentUrl(payUrl);
        } else {
          _showSnackBar('Lỗi tạo thanh toán MoMo', Colors.red);
        }
      } else {
        _showSnackBar('Không thể tạo thanh toán', Colors.red);
      }
    } catch (e) {
      developer.log('Payment error: $e', name: 'Checkout');

      if (e is DioException) {
        final errorMsg = e.response?.data is Map<String, dynamic>
            ? e.response!.data['message'] ?? e.message
            : e.message;
        _showSnackBar('Lỗi thanh toán: $errorMsg', Colors.red);
      } else {
        _showSnackBar('Lỗi hệ thống: $e', Colors.red);
      }
    } finally {
      setState(() => _isProcessingPayment = false);
    }
  }

  Future<void> _launchPaymentUrl(String url) async {
    try {
      final uri = Uri.parse(url);

      if (Platform.isAndroid) {
        // Android: Force open in Chrome
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else if (Platform.isIOS) {
        // iOS: Force open in Safari
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        await launchUrl(uri);
      }

      _showPaymentCompletionDialog();
    } catch (e) {
      developer.log('Error launching payment URL: $e', name: 'Checkout');
      _showSnackBar('Lỗi mở trang thanh toán', Colors.red);
    }
  }

  void _showPaymentCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hoàn tất thanh toán'),
          content: const Text(
              'Vui lòng hoàn tất thanh toán trong ứng dụng MoMo và quay lại ứng dụng.\n\n'
              'Bạn đã hoàn tất thanh toán chưa?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Return to cart or home
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              },
              child: const Text('Đã thanh toán'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Chưa xong', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Chọn hình thức thanh toán',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Full payment option
                  Card(
                    elevation: _selectedPaymentOption == 'full' ? 4 : 1,
                    color: _selectedPaymentOption == 'full'
                        ? const Color(0xFF1D7020).withOpacity(0.1)
                        : Colors.white,
                    child: RadioListTile<String>(
                      title: const Text(
                        'Thanh toán toàn bộ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Giảm 10% tổng giá trị đơn hàng'),
                          const SizedBox(height: 4),
                          Text(
                            'Thanh toán: ${_formatCurrency((widget.totalAmount - _discountAmount) * 0.9)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D7020),
                            ),
                          ),
                        ],
                      ),
                      value: 'full',
                      groupValue: _selectedPaymentOption,
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedPaymentOption = value!;
                        });
                      },
                      activeColor: const Color(0xFF1D7020),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Partial payment option
                  Card(
                    elevation: _selectedPaymentOption == 'partial' ? 4 : 1,
                    color: _selectedPaymentOption == 'partial'
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.white,
                    child: RadioListTile<String>(
                      title: const Text(
                        'Thanh toán trước 30%',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thanh toán 30% giá trị đơn hàng trước'),
                          const SizedBox(height: 4),
                          Text(
                            'Thanh toán: ${_formatCurrency((widget.totalAmount - _discountAmount) * 0.3)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Còn lại: ${_formatCurrency((widget.totalAmount - _discountAmount) * 0.7)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      value: 'partial',
                      groupValue: _selectedPaymentOption,
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedPaymentOption = value!;
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Update the main screen
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D7020),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D7020),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D7020),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tổng quan đơn hàng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng tiền:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        _formatCurrency(widget.totalAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_discountAmount > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Giảm giá voucher:',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        Text(
                          '-${_formatCurrency(_discountAmount)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_selectedPaymentOption == 'full') ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thanh toán toàn bộ (-10%):',
                          style: TextStyle(fontSize: 16, color: Colors.green),
                        ),
                        Text(
                          '-${_formatCurrency((widget.totalAmount - _discountAmount) * 0.1)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ] else if (_selectedPaymentOption == 'partial') ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thanh toán trước (30%):',
                          style: TextStyle(fontSize: 16, color: Colors.orange),
                        ),
                        Text(
                          '${_formatCurrency((widget.totalAmount - _discountAmount) * 0.3)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thành tiền:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatCurrency(_finalAmount),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D7020),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Payment Option Selection
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.payment,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Hình thức thanh toán',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showPaymentOptionsDialog,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Thay đổi'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (_selectedPaymentOption == 'full'
                              ? const Color(0xFF1D7020)
                              : Colors.orange)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedPaymentOption == 'full'
                            ? const Color(0xFF1D7020)
                            : Colors.orange,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedPaymentOption == 'full'
                              ? 'Thanh toán toàn bộ'
                              : 'Thanh toán trước 30%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selectedPaymentOption == 'full'
                                ? const Color(0xFF1D7020)
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedPaymentOption == 'full'
                              ? 'Giảm 10% tổng giá trị đơn hàng'
                              : 'Thanh toán 30% trước, 70% còn lại khi giao hàng',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Số tiền cần thanh toán: ${_formatCurrency(_finalAmount)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _selectedPaymentOption == 'full'
                                ? const Color(0xFF1D7020)
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Delivery Address Card (existing code)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D7020),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Địa chỉ giao hàng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        ' *',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _showAddressSelectionDialog,
                        icon: const Icon(Icons.edit, size: 18),
                        label: Text(
                            _selectedAddress == null ? 'Chọn' : 'Thay đổi'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1D7020),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingAddresses)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF1D7020),
                        ),
                      ),
                    )
                  else if (_selectedAddress == null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chưa chọn địa chỉ giao hàng',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _showAddressSelectionDialog,
                            icon: const Icon(Icons.add_location_alt),
                            label: const Text('Chọn địa chỉ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D7020),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D7020).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF1D7020).withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _selectedAddress!.receiverName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (_selectedAddress!.tagName != null &&
                                  _selectedAddress!.tagName!.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1D7020)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _selectedAddress!.tagName!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF1D7020),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                              if (_selectedAddress!.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Mặc định',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedAddress!.receiverPhone,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedAddress!.receiverAddress,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Voucher Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_offer,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mã giảm giá',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _voucherController,
                          decoration: InputDecoration(
                            hintText:
                                'Nhập mã voucher (GIAM10, FREESHIP, SAVE50K)',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1D7020), width: 2),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _applyVoucher,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Áp dụng',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessingPayment ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D7020),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
                child: _isProcessingPayment
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Đang xử lý...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Thanh toán với MoMo ${_formatCurrency(_finalAmount)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
