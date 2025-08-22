// lib/pages/notification/screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_state.dart';
import '../../../models/notification_model.dart';
import '../widgets/in_app_notification.dart';
import '../widgets/notification_extensions.dart';

class NotificationScreen extends StatefulWidget {
  final String userId;
  const NotificationScreen({super.key, required this.userId});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);

    // Start polling when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  void _initializeNotifications() {
    if (!_isInitialized && mounted) {
      context.read<NotificationBloc>().startPolling(widget.userId);
      _isInitialized = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    final bloc = context.read<NotificationBloc>();
    if (state == AppLifecycleState.paused) {
      bloc.stopPolling();
    } else if (state == AppLifecycleState.resumed) {
      bloc.startPolling(widget.userId);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    if (mounted) {
      context.read<NotificationBloc>().stopPolling();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Thông báo'),
            const SizedBox(width: 8),
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded && state.unreadCount > 0) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1D7020),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshNotifications(),
            tooltip: 'Làm mới',
          ),
          _buildActionMenu(),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chưa đọc'),
            Tab(text: 'Quan trọng'),
          ],
        ),
      ),
      body: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          // Show in-app notification when new notification arrives
          if (state is InAppNotificationShown) {
            InAppNotificationService.show(
              context,
              title: state.title,
              message: state.message,
              onTap: () {
                // Refresh notifications when tapped
                _refreshNotifications();
              },
            );
          } else if (state is NotificationError) {
            _showErrorSnackBar(state.message);
          }
        },
        child: RefreshIndicator(
          onRefresh: _refreshNotifications,
          color: const Color(0xFF1D7020),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllNotificationsTab(),
              _buildUnreadNotificationsTab(),
              _buildImportantNotificationsTab(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateNotificationDialog(),
        backgroundColor: const Color(0xFF1D7020),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActionMenu() {
    return PopupMenuButton<String>(
      onSelected: _handleMenuAction,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'mark_all_read',
          child: Row(
            children: [
              Icon(Icons.done_all, size: 20),
              SizedBox(width: 8),
              Text('Đánh dấu tất cả đã đọc'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete_all_read',
          child: Row(
            children: [
              Icon(Icons.clear_all, size: 20, color: Colors.orange),
              SizedBox(width: 8),
              Text('Xóa thông báo đã đọc',
                  style: TextStyle(color: Colors.orange)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete_all',
          child: Row(
            children: [
              Icon(Icons.delete_sweep, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Xóa tất cả', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: const Icon(Icons.more_vert),
    );
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'mark_all_read':
        _markAllAsRead();
        break;
      case 'delete_all_read':
        _showDeleteReadDialog();
        break;
      case 'delete_all':
        _showDeleteAllDialog();
        break;
    }
  }

  Widget _buildAllNotificationsTab() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is NotificationLoaded) {
          if (state.notifications.isEmpty) {
            return _buildEmptyState();
          }
          return _buildNotificationList(state.notifications.sorted);
        } else if (state is NotificationError) {
          return _buildErrorState(state.message);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildUnreadNotificationsTab() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is NotificationLoaded) {
          final unreadNotifications = state.notifications.unread.sorted;
          if (unreadNotifications.isEmpty) {
            return _buildEmptyState(
              icon: Icons.mark_email_read,
              title: 'Không có thông báo chưa đọc',
              subtitle: 'Tuyệt vời! Bạn đã đọc hết thông báo.',
            );
          }
          return _buildNotificationList(unreadNotifications);
        } else if (state is NotificationError) {
          return _buildErrorState(state.message);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildImportantNotificationsTab() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is NotificationLoaded) {
          final importantNotifications =
              state.notifications.byPriority(NotificationPriority.high).sorted;
          if (importantNotifications.isEmpty) {
            return _buildEmptyState(
              icon: Icons.priority_high,
              title: 'Không có thông báo quan trọng',
              subtitle: 'Các thông báo quan trọng sẽ xuất hiện ở đây.',
            );
          }
          return _buildNotificationList(importantNotifications);
        } else if (state is NotificationError) {
          return _buildErrorState(state.message);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    final groupedNotifications = notifications.groupedByDate;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedNotifications.length,
      itemBuilder: (context, index) {
        final dateKey = groupedNotifications.keys.elementAt(index);
        final notificationsForDate = groupedNotifications[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                dateKey,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            // Notifications for this date
            ...notificationsForDate
                .map((notification) => _buildNotificationCard(notification)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final priority = notification.priority;
    final type = notification.type;

    return Card(
      elevation: notification.isRead ? 1 : 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: notification.isRead ? null : const Color(0xFFF0F8FF),
      child: InkWell(
        onTap: () => _onNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: priority == NotificationPriority.high
                ? Border.all(color: Colors.red.withOpacity(0.3), width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(notification),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNotificationContent(notification),
                ),
                _buildNotificationMenu(notification),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationModel notification) {
    final isRecent = notification.isVeryRecent;
    final priority = notification.priority;

    Color backgroundColor;
    Color iconColor;
    IconData iconData;

    if (!notification.isRead) {
      backgroundColor = const Color(0xFF1D7020).withOpacity(0.1);
      iconColor = const Color(0xFF1D7020);
      iconData = Icons.notifications_active;
    } else {
      backgroundColor = Colors.grey.withOpacity(0.1);
      iconColor = Colors.grey;
      iconData = Icons.notifications;
    }

    // Override colors for high priority
    if (priority == NotificationPriority.high) {
      backgroundColor = Colors.red.withOpacity(0.1);
      iconColor = Colors.red;
      iconData = Icons.priority_high;
    }

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            iconData,
            color: iconColor,
            size: 20,
          ),
        ),
        if (isRecent && !notification.isRead)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationContent(NotificationModel notification) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
            color: const Color(0xFF2D3748),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          notification.message,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              notification.formattedTime,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(width: 8),
            _buildPriorityChip(notification.priority),
            const SizedBox(width: 8),
            _buildTypeChip(notification.type),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityChip(NotificationPriority priority) {
    if (priority == NotificationPriority.low) return const SizedBox.shrink();

    Color color;
    String text;

    switch (priority) {
      case NotificationPriority.high:
        color = Colors.red;
        text = 'Quan trọng';
        break;
      case NotificationPriority.medium:
        color = Colors.orange;
        text = 'Trung bình';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTypeChip(NotificationType type) {
    Color color;
    String text;
    IconData icon;

    switch (type) {
      case NotificationType.order:
        color = Colors.blue;
        text = 'Đơn hàng';
        icon = Icons.shopping_cart;
        break;
      case NotificationType.payment:
        color = Colors.green;
        text = 'Thanh toán';
        icon = Icons.payment;
        break;
      case NotificationType.delivery:
        color = Colors.purple;
        text = 'Giao hàng';
        icon = Icons.local_shipping;
        break;
      case NotificationType.promotion:
        color = Colors.pink;
        text = 'Khuyến mãi';
        icon = Icons.local_offer;
        break;
      default:
        color = Colors.grey;
        text = 'Chung';
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationMenu(NotificationModel notification) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleNotificationAction(value, notification),
      itemBuilder: (context) => [
        if (!notification.isRead)
          const PopupMenuItem(
            value: 'mark_read',
            child: Row(
              children: [
                Icon(Icons.done, size: 20),
                SizedBox(width: 8),
                Text('Đánh dấu đã đọc'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Xóa', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Icon(
        Icons.more_vert,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildEmptyState({
    IconData? icon,
    String? title,
    String? subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title ?? 'Không có thông báo nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle ?? 'Các thông báo mới sẽ xuất hiện ở đây',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Đã có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D7020),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _onNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      context.read<NotificationBloc>().markAsRead(notification.id);
    }

    // You can add navigation logic here based on notification type
    // For example: navigate to order details, payment screen, etc.
  }

  void _handleNotificationAction(
      String action, NotificationModel notification) {
    switch (action) {
      case 'mark_read':
        context.read<NotificationBloc>().markAsRead(notification.id);
        break;
      case 'delete':
        _showDeleteConfirmDialog(notification);
        break;
    }
  }

  Future<void> _refreshNotifications() async {
    context.read<NotificationBloc>().fetchNotifications(widget.userId);
  }

  void _markAllAsRead() {
    final bloc = context.read<NotificationBloc>();
    if (bloc.state is NotificationLoaded) {
      final notifications = (bloc.state as NotificationLoaded).notifications;
      for (final notification in notifications) {
        if (!notification.isRead) {
          bloc.markAsRead(notification.id);
        }
      }
    }
    _showSuccessSnackBar('Đã đánh dấu tất cả thông báo là đã đọc');
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả thông báo'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả thông báo không? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllNotifications();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }

  void _showDeleteReadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thông báo đã đọc'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả thông báo đã đọc không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReadNotifications();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Xóa đã đọc'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thông báo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn có chắc chắn muốn xóa thông báo này không?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                notification.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<NotificationBloc>()
                  .deleteNotification(notification.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _deleteAllNotifications() {
    final bloc = context.read<NotificationBloc>();
    if (bloc.state is NotificationLoaded) {
      final notifications = (bloc.state as NotificationLoaded).notifications;
      for (final notification in notifications) {
        bloc.deleteNotification(notification.id);
      }
    }
    _showSuccessSnackBar('Đã xóa tất cả thông báo');
  }

  void _deleteReadNotifications() {
    final bloc = context.read<NotificationBloc>();
    if (bloc.state is NotificationLoaded) {
      final notifications = (bloc.state as NotificationLoaded).notifications;
      final readNotifications = notifications.where((n) => n.isRead);
      for (final notification in readNotifications) {
        bloc.deleteNotification(notification.id);
      }
    }
    _showSuccessSnackBar('Đã xóa các thông báo đã đọc');
  }

  void _showCreateNotificationDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo thông báo mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Nội dung',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty &&
                  messageController.text.trim().isNotEmpty) {
                context.read<NotificationBloc>().createNotification(
                      widget.userId,
                      titleController.text.trim(),
                      messageController.text.trim(),
                    );
                Navigator.pop(context);
                _showSuccessSnackBar('Đã tạo thông báo mới');
              } else {
                _showErrorSnackBar('Vui lòng nhập đầy đủ thông tin');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D7020),
            ),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1D7020),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
