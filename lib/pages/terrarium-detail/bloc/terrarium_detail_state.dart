abstract class TerrariumDetailState {}

class TerrariumDetailInitial extends TerrariumDetailState {}

class TerrariumDetailLoading extends TerrariumDetailState {}

class TerrariumDetailLoaded extends TerrariumDetailState {
  final Map<String, dynamic> terrarium;

  TerrariumDetailLoaded(this.terrarium);
}

class TerrariumDetailError extends TerrariumDetailState {
  final String message;

  TerrariumDetailError(this.message);
}
