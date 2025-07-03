import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../pages/authentication/screens/login_screen.dart';
import '../pages/authentication/screens/register_screen.dart';
import '../pages/home/screens/home_screen.dart';
import '../pages/profile/screens/profile_screen.dart';
import '../pages/profile/bloc/profile_bloc.dart';
import 'routes.dart';

Map<String, WidgetBuilder> getAppRoutes() {
  return {
    Routes.login: (context) => LoginScreen(),
    Routes.register: (context) => RegisterScreen(),
    Routes.home: (context) => HomeScreen(),
    Routes.profile: (context) => BlocProvider(
          create: (context) => ProfileBloc(),
          child: ProfileScreen(),
        ),
  };
}
