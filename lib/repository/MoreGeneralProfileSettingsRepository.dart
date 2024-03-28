import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/ResponseModel.dart';
import '../models/SignUpOnBoardAnswersRequestModel.dart';
import '../models/SignUpOnBoardSelectedAnswersModel.dart';
import '../models/UserProfileInfoModel.dart';
import '../networking/AppException.dart';
import '../networking/NetworkService.dart';
import '../networking/RequestMethod.dart';
import '../providers/SignUpOnBoardProviders.dart';
import '../util/Utils.dart';
import '../util/constant.dart';

class MoreGeneralProfileSettingsRepository {
  Future<dynamic> editMyProfileServiceCall(
      String url,
      RequestMethod requestMethod,
      List<SelectedAnswers> selectedAnswerList, BuildContext context) async {
    try {
      String payload = await _getProfileDataPayload(selectedAnswerList, context);
      var response =
      await NetworkService(url, requestMethod, payload).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return ResponseModel.fromJson(jsonDecode(response));
      }
    } catch (e) {
      return null;
    }
  }

  Future<String> _getProfileDataPayload(
      List<SelectedAnswers> selectedAnswers, BuildContext context) async {
    SignUpOnBoardAnswersRequestModel signUpOnBoardAnswersRequestModel =
    SignUpOnBoardAnswersRequestModel();

    DateTime dateTime = DateTime.now();
    var userProfileInfoData =
    await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    signUpOnBoardAnswersRequestModel.eventType = Constant.profileEventType;
    if (userProfileInfoData != null)
      signUpOnBoardAnswersRequestModel.userId =
          int.parse(userProfileInfoData.userId!);
    else
      var i = signUpOnBoardAnswersRequestModel.userId = 4214;
    signUpOnBoardAnswersRequestModel.calendarEntryAt =
        Utils.getDateTimeInUtcFormat(dateTime, true, context);
    signUpOnBoardAnswersRequestModel.updatedAt =
        Utils.getDateTimeInUtcFormat(dateTime, true, context);
    signUpOnBoardAnswersRequestModel.mobileEventDetails = [];
    try {
      selectedAnswers.forEach((model) {
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

  Future<UserProfileInfoModel> getUserProfileInfoModel() async {
    return await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
  }
}