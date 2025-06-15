import 'package:equatable/equatable.dart';
import 'package:maps_app/data/models/driver_mission.dart';

enum UserLocationStatus { initial, loading, success, failure, pickedMissionSuccess }
enum GoogleMapsStatus { initial, loading, success, failure }

class UserLocationState extends Equatable {
  final double latitude;
  final double longitude;
  final MissionCoordinates? pickedMission;
  final UserLocationStatus status;
  final GoogleMapsStatus mapsStatus;
  final String? errorMessage;

  const UserLocationState({
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.mapsStatus,
    this.errorMessage,
    this.pickedMission
  });

  UserLocationState copyWith({
    double? latitude,
    double? longitude,
    UserLocationStatus? status,
    GoogleMapsStatus? mapsStatus,
    String? errorMessage,
    MissionCoordinates? pickedMission
  }) {
    return UserLocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      mapsStatus: mapsStatus ?? this.mapsStatus,
      errorMessage: errorMessage ?? this.errorMessage,
        pickedMission: pickedMission ?? this.pickedMission
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, status,mapsStatus, errorMessage, pickedMission];
}
