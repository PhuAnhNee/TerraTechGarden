import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'navigation/routes.dart';
import 'navigation/app_router.dart';
import 'pages/authentication/bloc/auth_bloc.dart';
import 'pages/authentication/bloc/auth_state.dart';
import 'pages/terrarium/bloc/terrarium_bloc.dart';
import 'pages/accessory/bloc/accessory_bloc.dart';
import 'pages/blog/bloc/blog_bloc.dart';
import 'pages/cart/bloc/cart_bloc.dart';
import 'pages/ship/home/bloc/ship_bloc.dart'; // Updated import path
import 'pages/notification/bloc/notification_bloc.dart';
import 'pages/notification/widgets/notification_provider.dart';
import 'core/utils/auth_utils.dart';
import 'pages/order/bloc/order_bloc.dart';
import 'core/utils/firebase_messaging_setup.dart';
import 'core/utils/notification_navigator_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  final storedToken = await getStoredToken();
  final storedUserId = await getStoredUserId();

  runApp(MyApp(
    storedToken: storedToken,
    storedUserId: storedUserId,
  ));
}

class MyApp extends StatelessWidget {
  final String? storedToken;
  final String? storedUserId;

  const MyApp({
    super.key,
    this.storedToken,
    this.storedUserId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => TerrariumBloc()),
        BlocProvider(create: (context) => AccessoryBloc()),
        BlocProvider(create: (context) => BlogBloc()),
        BlocProvider(create: (context) => CartBloc(storedToken: storedToken)),
        BlocProvider(
            create: (context) => ShipBloc()), // Updated to use ShipBloc
        BlocProvider(create: (context) => NotificationBloc()),
        BlocProvider(create: (context) => OrderBloc(storedToken: storedToken)),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess && state.role != null) {
                final userId = extractUserIdFromRole(state.role);
                if (userId != null) {
                  // Ensure NotificationBloc is available
                  final notificationBloc = context.read<NotificationBloc>();
                  context.read<NotificationBloc>().startPolling(userId);
                  saveFcmToken(userId);
                }
              } else if (state is! AuthSuccess) {
                final notificationBloc = context.read<NotificationBloc>();
                context.read<NotificationBloc>().stopPolling();
              }
            },
            child: NotificationProvider(
              userId: _getCurrentUserId(context),
              child: MaterialApp(
                title: 'TerraTechGarden',
                initialRoute: storedToken != null ? Routes.home : Routes.login,
                routes: getAppRoutes(),
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF1D7020),
                    primary: const Color(0xFF1D7020),
                  ),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Color(0xFF1D7020),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D7020),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  cardTheme: CardTheme(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  useMaterial3: true,
                ),
                builder: (context, child) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      setupFirebaseMessaging(context);
                    }
                  });
                  return child!;
                },
                navigatorObservers: [
                  NotificationNavigatorObserver(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _getCurrentUserId(BuildContext context) {
    try {
      final authState = context.watch<AuthBloc>().state;
      if (authState is AuthSuccess && authState.role != null) {
        return extractUserIdFromRole(authState.role);
      }
    } catch (e) {
      print('Error getting current user ID in _getCurrentUserId: $e');
    }
    return storedUserId;
  }
}
