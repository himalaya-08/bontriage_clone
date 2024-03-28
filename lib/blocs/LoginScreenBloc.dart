import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/models/DeviceTokenModel.dart';
import 'package:mobile/models/ForgotPasswordModel.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/LoginScreenRepository.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/util/constant.dart';

import '../main.dart';

class LoginScreenBloc {
  LoginScreenRepository _loginScreenRepository = LoginScreenRepository();
  StreamController<dynamic> _loginStreamController = StreamController();
  int count = 0;

  StreamSink<dynamic> get loginDataSink => _loginStreamController.sink;

  Stream<dynamic> get loginDataStream => _loginStreamController.stream;

  StreamController<dynamic> _forgotPasswordStreamController = StreamController();

  StreamSink<dynamic> get forgotPasswordStreamSink =>
      _forgotPasswordStreamController.sink;

  Stream<dynamic> get forgotPasswordStream =>
      _forgotPasswordStreamController.stream;

  StreamController<dynamic> _networkStreamController = StreamController();

  StreamSink<dynamic> get networkStreamSink => _networkStreamController.sink;

  Stream<dynamic> get networkStream => _networkStreamController.stream;

  LoginScreenBloc({this.count = 0}) {
    _loginStreamController = StreamController<dynamic>();
    _forgotPasswordStreamController = StreamController<dynamic>();
    _networkStreamController = StreamController<dynamic>();
    _loginScreenRepository = LoginScreenRepository();
  }

  Future<void> callForgotPasswordApi(String userEmail, String birthYear, BuildContext context) async {
    try {
      var appConfig = AppConfig.of(context);
      String url;

      if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
        url = '${WebservicePost.getServerUrl(context)}otp?email=$userEmail&isUserExist=true';
      else
        url = '${WebservicePost.getServerUrl(context)}user/details?subject_id=${Uri.encodeComponent(userEmail)}';

      var response = await _loginScreenRepository.forgotPasswordServiceCall(
          url, RequestMethod.GET, birthYear, appConfig!);
      if (response is AppException) {
        forgotPasswordStreamSink.addError(response);
        networkStreamSink.addError(response);
      } else {
        if (response != null && response is ForgotPasswordModel) {
          networkStreamSink.add(Constant.success);
          forgotPasswordStreamSink.add(response);
        } else {
          networkStreamSink.addError(Exception(Constant.somethingWentWrong));
          debugPrint('on something went wrong 1');
        }
      }
    } catch (e) {
      networkStreamSink.addError(Exception(Constant.somethingWentWrong));
      debugPrint('on something went wrong 2');
    }
  }

