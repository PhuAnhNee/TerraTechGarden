import 'package:equatable/equatable.dart';

abstract class AccessoryState extends Equatable {
  const AccessoryState();

  @override
  List<Object?> get props => [];
}

class AccessoryInitial extends AccessoryState {}

class AccessoryLoading extends AccessoryState {}

// State mới cho việc loading khi đổi page
class AccessoryPageLoading extends AccessoryState {
  final AccessoryLoaded previousState;

  const AccessoryPageLoading(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

class AccessoryLoaded extends AccessoryState {
  final List<Map<String, dynamic>> accessories;
  final int totalPages;
  final int currentPage;
  final int totalItems;

  const AccessoryLoaded(
    this.accessories, {
    this.totalPages = 1,
    this.currentPage = 1,
    this.totalItems = 0,
  });

  @override
  List<Object?> get props => [accessories, totalPages, currentPage, totalItems];

  AccessoryLoaded copyWith({
    List<Map<String, dynamic>>? accessories,
    int? totalPages,
    int? currentPage,
    int? totalItems,
  }) {
    return AccessoryLoaded(
      accessories ?? this.accessories,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}

class AccessoryError extends AccessoryState {
  final String message;

  const AccessoryError(this.message);

  @override
  List<Object?> get props => [message];
}
