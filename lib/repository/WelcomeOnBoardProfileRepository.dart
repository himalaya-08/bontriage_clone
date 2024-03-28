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

class WelcomeOnBoardProfileRepository {
  String? url;

  Future<dynamic> serviceCall(String url, RequestMethod requestMethod) async {
    var album;
    try {
      var response =
          await NetworkService(url, requestMethod, _getPayload()).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        album = WelcomeOnBoardProfileModel.fromJson(json.decode(response));
        LocalQuestionnaire localQuestionnaire = LocalQuestionnaire();
        localQuestionnaire.eventType = Constant.zeroEventStep;
        localQuestionnaire.questionnaires = response;
        localQuestionnaire.selectedAnswers = "";
        SignUpOnBoardProviders.db.insertQuestionnaire(localQuestionnaire);
        return album;
      }
    } catch (e) {
      return album;
    }
  }

  Future<dynamic> signUpProfileInfoObjectServiceCall(
      String url,
      RequestMethod requestMethod,
      SignUpOnBoardSelectedAnswersModel
          signUpOnBoardSelectedAnswersModel, BuildContext context) async {
    var album;
    try {
      var response = await NetworkService(url, requestMethod,
              _setUserProfileSignUpPayload(signUpOnBoardSelectedAnswersModel, context))
          .serviceCall();
      if (response is AppException) {
        return response;
      } else {
        //album = WelcomeOnBoardProfileModel.fromJson(json.decode(response));

        return album;
      }
    } catch (e) {
      return album;
    }
  }

  String _getPayload() {
    return jsonEncode(
        <String, String>{"event_type": "profile", "mobile_user_id": "4214"});
  }

  String _setUserProfileSignUpPayload(
      SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel, BuildContext context) {
    SignUpOnBoardAnswersRequestModel signUpOnBoardAnswersRequestModel =
        SignUpOnBoardAnswersRequestModel();
    DateTime dateTime = DateTime.now();

    signUpOnBoardAnswersRequestModel.eventType = "profile";
    signUpOnBoardAnswersRequestModel.userId = 4551;
    signUpOnBoardAnswersRequestModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(dateTime, true, context);
    signUpOnBoardAnswersRequestModel.updatedAt = Utils.getDateTimeInUtcFormat(dateTime, true, context);
    signUpOnBoardAnswersRequestModel.mobileEventDetails = [];
    try {
      signUpOnBoardSelectedAnswersModel.selectedAnswers!.forEach((model) {
        signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
            MobileEventDetails(
                questionTag: model.questionTag,
                questionJson: "",
                updatedAt: Utils.getDateTimeInUtcFormat(dateTime, true, context),
                value: [model.answer!]));
      });
    } catch (e) {
      print(e);
    }

    return jsonEncode(signUpOnBoardAnswersRequestModel);
  }
}
