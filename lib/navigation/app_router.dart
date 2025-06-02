import 'package:flutter/material.dart';
import '../pages/authentication/screens/login_screen.dart';
import '../pages/authentication/screens/register_screen.dart';
import '../pages/home/screens/home_screen.dart';
import 'routes.dart';

Map<String, WidgetBuilder> getAppRoutes() {
  return {
    Routes.login: (context) => LoginScreen(),
    Routes.register: (context) => RegisterScreen(),
    Routes.home: (context) => HomeScreen(),
  };
}
