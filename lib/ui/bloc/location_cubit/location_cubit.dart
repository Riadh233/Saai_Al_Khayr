import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/data/models/driver_mission.dart';
import 'package:maps_app/main.dart';
import 'package:url_launcher/url_launcher.dart';

import 'location_state.dart';

class UserLocationCubit extends Cubit<UserLocationState> {
  StreamSubscription<Position>? _positionStream;

  UserLocationCubit()
    : super(
        UserLocationState(
          latitude: -1,
          longitude: -1,
          status: UserLocationStatus.initial,
          mapsStatus: GoogleMapsStatus.initial,
        ),
      );

  Future<bool> _checkPermissions() async {
    // 1. Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool didEnable = await Geolocator.openLocationSettings();
      if (!didEnable) {
        return false; // User refused to enable location
      }
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return false; // User denied permissions
      }
    }

    return true;
  }

  void startLocationUpdates() async {
    if (!await _checkPermissions()) {
      emit(state.copyWith(status: UserLocationStatus.failure));
      return;
    }

    _positionStream = Geolocator.getPositionStream(

      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
            'سيتم إشعارك عند الوصول.',
            notificationTitle: 'تتبع الموقع قيد التشغيل',
            enableWakeLock: false,
          )
      ),
    ).listen(
      (Position position) {
        emit(
          state.copyWith(
            latitude: position.latitude,
            longitude: position.longitude,
            status: UserLocationStatus.success,
          ),
        );
        if (state.pickedMission != null) {
          logger.log(Logger.level, 'destination picked');
          //send to the backend
        }
      },
      onError: (e) {
        emit(
          state.copyWith(
            status: UserLocationStatus.failure,
            errorMessage: e.toString(),
          ),
        );
      },
    );
  }

  void getCurrentLocation() async {
    emit(state.copyWith(status: UserLocationStatus.loading));

    try {
      if (!await _checkPermissions()) {
        emit(state.copyWith(status: UserLocationStatus.failure));
        return;
      }
      emit(state.copyWith(status: UserLocationStatus.loading));
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      emit(
        state.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          status: UserLocationStatus.success,
        ),
      );
    } catch (e) {
      logger.log(Logger.level, 'loading loacation failed $e');
      emit(
        state.copyWith(
          status: UserLocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void setPickedMission(MissionCoordinates pickedMission) {
    emit(state.copyWith(pickedMission: pickedMission, status: UserLocationStatus.pickedMissionSuccess));
  }

  void openGoogleMaps() async {
    final destLat = state.pickedMission!.missionCoordinates.latitude;
    final destLng = state.pickedMission!.missionCoordinates.longitude;

    // final service = FlutterBackgroundService();
    // if (!(await service.isRunning())) {
    //   _appService.initializeService();
    //   logger.log(Logger.level, 'service started successfully ..');
    // } else {
    //   logger.log(Logger.level, 'failed to start service ....');
    // }
    // service.invoke('setDestination', {
    //   'latitude': destLat,
    //   'longitude': destLng,
    // });

    final googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=${state.latitude},${state.longitude}&destination=$destLat,$destLng&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      emit(state.copyWith(mapsStatus: GoogleMapsStatus.loading));
      await launchUrl(
        Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication,
      );
      emit(state.copyWith(mapsStatus: GoogleMapsStatus.success));
    } else {
      emit(state.copyWith(mapsStatus: GoogleMapsStatus.failure));
    }
  }


  @override
  Future<void> close() {
    _positionStream?.cancel();
    return super.close();
  }
}
