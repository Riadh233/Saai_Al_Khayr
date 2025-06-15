import 'package:formz/formz.dart';

enum UsernameValidationError{
  invalid,
  invalidLength
}

class Username extends FormzInput<String,UsernameValidationError>{
  const Username.pure() : super.pure('');
  const Username.dirty([super.value = '']) : super.dirty();

  static final RegExp _usernameRegExp =  RegExp(r"^[\p{L} ]+$", unicode: true);


  @override
  UsernameValidationError? validator(String value) {
    if(value.length <2){
      return UsernameValidationError.invalidLength;
    }
    return _usernameRegExp.hasMatch(value ?? '') ? null : UsernameValidationError.invalid;
  }
}