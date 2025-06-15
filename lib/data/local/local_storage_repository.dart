import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/data/models/user.dart';
import 'package:maps_app/main.dart';

class LocalStorageRepository{
  final _storage = FlutterSecureStorage();

  Future<void> storeJwtToken(String jwtToken) async{
    logger.log(Logger.level, 'store token called...');
    await _storage.write(key: 'jwt', value: jwtToken);
  }
  Future<void> deleteJwtToken() async{
    logger.log(Logger.level, 'delete token called...');
    await _storage.delete(key: 'jwt');
  }
  Future<String?> getToken() async{
    final token = await _storage.read(key: 'jwt');
    logger.log(Logger.level, 'get token called :$token...');
    return token;
  }

  Future<void> storeUserRole(String role) async {
    await _storage.write(key: 'role', value: role);
  }

  Future<UserRole> getUserRole() async {
    final role = await _storage.read(key: 'role');
    return User.getRole(role!);
  }
  Future<void> deleteUserRole() async{
    await _storage.delete(key: 'role');
  }

}