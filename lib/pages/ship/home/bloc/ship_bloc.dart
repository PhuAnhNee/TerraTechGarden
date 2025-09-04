import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../api/terra_api.dart';
import '../../../../models/order.dart';
import '../../../../models/transport.dart';
import '../../../../models/address.dart';
import 'ship_event.dart';
import 'ship_state.dart';
import 'dart:io';

class ShipBloc extends Bloc<ShipEvent, ShipState> {
  final Dio _dio = Dio();

  // Getter to access Dio instance from external widgets
  Dio get dio => _dio;

  ShipBloc() : super(ShipInitial()) {
    on<LoadAvailableOrdersEvent>(_onLoadAvailableOrders);
    on<LoadShippingOrdersEvent>(_onLoadShippingOrders);
    on<LoadTransportHistoryEvent>(_onLoadTransportHistory);
    on<LoadTransportsEvent>(_onLoadTransports);
    on<CreateTransportEvent>(_onCreateTransport);
    on<LoadAddressDetailsEvent>(_onLoadAddressDetails);
    on<UpdateTransportStatusEvent>(_onUpdateTransportStatus);
    on<LoadTransportByOrderEvent>(_onLoadTransportByOrder);
  }

  Future<void> _onLoadAvailableOrders(
      LoadAvailableOrdersEvent event, Emitter<ShipState> emit) async {
    emit(ShipLoading());
    try {
      // Get orders
      final response = await _dio.get(
        TerraApi.getAllOrders(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${event.token}',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 200) {
        final ordersData = response.data['data'] as List;

        // Filter orders: only processing status and paid payment status
        final filteredOrders = ordersData
            .map((orderJson) => Order.fromJson(orderJson))
            .where((order) =>
                order.status == 'Processing' && order.paymentStatus == 'Paid')
            .toList();

        // Load address details for each order
        Map<int, Address> addresses = {};
        for (final order in filteredOrders) {
          try {
            final addressResponse = await _dio.get(
              TerraApi.getAddress(order.addressId),
              options: Options(
                headers: {
                  'Authorization': 'Bearer ${event.token}',
                  'accept': '*/*',
                },
              ),
            );

            if (addressResponse.statusCode == 200 &&
                addressResponse.data['status'] == 200) {
              addresses[order.addressId] =
                  Address.fromJson(addressResponse.data['data']);
            }
          } catch (e) {
            print('Error loading address ${order.addressId}: $e');
          }
        }

        emit(OrdersLoaded(orders: filteredOrders, addresses: addresses));
      } else {
        emit(ShipError(
            'Failed to load orders: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ShipError('Unauthorized. Please login again.'));
        } else {
          emit(ShipError('Network error: ${e.message}'));
        }
      } else {
        emit(ShipError('Failed to load orders: $e'));
      }
    }
  }

  Future<void> _onLoadShippingOrders(
      LoadShippingOrdersEvent event, Emitter<ShipState> emit) async {
    emit(ShipLoading());
    try {
      // Get orders with shipping status and paid payment status
      final response = await _dio.get(
        TerraApi.getAllOrders(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${event.token}',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 200) {
        final ordersData = response.data['data'] as List;

        // Filter orders: only shipping status and paid payment status
        final filteredOrders = ordersData
            .map((orderJson) => Order.fromJson(orderJson))
            .where((order) =>
                order.status == 'shipping' && order.paymentStatus == 'Paid')
            .toList();

        // Load address details for each order
        Map<int, Address> addresses = {};
        for (final order in filteredOrders) {
          try {
            final addressResponse = await _dio.get(
              TerraApi.getAddress(order.addressId),
              options: Options(
                headers: {
                  'Authorization': 'Bearer ${event.token}',
                  'accept': '*/*',
                },
              ),
            );

            if (addressResponse.statusCode == 200 &&
                addressResponse.data['status'] == 200) {
              addresses[order.addressId] =
                  Address.fromJson(addressResponse.data['data']);
            }
          } catch (e) {
            print('Error loading address ${order.addressId}: $e');
          }
        }

        emit(OrdersLoaded(orders: filteredOrders, addresses: addresses));
      } else {
        emit(ShipError(
            'Failed to load shipping orders: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ShipError('Unauthorized. Please login again.'));
        } else {
          emit(ShipError('Network error: ${e.message}'));
        }
      } else {
        emit(ShipError('Failed to load shipping orders: $e'));
      }
    }
  }

  Future<void> _onLoadTransports(
      LoadTransportsEvent event, Emitter<ShipState> emit) async {
    emit(ShipLoading());
    try {
      final response = await _dio.get(
        TerraApi.getAllTransports(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${event.token}',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final transportsData = responseData['data'] as List? ?? [];
        final transports = <Transport>[];
        final Map<int, Address> addresses = {};

        for (var transportJson in transportsData) {
          final transport = Transport.fromJson(transportJson);
          if (transport.status == 'inWarehouse' ||
              transport.status == 'shipping') {
            // Fetch order details to get addressId
            final orderResponse = await _dio.get(
              TerraApi.getOrder(transport.orderId),
              options: Options(
                headers: {
                  'Authorization': 'Bearer ${event.token}',
                  'accept': '*/*',
                },
              ),
            );
            if (orderResponse.statusCode == 200 &&
                orderResponse.data['status'] == 200) {
              final orderData = orderResponse.data['data'];
              final order = Order.fromJson(orderData);

              // Fetch address details
              final addressResponse = await _dio.get(
                TerraApi.getAddress(order.addressId),
                options: Options(
                  headers: {
                    'Authorization': 'Bearer ${event.token}',
                    'accept': '*/*',
                  },
                ),
              );
              if (addressResponse.statusCode == 200 &&
                  addressResponse.data['status'] == 200) {
                final addressData = addressResponse.data['data'];
                final address = Address.fromJson(addressData);
                addresses[transport.orderId] = address;
              }
            }
            transports.add(transport);
          }
        }

        emit(TransportsLoaded(transports: transports, addresses: addresses));
      } else {
        emit(ShipError(
            'Failed to load transports: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ShipError('Unauthorized. Please login again.'));
        } else {
          emit(ShipError('Network error: ${e.message}'));
        }
      } else {
        emit(ShipError('Failed to load transports: $e'));
      }
    }
  }

  Future<void> _onLoadTransportByOrder(
      LoadTransportByOrderEvent event, Emitter<ShipState> emit) async {
    try {
      final response = await _dio.get(
        TerraApi.getOrderTransport(event.orderId.toString()),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${event.token}',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 200) {
        final transport = Transport.fromJson(response.data['data']);
        emit(TransportByOrderLoaded(
            orderId: event.orderId, transport: transport));
      } else {
        emit(ShipError(
            'Failed to load transport: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ShipError('Unauthorized. Please login again.'));
        } else if (e.response?.statusCode == 404) {
          emit(ShipError('Transport not found for this order.'));
        } else {
          emit(ShipError('Network error: ${e.message}'));
        }
      } else {
        emit(ShipError('Failed to load transport: $e'));
      }
    }
  }

  Future<void> _onCreateTransport(
      CreateTransportEvent event, Emitter<ShipState> emit) async {
    emit(ShipLoading());
    try {
      // Calculate estimated completion date (orderDate + 12 hours)
      final estimatedDate = event.orderDate.add(Duration(hours: 12));

      final requestData = {
        "orderId": event.orderId,
        "estimateCompletedDate": estimatedDate.toIso8601String(),
        "note": event.note,
        "isRefund": false, // Always false as requested
        "userId": event.userId,
      };

      final response = await _dio.post(
        TerraApi.createTransport(),
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${event.token}',
            'Content-Type': 'application/json',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final transport = Transport.fromJson(response.data['data']);
        emit(TransportCreated(transport: transport));

        // Reload shipping orders after creating transport
        add(LoadShippingOrdersEvent(token: event.token));
      } else {
        emit(ShipError(
            'Failed to create transport: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ShipError('Unauthorized. Please login again.'));
        } else if (e.response?.statusCode == 400) {
          emit(ShipError('Invalid data. Please check your input.'));
        } else {
          emit(ShipError('Network error: ${e.message}'));
        }
      } else {
        emit(ShipError('Failed to create transport: $e'));
      }
    }
  }

// Add this method to ShipBloc constructor

// Add this method to ShipBloc class
  Future<void> _onLoadTransportHistory(
      LoadTransportHistoryEvent event, Emitter<ShipState> emit) async {
    emit(ShipLoading());
    try {
      final response = await _dio.get(
        TerraApi.getAllTransports(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${event.token}',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final transportsData = responseData['data'] as List? ?? [];
        final transports = <Transport>[];
        final Map<int, Address> addresses = {};

        for (var transportJson in transportsData) {
          final transport = Transport.fromJson(transportJson);

          // Only include completed and failed transports
          if (transport.status == 'completed' || transport.status == 'failed') {
            // Fetch order details to get addressId
            try {
              final orderResponse = await _dio.get(
                TerraApi.getOrder(transport.orderId),
                options: Options(
                  headers: {
                    'Authorization': 'Bearer ${event.token}',
                    'accept': '*/*',
                  },
                ),
              );

              if (orderResponse.statusCode == 200 &&
                  orderResponse.data['status'] == 200) {
                final orderData = orderResponse.data['data'];
                final order = Order.fromJson(orderData);

                // Fetch address details
                final addressResponse = await _dio.get(
                  TerraApi.getAddress(order.addressId),
                  options: Options(
                    headers: {
                      'Authorization': 'Bearer ${event.token}',
                      'accept': '*/*',
                    },
                  ),
                );

                if (addressResponse.statusCode == 200 &&
                    addressResponse.data['status'] == 200) {
                  final addressData = addressResponse.data['data'];
                  final address = Address.fromJson(addressData);
                  addresses[transport.orderId] = address;
                }
              }

              transports.add(transport);
            } catch (e) {
              print('Error loading order ${transport.orderId}: $e');
              // Still add transport even if we can't get address
              transports.add(transport);
            }
          }
        }

        // Sort by created date (newest first), handle nullable DateTime
        transports.sort((a, b) {
          final dateA = a.createdDate ?? a.createdAt ?? DateTime.now();
          final dateB = b.createdDate ?? b.createdAt ?? DateTime.now();
          return dateB.compareTo(dateA);
        });

        emit(TransportHistoryLoaded(
            transports: transports, addresses: addresses));
      } else {
        emit(ShipError(
            'Failed to load transport history: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ShipError('Unauthorized. Please login again.'));
        } else {
          emit(ShipError('Network error: ${e.message}'));
        }
      } else {
        emit(ShipError('Failed to load transport history: $e'));
      }
    }
  }
  // Updated _onUpdateTransportStatus method in ship_bloc.dart

  Future<void> _onUpdateTransportStatus(
      UpdateTransportStatusEvent event, Emitter<ShipState> emit) async {
    try {
      FormData formData = FormData();

      // Add required transport status update fields
      formData.fields.addAll([
        MapEntry('TransportId', event.transportId.toString()),
        MapEntry('Status', event.status),
        MapEntry('ContactFailNumber',
            event.contactFailNumber ?? '0'), // Changed to string as API expects
        MapEntry('AssignToUserId', event.assignToUserId?.toString() ?? ''),
      ]);

      // Add reason if provided
      if (event.reason != null && event.reason!.isNotEmpty) {
        formData.fields.add(MapEntry('Reason', event.reason!));
      }

      // Add image file if provided
      if (event.imagePath != null && event.imagePath!.isNotEmpty) {
        final file = File(event.imagePath!);
        if (await file.exists()) {
          formData.files.add(MapEntry(
            'Image', // Changed to match API parameter name
            await MultipartFile.fromFile(
              event.imagePath!,
              filename: 'transport_${event.transportId}_${event.status}.jpg',
              contentType: MediaType('image', 'jpeg'),
            ),
          ));
        }
      }

      final response = await _dio.put(
        TerraApi.updateTransport(event.transportId.toString()),
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${event.token}',
            'accept': '*/*',
            'Content-Type':
                'multipart/form-data', // Added explicit content type
          },
        ),
      );

      if (response.statusCode == 200 &&
          (response.data['status'] == 200 || response.data['status'] == 201)) {
        // Added 201 status
        final updatedTransport = Transport.fromJson(response.data['data']);
        emit(TransportUpdated(transport: updatedTransport));

        // Reload transports after successful update
        add(LoadTransportsEvent(token: event.token));
      } else {
        emit(ShipError(
            'Failed to update transport status: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ShipError('Unauthorized. Please login again.'));
        } else if (e.response?.statusCode == 404) {
          emit(ShipError('Transport not found.'));
        } else {
          // Log the actual error response for debugging
          print('Update transport error: ${e.response?.data}');
          emit(ShipError('Network error: ${e.message}'));
        }
      } else {
        emit(ShipError('Failed to update transport status: $e'));
      }
    }
  }

  Future<void> _onLoadAddressDetails(
      LoadAddressDetailsEvent event, Emitter<ShipState> emit) async {
    try {
      final response = await _dio.get(
        TerraApi.getAddress(event.addressId),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${event.token}',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 200) {
        final address = Address.fromJson(response.data['data']);
        emit(AddressLoaded(address: address));
      } else {
        emit(ShipError(
            'Failed to load address: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ShipError('Unauthorized. Please login again.'));
        } else {
          emit(ShipError('Network error: ${e.message}'));
        }
      } else {
        emit(ShipError('Failed to load address: $e'));
      }
    }
  }
}
