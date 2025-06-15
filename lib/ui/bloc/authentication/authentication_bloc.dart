import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/data/local/local_storage_repository.dart';
import 'package:maps_app/main.dart';

import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({required databaseService, required localStorageRepository})
      : _localStorageRepository = localStorageRepository,
        super(const AuthenticationState.authenticated()) {
    on<AppStarted>(_onAppStarted);
    on<AdminLoginRequested>(_loginRequested);
    on<AdminLogoutRequested>(_logoutRequested);
  }

  final LocalStorageRepository _localStorageRepository;

  void _onAppStarted(AppStarted event,
      Emitter<AuthenticationState> emit) async {
    try {
      emit(AuthenticationState.unknown());
      final isAdminLoggedIn = await _localStorageRepository.getToken();
      final userRole = await _localStorageRepository.getUserRole();
      logger.log(Logger.level, 'is admin logged in $isAdminLoggedIn');
      emit(isAdminLoggedIn != null
          ?  AuthenticationState.authenticated(userRole: userRole)
          : const AuthenticationState.unauthenticated());
    } catch (error) {
      logger.log(Logger.level, error);
      emit(const AuthenticationState.unauthenticated());
    }
  }

  void _logoutRequested(AdminLogoutRequested event,
      Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationState.unauthenticated());
  }

  void _loginRequested(AdminLoginRequested event,
      Emitter<AuthenticationState> emit) async{
    logger.log(Logger.level, event.role);
    emit( AuthenticationState.authenticated(userRole: event.role));
  }

  @override
  void onChange(Change<AuthenticationState> change) {
    // TODO: implement onChange
    logger.log(Logger.level, 'auth state change : ${change.currentState.status},${change.nextState.status}');
    super.onChange(change);
  }
}
