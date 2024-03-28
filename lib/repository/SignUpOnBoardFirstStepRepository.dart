import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/LocalQuestionnaire.dart';
import 'package:mobile/models/SignUpOnBoardAnswersRequestModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/WelcomeOnBoardProfileModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';

class SignUpOnBoardFirstStepRepository {
  String? url;

  Future<dynamic> serviceCall(String url, RequestMethod requestMethod) async {
    var album;
    try {
      var response = await NetworkService(url, requestMethod, _getPayload()).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        album = WelcomeOnBoardProfileModel.fromJson(json.decode(response));
        LocalQuestionnaire localQuestionnaire = LocalQuestionnaire();
        localQuestionnaire.eventType = Constant.firstEventStep;
        localQuestionnaire.questionnaires = response;
        localQuestionnaire.selectedAnswers = "";
        SignUpOnBoardProviders.db.insertQuestionnaire(localQuestionnaire);
        return album;
      }
    } catch (e) {
      return album;
    }
  }

  Future<dynamic> signUpFirstStepInfoObjectServiceCall(
      String url,
      RequestMethod requestMethod,
      SignUpOnBoardSelectedAnswersModel
          signUpOnBoardSelectedAnswersModel, BuildContext context) async {
    var album;
    try {
      String payload = await _setUserFirstStepSignUpPayload(
          signUpOnBoardSelectedAnswersModel, context);
      var response =
          await NetworkService(url, requestMethod, payload).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return album;
    }
  }

  Future<dynamic> signUpZeroStepInfoObjectServiceCall(
      String url,
      RequestMethod requestMethod,
      SignUpOnBoardSelectedAnswersModel
      signUpOnBoardSelectedAnswersModel, BuildContext context) async {
    var album;
    try {
      String payload = await _setUserZeroStepSignUpPayload(signUpOnBoardSelectedAnswersModel, context);
      var response = await NetworkService(url, requestMethod, payload).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return album;
    }
  }

  String _getPayload() {
    return jsonEncode(<String, String>{
      "event_type": Constant.clinicalImpressionShort0,
      "mobile_user_id": "4214"
    });
  }

  Future<String> _setUserFirstStepSignUpPayload(
      SignUpOnBoardSelectedAnswersModel
          signUpOnBoardSelectedAnswersModel, BuildContext context) async {
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    SignUpOnBoardAnswersRequestModel signUpOnBoardAnswersRequestModel =
        SignUpOnBoardAnswersRequestModel();
    signUpOnBoardAnswersRequestModel.eventType = Constant.clinicalImpression;
    signUpOnBoardAnswersRequestModel.userId = int.parse(userProfileInfoData.userId!);
    signUpOnBoardAnswersRequestModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);
    signUpOnBoardAnswersRequestModel.updatedAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);
    signUpOnBoardAnswersRequestModel.mobileEventDetails = [];
    try {
      signUpOnBoardSelectedAnswersModel.selectedAnswers!.forEach((model) {
        signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
            MobileEventDetails(
                questionTag: model.questionTag,
                questionJson: "",
                updatedAt: Utils.getDateTimeInUtcFormat(DateTime.now(), true, context),
                value: [model.answer!]));
      });
    } catch (e) {
      print(e);
    }

    return jsonEncode(signUpOnBoardAnswersRequestModel);
  }

  Future<String> _setUserZeroStepSignUpPayload(
      SignUpOnBoardSelectedAnswersModel
      signUpOnBoardSelectedAnswersModel, BuildContext context) async {
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    SignUpOnBoardAnswersRequestModel signUpOnBoardAnswersRequestModel =
    SignUpOnBoardAnswersRequestModel();
    signUpOnBoardAnswersRequestModel.eventType = "profile";
    print('userProfileInfoData????$userProfileInfoData');
    signUpOnBoardAnswersRequestModel.userId = int.parse(userProfileInfoData.userId!);
    signUpOnBoardAnswersRequestModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);
    signUpOnBoardAnswersRequestModel.updatedAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);
    signUpOnBoardAnswersRequestModel.mobileEventDetails = [];
    try {
      signUpOnBoardSelectedAnswersModel.selectedAnswers!.forEach((model) {
        if(model.questionTag == Constant.profileLocationTag) {
          List<String> valuesList = (json.decode(model.answer!) as List<dynamic>).cast<String>();
          signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
              MobileEventDetails(
                  questionTag: model.questionTag,
                  questionJson: "",
                  updatedAt: Utils.getDateTimeInUtcFormat(DateTime.now(), true, context),
                  value: valuesList));
        } else {
          signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
              MobileEventDetails(
                  questionTag: model.questionTag,
                  questionJson: "",
                  updatedAt: Utils.getDateTimeInUtcFormat(DateTime.now(), true, context),
                  value: [model.answer!]));
        }
      });
    } catch (e) {
      print(e);
    }

    return jsonEncode(signUpOnBoardAnswersRequestModel);
  }
}
