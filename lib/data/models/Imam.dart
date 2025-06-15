import 'package:maps_app/data/models/mosque.dart';

class Imam {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final Mosque? mosque;

  Imam({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.mosque,
  });

  factory Imam.fromJson(Map<String, dynamic> json) {
    return Imam(
      id: json['id'],
      firstName: json['name'],
      lastName: json['famillyname'],
      phone: json['phone'],
      mosque: json['mosque_id'] != null ? Mosque.fromImamJson(json) : null,
    );
  }
}