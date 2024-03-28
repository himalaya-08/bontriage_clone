import 'package:flutter/material.dart';
import 'package:mobile/models/SignUpHeadacheAnswerListModel.dart';
import 'package:mobile/models/UserLogHeadacheDataCalendarModel.dart';
import 'package:mobile/util/DrawHorizontalLine.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/DateWidget.dart';

class ConsecutiveSelectedDateWidget extends StatelessWidget {
  final DateTime weekDateData;
  final int calendarType;
  final int calendarDateViewType;
  final List<SignUpHeadacheAnswerListModel> triggersListData;
  final List<SignUpHeadacheAnswerListModel> userMonthTriggersListData;

  final SelectedDayHeadacheIntensity selectedDayHeadacheIntensity;
  final Future<dynamic> Function(String, dynamic) navigateToOtherScreenCallback;
  final bool isMigraine;

  ConsecutiveSelectedDateWidget(
      {required this.weekDateData,
      required this.calendarType,
      required this.calendarDateViewType,
      required this.triggersListData,
      required this.userMonthTriggersListData,
      required this.selectedDayHeadacheIntensity,
      required this.navigateToOtherScreenCallback,
      required this.isMigraine});

  @override
  Widget build(BuildContext context) {
    return DrawHorizontalLine(
        painter: HorizontalLinePainter(
            lineColor:
                isMigraine ? Constant.migraineColor : Constant.chatBubbleGreen),
        child: DateWidget(
          weekDateData: weekDateData,
          calendarType: calendarType,
          calendarDateViewType: calendarDateViewType,
          triggersListData: triggersListData,
          userMonthTriggersListData: userMonthTriggersListData,
          selectedDayHeadacheIntensity: selectedDayHeadacheIntensity,
          navigateToOtherScreenCallback: navigateToOtherScreenCallback,
        ));
  }
}
