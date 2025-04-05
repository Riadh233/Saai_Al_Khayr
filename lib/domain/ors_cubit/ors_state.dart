import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

enum OrsStatus{loading , success, failure}
class OrsState extends Equatable{
  final List<LatLng> coordinates;
  final OrsStatus status;

  const OrsState({this.coordinates = const <LatLng>[], this.status = OrsStatus.loading});

  OrsState copyWith({List<LatLng>? coordinates, OrsStatus? status}){
    return OrsState(
      coordinates: coordinates ?? this.coordinates,
      status: status ?? this.status
    );
  }
  @override
  List<Object?> get props => [coordinates, status];

}