import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/AddHeadacheLogModel.dart';
import 'package:mobile/models/AddHeadacheResponseModel.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/LogDaySendDataModel.dart';
import 'package:mobile/models/LogHeadacheResponseDataModel.dart' as logHeadacheResponseDataModel;
import 'package:mobile/models/LogHeadacheResponseModel.dart';
import 'package:mobile/models/SignUpOnBoardAnswersRequestModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/models/CalendarInfoDataModel.dart' as headacheModel;


class TonixAddHeadacheRepository{
  String? url;
  CurrentUserHeadacheModel currentUserHeadacheModel = CurrentUserHeadacheModel();

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
    } catch(e){
      return album;
    }
  }

  Future<dynamic> getMedicationServiceCall(String url, RequestMethod requestMethod) async{
    var album;
    try {
      String payload = await _getPayload1();
      var response = await NetworkService(url,requestMethod, payload).serviceCall();
      if(response is AppException){
        return response;
      } else {
        album = AddHeadacheLogModel.fromJson(json.decode(response));
        return album;
      }
    } catch(e){
      return album;
    }
  }

  Future<dynamic> calendarTriggersServiceCall(String url, RequestMethod requestMethod) async {
    var calendarData;
    try {
      var response = await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        //calendarData = headacheLogDataModelFromJson(response);
        calendarData = logHeadacheResponseDataModel.logHeadacheResponseDataModelFromJson(response);
        return calendarData;
      }
    } catch (e) {
      return calendarData;
    }
  }

  Future<dynamic> userAddHeadacheObjectServiceCall(
      String url,
      RequestMethod requestMethod,
      SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel,
      List<List<SelectedAnswers>> medicationSelectedAnswerList,
      bool isEditing,
      int headacheId,
      List<int> medicationEventIdList,
      DateTime calendarEntryAt,
      BuildContext context) async {
    var album;
    String payload = await _setUserAddHeadachePayload(signUpOnBoardSelectedAnswersModel, medicationSelectedAnswerList, headacheId, medicationEventIdList, calendarEntryAt, context);
    try {
      var response = await NetworkService(url, requestMethod,
          payload)
          .serviceCall();
      if (response is AppException) {
        return response;
      } else {
        _sendAnalyticsData(isEditing, payload, context);
        LogHeadacheResponseModel logHeadacheResponseModel = logHeadacheResponseModelFromJson(response);
        if(logHeadacheResponseModel != null) {

          if(medicationSelectedAnswerList != null && medicationSelectedAnswerList.isNotEmpty)
            await SignUpOnBoardProviders.db.tonixInsertOrUpdateLogHeadacheMedication(medicationSelectedAnswerList);
          else
            await SignUpOnBoardProviders.db.tonixInsertOrUpdateLogHeadacheMedication([]);

          await SignUpOnBoardProviders.db.tonixUpdateMedicationLoggedTimes(medicationSelectedAnswerList);

          Headache headacheData = logHeadacheResponseModel.headache!;

          AddHeadacheMobileEventDetail? headacheTypeMobileEventDetail = headacheData.mobileEventDetails!.firstWhereOrNull((element) => element.questionTag == Constant.headacheTypeTag);
          AddHeadacheMobileEventDetail? onGoingMobileEventDetail = headacheData.mobileEventDetails!.firstWhereOrNull((element) => element.questionTag == Constant.onGoingTag);
          AddHeadacheMobileEventDetail? onSetMobileEventDetail = headacheData.mobileEventDetails!.firstWhereOrNull((element) => element.questionTag == Constant.onSetTag);


          if(headacheTypeMobileEventDetail != null) {
            if(headacheTypeMobileEventDetail.value == Constant.noHeadacheValue) {
              var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
              CurrentUserHeadacheModel? currentUserHeadacheModel = await SignUpOnBoardProviders.db.getUserCurrentHeadacheData(userProfileInfoData.userId!);

              if(currentUserHeadacheModel != null) {
                if (currentUserHeadacheModel.headacheId != null &&
                    headacheId != null) {
                  if (headacheId == currentUserHeadacheModel.headacheId) {
                    await SignUpOnBoardProviders.db.deleteUserCurrentHeadacheData();
                  }
                }
              }
            } else {
              //for deleting the current headache data from the database
              //here checking the headache id if it's same then delete the data
              var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
              if (userProfileInfoData != null && onGoingMobileEventDetail != null) {
                CurrentUserHeadacheModel? currentUserHeadacheModelData = await SignUpOnBoardProviders.db.getUserCurrentHeadacheData(userProfileInfoData.userId!);
                if(onGoingMobileEventDetail.value.toLowerCase() == 'no') {
                  if (currentUserHeadacheModel != null && currentUserHeadacheModelData != null) {
                    if (currentUserHeadacheModel.headacheId == currentUserHeadacheModelData.headacheId) {
                      debugPrint('Headache Data Deleted');
                      await SignUpOnBoardProviders.db.deleteUserCurrentHeadacheData();
                    }
                  }
                } else {
                  if(onSetMobileEventDetail != null) {
                    if(currentUserHeadacheModel != null) {
                      currentUserHeadacheModel.isFromServer = true;
                      currentUserHeadacheModel.selectedDate = onSetMobileEventDetail.value;
                      currentUserHeadacheModel.headacheId = headacheData.id;
                      List<headacheModel.MobileEventDetails1> headacheMobileEventDetails = [];
                      logHeadacheResponseModel.headache!.mobileEventDetails!.forEach((mobileEventDetailsElement) {
                        headacheMobileEventDetails.add(headacheModel.MobileEventDetails1(
                          id: mobileEventDetailsElement.id,
                          value: mobileEventDetailsElement.value,
                          questionTag: mobileEventDetailsElement.questionTag,
                          eventId: mobileEventDetailsElement.eventId,
                          questionJson: mobileEventDetailsElement.questionJson,
                          updatedAt: mobileEventDetailsElement.updatedAt.toIso8601String(),
                          uploadedAt: mobileEventDetailsElement.uploadedAt.toIso8601String(),
                        ));
                      });
                      currentUserHeadacheModel.mobileEventDetails = headacheMobileEventDetails;
                      debugPrint('Headache Data Updated');
                      await SignUpOnBoardProviders.db.insertOrUpdateCurrentHeadacheData(currentUserHeadacheModel);
                    }
                  }
                }
              }
            }
          }
          SelectedAnswers? headacheMigraineSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull((element) => element.questionTag == Constant.headacheMigraineTag);
          SelectedAnswers? headacheTypeSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull((element) => element.questionTag == Constant.headacheTypeTag);

          if(headacheMigraineSelectedAnswer != null) {
            List<String> list;
            if(headacheMigraineSelectedAnswer.answer!.isNotEmpty)
              list = List<String>.from(jsonDecode(headacheMigraineSelectedAnswer.answer!));
            else
              list = [];
            //  var list = List<String>.from(jsonDecode(headacheMigraineSelectedAnswer.answer));

            if(headacheTypeSelectedAnswer != null)
              if(headacheTypeSelectedAnswer.answer == Constant.migraineProbableMigraine)
                SignUpOnBoardProviders.db.insertOrUpdateLogHeadacheMigraine(list);
          } else {
            if(headacheTypeSelectedAnswer != null)
              if(headacheTypeSelectedAnswer.answer == Constant.migraineProbableMigraine)
                SignUpOnBoardProviders.db.insertOrUpdateLogHeadacheMigraine([]);
          }
        }
        return response;
      }
    } catch (e) {
      debugPrint('catching error');
      debugPrint(e.toString());
      return album;
    }
  }

  Future<String> _setUserAddHeadachePayload(
      SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel, List<List<SelectedAnswers>> medicationSelectedAnswer, int headacheId, List<int> medicationEventIdList, DateTime calendarEntryAt, BuildContext context) async {

    SelectedAnswers? rescueMedicationTaken = signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull((element) => element.questionTag == Constant.isRescueMedicationTakenTag);

    SelectedAnswers? headacheTimeZoneSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull((element) => element.questionTag == Constant.timeZoneTag);
    SelectedAnswers? headacheTimeZoneOffsetSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull((element) => element.questionTag == Constant.timeZoneOffsetTag);

    if(headacheTimeZoneSelectedAnswer != null)
      headacheTimeZoneSelectedAnswer.answer = DateTime.now().timeZoneName;
    else
      signUpOnBoardSelectedAnswersModel.selectedAnswers!.add(SelectedAnswers(questionTag: Constant.timeZoneTag, answer: DateTime.now().timeZoneName));

    if(headacheTimeZoneOffsetSelectedAnswer != null)
      headacheTimeZoneOffsetSelectedAnswer.answer = Utils.getDateTimeOffset(DateTime.now().timeZoneOffset.toString(), false);
    else
      signUpOnBoardSelectedAnswersModel.selectedAnswers!.add(SelectedAnswers(questionTag: Constant.timeZoneOffsetTag, answer: Utils.getDateTimeOffset(DateTime.now().timeZoneOffset.toString(), false)));

    if(rescueMedicationTaken == null)
      signUpOnBoardSelectedAnswersModel.selectedAnswers!.add(SelectedAnswers(questionTag: Constant.isRescueMedicationTakenTag, answer: (medicationSelectedAnswer.isNotEmpty).toString()));
    else
      rescueMedicationTaken.answer = (medicationSelectedAnswer.isNotEmpty).toString();

    LogDaySendDataModel logDaySendDataModel = LogDaySendDataModel();
    SignUpOnBoardAnswersRequestModel signUpOnBoardAnswersRequestModel = SignUpOnBoardAnswersRequestModel();
    signUpOnBoardAnswersRequestModel.eventType = "headache";
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    if(userProfileInfoData != null) {
      signUpOnBoardAnswersRequestModel.userId = int.parse(userProfileInfoData.userId!);
    } else {
      signUpOnBoardAnswersRequestModel.userId = 4214;
    }

    if(headacheId != null)
      signUpOnBoardAnswersRequestModel.eventId = headacheId;

    if (calendarEntryAt != null)
      signUpOnBoardAnswersRequestModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(calendarEntryAt, true, context);
    else
      signUpOnBoardAnswersRequestModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);

    signUpOnBoardAnswersRequestModel.updatedAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);
    signUpOnBoardAnswersRequestModel.mobileEventDetails = [];

    signUpOnBoardSelectedAnswersModel.selectedAnswers!.forEach((model) {
      try {
        if(model.questionTag != Constant.headacheMigraineTag) {
          signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
              MobileEventDetails(
                  questionTag: model.questionTag,
                  questionJson: "",
                  updatedAt: Utils.getDateTimeInUtcFormat(DateTime.now(), true, context),
                  value: [model.answer!]));
        } else {
          if(model.answer!.isEmpty){
            signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
                MobileEventDetails(
                    questionTag: model.questionTag,
                    questionJson: "",
                    updatedAt: Utils.getDateTimeInUtcFormat(DateTime.now(), true, context),
                    value: [model.answer!]));
          }else{
            List<String> valuesList = (json.decode(model.answer!) as List<dynamic>).cast<String>();
            signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
                MobileEventDetails(
                    questionTag: model.questionTag,
                    questionJson: "",
                    updatedAt: Utils.getDateTimeInUtcFormat(DateTime.now(), true, context),
                    value: valuesList));
          }

        }
      } catch(e) {
        signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
            MobileEventDetails(
                questionTag: model.questionTag,
                questionJson: "",
                updatedAt: Utils.getDateTimeInUtcFormat(DateTime.now(), true, context),
                value: [model.answer!]));
        debugPrint(e.toString());
      }

    });

    logDaySendDataModel.headache = signUpOnBoardAnswersRequestModel;

    logDaySendDataModel.medication = [];

    medicationSelectedAnswer.asMap().forEach((index, selectedAnswerList) {
      SignUpOnBoardAnswersRequestModel medicationAnswerModel = SignUpOnBoardAnswersRequestModel();
      medicationAnswerModel.eventType = 'medication';

      SelectedAnswers? medicationZoneSelectedAnswer = selectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.timeZoneTag);

      SelectedAnswers? medicationZoneOffsetSelectedAnswer = selectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.timeZoneOffsetTag);

      if(medicationZoneSelectedAnswer != null)
        medicationZoneSelectedAnswer.answer = DateTime.now().timeZoneName;
      else
        selectedAnswerList.add(SelectedAnswers(questionTag: Constant.timeZoneTag, answer: DateTime.now().timeZoneName));

      if(medicationZoneOffsetSelectedAnswer != null)
        medicationZoneOffsetSelectedAnswer.answer = Utils.getDateTimeOffset(DateTime.now().timeZoneOffset.toString(), false);
      else
        selectedAnswerList.add(SelectedAnswers(questionTag: Constant.timeZoneOffsetTag, answer: Utils.getDateTimeOffset(DateTime.now().timeZoneOffset.toString(), false)));

      try {
        if((index + 1) <= medicationEventIdList.length) {
          medicationAnswerModel.eventId = medicationEventIdList[index];
        }
      } catch(e) {
        debugPrint(e.toString());
      }

      if(userProfileInfoData != null) {
        medicationAnswerModel.userId = int.parse(userProfileInfoData.userId!);
      } else {
        medicationAnswerModel.userId = 4214;
      }

      if (calendarEntryAt != null)
        medicationAnswerModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(calendarEntryAt, true, context);
      else
        medicationAnswerModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);

      medicationAnswerModel.updatedAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);
      medicationAnswerModel.mobileEventDetails = [];

      selectedAnswerList.forEach((model) {
        medicationAnswerModel.mobileEventDetails!.add(
            MobileEventDetails(
                questionTag: model.questionTag,
                questionJson: "",
                updatedAt: Utils.getDateTimeInUtcFormat(DateTime.now(), true, context),
                value: [model.answer!]));
      });

      logDaySendDataModel.medication!.add(medicationAnswerModel);
    });


    //insert empty data in remaining event id
    int lengthDiff = medicationEventIdList.length - logDaySendDataModel.medication!.length;

    int eventIndex = logDaySendDataModel.medication!.length;

    if(lengthDiff > 0) {
      for (int i = 1; i <= lengthDiff; i++) {
        SignUpOnBoardAnswersRequestModel medicationAnswerModel = SignUpOnBoardAnswersRequestModel();
        medicationAnswerModel.eventType = 'medication';

        try {
          if((eventIndex + 1) <= medicationEventIdList.length) {
            medicationAnswerModel.eventId = medicationEventIdList[eventIndex];
          }
        } catch(e) {
          debugPrint(e.toString());
        }

        if(userProfileInfoData != null) {
          medicationAnswerModel.userId = int.parse(userProfileInfoData.userId!);
        } else {
          medicationAnswerModel.userId = 4214;
        }

        if (calendarEntryAt != null)
          medicationAnswerModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(calendarEntryAt, true, context);
        else
          medicationAnswerModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);

        medicationAnswerModel.updatedAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);
        medicationAnswerModel.mobileEventDetails = [];

        logDaySendDataModel.medication!.add(medicationAnswerModel);
      }
    }

    return jsonEncode(logDaySendDataModel.toJsonForHeadache());
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

  Future<String> _getPayload1() async{
    var userProfileInfoData =
    await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    return jsonEncode(<String, String>{
      "event_type": "medication", "mobile_user_id": userProfileInfoData.userId!
    });
  }

  void _sendAnalyticsData(bool isEditing, String payload, BuildContext context) async {
    Map<String, dynamic> params = {
      'isEdited': isEditing.toString(),
      /*'data': payload,*/
    };

    var jsonMap = jsonDecode(payload);

    jsonMap["headache"]["mobile_event_details"].forEach((element) {
      var tag = element["question_tag"].replaceAll(".", "_");
      var valueList = element["value"];

      if(valueList.isNotEmpty) {
        if(valueList.length == 1) {
          params[tag] = valueList[0];
        } else {
          params[tag] = valueList.toString();
        }
      }
    });

    jsonMap["medication"].asMap().forEach((index, element1) {
      element1["mobile_event_details"].forEach((element) {
        var tag = element["question_tag"].replaceAll(".", "_");
        var valueList = element["value"];

        if(valueList.isNotEmpty) {
          if(valueList.length == 1) {
            params['${tag}_$index'] = valueList[0];
          } else {
            params['${tag}_$index'] = valueList.toString();
          }
        }
      });
    });

    var userProfileInfoModel = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    params['user_id'] = userProfileInfoModel.userId;

    Utils.sendAnalyticsEvent(Constant.tonixHeadacheLoggedEvent, params, context);
  }
}
