class Transport {
  final int transportId;
  final int orderId;
  final String status;
  final DateTime? estimateCompletedDate;
  final DateTime? completedDate;
  final DateTime? lastConfirmFailed;
  final int contactFailNumber;
  final String note;
  final bool isRefund;
  final int userId;
  final DateTime createdDate;
  final String createdBy;
  final String image;

  Transport({
    required this.transportId,
    required this.orderId,
    required this.status,
    this.estimateCompletedDate,
    this.completedDate,
    this.lastConfirmFailed,
    required this.contactFailNumber,
    required this.note,
    required this.isRefund,
    required this.userId,
    required this.createdDate,
    required this.createdBy,
    required this.image,
  });

  factory Transport.fromJson(Map<String, dynamic> json) {
    return Transport(
      transportId: json['transportId'] ?? 0,
      orderId: json['orderId'] ?? 0,
      status: json['status'] ?? '',
      estimateCompletedDate: json['estimateCompletedDate'] != null
          ? DateTime.tryParse(json['estimateCompletedDate'])
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.tryParse(json['completedDate'])
          : null,
      lastConfirmFailed: json['lastConfirmFailed'] != null
          ? DateTime.tryParse(json['lastConfirmFailed'])
          : null,
      contactFailNumber: json['contactFailNumber'] ?? 0,
      note: json['note'] ?? '',
      isRefund: json['isRefund'] ?? false,
      userId: json['userId'] ?? 0,
      createdDate: DateTime.parse(json['createdDate']),
      createdBy: json['createdBy'] ?? '',
      image: json['image'] ?? '',
    );
  }

  factory Transport.empty() {
    return Transport(
      transportId: 0,
      orderId: 0,
      status: '',
      contactFailNumber: 0,
      note: '',
      isRefund: false,
      userId: 0,
      createdDate: DateTime.now(),
      createdBy: '',
      image: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transportId': transportId,
      'orderId': orderId,
      'status': status,
      'estimateCompletedDate': estimateCompletedDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'lastConfirmFailed': lastConfirmFailed?.toIso8601String(),
      'contactFailNumber': contactFailNumber,
      'note': note,
      'isRefund': isRefund,
      'userId': userId,
      'createdDate': createdDate.toIso8601String(),
      'createdBy': createdBy,
      'image': image,
    };
  }

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'inwarehouse':
        return 'Đang trong kho';
      case 'shipping':
        return 'Đang giao hàng';
      case 'completed':
        return 'Đã giao thành công';
      case 'failed':
        return 'Giao hàng thất bại';
      default:
        return status;
    }
  }

  bool get isActiveTransport {
    return ['inwarehouse', 'shipping'].contains(status.toLowerCase());
  }

  bool get isCompletedTransport {
    return ['completed', 'failed'].contains(status.toLowerCase());
  }
}
