import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/data/api/driver_api_service.dart';
import 'package:maps_app/data/models/driver_mission.dart';
import 'package:maps_app/main.dart';

import '../../../../data/api/database_service.dart';
import 'driver_missions_state.dart';


class DriverMissionsCubit extends Cubit<DriverMissionsState>{

  final DriverApiService _apiService;

  DriverMissionsCubit(this._apiService) : super(DriverMissionsState());

  Future<void> getAvailableMissions(LatLng currentLocation) async {
    try{
      emit(state.copyWith(status: DriverMissionsStatus.loading));
      final missions = await _apiService.getAvailableMissions(currentLocation);
      emit(state.copyWith(missionsList: missions, status: DriverMissionsStatus.success));
    }on ApiException catch(e){
      emit(state.copyWith(status: DriverMissionsStatus.failed, errorMessage: e.message));
    }on TokenException catch(e){
      //emit token expired
      emit(state.copyWith(status: DriverMissionsStatus.tokenExpired, errorMessage: e.message));
    }
  }
  Future<void> pickMission(DriverMission mission, LatLng currLocation) async {
    try{
      emit(state.copyWith(status: DriverMissionsStatus.loading));
      final pickedMission = await _apiService.pickMission(mission.id, currLocation);
      if(pickedMission == MissionCoordinates.defaultMission){
        logger.log(Logger.level,'mission is already picked');
        emit(state.copyWith(status: DriverMissionsStatus.pickMissionFailed));
        return;
      }
      logger.log(Logger.level,'mission picked success in cubit');
      emit(state.copyWith(pickedMission: pickedMission, status: DriverMissionsStatus.pickMissionSuccess));
    }on ApiException catch(e){
      logger.log(Logger.level,'error picking mission;${e.message}');
      emit(state.copyWith(status: DriverMissionsStatus.failed, errorMessage: e.message));
    }on TokenException catch(e){
      //emit token expired
      emit(state.copyWith(status: DriverMissionsStatus.tokenExpired, errorMessage: e.message));
    }
  }
  Future<void> getPickedMission(LatLng currLocation) async {
    try{
      emit(state.copyWith(status: DriverMissionsStatus.loading));
      final pickedMission = await _apiService.getPickedMission(currLocation);
      emit(state.copyWith(pickedMission: pickedMission, status: DriverMissionsStatus.success));
    }on ApiException catch(e){
      emit(state.copyWith(pickedMission:null, status: DriverMissionsStatus.failed, errorMessage: e.message));
    }on TokenException catch(e){
      //emit token expired
      emit(state.copyWith(status: DriverMissionsStatus.tokenExpired, errorMessage: e.message));
    }
  }
  Future<void> cancelPickedMission() async {
    try{
      emit(state.copyWith(status: DriverMissionsStatus.loading));
      await _apiService.cancelPickedMission(state.pickedMission!.missionId!);
      emit(state.copyWith(pickedMission: null, status: DriverMissionsStatus.missionCanceledSuccess));
    }on ApiException catch(e){
      logger.log(Logger.level, 'mission cancel failed ${e.message} ');
      emit(state.copyWith(status: DriverMissionsStatus.failed, errorMessage: e.message));
    }on TokenException catch(e){
      //emit token expired
      emit(state.copyWith(status: DriverMissionsStatus.tokenExpired, errorMessage: e.message));
    }
  }
  void updateFilter(String filter) {
    emit(state.copyWith(selectedFilter: filter));
  }
}