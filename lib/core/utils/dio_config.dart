import 'package:dio/dio.dart';
import '../../config/config.dart';

class DioClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': '*/*',
    },
  ));

  Dio get dio => _dio;

  // Method to add Authorization header dynamically
  void updateToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }
}

// Singleton instance
final dioClient = DioClient();
