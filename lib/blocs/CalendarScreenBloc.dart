import 'dart:async';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/models/CalendarInfoDataModel.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/OnGoingHeadacheDataModel.dart';
import 'package:mobile/models/SignUpHeadacheAnswerListModel.dart';
import 'package:mobile/models/UserLogHeadacheDataCalendarModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/CalendarRepository.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';

class CalendarScreenBloc {
  CalendarRepository? _calendarRepository;
  StreamController<dynamic> _calendarStreamController = StreamController();
  StreamController<dynamic> _triggersStreamController = StreamController();
  StreamController<dynamic> _networkStreamController = StreamController();
  UserLogHeadacheDataCalendarModel _userLogHeadacheDataCalendarModel = UserLogHeadacheDataCalendarModel();
  int count = 0;
  CurrentUserHeadacheModel currentUserHeadacheModel = CurrentUserHeadacheModel();

  StreamSink<dynamic> get calendarDataSink => _calendarStreamController.sink;

  Stream<dynamic> get calendarDataStream => _calendarStreamController.stream;

  StreamSink<dynamic> get triggersDataSink => _triggersStreamController.sink;

  Stream<dynamic> get triggersDataStream => _triggersStreamController.stream;

  Stream<dynamic> get networkDataStream => _networkStreamController.stream;

  StreamSink<dynamic> get networkDataSink => _networkStreamController.sink;

  List<SignUpHeadacheAnswerListModel> userMonthTriggersData = [];

  CalendarScreenBloc({this.count = 0}) {
    _calendarStreamController = StreamController<dynamic>.broadcast();
    _triggersStreamController = StreamController<dynamic>.broadcast();
    _networkStreamController  = StreamController<dynamic>.broadcast();
    _calendarRepository = CalendarRepository();
  }

  Future<CurrentUserHeadacheModel?> fetchUserOnGoingHeadache(BuildContext context) async {
    var appConfig = AppConfig.of(context);
    CurrentUserHeadacheModel? currentUserHeadacheModel;
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    if(userProfileInfoData != null) {
      try {
        String url = '${WebservicePost.getServerUrl(context)}common/ongoingheadache/${userProfileInfoData.userId}';
        print(url);
        var response = await _calendarRepository!.onGoingHeadacheServiceCall(url, RequestMethod.GET);
        if (response is AppException) {
          networkDataSink.addError(response);
        } else {
          print(response);
          if(response != null && response is OnGoingHeadacheDataModel) {
            if(response.isExists!) {
              currentUserHeadacheModel = CurrentUserHeadacheModel();
              var headacheStartTimeMobileEventDetail = response.headaches![0].mobileEventDetails?.firstWhereOrNull((element) => element.questionTag == Constant.onSetTag);
              currentUserHeadacheModel.selectedDate = (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) ? headacheStartTimeMobileEventDetail!.value : DateTime.tryParse(headacheStartTimeMobileEventDetail!.value!)!.toLocal().toIso8601String();
              currentUserHeadacheModel.userId = userProfileInfoData.userId;
              currentUserHeadacheModel.headacheId = response.headaches![0].id;
              currentUserHeadacheModel.isOnGoing = true;
              currentUserHeadacheModel.isFromRecordScreen = false;
              currentUserHeadacheModel.isFromServer = true;
              if (appConfig?.buildFlavor == Constant.tonixBuildFlavor)
                currentUserHeadacheModel.mobileEventDetails = response.headaches![0].mobileEventDetails;
              await SignUpOnBoardProviders.db.insertUserCurrentHeadacheData(currentUserHeadacheModel);
            }
          } else {
            networkDataSink.addError(Exception(Constant.somethingWentWrong));
            debugPrint('67');
          }
        }
      } catch(e) {
        networkDataSink.addError(Exception(Constant.somethingWentWrong));
        print(e);
      }
    }
    return currentUserHeadacheModel;
  }

