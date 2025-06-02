import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../navigation/routes.dart';
import '../../../components/message.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  String? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        username: _usernameController.text.trim(),
        passwordHash:
            _passwordController.text.trim(), // Backend should handle hashing
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        fullName: _fullNameController.text.trim(),
        dateOfBirth: _dateOfBirthController.text.trim(),
        gender: _selectedGender ?? '',
      );
      context.read<AuthBloc>().add(RegisterRequested(user: user));
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().subtract(const Duration(days: 6570)), // ~18 years ago
      firstDate: DateTime(1900),
      lastDate:
          DateTime.now().subtract(const Duration(days: 4380)), // ~12 years ago
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                              'Đăng Ký',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: _usernameController,
                              decoration: _buildInputDecoration(
                                label: 'Tên người dùng',
                                icon: Icons.person,
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Vui lòng nhập tên người dùng';
                                }
                                if (value!.length < 3) {
                                  return 'Tên người dùng phải có ít nhất 3 ký tự';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _fullNameController,
                              decoration: _buildInputDecoration(
                                label: 'Họ và tên',
                                icon: Icons.person_outline,
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Vui lòng nhập họ và tên';
                                }
                                if (value!.trim().split(' ').length < 2) {
                                  return 'Vui lòng nhập họ và tên đầy đủ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
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
                              controller: _phoneNumberController,
                              decoration: _buildInputDecoration(
                                label: 'Số điện thoại',
                                icon: Icons.phone,
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true)
                                  return 'Vui lòng nhập số điện thoại';
                                // Vietnamese phone number validation
                                if (!RegExp(r'^(0|\+84)[3-9]\d{8}$')
                                    .hasMatch(value!)) {
                                  return 'Số điện thoại không hợp lệ';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _passwordController,
                              decoration: _buildInputDecoration(
                                label: 'Mật khẩu',
                                icon: Icons.lock,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(0xFF4CAF50),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true)
                                  return 'Vui lòng nhập mật khẩu';
                                if (value!.length < 8)
                                  return 'Mật khẩu phải có ít nhất 8 ký tự';
                                if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)')
                                    .hasMatch(value)) {
                                  return 'Mật khẩu phải có ít nhất 1 chữ hoa, 1 chữ thường và 1 số';
                                }
                                return null;
                              },
                              obscureText: _obscurePassword,
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: _buildInputDecoration(
                                label: 'Xác nhận mật khẩu',
                                icon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(0xFF4CAF50),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true)
                                  return 'Vui lòng xác nhận mật khẩu';
                                if (value != _passwordController.text) {
                                  return 'Mật khẩu xác nhận không khớp';
                                }
                                return null;
                              },
                              obscureText: _obscureConfirmPassword,
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _dateOfBirthController,
                              decoration: _buildInputDecoration(
                                label: 'Ngày sinh',
                                icon: Icons.calendar_today,
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true)
                                  return 'Vui lòng chọn ngày sinh';
                                try {
                                  final date = DateFormat('yyyy-MM-dd')
                                      .parseStrict(value!);
                                  final now = DateTime.now();
                                  final age = now.difference(date).inDays / 365;
                                  if (age < 12)
                                    return 'Phải từ 12 tuổi trở lên';
                                  if (age > 120)
                                    return 'Ngày sinh không hợp lệ';
                                  return null;
                                } catch (e) {
                                  return 'Ngày sinh phải có định dạng YYYY-MM-DD';
                                }
                              },
                              readOnly: true,
                              onTap: _selectDate,
                            ),
                            const SizedBox(height: 16.0),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: _buildInputDecoration(
                                label: 'Giới tính',
                                icon: Icons.people,
                              ),
                              items: ['Nam', 'Nữ', 'Khác'].map((String gender) {
                                return DropdownMenuItem<String>(
                                  value: gender,
                                  child: Text(gender),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                              validator: (value) => value == null
                                  ? 'Vui lòng chọn giới tính'
                                  : null,
                            ),
                            const SizedBox(height: 24.0),
                            BlocListener<AuthBloc, AuthState>(
                              listener: (context, state) {
                                if (state is AuthSuccess) {
                                  Message.showSuccess(
                                    context: context,
                                    message: 'Đăng ký thành công',
                                  );
                                  Navigator.pushReplacementNamed(
                                      context, Routes.home);
                                } else if (state is AuthFailure) {
                                  Message.showError(
                                    context: context,
                                    message: state.error,
                                    onRetry: _submitForm,
                                  );
                                }
                              },
                              child: BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return AnimatedOpacity(
                                    opacity: state is AuthLoading ? 0.5 : 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: state is AuthLoading
                                            ? null
                                            : _submitForm,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF4CAF50),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 40.0, vertical: 16.0),
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
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.0,
                                                ),
                                              )
                                            : const Text(
                                                'Đăng Ký',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
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
                      Navigator.pushNamed(context, Routes.login);
                    },
                    child: const Text(
                      'Đã có tài khoản? Đăng nhập',
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
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[300]!),
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
