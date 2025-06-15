import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:maps_app/data/models/completed_mission.dart';
import 'package:maps_app/data/models/mission.dart';
import 'package:maps_app/utils/formz/arabic_money.dart';
import 'package:maps_app/utils/formz/dzd_money.dart';

enum ImamMissionsStatus { initial, loading, success, failed, tokenExpired, amountSuccess }

class ImamMissionsState extends Equatable {
  final CompletedMission? currentMission;
  final ImamMissionsStatus status;
  final String? errorMessage;
  final DzdAmountInput amount;
  final ArabicAmountInput arabicAmount;
  final FormzSubmissionStatus formzStatus;
  final bool isValid;

  const ImamMissionsState({
    this.currentMission,
    this.status = ImamMissionsStatus.initial,
    this.errorMessage,
    this.amount = const DzdAmountInput.pure(),
    this.arabicAmount = const ArabicAmountInput.pure(),
    this.formzStatus = FormzSubmissionStatus.initial,
    this.isValid = false
  });

  ImamMissionsState copyWith({
    CompletedMission? currentMission,
    ImamMissionsStatus? status,
    String? errorMessage,
    DzdAmountInput? amount,
    ArabicAmountInput? arabicAmount,
    FormzSubmissionStatus? formzStatus,
    bool? isValid
  }) {
    return ImamMissionsState(
      currentMission: currentMission ?? this.currentMission,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      amount: amount ?? this.amount,
      arabicAmount: arabicAmount ?? this.arabicAmount,
      formzStatus: formzStatus ?? this.formzStatus,
      isValid: isValid ?? this.isValid
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [currentMission, status, errorMessage, amount, arabicAmount, formzStatus, isValid];
}
