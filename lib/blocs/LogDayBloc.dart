import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:mobile/models/CalendarInfoDataModel.dart';
import 'package:mobile/models/LogDayResponseModel.dart';
import 'package:mobile/models/LogDaySendDataModel.dart';
import 'package:mobile/models/MedicationSelectedDataModel.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardAnswersRequestModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/models/medication_history_model.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/LogDayRepository.dart';
import 'package:mobile/util/LinearListFilter.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';

import '../models/ResponseModel.dart';
import '../view/medicationlist/medication_list_action_sheet.dart';

class LogDayBloc {
  LogDayRepository _logDayRepository  = LogDayRepository();
  StreamController<dynamic> _logDayDataStreamController = StreamController<dynamic>();

  List<SelectedAnswers> behaviorSelectedAnswerList = [];
  List<List<SelectedAnswers>> medicationSelectedAnswerList = [];
  List<SelectedAnswers> triggerSelectedAnswerList = [];
  List<SelectedAnswers> noteSelectedAnswer = [];

  CalendarInfoDataModel? calendarInfoModel;

  List<MedicationHistoryModel> medicationHistoryDataModelList = [];

  List<SelectedAnswers> selectedAnswerList = [];


  StreamSink<dynamic> get logDayDataSink => _logDayDataStreamController.sink;

  Stream<dynamic> get logDayDataStream => _logDayDataStreamController.stream;

  StreamController<dynamic> _sendLogDayDataStreamController = StreamController();

  StreamSink<dynamic> get sendLogDayDataSink => _sendLogDayDataStreamController.sink;

  Stream<dynamic> get sendLogDayDataStream => _sendLogDayDataStreamController.stream;

  List<Questions> filterQuestionsListData = [];

  DateTime? selectedDateTime;

  int? behaviorEventId;
  List<int> medicationEventIdList = [];
  int? triggerEventId;
  int? noteEventId;

  ResponseModel profileModel = ResponseModel();
  List<MedicationListActionSheetModel> preventiveMedicationActionSheetModelList = [];
  List<MedicationListActionSheetModel> acuteMedicationActionSheetModelList = [];

  LogDayBloc(DateTime? selectedDateTime) {
    _logDayDataStreamController = StreamController<dynamic>();
    _sendLogDayDataStreamController = StreamController<dynamic>();
    _logDayRepository = LogDayRepository();
    this.selectedDateTime = selectedDateTime ?? DateTime.now();
  }

