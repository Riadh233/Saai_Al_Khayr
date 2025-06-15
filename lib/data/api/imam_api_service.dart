import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/data/api/database_service.dart';
import 'package:maps_app/data/models/Imam.dart';
import 'package:maps_app/data/models/completed_mission.dart';
import 'package:maps_app/data/models/mission.dart';
import 'package:maps_app/data/models/user.dart';
import 'package:maps_app/main.dart';

import '../local/local_storage_repository.dart';
import 'logger_interceptor.dart';

class ImamApiService {
  final LocalStorageRepository _localStorage;
  final Client client;

  ImamApiService({required LocalStorageRepository localStorage})
      : _localStorage = localStorage,
        client = InterceptedClient.build(
          interceptors: [ApiInterceptor(localStorage: localStorage)],
        );

  final baseUrl = dotenv.env['BASE_URL']!;

  Future<void> addMoneyToMission(int id, String amount, String? amountText) async{
    try{
      final Map<String, dynamic> body = {
        'missionId' : id,
        'amount' : amount
      };
      if(amountText != null){
        body['amount_arabic'] = amountText;
      }
      final response = await client.post(
          Uri.parse('$baseUrl/api/missionMangment/addCollectedMoney'),
        body: jsonEncode(body)
      );
      final json = jsonDecode(response.body);

      if(response.statusCode != 200 ){
        logger.log(Logger.level, json['errors']);
        throw ApiException(json['message']);
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException catch(e) {
      logger.log(Level.error,e);
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }
  Future<void> updateMoneyForMission(int id, String amount, String? amountText) async{
    try{
      final Map<String, dynamic> body = {
        'missionId' : id,
        'amount' : amount
      };
      if(amountText != null){
        body['amount_arabic'] = amountText;
      }
      final response = await client.put(
          Uri.parse('$baseUrl/api/missionMangment/modifyCollectedMoney'),
        body: jsonEncode(body)
      );
      final json = jsonDecode(response.body);

      if(response.statusCode == 404 ){
        logger.log(Logger.level, json['errors']);
        throw ApiException('لا يمكنك تغيير المبلغ , الرجاء الاتصال بالادارة');
      }
      else if(response.statusCode != 200 ){
        logger.log(Logger.level, json['errors']);
        throw ApiException('الاستجابة من الخادم غير صالحة.');
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException catch(e) {
      logger.log(Level.error,e);
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }
  Future<CompletedMission> getMissionForFriday() async{
    try{
      final response = await client.get(
          Uri.parse('$baseUrl/api/missionMangment/checkMissionStatus')
      );

      final json = jsonDecode(response.body);
      logger.log(Logger.level, json);
      if(response.statusCode == 200){
        return CompletedMission.fromJson(json);
      }else if(response.statusCode == 400) {
        throw ApiException( 'لم يتم جمع التبرعات من قبل السائق بعد.');
      }else if(response.statusCode == 404){
        logger.log(Logger.level, json);
        throw ApiException( 'لم يتم تعيين مسجد لك بعد.\nيرجى التواصل مع الإدارة.');
      }else {
        logger.log(Logger.level, json);
        throw ApiException(json['message']);
      }

    } on SocketException catch(e){
      logger.log(Level.error, e);
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException catch(e){
      logger.log(Level.error, e);
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }
  
  Future<Imam> getImamInfo() async {
    try{
      final response = await client.get(
        Uri.parse('$baseUrl/api/userMangment/getUser')
      );
      final json = jsonDecode(response.body);
      logger.log(Logger.level, 'get imam info status code : ${response.statusCode}');
      if(response.statusCode == 200){
       logger.log(Logger.level, json);
        return Imam.fromJson(json['data']);
      }else{
        logger.log(Logger.level, json);
        throw ApiException(json['message']);
      }
    }on SocketException catch(e){
      logger.log(Logger.level, e);
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException catch(e){
      logger.log(Logger.level, e);
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }
  Future<void> updateMosqueLocation(double lat, double lng) async{
    try{
      final response = await client.post(
        Uri.parse('$baseUrl/api/mosqueMangment/mosques/location'),
        body: jsonEncode({
        'raw_lat': lat.toString(),
          'raw_lng': lng.toString()
        })
      );

      final json = jsonDecode(response.body);
      if(response.statusCode == 200){
        logger.log(Logger.level, json);
      }else{
        logger.log(Logger.level, json);
        throw ApiException(json['message']);
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException {
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }
}