import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/CalendarInfoDataModel.dart';
import 'package:mobile/models/LogDayResponseModel.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/models/medication_history_model.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';

import '../view/medicationlist/medication_list_action_sheet.dart';

class LogDayRepository {
  String? url;
  String? eventType;

  Future<dynamic> serviceCall(String url, RequestMethod requestMethod) async {
    var album;
    try {
      var response =
          await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        var decodeMap = json.decode(response);
        decodeMap['profile'][0]['updated_at'] = null;
        decodeMap['profile'][0]['uploaded_at'] = null;
        decodeMap['profile'][0]['calendar_entry_at'] = null;

        decodeMap['profile'][0]['mobile_event_details'].forEach((element) {
          element['updated_at'] = null;
          element['uploaded_at'] = null;
        });

        album = LogDayResponseModel.fromJson(decodeMap);
        return album;
      }
    } catch (e) {
      return album;
    }
  }

  Future<List<Map>?> getAllLogDayData(String userId) async {
    List<Map>? userLogDataMap =
        await SignUpOnBoardProviders.db.getLogDayData(userId);
    return userLogDataMap;
  }

  Future<dynamic> sendMedicationHistoryDataServiceCall(String url, RequestMethod requestMethod, List<MedicationListActionSheetModel> list) async {
    var response;

    String payload = await _getMedicationHistoryPayload(list);
    try {
      response = await NetworkService(url, requestMethod, payload).serviceCall();

      if (response is AppException)
        return response;
      else {
        return medicationHistoryModelFromJson(response);
      }
    } catch(e) {
      return response;
    }
  }

  Future<dynamic> logDaySubmissionDataServiceCall(
      String url, RequestMethod requestMethod, String payload) async {
    var response;
    try {
      response =
          await NetworkService(url, requestMethod, payload).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return response;
    }
  }

  Future<dynamic> calendarTriggersServiceCall(
      String url, RequestMethod requestMethod) async {
    var calendarData;
    try {
      var response =
          await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        calendarData = CalendarInfoDataModel.fromJson(json.decode(response));
        return calendarData;
      }
    } catch (e) {
      debugPrint(e.toString());
      return calendarData;
    }
  }

  Future<dynamic> medicationHistoryServiceCall(String url, RequestMethod requestMethod) async {
    List<MedicationHistoryModel>? medicationHistoryList;
    try {
      var response =
          await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return medicationHistoryModelFromJson(response);
      }
    } catch (e) {
      debugPrint(e.toString());
      return medicationHistoryList;
    }
  }

  Future<String> _getMedicationHistoryPayload(List<MedicationListActionSheetModel> list) async {
    List<MedicationHistoryModel> medicationHistoryModelList = [];

    UserProfileInfoModel userProfileInfoModel = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    list.forEach((element) {
      medicationHistoryModelList.add(
        MedicationHistoryModel(
          id: element.id,
          userId: int.tryParse(userProfileInfoModel.userId ?? '') ?? -1,
          medicationName: element.medicationText,
          medicationTime: element.selectedTime,
          dosage: element.selectedDosage,
          numberOfDosage: element.numberOfDosage.toString(),
          formulation: element.formulationText,
          startDate: element.startDate ?? DateTime.now(),
          endDate: element.endDate,
          reason: element.reason ?? '',
          comments: element.comments ?? '',
          isPreventive: element.isPreventive,
          calenderEntryAt: element.startDate ?? DateTime.now(),
        )
      );
    });

    return medicationHistoryModelToJson(medicationHistoryModelList);
  }
}
