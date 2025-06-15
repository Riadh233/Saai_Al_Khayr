import 'package:formz/formz.dart';

enum CarPlateNumberValidationError { invalid }

class CarPlateNumber extends FormzInput<String, CarPlateNumberValidationError> {
  const CarPlateNumber.pure() : super.pure('');

  const CarPlateNumber.dirty([String value = '']) : super.dirty(value);

  // Regular expression to match only numbers
  static final RegExp _plateRegExp = RegExp(r'^\d+$');

  @override
  CarPlateNumberValidationError? validator(String value) {
    return _plateRegExp.hasMatch(value) ? null : CarPlateNumberValidationError.invalid;
  }
}
