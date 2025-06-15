import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/main.dart';

class DriverMission {
  final int id;
  final String mosqueName;
  final String mosqueAddress;
  final String distance;
  final String time;
  final String imamName;
  final String imamNumber;
  final String? status;

  const DriverMission({
    required this.id,
    required this.mosqueName,
    required this.mosqueAddress,
    required this.distance,
    required this.time,
    required this.imamName,
    required this.imamNumber,
    this.status,
  });

  static const empty = DriverMission(
    id: -1,
    mosqueName: '',
    mosqueAddress: '',
    distance: '0',
    time: '0',
    imamName: '',
    imamNumber: '',
  );

  factory DriverMission.fromJson(int missionId, Map<String, dynamic> json) {
    return DriverMission(
      id: missionId,
      mosqueName: json['name'],
      mosqueAddress: json['address'],
      distance: json['distance_readable'],
      time: json['duration_readable'],
      imamName: '',
      imamNumber: json['phone_number'],
    );
  }
}

class MissionCoordinates {
  final int? missionId;
  final List<LatLng> shortestPath;
  final LatLng missionCoordinates;
  final String distance;
  final String duration;
  final String? mosqueName;
  final String? mosqueAddress;
  final bool? alreadyPicked;

  const MissionCoordinates({
    this.missionId,
    required this.shortestPath,
    required this.missionCoordinates,
    required this.distance,
    required this.duration,
    this.mosqueName,
    this.mosqueAddress,
    this.alreadyPicked
  });

  static const defaultMission = MissionCoordinates(
    shortestPath: const [],
    mosqueName: 'مسجد الفتح',
    mosqueAddress: 'حي الربيع، قسنطينة',
    missionCoordinates: LatLng(36.756061, 3.442273),
    distance: '15.35',
    duration: '15.35',
  );

  factory MissionCoordinates.fromJson(Map<String, dynamic> json) {
    final coordinates = json['navigation']['route'];
    final polylinePoints = coordinates.map<LatLng>((point ) {
      final lat = point['lat'] as double;
      final lng = point['lng'] as double;
      return LatLng(lat, lng);
    }).toList();
    final destination = json['navigation']['end_point'];
     final lat = double.parse(destination['lat']);
     final lng = double.parse(destination['lng']);
    return MissionCoordinates(
      missionId: json['mission_details']['id'] ?? -1,
      mosqueName: json['mission_details']['name'],
      mosqueAddress: json['mission_details']['address'],
        shortestPath:polylinePoints,
      missionCoordinates: LatLng(lat, lng),
      distance: json['navigation']['distance'],
      duration: ''
    );
  }

  // factory MissionCoordinates.fromAlreadyPickedJson(Map<String, dynamic> json) {
  //
  //   return MissionCoordinates(
  //       missionId: json['mission_details']['id'] ?? -1,
  //       mosqueName: json['mission_details']['name'],
  //       mosqueAddress: json['mission_details']['address'],
  //       shortestPath: [],
  //       missionCoordinates: LatLng(-1, -1),
  //       distance: json['navigation']['distance'],
  //       alreadyPicked: json['alreadypicked']
  //   );
  // }

  factory MissionCoordinates.fromPickedMissionJson({
    required Map<String, dynamic> missionJson,
    required Map<String, dynamic> routeJson,
  }) {
    final data = missionJson['data'];
    final navigation = routeJson['navigation'];
    final lat = double.parse((navigation['end_point']['lat'] as String).trim());
    final lng = double.parse((navigation['end_point']['lng'] as String).trim());

    //logger.log(Logger.level, 'lat for mosque is : ${navigation['end_point']['lat']}');
    return MissionCoordinates(
      missionId: data['mission_id'],
      mosqueName: data['name'],
      mosqueAddress: data['address'],
      missionCoordinates: LatLng(
        lat,
        lng
      ),
      shortestPath: (navigation['route'] as List)
          .map((point) => LatLng(
        point['lat']?.toDouble(),
        point['lng']?.toDouble(),
      ))
          .toList(),
      distance: navigation['distance'],
      duration: navigation['duration'],

    );
  }
}
