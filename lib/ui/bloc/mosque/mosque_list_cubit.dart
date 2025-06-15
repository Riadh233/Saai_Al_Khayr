import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/api/database_service.dart';
import 'mosque_list_state.dart';

class MosqueListCubit extends Cubit<MosqueListState>{
  MosqueListCubit(this._databaseService) : super(MosqueListState());
  final DatabaseService _databaseService;

  void getAllMosques() async {
    try{
      emit(state.copyWith(status: MosqueListStatus.loading));
      final mosqueList = await _databaseService.getAllMosques();
      emit(state.copyWith(mosquesList: mosqueList,status: MosqueListStatus.success));
    }on ApiException catch(e){
      emit(state.copyWith(status: MosqueListStatus.failed, errorMessage: e.message));
    }on TokenException catch(e){
      //emit token expired
      emit(state.copyWith(status: MosqueListStatus.tokenExpired, errorMessage: e.message));
    }
  }

  void searchMosque(String query){
    final filteredList = state.mosquesList
        .where((user) =>
    user.name.toLowerCase().contains(query.toLowerCase())).toList();
    emit(state.copyWith(
        filteredList: filteredList,
        searchQuery: query,
        errorMessage: ''
    ));
  }

}