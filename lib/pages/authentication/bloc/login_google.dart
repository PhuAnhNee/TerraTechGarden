// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:terratechgarden/api/terra_api.dart';
// import 'package:terratechgarden/components/message.dart';
// import 'package:flutter/material.dart';

// Future<void> performGoogleLogin(
//     BuildContext context, String accessToken) async {
//   try {
//     final response = await http.post(
//       Uri.parse(TerraApi.loginGoogle()),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'accessToken': accessToken}),
//     );

//     if (response.statusCode == 200) {
//       final responseBody = jsonDecode(response.body);
//       if (responseBody['status'] == 0) {
//         Message.showSuccess(
//           context: context,
//           message: responseBody['message'] ?? 'Đăng nhập Google thành công',
//         );
//         // Navigate to home screen (assuming this is handled by the caller)
//       } else {
//         Message.showError(
//           context: context,
//           message: responseBody['message'] ?? 'Đăng nhập Google thất bại',
//         );
//       }
//     } else {
//       Message.showError(
//         context: context,
//         message: 'Yêu cầu thất bại. Vui lòng thử lại.',
//       );
//     }
//   } catch (e) {
//     Message.showError(
//       context: context,
//       message: 'Lỗi kết nối: ${e.toString()}',
//     );
//   }
// }
