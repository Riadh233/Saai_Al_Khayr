import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:maps_app/data/models/user.dart';
import 'package:maps_app/utils/formz/address.dart';
import 'package:maps_app/utils/formz/latitude.dart';
import 'package:maps_app/utils/formz/longitude.dart';
import 'package:maps_app/utils/formz/username.dart';

enum AddMosqueStatus{initial,loading, success, failed,tokenExpired, detailsLoaded, imamsLoaded}

class AddMosqueState extends Equatable {
  final Username name;
  final User imam;
  final List<User> imamsList;
  final Address address;
  final Latitude latitude;
  final Longitude longitude;
  final bool isApproved;
  final FormzSubmissionStatus status;
  final AddMosqueStatus loadStatus;
  final bool isValid;
  final String? errorMessage;

  const AddMosqueState({
    this.name = const Username.pure(),
    this.imam = User.empty,
    this.imamsList = const <User> [],
    this.address = const Address.pure(),
    this.latitude = const Latitude.pure(),
    this.longitude = const Longitude.pure(),
    this.isApproved = true,
    this.status = FormzSubmissionStatus.initial,
    this.loadStatus = AddMosqueStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });

  AddMosqueState copyWith({
    Username? name,
    User? imam,
    List<User>? imamsList,
    Address? address,
    Latitude? latitude,
    Longitude? longitude,
    bool? isApproved,
    FormzSubmissionStatus? status,
    AddMosqueStatus? loadStatus,
    bool? isValid,
    String? errorMessage,
  }) {
    return AddMosqueState(
      name: name ?? this.name,
      imam: imam ?? this.imam,
      imamsList: imamsList ?? this.imamsList,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isApproved: isApproved ?? this.isApproved,
      status: status ?? this.status,
      loadStatus: loadStatus ?? this.loadStatus,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    name,
    imam,
    imamsList,
    address,
    latitude,
    longitude,
    isApproved,
    status,
    loadStatus,
    isValid,
    errorMessage,
  ];
}