  Future<dynamic> fetchLogDayData(BuildContext context) async {
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
    var logDayData = await _logDayRepository.serviceCall('${WebservicePost.getServerUrl(context)}logday?mobile_user_id=' +
            userProfileInfoData.userId!,
        RequestMethod.GET);
    if (logDayData is AppException) {
      logDayDataSink.addError(logDayData);
    } else {
      if (logDayData is LogDayResponseModel) {
        filterQuestionsListData.addAll(LinearListFilter.getQuestionSeries(
            logDayData.behaviors!.questionnaires![0].initialQuestion!,
            logDayData.behaviors!.questionnaires![0].questionGroups![0].questions!));

        filterQuestionsListData.addAll(LinearListFilter.getQuestionSeries(
            logDayData.triggers!.questionnaires![0].initialQuestion!,
            logDayData.triggers!.questionnaires![0].questionGroups![0].questions!));

        filterQuestionsListData.addAll(LinearListFilter.getQuestionSeries(
            logDayData.medication!.questionnaires![0].initialQuestion!,
            logDayData.medication!.questionnaires![0].questionGroups![0].questions!));

        /*filterQuestionsListData.add(Questions(
          tag: 'device',
          text: 'Devices',
          helpText: 'Did you use any medical devices today?',
          questionType: 'multi',
          precondition: '',
          uiHints: '',
          values: [
            Values(valueNumber: '1', text: 'device 1', isValid: true),
            Values(valueNumber: '2', text: 'device 2', isValid: true),
            Values(valueNumber: '3', text: 'device 3', isValid: true),
            Values(valueNumber: '4', text: 'device 4', isValid: true),
          ],
        ));*/
      }

      if (logDayData is LogDayResponseModel) {
        profileModel = logDayData.profile![0];
      }

      Questions? medicationQuestion = filterQuestionsListData.firstWhere((element) => element.tag == Constant.logDayMedicationTag);

      List<Questions> formulationQuestionList = filterQuestionsListData.where((element) => element.tag!.contains('.formulation')).toList();

      debugPrint(formulationQuestionList.toString());

      /*List<String> formulationList = [];

      formulationQuestionList.forEach((element) {
        element.values?.forEach((el) {
          String? text = formulationList.firstWhereOrNull((e) => e == el.text);

          if (text == null)
            formulationList.add(el.text ?? '');

          if (el.text?.contains('Enteric-coated') == true)
            debugPrint('asdadadasd???${element.tag}');
        });
      });

      debugPrint(formulationList.toString());*/

      medicationQuestion.values!.forEach((element) {
        String medName = element.text!;
        Questions? formulationQuestion = formulationQuestionList.firstWhereOrNull((element1) {
          List<String> splitConditionList = element1.text!.split('=');
          if (splitConditionList.length == 2) {
            splitConditionList[0] = splitConditionList[0].trim();
            splitConditionList[1] = splitConditionList[1].trim();
            return medName == splitConditionList[1];
          } else {
            return false;
          }
        });

        if (formulationQuestion != null) {
          element.medicationType = formulationQuestion.min;
        } else {
          debugPrint('$medName');
        }
      });

      if (medicationQuestion != null) {
        SignUpOnBoardProviders.db.insertMedicationList(medicationQuestion.values!);
      }



      debugPrint(filterQuestionsListData.toString());
      logDayDataSink.add(filterQuestionsListData);
    }
    } catch (e) {
      logDayDataSink.addError(Exception(Constant.somethingWentWrong));
      debugPrint(e.toString());
    }
  }

  fetchCalendarHeadacheLogDayData(String selectedDate, BuildContext context) async {
    selectedDateTime = DateTime.tryParse(selectedDate);
    String? apiResponse;
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url = '${WebservicePost.getServerUrl(context)}common?date=$selectedDate&user_id=${userProfileInfoData.userId}';
      var response = await _logDayRepository.calendarTriggersServiceCall(url, RequestMethod.GET);
      if (response is AppException) {
        apiResponse = response.toString();
        logDayDataSink.addError(response.toString());
      } else {
        if (response != null && response is CalendarInfoDataModel) {
          calendarInfoModel = response;
          if(calendarInfoModel!.behaviours!.length >= 1)
            behaviorEventId = calendarInfoModel!.behaviours![0].id!;
          if(calendarInfoModel!.medication!.length >= 1) {
            calendarInfoModel!.medication!.forEach((element) {
              medicationEventIdList.add(element.id!);
            });
          }

          calendarInfoModel!.triggers?.forEach((triggerElement) {
            MobileEventDetails1? travelTrigger = triggerElement.mobileEventDetails!.firstWhereOrNull((mobileEventElement) => mobileEventElement.questionTag == 'triggers1.travel');

            if (travelTrigger != null) {
              travelTrigger.value = travelTrigger.value?.replaceAll('travelled', 'traveled');
            }
          });


          if(calendarInfoModel!.triggers!.length >= 1)
            triggerEventId = calendarInfoModel!.triggers![0].id!;
          if(calendarInfoModel!.logDayNote!.length >= 1)
            noteEventId = calendarInfoModel!.logDayNote![0].id!;

          debugPrint('id???$behaviorEventId???$medicationEventIdList???$triggerEventId???$noteEventId');
          await fetchMedicationHistoryLogDayData(context);
        } else {
          logDayDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      apiResponse = Constant.somethingWentWrong;
      logDayDataSink.addError(Exception(Constant.somethingWentWrong));
    }
    return apiResponse;
  }

  fetchMedicationHistoryLogDayData(BuildContext context) async {
    String? apiResponse;
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url = '${WebservicePost.getServerUrl(context)}medicationhistory?mobile_user_id=${userProfileInfoData.userId}';
      var response = await _logDayRepository.medicationHistoryServiceCall(url, RequestMethod.GET);
      if (response is AppException) {
        apiResponse = response.toString();
        logDayDataSink.addError(response.toString());
      } else {
        if (response != null && response is List<MedicationHistoryModel>) {
          medicationHistoryDataModelList.addAll(response);
          debugPrint('id???$behaviorEventId???$medicationEventIdList???$triggerEventId???$noteEventId');
          //TODO: add medication history data to the log day sink?

          await fetchLogDayData(context);
        } else {
          logDayDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      apiResponse = Constant.somethingWentWrong;
      logDayDataSink.addError(Exception(Constant.somethingWentWrong));
    }
    return apiResponse;
  }

  Future<List<Map>?> getAllLogDayData(String userId) async {
    return await _logDayRepository.getAllLogDayData(userId);
  }

  void dispose() {
    _logDayDataStreamController.close();
    _sendLogDayDataStreamController.close();
  }

  Future<String?> sendMedicationHistoryData(List<SelectedAnswers> selectedAnswers, List<Questions> questionList, BuildContext context) async {
    String? response;

    SelectedAnswers? selectedAnswer = selectedAnswers.firstWhereOrNull((element) => element.questionTag == Constant.administeredTag);

    if (selectedAnswer != null) {

      List<MedicationListActionSheetModel> medicationListActionSheetModelList = medicationListActionSheetModelFromJson(selectedAnswer.answer ?? '');
      try {
        var responseData = await _logDayRepository.sendMedicationHistoryDataServiceCall('${WebservicePost.getServerUrl(context)}medicationhistory', RequestMethod.POST, medicationListActionSheetModelList.where((element) => element.isChecked).toList());

        if (responseData is AppException) {
          response = responseData.toString();
          sendLogDayDataSink.addError(responseData);
        } else {
          if (responseData is List<MedicationHistoryModel>) {
            responseData.asMap().forEach((index, value) {
              medicationListActionSheetModelList[index].id = value.id;
            });
          }

          selectedAnswer.answer = medicationListActionSheetModelToJson(medicationListActionSheetModelList.where((element) => !element.isDeleted && element.isChecked).toList());

          return await sendLogDayData(selectedAnswers, questionList, context);
        }
      } catch (e) {
        response = Constant.somethingWentWrong;
        sendLogDayDataSink.addError(Exception(Constant.somethingWentWrong));
      }
    } else {
      return await sendLogDayData(selectedAnswers, questionList, context);
    }
    
    return response;
  }


  Future<String?> sendLogDayData(List<SelectedAnswers> selectedAnswers, List<Questions> questionList, BuildContext context) async {
    behaviorSelectedAnswerList.clear();
    medicationSelectedAnswerList.clear();
    triggerSelectedAnswerList.clear();
    String payload = await _getLogDaySubmissionPayload(selectedAnswers, questionList, context);

    Map<String, dynamic> logDayMap = jsonDecode(payload);
    String? response;
    try {
      var logDaySendData = await _logDayRepository.logDaySubmissionDataServiceCall('${WebservicePost.getServerUrl(context)}logday', RequestMethod.POST, payload);
      if (logDaySendData is AppException) {
        response = logDaySendData.toString();
        sendLogDayDataSink.addError(logDaySendData);
      } else {
        debugPrint(logDaySendData.toString());
        _sendAnalyticsData(payload, context);

        await SignUpOnBoardProviders.db.updateMedicationLoggedTimes(logDayMap);

        await SignUpOnBoardProviders.db.insertOrUpdateLogHeadacheMedication(logDayMap);

        if(logDaySendData != null) {
          response = Constant.success;
        } else {
          sendLogDayDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      response = Constant.somethingWentWrong;
      sendLogDayDataSink.addError(Exception(Constant.somethingWentWrong));
      //  signUpFirstStepDataSink.add("Error");
    }
    return response;
  }

  Future<String> _getLogDaySubmissionPayload(List<SelectedAnswers> selectedAnswers, List<Questions> questionList, BuildContext context) async {
    var triggerAlcoholNumSelectedAnswer = selectedAnswers.firstWhereOrNull((element) => element.questionTag == 'triggers1.alcohol');
    var triggerCaffeineNumSelectedAnswer = selectedAnswers.firstWhereOrNull((element) => element.questionTag == 'triggers1.caffeine');

    var triggerSelectedAnswer = selectedAnswers.where((element) => element.questionTag == 'triggers1').toList();

    var triggerQuestion = questionList.firstWhereOrNull((element) => element.tag == Constant.triggersTag);

    if(triggerCaffeineNumSelectedAnswer == null || triggerCaffeineNumSelectedAnswer == null) {
      if(triggerQuestion != null) {
        triggerSelectedAnswer.forEach((element) {
          //int selectedIndex = int.tryParse(element.answer) - 1;

          var triggerValue = triggerQuestion.values!.firstWhereOrNull((e) => e.text == element.answer);

          if(triggerValue!.text!.toLowerCase() == 'alcohol') {
            if(triggerAlcoholNumSelectedAnswer == null) {
              selectedAnswers.add(SelectedAnswers(questionTag: 'triggers1.alcohol', answer: '1'));
            }
          }

          if(triggerValue.text!.toLowerCase() == 'caffeine') {
            if(triggerCaffeineNumSelectedAnswer == null) {
              selectedAnswers.add(SelectedAnswers(questionTag: 'triggers1.caffeine', answer: '1'));
            }
          }
        });
      }
    }

    behaviorSelectedAnswerList.clear();
    medicationSelectedAnswerList.clear();
    triggerSelectedAnswerList.clear();
    noteSelectedAnswer.clear();
    LogDaySendDataModel logDaySendDataModel = LogDaySendDataModel();
    selectedAnswers.forEach((element) {
      List<String> selectedValuesList = [];
      if(element.questionTag!.contains('behavior')) {
        SelectedAnswers? behaviorSelectedAnswer = behaviorSelectedAnswerList.firstWhereOrNull((element1) => element1.questionTag == element.questionTag);
        if(behaviorSelectedAnswer == null) {
          try {
            //int selectedIndex = int.parse(element.answer.toString()) - 1;
            Questions? questions = questionList.firstWhereOrNull((quesElement) => quesElement.tag == element.questionTag);
            if(questions != null) {
              Values? v = questions.values!.firstWhereOrNull((e) => e.text == element.answer);
              selectedValuesList.add(v!.text!);
              behaviorSelectedAnswerList.add(SelectedAnswers(questionTag: element.questionTag, answer: jsonEncode(selectedValuesList)));
            }
          } catch(e) {
            debugPrint(e.toString());
          }
        } else {
          try {
            selectedValuesList = (json.decode(behaviorSelectedAnswer.answer!) as List<dynamic>).cast<String>();
            //int selectedIndex = int.parse(element.answer.toString()) - 1;
            Questions? questions = questionList.firstWhereOrNull((quesElement) => quesElement.tag == element.questionTag);
            if(questions != null) {
              Values? v = questions.values!.firstWhereOrNull((e) => e.text == element.answer);
              selectedValuesList.add(v!.text!);
              behaviorSelectedAnswer.answer = jsonEncode(selectedValuesList);
            }
          } catch(e) {
            debugPrint(e.toString());
          }
        }
      } else if (element.questionTag!.contains('medication') || element.questionTag!.contains('administered') || element.questionTag!.contains('dosage')) {
        if(element.questionTag == 'administered') {
          /*try {
            var decodedJson = jsonDecode(element.answer!);
            MedicationSelectedDataModel medicationSelectedDataModel = MedicationSelectedDataModel.fromJson(decodedJson);
            medicationSelectedDataModel.selectedMedicationIndex.asMap().forEach((index, selectedMedicationValue1) {
              List<SelectedAnswers> medSelectedAnswersList = [];
              medSelectedAnswersList.add(SelectedAnswers(questionTag: Constant.logDayMedicationTag, answer: selectedMedicationValue1.selectedText));
              Questions selectedMedicationQuestion = questionList.firstWhere((quesElement) => quesElement.tag == 'medication');
              if(selectedMedicationQuestion != null) {
                Values? medValue = selectedMedicationQuestion.values!.firstWhereOrNull((element) => element.text == selectedMedicationValue1.text);
                int selectedIndex = selectedMedicationQuestion.values!.indexOf(medValue!);
                String selectedMedicationValue = selectedMedicationQuestion.values![selectedIndex].selectedText!;

                Questions? selectedDosageQuestion = questionList.firstWhereOrNull((element) {
                  List<String> splitConditionList = element.precondition!.split('=');
                  if(splitConditionList.length == 2) {
                    splitConditionList[0] = splitConditionList[0].trim();
                    splitConditionList[1] = splitConditionList[1].trim();

                    if (selectedMedicationValue.length < 5) {
                      return selectedMedicationValue == splitConditionList[1];
                    }else if (selectedMedicationValue == selectedMedicationQuestion.values![selectedIndex].text) {
                      return selectedMedicationValue == splitConditionList[1];
                    } else {
                      return (splitConditionList[1].contains(selectedMedicationValue.replaceAll("(generic)", Constant.blankString).trim()));
                    }
                  } else {
                    return false;
                  }
                });

                selectedValuesList = [];

                if(selectedDosageQuestion != null) {
                  medicationSelectedDataModel.selectedMedicationDosageList[index].forEach((dosageElement) {
                    //int selectedDosageIndex = (int.tryParse(dosageElement.toString()) ?? 0) - 1;
                    Values? v = selectedDosageQuestion.values!.firstWhereOrNull((e) => e.text == dosageElement.toString());
                    selectedValuesList.add(v!.text!);
                  });
                  medSelectedAnswersList.add(SelectedAnswers(questionTag: selectedDosageQuestion.tag, answer: jsonEncode(selectedValuesList)));
                } else {
                  medicationSelectedDataModel.selectedMedicationDosageList[index].forEach((dosageElement) {
                    selectedValuesList.add(dosageElement);
                  });
                  medSelectedAnswersList.add(SelectedAnswers(questionTag: '${selectedMedicationValue}_custom.dosage', answer: jsonEncode(selectedValuesList)));
                }

                selectedValuesList = [];

                medicationSelectedDataModel.selectedMedicationDateList[index].forEach((dateElement) {
                  //selectedValuesList.add(Utils.getDateTimeInUtcFormat(DateTime.parse(dateElement), true, context));
                  selectedValuesList.add(dateElement);
                });

                medSelectedAnswersList.add(SelectedAnswers(questionTag: element.questionTag, answer: jsonEncode(selectedValuesList)));
              }
              medicationSelectedAnswerList.add(medSelectedAnswersList);
            });
          } catch(e) {
            debugPrint(e.toString());
          }*/

          List<MedicationListActionSheetModel> medicationListActionSheetModelList = medicationListActionSheetModelFromJson(element.answer!);

          debugPrint(medicationListActionSheetModelList.toString());

          medicationListActionSheetModelList.where((e) => !e.isDeleted).toList().forEach((modelElement) {
            List<SelectedAnswers> medicationAnswerList = [];

            medicationAnswerList
              ..add(SelectedAnswers(questionTag: Constant.logDayMedicationTag, answer: modelElement.medicationText))
              ..add(SelectedAnswers(questionTag: modelElement.formulationTag, answer: modelElement.formulationText))
              ..add(SelectedAnswers(questionTag: modelElement.dosageTag, answer: modelElement.selectedDosage))
              ..add(SelectedAnswers(questionTag: Constant.administeredTag, answer: modelElement.selectedTime))
              ..add(SelectedAnswers(questionTag: Constant.numberOfDosageTag, answer: modelElement.numberOfDosage.toString()))
              ..add(SelectedAnswers(questionTag: 'is_preventive', answer: modelElement.isPreventive.toString()));

            if (modelElement.id != null)
              medicationAnswerList.add(SelectedAnswers(questionTag: 'medication_history_id', answer: modelElement.id.toString()));

            medicationSelectedAnswerList.add(medicationAnswerList);
          });
        }
      } else if(element.questionTag!.contains('triggers1')) {
        if (element.questionTag != 'triggers1.travel' && element.questionTag != 'triggers1') {
          SelectedAnswers? triggersSelectedAnswer = triggerSelectedAnswerList
              .firstWhereOrNull((element1) =>
          element1.questionTag == element.questionTag);
          if (triggersSelectedAnswer == null) {
            selectedValuesList.add(element.answer!);
            triggerSelectedAnswerList.add(SelectedAnswers(questionTag: element.questionTag, answer: jsonEncode(selectedValuesList)));
          } else {
            try {
              selectedValuesList =
                  (json.decode(triggersSelectedAnswer.answer!) as List<dynamic>)
                      .cast<String>();
              //int selectedIndex = int.tryParse(element.answer.toString()) - 1;
              Questions? questions = questionList.firstWhereOrNull((
                  quesElement) => quesElement.tag == element.questionTag);
              if (questions != null) {
                Values? v = questions.values!.firstWhereOrNull((e) => e.text == element.answer.toString());
                selectedValuesList.add(v!.text!);
                triggersSelectedAnswer.answer = jsonEncode(selectedValuesList);
              }
            } catch (e) {
              debugPrint(e.toString());
            }
          }
        } else if (element.questionTag == 'triggers1') {
          SelectedAnswers? triggersSelectedAnswer = triggerSelectedAnswerList
              .firstWhereOrNull((element1) =>
          element1.questionTag == element.questionTag);
          if (triggersSelectedAnswer == null) {
            try {
              //int selectedIndex = int.parse(element.answer.toString()) - 1;
              Questions? questions = questionList.firstWhereOrNull((quesElement) => quesElement.tag == element.questionTag);
              if(questions != null) {
                Values? v = questions.values!.firstWhereOrNull((e) => e.text == element.answer.toString());
                selectedValuesList.add(v!.text!);
                triggerSelectedAnswerList.add(SelectedAnswers(questionTag: element.questionTag, answer: jsonEncode(selectedValuesList)));
              }
            } catch(e) {
              debugPrint(e.toString());
            }
          } else {
            try {
              selectedValuesList = (json.decode(triggersSelectedAnswer.answer!) as List<dynamic>).cast<String>();
              //int selectedIndex = int.parse(element.answer.toString()) - 1;
              Questions? questions = questionList.firstWhereOrNull((
                  quesElement) => quesElement.tag == element.questionTag);
              if (questions != null) {
                Values? v = questions.values!.firstWhereOrNull((e) => e.text == element.answer.toString());
                selectedValuesList.add(v!.text!);
                triggersSelectedAnswer.answer = jsonEncode(selectedValuesList);
              }
            } catch (e) {
              debugPrint(e.toString());
            }
          }
        } else {
          Questions triggerTravelQuestionObj = Questions.fromJson(jsonDecode(element.answer!));
          triggerTravelQuestionObj.values!.forEach((element) {
            if(element.isSelected) {
              selectedValuesList.add(element.text!);
            }
          });
          triggerSelectedAnswerList.add(SelectedAnswers(
              questionTag: element.questionTag,
              answer: jsonEncode(selectedValuesList)));
        }
      } else if (element.questionTag == 'logday.note') {
        selectedValuesList.add(element.answer!);
        noteSelectedAnswer.add(SelectedAnswers(questionTag: element.questionTag, answer: jsonEncode(selectedValuesList)));
      }
    });

    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    logDaySendDataModel.behaviors = _getSelectAnswerModel(behaviorSelectedAnswerList, Constant.behaviorsEventType, userProfileInfoData, behaviorEventId, context);
    logDaySendDataModel.medication = _getMedicationSelectedAnswerModel(medicationSelectedAnswerList, Constant.medicationEventType, userProfileInfoData, medicationEventIdList, context);
    logDaySendDataModel.triggers = _getSelectAnswerModel(triggerSelectedAnswerList, Constant.triggersEventType, userProfileInfoData, triggerEventId, context);
    logDaySendDataModel.note = _getSelectAnswerModel(noteSelectedAnswer, Constant.noteEventType, userProfileInfoData, noteEventId, context);

    return jsonEncode(logDaySendDataModel.toJson());
  }

  List<SignUpOnBoardAnswersRequestModel> _getMedicationSelectedAnswerModel(List<List<SelectedAnswers>> selectedAnswersList, String eventType, UserProfileInfoModel userProfileInfoData, List<int> eventId, BuildContext context) {
    List<SignUpOnBoardAnswersRequestModel> signUpOnBoardAnswersRequestModelList = [];

    selectedAnswersList.asMap().forEach((key, selectedAnswers) {
      SignUpOnBoardAnswersRequestModel signUpOnBoardAnswersRequestModel = SignUpOnBoardAnswersRequestModel();
      signUpOnBoardAnswersRequestModel.eventType = eventType;
      if (userProfileInfoData != null)
        signUpOnBoardAnswersRequestModel.userId =
            int.parse(userProfileInfoData.userId!);
      else
        signUpOnBoardAnswersRequestModel.userId = 4214;
      DateTime dateTime = DateTime.now();
      if(selectedDateTime == null){
        signUpOnBoardAnswersRequestModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(dateTime, true, context);
      }else{
        signUpOnBoardAnswersRequestModel.calendarEntryAt = '${selectedDateTime!.year}-${selectedDateTime!.month}-${selectedDateTime!.day}T00:00:00Z';
      }

      signUpOnBoardAnswersRequestModel.updatedAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);
      try {
        signUpOnBoardAnswersRequestModel.eventId = eventId[key];
      } catch(e) {
        signUpOnBoardAnswersRequestModel.eventId = null;
      }
      signUpOnBoardAnswersRequestModel.mobileEventDetails = [];

      selectedAnswers.forEach((element) {
        /*try {
          List<String> valuesList = (json.decode(element.answer!) as List<dynamic>).cast<String>();
          signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
              MobileEventDetails(
                  questionTag: element.questionTag,
                  *//*eventId: eventId,*//*
                  questionJson: "",
                  updatedAt: Utils.getDateTimeInUtcFormat(DateTime.now(), true, context),
                  value: valuesList));
        } on FormatException {
          signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
              MobileEventDetails(
                  questionTag: element.questionTag,
                  *//*eventId: eventId,*//*
                  questionJson: "",
                  updatedAt: Utils.getDateTimeInUtcFormat(DateTime.now(), true, context),
                  value: [element.answer!]));
        }*/
        signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
            MobileEventDetails(
                questionTag: element.questionTag,
                questionJson: "",
                updatedAt: Utils.getDateTimeInUtcFormat(DateTime.now(), true, context),
                value: [element.answer!]));
      });

      signUpOnBoardAnswersRequestModelList.add(signUpOnBoardAnswersRequestModel);
    });

    int lengthDiff = eventId.length - selectedAnswersList.length;

    int eventIndex = selectedAnswersList.length;

    if(lengthDiff > 0) {
      for (int i = 1; i <= lengthDiff; i++) {
        SignUpOnBoardAnswersRequestModel signUpOnBoardAnswersRequestModel = SignUpOnBoardAnswersRequestModel();
        signUpOnBoardAnswersRequestModel.eventType = eventType;
        if (userProfileInfoData != null)
          signUpOnBoardAnswersRequestModel.userId =
              int.parse(userProfileInfoData.userId!);
        else
          signUpOnBoardAnswersRequestModel.userId = 4214;
        DateTime dateTime = DateTime.now();
        if(selectedDateTime == null){
          signUpOnBoardAnswersRequestModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(dateTime, true , context);
        }else{
          signUpOnBoardAnswersRequestModel.calendarEntryAt = '${selectedDateTime!.year}-${selectedDateTime!.month}-${selectedDateTime!.day}T00:00:00Z';
        }

        signUpOnBoardAnswersRequestModel.updatedAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);

        try {
          signUpOnBoardAnswersRequestModel.eventId = eventId[eventIndex];
          eventIndex++;
        } catch(e) {
          signUpOnBoardAnswersRequestModel.eventId = null;
        }
        signUpOnBoardAnswersRequestModel.mobileEventDetails = [];

        signUpOnBoardAnswersRequestModelList.add(signUpOnBoardAnswersRequestModel);
      }
    }

    return signUpOnBoardAnswersRequestModelList;
  }

  SignUpOnBoardAnswersRequestModel _getSelectAnswerModel(List<SelectedAnswers> selectedAnswers, String eventType, UserProfileInfoModel userProfileInfoData, int? eventId, BuildContext context){
    SignUpOnBoardAnswersRequestModel signUpOnBoardAnswersRequestModel = SignUpOnBoardAnswersRequestModel();
    signUpOnBoardAnswersRequestModel.eventType = eventType;
    if (userProfileInfoData != null)
      signUpOnBoardAnswersRequestModel.userId =
          int.parse(userProfileInfoData.userId!);
    else
      signUpOnBoardAnswersRequestModel.userId = 4214;
    DateTime dateTime = DateTime.now();
    if(selectedDateTime == null){
      signUpOnBoardAnswersRequestModel.calendarEntryAt = Utils.getDateTimeInUtcFormat(dateTime, true, context);
    }else{
      signUpOnBoardAnswersRequestModel.calendarEntryAt = '${selectedDateTime!.year}-${selectedDateTime!.month}-${selectedDateTime!.day}T00:00:00Z';
    }

    signUpOnBoardAnswersRequestModel.updatedAt = Utils.getDateTimeInUtcFormat(DateTime.now(), true, context);
    signUpOnBoardAnswersRequestModel.eventId = eventId;
    signUpOnBoardAnswersRequestModel.mobileEventDetails = [];

    selectedAnswers.forEach((element) {
      List<String> valuesList =
      (json.decode(element.answer!) as List<dynamic>).cast<String>();
      signUpOnBoardAnswersRequestModel.mobileEventDetails!.add(
          MobileEventDetails(
              questionTag: element.questionTag,
              /*eventId: eventId,*/
              questionJson: "",
              updatedAt: Utils.getDateTimeInUtcFormat(DateTime.now(), true, context),
              value: valuesList));
    });

    return signUpOnBoardAnswersRequestModel;
  }

  List<SelectedAnswers> getSelectedAnswerList(List<SelectedAnswers> doubleTappedSelectedAnswerList) {
    if (selectedAnswerList == null || selectedAnswerList.isEmpty) {
      selectedAnswerList = [];

      selectedAnswerList.addAll(doubleTappedSelectedAnswerList);

      if (calendarInfoModel != null) {
        calendarInfoModel!.behaviours!.forEach((behaviorElement) {
          behaviorElement.mobileEventDetails!.forEach((behaviorMobileEventDetailsElement) {
            selectedAnswerList.removeWhere((element) => element.questionTag == behaviorMobileEventDetailsElement.questionTag);
            Questions? questions = filterQuestionsListData.firstWhereOrNull((questionElement) => questionElement.tag == behaviorMobileEventDetailsElement.questionTag);
            if(questions != null) {
              String value = behaviorMobileEventDetailsElement.value!;
              List<String> valuesList = value.split("%@");
              valuesList.forEach((valueElement) {
                Values? selectedValues = questions.values!.firstWhereOrNull((element) => valueElement == element.text);
                selectedAnswerList.add(SelectedAnswers(
                    questionTag: behaviorMobileEventDetailsElement.questionTag,
                    answer: selectedValues!.text,
                    isDoubleTapped: false));
              });
            }
          });
        });

        MedicationSelectedDataModel medicationSelectedDataModel = MedicationSelectedDataModel();
        medicationSelectedDataModel.selectedMedicationIndex = [];
        medicationSelectedDataModel.selectedMedicationDosageList = [];
        medicationSelectedDataModel.selectedMedicationDateList = [];

        debugPrint('MedicationLength???${calendarInfoModel!.medication!.length}');

        List<MedicationListActionSheetModel> medicationListActionSheetModelList = [];

        calendarInfoModel!.medication!.forEach((medicationElement) {
          MobileEventDetails1? medicationMobileEventDetails = medicationElement.mobileEventDetails?.firstWhereOrNull((element) => element.questionTag == Constant.logDayMedicationTag);
          MobileEventDetails1? administeredMobileEventDetails = medicationElement.mobileEventDetails?.firstWhereOrNull((element) => element.questionTag == Constant.administeredTag);
          MobileEventDetails1? dosageMobileEventDetails = medicationElement.mobileEventDetails?.firstWhereOrNull((element) => element.questionTag?.contains('.dosage') == true);
          MobileEventDetails1? formulationMobileEventDetails = medicationElement.mobileEventDetails?.firstWhereOrNull((element) => element.questionTag?.contains('.formulation') == true);

          Questions? medicationQuestion = filterQuestionsListData.firstWhereOrNull((element) => element.tag == Constant.logDayMedicationTag);

          if (medicationMobileEventDetails != null && formulationMobileEventDetails == null) {
            String medName = medicationMobileEventDetails.value ?? Constant.blankString;

            Values? medValue = medicationQuestion?.values?.firstWhereOrNull((element) => element.text?.toLowerCase() == medName.toLowerCase());

            int? id;
            String medicationText = '';
            String formulationText = '';
            String formulationTag = '';
            String selectedTime = '';
            DateTime? startDate;
            DateTime? endDate;
            String selectedDosage = '';
            String dosageTag = '';
            double? numberOfDosage;
            bool isPreventive = true;
            String? reason;
            String? comments;

            if (medValue != null) {
              medicationText = medValue.text ?? Constant.blankString;
              isPreventive = medValue.medicationType == 2 || medValue.medicationType == 3;
            } else {
              medicationText = medName;
              medicationText = medicationText == 'Onabotulinumtoxina (Botox)' ? 'BOTOX' : medicationText;
            }

            if (administeredMobileEventDetails != null && dosageMobileEventDetails != null) {
              if (administeredMobileEventDetails.value?.contains("%@") == true && dosageMobileEventDetails.value?.contains("%@") == true) {

                List<String> administeredList = administeredMobileEventDetails.value?.split("%@") ?? [];
                List<String> dosageList = dosageMobileEventDetails.value?.split("%@") ?? [];

                if (administeredList.isNotEmpty && dosageList.isNotEmpty) {
                  administeredList.asMap().forEach((index, value) {
                    selectedTime = value;
                    selectedDosage = dosageList[index];

                    MedicationListActionSheetModel medicationListActionSheetModel = MedicationListActionSheetModel(
                      id: id,
                      medicationText: medicationText,
                      formulationText: formulationText,
                      formulationTag: formulationTag,
                      selectedTime: selectedTime,
                      startDate: startDate,
                      endDate: endDate,
                      medicationValue: null,
                      selectedDosage: selectedDosage,
                      dosageTag: dosageTag,
                      numberOfDosage: numberOfDosage,
                      isPreventive: isPreventive,
                      reason: reason,
                      comments: comments,
                      isChecked: true,
                    );

                    medicationListActionSheetModelList.add(medicationListActionSheetModel);
                  });
                }
              } else {
                selectedTime = administeredMobileEventDetails.value ?? '';
                selectedDosage = dosageMobileEventDetails.value ?? '';

                MedicationListActionSheetModel medicationListActionSheetModel = MedicationListActionSheetModel(
                  id: id,
                  medicationText: medicationText,
                  formulationText: formulationText,
                  formulationTag: formulationTag,
                  selectedTime: selectedTime,
                  startDate: startDate,
                  endDate: endDate,
                  medicationValue: null,
                  selectedDosage: selectedDosage,
                  dosageTag: dosageTag,
                  numberOfDosage: numberOfDosage,
                  isPreventive: isPreventive,
                  reason: reason,
                  comments: comments,
                  isChecked: true,
                );

                medicationListActionSheetModelList.add(medicationListActionSheetModel);
              }
            }
          } else {
            if (medicationElement.mobileEventDetails?.isNotEmpty == true) {
              int? id;
              String medicationText = '';
              String formulationText = '';
              String formulationTag = '';
              String selectedTime = '';
              DateTime? startDate;
              DateTime? endDate;
              String selectedDosage = '';
              String dosageTag = '';
              double? numberOfDosage;
              bool isPreventive = true;
              String? reason;
              String? comments;

              medicationElement.mobileEventDetails!.forEach((element) {
                if (element.questionTag == 'medication_history_id') {
                  id = int.tryParse(element.value ?? '');

                  MedicationHistoryModel? medicationHistoryModel = medicationHistoryDataModelList.firstWhereOrNull((element) => element.id == id);

                  if (medicationHistoryModel != null) {
                    startDate = medicationHistoryModel.startDate;
                    endDate = medicationHistoryModel.endDate;
                    reason = medicationHistoryModel.reason;
                    comments = medicationHistoryModel.comments;
                  }
                } else if (element.questionTag == 'medication') {
                  medicationText = element.value ?? '';
                } else if (element.questionTag?.contains('.formulation') ?? false) {
                  formulationText = element.value ?? '';
                  formulationTag = element.questionTag ?? '';
                } else if (element.questionTag == Constant.administeredTag) {
                  selectedTime = element.value ?? '';
                } else if (element.questionTag == Constant.numberOfDosageTag) {
                  numberOfDosage = double.tryParse(element.value ?? '');
                } else if (element.questionTag == 'is_preventive') {
                  isPreventive = element.value == 'true';
                } else if (element.questionTag?.contains('.dosage') ?? false) {
                  selectedDosage = element.value ?? '';
                  dosageTag = element.questionTag ?? '';
                }
              });

              MedicationListActionSheetModel medicationListActionSheetModel = MedicationListActionSheetModel(
                id: id,
                medicationText: medicationText,
                formulationText: formulationText,
                formulationTag: formulationTag,
                selectedTime: selectedTime,
                startDate: startDate,
                endDate: endDate,
                medicationValue: null,
                selectedDosage: selectedDosage,
                dosageTag: dosageTag,
                numberOfDosage: numberOfDosage,
                isPreventive: isPreventive,
                reason: reason,
                comments: comments,
                isChecked: true,
              );

              medicationListActionSheetModelList.add(medicationListActionSheetModel);
            }
          }
        });

        selectedAnswerList.add(SelectedAnswers(questionTag: Constant.administeredTag, answer: medicationListActionSheetModelToJson(medicationListActionSheetModelList)));

        debugPrint(medicationSelectedDataModel.toString());

        calendarInfoModel!.triggers!.forEach((triggerElement) {
          triggerElement.mobileEventDetails!.forEach((triggerMobileEventDetailElement) {
            selectedAnswerList.removeWhere((element) => element.questionTag == triggerMobileEventDetailElement.questionTag);
            Questions? questions = filterQuestionsListData.firstWhereOrNull((questionElement) => questionElement.tag == triggerMobileEventDetailElement.questionTag);
            if(questions != null) {
              if (triggerMobileEventDetailElement.questionTag ==
                  Constant.triggersTag) {
                List<String> triggersSelectedValues = triggerMobileEventDetailElement
                    .value!.split("%@");
                triggersSelectedValues.forEach((valueElement) {
                  Values? selectedValues = questions.values!.firstWhereOrNull((
                      element) => valueElement == element.text);
                  selectedAnswerList.add(SelectedAnswers(
                      questionTag: triggerMobileEventDetailElement.questionTag,
                      answer: selectedValues!.text,
                      isDoubleTapped: false));
                });
              } else if (questions.questionType == Constant.QuestionMultiType) {
                List<String> selectedValues = triggerMobileEventDetailElement
                    .value!.split("%@");
                selectedValues.forEach((selectedValueElement) {
                  Values? values = questions.values!.firstWhereOrNull((
                      element) => element.text == selectedValueElement);
                  if (values != null) {
                    values.isSelected = true;
                  }
                });
                selectedAnswerList.add(SelectedAnswers(
                    questionTag: questions.tag,
                    answer: jsonEncode(questions.toJson()),
                    isDoubleTapped: false));
              } else
              if (questions.questionType == Constant.QuestionNumberType) {
                selectedAnswerList.add(SelectedAnswers(
                    questionTag: questions.tag,
                    answer: triggerMobileEventDetailElement.value,
                    isDoubleTapped: false));
              } else if (questions.questionType == Constant.QuestionTextType) {
                selectedAnswerList.add(SelectedAnswers(
                    questionTag: questions.tag,
                    answer: triggerMobileEventDetailElement.value,
                    isDoubleTapped: false));
              }
            } else {
              selectedAnswerList.add(SelectedAnswers(
                  questionTag: triggerMobileEventDetailElement.questionTag,
                  answer: triggerMobileEventDetailElement.value,
                  isDoubleTapped: false));
            }
          });
        });

        calendarInfoModel!.logDayNote!.forEach((logDayNoteElement) {
          MobileEventDetails1? mobileEventDetails1 = logDayNoteElement.mobileEventDetails!.firstWhereOrNull((element) => element.questionTag == Constant.logDayNoteTag);
          if(mobileEventDetails1 != null) {
            selectedAnswerList.add(SelectedAnswers(questionTag: mobileEventDetails1.questionTag, answer: mobileEventDetails1.value));
          }
        });
      }
    }

    var profileSexDetail = profileModel.mobileEventDetails.firstWhereOrNull((e) => e.questionTag == Constant.profileSexTag);
    var profileGenderDetail = profileModel.mobileEventDetails.firstWhereOrNull((e) => e.questionTag == Constant.profileGenderTag);
    var profileMenstruationDetail = profileModel.mobileEventDetails.firstWhereOrNull((e) => e.questionTag == Constant.profileMenstruationTag);

    if (profileSexDetail != null && profileGenderDetail != null) {
      if (profileSexDetail.value != "Female" || profileGenderDetail.value != "Woman"  || profileMenstruationDetail?.value == Constant.isStopped) {
        var triggersSelectedAnswerList = selectedAnswerList.where((element) => element.questionTag == Constant.triggersTag);
        var menstruatingTriggerSelectedAnswer = triggersSelectedAnswerList.firstWhereOrNull((element) => element.answer == Constant.menstruatingTriggerOption);

        if (menstruatingTriggerSelectedAnswer == null) {
          var triggersQuestion = filterQuestionsListData.firstWhereOrNull((element) => element.tag == Constant.triggersTag);
          if (triggersQuestion != null) {
            triggersQuestion.values!.removeWhere((element) => element.text == Constant.menstruatingTriggerOption);
            doubleTappedSelectedAnswerList.removeWhere((element) => (element.questionTag == Constant.triggersTag) && (element.answer == Constant.menstruatingTriggerOption));
            debugPrint('${triggersQuestion.values}');
          }
        }
      }
    }

    selectedAnswerList.forEach((selectedAnswerElement) {
      if(selectedAnswerElement.questionTag == Constant.behaviourPreSleepTag ||
        selectedAnswerElement.questionTag == Constant.behaviourPreExerciseTag ||
        selectedAnswerElement.questionTag == Constant.behaviourPreMealTag ||
        selectedAnswerElement.questionTag == Constant.administeredTag ||
        selectedAnswerElement.questionTag == Constant.triggersTag) {
        var doubleTapSelectedAnswerList = doubleTappedSelectedAnswerList.where((doubleTappedSelectedAnswerElement) => doubleTappedSelectedAnswerElement.questionTag == selectedAnswerElement.questionTag /*&& doubleTappedSelectedAnswerElement.answer == selectedAnswerElement.answer*/);
        //SelectedAnswers doubleTappedSelectedAnswer = doubleTappedSelectedAnswerList.firstWhere((doubleTappedSelectedAnswerElement) => doubleTappedSelectedAnswerElement.questionTag == selectedAnswerElement.questionTag /*&& doubleTappedSelectedAnswerElement.answer == selectedAnswerElement.answer*/, orElse: () => null);
        if(doubleTapSelectedAnswerList != null) {
          doubleTapSelectedAnswerList.forEach((doubleTappedSelectedAnswer) {
            if(doubleTappedSelectedAnswer != null) {
              if(doubleTappedSelectedAnswer.questionTag != Constant.administeredTag) {
                if(doubleTappedSelectedAnswer.answer == selectedAnswerElement.answer) {
                  selectedAnswerElement.isDoubleTapped = true;
                }
              } /*else {
                debugPrint("$selectedAnswerElement");
                if(selectedAnswerElement.answer!.isNotEmpty && doubleTappedSelectedAnswer.answer!.isNotEmpty) {

                  MedicationSelectedDataModel medicationSelectedDataModel = MedicationSelectedDataModel.fromJson(jsonDecode(doubleTappedSelectedAnswer.answer!));
                  MedicationSelectedDataModel medicationSelectedDataModel1 = MedicationSelectedDataModel.fromJson(jsonDecode(selectedAnswerElement.answer!));

                  if(medicationSelectedDataModel != null && medicationSelectedDataModel1 != null) {
                    medicationSelectedDataModel.selectedMedicationIndex.forEach((selectedMedicationIndexElement1) {
                        Values? medValue = medicationSelectedDataModel1.selectedMedicationIndex.firstWhereOrNull((selectedMedicationIndexElement2) =>
                        selectedMedicationIndexElement1.text == selectedMedicationIndexElement2.text);
                        if (medValue != null) {
                          medValue.isDoubleTapped = true;
                          selectedAnswerElement.answer = jsonEncode(medicationSelectedDataModel1.toJson());
                        }
                    });
                  }
                }
              }*/
            }
          });
        }
      }
    });

    if(selectedAnswerList.isEmpty) {
      SelectedAnswers? medicationSelectedAnswers = doubleTappedSelectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.administeredTag);

      if(medicationSelectedAnswers != null) {
        MedicationSelectedDataModel medicationSelectedDataModel = MedicationSelectedDataModel.fromJson(jsonDecode(medicationSelectedAnswers.answer!));

        if(medicationSelectedDataModel != null) {
          List<Values> medValueList = [];
          List<List<String>> medDateList = [];
          List<List<String>> medDosageList = [];
          medicationSelectedDataModel.selectedMedicationIndex.asMap().forEach((key, value) {
            if(!value.isDoubleTapped) {
              medValueList.add(value);
              medDateList.add(medicationSelectedDataModel.selectedMedicationDateList[key]);
              medDosageList.add(medicationSelectedDataModel.selectedMedicationDosageList[key]);
            }
          });

          medValueList.forEach((element) {
            medicationSelectedDataModel.selectedMedicationIndex.remove(element);
          });

          medDateList.forEach((element) {
            medicationSelectedDataModel.selectedMedicationDateList.remove(element);
          });

          medDosageList.forEach((element) {
            medicationSelectedDataModel.selectedMedicationDosageList.remove(element);
          });
        }

        medicationSelectedAnswers.answer = jsonEncode(medicationSelectedDataModel);
      }
    }

    return selectedAnswerList;
  }

  void enterSomeDummyDataToStreamController() {
    sendLogDayDataSink.add(Constant.loading);
  }

  void _sendAnalyticsData(String payload, BuildContext context) async {
    Map<String, dynamic> params;
    bool isEdited = behaviorEventId != null || medicationEventIdList.isNotEmpty || triggerEventId != null || noteEventId != null;
    params = {
      'isEdited': isEdited.toString(),
      /*'data': payload,*/
    };

    Map<dynamic, dynamic> jsonMap = jsonDecode(payload);

    debugPrint('Working1');

    jsonMap["behaviors"]["mobile_event_details"].forEach((element) {
      debugPrint('Working3');
      String tag = element["question_tag"].replaceAll(".", "_");
      var valueList = element["value"];

      if(valueList.isNotEmpty) {
        if(valueList.length == 1) {
          params[tag] = valueList[0];
        } else {
          params[tag] = valueList.toString();
        }
      }
    });

    debugPrint('Working4');

    jsonMap["medication"].asMap().forEach((index, element1) {
      debugPrint('Working5');
      element1["mobile_event_details"].forEach((element) {
        debugPrint('Working6');
        var tag = element["question_tag"].replaceAll(".", "_");
        var valueList = element["value"];

        if(valueList.isNotEmpty) {
          if(valueList.length == 1) {
            params["$tag$index"] = valueList[0];
          } else {
            params["$tag$index"] = valueList.toString();
          }
        }
      });
    });

    debugPrint('Working7');

    jsonMap["triggers"]["mobile_event_details"].forEach((element) {
      debugPrint('Working8');
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

    debugPrint('Working9');

    jsonMap["note"]["mobile_event_details"].forEach((element) {
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

    var userProfileInfoModel = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    params['user_id'] = userProfileInfoModel.userId;

    Utils.sendAnalyticsEvent(Constant.logDayEvent, params, context);
  }
}
