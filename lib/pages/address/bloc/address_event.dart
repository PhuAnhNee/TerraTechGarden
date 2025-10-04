import 'package:equatable/equatable.dart';
import '../../../models/address.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class LoadAddresses extends AddressEvent {
  const LoadAddresses();
}

class AddAddress extends AddressEvent {
  final Address address;

  const AddAddress(this.address);

  @override
  List<Object?> get props => [address];
}

class UpdateAddress extends AddressEvent {
  final Address address;

  const UpdateAddress(this.address);

  @override
  List<Object?> get props => [address];
}

class DeleteAddress extends AddressEvent {
  final int addressId;

  const DeleteAddress(this.addressId);

  @override
  List<Object?> get props => [addressId];
}

class SetDefaultAddress extends AddressEvent {
  final int addressId;

  const SetDefaultAddress(this.addressId);

  @override
  List<Object?> get props => [addressId];
}

class RefreshAddresses extends AddressEvent {
  const RefreshAddresses();
}
