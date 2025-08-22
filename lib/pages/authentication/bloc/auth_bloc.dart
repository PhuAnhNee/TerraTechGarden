// lib/pages/authentication/bloc/auth_bloc.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../config/config.dart';
import '../../../core/utils/dio_config.dart';
import '../../../api/terra_api.dart';
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

  Future<void> saveFcmToken(String userId) async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await Dio().post(
          TerraApi.saveFcmToken(),
          data: {
            'userId': userId,
            'fcmToken': fcmToken,
          },
        );
        print('FCM token saved for user $userId');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (event.username.isEmpty || event.password.isEmpty) {
        emit(const AuthFailure(
            error: 'Vui lòng điền tên đăng nhập và mật khẩu'));
        return;
      }

      final response = await dioClient.dio.post(
        '/api/Users/login',
        data: {
          'username': event.username,
          'password': event.password,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.data;
        _storedToken = responseBody['token'];
        _storedRefreshToken = responseBody['refreshToken'];
        AppConfig.accessToken = _storedToken; // Update AppConfig.accessToken
        final userId = _decodeJwtPayload(_storedToken!)['sub'] as String?;
        if (userId != null) {
          await saveFcmToken(userId); // Save FCM token
        }
        print(
            'Login successful, token: $_storedToken, refreshToken: $_storedRefreshToken');

        final payload = _decodeJwtPayload(_storedToken!);
        final role = payload[
                'http://schemas.microsoft.com/ws/2008/06/identity/claims/role']
            as String?;

        _scheduleTokenRefresh(_storedToken!);
        emit(AuthSuccess(role: role));
      } else {
        final errorMessage = _parseErrorResponse(response);
        print(
            'Login API Error: $errorMessage, Status: ${response.statusCode}, Body: ${response.data}');
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
      dioClient.updateToken(null); // Clear Authorization header for register
      print('Register request body: ${jsonEncode(event.user.toJson())}');
      final response = await dioClient.dio.post(
        '/api/Users/register',
        data: event.user.toJson(),
      );

      if (response.statusCode == 200) {
        emit(const AuthSuccess());
      } else {
        final errorMessage = _parseErrorResponse(response);
        print(
            'Register API Error: $errorMessage, Status: ${response.statusCode}, Body: ${response.data}');
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
    final refreshTime = expiryDate.subtract(const Duration(minutes: 5));
    final timeUntilRefresh = refreshTime.difference(DateTime.now()).inSeconds;

    if (timeUntilRefresh > 0) {
      _refreshTimer =
          Timer(Duration(seconds: timeUntilRefresh), () => _refreshToken());
    }
  }

  Future<void> _refreshToken() async {
    if (_storedRefreshToken == null) return;

    try {
      dioClient.updateToken(null); // Clear Authorization header for refresh
      final response = await dioClient.dio.post(
        '/api/Users/refresh-token',
        data: {'refreshToken': _storedRefreshToken},
      );

      if (response.statusCode == 200) {
        final responseBody = response.data;
        _storedToken = responseBody['token'];
        _storedRefreshToken = responseBody['refreshToken'];
        AppConfig.accessToken = _storedToken; // Update AppConfig.accessToken
        dioClient.updateToken(_storedToken); // Update Dio with new token
        print('Token refreshed, new token: $_storedToken');
        _scheduleTokenRefresh(_storedToken!);
      } else {
        print('Token refresh failed: ${_parseErrorResponse(response)}');
        emit(const AuthFailure(error: 'Phiên hết hạn, vui lòng đăng nhập lại'));
        _storedToken = null;
        _storedRefreshToken = null;
        AppConfig.accessToken = null;
        dioClient.updateToken(null);
      }
    } catch (e) {
      print('Token refresh error: $e');
      emit(const AuthFailure(error: 'Lỗi kết nối khi làm mới token'));
      _storedToken = null;
      _storedRefreshToken = null;
      AppConfig.accessToken = null;
      dioClient.updateToken(null);
    }
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = parts[1];
    final decoded = utf8.decode(base64Url.decode(base64Url.normalize(payload)));
    return jsonDecode(decoded);
  }

  String _parseErrorResponse(Response response) {
    try {
      final body = response.data;
      return body['message'] ?? response.statusMessage ?? 'Lỗi không xác định';
    } catch (_) {
      return response.statusMessage ?? 'Lỗi không xác định';
    }
  }

  String? get token => _storedToken;
}
