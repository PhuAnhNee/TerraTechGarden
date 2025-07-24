import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../../config/config.dart';
import '../../../models/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  String? _storedToken;
  String? _storedRefreshToken;
  Timer? _refreshTimer;

  AuthBloc() : super(AuthUnauthenticated()) {
    print('Initial AuthBloc state: AuthUnauthenticated');
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (event.username.isEmpty || event.password.isEmpty) {
        emit(AuthFailure(error: 'Vui lòng điền tên đăng nhập và mật khẩu'));
        return;
      }

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/Users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': event.username,
          'password': event.password,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        _storedToken = responseBody['token'];
        _storedRefreshToken = responseBody['refreshToken'];
        print(
            'Login successful, token: $_storedToken, refreshToken: $_storedRefreshToken');

        // Decode JWT to extract role
        final payload = _decodeJwtPayload(_storedToken!);
        final role = payload[
                'http://schemas.microsoft.com/ws/2008/06/identity/claims/role']
            as String?;

        _scheduleTokenRefresh(_storedToken!);
        emit(AuthSuccess(role: role)); // Pass role to AuthSuccess
      } else {
        final errorMessage = _parseErrorResponse(response);
        print(
            'Login API Error: $errorMessage, Status: ${response.statusCode}, Body: ${response.body}');
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
      print('Register request body: ${jsonEncode(event.user.toJson())}');
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/Users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(event.user.toJson()),
      );

      if (response.statusCode == 200) {
        emit(AuthSuccess());
      } else {
        final errorMessage = _parseErrorResponse(response);
        print(
            'Register API Error: $errorMessage, Status: ${response.statusCode}, Body: ${response.body}');
        emit(AuthFailure(error: 'Đăng ký thất bại: $errorMessage'));
      }
    } catch (e) {
      emit(AuthFailure(error: 'Lỗi kết nối: ${e.toString()}'));
    }
  }

  void _scheduleTokenRefresh(String token) {
    _refreshTimer?.cancel();
    final payload = _decodeJwtPayload(token);
    final exp = payload['exp'] as int? ?? 0;
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    final refreshTime = expiryDate.subtract(Duration(minutes: 5));
    final timeUntilRefresh = refreshTime.difference(DateTime.now()).inSeconds;

    if (timeUntilRefresh > 0) {
      _refreshTimer =
          Timer(Duration(seconds: timeUntilRefresh), () => _refreshToken());
    }
  }

  Future<void> _refreshToken() async {
    if (_storedRefreshToken == null) return;

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/Users/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _storedRefreshToken}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        _storedToken = responseBody['token'];
        print('Token refreshed, new token: $_storedToken');
        _scheduleTokenRefresh(_storedToken!);
      } else {
        print('Token refresh failed: ${_parseErrorResponse(response)}');
        emit(AuthFailure(error: 'Phiên hết hạn, vui lòng đăng nhập lại'));
        _storedToken = null;
        _storedRefreshToken = null;
      }
    } catch (e) {
      print('Token refresh error: $e');
      emit(AuthFailure(error: 'Lỗi kết nối khi làm mới token'));
      _storedToken = null;
      _storedRefreshToken = null;
    }
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = parts[1];
    final decoded = utf8.decode(base64Url.decode(base64Url.normalize(payload)));
    return jsonDecode(decoded);
  }

  String _parseErrorResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? response.reasonPhrase ?? 'Lỗi không xác định';
    } catch (_) {
      return response.reasonPhrase ?? 'Lỗi không xác định';
    }
  }

  String? get token => _storedToken;
}
