import 'package:flutter/material.dart';
import '../../navigation/routes.dart';

class NotificationNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == Routes.notification) {
      // Add logic here to mark notifications as seen
    }
  }
}
