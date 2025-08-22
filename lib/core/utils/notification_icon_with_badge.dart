import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../pages/notification/bloc/notification_bloc.dart';
import '../../pages/notification/bloc/notification_state.dart';
import '../../navigation/routes.dart';
import '../../core/utils/auth_utils.dart'; // Added import

class NotificationIconWithBadge extends StatelessWidget {
  final VoidCallback? onTap;
  final String? userId;
  final double? iconSize;
  final Color? iconColor;

  const NotificationIconWithBadge({
    super.key,
    this.onTap,
    this.userId,
    this.iconSize,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;
        bool hasError = false;

        if (state is NotificationLoaded) {
          unreadCount = state.notifications.where((n) => !n.isRead).length;
        } else if (state is NotificationError) {
          hasError = true;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // IconButton(
            //   icon: Icon(
            //     hasError ? Icons.notifications_off : Icons.notifications,
            //     size: iconSize ?? 24,
            //     color: iconColor ?? (hasError ? Colors.red : null),
            //   ),
            //   onPressed: onTap ?? () => _navigateToNotifications(context),
            //   tooltip: hasError ? 'Lỗi thông báo' : 'Thông báo',
            // ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (hasError)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // void _navigateToNotifications(BuildContext context) {
  //   final currentUserId = userId ?? getCurrentUserIdFromContext(context);
  //   if (currentUserId != null) {
  //     Navigator.pushNamed(
  //       context,
  //       Routes.notification,
  //       arguments: currentUserId,
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Vui lòng đăng nhập để xem thông báo'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }
}
