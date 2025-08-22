// lib/pages/notification/extensions/notification_extensions.dart
import '../../../models/notification_model.dart';

// Add these enums if they don't exist in your notification component
enum NotificationPriority { high, medium, low }

enum NotificationType { order, payment, delivery, promotion, system, general }

extension NotificationModelExtensions on NotificationModel {
  /// Returns true if notification is recent (within last 24 hours)
  bool get isRecent {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    return difference.inHours < 24;
  }

  /// Returns true if notification is very recent (within last hour)
  bool get isVeryRecent {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    return difference.inHours < 1;
  }

  /// Returns true if notification is from today
  bool get isToday {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final createdDate = createdAt!;
    return now.year == createdDate.year &&
        now.month == createdDate.month &&
        now.day == createdDate.day;
  }

  /// Returns true if notification is from yesterday
  bool get isYesterday {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final createdDate = createdAt!;
    return yesterday.year == createdDate.year &&
        yesterday.month == createdDate.month &&
        yesterday.day == createdDate.day;
  }

  /// Returns formatted time string
  String get formattedTime {
    if (createdAt == null) return 'Không rõ thời gian';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    final createdDate = createdAt!;

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24 && isToday) {
      return '${difference.inHours} giờ trước';
    } else if (isYesterday) {
      return 'Hôm qua lúc ${_formatTime(createdDate)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${createdDate.day}/${createdDate.month}/${createdDate.year}';
    }
  }

  /// Returns short formatted time (for lists)
  String get shortFormattedTime {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    final createdDate = createdAt!;

    if (difference.inMinutes < 1) {
      return 'vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}p';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${createdDate.day}/${createdDate.month}';
    }
  }

  /// Returns notification priority based on keywords and content analysis
  NotificationPriority get priority {
    final titleLower = title.toLowerCase();
    final messageLower = message.toLowerCase();
    final combinedText = '$titleLower $messageLower';

    // High priority keywords
    final highPriorityKeywords = [
      'urgent',
      'khẩn cấp',
      'quan trọng',
      'cảnh báo',
      'warning',
      'alert',
      'lỗi',
      'error',
      'failed',
      'thất bại',
      'cancelled',
      'hủy',
      'hủy bỏ',
      'refund',
      'hoàn tiền',
      'problem',
      'vấn đề',
      'issue',
      'critical',
      'emergency',
      'immediately',
      'ngay lập tức',
      'gấp',
      'security',
      'bảo mật',
      'fraud',
      'lừa đảo',
      'suspicious',
      'đáng nghi'
    ];

    // Medium priority keywords
    final mediumPriorityKeywords = [
      'order',
      'đơn hàng',
      'payment',
      'thanh toán',
      'invoice',
      'hóa đơn',
      'delivery',
      'giao hàng',
      'shipped',
      'đã gửi',
      'tracking',
      'theo dõi',
      'update',
      'cập nhật',
      'change',
      'thay đổi',
      'modified',
      'sửa đổi',
      'reminder',
      'nhắc nhở',
      'due',
      'đến hạn',
      'expires',
      'hết hạn',
      'confirm',
      'xác nhận',
      'verify',
      'xác minh',
      'action required',
      'cần hành động',
      'review',
      'đánh giá'
    ];

    // Check for high priority first
    for (final keyword in highPriorityKeywords) {
      if (combinedText.contains(keyword)) {
        return NotificationPriority.high;
      }
    }

    // Check for medium priority
    for (final keyword in mediumPriorityKeywords) {
      if (combinedText.contains(keyword)) {
        return NotificationPriority.medium;
      }
    }

    // Additional context-based priority detection
    if (_containsNumbers(title) || _containsNumbers(message)) {
      return NotificationPriority.medium; // Usually order IDs, amounts, etc.
    }

    return NotificationPriority.low;
  }

  /// Returns notification type based on content analysis
  NotificationType get type {
    final titleLower = title.toLowerCase();
    final messageLower = message.toLowerCase();
    final combinedText = '$titleLower $messageLower';

    // Order-related keywords
    final orderKeywords = [
      'order',
      'đơn hàng',
      'purchase',
      'mua hàng',
      'checkout',
      'thanh toán',
      'cart',
      'giỏ hàng',
      'buy',
      'mua',
      'sold',
      'bán',
      'invoice',
      'hóa đơn'
    ];

    // Payment-related keywords
    final paymentKeywords = [
      'payment',
      'thanh toán',
      'paid',
      'đã thanh toán',
      'charge',
      'phí',
      'refund',
      'hoàn tiền',
      'transaction',
      'giao dịch',
      'balance',
      'số dư',
      'wallet',
      'ví',
      'bank',
      'ngân hàng',
      'card',
      'thẻ',
      'money',
      'tiền'
    ];

    // Delivery-related keywords
    final deliveryKeywords = [
      'delivery',
      'giao hàng',
      'shipped',
      'đã gửi',
      'tracking',
      'theo dõi',
      'package',
      'gói hàng',
      'courier',
      'người giao hàng',
      'address',
      'địa chỉ',
      'location',
      'vị trí',
      'arrived',
      'đã đến',
      'delivered',
      'đã giao'
    ];

    // Promotion-related keywords
    final promotionKeywords = [
      'promotion',
      'khuyến mãi',
      'discount',
      'giảm giá',
      'sale',
      'ưu đãi',
      'offer',
      'deal',
      'coupon',
      'mã giảm giá',
      'voucher',
      'free',
      'miễn phí',
      'bonus',
      'thưởng',
      'reward',
      'phần thưởng',
      'special',
      'đặc biệt'
    ];

    // System/Account-related keywords
    final systemKeywords = [
      'account',
      'tài khoản',
      'profile',
      'hồ sơ',
      'settings',
      'cài đặt',
      'password',
      'mật khẩu',
      'login',
      'đăng nhập',
      'logout',
      'đăng xuất',
      'security',
      'bảo mật',
      'update',
      'cập nhật',
      'maintenance',
      'bảo trì'
    ];

    // Check each type
    if (_containsAnyKeyword(combinedText, orderKeywords)) {
      return NotificationType.order;
    } else if (_containsAnyKeyword(combinedText, paymentKeywords)) {
      return NotificationType.payment;
    } else if (_containsAnyKeyword(combinedText, deliveryKeywords)) {
      return NotificationType.delivery;
    } else if (_containsAnyKeyword(combinedText, promotionKeywords)) {
      return NotificationType.promotion;
    } else if (_containsAnyKeyword(combinedText, systemKeywords)) {
      return NotificationType.system;
    }

    return NotificationType.general;
  }

  /// Returns appropriate icon for the notification
  String get iconAsset {
    switch (type) {
      case NotificationType.order:
        return 'assets/icons/order.png';
      case NotificationType.payment:
        return 'assets/icons/payment.png';
      case NotificationType.delivery:
        return 'assets/icons/delivery.png';
      case NotificationType.promotion:
        return 'assets/icons/promotion.png';
      case NotificationType.system:
        return 'assets/icons/system.png';
      default:
        return 'assets/icons/notification.png';
    }
  }

  /// Returns appropriate Material icon for the notification
  String get materialIcon {
    switch (type) {
      case NotificationType.order:
        return 'shopping_cart';
      case NotificationType.payment:
        return 'payment';
      case NotificationType.delivery:
        return 'local_shipping';
      case NotificationType.promotion:
        return 'local_offer';
      case NotificationType.system:
        return 'settings';
      default:
        return 'notifications';
    }
  }

  /// Returns color associated with the notification type
  int get typeColor {
    switch (type) {
      case NotificationType.order:
        return 0xFF2196F3; // Blue
      case NotificationType.payment:
        return 0xFF4CAF50; // Green
      case NotificationType.delivery:
        return 0xFF9C27B0; // Purple
      case NotificationType.promotion:
        return 0xFFE91E63; // Pink
      case NotificationType.system:
        return 0xFF607D8B; // Blue Grey
      default:
        return 0xFF757575; // Grey
    }
  }

  /// Returns color associated with the notification priority
  int get priorityColor {
    switch (priority) {
      case NotificationPriority.high:
        return 0xFFD32F2F; // Red
      case NotificationPriority.medium:
        return 0xFFFF9800; // Orange
      default:
        return 0xFF757575; // Grey
    }
  }

  /// Returns summary text for the notification
  String get summary {
    final words = message.split(' ');
    if (words.length <= 10) return message;
    return '${words.take(10).join(' ')}...';
  }

  /// Returns true if this notification should show a badge
  bool get shouldShowBadge {
    return !isRead || priority == NotificationPriority.high;
  }

  /// Returns the age of notification in a readable format
  String get ageDescription {
    if (createdAt == null) return 'Không rõ';

    final age = DateTime.now().difference(createdAt!);

    if (age.inDays > 30) {
      return 'Cũ (${(age.inDays / 30).floor()} tháng)';
    } else if (age.inDays > 7) {
      return 'Cũ (${(age.inDays / 7).floor()} tuần)';
    } else if (age.inDays > 0) {
      return 'Gần đây';
    } else {
      return 'Mới';
    }
  }

  // Helper methods
  bool _containsNumbers(String text) {
    return RegExp(r'\d').hasMatch(text);
  }

  bool _containsAnyKeyword(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

extension NotificationListExtensions on List<NotificationModel> {
  /// Returns only unread notifications
  List<NotificationModel> get unread => where((n) => !n.isRead).toList();

  /// Returns only read notifications
  List<NotificationModel> get read => where((n) => n.isRead).toList();

  /// Returns recent notifications (within last 24 hours)
  List<NotificationModel> get recent => where((n) => n.isRecent).toList();

  /// Returns today's notifications
  List<NotificationModel> get today => where((n) => n.isToday).toList();

  /// Returns yesterday's notifications
  List<NotificationModel> get yesterday => where((n) => n.isYesterday).toList();

  /// Returns notifications by priority
  List<NotificationModel> byPriority(NotificationPriority priority) =>
      where((n) => n.priority == priority).toList();

  /// Returns notifications by type
  List<NotificationModel> byType(NotificationType type) =>
      where((n) => n.type == type).toList();

  /// Returns high priority notifications
  List<NotificationModel> get highPriority =>
      byPriority(NotificationPriority.high);

  /// Returns medium priority notifications
  List<NotificationModel> get mediumPriority =>
      byPriority(NotificationPriority.medium);

  /// Returns low priority notifications
  List<NotificationModel> get lowPriority =>
      byPriority(NotificationPriority.low);

  /// Returns sorted notifications (newest first)
  List<NotificationModel> get sorted {
    final sortedList = List<NotificationModel>.from(this);
    sortedList.sort((a, b) {
      // First sort by read status (unread first)
      if (a.isRead != b.isRead) {
        return a.isRead ? 1 : -1;
      }

      // Then by priority (high first)
      final priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) return priorityComparison;

      // Finally by date (newest first)
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return sortedList;
  }

  /// Returns notifications grouped by date
  Map<String, List<NotificationModel>> get groupedByDate {
    final Map<String, List<NotificationModel>> grouped = {};
    final now = DateTime.now();

    for (final notification in this) {
      String dateKey;

      if (notification.createdAt == null) {
        dateKey = 'Không rõ ngày';
      } else {
        final createdDate = notification.createdAt!;

        if (notification.isToday) {
          dateKey = 'Hôm nay';
        } else if (notification.isYesterday) {
          dateKey = 'Hôm qua';
        } else {
          final difference = now.difference(createdDate).inDays;
          if (difference < 7) {
            dateKey = '$difference ngày trước';
          } else if (difference < 30) {
            final weeks = (difference / 7).floor();
            dateKey = '$weeks tuần trước';
          } else {
            final months = (difference / 30).floor();
            dateKey = '$months tháng trước';
          }
        }
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notification);
    }

    // Sort notifications within each group
    for (final key in grouped.keys) {
      grouped[key] = grouped[key]!.sorted;
    }

    return grouped;
  }

  /// Returns notifications grouped by type
  Map<NotificationType, List<NotificationModel>> get groupedByType {
    final Map<NotificationType, List<NotificationModel>> grouped = {};

    for (final notification in this) {
      final type = notification.type;
      if (!grouped.containsKey(type)) {
        grouped[type] = [];
      }
      grouped[type]!.add(notification);
    }

    // Sort notifications within each group
    for (final key in grouped.keys) {
      grouped[key] = grouped[key]!.sorted;
    }

    return grouped;
  }

  /// Returns notifications grouped by priority
  Map<NotificationPriority, List<NotificationModel>> get groupedByPriority {
    final Map<NotificationPriority, List<NotificationModel>> grouped = {};

    for (final notification in this) {
      final priority = notification.priority;
      if (!grouped.containsKey(priority)) {
        grouped[priority] = [];
      }
      grouped[priority]!.add(notification);
    }

    // Sort notifications within each group
    for (final key in grouped.keys) {
      grouped[key] = grouped[key]!.sorted;
    }

    return grouped;
  }

  /// Returns statistics about notifications
  NotificationStats get stats {
    return NotificationStats(
      total: length,
      unreadCount: unread.length,
      readCount: read.length,
      todayCount: today.length,
      yesterdayCount: yesterday.length,
      recentCount: recent.length,
      highPriorityCount: highPriority.length,
      mediumPriorityCount: mediumPriority.length,
      lowPriorityCount: lowPriority.length,
      typeStats: _getTypeStats(),
    );
  }

  Map<NotificationType, int> _getTypeStats() {
    final Map<NotificationType, int> stats = {};
    for (final notification in this) {
      final type = notification.type;
      stats[type] = (stats[type] ?? 0) + 1;
    }
    return stats;
  }

  /// Filters notifications by date range
  List<NotificationModel> filterByDateRange(DateTime start, DateTime end) {
    return where((notification) {
      if (notification.createdAt == null) return false;
      return notification.createdAt!.isAfter(start) &&
          notification.createdAt!.isBefore(end);
    }).toList();
  }

  /// Filters notifications by keyword search
  List<NotificationModel> search(String keyword) {
    if (keyword.isEmpty) return this;

    final searchTerm = keyword.toLowerCase();
    return where((notification) {
      return notification.title.toLowerCase().contains(searchTerm) ||
          notification.message.toLowerCase().contains(searchTerm);
    }).toList();
  }

  /// Returns the most recent notification
  NotificationModel? get mostRecent {
    if (isEmpty) return null;
    return sorted.first;
  }

  /// Returns the oldest notification
  NotificationModel? get oldest {
    if (isEmpty) return null;
    return sorted.last;
  }
}

/// Statistics class for notification analytics
class NotificationStats {
  final int total;
  final int unreadCount;
  final int readCount;
  final int todayCount;
  final int yesterdayCount;
  final int recentCount;
  final int highPriorityCount;
  final int mediumPriorityCount;
  final int lowPriorityCount;
  final Map<NotificationType, int> typeStats;

  const NotificationStats({
    required this.total,
    required this.unreadCount,
    required this.readCount,
    required this.todayCount,
    required this.yesterdayCount,
    required this.recentCount,
    required this.highPriorityCount,
    required this.mediumPriorityCount,
    required this.lowPriorityCount,
    required this.typeStats,
  });

  double get readPercentage => total > 0 ? (readCount / total) * 100 : 0;
  double get unreadPercentage => total > 0 ? (unreadCount / total) * 100 : 0;
  double get highPriorityPercentage =>
      total > 0 ? (highPriorityCount / total) * 100 : 0;

  @override
  String toString() {
    return 'NotificationStats(total: $total, unread: $unreadCount, read: $readCount)';
  }
}
