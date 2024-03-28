import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/LocalQuestionnaire.dart';
import 'package:mobile/models/ResponseModel.dart';
import 'package:mobile/models/SignUpOnBoardAnswersRequestModel.dart';
import 'package:mobile/models/SignUpOnBoardSecondStepModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';

class SignUpOnBoardThirdStepRepository {
  String? eventTypeName;

  Future<dynamic> serviceCall(
      String url, RequestMethod requestMethod, String argumentsName) async {
    var album;
    try {
      eventTypeName = argumentsName;
      String payload = await _getPayload();
      var response =
          await NetworkService(url, requestMethod,payload).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        album = SignUpOnBoardSecondStepModel.fromJson(json.decode(response));
        LocalQuestionnaire localQuestionnaire = LocalQuestionnaire();
        localQuestionnaire.eventType = Constant.thirdEventStep;
        localQuestionnaire.questionnaires = response;
        localQuestionnaire.selectedAnswers = "";
        SignUpOnBoardProviders.db.insertQuestionnaire(localQuestionnaire);
        return album;
      }
    } catch (e) {
      return album;
    }
  }

  Future<UserProfileInfoModel> getUserProfileInfoModel() async {
    return await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
  }

  Future<dynamic> myProfileServiceCall(
      String url, RequestMethod requestMethod) async {
    try {
      var response =
      await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        List<ResponseModel> responseModelList = responseModelFromJson(response);
        if (responseModelList != null && responseModelList.length > 0)
          return responseModelList[0];
        else
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> signUpThirdStepInfoObjectServiceCall(
      String url,
      RequestMethod requestMethod,
      SignUpOnBoardSelectedAnswersModel
          signUpOnBoardSelectedAnswersModel, BuildContext context) async {
    var album;
    try {
      var dataPayload =
          await _setSignUpThirdStepPayload(signUpOnBoardSelectedAnswersModel, context);
      var response =
          await NetworkService(url, requestMethod, dataPayload).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        //album = WelcomeOnBoardProfileModel.fromJson(json.decode(response));
        return response;
      }
    } catch (e) {
      return album;
    }
  }

  Future<String> _setSignUpThirdStepPayload(
      SignUpOnBoardSelectedAnswersModel
          signUpOnBoardSelectedAnswersModel, BuildContext context) async {
    SignUpOnBoardAnswersRequestModel signUpOnBoardAnswersRequestModel =
        SignUpOnBoardAnswersRequestModel();

    DateTime dateTime = DateTime.now();

    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    signUpOnBoardAnswersRequestModel.eventType =
        Constant.clinicalImpressionShort3; //TODO: this has been changed
    if(userProfileInfoData != null)
      signUpOnBoardAnswersRequestModel.userId = int.parse(userProfileInfoData.userId!);
    else
      signUpOnBoardAnswersRequestModel.userId = 4214;
    signUpOnBoardAnswersRequestModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(dateTime, true, context);
    signUpOnBoardAnswersRequestModel.updatedAt = Utils.getDateTimeInUtcFormat(dateTime, true, context);
    signUpOnBoardAnswersRequestModel.mobileEventDetails = [];
    try {
      signUpOnBoardSelectedAnswersModel.selectedAnswers!.forEach((model) {
        try {
          var decodedJson = jsonDecode(model.answer!);
          if (decodedJson is List<dynamic>) {
            List<String> valuesList = (json.decode(model.answer!) as List<
                dynamic>).cast<String>();
            signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
                MobileEventDetails(
                    questionTag: model.questionTag,
                    questionJson: "",
                    updatedAt: Utils.getDateTimeInUtcFormat(dateTime, true, context),
                    value: valuesList));
          } else {
            signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
                MobileEventDetails(
                    questionTag: model.questionTag,
                    questionJson: "",
                    updatedAt: Utils.getDateTimeInUtcFormat(dateTime, true, context),
                    value: [model.answer!]));
          }
        } on FormatException catch(e) {
          print(e.toString());
          //This catch is used to enter data in mobile event details list
          signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
              MobileEventDetails(
                  questionTag: model.questionTag,
                  questionJson: "",
                  updatedAt: Utils.getDateTimeInUtcFormat(dateTime, true, context),
                  value: [model.answer!]));
        }
      });
    } catch (e) {
      print(e);
    }

    return jsonEncode(signUpOnBoardAnswersRequestModel);
  }

  Future<String> _getPayload() async {
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    if(userProfileInfoData != null) {
      return jsonEncode(<String, String>{
        "event_type": eventTypeName!,
        "mobile_user_id": userProfileInfoData.userId!
      });
    } else {
      return jsonEncode(<String, String>{
        "event_type": eventTypeName!,
        "mobile_user_id": '4214'
      });
    }
  }
}
