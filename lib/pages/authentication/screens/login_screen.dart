import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../navigation/routes.dart';
import '../../../components/message.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('Building LoginScreen'); // Debug
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 40.0),
                  child: const Text(
                    'Terrarium Haven',
                    style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(2.0, 2.0),
                          blurRadius: 4.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Đăng Nhập',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            controller: _emailController,
                            decoration: _buildInputDecoration(
                              label: 'Email',
                              icon: Icons.email,
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true)
                                return 'Vui lòng nhập email';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value!)) {
                                return 'Email không hợp lệ';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _passwordController,
                            decoration: _buildInputDecoration(
                              label: 'Mật khẩu',
                              icon: Icons.lock,
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true)
                                return 'Vui lòng nhập mật khẩu';
                              if (value!.length < 6)
                                return 'Mật khẩu phải có ít nhất 6 ký tự';
                              return null;
                            },
                            obscureText: true,
                          ),
                          const SizedBox(height: 20.0),
                          BlocListener<AuthBloc, AuthState>(
                            listener: (context, state) {
                              print(
                                  'AuthBloc State in LoginScreen: $state'); // Debug
                              if (state is AuthSuccess) {
                                print('Navigating to home screen'); // Debug
                                Message.showSuccess(
                                  context: context,
                                  message: 'Đăng nhập thành công',
                                );
                                Navigator.pushReplacementNamed(
                                    context, Routes.home);
                              } else if (state is AuthFailure) {
                                Message.showError(
                                  context: context,
                                  message: state.error,
                                  onRetry: () {
                                    final email = _emailController.text.trim();
                                    final password =
                                        _passwordController.text.trim();
                                    context.read<AuthBloc>().add(
                                          LoginRequested(
                                              email: email, password: password),
                                        );
                                  },
                                );
                              }
                            },
                            child: BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                return AnimatedOpacity(
                                  opacity: state is AuthLoading ? 0.5 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: ElevatedButton(
                                    onPressed: state is AuthLoading
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              final email =
                                                  _emailController.text.trim();
                                              final password =
                                                  _passwordController.text
                                                      .trim();
                                              context.read<AuthBloc>().add(
                                                    LoginRequested(
                                                        email: email,
                                                        password: password),
                                                  );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4CAF50),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40.0, vertical: 12.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      elevation: 4.0,
                                    ),
                                    child: state is AuthLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.0,
                                            ),
                                          )
                                        : const Text(
                                            'Đăng Nhập',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    print('Register TextButton pressed'); // Debug
                    try {
                      Navigator.pushNamed(context, Routes.register);
                      print('Navigated to register screen'); // Debug
                    } catch (e) {
                      print('Navigation error: $e'); // Debug
                      Message.showError(
                        context: context,
                        message: 'Lỗi điều hướng: $e',
                      );
                    }
                  },
                  child: const Text(
                    'Chưa có tài khoản? Đăng ký',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight
                          .w500, // Fixed: was 16.0, should be FontWeight
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset:
                              Offset(1.0, 1.0), // Fixed: was Offset(1.0, 16.0)
                          blurRadius: 2.0,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextButton(
                  onPressed: () {
                    // Fixed: Proper function syntax
                    print('Forgot Password TextButton pressed'); // Debug
                    Message.showInfo(
                      context: context,
                      message:
                          'Chưa có chức năng quên mật khẩu', // Fixed: removed "đăng" at the end
                    );
                  },
                  child: const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(1.0, 1.0),
                          blurRadius: 2.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]), // Fixed: removed const
      prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide:
            BorderSide(color: Colors.grey[300]!), // Fixed: removed const
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}
