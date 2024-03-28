import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mobile/models/SignUpHeadacheAnswerListModel.dart';
import 'package:mobile/models/UserLogHeadacheDataCalendarModel.dart';
import 'package:mobile/view/ConsecutiveSelectedDateWidget.dart';
import 'package:mobile/view/DateWidget.dart';

import 'Utils.dart';

class CalendarUtil {
  int calenderType;
  UserLogHeadacheDataCalendarModel userLogHeadacheDataCalendarModel;
  List<String> userLogHeadacheDataList = [];
  List<SignUpHeadacheAnswerListModel> userMonthTriggersListData = [];
  final Future<dynamic> Function(String,dynamic) navigateToOtherScreenCallback;

  // calenderType
  // 0- Me Screen
  // 1- Triggers Screen
  // 2- Severity Screen
  CalendarUtil({required this.calenderType, required this.userLogHeadacheDataCalendarModel, required this.userMonthTriggersListData, required this.navigateToOtherScreenCallback}) ;



  ///method to draw the month calendar for the month and year passed as arguments.
  ///and it returns the list of widgets which contain the calendar items to draw over screen.
  List<Widget> drawMonthCalendar(
      {int yy = 2020, int mm = 1, int dd = 1, bool drawCurrentMonth = false}) {
    List<Widget> monthData = [];
    List<CurrentWeekConsData> currentWeekConsData = [];
    var _firstDateOfMonth = DateTime.utc(yy, mm, dd);
    var daysInMonth = Utils.daysInCurrentMonth(mm, yy);
    var weekDay =
        _firstDateOfMonth.weekday != 7 ? _firstDateOfMonth.weekday : 0;
    filterSelectedLogAndHeadacheDayList(daysInMonth, currentWeekConsData);

    if(currentWeekConsData.length < 100){
      int count = 100 - currentWeekConsData.length;
      for(int i = 0 ; i<count ; i++){
        currentWeekConsData.add(CurrentWeekConsData(widgetType: 2, eventIdList: []));
      }
    }

    for (int n = 0, i = 0; n < 37 && i < daysInMonth; n++) {
      List<SignUpHeadacheAnswerListModel> triggersListData = [];
      SelectedDayHeadacheIntensity selectedDayHeadacheIntensity = SelectedDayHeadacheIntensity();

      if (i == 15) {
        debugPrint(i.toString());
      }

      if(calenderType == 1){
        userLogHeadacheDataCalendarModel.addTriggersListData.firstWhereOrNull(
                (element) {
              if (int.parse(element.selectedDay!) - 1 == i) {
                triggersListData = element.userTriggersListData!;
                return true;
              }
              return false;
            });

        selectedDayHeadacheIntensity  = SelectedDayHeadacheIntensity();
        var addHeadacheIntensityList = userLogHeadacheDataCalendarModel.addHeadacheIntensityListData.where((element) => int.parse(element.selectedDay ?? '') - 1 == i).toList();

        if (addHeadacheIntensityList != null && addHeadacheIntensityList.isNotEmpty) {
          var migraineAddHeadacheIntensity = addHeadacheIntensityList.firstWhereOrNull((element) => element.isMigraine);

          if (migraineAddHeadacheIntensity != null) {
            selectedDayHeadacheIntensity.intensityValue = migraineAddHeadacheIntensity.intensityValue;
            selectedDayHeadacheIntensity.isMigraine = migraineAddHeadacheIntensity.isMigraine;
          } else {
            var headacheAddHeadacheIntensity = addHeadacheIntensityList.firstWhereOrNull((element) => !element.isMigraine);

            if (headacheAddHeadacheIntensity != null) {
              selectedDayHeadacheIntensity.intensityValue = headacheAddHeadacheIntensity.intensityValue;
              selectedDayHeadacheIntensity.isMigraine = headacheAddHeadacheIntensity.isMigraine;
            }
          }
        }
      }else if(calenderType == 2){
        selectedDayHeadacheIntensity  = SelectedDayHeadacheIntensity();
        var addHeadacheIntensityList = userLogHeadacheDataCalendarModel.addHeadacheIntensityListData.where((element) => int.parse(element.selectedDay ?? '') - 1 == i).toList();

        if (addHeadacheIntensityList != null && addHeadacheIntensityList.isNotEmpty) {
          var migraineAddHeadacheIntensity = addHeadacheIntensityList.firstWhereOrNull((element) => element.isMigraine);

          if (migraineAddHeadacheIntensity != null) {
            selectedDayHeadacheIntensity.intensityValue = migraineAddHeadacheIntensity.intensityValue;
            selectedDayHeadacheIntensity.isMigraine = migraineAddHeadacheIntensity.isMigraine;
          } else {
            var headacheAddHeadacheIntensity = addHeadacheIntensityList.firstWhereOrNull((element) => !element.isMigraine);

            if (headacheAddHeadacheIntensity != null) {
              selectedDayHeadacheIntensity.intensityValue = headacheAddHeadacheIntensity.intensityValue;
              selectedDayHeadacheIntensity.isMigraine = headacheAddHeadacheIntensity.isMigraine;
            }
          }
        }
      }


      if (n < weekDay || n > daysInMonth + weekDay) {
        monthData.add(Container());
      } else {
        if ((currentWeekConsData[i].widgetType == 0 || currentWeekConsData[i].widgetType == 1) &&
            (n + 1) % 7 != 0) {

          var j = i + 1;
          if (j < daysInMonth &&
              (currentWeekConsData[i].widgetType == 0) &&
              (currentWeekConsData[j].widgetType == 0) && _checkForConsecutiveHeadacheId(currentWeekConsData[i], currentWeekConsData[j])) {
            monthData.add(ConsecutiveSelectedDateWidget(
                weekDateData:_firstDateOfMonth,
                calendarType:calenderType,
                isMigraine: selectedDayHeadacheIntensity.isMigraine,
                calendarDateViewType:currentWeekConsData[i].widgetType!,
                triggersListData:triggersListData,userMonthTriggersListData:userMonthTriggersListData,selectedDayHeadacheIntensity: selectedDayHeadacheIntensity,navigateToOtherScreenCallback: navigateToOtherScreenCallback,));
          } else {
            monthData.add(DateWidget(weekDateData:_firstDateOfMonth,
                calendarType:calenderType,calendarDateViewType: currentWeekConsData[i].widgetType!,triggersListData: triggersListData,userMonthTriggersListData:userMonthTriggersListData,selectedDayHeadacheIntensity: selectedDayHeadacheIntensity,navigateToOtherScreenCallback: navigateToOtherScreenCallback,));
          }
          i++;
        } else {
          monthData.add(DateWidget(weekDateData:_firstDateOfMonth,
              calendarType:calenderType,calendarDateViewType: currentWeekConsData[i].widgetType!,triggersListData: triggersListData,userMonthTriggersListData:userMonthTriggersListData,selectedDayHeadacheIntensity: selectedDayHeadacheIntensity,navigateToOtherScreenCallback: navigateToOtherScreenCallback,));

          i++;
        }
         _firstDateOfMonth = DateTime(_firstDateOfMonth.year,
            _firstDateOfMonth.month, _firstDateOfMonth.day + 1);
      }
    }
    return monthData;
  }


// 0- Headache Data
  // 1- LogDay Data
  // 2- No Headache and No Log
  void filterSelectedLogAndHeadacheDayList(daysInMonth, List<CurrentWeekConsData> currentWeekConsDataList) {
      for (int i = 0; i < daysInMonth; i++) {
        var userCalendarData = userLogHeadacheDataCalendarModel
            .addHeadacheListData
            .firstWhereOrNull((element) {
          if (int.parse(element.selectedDay!) - 1 == i) {
            CurrentWeekConsData currentWeekConsData = CurrentWeekConsData();
            currentWeekConsData.widgetType = 0;
            currentWeekConsData.eventIdList = [];

            print(element.headacheListData);

            if(element.headacheListData != null) {
              element.headacheListData!.forEach((headacheElement) {
                currentWeekConsData.eventIdList!.add(headacheElement.id!);
              });
            }
            currentWeekConsDataList.add(currentWeekConsData);
            return true;
          }
          return false;
        });
        if (userCalendarData == null) {
          SelectedHeadacheLogDate? res = userLogHeadacheDataCalendarModel.addLogDayListData.firstWhereOrNull(
                  (element) {
                if (int.parse(element.selectedDay!) - 1 == i) {
                  CurrentWeekConsData currentWeekConsData = CurrentWeekConsData(widgetType: null, eventIdList: null);
                  currentWeekConsData.widgetType = 1;
                  currentWeekConsData.eventIdList = [];
                  currentWeekConsDataList.add(currentWeekConsData);
                  return true;
                }
                return false;
              });

          if(res == null){
            CurrentWeekConsData currentWeekConsData = CurrentWeekConsData(widgetType: null, eventIdList: null);
            currentWeekConsData.widgetType = 2;
            currentWeekConsData.eventIdList = [];
            currentWeekConsDataList.add(currentWeekConsData);
          }
        }
        // currentWeekConsData.add(a);
      }

    debugPrint(currentWeekConsDataList.toString());
  }

  bool _checkForConsecutiveHeadacheId(CurrentWeekConsData currentWeekConsData1, CurrentWeekConsData currentWeekConsData2) {
    bool isSatisfied = false;

    for (int i = 0; i < currentWeekConsData1.eventIdList!.length; i++) {
      int eventId = currentWeekConsData1.eventIdList![i];

      var eventIdElement = currentWeekConsData2.eventIdList?.firstWhereOrNull((element) => element == eventId);

      if(eventIdElement != null) {
        isSatisfied = true;
        break;
      }
    }

    return isSatisfied;
  }
}

class CurrentWeekConsData {
   int? widgetType;
   List<int>? eventIdList;

  CurrentWeekConsData({ this.widgetType, this.eventIdList});
}
