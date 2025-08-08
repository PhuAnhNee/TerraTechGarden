import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class FetchCart extends CartEvent {}

class AddCartItems extends CartEvent {
  final List<Map<String, dynamic>> items;

  const AddCartItems(this.items);

  @override
  List<Object?> get props => [items];
}

class UpdateCartItem extends CartEvent {
  final String itemId;
  final Map<String, dynamic> itemData;

  const UpdateCartItem(this.itemId, this.itemData);

  @override
  List<Object?> get props => [itemId, itemData];
}

class DeleteCartItem extends CartEvent {
  final String itemId;

  const DeleteCartItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class DeleteAllCartItems extends CartEvent {}
