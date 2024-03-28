import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mobile/models/AddHeadacheLogModel.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/LogHeadacheResponseDataModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/TonixAddHeadacheRepository.dart';
import 'package:mobile/util/AddHeadacheLinearListFilter.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';

class TonixAddHeadacheBloc {
  TonixAddHeadacheRepository _addHeadacheLogRepository = TonixAddHeadacheRepository();
  StreamController<dynamic> _addHeadacheLogStreamController = StreamController();
  StreamController<dynamic> _addNoteStreamController = StreamController();
  CurrentUserHeadacheModel currentUserHeadacheModel = CurrentUserHeadacheModel();
  int count = 0;

  List<SelectedAnswers> selectedAnswersList = [];
  List<List<SelectedAnswers>> medicationSelectedAnswerList = [];

  int? headacheId;
  List<int> _medicationEventIdList = [];

  bool isMedicationLoggedEmpty = false;

  StreamSink<dynamic> get addHeadacheLogDataSink =>
      _addHeadacheLogStreamController.sink;

  Stream<dynamic> get addHeadacheLogDataStream =>
      _addHeadacheLogStreamController.stream;

  StreamController<dynamic> _sendAddHeadacheLogStreamController = StreamController();

  StreamSink<dynamic> get sendAddHeadacheLogDataSink =>
      _sendAddHeadacheLogStreamController.sink;

  Stream<dynamic> get sendAddHeadacheLogDataStream =>
      _sendAddHeadacheLogStreamController.stream;

  StreamSink<dynamic> get addNoteSink =>
      _addNoteStreamController.sink;

  Stream<dynamic> get addNoteStream =>
      _addNoteStreamController.stream;

  bool isHeadacheLogged = false;

  DateTime? _calendarEntryAt;

  TonixAddHeadacheBloc({this.count = 0}) {
    _addHeadacheLogStreamController = StreamController<dynamic>();
    _sendAddHeadacheLogStreamController = StreamController<dynamic>();
    _addNoteStreamController = StreamController<dynamic>();
    _addHeadacheLogRepository = TonixAddHeadacheRepository();
  }

