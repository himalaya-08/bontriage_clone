import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/SignUpOnBoardAnswersRequestModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';

class LogStudyMedicationRepository {
  Future<dynamic> fetchLogStudyMedicationDataServiceCall(
      String url, RequestMethod requestMethod) async {
    var response;
    try {
      response =
          await NetworkService.getRequest(url, requestMethod).serviceCall();

      if (response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return response;
    }
  }

  Future<dynamic> sendLogStudyMedicationDataServiceCall(
      String url,
      RequestMethod requestMethod,
      SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel,
      DateTime calendarEntryAtDateTime,
      bool isEditing,
      BuildContext context) async {
    String payload = await _getSendDataPayload(
        signUpOnBoardSelectedAnswersModel, calendarEntryAtDateTime, context);
    var response;
    try {
      response =
          await NetworkService(url, requestMethod, payload).serviceCall();

      if (response is AppException) {
        return response;
      } else {
        _sendAnalyticsData(isEditing, payload, context);
        return response;
      }
    } catch (e) {
      return response;
    }
  }

  Future<String> _getSendDataPayload(
      SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel,
      DateTime calendarEntryAtDateTime,
      BuildContext context) async {
    SignUpOnBoardAnswersRequestModel signUpOnBoardAnswersRequestModel =
        SignUpOnBoardAnswersRequestModel();
    signUpOnBoardAnswersRequestModel.eventType =
        Constant.logStudyMedicationEvent;
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    if (userProfileInfoData != null) {
      signUpOnBoardAnswersRequestModel.userId =
          int.parse(userProfileInfoData.userId!);
    } else {
      signUpOnBoardAnswersRequestModel.userId = 4214;
    }

    if (calendarEntryAtDateTime != null)
      signUpOnBoardAnswersRequestModel.calendarEntryAt =
          Utils.getDateTimeInUtcFormat(calendarEntryAtDateTime, true, context);
    else
      signUpOnBoardAnswersRequestModel.calendarEntryAt =
          Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);

    signUpOnBoardAnswersRequestModel.updatedAt =
        Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);
    signUpOnBoardAnswersRequestModel.mobileEventDetails = [];

    signUpOnBoardSelectedAnswersModel.selectedAnswers!.forEach((model) {
      signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
          MobileEventDetails(
              questionTag: model.questionTag,
              questionJson: "",
              updatedAt:
                  Utils.getDateTimeInUtcFormat(DateTime.now(), true, context),
              value: [model.answer!]));
    });

    return jsonEncode(signUpOnBoardAnswersRequestModel);
  }

  void _sendAnalyticsData(bool isEditing, String payload, BuildContext context) async {
    Map<String, dynamic> params = {
      'isEdited': isEditing.toString(),
      /*'data': payload,*/
    };

    var jsonMap = jsonDecode(payload);

    jsonMap["mobile_event_details"].forEach((element) {
      var tag = element["question_tag"].replaceAll(".", "_");
      var valueList = element["value"];

      if (valueList.isNotEmpty) {
        if (valueList.length == 1) {
          params[tag] = valueList[0];
        } else {
          params[tag] = valueList.toString();
        }
      }
    });

    var userProfileInfoModel =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    params['user_id'] = userProfileInfoModel.userId;

    Utils.sendAnalyticsEvent(Constant.tonixLogStudyMedicationEvent, params, context);
  }
}
