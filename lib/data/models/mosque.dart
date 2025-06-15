import 'package:logger/logger.dart';
import 'package:maps_app/data/models/user.dart';
import 'package:maps_app/main.dart';

class Mosque {
  final int? id;
  final User? imam;
  final String name;
  final String? address;
  final String? lat;
  final String? ling;
  final bool? isApproved;

  const Mosque({this.id, this.imam, required this.name,this.address, this.lat, this.ling, this.isApproved});

  static const empty = Mosque(name: '');
  factory Mosque.fromJson(Map<String, dynamic> json) {
    return Mosque(
      id: json['id'] ?? '',
      imam: json['user_id'] != null
          ? User(
        id: json['user_id'],
        lastName: json['user_famillyname'] ?? '',
        firstName: json['user_name'] ?? '',
        password: '',
      )
          : null,
      name: json['name'] ?? '',
      address: json['address'],
      lat: json['latitude'] == 0.0 ? null : _formatCoordinate(json['latitude']), // Null if missing/invalid
      ling: json['longitude'] == 0.0 ? null : _formatCoordinate(json['longitude']), // Null if missing/invalid
      isApproved: json['is_approved'] ?? false, // Default to false
    );
  }

  factory Mosque.fromDetailsJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'];
    final hasCoordinates = coordinates != null &&
        ((coordinates['latitude'] != 0.0 &&
                coordinates['longitude'] != 0.0));
    logger.log(Level.error, 'is approved from json ${coordinates['is_approved']}');
    return Mosque(
      id: json['id'],
      imam: json['imam'] != null ? User.fromImamJson(json['imam']) : null,
      name: json['name'] ?? '', // Required
      address: json['address'], // Optional
      lat: hasCoordinates
          ? _formatCoordinate(coordinates['latitude'])
          : null,
      ling: hasCoordinates
          ? _formatCoordinate(coordinates['longitude'])
          : null,
      isApproved: coordinates['is_approved'] ?? false,
    );
  }
  factory Mosque.fromMissionJson(Map<String,dynamic> json){
    return Mosque(name: json['name'],id: json['id']);
  }
  factory Mosque.fromImamJson(Map<String,dynamic> json) {
    return Mosque(
      id: json['mosque_id'],
      name: json['mosque_name'],
      address: json['mosque_address'],
      lat: json['latitude']?.toString(),
      ling: json['longitude']?.toString(),
      isApproved: json['is_approved'],
    );
  }

  @override
  String toString() {
    return '''
Mosque(
  id: $id,
  name: $name,
  address: $address,
  lat: $lat,
  ling: $ling,
  isApproved: $isApproved,
  imam: ${imam?.toString() ?? 'null'}
)''';
  }
}
String? _formatCoordinate(String numStr) {
  // Convert the string to a double to remove unnecessary zeros
  double num = double.parse(numStr);

  // Check if the number is zero (after parsing)
  if (num == 0.0) return null;

  // Convert back to a string and remove trailing zeros after decimal
  String cleaned = num.toString();
  if (cleaned.contains('.')) {
    cleaned = cleaned.replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');
  }

  return cleaned;
}