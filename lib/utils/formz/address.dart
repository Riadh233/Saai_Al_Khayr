import 'package:formz/formz.dart';

enum AddressValidationError { invalid, tooShort }

class Address extends FormzInput<String, AddressValidationError> {
  const Address.pure() : super.pure('');
  const Address.dirty([super.value = '']) : super.dirty();

  static final _addressRegExp = RegExp(r"^[\p{L}\d\s,.\-_/#()]+$", unicode: true);

  @override
  AddressValidationError? validator(String value) {
    if (value.trim().length < 3) {
      return AddressValidationError.tooShort;
    }
    return null;
  }
}
