import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'navigation/routes.dart';
import 'navigation/app_router.dart';
import 'pages/authentication/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  try {
    await Firebase.initializeApp(); // Initialize Firebase
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Có thể hiển thị dialog lỗi hoặc log chi tiết hơn
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        initialRoute: Routes.login,
        routes: getAppRoutes(),
        theme: ThemeData(
          primaryColor: const Color(0xFF1D7020),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D7020),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
