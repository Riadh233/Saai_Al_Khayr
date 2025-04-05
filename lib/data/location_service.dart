import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  LocationService() {
    _initialize();
  }

  // Initialize permissions & service on creation
  Future<void> _initialize() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
    }
  }

  // Get real-time location updates
  Stream<LocationData>? get locationStream {
    if (!_serviceEnabled || _permissionGranted != PermissionStatus.granted) {
      return null;
    }
    return _location.onLocationChanged;
  }

  // Get current location once
  Future<LocationData?> getCurrentLocation() async {
    if (!_serviceEnabled || _permissionGranted != PermissionStatus.granted) {
      return null;
    }
    try {
      return await _location.getLocation();
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }
}
