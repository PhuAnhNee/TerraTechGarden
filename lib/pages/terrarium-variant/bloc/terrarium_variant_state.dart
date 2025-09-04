import 'package:equatable/equatable.dart';

abstract class TerrariumVariantState extends Equatable {
  const TerrariumVariantState();

  @override
  List<Object?> get props => [];
}

class TerrariumVariantInitial extends TerrariumVariantState {}

class TerrariumVariantLoading extends TerrariumVariantState {}

class TerrariumVariantLoaded extends TerrariumVariantState {
  final List<Map<String, dynamic>> variants;
  final int selectedVariantIndex;
  final Map<int, Map<String, dynamic>> accessoryDetails;

  const TerrariumVariantLoaded({
    required this.variants,
    this.selectedVariantIndex = 0,
    this.accessoryDetails = const {},
  });

  Map<String, dynamic> get selectedVariant =>
      variants.isNotEmpty ? variants[selectedVariantIndex] : {};

  TerrariumVariantLoaded copyWith({
    List<Map<String, dynamic>>? variants,
    int? selectedVariantIndex,
    Map<int, Map<String, dynamic>>? accessoryDetails,
  }) {
    return TerrariumVariantLoaded(
      variants: variants ?? this.variants,
      selectedVariantIndex: selectedVariantIndex ?? this.selectedVariantIndex,
      accessoryDetails: accessoryDetails ?? this.accessoryDetails,
    );
  }

  @override
  List<Object?> get props => [variants, selectedVariantIndex, accessoryDetails];
}

class TerrariumVariantError extends TerrariumVariantState {
  final String message;

  const TerrariumVariantError(this.message);

  @override
  List<Object?> get props => [message];
}
