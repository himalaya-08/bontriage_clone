import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';


class RecordsCompassRepository{
  String? url;

  Future<dynamic> compassServiceCall(String url, RequestMethod requestMethod) async {
    var album;
    try {
      var response =
      await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (Exception) {
      return album;
    }
  }

}
