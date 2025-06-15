import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:maps_app/data/models/user.dart';

import '../../../utils/formz/password.dart';
import '../../../utils/formz/username.dart';

enum LoginStatus {initial, loading, success, failed }

class LoginState extends Equatable {
  const LoginState({
    this.firstName = const Username.pure(),
    this.lastName = const Username.pure(),
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.loginStatus = LoginStatus.initial,
    this.isValid = false,
    this.hidePassword = false,
    this.errorMessage,
    this.role
  });

  final Username firstName;
  final Username lastName;
  final Password password;
  final FormzSubmissionStatus status;
  final LoginStatus loginStatus;
  final bool isValid;
  final String? errorMessage;
  final UserRole? role;
  final bool hidePassword;

  LoginState copyWith({
    Username? firstName,
    Username? lastName,
    Password? password,
    FormzSubmissionStatus? status,
    LoginStatus? loginStatus,
    bool? isValid,
    bool? hidePassword,
    String? errorMessage,
    UserRole? role
  }) {
    return LoginState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
      status: status ?? this.status,
      loginStatus: loginStatus ?? this.loginStatus,
      isValid: isValid ?? this.isValid,
      hidePassword: hidePassword ?? this.hidePassword,
      errorMessage: errorMessage ?? this.errorMessage,
      role: role ?? this.role
    );
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    password,
    status,
    loginStatus,
    isValid,
    hidePassword,
    errorMessage,
    role
  ];
}
