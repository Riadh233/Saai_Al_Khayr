import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/data/local/local_storage_repository.dart';
import 'package:maps_app/data/api/logger_interceptor.dart';
import 'package:maps_app/main.dart';

import '../models/admin_completed_mission.dart';
import '../models/mission.dart';
import '../models/mosque.dart';
import '../models/user.dart';

class DatabaseService {

  final LocalStorageRepository _localStorage;
  final Client client;

  DatabaseService({required LocalStorageRepository localStorage})
      : _localStorage = localStorage,
        client = InterceptedClient.build(interceptors: [
          ApiInterceptor(localStorage: localStorage),
        ]);

  final baseUrl = dotenv.env['BASE_URL']!;

  Future<UserRole?> signIn({
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    logger.log(Logger.level, '$firstName, $lastName , $password');
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/auth/login'),
        body: jsonEncode({
          'name': firstName.trim(),
          'famillyname': lastName.trim(),
          'password': password.trim(),
        }),
      );
      final json = jsonDecode(response.body);
      if(response.statusCode == 200){
        logger.log(Logger.level, 'user role from database : ${json['data']['role']}');
        await _localStorage.storeJwtToken(json['token']);
        await _localStorage.storeUserRole(json['data']['role']);
        return User.getRole(json['data']['role']);
      }else{
        logger.log(Level.error, json['errors']);
        throw ApiException(json['message']);
      }
    }on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException {
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }

