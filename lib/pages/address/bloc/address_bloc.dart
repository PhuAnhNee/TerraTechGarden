import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../api/terra_api.dart';
import '../../../models/address.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final String? storedToken;
  final Dio _dio = Dio();

  AddressBloc({this.storedToken}) : super(AddressInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<AddAddress>(_onAddAddress);
    on<RefreshAddresses>(_onRefreshAddresses);
  }

  String? get _userId {
    if (storedToken == null || storedToken!.isEmpty) return null;
    try {
      final decodedToken = JwtDecoder.decode(storedToken!);
      return decodedToken['sub']?.toString();
    } catch (e) {
      print('Error decoding JWT token: $e');
      return null;
    }
  }

  Map<String, String> get _headers {
    return {
      'Authorization': 'Bearer $storedToken',
      'Content-Type': 'application/json',
    };
  }

  Future<void> _onLoadAddresses(
      LoadAddresses event, Emitter<AddressState> emit) async {
    if (_userId == null) {
      emit(const AddressError('Không tìm thấy thông tin người dùng'));
      return;
    }

    emit(AddressLoading());

    try {
      final response = await _dio.get(
        TerraApi.getAllAddressesByUserId(_userId!),
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200 && response.data['status'] == 200) {
        final List<dynamic> addressesData = response.data['data'] ?? [];
        final addresses =
            addressesData.map((json) => Address.fromJson(json)).toList();
        emit(AddressLoaded(addresses));
      } else {
        emit(AddressError(
            response.data['message'] ?? 'Không thể tải danh sách địa chỉ'));
      }
    } on DioException catch (e) {
      String errorMessage = 'Lỗi kết nối';

      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 401:
            errorMessage = 'Phiên đăng nhập đã hết hạn';
            break;
          case 403:
            errorMessage = 'Không có quyền truy cập';
            break;
          case 404:
            errorMessage = 'Không tìm thấy dữ liệu';
            break;
          case 500:
            errorMessage = 'Lỗi server';
            break;
          default:
            errorMessage = e.response?.data?['message'] ?? 'Lỗi không xác định';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Kết nối bị timeout';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Không thể kết nối đến server';
      }

      emit(AddressError(errorMessage));
    } catch (e) {
      emit(AddressError('Lỗi không xác định: ${e.toString()}'));
    }
  }

  Future<void> _onAddAddress(
      AddAddress event, Emitter<AddressState> emit) async {
    if (_userId == null) {
      emit(const AddressError('Không tìm thấy thông tin người dùng'));
      return;
    }

    emit(AddressSubmitting());

    try {
      final addressData = {
        'tagName': event.address.tagName,
        'receiverName': event.address.receiverName,
        'receiverPhone': event.address.receiverPhone,
        'receiverAddress': event.address.receiverAddress,
        'provinceCode': event.address.provinceCode,
        'districtCode': event.address.districtCode,
        'wardCode': event.address.wardCode,
        'latitude': event.address.latitude,
        'longitude': event.address.longitude,
        'isDefault': event.address.isDefault,
      };

      final response = await _dio.post(
        TerraApi.addAddress(),
        data: addressData,
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(AddressSubmitSuccess('Thêm địa chỉ thành công'));
        // Reload addresses after successful addition
        add(LoadAddresses());
      } else {
        emit(AddressError(
            response.data?['message'] ?? 'Không thể thêm địa chỉ'));
      }
    } on DioException catch (e) {
      String errorMessage = 'Lỗi kết nối';

      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 400:
            errorMessage = 'Thông tin địa chỉ không hợp lệ';
            break;
          case 401:
            errorMessage = 'Phiên đăng nhập đã hết hạn';
            break;
          case 403:
            errorMessage = 'Không có quyền thêm địa chỉ';
            break;
          case 500:
            errorMessage = 'Lỗi server';
            break;
          default:
            errorMessage = e.response?.data?['message'] ?? 'Lỗi không xác định';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Kết nối bị timeout';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Không thể kết nối đến server';
      }

      emit(AddressError(errorMessage));
    } catch (e) {
      emit(AddressError('Lỗi không xác định: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshAddresses(
      RefreshAddresses event, Emitter<AddressState> emit) async {
    // Refresh without showing loading state
    add(LoadAddresses());
  }
}
