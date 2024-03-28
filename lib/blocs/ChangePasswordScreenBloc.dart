import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/models/DeviceTokenModel.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/LoginScreenRepository.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordBloc {
  LoginScreenRepository? _loginScreenRepository;
  StreamController<String> _changePasswordStreamController = StreamController();
  int count = 0;

  StreamSink<String> get changePasswordScreenDataSink =>
      _changePasswordStreamController.sink;

  Stream<String> get changePasswordDataStream =>
      _changePasswordStreamController.stream;

  StreamController<dynamic> _changePasswordScreenStreamController = StreamController();

  ChangePasswordBloc({this.count = 0}) {
    _changePasswordStreamController = StreamController<String>();

    _changePasswordScreenStreamController = StreamController<dynamic>();
    _loginScreenRepository = LoginScreenRepository();
  }

  /// This method will be use for implement API for to check USer Already registered in to the application or not.
  Future<dynamic?> sendChangePasswordData(
      String emailValue, String passwordValue, bool isFromMoreSettings, BuildContext context) async {
    String? apiResponse;
    try {
      var appConfig = AppConfig.of(context);

      String url = '${WebservicePost.getServerUrl(context)}user/changepassword?${appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? 'email=$emailValue' : 'subject_id=${Uri.encodeComponent(emailValue)}'}&password=${Uri.encodeComponent(passwordValue)}';
      var response = await _loginScreenRepository!.loginServiceCall(
          url, RequestMethod.POST);
      if (response is AppException) {
        changePasswordScreenDataSink.addError(response);
        apiResponse = response.toString();
        print(apiResponse.toString());
      } else {
        apiResponse = Constant.success;
        changePasswordScreenDataSink.add(Constant.success);
        if (!isFromMoreSettings) {
          UserProfileInfoModel userProfileInfoModel = UserProfileInfoModel();
          userProfileInfoModel =
              UserProfileInfoModel.fromJson(jsonDecode(response));
          if (userProfileInfoModel.profileName == null) {
            userProfileInfoModel.profileName = userProfileInfoModel.firstName;
          }
          FirebaseMessaging _fcm = FirebaseMessaging.instance;
          var deviceToken = await _fcm.getToken();
          deleteDeviceTokenOfTheUser(deviceToken!, userProfileInfoModel.userId!, context);
          setDeviceTokenOfTheUser(deviceToken, userProfileInfoModel.userId!, context);
          await _deleteAllUserData();
          await SignUpOnBoardProviders.db.deleteTableQuestionnaires();
          await SignUpOnBoardProviders.db.deleteTableUserProgress();
          await SignUpOnBoardProviders.db
              .insertUserProfileInfo(userProfileInfoModel);
        }
      }
    } catch (e) {
      changePasswordScreenDataSink
          .addError(Exception(Constant.somethingWentWrong));
      print(e.toString());
    }
    return apiResponse;
  }

  void enterSomeDummyDataToStreamController() {
    changePasswordScreenDataSink.add(Constant.loading);
  }

  void dispose() {
    _changePasswordStreamController.close();
    _changePasswordScreenStreamController.close();
  }

  void inItNetworkStream() {
    _changePasswordScreenStreamController.close();
    _changePasswordScreenStreamController = StreamController<dynamic>();
  }

  ///This method is used to log out from the app and redirecting to the welcome start assessment screen
  Future<void> _deleteAllUserData() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      bool? isVolume = sharedPreferences.getBool(Constant.chatBubbleVolumeState);
      String ttsAccent = sharedPreferences.getString(Constant.ttsAccentKey) ?? 'en-US';
      sharedPreferences.clear();
      sharedPreferences.setString(Constant.ttsAccentKey, ttsAccent);
      sharedPreferences.setBool(
          Constant.chatBubbleVolumeState, isVolume ?? false);
      sharedPreferences.setBool(Constant.tutorialsState, true);
      await SignUpOnBoardProviders.db.deleteAllTableData();
    } catch (e) {
      print(e);
    }
  }

  //https://mobileapp.bontriage.com/mobileapi/v0/notification/push?action=create&user_id=4776&tokenType=1&devicetoken=123456
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
      deviceTokenModel.userId = int.tryParse(userId)!;
      deviceTokenModel.devicetoken = deviceToken;
      deviceTokenModel.tokenType = tokenType;
      deviceTokenModel.action = 'create';
      var response = await _loginScreenRepository
          !.createAndDeletePushNotificationServiceCall(url, RequestMethod.POST,
              deviceTokenModelToJson(deviceTokenModel));
      print(response);
    } catch (e) {}
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
      var response = await _loginScreenRepository
          !.createAndDeletePushNotificationServiceCall(url, RequestMethod.POST,
              deviceTokenModelToJson(deviceTokenModel));
      print(response);
    } catch (e) {}
  }
}
