import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeLoading()) {
    on<LoadHomeEvent>((event, emit) async {
      await Future.delayed(Duration(seconds: 1));
      emit(HomeLoaded());
    });
    on<LogoutEvent>((event, emit) {
      emit(HomeLoading());
    });
  }
}
