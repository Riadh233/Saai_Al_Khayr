import 'package:equatable/equatable.dart';
import 'package:maps_app/data/models/mission.dart';
import 'package:maps_app/data/models/mosque.dart';

enum ImamProfileStatus {initial, loading, success, failure, tokenExpired}
class ImamState extends Equatable {
  final String imamName;
  final String imamNumber;
  final Mosque? mosque;
  final ImamProfileStatus status;
  final String? errorMessage;

  const ImamState({
    this.imamName = '',
    this.imamNumber = '',
    this.mosque = const Mosque(
      id: 3,
      name: 'Mosquée En-Nour',
      address: 'Hydra, Alger',
      lat: '36.7487',
      ling: '3.0463',
      isApproved: null,
      imam: null,
    ),
    this.status = ImamProfileStatus.initial,
    this.errorMessage

  });

  @override
  List<Object?> get props => [imamName, imamNumber, mosque,errorMessage,status];

  ImamState copyWith({
    String? imamName,
    String? imamNumber,
    Mosque? mosque,
    ImamProfileStatus? status,
    String? errorMessage
  }) {
    return ImamState(
      imamName: imamName ?? this.imamName,
      imamNumber: imamNumber ?? this.imamNumber,
      mosque: mosque ?? this.mosque,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage
    );
  }
}
