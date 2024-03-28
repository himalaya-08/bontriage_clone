import 'dart:async';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mobile/models/CalendarInfoDataModel.dart';
import 'package:mobile/models/UserHeadacheLogDayDetailsModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/CalendarRepository.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';

import '../models/medication_history_model.dart';

class CalendarHeadacheLogDayDetailsBloc {

  //regex for removing the redundant decimal zeros from doubleString
  RegExp regex = RegExp(r'([.]*0)(?!.*\d)');

  CalendarRepository? _calendarRepository;
  StreamController<dynamic>? _calendarLogDayStreamController;
  StreamController<dynamic>? _networkStreamController;
  UserHeadacheLogDayDetailsModel userHeadacheLogDayDetailsModel =
      UserHeadacheLogDayDetailsModel();
  int count = 0;
  int? onGoingHeadacheId;

  StreamSink<dynamic> get calendarLogDayDataSink =>
      _calendarLogDayStreamController!.sink;

  Stream<dynamic> get calendarLogDayDetailsDataStream =>
      _calendarLogDayStreamController!.stream;

  Stream<dynamic> get networkDataStream => _networkStreamController!.stream;

  StreamSink<dynamic> get networkDataSink => _networkStreamController!.sink;

  List<MedicationHistoryModel> _medicationHistoryDataModelList = [];

  List<MedicationHistoryModel> get medicationHistoryDataModelList => _medicationHistoryDataModelList;
  Map<String, DateTime> _unitMedicationsLastDate = Map();

  CalendarHeadacheLogDayDetailsBloc({this.count = 0}) {
    _calendarLogDayStreamController = StreamController<dynamic>();
    _networkStreamController = StreamController<dynamic>();
    _calendarRepository = CalendarRepository();
  }

  Future<void> fetchMedicationHistoryLogDayData(String selectedDate, BuildContext context) async {
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url = '${WebservicePost.getServerUrl(context)}medicationhistory?mobile_user_id=${userProfileInfoData.userId}';
      var response = await _calendarRepository?.medicationHistoryServiceCall(url, RequestMethod.GET);
      if (response is AppException) {
        networkDataSink.addError(response);
      } else {
        if (response != null && response is List<MedicationHistoryModel>) {
          _medicationHistoryDataModelList.clear();
          _unitMedicationsLastDate.clear();

          _medicationHistoryDataModelList.addAll(response);
          Utils.lastGivenDateGenerator(medicationHistoryDataModelList, _unitMedicationsLastDate);

          await Future.delayed(Duration(seconds: 1)).then((value) async {
            await fetchCalendarHeadacheLogDayData(selectedDate, context);
          });
        } else {
          networkDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      networkDataSink.addError(Exception(Constant.somethingWentWrong));
    }
  }

  fetchCalendarHeadacheLogDayData(
      String selectedDate, BuildContext context) async {
    if (userHeadacheLogDayDetailsModel.headacheLogDayListData != null)
      userHeadacheLogDayDetailsModel.headacheLogDayListData!.clear();
    String? apiResponse;
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url =
          '${WebservicePost.getServerUrl(context)}common?date=$selectedDate&user_id=${userProfileInfoData.userId}';
      var response = await _calendarRepository!
          .calendarTriggersServiceCall(url, RequestMethod.GET);
      if (response is AppException) {
        apiResponse = response.toString();
        networkDataSink.addError(response);
      } else {
        if (response != null && response is CalendarInfoDataModel) {
          debugPrint(response.toString());
          getHeadacheLogDayData(response);
          if (userHeadacheLogDayDetailsModel.headacheLogDayListData != null) {
            userHeadacheLogDayDetailsModel.headacheLogDayListData!
                .removeWhere((element) => element.imagePath == null);
          }
          calendarLogDayDataSink.add(userHeadacheLogDayDetailsModel);
          networkDataSink.add(Constant.success);
        }
      }
    } catch (e) {
      apiResponse = Constant.somethingWentWrong;
      networkDataSink.addError(Exception(Constant.somethingWentWrong));
    }
    return apiResponse;
  }

  void enterSomeDummyDataToStreamController() {
    networkDataSink.add(Constant.loading);
  }

  void initNetworkStreamController() {
    _networkStreamController?.close();
    _networkStreamController = StreamController<dynamic>();
  }

  void dispose() {
    _calendarLogDayStreamController?.close();
    _networkStreamController?.close();
  }

