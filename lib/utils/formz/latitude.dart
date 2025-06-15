import 'package:formz/formz.dart';

enum LatitudeValidationError { invalid }

class Latitude extends FormzInput<String, LatitudeValidationError> {
  const Latitude.pure() : super.pure('');
  const Latitude.dirty([super.value = '']) : super.dirty();

  @override
  LatitudeValidationError? validator(String value) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < -90 || parsed > 90) {
      return LatitudeValidationError.invalid;
    }
    return null;
  }
}
