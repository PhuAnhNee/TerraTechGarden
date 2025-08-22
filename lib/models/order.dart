class Order {
  final int orderId;
  final int userId;
  final int addressId;
  final double totalAmount;
  final double deposit;
  final double? discountAmount;
  final DateTime orderDate;
  final String status;
  final String paymentStatus;
  final String transactionId;
  final String paymentMethod;
  final List<dynamic> orderItems;

  Order({
    required this.orderId,
    required this.userId,
    required this.addressId,
    required this.totalAmount,
    required this.deposit,
    this.discountAmount,
    required this.orderDate,
    required this.status,
    required this.paymentStatus,
    required this.transactionId,
    required this.paymentMethod,
    required this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] ?? 0,
      userId: json['userId'] ?? 0,
      addressId: json['addressId'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      deposit: (json['deposit'] ?? 0).toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      orderDate:
          DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      transactionId: json['transactionId'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      orderItems: json['orderItems'] ?? [],
    );
  }
}