  UserHeadacheLogDayDetailsModel getHeadacheLogDayData(
      CalendarInfoDataModel response) {
    RecordWidgetData headacheWidgetData = RecordWidgetData();
    if (response.headache!.length > 0 ||
        response.behaviours!.length > 0 ||
        response.triggers!.length > 0 ||
        response.medication!.length > 0 ||
        response.logDayNote!.length > 0) {
      userHeadacheLogDayDetailsModel.headacheLogDayListData = [];
      userHeadacheLogDayDetailsModel.isDayLogged = false;
      userHeadacheLogDayDetailsModel.isHeadacheLogged = false;
      headacheWidgetData.headacheListData = [];
      headacheWidgetData.imagePath = Constant.migraineIcon;
    }
    response.headache!.forEach((element) {
      if (element.mobileEventDetails?.isNotEmpty ?? false) {
        var headacheTypeData = element.mobileEventDetails?.firstWhereOrNull(
                (mobileEventElement) =>
            mobileEventElement.questionTag == Constant.HeadacheTypeTag);
        var headacheEndTimeData = element.mobileEventDetails?.firstWhereOrNull(
                (mobileEventElement) =>
            mobileEventElement.questionTag == Constant.endTimeTag);
        var headacheStartTimeData = element.mobileEventDetails?.firstWhereOrNull(
                (mobileEventElement) =>
            mobileEventElement.questionTag == Constant.onSetTag);
        var headacheIntensityData = element.mobileEventDetails?.firstWhereOrNull(
                (mobileEventElement) =>
            mobileEventElement.questionTag == Constant.severityTag);
        var headacheDisabilityData = element.mobileEventDetails?.firstWhereOrNull(
                (mobileEventElement) =>
            mobileEventElement.questionTag == Constant.disabilityTag);
        var headacheOnGoingData = element.mobileEventDetails?.firstWhereOrNull(
                (mobileEventElement) =>
            mobileEventElement.questionTag == Constant.onGoingTag);
        var headacheNoteData = element.mobileEventDetails?.firstWhereOrNull(
                (mobileEventElement) =>
            mobileEventElement.questionTag == Constant.headacheNoteTag);

        HeadacheData headacheData = HeadacheData();
        headacheData.isMigraine = element.isMigraine ?? true;
        headacheData.headacheId = element.id;
        String headacheInfo = "";
        if (headacheTypeData != null) {
          headacheData.headacheName = '${headacheTypeData.value} (${element.isMigraine ?? true ? 'Migraine' : 'Headache'})';
        } else {
          headacheData.headacheName = "";
        }
        if (headacheNoteData != null) {
          headacheData.headacheNote = headacheNoteData.value;
        } else {
          headacheData.headacheNote = "";
        }
        if (headacheOnGoingData != null) {
          if (headacheOnGoingData.value!.toLowerCase() == 'yes') {
            onGoingHeadacheId = element.id;
            headacheInfo = 'Headache On-Going: Yes';
            DateTime? startDataTime =
            DateTime.tryParse(headacheStartTimeData?.value ?? '');
            if (startDataTime != null) {
              startDataTime = startDataTime;
              headacheInfo =
              'Headache starting on ${Constant.monthMapper[startDataTime.month]} ${startDataTime.day} at ${Utils.getTimeInAmPmFormat(startDataTime.hour, startDataTime.minute)} currently in progress.\n$headacheInfo\nStart Time: ${Utils.getTimeInAmPmFormat(startDataTime.hour, startDataTime.minute)}';
            }

          } else if (headacheEndTimeData != null && headacheStartTimeData != null) {
            onGoingHeadacheId = null;
            DateTime? startDataTime =
            DateTime.tryParse(headacheStartTimeData.value!)!;
            DateTime endDataTime = DateTime.tryParse(headacheEndTimeData.value!)!;
            Duration headacheTimeDuration = endDataTime.difference(startDataTime);
            if (headacheStartTimeData != headacheEndTimeData) {
              headacheInfo =
              'Started on ${Constant.monthMapper[startDataTime.month]} ${startDataTime.day} at ${Utils.getTimeInAmPmFormat(startDataTime.hour, startDataTime.minute)}, ended on ${Constant.monthMapper[endDataTime.month]} ${endDataTime.day} at ${Utils.getTimeInAmPmFormat(endDataTime.hour, endDataTime.minute)}.\nDuration: ${_getDisplayTime(headacheTimeDuration.inMinutes.abs())}';
            }
          }
        }
        if (headacheIntensityData != null) {
          headacheInfo =
          '$headacheInfo\nIntensity: ${headacheIntensityData.value}';
        } else {
          headacheInfo = '$headacheInfo\nIntensity: 0';
        }
        if (headacheDisabilityData != null) {
          headacheInfo =
          '$headacheInfo, Disability: ${headacheDisabilityData.value}';
        } else {
          headacheInfo = '$headacheInfo, Disability: 0';
        }
        headacheData.headacheInfo = headacheInfo;
        headacheWidgetData.headacheListData!.add(headacheData);
        userHeadacheLogDayDetailsModel.isHeadacheLogged = true;
      }
    });

    if (userHeadacheLogDayDetailsModel.headacheLogDayListData != null) {
      if (headacheWidgetData.headacheListData?.isNotEmpty ?? false) {
        userHeadacheLogDayDetailsModel.headacheLogDayListData!
            .add(headacheWidgetData);
      }
    }

    response.behaviours!.asMap().forEach((index, element) {
      if (element.mobileEventDetails?.isNotEmpty ?? false) {
        if (index == 0) {
          RecordWidgetData logDaySleepWidgetData = RecordWidgetData();
          logDaySleepWidgetData.logDayListData = LogDayData();

          var behaviourPreSleepData = element.mobileEventDetails?.firstWhereOrNull((mobileEventElement) => mobileEventElement.questionTag == Constant.behaviourPreSleepTag);
          var behaviourSleepData = element.mobileEventDetails?.firstWhereOrNull((mobileEventElement) => mobileEventElement.questionTag == Constant.behaviourSleepTag);
          var behaviourMealData = element.mobileEventDetails?.firstWhereOrNull((mobileEventElement) => mobileEventElement.questionTag == Constant.behaviourPreMealTag);

          var behaviourExerciseData = element.mobileEventDetails?.firstWhereOrNull((mobileEventElement) => mobileEventElement.questionTag == Constant.behaviourPreExerciseTag);

          if (behaviourPreSleepData != null) {
            String titleInfo = behaviourPreSleepData.value!;
            if (titleInfo.toLowerCase() == "yes") {
              titleInfo = 'Had restful sleep';
            }
            if (behaviourSleepData != null) {
              List<String>? formattedValues = behaviourSleepData.value?.split("%@");
              if (formattedValues != null) {
                formattedValues.forEach((sleepElement) {
                  titleInfo = '$titleInfo, $sleepElement';
                });
              }
            }
            logDaySleepWidgetData.logDayListData!.titleInfo = titleInfo;
            logDaySleepWidgetData.logDayListData!.titleName = "Sleep";
            logDaySleepWidgetData.imagePath = Constant.sleepIcon;
          }
          userHeadacheLogDayDetailsModel.headacheLogDayListData!
              .add(logDaySleepWidgetData);

          RecordWidgetData logDayExerciseWidgetData = RecordWidgetData();
          logDayExerciseWidgetData.logDayListData = LogDayData();
          if (behaviourExerciseData != null) {
            String? titleBehaviorInfo = behaviourExerciseData.value;

            logDayExerciseWidgetData.imagePath = Constant.exerciseIcon;
            logDayExerciseWidgetData.logDayListData!.titleName = "Exercise";
            logDayExerciseWidgetData.logDayListData!.titleInfo =
                titleBehaviorInfo;
          }

          userHeadacheLogDayDetailsModel.headacheLogDayListData!
              .add(logDayExerciseWidgetData);

          RecordWidgetData logDayMealWidgetData = RecordWidgetData();
          logDayMealWidgetData.logDayListData = LogDayData();
          if (behaviourMealData != null) {
            String? titleMealInfo = behaviourMealData.value;
            if (titleMealInfo!.toLowerCase() == "yes") {
              titleMealInfo = 'Regular meal times';
            } else {
              titleMealInfo = 'No meal';
            }
            logDayMealWidgetData.imagePath = Constant.mealIcon;
            logDayMealWidgetData.logDayListData!.titleName = "Meal";
            logDayMealWidgetData.logDayListData!.titleInfo = titleMealInfo;
          }

          userHeadacheLogDayDetailsModel.headacheLogDayListData!
              .add(logDayMealWidgetData);

          userHeadacheLogDayDetailsModel.isDayLogged = true;
        }
      }
    });

    RecordWidgetData logDayMedicationWidgetData = RecordWidgetData();
    logDayMedicationWidgetData.logDayListData = LogDayData();
    logDayMedicationWidgetData.logDayListData!.titleName = Constant.medication;
    logDayMedicationWidgetData.logDayListData!.titleInfo = Constant.blankString;
    logDayMedicationWidgetData.imagePath = Constant.pillIcon;

    response.medication!.asMap().forEach((index, element) {
      if (element.mobileEventDetails?.isNotEmpty ?? false) {
        var medicationMobileEvent = element.mobileEventDetails?.firstWhereOrNull((mobileEventDetailElement) => mobileEventDetailElement.questionTag == Constant.logDayMedicationTag);
        if (element.mobileEventDetails!.length > 0 && medicationMobileEvent != null) {
          var medicationData = element.mobileEventDetails?.firstWhereOrNull((mobileEventElement) => mobileEventElement.questionTag == Constant.logDayMedicationTag);

          var formulationData = element.mobileEventDetails?.firstWhereOrNull((mobileEventElement) => mobileEventElement.questionTag!.contains('.formulation'));

          var medicationTimeData = element.mobileEventDetails?.firstWhereOrNull((mobileEventElement) => mobileEventElement.questionTag == Constant.administeredTag);

          var medicationDosageData = element.mobileEventDetails?.firstWhereOrNull((mobileEventElement) => mobileEventElement.questionTag!.contains(Constant.dotDosage));

          var numberOfDosageData = element.mobileEventDetails?.firstWhereOrNull((mobileEventElement) => mobileEventElement.questionTag == Constant.numberOfDosageTag);

          var medicationHistoryIdData = element.mobileEventDetails?.firstWhereOrNull((mobileEventElement) => mobileEventElement.questionTag == 'medication_history_id');

          if (medicationData != null) {

            if (formulationData != null) {
              medicationData.value = (medicationData.value == 'Onabotulinumtoxina (Botox)') ? 'BOTOX': medicationData.value ?? '';
              String titleInfo = medicationData.value ?? '';

              MedicationHistoryModel? medicationHistoryModel = _medicationHistoryDataModelList.firstWhereOrNull((element) => element.id == int.tryParse(medicationHistoryIdData?.value ?? ''));
              if (medicationDosageData?.value?.contains("units") == true) {
                titleInfo = '$titleInfo (started ${Utils.getDateText(medicationHistoryModel?.startDate ?? DateTime.now(), true)})\n';
                titleInfo = '$titleInfo${_unitMedicationsLastDate[medicationData.value ?? ''] == null ? 'You have not taken this before\n' : 'Last given on ${Utils.getDateText(_unitMedicationsLastDate[medicationData.value]!, true)} ${Utils.dateDifferenceTextGenerator(medicationData.value, _unitMedicationsLastDate)}\n'}';
                titleInfo = '$titleInfo${formulationData.value}, ${medicationDosageData?.value}';
              } else {
                titleInfo = '$titleInfo (${medicationHistoryModel?.endDate == null ? 'started ${Utils.getDateText(medicationHistoryModel?.startDate ?? DateTime.now(), true)}' : '${Utils.getDateText(medicationHistoryModel?.startDate ?? DateTime.now(), true)} - ${Utils.getDateText(medicationHistoryModel?.endDate ?? DateTime.now(), true)}'})\n';
                titleInfo = '$titleInfo${formulationData.value}, ${medicationDosageData?.value}\n';

                titleInfo = '$titleInfo\u2022 ${numberOfDosageData?.value?.replaceAll(regex, '')} ${formulationTextGenerator(numberOfDosageData?.value ?? '', formulationData.value ?? '')} (${medicationTimeData?.value})';
              }

              if (logDayMedicationWidgetData.logDayListData!.titleInfo!.isEmpty)
                logDayMedicationWidgetData.logDayListData!.titleInfo = titleInfo;
              else
                logDayMedicationWidgetData.logDayListData!.titleInfo =
                '${logDayMedicationWidgetData.logDayListData!.titleInfo}\n\n$titleInfo';
            } else {
              if (medicationDosageData != null && medicationTimeData != null) {
                List<String>? formattedValues = medicationDosageData.value?.split("%@");
                List<String>? medicationTimeValues = medicationTimeData.value?.split("%@");

                if (formattedValues != null && medicationTimeValues != null) {

                  formattedValues.asMap().forEach((index, medicationElement) {
                    String titleInfo = (medicationData.value == 'Onabotulinumtoxina (Botox)') ? 'BOTOX': medicationData.value ?? '';

                    titleInfo = '$titleInfo\n${_getMedicationDosageUnit(medicationElement)}\n\u2022 ${medicationTimeValues[index]}';

                    if (logDayMedicationWidgetData.logDayListData!.titleInfo!.isEmpty)
                      logDayMedicationWidgetData.logDayListData!.titleInfo = titleInfo;
                    else
                      logDayMedicationWidgetData.logDayListData!.titleInfo = '${logDayMedicationWidgetData.logDayListData!.titleInfo}\n\n$titleInfo';
                  });
                }
              }
            }
          }
        }
      }
    });

    if (response.medication != null) {
      if (response.medication!.isNotEmpty &&
          logDayMedicationWidgetData.logDayListData!.titleInfo!.isNotEmpty) {
        userHeadacheLogDayDetailsModel.headacheLogDayListData!.add(logDayMedicationWidgetData);
        userHeadacheLogDayDetailsModel.isDayLogged = true;
      }
    }

    response.triggers!.asMap().forEach((index, element) {
      if (element.mobileEventDetails?.isNotEmpty ?? false) {
        if (index == 0) {
          if (element.mobileEventDetails!.length > 0) {
            RecordWidgetData logDayTriggersWidgetData = RecordWidgetData();
            logDayTriggersWidgetData.logDayListData = LogDayData();
            var triggersElement = element.mobileEventDetails?.firstWhereOrNull(
                    (mobileEventElement) =>
                mobileEventElement.questionTag == Constant.triggersTag);
            if (triggersElement != null) {
              String triggersValues = triggersElement.value!;
              List<String> formattedValues = triggersValues.split("%@");
              String titleInfo = Constant.blankString;
              formattedValues.forEach((triggerName) {
                if (triggerName.toLowerCase() == 'foods') {
                  var mobileEventDetailTrigger = element.mobileEventDetails
                      ?.firstWhereOrNull(
                          (element) => element.questionTag == 'triggers1.food');

                  if (mobileEventDetailTrigger == null)
                    titleInfo = '$titleInfo$triggerName\n';
                  else {
                    if (mobileEventDetailTrigger.value!.trim().isEmpty)
                      titleInfo = '$titleInfo$triggerName\n';
                    else
                      titleInfo =
                      '$titleInfo$triggerName (${mobileEventDetailTrigger.value})\n';
                  }
                } else if (triggerName.toLowerCase() == 'change in schedule') {
                  var mobileEventDetailTrigger = element.mobileEventDetails
                      ?.firstWhereOrNull((element) =>
                  element.questionTag == 'triggers1.scheduleChange');

                  if (mobileEventDetailTrigger == null)
                    titleInfo = '$titleInfo$triggerName\n';
                  else
                    titleInfo =
                    '$titleInfo$triggerName (${mobileEventDetailTrigger.value})\n';
                } else if (triggerName.toLowerCase() == 'environmental changes') {
                  var mobileEventDetailTrigger = element.mobileEventDetails
                      ?.firstWhereOrNull((element) =>
                  element.questionTag == 'triggers1.environment');

                  if (mobileEventDetailTrigger == null)
                    titleInfo = '$titleInfo$triggerName\n';
                  else
                    titleInfo =
                    '$titleInfo$triggerName (${mobileEventDetailTrigger.value})\n';
                } else if (triggerName.toLowerCase() == 'travel') {
                  var mobileEventDetailTrigger = element.mobileEventDetails
                      ?.firstWhereOrNull(
                          (element) => element.questionTag == 'triggers1.travel');

                  if (mobileEventDetailTrigger != null) {
                    if (mobileEventDetailTrigger.value!.isNotEmpty) {
                      List<String> travelTriggerList =
                      mobileEventDetailTrigger.value!.split('%@');

                      if (travelTriggerList.length > 0) {
                        titleInfo =
                        '$titleInfo$triggerName ${travelTriggerList.toString().replaceAll('[', '(').replaceAll(']', ')')}\n';
                      }
                    } else {
                      titleInfo = '$titleInfo$triggerName\n';
                    }
                  } else {
                    titleInfo = '$titleInfo$triggerName\n';
                  }
                } else {
                  var mobileEventDetailTrigger = element.mobileEventDetails
                      ?.firstWhereOrNull((element) => element.questionTag!
                      .contains(triggerName.toLowerCase()));

                  if (triggerName.toLowerCase() == 'alcohol') {
                    if (mobileEventDetailTrigger == null)
                      titleInfo = '$titleInfo$triggerName (1 drink)\n';
                    else {
                      int noOfAlcoholDrinks =
                      int.tryParse(mobileEventDetailTrigger.value!)!;

                      if (noOfAlcoholDrinks == 1) {
                        titleInfo =
                        '$titleInfo$triggerName (${mobileEventDetailTrigger.value} drink)\n';
                      } else {
                        titleInfo =
                        '$titleInfo$triggerName (${mobileEventDetailTrigger.value} drinks)\n';
                      }
                    }
                  } else if (triggerName.toLowerCase() == 'caffeine') {
                    if (mobileEventDetailTrigger == null)
                      titleInfo = '$titleInfo$triggerName (1 cup)\n';
                    else {
                      int noOfCaffeineCups =
                      int.tryParse(mobileEventDetailTrigger.value!)!;

                      if (noOfCaffeineCups == 1) {
                        titleInfo =
                        '$titleInfo$triggerName (${mobileEventDetailTrigger.value} cup)\n';
                      } else {
                        titleInfo =
                        '$titleInfo$triggerName (${mobileEventDetailTrigger.value} cups)\n';
                      }
                    }
                  } else {
                    if (mobileEventDetailTrigger == null)
                      titleInfo = '$titleInfo$triggerName\n';
                    else
                      titleInfo =
                      '$titleInfo$triggerName (${mobileEventDetailTrigger.value})\n';
                  }
                }
              });

              titleInfo = titleInfo.replaceRange(
                  titleInfo.length - 1, titleInfo.length, Constant.blankString);
              logDayTriggersWidgetData.logDayListData!.titleInfo = titleInfo;
              logDayTriggersWidgetData.logDayListData!.titleName = 'Triggers';

              logDayTriggersWidgetData.imagePath = Constant.alcoholIcon;
              userHeadacheLogDayDetailsModel.headacheLogDayListData!
                  .add(logDayTriggersWidgetData);
              userHeadacheLogDayDetailsModel.isDayLogged = true;
            }
          }
        }
      }
    });

    response.logDayNote!.forEach((element) {
      var logDayNoteData = element.mobileEventDetails?.firstWhereOrNull(
          (mobileEventElement) =>
              mobileEventElement.questionTag == Constant.logDayNoteTag);
      if (logDayNoteData != null && logDayNoteData.value?.trim().isNotEmpty == true) {
        userHeadacheLogDayDetailsModel.logDayNote = logDayNoteData.value;
        userHeadacheLogDayDetailsModel.headacheLogDayListData?.add(headacheWidgetData);
      }
    });

    return userHeadacheLogDayDetailsModel;
  }

