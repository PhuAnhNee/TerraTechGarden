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
import '../pages/ship/delivery/screens/delivery_screen.dart';
import '../pages/cart/screens/cart_screen.dart';
import '../pages/cart/bloc/cart_bloc.dart';
import '../pages/cart/bloc/cart_event.dart';
import '../pages/notification/screens/notification_screen.dart';
import '../pages/cart/widgets/checkout_screen.dart';
import '../pages/chat/screens/chat_screen.dart';
import '../pages/chat/bloc/chat_bloc.dart';
import '../pages/order/screens/order_screen.dart';
import '../pages/order/bloc/order_bloc.dart';
import '../pages/order/bloc/order_event.dart';
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
    Routes.profile: (context) {
      final authBloc = context.read<AuthBloc>();
      final token = authBloc.token;
      developer.log('ProfileBloc token: $token', name: 'AppRouter');

      // Check if token exists
      if (token == null || token.isEmpty) {
        developer.log('No token found, redirecting to login',
            name: 'AppRouter');
        // If no token, redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return BlocProvider(
        create: (context) => ProfileBloc(),
        child: profile_screens.ProfileScreen(authToken: token),
      );
    },
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
    Routes.shipHome: (context) {
      final authBloc = context.read<AuthBloc>();
      final token = authBloc.token;
      developer.log('ShipHome ShipBloc token: $token', name: 'AppRouter');

      // Check if token exists
      if (token == null || token.isEmpty) {
        developer.log('No token found for ShipHome, redirecting to login',
            name: 'AppRouter');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return BlocProvider(
        create: (context) => ShipBloc(),
        child: ShipperHomeScreen(token: token),
      );
    },
    Routes.shipperHome: (context) {
      developer.log(
          'Using deprecated shipperHome route, redirecting to shipHome',
          name: 'AppRouter');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(Routes.shipHome);
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
    Routes.delivery: (context) {
      final authBloc = context.read<AuthBloc>();
      final token = authBloc.token;

      // Check if token exists
      if (token == null || token.isEmpty) {
        developer.log('No token found for delivery, redirecting to login',
            name: 'AppRouter');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return BlocProvider(
        create: (context) => ShipBloc(),
        child: DeliveryScreen(),
      );
    },
    Routes.cart: (context) {
      final authBloc = context.read<AuthBloc>();
      final token = authBloc.token;
      developer.log('CartBloc token: $token', name: 'AppRouter');
      return BlocProvider(
        create: (context) => CartBloc(storedToken: token)..add(FetchCart()),
        child: CartScreen(),
      );
    },
    Routes.checkout: (context) => CheckoutScreen(
          totalAmount:
              ModalRoute.of(context)!.settings.arguments as double? ?? 0.0,
        ),
    Routes.notification: (context) => NotificationScreen(
          userId: ModalRoute.of(context)!.settings.arguments as String,
        ),
    Routes.chat: (context) {
      final authBloc = context.read<AuthBloc>();
      final token = authBloc.token;
      developer.log('ChatScreen token: $token', name: 'AppRouter');

      return BlocProvider(
        create: (context) => ChatBloc(storedToken: token),
        child: ChatScreen(authToken: token),
      );
    },
    Routes.order: (context) {
      final authBloc = context.read<AuthBloc>();
      final token = authBloc.token;
      developer.log('OrderScreen token: $token', name: 'AppRouter');

      // Check if token exists
      if (token == null || token.isEmpty) {
        developer.log('No token found for orders, redirecting to login',
            name: 'AppRouter');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return BlocProvider(
        create: (context) => OrderBloc(storedToken: token)..add(LoadOrders()),
        child: const OrderScreen(),
      );
    },
  };
}
