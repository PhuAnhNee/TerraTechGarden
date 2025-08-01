import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../pages/authentication/screens/login_screen.dart' as auth_screens;
import '../pages/authentication/screens/register_screen.dart' as auth_screens;
import '../pages/home/screens/home_screen.dart' as home_screens;
import '../pages/profile/screens/profile_screen.dart' as profile_screens;
import '../pages/profile/bloc/profile_bloc.dart';
import '../pages/category/screens/category_screen.dart' as category_screens;
import '../pages/category/bloc/category_bloc.dart';
import '../pages/authentication/bloc/auth_bloc.dart';
import '../pages/blog/screens/blog_screen.dart';
import '../pages/accessory/screens/accessory_screen.dart';
import '../pages/terrarium/screens/terrarium_screen.dart';
import '../pages/ship/home/screens/shipperHome_screen.dart';
import '../pages/ship/delivery/screens/delivery_screen.dart';
import 'routes.dart';

Map<String, WidgetBuilder> getAppRoutes() {
  return {
    Routes.login: (context) => auth_screens.LoginScreen(),
    Routes.register: (context) => auth_screens.RegisterScreen(),
    Routes.home: (context) => home_screens.HomeScreen(),
    Routes.profile: (context) => BlocProvider(
          create: (context) => ProfileBloc(),
          child: profile_screens.ProfileScreen(),
        ),
    Routes.categories: (context) => BlocProvider(
          create: (context) => CategoryBloc(authBloc: context.read<AuthBloc>()),
          child: category_screens.CategoryScreen(),
        ),
    Routes.blog: (context) => BlogScreen(),
    Routes.accessory: (context) => AccessoryScreen(),
    Routes.terrarium: (context) =>
        TerrariumScreen(), // No local provider needed
    Routes.shipperHome: (context) => ShipperHomeScreen(),
    Routes.delivery: (context) => DeliveryScreen(),
  };
}
