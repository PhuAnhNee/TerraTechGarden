import 'package:equatable/equatable.dart';
import '../../../models/address.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  const AddressLoading();
}

class AddressLoaded extends AddressState {
  final List<Address> addresses;

  const AddressLoaded(this.addresses);

  @override
  List<Object?> get props => [addresses];

  Address? get defaultAddress {
    if (addresses.isEmpty) return null;

    // Find address with isDefault = true
    for (final address in addresses) {
      if (address.isDefault == true) {
        return address;
      }
    }

    // If no default found, return first address
    return addresses.first;
  }
}

class AddressSubmitting extends AddressState {
  const AddressSubmitting();
}

class AddressSubmitSuccess extends AddressState {
  final String message;

  const AddressSubmitSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}
