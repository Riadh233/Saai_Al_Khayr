import 'package:equatable/equatable.dart';
import 'package:maps_app/data/models/mission.dart';

enum MissionsListStatus { initial, loading, success, failure, tokenExpired }

class MissionsListState extends Equatable {
  final List<Mission> missionsList;
  final List<Mission> searchMissionsList;
  final String statusFilter;
  final int daysAgoFilter;
  final String searchQuery;
  final MissionsListStatus status;
  final String? errorMessage;
  final bool isReset;

  const MissionsListState({
    required this.missionsList,
    required this.searchMissionsList,
    required this.statusFilter,
    required this.daysAgoFilter,
    required this.searchQuery,
    required this.status,
    this.errorMessage,
    this.isReset = false, // Default to false
  });

  MissionsListState copyWith({
    List<Mission>? missionsList,
    List<Mission>? searchMissionsList,
    String? statusFilter,
    int? daysAgoFilter,
    String? searchQuery,
    MissionsListStatus? status,
    String? errorMessage,
    bool? isReset,
  }) {
    return MissionsListState(
      missionsList: missionsList ?? this.missionsList,
      searchMissionsList: searchMissionsList ?? this.searchMissionsList,
      statusFilter: statusFilter ?? this.statusFilter,
      daysAgoFilter: daysAgoFilter ?? this.daysAgoFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isReset: isReset ?? this.isReset, // Include isReset in copyWith
    );
  }

  @override
  List<Object?> get props => [
    missionsList,
    searchMissionsList,
    statusFilter,
    daysAgoFilter,
    searchQuery,
    status,
    errorMessage,
    isReset, // Add to props for comparison
  ];
}
