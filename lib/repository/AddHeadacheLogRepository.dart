import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:mobile/models/AddHeadacheLogModel.dart';
import 'package:mobile/models/AddHeadacheResponseModel.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/HeadacheLogDataModel.dart';
import 'package:mobile/models/SignUpOnBoardAnswersRequestModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';


class AddHeadacheLogRepository{
  String? url;
  CurrentUserHeadacheModel? currentUserHeadacheModel;

  Future<dynamic> serviceCall(String url, RequestMethod requestMethod) async{
    var album;
    try {
      String payload = await _getPayload();
      var response = await NetworkService(url,requestMethod, payload).serviceCall();
      if(response is AppException){
        return response;
      } else {
        album = AddHeadacheLogModel.fromJson(json.decode(response));
        return album;
      }
    }catch(e){
      return album;
    }
  }

  Future<dynamic> calendarTriggersServiceCall(String url, RequestMethod requestMethod) async {
    var calendarData;
    try {
      var response =
      await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        calendarData = headacheLogDataModelFromJson(response);
        return calendarData;
      }
    } catch (e) {
      return calendarData;
    }
  }

  Future<dynamic> userAddHeadacheObjectServiceCall(
      String url,
      RequestMethod requestMethod,
      SignUpOnBoardSelectedAnswersModel
      signUpOnBoardSelectedAnswersModel, bool isEditing, BuildContext context) async {
    var album;
    try {
      String payload = await _setUserAddHeadachePayload(signUpOnBoardSelectedAnswersModel, context);
      var response = await NetworkService(url, requestMethod,
          payload)
          .serviceCall();
      if (response is AppException) {
        return response;
      } else {
        _sendAnalyticsData(isEditing, payload, context);
        AddHeadacheResponseModel addHeadacheResponseModel = addHeadacheResponseModelFromJson(response);

        if(addHeadacheResponseModel != null) {
          AddHeadacheMobileEventDetail? onGoingMobileEventDetail = addHeadacheResponseModel.mobileEventDetails.firstWhereOrNull((element) => element.questionTag == Constant.onGoingTag);
          AddHeadacheMobileEventDetail? onSetMobileEventDetail = addHeadacheResponseModel.mobileEventDetails.firstWhereOrNull((element) => element.questionTag == Constant.onSetTag);
          //AddHeadacheMobileEventDetail endTimeMobileEventDetail = addHeadacheResponseModel.mobileEventDetails.firstWhere((element) => element.questionTag == Constant.endTimeTag, orElse: () => null);

          //for deleting the current headache data from the database
          //here checking the headache id if it's same then delete the data
          var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
          if (userProfileInfoData != null && onGoingMobileEventDetail != null) {
            CurrentUserHeadacheModel? currentUserHeadacheModelData = await SignUpOnBoardProviders.db.getUserCurrentHeadacheData(userProfileInfoData.userId!);
            if(onGoingMobileEventDetail.value.toLowerCase() == 'no') {
              if (currentUserHeadacheModel != null && currentUserHeadacheModelData != null) {
                if (currentUserHeadacheModel?.headacheId != null && (currentUserHeadacheModel?.headacheId == currentUserHeadacheModelData.headacheId)) {
                  print('Headache Data Deleted');
                  await SignUpOnBoardProviders.db.deleteUserCurrentHeadacheData();
                }
              }
            } else {
              if(onSetMobileEventDetail != null) {
                if(currentUserHeadacheModel != null) {
                  currentUserHeadacheModel?.selectedDate = onSetMobileEventDetail.value;
                  currentUserHeadacheModel?.headacheId = addHeadacheResponseModel.id;
                  print('Headache Data Updated');
                  await SignUpOnBoardProviders.db.updateUserCurrentHeadacheData(currentUserHeadacheModel!);
                }
              }
            }
          }
        }
        return response;
      }
    } catch (e) {
      return album;
    }
  }

  Future<String> _setUserAddHeadachePayload(
      SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel, BuildContext context) async{
    SignUpOnBoardAnswersRequestModel signUpOnBoardAnswersRequestModel = SignUpOnBoardAnswersRequestModel();
    signUpOnBoardAnswersRequestModel.eventType = "headache";
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    if(userProfileInfoData != null) {
      signUpOnBoardAnswersRequestModel.userId = int.parse(userProfileInfoData.userId!);
    } else {
      signUpOnBoardAnswersRequestModel.userId = 4214;
    }

    if (currentUserHeadacheModel != null)
      signUpOnBoardAnswersRequestModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(DateTime.tryParse(currentUserHeadacheModel!.selectedDate!)!, true, context);
    else
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


  Future<List<Map>?> getAllHeadacheDataFromDatabase(String userId) async{
    List<Map>? userLogDataMap = await SignUpOnBoardProviders.db.getUserHeadacheData(userId);
    return userLogDataMap;
  }

  Future<String> _getPayload() async{
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    return jsonEncode(<String, String>{
      "event_type": "headache", "mobile_user_id": userProfileInfoData.userId!
    });
  }

  void _sendAnalyticsData(bool isEditing, String payload, BuildContext context) async {
    Map<String, dynamic> params = {
      'isEdited': isEditing.toString(),
      /*'data': payload,*/
    };

    var jsonMap = jsonDecode(payload);

    jsonMap["mobile_event_details"].forEach((element) {
      var tag = element["question_tag"];
      var valueList = element["value"];

      if(valueList.isNotEmpty) {
        params[tag] = valueList[0];
      }
    });

    var userProfileInfoModel = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    params['user_id'] = userProfileInfoModel.userId;

    Utils.sendAnalyticsEvent(Constant.headacheLogEvent, params, context);
  }
}
