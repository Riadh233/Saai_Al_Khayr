import 'package:maps_app/data/models/user.dart';

import 'mosque.dart';

class Mission {
  final int id;
  final Mosque mosque;
  final String status;
  final User driver;

  Mission({required this.id, required this.mosque, required this.status, required this.driver});

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      mosque: Mosque.fromMissionJson(json['mosque']),
      status: json['status'],
      driver: json['user'] == null ? User.empty : User.fromMissionsJson(json['user']),
    );
  }
  factory Mission.fromImamJson(int missionId, Map<String, dynamic> json) {
    return Mission(
      id: missionId,
      mosque: Mosque.empty,
      status: '',
      driver: User.fromDriverJson(json['driver']),
    );
  }

}
