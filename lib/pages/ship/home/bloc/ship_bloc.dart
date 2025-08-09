import 'dart:developer' as developer;
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../api/terra_api.dart';
import 'ship_event.dart';
import 'ship_state.dart';

class ShipBloc extends Bloc<ShipEvent, ShipState> {
  final String? _storedToken;

  ShipBloc(this._storedToken) : super(ShipInitial()) {
    on<FetchOrders>(_onFetchOrders);
    on<FetchOrderAddress>(_onFetchOrderAddress);
  }

  Dio _getDio() {
    final dio = Dio();
    if (_storedToken != null) {
      dio.options.headers['Authorization'] = 'Bearer $_storedToken';
      developer.log('Authorization header set: Bearer $_storedToken',
          name: 'ShipBloc');
    } else {
      developer.log('No token provided for Authorization', name: 'ShipBloc');
    }
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = '*/*';
    return dio;
  }

  Future<void> _onFetchOrders(
      FetchOrders event, Emitter<ShipState> emit) async {
    emit(ShipLoading());
    try {
      final dio = _getDio();
      developer.log('Fetching orders from ${TerraApi.getAllOrders()}',
          name: 'ShipBloc');
      final response = await dio.get(TerraApi.getAllOrders());
      developer.log(
          'Orders API Response: ${response.statusCode} - ${response.data}',
          name: 'ShipBloc');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['status'] == 200) {
          final List<dynamic> ordersData =
              responseData['data'] as List<dynamic>? ?? [];
          final filteredOrders = ordersData
              .where((order) =>
                  (order['paymentStatus'] as String?)?.toLowerCase() == 'paid')
              .toList();

          // Transform orders and fetch address for each
          List<Map<String, dynamic>> transformedOrders = [];
          for (var order in filteredOrders) {
            final transformedOrder =
                await _transformOrderWithAddress(order, dio);
            transformedOrders.add(transformedOrder);
          }

          emit(ShipLoaded(transformedOrders));
        } else {
          emit(ShipError(
              'Failed to fetch orders: ${responseData['message'] ?? 'Unknown error'}'));
        }
      } else {
        emit(ShipError(
            'Failed to fetch orders: Status ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      developer.log('Error fetching orders: $e', name: 'ShipBloc');
      if (e is DioException) {
        developer.log('Dio error details: ${e.response?.data}',
            name: 'ShipBloc');
        if (e.response?.statusCode == 401) {
          emit(ShipError(
              'Unauthorized: Please log in again. Status ${e.response?.statusCode}'));
        } else {
          emit(ShipError(
              'Failed to fetch orders: ${e.response?.data['message'] ?? e.message}'));
        }
      } else {
        emit(ShipError('Failed to fetch orders: $e'));
      }
    }
  }

  Future<Map<String, dynamic>> _transformOrderWithAddress(
      Map<String, dynamic> order, Dio dio) async {
    final userId = order['userId'] as int?;

    // Default values
    String customerName = 'Unknown Customer';
    String customerAddress = 'Unknown Address';
    String receiverPhone = 'Unknown Phone';

    if (userId != null) {
      try {
        // Fetch address from API
        final addressUrl = TerraApi.getAddressByUserId(userId.toString());
        developer.log('Fetching address for user $userId from $addressUrl',
            name: 'ShipBloc');

        final addressResponse = await dio.get(addressUrl);

        if (addressResponse.statusCode == 200) {
          final addressResponseData =
              addressResponse.data as Map<String, dynamic>;
          if (addressResponseData['status'] == 200) {
            final List<dynamic> addressData =
                addressResponseData['data'] as List<dynamic>? ?? [];

            // Find default address
            final defaultAddress = addressData.firstWhere(
              (address) => address['isDefault'] == true,
              orElse: () => addressData.isNotEmpty ? addressData.first : null,
            );

            if (defaultAddress != null) {
              customerName = defaultAddress['receiverName']?.toString() ??
                  'Unknown Customer';
              customerAddress = defaultAddress['receiverAddress']?.toString() ??
                  'Unknown Address';
              receiverPhone = defaultAddress['receiverPhone']?.toString() ??
                  'Unknown Phone';

              developer.log(
                  'Address found for user $userId: $customerName, $customerAddress, $receiverPhone',
                  name: 'ShipBloc');
            } else {
              developer.log('No address found for user $userId',
                  name: 'ShipBloc');
            }
          }
        }
      } catch (e) {
        developer.log('Error fetching address for user $userId: $e',
            name: 'ShipBloc');
        // Keep default values
      }
    }

    return {
      'orderId': order['orderId']?.toString() ?? 'Unknown Order',
      'userId': userId ?? 0,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'receiverPhone': receiverPhone,
      'location': const LatLng(10.7769,
          106.7009), // Default location - you might want to parse from address
      'status': _mapStatus(order['status']?.toString() ?? 'pending'),
      'date': _formatDate(
          order['orderDate']?.toString() ?? DateTime.now().toIso8601String()),
      'paymentStatus': order['paymentStatus']?.toString() ?? 'unknown',
      'totalAmount': order['totalAmount'] ?? 0,
      'steps': {
        'picked': order['status'] == 'picked' ||
            order['status'] == 'delivering' ||
            order['status'] == 'delivered',
        'delivering':
            order['status'] == 'delivering' || order['status'] == 'delivered',
        'delivered': order['status'] == 'delivered',
      },
    };
  }

  Future<void> _onFetchOrderAddress(
      FetchOrderAddress event, Emitter<ShipState> emit) async {
    emit(ShipLoading());
    try {
      final dio = _getDio();
      final apiUrl = TerraApi.getAddressByUserId(event.userId.toString());
      developer.log('Fetching address from $apiUrl', name: 'ShipBloc');
      final response = await dio.get(apiUrl);
      developer.log(
          'Address API Response: ${response.statusCode} - ${response.data}',
          name: 'ShipBloc');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['status'] == 200) {
          final List<dynamic> addressData =
              responseData['data'] as List<dynamic>? ?? [];
          final defaultAddress = addressData.firstWhere(
            (address) => address['isDefault'] == true,
            orElse: () => addressData.isNotEmpty ? addressData.first : null,
          );
          if (defaultAddress != null) {
            emit(ShipAddressLoaded({
              'receiverName':
                  defaultAddress['receiverName']?.toString() ?? 'Unknown',
              'receiverPhone':
                  defaultAddress['receiverPhone']?.toString() ?? 'Unknown',
              'receiverAddress':
                  defaultAddress['receiverAddress']?.toString() ?? 'Unknown',
              'userId': event.userId,
            }));
          } else {
            emit(ShipError('No address found for user ${event.userId}'));
          }
        } else {
          emit(ShipError(
              'Failed to fetch address: ${responseData['message'] ?? 'Unknown error'}'));
        }
      } else {
        emit(ShipError(
            'Failed to fetch address: Status ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      developer.log('Error fetching address: $e', name: 'ShipBloc');
      if (e is DioException) {
        developer.log('Dio error details: ${e.response?.data}',
            name: 'ShipBloc');
        emit(ShipError(
            'Failed to fetch address: ${e.response?.data['message'] ?? e.message}'));
      } else {
        emit(ShipError('Failed to fetch address: $e'));
      }
    }
  }

  String _mapStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'pending':
        return 'available';
      case 'picked':
        return 'picked';
      case 'delivering':
        return 'delivering';
      case 'delivered':
        return 'delivered';
      case 'cancelled':
        return 'cancelled';
      default:
        return 'available';
    }
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day} ${_getMonthName(parsedDate.month)} ${parsedDate.year % 100}';
    } catch (e) {
      developer.log('Error parsing date: $date, error: $e', name: 'ShipBloc');
      return 'Unknown Date';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return month >= 1 && month <= 12 ? months[month - 1] : 'Unknown';
  }
}
