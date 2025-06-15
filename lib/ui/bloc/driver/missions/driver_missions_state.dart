import 'package:equatable/equatable.dart';
import 'package:maps_app/data/models/driver_mission.dart';

enum DriverMissionsStatus { initial, loading, success,pickMissionSuccess,pickMissionFailed, missionCanceledSuccess ,failed, tokenExpired }

class DriverMissionsState extends Equatable {
  final List<DriverMission> missionsList;
  final MissionCoordinates? pickedMission;
  final DriverMissionsStatus status;
  final String selectedFilter;
  final String? errorMessage;

  const DriverMissionsState({
    this.missionsList = const <DriverMission>[],
    this.pickedMission,
    this.status = DriverMissionsStatus.initial,
    this.selectedFilter = 'متاحة',
    this.errorMessage,
  });

  DriverMissionsState copyWith({
    List<DriverMission>? missionsList,
    MissionCoordinates? pickedMission,
    DriverMissionsStatus? status,
    String? errorMessage,
    String? selectedFilter
  }) {
    return DriverMissionsState(
      missionsList: missionsList ?? this.missionsList,
      pickedMission: pickedMission ?? this.pickedMission,
      status: status ?? this.status,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    missionsList,
    pickedMission,
    status,
    errorMessage,
    selectedFilter
  ];
}
