import 'package:equatable/equatable.dart';

abstract class TerrariumVariantEvent extends Equatable {
  const TerrariumVariantEvent();

  @override
  List<Object?> get props => [];
}

class FetchTerrariumVariants extends TerrariumVariantEvent {
  final int terrariumId;

  const FetchTerrariumVariants(this.terrariumId);

  @override
  List<Object?> get props => [terrariumId];
}

class SelectVariant extends TerrariumVariantEvent {
  final int variantId;

  const SelectVariant(this.variantId);

  @override
  List<Object?> get props => [variantId];
}

class FetchAccessoryDetails extends TerrariumVariantEvent {
  final int accessoryId;

  const FetchAccessoryDetails(this.accessoryId);

  @override
  List<Object?> get props => [accessoryId];
}
