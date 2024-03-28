import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/DeviceTokenModel.dart';
import 'package:mobile/models/ForgotPasswordModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/OtpValidationRepository.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';

import '../main.dart';

class OtpValidationBloc {
  StreamController<int> _otpTimerStreamController = StreamController();

  StreamSink<int> get otpTimerStreamSink => _otpTimerStreamController.sink;

  Stream<int> get otpTimerStream => _otpTimerStreamController.stream;
  StreamController<dynamic> _otpVerifyStreamController = StreamController();

  StreamSink<dynamic> get otpVerifyStreamSink =>
      _otpVerifyStreamController.sink;

  Stream<dynamic> get otpVerifyStream => _otpVerifyStreamController.stream;

  StreamController<dynamic> _networkStreamController = StreamController();

  StreamSink<dynamic> get networkStreamSink => _networkStreamController.sink;

  Stream<dynamic> get networkStream => _networkStreamController.stream;

  OtpValidationRepository _repository = OtpValidationRepository();

  OtpValidationBloc() {
    _repository = OtpValidationRepository();

    _otpVerifyStreamController = StreamController<dynamic>();

    _networkStreamController = StreamController<dynamic>();
  }

  Future<void> callOtpVerifyApi(
    String userEmail,
    String otp,
    bool isFromSignUp,
    String password,
    bool isTermConditionCheck,
    bool isEmailMarkCheck,
      BuildContext context
  ) async {
    try {
      String url =
          '${WebservicePost.getServerUrl(context)}otp/validate?email=$userEmail&otp=$otp';
      var response =
          await _repository.otpVerifyServiceCall(url, RequestMethod.GET);
      if (response is AppException) {
        otpVerifyStreamSink.addError(response);
        networkStreamSink.addError(response);
      } else {
        if (response != null && response is ForgotPasswordModel) {
          if (isFromSignUp && response.status == 1)
            await signUpOfNewUser(userEmail, password, isTermConditionCheck,
                isEmailMarkCheck, response, context);
          else {
            networkStreamSink.add(Constant.success);
            otpVerifyStreamSink.add(response);
          }
        } else {
          networkStreamSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      networkStreamSink.addError(Exception(Constant.somethingWentWrong));
    }
  }

  Future<void> callResendOTPApi(String userEmail, BuildContext context) async {
    try {
      String url = '${WebservicePost.getServerUrl(context)}otp?email=$userEmail&isUserExist=false';
      var response = await _repository.otpVerifyServiceCall(url, RequestMethod.GET);
      if (response is AppException) {
        print(response);
      } else {
        if (response != null && response is ForgotPasswordModel) {
          print(Constant.success);
        } else {
          print(Constant.somethingWentWrong);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> signUpOfNewUser(
      String emailValue,
      String passwordValue,
      bool isTermConditionCheck,
      bool isEmailMarkCheck,
      ForgotPasswordModel forgotPasswordModel, BuildContext context) async {
    String apiResponse;
    UserProfileInfoModel userProfileInfoModel;
    List<SelectedAnswers>? selectedAnswerListData = await SignUpOnBoardProviders
        .db
        .getAllSelectedAnswers(Constant.zeroEventStep);
    try {
      var response = await _repository.signUpServiceCall(
          '${WebservicePost.getServerUrl(context)}user/',
          RequestMethod.POST,
          selectedAnswerListData!,
          emailValue,
          passwordValue,
          isTermConditionCheck,
          isEmailMarkCheck);
      if (response is AppException) {
        apiResponse = response.toString();
        networkStreamSink.addError(response);
      } else {
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
        await FirebaseCrashlytics.instance.setUserIdentifier(userProfileInfoModel.userId?.toString() ?? '');
        await analytics.logSignUp(signUpMethod: 'email');
        Map<String, String> params = {
          'sign_up_via': 'email',
          'email': userProfileInfoModel.email ?? '',
        };
        //await Utils.sendAnalyticsEvent(Constant.signUpEvent, params, context);
        networkStreamSink.add(Constant.success);
        otpVerifyStreamSink.add(forgotPasswordModel);
      }
    } catch (e) {
      networkStreamSink.addError(Exception(Constant.somethingWentWrong));
      apiResponse = Constant.somethingWentWrong;
    }
    return apiResponse;
  }

  String getFormattedTime(int seconds) {
    int remainingSeconds = 30 - seconds;
    String formattedTime = '0:30';

    int minutes = remainingSeconds ~/ 60;
    int second = remainingSeconds % 60;

    if (second < 10)
      formattedTime = '$minutes:0$second';
    else
      formattedTime = '$minutes:$second';

    return formattedTime;
  }

  void initNetworkStreamController() {
    _networkStreamController.close();
    _networkStreamController = StreamController<dynamic>();
  }

  void enterDummyDataToNetworkStream() {
    networkStreamSink.add(Constant.loading);
  }

  void dispose() {
    _networkStreamController.close();
    _otpVerifyStreamController.close();
    _otpTimerStreamController.close();
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
}
