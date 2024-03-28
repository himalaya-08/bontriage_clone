import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/ResponseModel.dart';
import 'package:mobile/models/SignUpOnBoardAnswersRequestModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';

class MoreTriggerMedicationRepository {
  Future<dynamic> editServiceCall(
      String url,
      RequestMethod requestMethod,
      List<SelectedAnswers> selectedAnswersList, BuildContext context) async {
    try {
      var dataPayload = await _createPayload(selectedAnswersList, context);
      var response = await NetworkService(url, requestMethod, dataPayload).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return ResponseModel.fromJson(jsonDecode(response));
      }
    } catch (e) {
      return null;
    }
  }

  Future<String> _createPayload(List<SelectedAnswers> selectedAnswersList, BuildContext context) async {
    SignUpOnBoardAnswersRequestModel signUpOnBoardAnswersRequestModel = SignUpOnBoardAnswersRequestModel();
    signUpOnBoardAnswersRequestModel.eventType = Constant.clinicalImpressionShort3;

    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    signUpOnBoardAnswersRequestModel.userId = int.parse(userProfileInfoData.userId!);
    signUpOnBoardAnswersRequestModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);
    signUpOnBoardAnswersRequestModel.updatedAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);
    signUpOnBoardAnswersRequestModel.mobileEventDetails = [];
    try {
      selectedAnswersList.forEach((model) {
        try {
          var decodedJson = jsonDecode(model.answer!);
          if (decodedJson is List<dynamic>) {
            List<String> valuesList = (json.decode(model.answer!) as List<
                dynamic>).cast<String>();
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
        } on FormatException catch(e) {
          print(e.toString());
          //This catch is used to enter data in mobile event details list
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