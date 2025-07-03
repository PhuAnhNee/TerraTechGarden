import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../navigation/routes.dart';
import '../../../components/message.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../models/user.dart';
import '../bloc/register_logic.dart';

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

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 4380)),
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
                  foregroundColor: const Color(0xFF4CAF50)),
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
                      child: Text("Tạo tài khoản mới",
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
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 30),

                        // Username Field
                        FadeInUp(
                          duration: Duration(milliseconds: 1400),
                          child: _buildInputField(
                            controller: _usernameController,
                            hintText: "Tên người dùng",
                            prefixIcon: Icons.person_outline,
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
                        ),
                        SizedBox(height: 16),

                        // Full Name Field
                        FadeInUp(
                          duration: Duration(milliseconds: 1450),
                          child: _buildInputField(
                            controller: _fullNameController,
                            hintText: "Họ và tên",
                            prefixIcon: Icons.badge_outlined,
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
                        ),
                        SizedBox(height: 16),

                        // Email Field
                        FadeInUp(
                          duration: Duration(milliseconds: 1500),
                          child: _buildInputField(
                            controller: _emailController,
                            hintText: "Email",
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Vui lòng nhập email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value!)) {
                                return 'Email không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16),

                        // Phone Field
                        FadeInUp(
                          duration: Duration(milliseconds: 1550),
                          child: _buildInputField(
                            controller: _phoneNumberController,
                            hintText: "Số điện thoại",
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Vui lòng nhập số điện thoại';
                              }
                              if (!RegExp(r'^(0|\+84)[3-9]\d{8}$')
                                  .hasMatch(value!)) {
                                return 'Số điện thoại không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16),

                        // Password Field
                        FadeInUp(
                          duration: Duration(milliseconds: 1600),
                          child: _buildPasswordField(
                            controller: _passwordController,
                            hintText: "Mật khẩu",
                            obscureText: _obscurePassword,
                            onToggle: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (value!.length < 8) {
                                return 'Mật khẩu phải có ít nhất 8 ký tự';
                              }
                              if (!RegExp(
                                      r'^(?=.*[a-zÀ-Ỹà-ỹ])(?=.*[A-ZÀ-Ỹ])(?=.*\d)')
                                  .hasMatch(value)) {
                                return 'Mật khẩu phải có ít nhất 1 chữ hoa, 1 chữ thường và 1 số';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16),

                        // Confirm Password Field
                        FadeInUp(
                          duration: Duration(milliseconds: 1650),
                          child: _buildPasswordField(
                            controller: _confirmPasswordController,
                            hintText: "Xác nhận mật khẩu",
                            obscureText: _obscureConfirmPassword,
                            onToggle: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Vui lòng xác nhận mật khẩu';
                              }
                              if (value != _passwordController.text) {
                                return 'Mật khẩu xác nhận không khớp';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16),

                        // Date of Birth Field
                        FadeInUp(
                          duration: Duration(milliseconds: 1700),
                          child: _buildDateField(),
                        ),
                        SizedBox(height: 16),

                        // Gender Dropdown
                        FadeInUp(
                          duration: Duration(milliseconds: 1750),
                          child: _buildGenderDropdown(),
                        ),
                        SizedBox(height: 40),

                        // Register Button
                        BlocListener<AuthBloc, AuthState>(
                          listener: (context, state) {
                            if (state is AuthSuccess) {
                              RegisterLogic.showOtpDialog(
                                context,
                                email: _emailController.text.trim(),
                              );
                            } else if (state is AuthFailure) {
                              Message.showError(
                                context: context,
                                message: state.error,
                                onRetry: () {
                                  _submitForm();
                                },
                              );
                            }
                          },
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return FadeInUp(
                                duration: Duration(milliseconds: 1800),
                                child: AnimatedOpacity(
                                  opacity: state is AuthLoading ? 0.5 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    width: double.infinity,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF4CAF50),
                                          Color(0xFF66BB6A)
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF4CAF50)
                                              .withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: MaterialButton(
                                      onPressed: state is AuthLoading
                                          ? null
                                          : _submitForm,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
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
                                              "Đăng Ký",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 30),

                        FadeInUp(
                          duration: Duration(milliseconds: 1900),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, Routes.login);
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Đã có tài khoản? ",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 16),
                                children: [
                                  TextSpan(
                                    text: "Đăng nhập",
                                    style: TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(prefixIcon, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: validator,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.grey[400],
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: TextFormField(
        controller: _dateOfBirthController,
        decoration: InputDecoration(
          hintText: "Ngày sinh (YYYY-MM-DD)",
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon:
              Icon(Icons.calendar_today_outlined, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Vui lòng chọn ngày sinh';
          }
          try {
            final date = DateFormat('yyyy-MM-dd').parseStrict(value!);
            final now = DateTime.now();
            final age = now.difference(date).inDays / 365;
            if (age < 12) {
              return 'Phải từ 12 tuổi trở lên';
            }
            if (age > 120) {
              return 'Ngày sinh không hợp lệ';
            }
            print('Validated dateOfBirth: $value');
            return null;
          } catch (e) {
            return 'Ngày sinh phải có định dạng YYYY-MM-DD';
          }
        },
        readOnly: true,
        onTap: _selectDate,
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          hintText: "Chọn giới tính",
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.person_pin_outlined, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        items: ['Nam', 'Nữ'].map((String gender) {
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
        validator: (value) => value == null ? 'Vui lòng chọn giới tính' : null,
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Map Vietnamese gender to server-expected values
      String serverGender = _selectedGender == 'Nam' ? 'male' : 'female';

      // Convert dateOfBirth to ISO 8601 format
      final dateOfBirth =
          DateFormat('yyyy-MM-dd').parse(_dateOfBirthController.text.trim());
      final isoDateOfBirth = dateOfBirth.toUtc().toIso8601String();

      final user = User(
        username: _usernameController.text.trim(),
        passwordHash: _passwordController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        fullName: _fullNameController.text.trim(),
        dateOfBirth: isoDateOfBirth,
        gender: serverGender,
      );

      print('Submitting user data: ${user.toJson()}'); // Debug log
      context.read<AuthBloc>().add(RegisterRequested(user: user));
    }
  }
}