  void enterSomeDummyDataToStream() {
    networkDataSink.add(Constant.loading);
  }

  String _getDisplayTime(int totalTime) {
    int hours = totalTime ~/ 60;
    int minute = totalTime % 60;

    if (hours < 10) {
      if (minute < 10) {
        return '$hours hrs, $minute mins';
      } else {
        return '$hours hrs, $minute mins';
      }
    } else if (hours < 24) {
      if (minute < 10) {
        return '${hours}hrs ${minute}mins';
      } else {
        return '${hours}hrs ${minute}mins';
      }
    } else {
      int days = (hours == 24) ? 1 : hours ~/ 24;
      hours = hours % 24;
      if (minute < 10) {
        if (days == 1)
          return '$days day, $hours hrs and $minute mins';
        else
          return '$days days, $hours hrs and $minute mins';
      } else {
        if (days == 1)
          return '$days day, $hours hrs and $minute mins';
        else
          return '$days days, $hours hrs and $minute mins';
      }
    }
  }

  String _getMedicationDosageUnit(String medicationDosage) {
    if (!(medicationDosage.contains('tablet') ||
        medicationDosage.contains('mcg/hr') ||
        medicationDosage.contains('injection') ||
        medicationDosage.contains('mg') ||
        medicationDosage.contains('ml') ||
        medicationDosage.contains('unit') ||
        (medicationDosage.contains('capsule')))) {
      if (medicationDosage.isNotEmpty)
        return '$medicationDosage mg';
      else
        return Constant.blankString;
    } else
      return medicationDosage;
  }

  String formulationTextGenerator(String medicationValue, String formulationText){
    if(double.parse(medicationValue) > 1){
      return '${formulationText}s';
    }
    else{
      return formulationText;
    }
  }
}
