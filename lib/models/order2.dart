class Order {
  final int orderId;
  final int userId;
  final int? voucherId;
  final int addressId;
  final double totalAmount;
  final double deposit;
  final double originalAmount;
  final double discountAmount;
  final DateTime orderDate;
  final String status;
  final String paymentStatus;
  final String transactionId;

  Order({
    required this.orderId,
    required this.userId,
    this.voucherId,
    required this.addressId,
    required this.totalAmount,
    required this.deposit,
    required this.originalAmount,
    required this.discountAmount,
    required this.orderDate,
    required this.status,
    required this.paymentStatus,
    required this.transactionId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] ?? 0,
      userId: json['userId'] ?? 0,
      voucherId: json['voucherId'],
      addressId: json['addressId'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      deposit: (json['deposit'] ?? 0).toDouble(),
      originalAmount: (json['originalAmount'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      orderDate:
          DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'Unknown',
      paymentStatus: json['paymentStatus'] ?? 'Unknown',
      transactionId: json['transactionId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'voucherId': voucherId,
      'addressId': addressId,
      'totalAmount': totalAmount,
      'deposit': deposit,
      'originalAmount': originalAmount,
      'discountAmount': discountAmount,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
      'paymentStatus': paymentStatus,
      'transactionId': transactionId,
    };
  }

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Đợi xác nhận';
      case 'progressing':
        return 'Đang xử lý';
      case 'shipping':
        return 'Đang giao hàng';
      case 'completed':
        return 'Giao hàng thành công';
      case 'failed':
        return 'Giao hàng thất bại';
      case 'rejected':
        return 'Đơn hàng bị hủy';
      default:
        return status;
    }
  }

  String get paymentStatusDisplayName {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return 'Đã thanh toán';
      case 'pending':
        return 'Chờ thanh toán';
      case 'failed':
        return 'Thanh toán thất bại';
      case 'refunded':
        return 'Đã hoàn tiền';
      default:
        return paymentStatus;
    }
  }
}
