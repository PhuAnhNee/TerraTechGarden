// utils/notification_helper.dart
import 'package:flutter/material.dart';
import 'dart:async';

class NotificationHelper {
  static void showNotification(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    bool showAction = false,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;

    switch (type) {
      case NotificationType.success:
        backgroundColor = Colors.green.shade600;
        icon = Icons.check_circle;
        break;
      case NotificationType.error:
        backgroundColor = Colors.red.shade600;
        icon = Icons.error;
        break;
      case NotificationType.warning:
        backgroundColor = Colors.orange.shade600;
        icon = Icons.warning;
        break;
      case NotificationType.info:
        backgroundColor = Colors.blue.shade600;
        icon = Icons.info;
        break;
      case NotificationType.loading:
        backgroundColor = Colors.grey.shade700;
        icon = Icons.hourglass_empty;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: textColor,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.all(16),
      action: showAction && actionLabel != null && onActionTap != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: textColor,
              onPressed: onActionTap,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Specific notification methods for common shipping actions
  static void showOrderAccepted(BuildContext context, String orderId) {
    showNotification(
      context,
      message: 'Đã nhận đơn hàng #$orderId thành công',
      type: NotificationType.success,
    );
  }

  static void showTransportCreated(BuildContext context, String transportId) {
    showNotification(
      context,
      message: 'Đã tạo vận đơn #$transportId thành công',
      type: NotificationType.success,
    );
  }

  static void showOrderStarted(BuildContext context, String orderId) {
    showNotification(
      context,
      message: 'Đã bắt đầu chạy đơn hàng #$orderId',
      type: NotificationType.info,
    );
  }

  static void showImageCaptured(BuildContext context) {
    showNotification(
      context,
      message: 'Đã chụp ảnh xác nhận thành công',
      type: NotificationType.success,
    );
  }

  static void showOrderCompleted(BuildContext context, String orderId) {
    showNotification(
      context,
      message: 'Đã hoàn thành đơn hàng #$orderId',
      type: NotificationType.success,
    );
  }

  static void showOrderCancelled(BuildContext context, String orderId) {
    showNotification(
      context,
      message: 'Đã hủy đơn hàng #$orderId',
      type: NotificationType.warning,
    );
  }

  static void showNavigationStarted(BuildContext context) {
    showNotification(
      context,
      message: 'Đang dẫn đường đến vị trí khách hàng',
      type: NotificationType.info,
    );
  }

  static void showLocationError(BuildContext context) {
    showNotification(
      context,
      message: 'Không thể xác định vị trí. Vui lòng kiểm tra GPS',
      type: NotificationType.error,
      duration: Duration(seconds: 5),
    );
  }

  static void showPhoneCallAttempt(BuildContext context) {
    showNotification(
      context,
      message: 'Đang thực hiện cuộc gọi...',
      type: NotificationType.info,
    );
  }

  static void showLoadingData(BuildContext context, String message) {
    showNotification(
      context,
      message: message,
      type: NotificationType.loading,
      duration: Duration(seconds: 2),
    );
  }

  static void showNetworkError(BuildContext context) {
    showNotification(
      context,
      message: 'Lỗi kết nối mạng. Vui lòng thử lại',
      type: NotificationType.error,
      duration: Duration(seconds: 4),
      showAction: true,
      actionLabel: 'Thử lại',
      onActionTap: () {
        // This will be handled by the calling widget
      },
    );
  }

  static void showSyncSuccess(BuildContext context) {
    showNotification(
      context,
      message: 'Đã đồng bộ dữ liệu thành công',
      type: NotificationType.success,
    );
  }

  static void showUpdateStatusSuccess(BuildContext context, String status) {
    String message;
    switch (status) {
      case 'shipping':
        message = 'Đã cập nhật trạng thái: Đang giao hàng';
        break;
      case 'completed':
        message = 'Đã cập nhật trạng thái: Hoàn thành';
        break;
      case 'failed':
        message = 'Đã cập nhật trạng thái: Hủy đơn';
        break;
      default:
        message = 'Đã cập nhật trạng thái thành công';
    }

    showNotification(
      context,
      message: message,
      type: NotificationType.success,
    );
  }

  // Top notification overlay (for more prominent notifications)
  static void showTopNotification(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case NotificationType.success:
        backgroundColor = Colors.green.shade600;
        icon = Icons.check_circle;
        break;
      case NotificationType.error:
        backgroundColor = Colors.red.shade600;
        icon = Icons.error;
        break;
      case NotificationType.warning:
        backgroundColor = Colors.orange.shade600;
        icon = Icons.warning;
        break;
      case NotificationType.info:
        backgroundColor = Colors.blue.shade600;
        icon = Icons.info;
        break;
      case NotificationType.loading:
        backgroundColor = Colors.grey.shade700;
        icon = Icons.hourglass_empty;
        break;
    }

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => TopNotificationWidget(
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto remove after duration
    Timer(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

enum NotificationType {
  success,
  error,
  warning,
  info,
  loading,
}

class TopNotificationWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onDismiss;

  const TopNotificationWidget({
    Key? key,
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.onDismiss,
  }) : super(key: key);

  @override
  _TopNotificationWidgetState createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 16,
              right: 16,
            ),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
