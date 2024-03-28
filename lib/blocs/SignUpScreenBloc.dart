import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile/main.dart';
import 'package:mobile/models/DeviceTokenModel.dart';
import 'package:mobile/models/ForgotPasswordModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/SignUpScreenRepository.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';

class SignUpScreenBloc {
  SignUpScreenRepository _signUpScreenRepository = SignUpScreenRepository();
  StreamController<String> _albumStreamController = StreamController();
  int count = 0;

  StreamSink<String> get albumDataSink => _albumStreamController.sink;

  Stream<String> get albumDataStream => _albumStreamController.stream;

  StreamController<dynamic> _checkUserAlreadySignUpStreamController = StreamController();
  Stream<dynamic> get checkUserAlreadySignUpStream => _checkUserAlreadySignUpStreamController.stream;
  StreamSink<dynamic> get checkUserAlreadySignUpSink => _checkUserAlreadySignUpStreamController.sink;

  StreamController<dynamic> _signUpOfNewUserStreamController = StreamController();
  Stream<dynamic> get signUpOfNewUserStream => _signUpOfNewUserStreamController.stream;
  StreamSink<dynamic> get signUpOfNewUserSink => _signUpOfNewUserStreamController.sink;

  SignUpScreenBloc({this.count = 0}) {
    _albumStreamController = StreamController<String>();
    _checkUserAlreadySignUpStreamController = StreamController<dynamic>();
    _signUpOfNewUserStreamController = StreamController<dynamic>();
    _signUpScreenRepository = SignUpScreenRepository();
  }



  /// This method will be use for implement API for to check USer Already registered in to the application or not.
  Future<dynamic> checkUserAlreadyExistsOrNot(String emailValue, BuildContext context) async {
    try {
      String url = '${WebservicePost.getServerUrl(context)}user?email=${emailValue.trim()}&check_user_exists=1';
      var apiResponse = await _signUpScreenRepository.serviceCall(url, RequestMethod.GET);
      if (apiResponse is AppException) {
        checkUserAlreadySignUpSink.addError(apiResponse);
        debugPrint(apiResponse.toString());
      } else {
        return apiResponse;
      }
    } catch (e) {
      checkUserAlreadySignUpSink.addError(Exception(Constant.somethingWentWrong));
      debugPrint(e.toString());
    }
    return null;
  }

  void enterSomeDummyDataToStreamController() {
    checkUserAlreadySignUpSink.add(Constant.loading);
    signUpOfNewUserSink.add(Constant.loading);
  }

  /// This method will be use for implement API for SignUp into the app in case of social signups.
  Future<dynamic> signUpOfNewUser(
      String emailValue,
      String passwordValue,
      bool isTermConditionCheck,
      bool isEmailMarkCheck, BuildContext context) async {
    String apiResponse;
    UserProfileInfoModel userProfileInfoModel;
    List<SelectedAnswers>? selectedAnswerListData = await SignUpOnBoardProviders
        .db
        .getAllSelectedAnswers(Constant.zeroEventStep);
    try {
      var response = await _signUpScreenRepository.signUpServiceCall(
          '${WebservicePost.getServerUrl(context)}user/',
          RequestMethod.POST,
          selectedAnswerListData!,
          emailValue,
          passwordValue,
          isTermConditionCheck,
          isEmailMarkCheck);
      if (response is AppException) {
        apiResponse = response.toString();
        signUpOfNewUserSink.addError(response);
      }
      else {
        apiResponse = Constant.success;
        userProfileInfoModel =
            UserProfileInfoModel.fromJson(jsonDecode(response));
        userProfileInfoModel.profileName = userProfileInfoModel.firstName;
        await SignUpOnBoardProviders.db
            .insertUserProfileInfo(userProfileInfoModel);
        FirebaseMessaging _fcm = FirebaseMessaging.instance;
        var deviceToken = await _fcm.getToken();
        deleteDeviceTokenOfTheUser(deviceToken!, userProfileInfoModel.userId!, context);
        setDeviceTokenOfTheUser(deviceToken, userProfileInfoModel.userId!, context);
        await Utils.setAnalyticsUserId(userProfileInfoModel.userId, context);
        await analytics.logSignUp(signUpMethod: 'email');
        Map<String, String> params = {
          'sign_up_via': 'email',
          'email': userProfileInfoModel.email ?? '',
        };
        //await Utils.sendAnalyticsEvent(Constant.signUpEvent, params, context);
        signUpOfNewUserSink.add(Constant.success);
      }
    }
    catch (e) {
      signUpOfNewUserSink.addError(Exception(Constant.somethingWentWrong));
      apiResponse = Constant.somethingWentWrong;
    }
    return apiResponse;
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
      await _signUpScreenRepository.createAndDeletePushNotificationServiceCall(url,
          RequestMethod.POST, deviceTokenModelToJson(deviceTokenModel));
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
      var response =
      await _signUpScreenRepository.createAndDeletePushNotificationServiceCall(url,
          RequestMethod.POST, deviceTokenModelToJson(deviceTokenModel));
      print(response);
    } catch (e) {}
  }

/*
  /// This method will be use for implement API for SignUp into the app.
  Future<dynamic> signUpOfNewUser(List<SelectedAnswers> selectedAnswerListData,
      String emailValue, String passwordValue, bool isTermConditionCheck, bool isEmailMarkCheck, BuildContext context) async {
    String apiResponse;
    UserProfileInfoModel userProfileInfoModel;
    try {
      var response = await _signUpScreenRepository.signUpServiceCall(
          '${WebservicePost.getServerUrl(context)}user/',
          RequestMethod.POST,
          selectedAnswerListData,
          emailValue,
          passwordValue,
        isTermConditionCheck,
        isEmailMarkCheck
      );
      if (response is AppException) {
        apiResponse = response.toString();
        _signUpOfNewUserStreamController.addError(response);
      } else {
        apiResponse = Constant.success;
        userProfileInfoModel = UserProfileInfoModel.fromJson(jsonDecode(response));
        userProfileInfoModel.profileName = userProfileInfoModel.firstName;
        await SignUpOnBoardProviders.db.insertUserProfileInfo(userProfileInfoModel);
        //print(loggedInUserInformationData);
      }
    } catch (e) {
      _signUpOfNewUserStreamController.addError(Exception(Constant.somethingWentWrong));
      apiResponse = Constant.somethingWentWrong;
    }
    return apiResponse;
  }
*/

  void dispose() {
    _albumStreamController.close();
    _checkUserAlreadySignUpStreamController.close();
    _signUpOfNewUserStreamController.close();
  }

  void inItNetworkStream(){
    _checkUserAlreadySignUpStreamController.close();
    _signUpOfNewUserStreamController.close();
    _checkUserAlreadySignUpStreamController = StreamController<dynamic>();
    _signUpOfNewUserStreamController= StreamController<dynamic>();
  }
}
