import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation/routes.dart';
import 'navigation/app_router.dart';
import 'pages/authentication/bloc/auth_bloc.dart';
import 'pages/terrarium/bloc/terrarium_bloc.dart';
import 'pages/accessory/bloc/accessory_bloc.dart';
import 'pages/blog/bloc/blog_bloc.dart';
import 'pages/cart/bloc/cart_bloc.dart';
import 'pages/ship/home/bloc/ship_bloc.dart';

Future<String?> getStoredToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('accessToken');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  final storedToken = await getStoredToken();

  runApp(MyApp(storedToken: storedToken));
}

class MyApp extends StatelessWidget {
  final String? storedToken;

  const MyApp({super.key, this.storedToken});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => TerrariumBloc()),
        BlocProvider(create: (context) => AccessoryBloc()),
        BlocProvider(create: (context) => BlogBloc()),
        BlocProvider(create: (context) => CartBloc(storedToken: storedToken)),
        BlocProvider(create: (context) => ShipBloc(storedToken)),
      ],
      child: MaterialApp(
        initialRoute: Routes.login,
        routes: getAppRoutes(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1D7020),
            primary: const Color(0xFF1D7020),
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
          useMaterial3: true,
        ),
      ),
    );
  }
}
