import 'package:formz/formz.dart';

enum ArabicAmountValidationError { invalid }

class ArabicAmountInput extends FormzInput<String, ArabicAmountValidationError> {
  const ArabicAmountInput.pure() : super.pure('');
  const ArabicAmountInput.dirty([String value = '']) : super.dirty(value);

  static final RegExp _arabicTextRegex = RegExp(r'^[\u0600-\u06FF\s]+$');

  @override
  ArabicAmountValidationError? validator(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (!_arabicTextRegex.hasMatch(trimmed)) return ArabicAmountValidationError.invalid;
    return null;
  }
}
