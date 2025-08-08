import 'package:equatable/equatable.dart';

abstract class AccessoryEvent extends Equatable {
  const AccessoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchAccessories extends AccessoryEvent {
  final int page;

  const FetchAccessories({this.page = 1});

  @override
  List<Object?> get props => [page];
}