  fetchCalendarHeadacheLogDayData(CurrentUserHeadacheModel currentUserHeadacheModel, BuildContext context) async {
    //this.headacheId = currentUserHeadacheModel.headacheId;
    String? apiResponse;

    var userProfileInfoModel = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url = '${WebservicePost.getServerUrl(context)}common/utc?date=${Utils.getDateTimeInUtcFormat(Utils.getDateTimeOf12AM(DateTime.tryParse(currentUserHeadacheModel.selectedDate!)!.toLocal()), true, context)}&user_id=${userProfileInfoModel.userId}&utc=true';
      var response = await _addHeadacheLogRepository.calendarTriggersServiceCall(url, RequestMethod.GET);
      if (response is AppException) {
        apiResponse = response.toString();
        addHeadacheLogDataSink.addError(response.toString());
      } else {
        if (response != null && response is LogHeadacheResponseDataModel) {
          selectedAnswersList = [];
          LogHeadacheResponseDataModel logHeadacheResponseModel = response;

          if(currentUserHeadacheModel.isFromServer!) {
            headacheId = currentUserHeadacheModel.headacheId;

            currentUserHeadacheModel.mobileEventDetails!.forEach((mobileEventDetailsElement) {
              selectedAnswersList.add(SelectedAnswers(questionTag: mobileEventDetailsElement.questionTag, answer: mobileEventDetailsElement.value));
            });
          } else {
            logHeadacheResponseModel.headache!.asMap().forEach((index, headacheElement) {
              if(index == 0) {
                headacheId = headacheElement.id;

                _calendarEntryAt = headacheElement.calendarEntryAt;

                headacheElement.mobileEventDetails!.forEach((mobileEventDetailsElement) {
                  selectedAnswersList.add(SelectedAnswers(questionTag: mobileEventDetailsElement.questionTag, answer: mobileEventDetailsElement.value));
                });
              }
            });
          }

          logHeadacheResponseModel.medication!.forEach((medicationElement) {
            List<SelectedAnswers> medSelectedAnswerList = [];

            medicationElement.mobileEventDetails!.forEach((mobileEventDetailsElement) {
              medSelectedAnswerList.add(SelectedAnswers(questionTag: mobileEventDetailsElement.questionTag, answer: mobileEventDetailsElement.value));
            });

            if(medSelectedAnswerList.isNotEmpty)
              medicationSelectedAnswerList.add(medSelectedAnswerList);
            else
              isMedicationLoggedEmpty = true;

            _medicationEventIdList.add(medicationElement.id!);
          });


        }

        SelectedAnswers? headacheTypeSelectedAnswer = selectedAnswersList.firstWhereOrNull((element) => element.questionTag == Constant.headacheTypeTag);
        SelectedAnswers? onSetSelectedAnswer = selectedAnswersList.firstWhereOrNull((element) => element.questionTag == Constant.onSetTag);
        SelectedAnswers? endTimeSelectedAnswer = selectedAnswersList.firstWhereOrNull((element) => element.questionTag == Constant.endTimeTag);

        if(headacheTypeSelectedAnswer != null) {
          if(headacheTypeSelectedAnswer.answer == Constant.noHeadacheValue) {
            //onSetSelectedAnswer.answer = Utils.getDateTimeInUtcFormat(DateTime.now());
            currentUserHeadacheModel.isOnGoing = false;
            currentUserHeadacheModel.selectedDate = onSetSelectedAnswer!.answer;
            currentUserHeadacheModel.selectedEndDate = onSetSelectedAnswer.answer;

            /*if(endTimeSelectedAnswer != null)
              endTimeSelectedAnswer.answer = Utils.getDateTimeInUtcFormat(DateTime.now());*/
          }
        }

        if(onSetSelectedAnswer != null) {
          currentUserHeadacheModel.selectedDate = onSetSelectedAnswer.answer;
        }

        if(endTimeSelectedAnswer != null) {
          currentUserHeadacheModel.isOnGoing = false;
          currentUserHeadacheModel.selectedEndDate = endTimeSelectedAnswer.answer;
        }

        if(currentUserHeadacheModel.isOnGoing == null)
          currentUserHeadacheModel.isOnGoing = false;

        if(currentUserHeadacheModel.isOnGoing ?? false)
          await SignUpOnBoardProviders.db.updateUserCurrentHeadacheData(currentUserHeadacheModel);

        await fetchAddHeadacheLogData(context);
      }
    } catch (e) {
      apiResponse = Constant.somethingWentWrong;
      addHeadacheLogDataSink.addError(Exception(Constant.somethingWentWrong));
    }
    return apiResponse;
  }

  Future<dynamic> fetchAddHeadacheLogData(BuildContext context) async {
    try {
      var addHeadacheLogData = await _addHeadacheLogRepository.serviceCall('${WebservicePost.getServerUrl(context)}questionnaire', RequestMethod.POST);
      if (addHeadacheLogData is AppException) {
        addHeadacheLogDataSink.addError(addHeadacheLogData.toString());
      } else {
        if(addHeadacheLogData != null) {
          if(addHeadacheLogData is AddHeadacheLogModel) {
            var addHeadacheLogListData = AddHeadacheLinearListFilter
                .getQuestionSeries(
                addHeadacheLogData.questionnaires[0].initialQuestion,
                addHeadacheLogData.questionnaires[0].questionGroups[0]
                    .questions);

            var addHeadacheLogData1 = await _addHeadacheLogRepository.getMedicationServiceCall(WebservicePost.getServerUrl(context) + 'questionnaire', RequestMethod.POST);

            var addHeadacheLogListData1 = AddHeadacheLinearListFilter
                .getQuestionSeries(
                addHeadacheLogData1.questionnaires[0].initialQuestion,
                addHeadacheLogData1.questionnaires[0].questionGroups[0]
                    .questions);

            if(addHeadacheLogListData1 != null) {
              var medicationQuestion = addHeadacheLogListData1.firstWhereOrNull((element) => element.tag == Constant.logDayMedicationTag);

              if(medicationQuestion != null) {
                await SignUpOnBoardProviders.db.insertMedicationList(medicationQuestion.values!);
              }
            }

            addHeadacheLogListData.addAll(addHeadacheLogListData1);

            addHeadacheLogDataSink.add(addHeadacheLogListData);
          } else {
            addHeadacheLogDataSink.addError(Exception(Constant.somethingWentWrong));
          }
        } else {
          addHeadacheLogDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      //  signUpFirstStepDataSink.add("Error");
      addHeadacheLogDataSink.addError(Exception(Constant.somethingWentWrong));
      print(e.toString());
    }
  }

  Future<List<Map>?> fetchDataFromLocalDatabase(String userId) async {
    return await _addHeadacheLogRepository
        .getAllHeadacheDataFromDatabase(userId);
  }

  sendAddHeadacheDetailsData(
      SignUpOnBoardSelectedAnswersModel
      signUpOnBoardSelectedAnswersModel, List<List<SelectedAnswers>> medicationSelectedAnswerList, DateTime calendarEntryAt, BuildContext context) async {
    String? apiResponse;
    try {
      _addHeadacheLogRepository.currentUserHeadacheModel = currentUserHeadacheModel;
      var signUpFirstStepData;

      if(headacheId == null)
        signUpFirstStepData = await _addHeadacheLogRepository.userAddHeadacheObjectServiceCall('${WebservicePost.getServerUrl(context)}logday', RequestMethod.POST, signUpOnBoardSelectedAnswersModel, medicationSelectedAnswerList, false, headacheId!, _medicationEventIdList, calendarEntryAt, context);
      else
        signUpFirstStepData = await _addHeadacheLogRepository.userAddHeadacheObjectServiceCall('${WebservicePost.getServerUrl(context)}logday', RequestMethod.POST, signUpOnBoardSelectedAnswersModel, medicationSelectedAnswerList, true, headacheId!, _medicationEventIdList, calendarEntryAt, context);

      if (signUpFirstStepData is AppException) {
        sendAddHeadacheLogDataSink.addError(signUpFirstStepData);
        apiResponse = signUpFirstStepData.toString();
        //signUpFirstStepDataSink.add(signUpFirstStepData.toString());
      } else {
        if(signUpFirstStepData != null) {
          isHeadacheLogged = true;
          apiResponse = Constant.success;
        } else {
          sendAddHeadacheLogDataSink.addError(Exception('${Constant.somethingWentWrong}'));
        }
      }
    } catch (e) {
      sendAddHeadacheLogDataSink.addError(Exception('${Constant.somethingWentWrong}'));
      apiResponse = Constant.somethingWentWrong;
      debugPrint(e.toString());
    }
    return apiResponse;
  }

  void dispose() {
    _addHeadacheLogStreamController.close();
    _sendAddHeadacheLogStreamController.close();
    _addNoteStreamController.close();
  }

  void addDataToNoteStream() {
    addNoteSink.add(Constant.loading);
  }

  void enterSomeDummyData() {
    sendAddHeadacheLogDataSink.add(Constant.loading);
  }

  ///If headache lasts for the next date then end the headache at 12:00 AM
  void checkIfHeadacheLastsForTheNextDate(SelectedAnswers onSetSelectedAnswer, SelectedAnswers endTimeSelectedAnswer, BuildContext context) {
    DateTime onSetDateTime = DateTime.tryParse(onSetSelectedAnswer.answer!)!.toLocal();
    DateTime endDateTime = DateTime.tryParse(endTimeSelectedAnswer.answer!)!.toLocal();

    if(onSetDateTime.day != endDateTime.day) {
      endDateTime = Utils.getDateTimeOf12AM(onSetDateTime.add(Duration(days: 1)));

      endTimeSelectedAnswer.answer = Utils.getDateTimeInUtcFormat(endDateTime, true, context);
    }
  }
}
