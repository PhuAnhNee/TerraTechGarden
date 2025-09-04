import '../../../models/order2.dart';
import '../../../models/order_detail.dart';
import '../../../models/transport2.dart';

abstract class OrderState {
  const OrderState();
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<Order> orders;

  const OrderLoaded(this.orders);
}

class OrderLoadedWithTransport extends OrderState {
  final List<Order> activeTransportOrders;
  final List<Order> completedTransportOrders;
  final List<Order> regularOrders;
  final List<Transport> transports;

  const OrderLoadedWithTransport({
    required this.activeTransportOrders,
    required this.completedTransportOrders,
    required this.regularOrders,
    required this.transports,
  });

  List<Order> get allOrders => [
        ...activeTransportOrders,
        ...completedTransportOrders,
        ...regularOrders,
      ];

  Transport? getTransportForOrder(int orderId) {
    return transports.firstWhere(
      (t) => t.orderId == orderId,
      orElse: () => Transport.empty(),
    );
  }
}

class OrderDetailLoading extends OrderState {}

class OrderDetailLoaded extends OrderState {
  final OrderDetail orderDetail;

  const OrderDetailLoaded(this.orderDetail);
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);
}
