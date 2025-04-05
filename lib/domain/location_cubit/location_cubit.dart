import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps_app/domain/location_cubit/location_state.dart';

import '../../data/location_service.dart';

class UserLocationCubit extends Cubit<UserLocationState> {
  final LocationService _locationService = LocationService();

  UserLocationCubit() : super(UserLocationState(latitude: -1, longitude: -1, status: UserLocationStatus.loading));

  void startLocationUpdates() {
    _locationService.locationStream?.listen((locationData) {
      emit(state.copyWith(latitude: locationData.latitude,longitude: locationData.longitude, status: UserLocationStatus.success));
    }, onError: (error) {
      emit(state.copyWith(status: UserLocationStatus.failure,errorMessage: error.toString()));
    });
  }
  void getCurrentLocation() async{
    final location = await _locationService.getCurrentLocation();
    if(location == null){
      emit(state.copyWith(status: UserLocationStatus.failure, errorMessage: 'location error'));
    }else {
      emit(state.copyWith(latitude: location.latitude, longitude: location.longitude, status: UserLocationStatus.success));
    }
  }
}