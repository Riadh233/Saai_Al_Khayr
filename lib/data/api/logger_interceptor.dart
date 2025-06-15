import 'dart:async';
import 'dart:math';

import 'package:http/http.dart';
import 'package:http_interceptor/models/interceptor_contract.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/data/api/database_service.dart';
import 'package:maps_app/data/local/local_storage_repository.dart';
import 'package:maps_app/main.dart';

class ApiInterceptor extends InterceptorContract{

  final LocalStorageRepository _localStorage;

  ApiInterceptor({required LocalStorageRepository localStorage}) : _localStorage = localStorage;
  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    if(response.statusCode == 403){
      await _localStorage.deleteJwtToken();
     throw TokenException();
    }
    return response;
  }

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final token = await _localStorage.getToken();

    if (request is Request) {
      if (['post', 'put', 'patch'].contains(request.method.toLowerCase())) {
      }
    }
    request.headers['Content-Type'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      if (!request.url.path.contains('signIn')) {
        //logger.log(Logger.level, 'token from interceptor $token');
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    // logger.i('➡️ [${request.method}] ${request.url}');
    // logger.i('Headers: ${request.headers}');
    // if (request is Request) {
    //   logger.i('Body: ${request.body}');
    // }

    return request;
  }
}