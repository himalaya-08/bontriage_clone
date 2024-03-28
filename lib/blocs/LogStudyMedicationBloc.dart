import 'dart:async';
import 'package:collection/collection.dart';

import 'package:flutter/cupertino.dart';
import 'package:mobile/models/HeadacheLogDataModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/LogStudyMedicationRepository.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/LogStudyMedicationDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogStudyMedicationBloc {
  LogStudyMedicationRepository _repository = LogStudyMedicationRepository();

  StreamController<dynamic> _sendDataStreamController = StreamController();

  Stream<dynamic> get sendDataStream => _sendDataStreamController.stream;
  StreamSink<dynamic> get sendDataSink => _sendDataStreamController.sink;

  StreamController<dynamic> _fetchDataStreamController = StreamController();

  Stream<dynamic> get fetchDataStream => _fetchDataStreamController.stream;
  StreamSink<dynamic> get fetchDataSink => _fetchDataStreamController.sink;

  int? _eventId;
  DateTime? _calendarEntryAtDateTime;

  LogStudyMedicationBloc() {
    _repository = LogStudyMedicationRepository();

    _sendDataStreamController = StreamController.broadcast();
    _fetchDataStreamController = StreamController.broadcast();
  }

  Future<void> fetchLogStudyMedicationData(SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel, LogStudyMedicationInfo logStudyMedicationInfo, DateTime currentDateTime, BuildContext context) async {
    try {
      var response;

      DateTime dateTime = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day, 0, 0, 0, 0);

      var userProfileInfoModel = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

      response = await _repository.fetchLogStudyMedicationDataServiceCall('${WebservicePost.getServerUrl(context)}common/events/utc?date=${Utils.getDateTimeInUtcFormat(dateTime, true, context)}&user_id=${userProfileInfoModel.userId}&event_type=${Constant.logStudyMedicationEvent}&utc=true', RequestMethod.GET);

      if(response is AppException) {
        fetchDataSink.addError(response.toString());
      } else {
        if(response != null && response is String) {
          List<HeadacheLogDataModel> headacheLogDataModelList = headacheLogDataModelFromJson(response);

          if(headacheLogDataModelList != null) {
            headacheLogDataModelList.forEach((logStudyMedicationDataModel) {
              _eventId = logStudyMedicationDataModel.id;
              _calendarEntryAtDateTime = logStudyMedicationDataModel.calendarEntryAt;
              var amDoseMobileEventDetail = logStudyMedicationDataModel
                  .mobileEventDetails
                  !.firstWhereOrNull((element) => element.questionTag == Constant.amDoseTag);

              var pmDoseMobileEventDetail = logStudyMedicationDataModel
                  .mobileEventDetails
                  !.firstWhereOrNull((element) => element.questionTag == Constant.pmDoseTag);

              var amSelectedAnswers = signUpOnBoardSelectedAnswersModel
                  .selectedAnswers
                  !.firstWhereOrNull((element) => element.questionTag == Constant.amDoseTag);

              var pmSelectedAnswers = signUpOnBoardSelectedAnswersModel
                  .selectedAnswers
                  !.firstWhereOrNull((element) => element.questionTag == Constant.pmDoseTag);

              if(amDoseMobileEventDetail != null &&
                  pmDoseMobileEventDetail != null &&
                  amSelectedAnswers != null &&
                  pmSelectedAnswers != null) {
                amSelectedAnswers.answer = amDoseMobileEventDetail.value;
                pmSelectedAnswers.answer = pmDoseMobileEventDetail.value;

                var amDoseOption = logStudyMedicationInfo.getLogStudyMedicationList().firstWhereOrNull((element) => element.value == 'AM');
                var pmDoseOption = logStudyMedicationInfo.getLogStudyMedicationList().firstWhereOrNull((element) => element.value == 'PM');

                if(amDoseOption != null && pmDoseOption != null) {
                  amDoseOption.isSelected = amDoseMobileEventDetail.value == '1';
                  pmDoseOption.isSelected = pmDoseMobileEventDetail.value == '1';
                }

                logStudyMedicationInfo.updateLogStudyMedicationInfo();
              }
            });
            fetchDataSink.add(Constant.success);
          } else {
            fetchDataSink.addError(Exception(Constant.somethingWentWrong));
          }
        } else {
          fetchDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      fetchDataSink.addError(Exception(Constant.somethingWentWrong));
    }
  }


  Future<void> sendLogStudyMedicationData(SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel, DateTime dateTime, BuildContext context) async {
    try {
      var response;

      DateTime calendarEntryAt = DateTime.now();

      if(dateTime != null && _calendarEntryAtDateTime == null) {
        calendarEntryAt = DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0, 0);
      } else {
        if(_calendarEntryAtDateTime != null)
          calendarEntryAt = _calendarEntryAtDateTime!;
      }

      if(_eventId == null)
        response = await _repository.sendLogStudyMedicationDataServiceCall('${WebservicePost.getServerUrl(context)}event', RequestMethod.POST, signUpOnBoardSelectedAnswersModel, calendarEntryAt, false, context);
      else
        response = await _repository.sendLogStudyMedicationDataServiceCall('${WebservicePost.getServerUrl(context)}event/$_eventId', RequestMethod.POST, signUpOnBoardSelectedAnswersModel, calendarEntryAt, true, context);

      if (response is AppException) {
        sendDataSink.addError(response.toString());
      } else {
        if(response != null && response is String) {
          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
          sharedPreferences.setString(Constant.updateMeScreenData, Constant.trueString);
          sendDataSink.add(Constant.success);
        } else {
          sendDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      sendDataSink.addError(Exception(Constant.somethingWentWrong));
    }
  }

  void enterSomeDummyData() {
    fetchDataSink.add(Constant.loading);
    sendDataSink.add(Constant.loading);
  }

  void dispose() {
    _sendDataStreamController.close();
    _fetchDataStreamController.close();
  }
}