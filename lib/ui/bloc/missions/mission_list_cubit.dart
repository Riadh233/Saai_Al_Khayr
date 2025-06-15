import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/api/database_service.dart';
import '../../../data/models/mission.dart';
import 'missions_list_state.dart';

class MissionsListCubit extends Cubit<MissionsListState> {
  MissionsListCubit(this._databaseService)
    : super(
        MissionsListState(
          missionsList: const <Mission>[],
          searchMissionsList: const <Mission>[],
          statusFilter: 'AVAILABLE',
          daysAgoFilter: 0,
          searchQuery: '',
          status: MissionsListStatus.initial,
        ),
      );
  final DatabaseService _databaseService;


  Future<void> getMissions({String? statusFilter, int? daysAgoFilter}) async {
    try{
      emit(state.copyWith(status: MissionsListStatus.loading));
      final missions = await _databaseService.getMissions(statusFilter ?? state.statusFilter, daysAgoFilter ?? state.daysAgoFilter);
      emit(state.copyWith(missionsList: missions, status: MissionsListStatus.success));
    }on ApiException catch (e) {
      emit(state.copyWith(status: MissionsListStatus.failure, errorMessage: e.message));
    } on TokenException catch (e) {
      //emit token expired
      emit(state.copyWith(status: MissionsListStatus.tokenExpired, errorMessage: e.message));
    }
  }
  Future<void> initMissions() async {
    //gets called each friday
    try{
      emit(state.copyWith(status: MissionsListStatus.loading));
      final isReset = await _databaseService.initMissions();
      final missions = await _databaseService.getMissions(state.statusFilter,state.daysAgoFilter);
      emit(state.copyWith(missionsList:missions, status: MissionsListStatus.success, isReset: isReset));
    }on ApiException catch (e) {
      emit(state.copyWith(status: MissionsListStatus.failure, errorMessage: e.message));
    } on TokenException catch (e) {
      //emit token expired
      emit(state.copyWith(status: MissionsListStatus.tokenExpired, errorMessage: e.message));
    }
  }

  void searchMission(String query){
    final filteredList = state.missionsList
        .where((mission) =>
    mission.mosque.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    emit(state.copyWith(
        searchMissionsList: filteredList,
        searchQuery: query,
    ));
  }
  void clearSearchQuery(){
    emit(state.copyWith(searchQuery: ''));
  }
  void addStatusFilter(String filter){
    emit(state.copyWith(statusFilter: filter));
  }
}
