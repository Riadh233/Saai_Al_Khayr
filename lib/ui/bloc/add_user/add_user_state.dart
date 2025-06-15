import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../utils/formz/car_number.dart';
import '../../../utils/formz/confirmed_password.dart';
import '../../../utils/formz/password.dart';
import '../../../utils/formz/phone_number.dart';
import '../../../utils/formz/username.dart';


class AddUserState extends Equatable {
  const AddUserState(
      {
        this.firstName = const Username.pure(),
        this.lastName = const Username.pure(),
        this.number = const PhoneNumber.pure(),
        this.carNumber = const CarPlateNumber.pure(), // Added carNumber field
        this.password = const Password.pure(),
        this.status = FormzSubmissionStatus.initial,
        this.confirmedPassword = const ConfirmedPassword.pure(),
        this.isValid = false,
        this.hidePassword = false,
        this.errorMessage});

  final PhoneNumber number;
  final Username firstName;
  final Username lastName;
  final CarPlateNumber carNumber; // Added carNumber field
  final Password password;
  final FormzSubmissionStatus status;
  final bool isValid;
  final bool hidePassword;
  final ConfirmedPassword confirmedPassword;
  final String? errorMessage;

  AddUserState copyWith(
      {PhoneNumber? number,
        Username? firstName,
        Username? lastName,
        CarPlateNumber? carNumber, // Added carNumber to copyWith
        Password? password,
        ConfirmedPassword? confirmedPassword,
        FormzSubmissionStatus? status,
        bool? isValid,
        bool? hidePassword,
        String? errorMessage}) {
    return AddUserState(
        number: number ?? this.number,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        carNumber: carNumber ?? this.carNumber, // Added carNumber to copyWith
        password: password ?? this.password,
        confirmedPassword: confirmedPassword ?? this.confirmedPassword,
        status: status ?? this.status,
        isValid: isValid ?? this.isValid,
        hidePassword: hidePassword ?? this.hidePassword,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props =>
      [number, firstName, lastName, carNumber, password, confirmedPassword, status, isValid, hidePassword, errorMessage];
}
