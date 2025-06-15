import 'package:formz/formz.dart';

enum DzdAmountValidationError { empty, invalid }

class DzdAmountInput extends FormzInput<String, DzdAmountValidationError> {
  const DzdAmountInput.pure() : super.pure('');
  const DzdAmountInput.dirty([String value = '']) : super.dirty(value);

  static final RegExp _numericRegex = RegExp(r'^\d+(\.\d{1,2})?$');

  @override
  DzdAmountValidationError? validator(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return DzdAmountValidationError.empty;
    if (!_numericRegex.hasMatch(trimmed)) return DzdAmountValidationError.invalid;
    return null;
  }
}