  Future<int?> addUser(User user) async {
    try {
      logger.log(Logger.level, user.status);
      final Map<String, dynamic> body = {
        'name': user.firstName,
        'famillyname': user.lastName,
        'password': user.password,
        'phone': user.number,
        'role': user.status.name,
      };
      if (user.status == UserRole.driver) {
        body['car_number'] = user.carNumber;
      }
      final response = await client.post(
        Uri.parse('$baseUrl/api/auth/register'),
        body: jsonEncode(body),
      );
      final json = jsonDecode(response.body);
      if (response.statusCode == 201) {
        final int id = json['data']['id'] as int;
        return id;
      } else {
        logger.log(Logger.level, '..............${json['errors']}...............');
        throw ApiException(json['message']);
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException {
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }
  Future<void> updateUser(Map<String, dynamic> updatedFields, int userId) async {
    try {
      logger.log(Logger.level, updatedFields);
      if(updatedFields.isEmpty) return;
      final response = await client.put(
        Uri.parse('$baseUrl/api/userMangment/userUpdate/$userId'),
        body: jsonEncode(updatedFields),
      );
      final json = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw ApiException(json['message']);
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException {
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }
  Future<void> deleteUser(int userId) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/api/userMangment/userDelete/$userId'),
      );
      final json = jsonDecode(response.body);
      if(response.statusCode != 200){
        throw(ApiException(json['message']));
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException {
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }
  Future<List<User>> getAllUsers(UserRole role) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/userMangment/getUsers?role=${role.name}'),
      );
      final json = jsonDecode(response.body);
      if(response.statusCode == 200){
        final data =  json['data'] as List<dynamic>;
        logger.log(Logger.level, data);
        return data.map((userJson) => User.fromJson(userJson)).toList();
      } else{
        throw ApiException(json['message']);
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException catch(e) {
      logger.log(Logger.level, e);
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }

  Future<int?> addMosque(Mosque mosque) async {
    try{
      final Map<String, dynamic> body = {
        'name': mosque.name,
      };
      if(mosque.address != null && mosque.address!.isNotEmpty){
        body['address'] = mosque.address;
      }
      if(mosque.imam != User.empty ){
        body['imam_id'] = mosque.imam!.id;
      }
      if(mosque.lat!.isNotEmpty && mosque.ling!.isNotEmpty){
        body['latitude'] = mosque.lat;
        body['longitude'] = mosque.ling;
        body['is_approved'] = true;
      }else{
        body['is_approved'] = false;
      }
      logger.log(Logger.level, 'adding the mosque : ${body}');
      final response = await client.post(
        Uri.parse('$baseUrl/api/mosqueMangment/mosques'),
        body: jsonEncode(body),
      );
      final json = jsonDecode(response.body);
      logger.log(Logger.level, json['errors']);
      if(response.statusCode == 201){
        final id = json['data']['id'] as int;
        return id;
      }else{
        throw ApiException(json['message']);
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException {
      throw ApiException('الاستجابة من الخادم غير صالحة.');

    }
  }
  Future<void> updateMosque(Mosque mosque) async{
    try{
      final Map<String, dynamic> body = {
        'name': mosque.name
      };

      if(mosque.address != null && mosque.address!.isNotEmpty){
        body['address'] = mosque.address;
      }
      if(mosque.imam != User.empty ){
        body['imam_id'] = mosque.imam!.id;
      }
      if(mosque.lat!.isNotEmpty && mosque.ling!.isNotEmpty){
        body['latitude'] = mosque.lat;
        body['longitude'] = mosque.ling;
        body['is_approved'] = true;
      }else{
        body['is_approved'] = false;
      }
      logger.log(Logger.level, 'updating the current mosque ${mosque.id}, ${mosque.name}');
      final response = await client.put(
          Uri.parse('$baseUrl/api/mosqueMangment/mosques/${mosque.id}',),
        body: jsonEncode(body)
      );
      final json = jsonDecode(response.body);
      if(response.statusCode != 200){
        logger.log(Level.error, json['errors']);
        throw ApiException(json['message']);
      }
    }on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException {
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }
  Future<void> deleteMosque(int id) async{
    try{
      logger.log(Logger.level, 'deleting mosque with id ${id}...');
      final response = await client.delete(
          Uri.parse('$baseUrl//api/mosqueMangment/mosques/$id',),
      );
      final json = jsonDecode(response.body);

      if(response.statusCode != 200){
        logger.log(Logger.level, json['message']);
        logger.log(Logger.level, json['errors']);
        throw ApiException(json['message']);
      }
    }on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException {
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }

  Future<Mosque> getMosqueDetails(int id) async {
    try{
      final response = await client.get(
        Uri.parse('$baseUrl/api/mosqueMangment/mosques/$id'),
      );
      final json = jsonDecode(response.body);
      if(response.statusCode == 200){
        logger.log(Logger.level, 'mosque details : ${json['data']}');
        return Mosque.fromDetailsJson(json['data'] as Map<String, dynamic>);
      }else{
        throw ApiException(json['message']);
      }
    }on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException catch(e) {
      logger.log(Level.error, e);
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }
  Future<List<Mosque>> getAllMosques() async {
    try{
      final response = await client.get(
          Uri.parse('$baseUrl/api/mosqueMangment/mosques')
      );

      final json = jsonDecode(response.body);
      logger.log(Logger.level, json);
      if(response.statusCode == 200){
        final data =  json['data'] as List<dynamic>;
        //logger.log(Logger.level, data);
        return data.map((mosqueJson) => Mosque.fromJson(mosqueJson)).toList();
      }else{
        logger.log(Level.debug, json['errors']);
        throw ApiException(json['message']);
      }
    }on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    }  on FormatException catch(e) {
      logger.log(Level.error, e);
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }
  Future<List<User>> getImamsWithoutCoordinates() async {
    try{
      final response = await client.get(
        Uri.parse('$baseUrl/api/mosqueMangment/mosques/imams/without-coordinates')
      );
      final json = jsonDecode(response.body);

      if(response.statusCode == 200){
        final data = json['data'] as List<dynamic>;
        logger.log(Logger.level, 'imams without coords : $data}');
        return data.map((imam) => User.fromImamWithoutCoordinates(imam)).toList();
      }else{
        logger.log(Level.debug, json['errors']);
        logger.log(Level.debug, json['message']);
        throw ApiException(json['message']);
      }
    }on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException {
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }
  Future<List<Mission>> getMissions(String status, int daysAgo) async {
    try{
      final response = await client.get(
        Uri.parse('$baseUrl/api/missionMangment/getMission?status=$status&days_ago=$daysAgo')
      );
      final json = jsonDecode(response.body);
      if(response.statusCode == 200){
        logger.log(Level.error, json['data']);
        final data = json['data'] as List<dynamic>;
        logger.log(Logger.level, data);
        return data.map((missionJson) => Mission.fromJson(missionJson)).toList();
      }else{
        logger.log(Level.error, json);
        throw ApiException(json['message']);
      }

    }on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException {
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }
  Future<bool> initMissions() async {
    try{
      final response = await client.post(
        Uri.parse('$baseUrl/api/missionMangment/assign')
      );
      final json = jsonDecode(response.body);
      if(response.statusCode == 201){
        logger.log(Logger.level, json['data']);
        //return the flag from the json
        return true;
      }else{
        logger.log(Logger.level, json);
        throw ApiException(json['message']);
      }
    }on SocketException {
      logger.log(Logger.level, 'لا يوجد اتصال بالإنترنت.');
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException {
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }

  Future<CollectedReport> getCompletedMissionsForInterval({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/missionMangment/getCollectedMoneyForWeek')
            .replace(queryParameters: {
          'fromDate': fromDate,
          'toDate': toDate,
        }),
      );

      final json = jsonDecode(response.body);
      if (response.statusCode == 200 && json['success'] == true) {
        logger.log(Logger.level, 'Collected report: $json');

        return CollectedReport.fromJson(json);
      } else {
        throw ApiException(json['message'] ?? 'حدث خطأ غير متوقع.');
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } on FormatException catch (e) {
      logger.log(Level.error, e);
      throw ApiException('الاستجابة من الخادم غير صالحة.');
    }
  }

}
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}
class TokenException implements Exception {
  final String? message;
  TokenException({this.message = 'انتهت صلاحية الجلسة، الرجاء تسجيل الدخول من جديد.'});
}
