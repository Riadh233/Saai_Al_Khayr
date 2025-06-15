import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'internet_connection_event.dart';

enum InternetState {online,offline,unknown}

class InternetConnectionBloc extends Bloc<InternetConnectionEvent,InternetState>{
  InternetConnectionBloc() : super(InternetState.unknown){
    on<AppStartedEvent>(_onAppStarted);
    on<OnCheckInternetEvent>(_onCheckInternetConnection);
    _subscription =  InternetConnection().onStatusChange.listen((internetStatus) {
      add(OnCheckInternetEvent(internetStatus));
      },
    );
  }

  late final StreamSubscription _subscription;

  void _onAppStarted(AppStartedEvent event,Emitter emit) async {
    bool isConnected = await InternetConnection().hasInternetAccess;
    if (isConnected) {
      emit(InternetState.online);
    } else {
      emit(InternetState.offline);
    }
  }
  void _onCheckInternetConnection(OnCheckInternetEvent event,Emitter<InternetState> emit) async{
    if (event.status == InternetStatus.connected) {
      emit(InternetState.online);
    } else {
      emit(InternetState.offline);
    }
  }
  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}