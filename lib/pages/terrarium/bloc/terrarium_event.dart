import 'package:equatable/equatable.dart';

abstract class TerrariumEvent extends Equatable {
  const TerrariumEvent();

  @override
  List<Object?> get props => [];
}

class FetchTerrariumReferences extends TerrariumEvent {}

class FetchTerrariums extends TerrariumEvent {
  final int page;

  const FetchTerrariums({required this.page});

  @override
  List<Object?> get props => [page];
}

class FilterTerrariums extends TerrariumEvent {
  final String? environmentName;
  final String? shapeName;
  final String? tankMethodType;
  final int page;

  const FilterTerrariums({
    this.environmentName,
    this.shapeName,
    this.tankMethodType,
    required this.page,
  });

  @override
  List<Object?> get props => [environmentName, shapeName, tankMethodType, page];
}
