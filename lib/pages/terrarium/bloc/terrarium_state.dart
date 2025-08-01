abstract class TerrariumState {}

class TerrariumInitial extends TerrariumState {}

class TerrariumLoading extends TerrariumState {}

class TerrariumLoaded extends TerrariumState {
  final List<Map<String, dynamic>> terrariums;
  final int totalPages;
  final int currentPage;
  final int totalItems;

  TerrariumLoaded(this.terrariums,
      {this.totalPages = 0, this.currentPage = 1, this.totalItems = 0});
}

class TerrariumReferencesLoaded extends TerrariumState {
  final List<Map<String, dynamic>> environments;
  final List<Map<String, dynamic>> shapes;
  final List<Map<String, dynamic>> tankMethods;

  TerrariumReferencesLoaded(this.environments, this.shapes, this.tankMethods);
}

class TerrariumError extends TerrariumState {
  final String message;

  TerrariumError(this.message);
}