  fetchCalendarTriggersData(String startDateValue, String endDateValue, BuildContext context) async {
    String? apiResponse;
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    var appConfig = AppConfig.of(context);
    try {

      DateTime? endDateTime;
      DateTime? startDateTime;

      if(appConfig?.buildFlavor == Constant.tonixBuildFlavor) {
        endDateTime = DateTime.tryParse(endDateValue)!;

        debugPrint(endDateTime.toIso8601String());

        endDateTime = DateTime(
            endDateTime.year,
            endDateTime.month,
            endDateTime.day,
            0,
            0,
            0,
            0,
            0);

        startDateTime = DateTime.tryParse(
            startDateValue)!;

        startDateTime = DateTime(
            startDateTime.year,
            startDateTime.month,
            startDateTime.day,
            0,
            0,
            0,
            0,
            0);
      }

      String url;

      if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
        url = '${WebservicePost.getServerUrl(context)}calender?end_calendar_entry_date=$endDateValue&start_calendar_entry_date=$startDateValue&user_id=${userProfileInfoData.userId}';
      else
        url = '${WebservicePost.getServerUrl(context)}calender/utc?end_calendar_entry_date=${Utils.getDateTimeInUtcFormat(endDateTime ?? DateTime.now(), true, context)}&start_calendar_entry_date=${Utils.getDateTimeInUtcFormat(startDateTime ?? DateTime.now(), true, context)}&user_id=${userProfileInfoData.userId}&utc=true&time_zone=${Utils.getDateTimeOffset(DateTime.now().timeZoneOffset.toString())}';

      var response = await _calendarRepository!.calendarTriggersServiceCall(
          url, RequestMethod.GET);
      if (response is AppException) {
        apiResponse = response.toString();
        networkDataSink.addError(response);
      } else {
        if (response != null && response is CalendarInfoDataModel) {
          debugPrint(response.toString());
          userMonthTriggersData.clear();
          UserLogHeadacheDataCalendarModel userLogHeadacheDataCalendarModel =  setAllCalendarDataInToModel(response, userProfileInfoData.userId!, appConfig!);

          if (appConfig.buildFlavor == Constant.tonixBuildFlavor)
            await _updateCalendarModelForOnGoingHeadache(userLogHeadacheDataCalendarModel);

          var menstruatingTriggerData = userMonthTriggersData.firstWhereOrNull((element) => element.answerData == Constant.menstruatingTriggerOption);
          if (menstruatingTriggerData != null) {
            userMonthTriggersData.remove(menstruatingTriggerData);
            userMonthTriggersData.insert(0, menstruatingTriggerData);
          }
          triggersDataSink.add(userMonthTriggersData);
          calendarDataSink.add(userLogHeadacheDataCalendarModel);
          networkDataSink.add(Constant.success);
        }
      }
    } catch (e) {
      apiResponse = Constant.somethingWentWrong;
      networkDataSink.addError(Exception(Constant.somethingWentWrong));
      print(e);
    }
    return apiResponse;
  }

  Future<void> _updateCalendarModelForOnGoingHeadache(UserLogHeadacheDataCalendarModel userLogHeadacheDataCalendarModel) async {
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    CurrentUserHeadacheModel? currentUserHeadacheModel = await SignUpOnBoardProviders.db.getUserCurrentHeadacheData(userProfileInfoData.userId!);

    if (currentUserHeadacheModel != null) {
      if (currentUserHeadacheModel.isFromServer!) {
        var headacheDateTime = DateTime.tryParse(currentUserHeadacheModel.selectedDate!)!.toLocal();

        SelectedHeadacheLogDate? selectedHeadacheLogDate = userLogHeadacheDataCalendarModel.addHeadacheListData.firstWhereOrNull((element) => element.selectedDay == headacheDateTime.day.toString());

        if (selectedHeadacheLogDate == null) {
          SelectedHeadacheLogDate onGoingHeadacheLogDate = SelectedHeadacheLogDate();
          onGoingHeadacheLogDate.selectedDay = headacheDateTime.day.toString();
          onGoingHeadacheLogDate.formattedDate = headacheDateTime.toIso8601String();
          onGoingHeadacheLogDate.headacheListData = [];
          onGoingHeadacheLogDate.userTriggersListData = [];

          userLogHeadacheDataCalendarModel.addHeadacheListData.add(onGoingHeadacheLogDate);
        }
      }
    }
  }

