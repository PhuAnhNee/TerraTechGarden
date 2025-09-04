abstract class OrderEvent {}

class LoadOrders extends OrderEvent {}

class LoadOrderDetail extends OrderEvent {
  final int orderId;

  LoadOrderDetail(this.orderId);
}

class RefreshOrders extends OrderEvent {}
