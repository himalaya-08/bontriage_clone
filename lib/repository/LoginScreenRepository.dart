import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/AppConfig.dart';
import 'package:mobile/models/ForgotPasswordModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/util/constant.dart';


class LoginScreenRepository{
  String? url;

  Future<dynamic> loginServiceCall(String url, RequestMethod requestMethod) async {
    var album;
    try {
      var response = await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return album;
    }
  }

  Future<dynamic> forgotPasswordServiceCall(String url, RequestMethod requestMethod, String birthYear, AppConfig appConfig) async {
    try {
      var response = await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
          return forgotPasswordModelFromJson(response);
        else {
          var responseMap = jsonDecode(response);
          debugPrint(responseMap.toString());
          ForgotPasswordModel forgotPasswordModel = ForgotPasswordModel();
          if(responseMap[Constant.messageTextKey] != null) {
            forgotPasswordModel.status = 0;
            forgotPasswordModel.messageText = 'Subject ID and year of birth do not match. Please try again.';
          } else if (responseMap['birthYear'] == birthYear) {
            forgotPasswordModel.status = 1;
            forgotPasswordModel.messageText = 'Valid.';
          } else {
            forgotPasswordModel.status = 0;
            forgotPasswordModel.messageText = 'Subject ID and year of birth do not match. Please try again.';
          }
          return forgotPasswordModel;
        }
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> createAndDeletePushNotificationServiceCall(String url, RequestMethod requestMethod, String requestBody) async {
    try {
      var response = await NetworkService(url, requestMethod,requestBody).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return null;
    }
  }

}