  void enterSomeDummyDataToStreamController() {
    networkDataSink.add(Constant.loading);
  }
  void initNetworkStreamController() {
    _networkStreamController.close();
    _networkStreamController = StreamController<dynamic>();
  }

  void dispose() {
    _calendarStreamController.close();
    _triggersStreamController.close();
    _networkStreamController.close();
  }

  UserLogHeadacheDataCalendarModel setAllCalendarDataInToModel(
      CalendarInfoDataModel response, String userId, AppConfig appConfig) {


    if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor) {
      _userLogHeadacheDataCalendarModel = UserLogHeadacheDataCalendarModel();
    } else {
      if(_userLogHeadacheDataCalendarModel == null) {
        _userLogHeadacheDataCalendarModel = UserLogHeadacheDataCalendarModel();
      }
    }

    ///Will reconsider for tonix
    //if(_userLogHeadacheDataCalendarModel == null) {
      //_userLogHeadacheDataCalendarModel = UserLogHeadacheDataCalendarModel();
    //}
    setCalendarHeadacheData(
        response.headache!, _userLogHeadacheDataCalendarModel);
    setCalendarLogTriggersData(
        response.triggers ?? [], _userLogHeadacheDataCalendarModel, appConfig);

    if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
      setCalendarLogBehaviorData(response.behaviours ?? [], _userLogHeadacheDataCalendarModel);

