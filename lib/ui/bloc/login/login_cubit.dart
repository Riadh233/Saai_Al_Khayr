import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/data/api/database_service.dart';
import 'package:maps_app/main.dart';
import '../../../utils/formz/password.dart';
import '../../../utils/formz/username.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState>{
  LoginCubit(this._databaseServiceRepository) : super(const LoginState());

  final DatabaseService _databaseServiceRepository;

  void firstNameChanged(String value) {
    final firstName = Username.dirty(value);
    emit(state.copyWith(
        firstName: firstName, isValid: Formz.validate([firstName,state.lastName, state.password])));
  }
  void lastNameChanged(String value) {
    final lastName = Username.dirty(value);
    emit(state.copyWith(
        lastName: lastName, isValid: Formz.validate([lastName,state.firstName, state.password])));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(state.copyWith(
        password: password, isValid: Formz.validate([state.firstName,state.lastName, password])));
  }

  void passwordVisibilityChanged() {
    emit(state.copyWith(hidePassword: !(state.hidePassword)));
  }

  void signIn() async{
    if (!state.isValid) return;

    emit(state.copyWith(loginStatus: LoginStatus.loading));
    try {
      final role = await _databaseServiceRepository
          .signIn(
        firstName: state.firstName.value,
        lastName: state.lastName.value,
        password: state.password.value,
      );
      logger.log(Logger.level, 'login succeful: $role');
      emit(state.copyWith(loginStatus: LoginStatus.success, role: role));
    } on ApiException catch (e) {
      logger.log(Logger.level, e.message);
      emit(state.copyWith(loginStatus: LoginStatus.failed, errorMessage: e.message));
    }
  }
}