import 'package:equatable/equatable.dart';

abstract class ShipState extends Equatable {
  const ShipState();

  @override
  List<Object?> get props => [];
}

class ShipInitial extends ShipState {}

class ShipLoading extends ShipState {}

class ShipLoaded extends ShipState {
  final List<Map<String, dynamic>> orders;

  const ShipLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class ShipAddressLoaded extends ShipState {
  final Map<String, dynamic> addressDetails;

  const ShipAddressLoaded(this.addressDetails);

  @override
  List<Object?> get props => [addressDetails];
}

class ShipError extends ShipState {
  final String message;

  const ShipError(this.message);

  @override
  List<Object?> get props => [message];
}
