import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../api/terra_api.dart';
import '../../../models/order2.dart';
import '../../../models/order_detail.dart';
import '../../../models/transport2.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final String? storedToken;
  final Dio _dio = Dio();

  OrderBloc({this.storedToken}) : super(OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<LoadOrderDetail>(_onLoadOrderDetail);
    on<RefreshOrders>(_onRefreshOrders);
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

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    if (_userId == null) {
      emit(const OrderError('Không tìm thấy thông tin người dùng'));
      return;
    }

    emit(OrderLoading());

    try {
      // Load orders and transports simultaneously
      final futures = await Future.wait([
        _dio.get(
          TerraApi.getAllOrdersByUserId(_userId!),
          options: Options(headers: _headers),
        ),
        _dio.get(
          TerraApi.getAllTransports(), // Sử dụng method từ TerraApi
          options: Options(headers: _headers),
        ),
      ]);

      final ordersResponse = futures[0];
      final transportsResponse = futures[1];

      if (ordersResponse.statusCode == 200 &&
          transportsResponse.statusCode == 200) {
        final List<dynamic> ordersData = ordersResponse.data;
        final orders = ordersData.map((json) => Order.fromJson(json)).toList();

        final List<dynamic> transportsData =
            transportsResponse.data['data'] ?? [];
        final transports =
            transportsData.map((json) => Transport.fromJson(json)).toList();

        // Sort orders by date (newest first)
        orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

        // Separate orders with active transports
        final activeTransportStatuses = ['inWarehouse', 'shipping'];
        final completedTransportStatuses = ['completed', 'failed'];

        final ordersWithActiveTransport = <Order>[];
        final ordersWithCompletedTransport = <Order>[];
        final ordersWithoutTransport = <Order>[];

        for (final order in orders) {
          final transport = transports.firstWhere(
            (t) => t.orderId == order.orderId,
            orElse: () => Transport.empty(),
          );

          if (transport.transportId != 0) {
            if (activeTransportStatuses.contains(transport.status)) {
              ordersWithActiveTransport.add(order);
            } else if (completedTransportStatuses.contains(transport.status)) {
              ordersWithCompletedTransport.add(order);
            } else {
              ordersWithoutTransport.add(order);
            }
          } else {
            ordersWithoutTransport.add(order);
          }
        }

        emit(OrderLoadedWithTransport(
          activeTransportOrders: ordersWithActiveTransport,
          completedTransportOrders: ordersWithCompletedTransport,
          regularOrders: ordersWithoutTransport,
          transports: transports,
        ));
      } else {
        emit(const OrderError('Không thể tải danh sách đơn hàng'));
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

      emit(OrderError(errorMessage));
    } catch (e) {
      emit(OrderError('Lỗi không xác định: ${e.toString()}'));
    }
  }

  Future<void> _onLoadOrderDetail(
      LoadOrderDetail event, Emitter<OrderState> emit) async {
    emit(OrderDetailLoading());

    try {
      final response = await _dio.get(
        TerraApi.getOrder(event.orderId),
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200 && response.data['status'] == 200) {
        final orderDetailData = response.data['data'];
        final orderDetail = OrderDetail.fromJson(orderDetailData);
        emit(OrderDetailLoaded(orderDetail));
      } else {
        emit(OrderError(
            response.data['message'] ?? 'Không thể tải chi tiết đơn hàng'));
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
            errorMessage = 'Không tìm thấy đơn hàng';
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

      emit(OrderError(errorMessage));
    } catch (e) {
      emit(OrderError('Lỗi không xác định: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshOrders(
      RefreshOrders event, Emitter<OrderState> emit) async {
    // Refresh without showing loading state
    add(LoadOrders());
  }
}
