import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/models/DeviceTokenModel.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/TonixSignUpRepository.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/SignUpScreen.dart';

import '../main.dart';
import '../models/SiteNameModelResponse.dart';

class TonixSignUpBloc {
  
  TonixSignUpRepository _repository = TonixSignUpRepository();

  StreamController<dynamic> _signUpStreamController = StreamController();
  Stream<dynamic> get signUpStream => _signUpStreamController.stream;
  StreamSink<dynamic> get signUpSink => _signUpStreamController.sink;

  TonixSignUpBloc() {
    _repository = TonixSignUpRepository();

    _signUpStreamController = StreamController.broadcast();
  }

  Future<dynamic> checkUserExistServiceCall(String subjectId, String birthYear, String password, TonixSignUpErrorInfo tonixSignUpErrorInfo, BuildContext context, {String? siteName, List<SiteNameModel>? siteNameModelList}) async {
    try {

      var response;
      
      response = await _repository.checkUserExistServiceCall('${WebservicePost.getServerUrl(context)}user?subject_id=${Uri.encodeComponent(subjectId)}&check_user_exists=1', RequestMethod.GET);

      if(response is AppException) {
        signUpSink.addError(response.toString());
      } else {
        if(response != null && response is String) {
          var responseMap = jsonDecode(response);

          String messageValue = responseMap[Constant.messageTextKey];
          if(messageValue != null) {
            if (messageValue == Constant.userNotFound) {
              await signUpServiceCall(subjectId, birthYear, password, context, siteName: siteName!, siteNameModelList: siteNameModelList!);
            }
          } else {
            signUpSink.add('User Already Exits!');
            tonixSignUpErrorInfo.updateSignUpErrorInfo(true, 'This subject ID is already registered.');
          }
        } else {
          signUpSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      signUpSink.addError(Exception(Constant.somethingWentWrong));
    }
  }

  Future<dynamic> signUpServiceCall(String subjectId, String birthYear, String password, BuildContext context, {String? siteName, List<SiteNameModel>? siteNameModelList}) async {
    try {
      var response;

      response = await _repository.signUpServiceCall('${WebservicePost.getServerUrl(context)}user', RequestMethod.POST, subjectId, birthYear, password, siteName: siteName, siteNameModelList: siteNameModelList);

      if(response is AppException) {
        signUpSink.addError(response.toString());
      } else {
        if(response != null && response is String) {
          var userProfileInfoModel =
              UserProfileInfoModel.fromJson(jsonDecode(response));
          userProfileInfoModel.profileName = userProfileInfoModel.firstName;
          await SignUpOnBoardProviders.db
              .insertUserProfileInfo(userProfileInfoModel);
          FirebaseMessaging fcm = FirebaseMessaging.instance;
          var deviceToken = await fcm.getToken();
          //Clipboard.setData(ClipboardData(text: deviceToken));
          deleteDeviceTokenOfTheUser(deviceToken!, userProfileInfoModel.userId!, context);
          setDeviceTokenOfTheUser(deviceToken, userProfileInfoModel.userId!, context);
          await Utils.setAnalyticsUserId(userProfileInfoModel.userId, context);
          await FirebaseCrashlytics.instance.setUserIdentifier(userProfileInfoModel.userId?.toString() ?? '');
          await analytics.logSignUp(signUpMethod: 'email');
          signUpSink.add(Constant.success);
        } else {
          signUpSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      signUpSink.addError(Exception(Constant.somethingWentWrong));
    }
  }

  /// this method will be use for to delete Device Token from server.
  void deleteDeviceTokenOfTheUser(String deviceToken, String userId, BuildContext context) async {
    try {
      int tokenType;
      String url = '${WebservicePost.getServerUrl(context)}notification/push';
      if (Platform.isAndroid) {
        tokenType = 1;
      } else {
        tokenType = 2;
      }
      DeviceTokenModel deviceTokenModel = DeviceTokenModel();
      deviceTokenModel.userId = int.tryParse(userId);
      deviceTokenModel.devicetoken = deviceToken;
      deviceTokenModel.tokenType = tokenType;
      deviceTokenModel.action = 'delete';
      var response =
      await _repository.createAndDeletePushNotificationServiceCall(url,
          RequestMethod.POST, deviceTokenModelToJson(deviceTokenModel));
      print(response);
    } catch (e) {}
  }

  /// This method will be use for to registered device token on server.
  void setDeviceTokenOfTheUser(String deviceToken, String userId, BuildContext context) async {
    try {
      int tokenType;
      String url = '${WebservicePost.getServerUrl(context)}notification/push';
      if (Platform.isAndroid) {
        tokenType = 1;
      } else {
        tokenType = 2;
      }
      DeviceTokenModel deviceTokenModel = DeviceTokenModel();
      deviceTokenModel.userId = int.tryParse(userId);
      deviceTokenModel.devicetoken = deviceToken;
      deviceTokenModel.tokenType = tokenType;
      deviceTokenModel.action = 'create';
      var response =
      await _repository.createAndDeletePushNotificationServiceCall(url,
          RequestMethod.POST, deviceTokenModelToJson(deviceTokenModel));
      print(response);
    } catch (e) {}
  }

  void enterSomeDummyData() {
    signUpSink.add(Constant.loading);
  }

  void dispose() {
    _signUpStreamController.close();
  }
}