import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:maps_app/utils/formz/car_number.dart';
import '../../../data/models/user.dart';
import '../../../utils/formz/confirmed_password.dart';
import '../../../utils/formz/password.dart';
import '../../../utils/formz/phone_number.dart';
import '../../../utils/formz/username.dart';
import 'add_user_state.dart';

class AddUserCubit extends Cubit<AddUserState> {
  AddUserCubit() : super(const AddUserState());


  void initialValues(User user) {
    emit(AddUserState(
        firstName: Username.dirty(user.firstName),
        lastName: Username.dirty(user.lastName),
        carNumber: CarPlateNumber.dirty(user.carNumber ?? ''),
        number: PhoneNumber.dirty(user.number!),
        password: Password.dirty(user.password),
        confirmedPassword: ConfirmedPassword.dirty(
            password: user.password, value: user.password),
        isValid: true));
  }

  void firstNameChanged(String value) {
    final username = Username.dirty(value);

    emit(state.copyWith(
        firstName: username,
        isValid: Formz.validate([
          username,
          state.lastName,
          state.number,
          state.password,
          state.confirmedPassword
        ])));
  }
  void lastNameChanged(String value) {
    final username = Username.dirty(value);

    emit(state.copyWith(
        lastName: username,
        isValid: Formz.validate([
          username,
          state.firstName,
          state.number,
          state.password,
          state.confirmedPassword
        ])));
  }

  void numberChanged(String value) {
    final number = PhoneNumber.dirty(value);
    emit(state.copyWith(
        number: number,
        isValid:
        Formz.validate([number, state.password, state.confirmedPassword])));
  }
  void carNumberChanged(String value) {
    final carNumber = CarPlateNumber.dirty(value);
    emit(state.copyWith(
        carNumber: carNumber,
        isValid:
        Formz.validate([carNumber, state.password, state.confirmedPassword])));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    final confirmedPassword =
    ConfirmedPassword.dirty(password: password.value, value: value);
    emit(state.copyWith(
        password: password,
        confirmedPassword: confirmedPassword,
        isValid: Formz.validate([state.number, password, confirmedPassword])));
  }

  void passwordVisibilityChanged() {
    emit(state.copyWith(hidePassword: !(state.hidePassword)));
  }

  void confirmedPasswordChanged(String value) {
    final confirmedPassword =
    ConfirmedPassword.dirty(password: state.password.value, value: value);
    emit(state.copyWith(
        confirmedPassword: confirmedPassword,
        isValid:
        Formz.validate([state.number, state.password, confirmedPassword])));
  }
}
