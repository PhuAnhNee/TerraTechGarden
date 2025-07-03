import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:terratechgarden/config/config.dart';
import '../../../navigation/routes.dart';
import '../screens/otp.dart'; // Import the OTP dialog

class RegisterLogic {
  static Future<void> showOtpDialog(BuildContext context,
      {required String email}) async {
    final otpControllers = List.generate(6, (_) => TextEditingController());
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => OtpDialog(
          email: email,
          onVerify: (otp) async {
            setState(() => isLoading = true);
            await _verifyOtp(context, email, otp);
            setState(() => isLoading = false);
          },
          isLoading: isLoading,
          otpControllers: otpControllers,
        ),
      ),
    );
  }

  static Future<void> _verifyOtp(
      BuildContext context, String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/Users/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // Close OTP dialog
        Navigator.pushReplacementNamed(context, Routes.login);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng ký thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mã OTP không đúng hoặc đã hết hạn')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối: ${e.toString()}')),
      );
    }
  }
}
