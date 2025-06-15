import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/data/api/imam_api_service.dart';
import 'package:maps_app/main.dart';

import '../../../data/api/database_service.dart';
import 'imam_state.dart';

class ImamCubit extends Cubit<ImamState> {
  ImamCubit(this._imamService) : super(ImamState());

  final ImamApiService _imamService;

  Future<void> getImamInfos() async {
    try {
      emit(state.copyWith(status: ImamProfileStatus.loading));
      final imam = await _imamService.getImamInfo();
      logger.log(Logger.level, imam.mosque.toString());
      emit(
        state.copyWith(
          imamName: '${imam.firstName} ${imam.lastName}',
          imamNumber: imam.phone,
          mosque: imam.mosque,
          status: ImamProfileStatus.success,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: ImamProfileStatus.failure,
          errorMessage: e.message,
        ),
      );
    } on TokenException catch (e) {
      //emit token expired
      emit(
        state.copyWith(
          status: ImamProfileStatus.tokenExpired,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> updateMosqueLocation(double lat, double lng) async {
    try {
      emit(state.copyWith(status: ImamProfileStatus.loading));
      await _imamService.updateMosqueLocation(lat, lng);
      emit(state.copyWith(status: ImamProfileStatus.success));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: ImamProfileStatus.failure,
          errorMessage: e.message,
        ),
      );
    } on TokenException catch (e) {
      //emit token expired
      emit(
        state.copyWith(
          status: ImamProfileStatus.tokenExpired,
          errorMessage: e.message,
        ),
      );
    }
  }
}
