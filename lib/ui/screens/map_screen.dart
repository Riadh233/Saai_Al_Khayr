import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class MapScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => MapScreenState();

}
class MapScreenState extends State<MapScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map Screen")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(36.7598, 3.4723), // Center the map over London
          initialZoom: 9.2,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
        ],
      ),
    );
  }
}