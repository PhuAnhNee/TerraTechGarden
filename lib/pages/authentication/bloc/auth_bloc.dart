import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config/config.dart';
import '../../../models/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthUnauthenticated()) {
    print('Initial AuthBloc state: AuthUnauthenticated'); // Debug initial state
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(AuthFailure(error: 'Vui lòng điền email và mật khẩu'));
        return;
      }

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/Users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': event.email,
          'password': event.password,
        }),
      );

      if (response.statusCode == 200) {
        emit(AuthSuccess());
      } else {
        final errorMessage = _parseErrorResponse(response);
        emit(AuthFailure(error: 'Đăng nhập thất bại: $errorMessage'));
      }
    } catch (e) {
      emit(AuthFailure(error: 'Lỗi kết nối: ${e.toString()}'));
    }
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/Users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(event.user.toJson()),
      );

      if (response.statusCode == 200) {
        emit(AuthSuccess());
      } else {
        final errorMessage = _parseErrorResponse(response);
        emit(AuthFailure(error: 'Đăng ký thất bại: $errorMessage'));
      }
    } catch (e) {
      emit(AuthFailure(error: 'Lỗi kết nối: ${e.toString()}'));
    }
  }

  String _parseErrorResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? response.reasonPhrase ?? 'Lỗi không xác định';
    } catch (_) {
      return response.reasonPhrase ?? 'Lỗi không xác định';
    }
  }
}
