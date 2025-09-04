class OrderDetail {
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
  final String paymentMethod;
  final bool isPayFull;
  final String note;
  final List<dynamic> refunds;
  final List<OrderItem> orderItems;

  OrderDetail({
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
    required this.paymentMethod,
    required this.isPayFull,
    required this.note,
    required this.refunds,
    required this.orderItems,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
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
      paymentMethod: json['paymentMethod'] ?? '',
      isPayFull: json['isPayFull'] ?? false,
      note: json['note'] ?? '',
      refunds: json['refunds'] ?? [],
      orderItems: (json['orderItems'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
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

class OrderItem {
  final int comboId;
  final String itemType;
  final int orderItemId;
  final int terrariumId;
  final int? accessoryId;
  final int terrariumVariantId;
  final int accessoryQuantity;
  final int terrariumVariantQuantity;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final int? parentOrderItemId;
  final bool isFeedBack;
  final List<dynamic> childItems;
  final String productName;
  final String imageUrl;

  OrderItem({
    required this.comboId,
    required this.itemType,
    required this.orderItemId,
    required this.terrariumId,
    this.accessoryId,
    required this.terrariumVariantId,
    required this.accessoryQuantity,
    required this.terrariumVariantQuantity,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.parentOrderItemId,
    required this.isFeedBack,
    required this.childItems,
    required this.productName,
    required this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      comboId: json['comboId'] ?? 0,
      itemType: json['itemType'] ?? '',
      orderItemId: json['orderItemId'] ?? 0,
      terrariumId: json['terrariumId'] ?? 0,
      accessoryId: json['accessoryId'],
      terrariumVariantId: json['terrariumVariantId'] ?? 0,
      accessoryQuantity: json['accessoryQuantity'] ?? 0,
      terrariumVariantQuantity: json['terrariumVariantQuantity'] ?? 0,
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      parentOrderItemId: json['parentOrderItemId'],
      isFeedBack: json['isFeedBack'] ?? false,
      childItems: json['childItems'] ?? [],
      productName: json['productName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  String get itemTypeDisplayName {
    switch (itemType) {
      case 'MAIN_ITEM':
        return 'Sản phẩm chính';
      case 'BUNDLE_ACCESSORY':
        return 'Phụ kiện đi kèm';
      case 'STANDALONE_ACCESSORY':
        return 'Phụ kiện riêng lẻ';
      default:
        return itemType;
    }
  }
}
