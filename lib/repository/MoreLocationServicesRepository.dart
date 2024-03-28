import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/ResponseModel.dart';
import 'package:mobile/models/SignUpOnBoardAnswersRequestModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';

class MoreLocationServicesRepository {

  Future<dynamic> myProfileServiceCall(String url, RequestMethod requestMethod) async {
    try {
      var response = await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        List<ResponseModel> responseModelList = responseModelFromJson(response);
        if(responseModelList != null && responseModelList.length > 0)
          return responseModelList[0];
        else
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> editMyProfileServiceCall(String url, RequestMethod requestMethod, List<SelectedAnswers> selectedAnswerList, BuildContext context) async {
    try {
      String payload = await _getProfileDataPayload(selectedAnswerList, context);
      var response = await NetworkService(url,requestMethod, payload).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return ResponseModel.fromJson(jsonDecode(response));
      }
    } catch (e) {
      return null;
    }
  }

  Future<String>_getProfileDataPayload(List<SelectedAnswers> selectedAnswers, BuildContext context) async {
    SignUpOnBoardAnswersRequestModel signUpOnBoardAnswersRequestModel = SignUpOnBoardAnswersRequestModel();

    DateTime dateTime = DateTime.now();
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    signUpOnBoardAnswersRequestModel.eventType = Constant.profileEventType;
    if (userProfileInfoData != null)
      signUpOnBoardAnswersRequestModel.userId = int.parse(userProfileInfoData.userId!);
    else
      signUpOnBoardAnswersRequestModel.userId = 4214;
    signUpOnBoardAnswersRequestModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(dateTime, true, context);
    signUpOnBoardAnswersRequestModel.updatedAt = Utils.getDateTimeInUtcFormat(dateTime, true, context);
    signUpOnBoardAnswersRequestModel.mobileEventDetails = [];
    try {
      selectedAnswers.forEach((model) {
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
                  updatedAt: Utils.getDateTimeInUtcFormat(dateTime, true, context),
                  value: [model.answer!]));
        }
      });
    } catch (e) {
      print(e);
    }

    return jsonEncode(signUpOnBoardAnswersRequestModel);
  }

  Future<UserProfileInfoModel?> getUserProfileInfoModel() async {
    return await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
  }
}