    if (appConfig.buildFlavor == Constant.tonixBuildFlavor)
      setCalendarStudyMedicationData(response.studyMedicationList!, _userLogHeadacheDataCalendarModel);
    _userLogHeadacheDataCalendarModel.userId = userId;
    return _userLogHeadacheDataCalendarModel;
  }

  void setCalendarStudyMedicationData(List<Headache> headache, UserLogHeadacheDataCalendarModel userLogHeadacheDataCalendarModel) {
    headache.forEach((element) {
      DateTime dateTime = DateTime.tryParse(element.calendarEntryAt!)!.toLocal();

      var userSelectedHeadacheDayData =  userLogHeadacheDataCalendarModel.studyMedicationList.firstWhereOrNull((intensityElementData) => intensityElementData.selectedDay == dateTime.day.toString());

      if(userSelectedHeadacheDayData == null) {
        SelectedHeadacheLogDate _selectedHeadacheLogDate =  SelectedHeadacheLogDate();
        _selectedHeadacheLogDate.formattedDate = dateTime.toIso8601String();
        _selectedHeadacheLogDate.headacheListData = [element];
        _selectedHeadacheLogDate.selectedDay = dateTime.day.toString();
        userLogHeadacheDataCalendarModel.studyMedicationList.add(_selectedHeadacheLogDate);
      } else {
        userSelectedHeadacheDayData.headacheListData!.add(element);
      }
    });
  }

  void setCalendarHeadacheData(List<Headache> headache,
      UserLogHeadacheDataCalendarModel userLogHeadacheDataCalendarModel) {
    debugPrint(headache.toString());
    headache.forEach((element) {

      DateTime _dateTime = DateTime.parse(element.calendarEntryAt!);

      var userSelectedHeadacheDayData =  userLogHeadacheDataCalendarModel.addHeadacheListData.firstWhereOrNull((intensityElementData) => intensityElementData.selectedDay == _dateTime.day.toString());

      if(userSelectedHeadacheDayData == null) {
        SelectedHeadacheLogDate _selectedHeadacheLogDate =  SelectedHeadacheLogDate();
        _selectedHeadacheLogDate.formattedDate = element.calendarEntryAt;
        _selectedHeadacheLogDate.headacheListData = [element];
        _selectedHeadacheLogDate.selectedDay = _dateTime.day.toString();
        userLogHeadacheDataCalendarModel.addHeadacheListData.add(_selectedHeadacheLogDate);
      } else {
        userSelectedHeadacheDayData.headacheListData!.add(element);
      }

      var onSetMobileEventDetails = element.mobileEventDetails?.firstWhereOrNull((mobileEventDetailElement) => mobileEventDetailElement.questionTag == Constant.onSetTag);

      var userSelectedHeadacheDayIntensityData =  userLogHeadacheDataCalendarModel.addHeadacheIntensityListData.firstWhereOrNull((intensityElementData) => intensityElementData.selectedDay == _dateTime.day.toString());
      if(userSelectedHeadacheDayIntensityData != null){
        var indexOfData = userLogHeadacheDataCalendarModel.addHeadacheIntensityListData.indexOf(userSelectedHeadacheDayIntensityData);
        SelectedDayHeadacheIntensity selectedDayHeadacheIntensity = SelectedDayHeadacheIntensity();
        selectedDayHeadacheIntensity.selectedDay = _dateTime.day.toString();
        selectedDayHeadacheIntensity.isMigraine = element.isMigraine!;
        selectedDayHeadacheIntensity.headacheStartDate = onSetMobileEventDetails!.value;
        var severityValue = element.mobileEventDetails?.firstWhereOrNull(
                (element) => element.questionTag == Constant.severityTag);
        if (severityValue != null) {
          if(int.tryParse(userSelectedHeadacheDayIntensityData.intensityValue!) !< int.tryParse(severityValue.value!)!){
            userSelectedHeadacheDayIntensityData.intensityValue = severityValue.value;
          }
        }

        if (selectedDayHeadacheIntensity.isMigraine) {
          selectedDayHeadacheIntensity.intensityValue = userSelectedHeadacheDayIntensityData.intensityValue;
          userSelectedHeadacheDayIntensityData = selectedDayHeadacheIntensity;
          userLogHeadacheDataCalendarModel.addHeadacheIntensityListData[indexOfData] = userSelectedHeadacheDayIntensityData;
          debugPrint(userSelectedHeadacheDayIntensityData.toString());
        }

        if (selectedDayHeadacheIntensity.isMigraine) {
          selectedDayHeadacheIntensity.intensityValue = userSelectedHeadacheDayIntensityData.intensityValue;
          userSelectedHeadacheDayIntensityData = selectedDayHeadacheIntensity;
          userLogHeadacheDataCalendarModel.addHeadacheIntensityListData[indexOfData] = userSelectedHeadacheDayIntensityData;
          debugPrint(userSelectedHeadacheDayIntensityData.toString());
        }
      } else {
        SelectedDayHeadacheIntensity _selectedDayHeadacheIntensity = SelectedDayHeadacheIntensity();
        _selectedDayHeadacheIntensity.selectedDay = _dateTime.day.toString();
        _selectedDayHeadacheIntensity.isMigraine = element.isMigraine!;
        _selectedDayHeadacheIntensity.headacheStartDate = onSetMobileEventDetails!.value;
        var severityValue = element.mobileEventDetails?.firstWhereOrNull(
                (element) => element.questionTag == Constant.severityTag);
        if (severityValue != null) {
          _selectedDayHeadacheIntensity.intensityValue = severityValue.value;
        } else {
          _selectedDayHeadacheIntensity.intensityValue = "0";
        }
        userLogHeadacheDataCalendarModel.addHeadacheIntensityListData.add(_selectedDayHeadacheIntensity);
      }
    });
    debugPrint(userLogHeadacheDataCalendarModel.toString());
  }

  void setCalendarLogTriggersData(List<Headache> triggers,
      UserLogHeadacheDataCalendarModel userLogHeadacheDataCalendarModel, AppConfig appConfig) {
    if(triggers.length == 0){
      userMonthTriggersData = [];

      if (appConfig.buildFlavor == Constant.tonixBuildFlavor)
        triggersDataSink.add(userMonthTriggersData);
    } else {
      triggers.forEach((element) {
        SelectedHeadacheLogDate selectedHeadacheLogDate =  SelectedHeadacheLogDate();
        selectedHeadacheLogDate.formattedDate = element.calendarEntryAt;
        DateTime _dateTime = DateTime.parse(element.calendarEntryAt!);
        var userSelectedHeadacheDayTriggersData =  userLogHeadacheDataCalendarModel.addTriggersListData.firstWhereOrNull((triggersElementData) => triggersElementData.selectedDay == _dateTime.day.toString());
           if(userSelectedHeadacheDayTriggersData != null){
             selectedHeadacheLogDate.selectedDay = _dateTime.day.toString();
             if (element.mobileEventDetails!.length == 0) {
               userLogHeadacheDataCalendarModel.addLogDayListData.add(selectedHeadacheLogDate);
             }else {
               var triggersElement = element.mobileEventDetails?.firstWhereOrNull((
                   element) => element.questionTag == "triggers1");
               if(triggersElement != null) {
                 String triggersValues = triggersElement.value!;
                 List<String> formattedValues = triggersValues.split("%@");
                 var menstruatingTriggerOption = formattedValues.firstWhereOrNull((e) => e == Constant.menstruatingTriggerOption);
                 if (menstruatingTriggerOption != null) {
                   formattedValues.removeWhere((e) => e == Constant.menstruatingTriggerOption);
                   formattedValues.insert(0, Constant.menstruatingTriggerOption);
                 }
                 formattedValues.asMap().forEach((index, element) {
                   SignUpHeadacheAnswerListModel signUpHeadacheAnswerListModel = SignUpHeadacheAnswerListModel();
                   signUpHeadacheAnswerListModel.answerData = element;
                   userSelectedHeadacheDayTriggersData.userTriggersListData!.add(signUpHeadacheAnswerListModel);
                 });
                 setAllMonthTriggersData(formattedValues);
               }
               userLogHeadacheDataCalendarModel.addLogDayListData.add(selectedHeadacheLogDate);
               //  userSelectedHeadacheDayTriggersData.userTriggersListData.addAll(selectedHeadacheLogDate);
             }
        } else {
          selectedHeadacheLogDate.selectedDay = _dateTime.day.toString();
          if (element.mobileEventDetails!.length == 0) {
            userLogHeadacheDataCalendarModel.addLogDayListData.add(selectedHeadacheLogDate);
          } else {
            var triggersElement = element.mobileEventDetails?.firstWhereOrNull((element) => element.questionTag == "triggers1");
            if (triggersElement != null) {
              String triggersValues = triggersElement.value!;
              List<String> formattedValues = triggersValues.split("%@");
              var menstruatingTriggerOption = formattedValues.firstWhereOrNull((e) => e == Constant.menstruatingTriggerOption);
              if (menstruatingTriggerOption != null) {
                formattedValues.removeWhere((e) => e == Constant.menstruatingTriggerOption);
                formattedValues.insert(0, Constant.menstruatingTriggerOption);
              }
              formattedValues.asMap().forEach((index, element) {
                SignUpHeadacheAnswerListModel signUpHeadacheAnswerListModel = SignUpHeadacheAnswerListModel();
                signUpHeadacheAnswerListModel.answerData = element;

                setInitialTriggers((menstruatingTriggerOption == null ? index + 1 : index), signUpHeadacheAnswerListModel);
                selectedHeadacheLogDate.userTriggersListData!.add(signUpHeadacheAnswerListModel);
              });
              setAllMonthTriggersData(formattedValues);
            }
            userLogHeadacheDataCalendarModel.addTriggersListData.add(selectedHeadacheLogDate);
            userLogHeadacheDataCalendarModel.addLogDayListData.add(selectedHeadacheLogDate);
          }
        }
      });
    }
  }

  void setCalendarLogBehaviorData(List<Headache> behaviors,
      UserLogHeadacheDataCalendarModel userLogHeadacheDataCalendarModel) {
    if (behaviors.length == 0) {
      userMonthTriggersData = [];
      var menstruatingTriggerData = userMonthTriggersData.firstWhereOrNull((element) => element.answerData == Constant.menstruatingTriggerOption);
      if (menstruatingTriggerData != null) {
        userMonthTriggersData.remove(menstruatingTriggerData);
        userMonthTriggersData.insert(0, menstruatingTriggerData);
      }
      triggersDataSink.add(userMonthTriggersData);
    } else {
      List<String> questionTagList = [Constant.behaviourPreExerciseTag, Constant.behaviourPreSleepTag, Constant.behaviourPreMealTag];
      questionTagList.forEach((questionTagValue) {
        behaviors.forEach((element) {
          SelectedHeadacheLogDate selectedHeadacheLogDate = SelectedHeadacheLogDate();
          selectedHeadacheLogDate.formattedDate = element.calendarEntryAt;
          DateTime dateTime = DateTime.parse(element.calendarEntryAt!);
          var userSelectedHeadacheDayTriggersData =  userLogHeadacheDataCalendarModel.addTriggersListData.firstWhereOrNull((triggersElementData) => triggersElementData.selectedDay == dateTime.day.toString());
          if (userSelectedHeadacheDayTriggersData != null) {
            selectedHeadacheLogDate.selectedDay = dateTime.day.toString();
            if (element.mobileEventDetails!.length == 0) {
              var logDayData = userLogHeadacheDataCalendarModel.addLogDayListData.firstWhereOrNull((logDayElement) => (logDayElement.selectedDay == dateTime.day.toString()));
              if (logDayData == null)
                userLogHeadacheDataCalendarModel.addLogDayListData.add(selectedHeadacheLogDate);
            } else {
              var exerciseElement = element.mobileEventDetails?.firstWhereOrNull((element) => element.questionTag == questionTagValue);
              if (exerciseElement != null) {
                String exerciseValue = exerciseElement.value!;

                if (exerciseValue == Constant.no) {
                  SignUpHeadacheAnswerListModel signUpHeadacheAnswerListModel = SignUpHeadacheAnswerListModel();
                  signUpHeadacheAnswerListModel.answerData = (questionTagValue == Constant.behaviourPreExerciseTag) ? Constant.noExercise : (questionTagValue == Constant.behaviourPreSleepTag ? Constant.noRestorativeSleep : Constant.irregularMeals);
                  userSelectedHeadacheDayTriggersData.userTriggersListData!.add(signUpHeadacheAnswerListModel);
                  setAllMonthTriggersData([(questionTagValue == Constant.behaviourPreExerciseTag) ? Constant.noExercise : (questionTagValue == Constant.behaviourPreSleepTag ? Constant.noRestorativeSleep : Constant.irregularMeals)]);
                }
              }
              var logDayData = userLogHeadacheDataCalendarModel.addLogDayListData.firstWhereOrNull((logDayElement) => (logDayElement.selectedDay == dateTime.day.toString()));
              if (logDayData == null)
                userLogHeadacheDataCalendarModel.addLogDayListData.add(selectedHeadacheLogDate);
            }
          } else {
            selectedHeadacheLogDate.selectedDay = dateTime.day.toString();

            if (element.mobileEventDetails!.length == 0) {
              var logDayData = userLogHeadacheDataCalendarModel.addLogDayListData.firstWhereOrNull((logDayElement) => (logDayElement.selectedDay == dateTime.day.toString()));
              if (logDayData == null)
                userLogHeadacheDataCalendarModel.addLogDayListData.add(selectedHeadacheLogDate);
            } else {
              var exerciseElement = element.mobileEventDetails?.firstWhereOrNull((element) => element.questionTag == questionTagValue);

              if (exerciseElement != null) {
                String exerciseValue = exerciseElement.value!;

                if (exerciseValue == Constant.no) {
                  SignUpHeadacheAnswerListModel signUpHeadacheAnswerListModel = SignUpHeadacheAnswerListModel();
                  signUpHeadacheAnswerListModel.answerData = (questionTagValue == Constant.behaviourPreExerciseTag) ? Constant.noExercise : (questionTagValue == Constant.behaviourPreSleepTag ? Constant.noRestorativeSleep : Constant.irregularMeals);
                  selectedHeadacheLogDate.userTriggersListData!.add(signUpHeadacheAnswerListModel);
                  var menstruatingTriggerElement = selectedHeadacheLogDate.userTriggersListData?.firstWhereOrNull((e) => e.answerData == Constant.menstruatingTriggerOption);
                  int index = menstruatingTriggerElement == null ? selectedHeadacheLogDate.userTriggersListData!.length - 1 : selectedHeadacheLogDate.userTriggersListData!.length;
                  setInitialTriggers(index, signUpHeadacheAnswerListModel);
                  setAllMonthTriggersData([(questionTagValue == Constant.behaviourPreExerciseTag) ? Constant.noExercise : (questionTagValue == Constant.behaviourPreSleepTag ? Constant.noRestorativeSleep : Constant.irregularMeals)]);
                }
                userLogHeadacheDataCalendarModel.addTriggersListData.add(selectedHeadacheLogDate);
                var logDayData = userLogHeadacheDataCalendarModel.addLogDayListData.firstWhereOrNull((logDayElement) => (logDayElement.selectedDay == dateTime.day.toString()));
                if (logDayData == null)
                  userLogHeadacheDataCalendarModel.addLogDayListData.add(selectedHeadacheLogDate);
              }
            }
          }
        });
      });
    }
  }

  void setAllMonthTriggersData(List<String> formattedValues) {
    formattedValues.forEach((element) {
      if (element != 'None') {
        SignUpHeadacheAnswerListModel signUpHeadacheAnswerListModel =
        SignUpHeadacheAnswerListModel();
        var filteredTriggersData = userMonthTriggersData.firstWhereOrNull(
                (triggersElement) => element == triggersElement.answerData);
        if (filteredTriggersData == null) {
          signUpHeadacheAnswerListModel.answerData = element;
          if (userMonthTriggersData.length <= 3) {

            List<SignUpHeadacheAnswerListModel> list = [];
            list.addAll(userMonthTriggersData);

            list.removeWhere((el) => el.answerData == Constant.menstruatingTriggerOption);
            setInitialTriggers(signUpHeadacheAnswerListModel.answerData == Constant.menstruatingTriggerOption ? 0 : list.length + 1, signUpHeadacheAnswerListModel);
          }
          userMonthTriggersData.add(signUpHeadacheAnswerListModel);
        }
      }
    });


    debugPrint("$userMonthTriggersData");
  }

  void setInitialTriggers(
      int index, SignUpHeadacheAnswerListModel signUpHeadacheAnswerListModel) {
      switch (index) {
        case 0:
          signUpHeadacheAnswerListModel.color =
              Constant.menstruatingTriggerColor;
          signUpHeadacheAnswerListModel.isSelected = signUpHeadacheAnswerListModel.answerData == Constant.menstruatingTriggerOption;
          break;
        case 1:
          signUpHeadacheAnswerListModel.color = Constant.triggerOneColor;
          signUpHeadacheAnswerListModel.isSelected = true;
          break;
        case 2:
          signUpHeadacheAnswerListModel.color = Constant.triggerTwoColor;
          signUpHeadacheAnswerListModel.isSelected = true;
          break;
        /*case 3:
          signUpHeadacheAnswerListModel.color =
              Constant.triggerThreeColor;
          signUpHeadacheAnswerListModel.isSelected = false;
          break;
        case 4:
          signUpHeadacheAnswerListModel.color =
              Constant.triggerFourColor;
          signUpHeadacheAnswerListModel.isSelected = false;
          break;
        case 5:
          signUpHeadacheAnswerListModel.color =
              Constant.triggerFiveColor;
          signUpHeadacheAnswerListModel.isSelected = false;
          break;
        case 6:
          signUpHeadacheAnswerListModel.color =
              Constant.triggerSixColor;
          signUpHeadacheAnswerListModel.isSelected = false;
          break;
        case 7:
          signUpHeadacheAnswerListModel.color =
              Constant.triggerSevenColor;
          signUpHeadacheAnswerListModel.isSelected = false;
          break;
        case 8:
          signUpHeadacheAnswerListModel.color =
              Constant.triggerEightColor;
          signUpHeadacheAnswerListModel.isSelected = false;
          break;*/
      }
  }
}
