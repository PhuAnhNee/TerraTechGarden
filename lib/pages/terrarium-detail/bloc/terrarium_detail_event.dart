import 'package:equatable/equatable.dart';

abstract class TerrariumDetailEvent extends Equatable {
  const TerrariumDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchTerrariumDetail extends TerrariumDetailEvent {
  final String terrariumId;

  const FetchTerrariumDetail(this.terrariumId);

  @override
  List<Object?> get props => [terrariumId];
}
