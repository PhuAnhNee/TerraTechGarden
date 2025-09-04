class Transport {
  final int transportId;
  final int orderId;
  final int? userId;
  final String status;
  final DateTime? createdAt;
  final DateTime? estimatedDelivery;
  final String? reason;
  final String? imagePath;
  final int? assignToUserId;
  final int? contactFailNumber;
  final String? note;
  final DateTime? completedAt;
  final String? failureReason;
  final DateTime? lastConfirmFailed;
  final bool? isRefund;
  final DateTime? createdDate;
  final String? createdBy;

  Transport({
    required this.transportId,
    required this.orderId,
    this.userId,
    required this.status,
    this.createdAt,
    this.estimatedDelivery,
    this.reason,
    this.imagePath,
    this.assignToUserId,
    this.contactFailNumber,
    this.note,
    this.completedAt,
    this.failureReason,
    this.lastConfirmFailed,
    this.isRefund,
    this.createdDate,
    this.createdBy,
  });

  factory Transport.fromJson(Map<String, dynamic> json) {
    return Transport(
      transportId: json['transportId'] ?? 0,
      orderId: json['orderId'] ?? 0,
      userId: json['userId'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['createdDate'] != null
              ? DateTime.parse(json['createdDate'])
              : null),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : (json['estimateCompletedDate'] != null
              ? DateTime.parse(json['estimateCompletedDate'])
              : null),
      reason: json['reason'],
      // Fix: Check for both 'image' and 'imagePath' fields
      imagePath: json['image'] ?? json['imagePath'],
      assignToUserId: json['assignToUserId'],
      contactFailNumber: json['contactFailNumber'] ?? 0,
      note: json['note'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : (json['completedDate'] != null
              ? DateTime.parse(json['completedDate'])
              : null),
      failureReason: json['failureReason'] ?? json['reason'],
      lastConfirmFailed: json['lastConfirmFailed'] != null
          ? DateTime.parse(json['lastConfirmFailed'])
          : null,
      isRefund: json['isRefund'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
      createdBy: json['createdBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transportId': transportId,
      'orderId': orderId,
      'userId': userId,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'reason': reason,
      'imagePath': imagePath,
      'assignToUserId': assignToUserId,
      'contactFailNumber': contactFailNumber,
      'note': note,
      'completedAt': completedAt?.toIso8601String(),
      'failureReason': failureReason,
      'lastConfirmFailed': lastConfirmFailed?.toIso8601String(),
      'isRefund': isRefund,
      'createdDate': createdDate?.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  Transport copyWith({
    int? transportId,
    int? orderId,
    int? userId,
    String? status,
    DateTime? createdAt,
    DateTime? estimatedDelivery,
    String? reason,
    String? imagePath,
    int? assignToUserId,
    int? contactFailNumber,
    String? note,
    DateTime? completedAt,
    String? failureReason,
    DateTime? lastConfirmFailed,
    bool? isRefund,
    DateTime? createdDate,
    String? createdBy,
  }) {
    return Transport(
      transportId: transportId ?? this.transportId,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      reason: reason ?? this.reason,
      imagePath: imagePath ?? this.imagePath,
      assignToUserId: assignToUserId ?? this.assignToUserId,
      contactFailNumber: contactFailNumber ?? this.contactFailNumber,
      note: note ?? this.note,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      lastConfirmFailed: lastConfirmFailed ?? this.lastConfirmFailed,
      isRefund: isRefund ?? this.isRefund,
      createdDate: createdDate ?? this.createdDate,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
