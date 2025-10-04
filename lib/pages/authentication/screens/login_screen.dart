import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import '../../../navigation/routes.dart';
import '../../../components/message.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../screens/forget_pass.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E7D32), // Dark green
                Color(0xFF4CAF50), // Main green
                Color(0xFF66BB6A), // Light green
                Color(0xFF81C784), // Lighter green
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: isSmallScreen ? 60 : 100),

              // Logo/Icon section
              FadeInDown(
                duration: Duration(milliseconds: 1000),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.eco,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Title section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    FadeInUp(
                      duration: Duration(milliseconds: 1200),
                      child: Text(
                        "TerraTechGarden",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 32 : 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(2.0, 2.0),
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 12),
                    FadeInUp(
                      duration: Duration(milliseconds: 1400),
                      child: Text(
                        "Chào mừng bạn đến với TerraTechGarden",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isSmallScreen ? 40 : 60),

              // Form container
              FadeInUp(
                duration: Duration(milliseconds: 1600),
                child: Container(
                  width: screenWidth,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 25,
                        offset: Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 25 : 35),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // Welcome text
                          Text(
                            "Đăng Nhập",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 24 : 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          Text(
                            "Vui lòng nhập thông tin của bạn",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: isSmallScreen ? 25 : 35),

                          // Username field
                          _buildInputField(
                            controller: _usernameController,
                            hintText: "Tên đăng nhập",
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Vui lòng nhập tên đăng nhập';
                              }
                              if (value!.length < 3) {
                                return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 20),

                          // Password field
                          _buildInputField(
                            controller: _passwordController,
                            hintText: "Mật khẩu",
                            icon: Icons.lock_outline,
                            isPassword: true,
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

                          SizedBox(height: 15),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => ForgetPass(),
                                );
                              },
                              child: Text(
                                "Quên mật khẩu?",
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 25 : 35),

                          // Login button
                          BlocListener<AuthBloc, AuthState>(
                            listener: (context, state) {
                              if (state is AuthSuccess) {
                                _showSuccessNotification(context);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                if (state.role == 'Shipper') {
                                  Navigator.pushReplacementNamed(
                                      context, Routes.shipperHome);
                                } else {
                                  Navigator.pushReplacementNamed(
                                      context, Routes.home);
                                }
                              } else if (state is AuthFailure) {
                                _showErrorNotification(context, state.error);
                              }
                            },
                            child: BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                return _buildLoginButton(
                                    context, state, isSmallScreen);
                              },
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 20 : 30),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "hoặc",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: isSmallScreen ? 20 : 30),

                          // Register button
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF4CAF50),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: MaterialButton(
                              onPressed: () {
                                try {
                                  Navigator.pushNamed(context, Routes.register);
                                } catch (e) {
                                  _showErrorNotification(
                                      context, 'Lỗi hệ thống');
                                }
                              },
                              child: Text(
                                "Đăng Ký Tài Khoản",
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(
            icon,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildLoginButton(
      BuildContext context, AuthState state, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF66BB6A),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: MaterialButton(
        onPressed: state is AuthLoading
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                  final username = _usernameController.text.trim();
                  final password = _passwordController.text.trim();
                  context.read<AuthBloc>().add(
                        LoginRequested(
                          username: username,
                          password: password,
                        ),
                      );
                }
              },
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
                  fontSize: 16,
                ),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  void _showSuccessNotification(BuildContext context) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16.0,
        left: 16.0,
        right: 16.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 22.0),
                SizedBox(width: 12.0),
                Flexible(
                  child: Text(
                    'Đăng nhập thành công',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
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

  void _showErrorNotification(BuildContext context, String error) {
    String displayMessage = _getSimpleErrorMessage(error);

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16.0,
        left: 16.0,
        right: 16.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 22.0),
                SizedBox(width: 12.0),
                Flexible(
                  child: Text(
                    displayMessage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  String _getSimpleErrorMessage(String error) {
    String lowerError = error.toLowerCase();

    if (lowerError.contains('password') ||
        lowerError.contains('username') ||
        lowerError.contains('credential') ||
        lowerError.contains('invalid') ||
        lowerError.contains('wrong') ||
        lowerError.contains('incorrect') ||
        lowerError.contains('sai') ||
        lowerError.contains('không đúng') ||
        lowerError.contains('không tồn tại')) {
      return 'Sai tên đăng nhập hoặc mật khẩu';
    }

    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout') ||
        lowerError.contains('kết nối') ||
        lowerError.contains('mạng')) {
      return 'Lỗi kết nối mạng';
    }

    if (lowerError.contains('server') ||
        lowerError.contains('service') ||
        lowerError.contains('máy chủ')) {
      return 'Lỗi hệ thống';
    }

    return 'Lỗi hệ thống';
  }
}
