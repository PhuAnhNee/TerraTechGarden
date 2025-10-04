import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'accessory_event.dart';
import 'accessory_state.dart';
import '../../../api/terra_api.dart';

class AccessoryBloc extends Bloc<AccessoryEvent, AccessoryState> {
  final Dio _dio = Dio();

  AccessoryBloc() : super(AccessoryInitial()) {
    on<FetchAccessories>((event, emit) async {
      // Không emit loading nếu đang load cùng page
      if (state is AccessoryLoaded &&
          (state as AccessoryLoaded).currentPage == event.page) {
        return;
      }

      developer.log('Fetching accessories for page: ${event.page}',
          name: 'AccessoryBloc');

      // Chỉ emit loading cho request đầu tiên hoặc khi đổi page
      if (state is! AccessoryLoaded) {
        emit(AccessoryLoading());
      } else {
        emit(AccessoryPageLoading((state as AccessoryLoaded)));
      }

      try {
        final response = await TerraApi.getAccessories(page: event.page);
        developer.log(
            'API Response: ${response['status']} - Page ${event.page}',
            name: 'AccessoryBloc');

        if (response['status'] == 200 &&
            response['data'] is Map<String, dynamic> &&
            response['data']['results'] is List) {
          final results = response['data']['results'] as List;

          // Validate dữ liệu trước khi emit
          if (results.isEmpty && event.page > 1) {
            emit(AccessoryError('Không có dữ liệu cho trang ${event.page}'));
            return;
          }

          final totalItems = response['data']['totalItems'] ?? 0;
          final pageSize = response['data']['pageSize'] ?? 10;
          final totalPages = response['data']['totalPages'] ?? 1;

          // Parse accessories với error handling
          final accessories = <Map<String, dynamic>>[];
          for (var item in results) {
            if (item is Map<String, dynamic>) {
              accessories.add(_sanitizeAccessoryData(item));
            }
          }

          developer.log(
              'Loaded ${accessories.length} accessories for page ${event.page}',
              name: 'AccessoryBloc');

          emit(AccessoryLoaded(
            accessories,
            totalPages: totalPages,
            currentPage: event.page,
            totalItems: totalItems,
          ));
        } else {
          final errorMsg = response['message'] ?? 'Lỗi không xác định';
          emit(AccessoryError('Không thể tải dữ liệu: $errorMsg'));
        }
      } catch (e) {
        developer.log('Exception during fetch: $e',
            name: 'AccessoryBloc', error: e);

        String errorMessage = 'Không thể tải phụ kiện';
        if (e is DioException) {
          switch (e.type) {
            case DioExceptionType.connectionTimeout:
            case DioExceptionType.sendTimeout:
            case DioExceptionType.receiveTimeout:
              errorMessage = 'Kết nối quá chậm, vui lòng thử lại';
              break;
            case DioExceptionType.badResponse:
              errorMessage = 'Server đang bận, vui lòng thử lại sau';
              break;
            case DioExceptionType.connectionError:
              errorMessage = 'Không có kết nối internet';
              break;
            default:
              errorMessage = 'Lỗi kết nối: ${e.message}';
          }
        }

        emit(AccessoryError(errorMessage));
      }
    });

    on<RefreshAccessories>((event, emit) async {
      emit(AccessoryLoading());
      add(FetchAccessories(page: 1));
    });
  }

  // Sanitize và validate dữ liệu accessory
  Map<String, dynamic> _sanitizeAccessoryData(Map<String, dynamic> data) {
    return {
      'id': data['accessoryId'] ?? data['id'] ?? '',
      'accessoryName': data['name']?.toString().trim() ?? 'Chưa có tên',
      'price': _formatPrice(data['price']),
      'accessoryImages': _sanitizeImages(data['accessoryImages']),
      'description': data['description']?.toString().trim() ?? '',
      'category': data['category']?.toString().trim() ?? '',
      'stock': data['stockQuantity'] ?? data['stock'] ?? 0,
      'size': data['size']?.toString().trim() ?? '',
      'quantitative': data['quantitative']?.toString().trim() ?? '',
      'averageRating': data['averageRating'] ?? 0,
      'feedbackCount': data['feedbackCount'] ?? 0,
      'purchaseCount': data['purchaseCount'] ?? 0,
      'status': data['status']?.toString().trim() ?? '',
    };
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'Liên hệ';
    if (price is String) {
      final numPrice = double.tryParse(price);
      if (numPrice == null) return price;
      return '${numPrice.toStringAsFixed(0)}đ';
    }
    if (price is num) {
      return '${price.toStringAsFixed(0)}đ';
    }
    return 'Liên hệ';
  }

  List<Map<String, dynamic>> _sanitizeImages(dynamic images) {
    if (images == null) return [];
    if (images is! List) return [];

    return (images as List)
        .where((img) => img is Map<String, dynamic> && img['imageUrl'] != null)
        .map((img) => {
              'imageUrl': img['imageUrl'].toString(),
              'altText': img['altText']?.toString() ?? '',
            })
        .toList();
  }
}