  Future<dynamic> getLoginOfUser(String emailValue, String passwordValue, String? source, String deviceToken, BuildContext context) async {
    String? apiResponse;
    try {
      var appConfig = AppConfig.of(context);
      //String url = '${WebservicePost.getServerUrl(context)}user?${appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? 'email=$emailValue' : 'subject_id=${Uri.encodeComponent(emailValue)}'}&password=${Uri.encodeComponent(passwordValue)}';
      String url = (source == null || passwordValue != Constant.blankString) ? '${WebservicePost.getServerUrl(context)}user?${appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? 'email=$emailValue' : 'subject_id=${Uri.encodeComponent(emailValue)}'}&password=${Uri.encodeComponent(passwordValue)}' : '${WebservicePost.getServerUrl(context)}user?${appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? 'email=$emailValue' : 'subject_id=${Uri.encodeComponent(emailValue)}'}&source=$source}';
      var response =
          await _loginScreenRepository.loginServiceCall(url, RequestMethod.GET);
      if (response is AppException) {
        loginDataSink.addError(response);
        apiResponse = response.toString();
      } else {
        if (response != null) {
          if (jsonDecode(response)[Constant.messageTextKey] != null) {
            String messageValue = jsonDecode(response)[Constant.messageTextKey];
            if (messageValue != null) {
              if (messageValue == Constant.userNotFound) {
                apiResponse = Constant.userNotFound;
              }
            }
          } else {
            await Utils.clearAllDataFromDatabaseAndCache();
            UserProfileInfoModel userProfileInfoModel = UserProfileInfoModel();
            userProfileInfoModel =
                UserProfileInfoModel.fromJson(jsonDecode(response));
            //userProfileInfoModel.userId = '4493'; //vipin user id
            //userProfileInfoModel.userId = '5347'; //kathleen user id
            //userProfileInfoModel.userId = "5946";
            //userProfileInfoModel.userId = "4620"; //lauren user id
            deleteDeviceTokenOfTheUser(deviceToken, userProfileInfoModel.userId!, context);
            setDeviceTokenOfTheUser(deviceToken, userProfileInfoModel.userId!, context);
            await _deleteAllUserData();
            await SignUpOnBoardProviders.db.deleteTableQuestionnaires();
            await SignUpOnBoardProviders.db.deleteTableUserProgress();
            var selectedAnswerListData = await SignUpOnBoardProviders.db
                .insertUserProfileInfo(userProfileInfoModel);
            await Utils.setAnalyticsUserId(userProfileInfoModel.userId, context);
            await FirebaseCrashlytics.instance.setUserIdentifier(userProfileInfoModel.userId?.toString() ?? '');
            await analytics.logLogin(loginMethod: 'email');
            debugPrint(selectedAnswerListData.toString());
            apiResponse = Constant.success;
          }
        } else {
          loginDataSink.addError(Exception(Constant.somethingWentWrong));
          debugPrint('on something went wrong 3');
        }
      }
    } catch (e) {
      loginDataSink.addError(Exception(Constant.somethingWentWrong));
      debugPrint('on something went wrong 4');
      apiResponse = Constant.somethingWentWrong;
      debugPrint(e.toString());
    }
    return apiResponse;
  }

  void enterSomeDummyDataToStream() {
    loginDataSink.add(Constant.loading);
  }

  void init() {
    _loginStreamController.close();
    _loginStreamController = StreamController<dynamic>();
  }

  void initNetworkStreamController() {
    _networkStreamController.close();
    _networkStreamController = StreamController<dynamic>();
  }

  void dispose() {
    _loginStreamController.close();
    _forgotPasswordStreamController.close();
    _networkStreamController.close();
  }

  void enterDummyDataToNetworkStream() {
    networkStreamSink.add(Constant.loading);
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
      debugPrint(e.toString());
    }
  }

  /// This method will be use for to registered device token on server.
  void setDeviceTokenOfTheUser(String deviceToken, String userId, BuildContext context) async{
    try {
      int tokenType;
      String url = '${WebservicePost.getServerUrl(context)}notification/push';
      if(Platform.isAndroid){
        tokenType = 1;
      }else{
        tokenType = 2;
      }
      DeviceTokenModel deviceTokenModel = DeviceTokenModel();
      deviceTokenModel.userId = int.tryParse(userId);
      deviceTokenModel.devicetoken = deviceToken;
      deviceTokenModel.tokenType = tokenType;
      deviceTokenModel.action = 'create';
      var response =
          await _loginScreenRepository.createAndDeletePushNotificationServiceCall(url, RequestMethod.POST,deviceTokenModelToJson(deviceTokenModel));
      debugPrint(response.toString());
    } catch (e) {}
  }
  /// this method will be use for to delete Device Token from server.
  void deleteDeviceTokenOfTheUser(String deviceToken, String userId, BuildContext context) async{
    try {
      int tokenType;
      String url = '${WebservicePost.getServerUrl(context)}notification/push';
      if(Platform.isAndroid){
        tokenType = 1;
      }else{
        tokenType = 2;
      }
      DeviceTokenModel deviceTokenModel = DeviceTokenModel();
      deviceTokenModel.userId = int.tryParse(userId);
      deviceTokenModel.devicetoken = deviceToken;
      deviceTokenModel.tokenType = tokenType;
      deviceTokenModel.action = 'delete';
      var response = await _loginScreenRepository.createAndDeletePushNotificationServiceCall(url, RequestMethod.POST,deviceTokenModelToJson(deviceTokenModel));
      debugPrint(response.toString());
    } catch (e) {}
  }
}
