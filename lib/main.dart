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
        title: 'Terrarium App',
        initialRoute: Routes.login,
        routes: getAppRoutes(),
      ),
    );
  }
}
