import 'dart:ffi';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/data/api/imam_api_service.dart';
import 'package:maps_app/main.dart';
import 'package:maps_app/utils/formz/arabic_money.dart';
import 'package:maps_app/utils/formz/dzd_money.dart';

import '../../../data/api/database_service.dart';
import 'imam_missions_state.dart';


class ImamMissionsCubit extends Cubit<ImamMissionsState>{
  ImamMissionsCubit(this._imamService) : super(ImamMissionsState());
  
  final ImamApiService _imamService;

  Future<void> getActiveMission() async {
    try {
      emit(state.copyWith(status: ImamMissionsStatus.loading));
      final mission = await _imamService.getMissionForFriday();
      final initialAmount = mission.amount != "0" ? DzdAmountInput.dirty(mission.amount) : const DzdAmountInput.pure();
      final initialArabicAmount = (mission.amountArabic != null && mission.amountArabic!.isNotEmpty)
          ? ArabicAmountInput.dirty(mission.amountArabic!)
          : const ArabicAmountInput.pure();

      emit(state.copyWith(
        status: ImamMissionsStatus.success,
        currentMission: mission,
        amount: initialAmount,
        arabicAmount: initialArabicAmount,
        isValid: Formz.validate([initialAmount]),
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(currentMission: null, status: ImamMissionsStatus.failed, errorMessage: e.message));
    } on TokenException catch (e) {
      emit(state.copyWith(status: ImamMissionsStatus.tokenExpired, errorMessage: e.message));
    }
  }

  Future<void> addMoneyToMission() async {
    try{
      emit(state.copyWith(status: ImamMissionsStatus.loading));
      await _imamService.addMoneyToMission(state.currentMission!.missionId, state.amount.value, state.arabicAmount?.value);
      emit(state.copyWith(status: ImamMissionsStatus.amountSuccess));
    } on ApiException catch(e){
      emit(state.copyWith(currentMission: null, status: ImamMissionsStatus.failed, errorMessage: e.message));
    } on TokenException catch(e){
      //emit token expired
      emit(state.copyWith(status: ImamMissionsStatus.tokenExpired, errorMessage: e.message));
    }
  }
  Future<void> modifyMoneyForMission() async {
    logger.log(Logger.level, 'udapte money called...');
    try{
      emit(state.copyWith(status: ImamMissionsStatus.loading));
      await _imamService.updateMoneyForMission(state.currentMission!.missionId, state.amount.value, state.arabicAmount.value);
      emit(state.copyWith(status: ImamMissionsStatus.amountSuccess));
    } on ApiException catch(e){
      emit(state.copyWith(currentMission: null, status: ImamMissionsStatus.failed, errorMessage: e.message));
    } on TokenException catch(e){
      //emit token expired
      emit(state.copyWith(status: ImamMissionsStatus.tokenExpired, errorMessage: e.message));
    }
  }

  void validateAmount(String value){
    final amount = DzdAmountInput.dirty(value);
    emit(state.copyWith(amount: amount, isValid: Formz.validate([amount])));
  }
  void validateArabicAmount(String value){
    final arabicAmount = ArabicAmountInput.dirty(value);
    emit(state.copyWith(arabicAmount: arabicAmount, isValid: Formz.validate([state.amount])));

  }

  @override
  void onChange(Change<ImamMissionsState> change) {
    super.onChange(change);
    logger.log(Logger.level, 'ImamMissionsCubit state changed: ${change.nextState.status}');
  }
}