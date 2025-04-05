
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_app/data/ors_repository.dart';
import 'package:maps_app/domain/ors_cubit/ors_state.dart';

class OrsCubit extends Cubit<OrsState>{
  OrsCubit(this._orsRepository) : super(const OrsState());

  final OpenRouteServiceRepository _orsRepository;
  void getRoute(LatLng start, LatLng end) async {
    try{
      final coordinates = await _orsRepository.getRoute(start, end);
      emit(OrsState(coordinates: coordinates, status: OrsStatus.success));

    }on Exception catch(e){
      emit(state.copyWith(status: OrsStatus.failure));
    }
  }

}