
import 'package:formz/formz.dart';

enum PasswordValidationError{
  invalid,
  invalidLength
}

class Password extends FormzInput<String,PasswordValidationError>{
  const Password.pure() : super.pure('');
  const Password.dirty([super.value = '']) : super.dirty();

  static final RegExp _passwordRegExp =  RegExp(r"^.+$");
  @override
  PasswordValidationError? validator(String value) {
    if (value.trim().length < 6) {
      return PasswordValidationError.invalidLength;
    } else if (!_passwordRegExp.hasMatch(value)) {
      return PasswordValidationError.invalid;
    }
    return null;
  }
}