import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OpenRouteServiceRepository{
  final _apiKey = dotenv.env['ORS_API_KEY'] ?? '';
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    if (_apiKey == '') {
      throw Exception("API Key is missing! Please check your .env file.");
    }

    final String url =
        "https://api.openrouteservice.org/v2/directions/driving-car?api_key=$_apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List coordinates = decoded['routes'][0]['geometry']['coordinates'];

      return coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
    } else {
      throw Exception("Failed to fetch route: ${response.body}");
    }
  }
}