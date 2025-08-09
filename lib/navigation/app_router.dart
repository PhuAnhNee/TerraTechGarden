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
import '../pages/terrarium-detail/screens/terrarium_detail_screen.dart';
import '../pages/ship/home/screens/shipper_home_screen.dart';
import '../pages/ship/home/bloc/ship_bloc.dart';
import '../pages/ship/home/bloc/ship_event.dart';
import '../pages/ship/delivery/screens/delivery_screen.dart';
import '../pages/cart/screens/cart_screen.dart';
import '../pages/cart/bloc/cart_bloc.dart';
import '../pages/cart/bloc/cart_event.dart';
import 'routes.dart';
import 'dart:developer' as developer;

Map<String, WidgetBuilder> getAppRoutes() {
  return {
    Routes.login: (context) => auth_screens.LoginScreen(),
    Routes.register: (context) => auth_screens.RegisterScreen(),
    Routes.home: (context) => BlocProvider(
          create: (context) =>
              CartBloc(storedToken: context.read<AuthBloc>().token),
          child: home_screens.HomeScreen(),
        ),
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
    Routes.terrarium: (context) => TerrariumScreen(),
    Routes.terrariumDetail: (context) {
      final authBloc = context.read<AuthBloc>();
      final token = authBloc.token;
      developer.log('TerrariumDetail CartBloc token: $token',
          name: 'AppRouter');
      return BlocProvider(
        create: (context) => CartBloc(storedToken: token),
        child: TerrariumDetailScreen(
          terrariumId: ModalRoute.of(context)!.settings.arguments as String,
        ),
      );
    },
    Routes.shipperHome: (context) {
      final authBloc = context.read<AuthBloc>();
      final token = authBloc.token;
      developer.log('ShipperHome ShipBloc token: $token', name: 'AppRouter');
      return BlocProvider(
        create: (context) => ShipBloc(token)..add(FetchOrders()),
        child: ShipperHomeScreen(token: token),
      );
    },
    Routes.delivery: (context) => DeliveryScreen(),
    Routes.cart: (context) {
      final authBloc = context.read<AuthBloc>();
      final token = authBloc.token;
      developer.log('CartBloc token: $token', name: 'AppRouter');
      return BlocProvider(
        create: (context) => CartBloc(storedToken: token)..add(FetchCart()),
        child: CartScreen(),
      );
    },
    Routes.error: (context) => const Scaffold(
          body: Center(
            child: Text(
              'Failed to initialize app. Please try again later.',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
          ),
        ),
  };
}
