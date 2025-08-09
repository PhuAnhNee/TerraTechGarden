import 'package:equatable/equatable.dart';

abstract class ShipEvent extends Equatable {
  const ShipEvent();

  @override
  List<Object?> get props => [];
}

class FetchOrders extends ShipEvent {}

class FetchOrderAddress extends ShipEvent {
  final int userId;

  const FetchOrderAddress(this.userId);

  @override
  List<Object?> get props => [userId];
}
