import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/CalendarInfoDataModel.dart';
import 'package:mobile/models/OnGoingHeadacheDataModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';

import '../models/medication_history_model.dart';


class CalendarRepository{
  Future<dynamic> calendarTriggersServiceCall(String url, RequestMethod requestMethod) async {
    CalendarInfoDataModel calendarData;
    try {
      var response =
      await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        calendarData = CalendarInfoDataModel.fromJson(json.decode(response));
        List<Headache> behaviorDataList = [];
        List<Headache> triggerDataList = [];
        List<Headache> medicationDataList = [];

        calendarData.behaviours?.forEach((element) {
          if (element.mobileEventDetails?.isEmpty == true)
            behaviorDataList.add(element);
        });

        calendarData.triggers?.forEach((element) {
          if (element.mobileEventDetails?.isEmpty == true)
            triggerDataList.add(element);
        });

        calendarData.medication?.forEach((element) {
          if (element.mobileEventDetails?.isEmpty == true)
            medicationDataList.add(element);
        });

        /*behaviorDataList.forEach((element) {
          calendarData.behaviours?.remove(element);
        });

        triggerDataList.forEach((element) {
          calendarData.triggers?.remove(element);
        });

        medicationDataList.forEach((element) {
          calendarData.medication?.remove(element);
        });*/

        return calendarData;
      }
    } catch (e) {
      return "album";
    }
  }

  Future<dynamic> onGoingHeadacheServiceCall(String url, RequestMethod requestMethod) async {
    var onGoingHeadacheData;
    try {
      var response = await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        onGoingHeadacheData = onGoingHeadacheDataModelDartFromJson(response);
        return onGoingHeadacheData;
      }
    } catch (e) {
      return onGoingHeadacheData;
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
}
