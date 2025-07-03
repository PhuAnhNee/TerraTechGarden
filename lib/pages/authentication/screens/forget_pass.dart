import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:terratechgarden/config/config.dart';
import 'package:terratechgarden/components/message.dart';
import 'package:terratechgarden/api/terra_api.dart';

class ForgetPass extends StatefulWidget {
  @override
  _ForgetPassState createState() => _ForgetPassState();
}

class _ForgetPassState extends State<ForgetPass> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestForgotPassword(
      BuildContext context, String email) async {
    try {
      final response = await http.post(
        Uri.parse(TerraApi.forgotPassword()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        Message.showSuccess(
          context: context,
          message: responseBody['message'] ?? 'Email gửi thành công',
        );
      } else {
        Message.showError(
          context: context,
          message: 'Gửi email thất bại. Vui lòng thử lại.',
        );
      }
    } catch (e) {
      Message.showError(
        context: context,
        message: 'Lỗi kết nối: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Quên Mật Khẩu'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Vui lòng nhập email để đặt lại mật khẩu'),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isLoading = true);
                    _requestForgotPassword(
                      context,
                      _emailController.text.trim(),
                    ).then((_) {
                      setState(() => _isLoading = false);
                      Navigator.pop(context);
                    });
                  }
                },
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4CAF50)),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white))
              : Text('Gửi'),
        ),
      ],
    );
  }
}
