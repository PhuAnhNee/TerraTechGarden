// ship_state.dart
import 'package:equatable/equatable.dart';
import '../../../../models/order.dart';
import '../../../../models/transport.dart';
import '../../../../models/address.dart';

abstract class ShipState extends Equatable {
  const ShipState();

  @override
  List<Object?> get props => [];
}

class ShipInitial extends ShipState {}

class ShipLoading extends ShipState {}

class ShipError extends ShipState {
  final String message;

  const ShipError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrdersLoaded extends ShipState {
  final List<Order> orders;
  final Map<int, Address> addresses; // addressId -> Address mapping
  final Map<int, Transport>?
      transports; // orderId -> Transport mapping (optional)

  const OrdersLoaded({
    required this.orders,
    required this.addresses,
    this.transports,
  });

  @override
  List<Object?> get props => [orders, addresses, transports];
}

class TransportsLoaded extends ShipState {
  final List<Transport> transports;
  final Map<int, Address> addresses;
  const TransportsLoaded({required this.transports, required this.addresses});

  @override
  List<Object?> get props => [transports, addresses];
}

class TransportCreated extends ShipState {
  final Transport transport;

  const TransportCreated({required this.transport});

  @override
  List<Object?> get props => [transport];
}

// New state for transport loaded by order
class TransportByOrderLoaded extends ShipState {
  final int orderId;
  final Transport transport;

  const TransportByOrderLoaded({
    required this.orderId,
    required this.transport,
  });

  @override
  List<Object?> get props => [orderId, transport];
}

// New state for transport status updated
class TransportUpdated extends ShipState {
  final Transport transport;

  const TransportUpdated({required this.transport});

  @override
  List<Object?> get props => [transport];
}

class AddressLoaded extends ShipState {
  final Address address;

  const AddressLoaded({required this.address});

  @override
  List<Object?> get props => [address];
}
