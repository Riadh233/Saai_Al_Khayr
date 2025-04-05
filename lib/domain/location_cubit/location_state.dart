import 'package:equatable/equatable.dart';

enum UserLocationStatus { loading, success, failure }

class UserLocationState extends Equatable {
  final double latitude;
  final double longitude;
  final UserLocationStatus status;
  final String? errorMessage;

  UserLocationState({
    required this.latitude,
    required this.longitude,
    required this.status,
    this.errorMessage,
  });

  UserLocationState copyWith({
    double? latitude,
    double? longitude,
    UserLocationStatus? status,
    String? errorMessage,
  }) {
    return UserLocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, status, errorMessage];
}
