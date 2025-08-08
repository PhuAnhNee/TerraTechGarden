import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'blog_event.dart';
import 'blog_state.dart';
import '../../../api/terra_api.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  BlogBloc() : super(BlogInitial()) {
    on<FetchBlogs>((event, emit) async {
      developer.log('Fetching blogs for page: ${event.page}', name: 'BlogBloc');
      emit(BlogLoading());

      try {
        final response = await http.get(
          Uri.parse(TerraApi.getAllBlogs()),
          headers: {
            'Content-Type': 'application/json',
            'accept': 'text/plain',
          },
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Request timeout - Vui lòng kiểm tra kết nối mạng');
          },
        );

        developer.log(
          'API Response (get-all): ${response.statusCode} - Body length: ${response.body.length}',
          name: 'BlogBloc',
        );

        if (response.statusCode == 200) {
          try {
            final data = jsonDecode(response.body);
            developer.log('Decoded data structure: ${data.runtimeType}',
                name: 'BlogBloc');
            developer.log(
                'Data keys: ${data is Map ? data.keys.toList() : 'Not a Map'}',
                name: 'BlogBloc');

            // Handle different possible response structures
            List<dynamic> results = [];

            if (data is Map<String, dynamic>) {
              if (data['status'] == 200 || data['statusCode'] == 200) {
                // Structure: { status: 200, data: { results: [...] } }
                if (data['data'] is Map<String, dynamic> &&
                    data['data']['results'] is List) {
                  results = data['data']['results'] as List;
                }
                // Structure: { status: 200, results: [...] }
                else if (data['results'] is List) {
                  results = data['results'] as List;
                }
                // Structure: { status: 200, data: [...] }
                else if (data['data'] is List) {
                  results = data['data'] as List;
                } else {
                  developer.log('Unexpected data structure in success response',
                      name: 'BlogBloc');
                  emit(BlogError(
                      'Định dạng dữ liệu không hợp lệ: ${data['message'] ?? 'Unknown error'}'));
                  return;
                }
              } else {
                emit(BlogError(
                    'API Error: ${data['message'] ?? 'Unknown error'}'));
                return;
              }
            }
            // Direct array response
            else if (data is List) {
              results = data;
            } else {
              developer.log('Unexpected response format: ${data.runtimeType}',
                  name: 'BlogBloc');
              emit(BlogError('Định dạng response không hợp lệ'));
              return;
            }

            developer.log('Total results found: ${results.length}',
                name: 'BlogBloc');

            if (results.isEmpty) {
              emit(BlogError('Không có blog nào được tìm thấy'));
              return;
            }

            // Log first item structure for debugging
            if (results.isNotEmpty) {
              developer.log('First item structure: ${results.first}',
                  name: 'BlogBloc');
              developer.log('First item type: ${results.first.runtimeType}',
                  name: 'BlogBloc');
              if (results.first is Map) {
                developer.log(
                    'First item keys: ${(results.first as Map).keys.toList()}',
                    name: 'BlogBloc');
              }
            }

            // Pagination logic
            const pageSize = 10;
            final totalItems = results.length;
            final totalPages = (totalItems / pageSize).ceil();
            final startIndex = (event.page - 1) * pageSize;
            final endIndex = (startIndex + pageSize > totalItems)
                ? totalItems
                : startIndex + pageSize;

            if (startIndex >= totalItems) {
              emit(BlogError('Trang ${event.page} không tồn tại'));
              return;
            }

            final paginatedResults = results.sublist(startIndex, endIndex);
            final blogs = paginatedResults.cast<Map<String, dynamic>>();

            developer.log(
              'Emitting blogs for page ${event.page}: ${blogs.length} items (${startIndex}-${endIndex - 1} of $totalItems)',
              name: 'BlogBloc',
            );

            emit(BlogLoaded(
              blogs,
              totalPages: totalPages,
              currentPage: event.page,
              totalItems: totalItems,
            ));
          } catch (jsonError) {
            developer.log('JSON decode error: $jsonError', name: 'BlogBloc');
            developer.log(
                'Response body preview: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}',
                name: 'BlogBloc');
            emit(BlogError('Lỗi xử lý dữ liệu: ${jsonError.toString()}'));
          }
        } else {
          developer.log(
              'HTTP Error: ${response.statusCode} - ${response.reasonPhrase}',
              name: 'BlogBloc');
          String errorMessage = 'Lỗi tải dữ liệu (${response.statusCode})';

          // Try to decode error response
          try {
            final errorData = jsonDecode(response.body);
            if (errorData is Map && errorData['message'] != null) {
              errorMessage += ': ${errorData['message']}';
            }
          } catch (e) {
            // If we can't decode the error, use the status code
            errorMessage += ': ${response.reasonPhrase ?? 'Unknown error'}';
          }

          emit(BlogError(errorMessage));
        }
      } catch (e) {
        developer.log('Exception during fetch: $e', name: 'BlogBloc');
        String errorMessage = 'Không thể tải blog';

        if (e.toString().contains('timeout')) {
          errorMessage = 'Kết nối bị timeout - Vui lòng thử lại';
        } else if (e.toString().contains('SocketException') ||
            e.toString().contains('NetworkException')) {
          errorMessage = 'Lỗi kết nối mạng - Vui lòng kiểm tra internet';
        } else {
          errorMessage = 'Lỗi: ${e.toString()}';
        }

        emit(BlogError(errorMessage));
      }
    });
  }
}
