import 'package:formz/formz.dart';

enum LongitudeValidationError { invalid }

class Longitude extends FormzInput<String, LongitudeValidationError> {
  const Longitude.pure() : super.pure('');
  const Longitude.dirty([super.value = '']) : super.dirty();

  @override
  LongitudeValidationError? validator(String value) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < -180 || parsed > 180) {
      return LongitudeValidationError.invalid;
    }
    return null;
  }
}
