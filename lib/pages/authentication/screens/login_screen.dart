import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../../../navigation/routes.dart';
import '../../../components/message.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../screens/forget_pass.dart';
import '../bloc/login_google.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('Building LoginScreen'); // Debug
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, colors: [
          Color(0xFF4CAF50), // Green shade 900
          Color(0xFF66BB6A), // Green shade 800
          Color(0xFF81C784) // Green shade 400
        ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 80),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      child: Text("TerraTechGarden",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(2.0, 2.0),
                                blurRadius: 4.0,
                              ),
                            ],
                          ))),
                  SizedBox(height: 10),
                  FadeInUp(
                      duration: Duration(milliseconds: 1300),
                      child: Text("Chào mừng bạn đến với TerraTechGarden",
                          style: TextStyle(color: Colors.white, fontSize: 18))),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60))),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 60),
                        FadeInUp(
                            duration: Duration(milliseconds: 1400),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Color(0xFF4CAF50).withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: Offset(0, 10))
                                  ]),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey.shade200))),
                                    child: TextFormField(
                                      controller: _usernameController,
                                      decoration: InputDecoration(
                                          hintText: "Tên đăng nhập",
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          border: InputBorder.none),
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return 'Vui lòng nhập tên đăng nhập';
                                        }
                                        if (value!.length < 3) {
                                          return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey.shade200))),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          hintText: "Mật khẩu",
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          border: InputBorder.none),
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return 'Vui lòng nhập mật khẩu';
                                        }
                                        if (value!.length < 6) {
                                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(height: 40),
                        FadeInUp(
                            duration: Duration(milliseconds: 1500),
                            child: TextButton(
                                onPressed: () {
                                  print('Forgot Password TextButton pressed');
                                  showDialog(
                                    context: context,
                                    builder: (context) => ForgetPass(),
                                  );
                                },
                                child: Text("Quên mật khẩu?",
                                    style: TextStyle(color: Colors.grey)))),
                        SizedBox(height: 40),
                        BlocListener<AuthBloc, AuthState>(
                          listener: (context, state) {
                            print('AuthBloc State in LoginScreen: $state');
                            if (state is AuthSuccess) {
                              print('Navigating to home screen');
                              _showSuccessNotification(context);
                              ScaffoldMessenger.of(context).clearSnackBars();
                              Navigator.pushReplacementNamed(
                                  context, Routes.home);
                            } else if (state is AuthFailure) {
                              Message.showError(
                                context: context,
                                message: state.error,
                                onRetry: () {
                                  final username =
                                      _usernameController.text.trim();
                                  final password =
                                      _passwordController.text.trim();
                                  context.read<AuthBloc>().add(
                                        LoginRequested(
                                            username: username,
                                            password: password),
                                      );
                                },
                              );
                            }
                          },
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return FadeInUp(
                                  duration: Duration(milliseconds: 1600),
                                  child: AnimatedOpacity(
                                    opacity: state is AuthLoading ? 0.5 : 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: MaterialButton(
                                      onPressed: state is AuthLoading
                                          ? null
                                          : () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                final username =
                                                    _usernameController.text
                                                        .trim();
                                                final password =
                                                    _passwordController.text
                                                        .trim();
                                                context.read<AuthBloc>().add(
                                                      LoginRequested(
                                                          username: username,
                                                          password: password),
                                                    );
                                              }
                                            },
                                      height: 50,
                                      minWidth: double.infinity,
                                      color: Color(0xFF4CAF50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: state is AuthLoading
                                          ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.0,
                                              ),
                                            )
                                          : Text(
                                              "Đăng Nhập",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                    ),
                                  ));
                            },
                          ),
                        ),
                        SizedBox(height: 30),
                        FadeInUp(
                            duration: Duration(milliseconds: 1700),
                            child: TextButton(
                                onPressed: () {
                                  print('Register TextButton pressed');
                                  try {
                                    Navigator.pushNamed(
                                        context, Routes.register);
                                    print('Navigated to register screen');
                                  } catch (e) {
                                    print('Navigation error: $e');
                                    Message.showError(
                                      context: context,
                                      message: 'Lỗi điều hướng: $e',
                                    );
                                  }
                                },
                                child: Text("Chưa có tài khoản? Đăng ký",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16)))),
                        SizedBox(height: 30),
                        FadeInUp(
                            duration: Duration(milliseconds: 1800),
                            child: Text("Hoặc đăng nhập bằng",
                                style: TextStyle(color: Colors.grey))),
                        SizedBox(height: 30),
                        FadeInUp(
                            duration: Duration(milliseconds: 1900),
                            child: MaterialButton(
                              onPressed: () async {
                                print('Google Login Button pressed');
                                // await _handleGoogleSignIn(context);
                              },
                              height: 50,
                              minWidth: double.infinity,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  side:
                                      BorderSide(color: Colors.grey.shade300)),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/google_logo.png',
                                    height: 24,
                                    width: 24,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.g_mobiledata,
                                        color: Colors.red,
                                        size: 24,
                                      );
                                    },
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Đăng nhập với Google",
                                    style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Future<void> _handleGoogleSignIn(BuildContext context) async {
  //   try {
  //     final GoogleAuthProvider authProvider = GoogleAuthProvider();
  //     final UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithProvider(authProvider);
  //     final String accessToken = await userCredential.credential?.token ?? '';
  //     await performGoogleLogin(context, accessToken);
  //   } catch (e) {
  //     print('Firebase Google Sign-In Error: $e');
  //     Message.showError(
  //         context: context, message: 'Lỗi đăng nhập Google: ${e.toString()}');
  //   }
  // }

  void _showSuccessNotification(BuildContext context) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16.0,
        left: 16.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Color(0xFF26A69A),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.0),
                SizedBox(width: 8.0),
                Text(
                  'Đăng nhập thành công',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
