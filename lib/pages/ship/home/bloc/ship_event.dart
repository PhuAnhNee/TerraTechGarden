abstract class ShipEvent {}

class LoadAvailableOrdersEvent extends ShipEvent {
  final String token;
  LoadAvailableOrdersEvent({required this.token});
}

class LoadShippingOrdersEvent extends ShipEvent {
  final String token;
  LoadShippingOrdersEvent({required this.token});
}

class LoadTransportsEvent extends ShipEvent {
  final String token;
  LoadTransportsEvent({required this.token});
}

class CreateTransportEvent extends ShipEvent {
  final int orderId;
  final DateTime orderDate;
  final String note;
  final String token;
  final int userId;
  CreateTransportEvent({
    required this.orderId,
    required this.orderDate,
    required this.note,
    required this.token,
    required this.userId,
  });
}

class LoadAddressDetailsEvent extends ShipEvent {
  final int addressId;
  final String token;
  LoadAddressDetailsEvent({required this.addressId, required this.token});
}

class UpdateTransportStatusEvent extends ShipEvent {
  final int transportId;
  final String status;
  final String token;
  final String? reason;
  final String? imagePath;
  final String? contactFailNumber;
  final int? assignToUserId;

  UpdateTransportStatusEvent({
    required this.transportId,
    required this.status,
    required this.token,
    this.reason,
    this.imagePath,
    this.contactFailNumber,
    this.assignToUserId,
  });
}

class LoadTransportByOrderEvent extends ShipEvent {
  final int orderId;
  final String token;
  LoadTransportByOrderEvent({required this.orderId, required this.token});
}
