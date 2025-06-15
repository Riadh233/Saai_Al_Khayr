import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/data/models/driver_mission.dart';
import 'package:maps_app/main.dart';
import '../local/local_storage_repository.dart';
import 'logger_interceptor.dart';
import 'database_service.dart';

class DriverApiService {
  final Client client;

  DriverApiService({required LocalStorageRepository localStorage})
    :client = InterceptedClient.build(
        interceptors: [ApiInterceptor(localStorage: localStorage)],
      );

  final baseUrl = dotenv.env['BASE_URL']!;

  Future<List<DriverMission>> getAvailableMissions(
    LatLng currentLocation,
  ) async {
    try {
      final response = await client.get(
        Uri.parse(
          '$baseUrl/api/missionMangment/getAvailableMissionsForDriver?lat=${currentLocation.latitude}&lng=${currentLocation.longitude}',
        ),
      );
      final json = jsonDecode(response.body);
      logger.log(Logger.level, json);
      if (response.statusCode == 200) {
        final data = json['data'] as List<dynamic>;
       // logger.log(Logger.level, data);
        return data
            .map((json) => DriverMission.fromJson(json['id'], json['mosque']))
            .toList();
      } else {
        logger.log(Level.error, json);
        throw ApiException(json['message']);
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException {
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }

  Future<void> updateMissionStatus(String status, int id) async {
    try {
      final response = await client.put(
        Uri.parse(
          '$baseUrl/api/missionMangment/updateMissionStatusByDriver/$id',
        ),
        body: jsonEncode(
            {'newStatus': status}
        ),
      );
      final json = jsonDecode(response.body);
      if (response.statusCode != 200) {
        logger.log(Level.error, json['errors']);
        throw ApiException(json['message']);
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException {
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }

  Future<MissionCoordinates> pickMission(int id, LatLng currLocation) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/missionMangment/pickMission/$id'),
        body: jsonEncode(
            {
              "driver_lat": currLocation.latitude.toString(),
              "driver_lng": currLocation.longitude.toString(),
            }
        ),
      );
      final json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        logger.log(Logger.level, 'mission picked success');
        logger.log(Logger.level, '${json}');
        return MissionCoordinates.fromJson(json['data']);
      }else if(response.statusCode == 409){
        //read the picked mission data adn return it
        logger.log(Level.error, '${json}');
        return MissionCoordinates.defaultMission;
      } else {
        logger.log(Level.error, '${json['errors']},${response.statusCode}');
        throw ApiException(json['message']);
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException catch(e){
      logger.log(Logger.level, e);
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }

  Future<void> cancelPickedMission(int missionId) async {
    try {
      logger.log(Level.error, 'cancel mission called with id $missionId');
      final response = await client.put(
        Uri.parse('$baseUrl/api/missionMangment/undoMissionForDriver/$missionId'),
      );
      final json = jsonDecode(response.body);
      logger.log(Level.error, 'cancel mission called with id $missionId: ${response.statusCode}');
      if (response.statusCode != 200) {
        logger.log(Level.error, json);
        throw ApiException(json['message']);
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException {
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }

  Future<MissionCoordinates?> getPickedMission(LatLng currLocation) async {
   try{
     final missionResponse = await client.get(
         Uri.parse('$baseUrl/api/missionMangment/mission/current')
     );
     final missionJson = jsonDecode(missionResponse.body);
     logger.log(Logger.level, 'mission json : $missionJson , ${missionResponse.statusCode}');
     if(missionResponse.statusCode == 200 ){
       final lat = currLocation.latitude.toString();
       final lng = currLocation.longitude.toString();
       final routeResponse = await client.get(
           Uri.parse('$baseUrl/api/missionMangment/mission/${missionJson['data']['mission_id']}/route/$lat/$lng'),
       );
       if(routeResponse.statusCode == 200){
         final routeJson = jsonDecode(routeResponse.body);
          logger.log(Logger.level, 'route json : ${routeJson['navigation']}');
          logger.log(Logger.level, 'mission json : $missionJson');
         return MissionCoordinates.fromPickedMissionJson(missionJson: missionJson, routeJson: routeJson);
       }else{
         throw ApiException(missionJson['message']);
       }
     }else{
       logger.log(Logger.level, 'error');
       throw ApiException(missionJson['message']);
     }
   } on SocketException {
     throw ApiException('لا يوجد اتصال بالإنترنت.');
   } on FormatException {
     throw ApiException('الاستجابة من الخادم غير صالحة.');
   }
  }
  Future<void> sendArrivalNotification() async {}
}
