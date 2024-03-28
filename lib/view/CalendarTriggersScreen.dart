import 'dart:async';
import 'package:collection/collection.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/blocs/CalendarScreenBloc.dart';
import 'package:mobile/models/SelectedTriggersColorsModel.dart';
import 'package:mobile/models/SignUpHeadacheAnswerListModel.dart';
import 'package:mobile/models/UserLogHeadacheDataCalendarModel.dart';
import 'package:mobile/util/CalendarUtil.dart';
import 'package:mobile/util/MonthYearCupertinoDatePicker.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CustomTextWidget.dart';
import 'MigraineDaysVsHeadacheDaysDialog.dart';
import 'NetworkErrorScreen.dart';

class CalendarTriggersScreen extends StatefulWidget {
  final Function(Stream, Function)? showApiLoaderCallback;
  final Future<dynamic> Function(String, dynamic)? navigateToOtherScreenCallback;
  final StreamSink<dynamic>? refreshCalendarDataSink;
  final Stream<dynamic>? refreshCalendarDataStream;
  final Future<DateTime> Function(MonthYearCupertinoDatePickerMode, Function, DateTime)?
      openDatePickerCallback;

  const CalendarTriggersScreen(
      {Key? key,
      this.showApiLoaderCallback,
      this.navigateToOtherScreenCallback,
      this.refreshCalendarDataSink,
      this.refreshCalendarDataStream,
      this.openDatePickerCallback})
      : super(key: key);

  @override
  _CalendarTriggersScreenState createState() => _CalendarTriggersScreenState();
}

class _CalendarTriggersScreenState extends State<CalendarTriggersScreen>
    with AutomaticKeepAliveClientMixin {
  List<Widget> currentMonthData = [];
  Color? lastDeselectedColor;
  CalendarScreenBloc _calendarScreenBloc = CalendarScreenBloc();
  DateTime _dateTime = DateTime.now();
  int? currentMonth;
  int? currentYear;
  String? monthName;
  int? totalDaysInCurrentMonth;
  String? firstDayOfTheCurrentMonth;
  String? lastDayOfTheCurrentMonth;

  List<SignUpHeadacheAnswerListModel> userMonthTriggersListModel = [];

  List<SelectedTriggersColorsModel> triggersColorsListData = [];

  int totalHeadacheDays = 0;
  int totalMigraineDays = 0;
  int totalHeadacheFreeDays = 0;
  int totalTriggersCanBeSelected = 0;

  @override
  void initState() {
    super.initState();
    _calendarScreenBloc = CalendarScreenBloc();
    _dateTime = DateTime.now();
    currentMonth = _dateTime.month;
    currentYear = _dateTime.year;
    monthName = Utils.getMonthName(currentMonth!);
    totalDaysInCurrentMonth =
        Utils.daysInCurrentMonth(currentMonth!, currentYear!);
    firstDayOfTheCurrentMonth = Utils.firstDateWithCurrentMonthAndTimeInUTC(
        currentMonth!, currentYear!, 1);
    lastDayOfTheCurrentMonth = Utils.lastDateWithCurrentMonthAndTimeInUTC(
        currentMonth!, currentYear!, totalDaysInCurrentMonth!);
    _removeDataFromSharedPreference();
    callAPIService();
    _initTriggerColorListData();

    widget.refreshCalendarDataStream!.listen((event) {
      if (event is bool && event) {
        _removeDataFromSharedPreference();
        _calendarScreenBloc.initNetworkStreamController();
        currentMonth = _dateTime.month;
        currentYear = _dateTime.year;
        monthName = Utils.getMonthName(currentMonth!);
        totalDaysInCurrentMonth =
            Utils.daysInCurrentMonth(currentMonth!, currentYear!);
        firstDayOfTheCurrentMonth = Utils.firstDateWithCurrentMonthAndTimeInUTC(
            currentMonth!, currentYear!, 1);
        lastDayOfTheCurrentMonth = Utils.lastDateWithCurrentMonthAndTimeInUTC(
            currentMonth!, currentYear!, totalDaysInCurrentMonth!);

        // _calendarScreenBloc.initNetworkStreamController();

        print('show api loader 2');
        widget.showApiLoaderCallback!(_calendarScreenBloc.networkDataStream, () {
          _calendarScreenBloc.enterSomeDummyDataToStreamController();
          requestService(firstDayOfTheCurrentMonth!, lastDayOfTheCurrentMonth);
        });

        requestService(firstDayOfTheCurrentMonth!, lastDayOfTheCurrentMonth);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CalendarTriggersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('In did update widget of calendar trigger screen');
    getCurrentPositionOfTabBar();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build of calendar trigger');
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.only(left: 15, right: 15),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Constant.locationServiceGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                StreamBuilder<dynamic>(
                    stream: _calendarScreenBloc.calendarDataStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        setCurrentMonthData(
                            snapshot.data, currentMonth!, currentYear!);
                        _countTotalDays(snapshot.data);
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    DateTime dateTime = DateTime(
                                        _dateTime.year, _dateTime.month - 1);
                                    _dateTime = dateTime;
                                    _onStartDateSelected(dateTime);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Image(
                                      image: AssetImage(Constant.backArrow),
                                      width: 17,
                                      height: 17,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    _openDatePickerBottomSheet(
                                        CupertinoDatePickerMode.date);
                                    //widget.openDatePickerCallback(CupertinoDatePickerMode.date, _getDateTimeCallbackFunction(0), _dateTime);
                                  },
                                  child: CustomTextWidget(
                                    text: monthName! +
                                        " " +
                                        currentYear.toString(),
                                    style: TextStyle(
                                        color: Constant.chatBubbleGreen,
                                        fontSize: 15,
                                        fontFamily: Constant.jostRegular),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    DateTime dateTime = DateTime(
                                        _dateTime.year, _dateTime.month + 1);
                                    Duration duration = dateTime.difference(
                                        DateTime.tryParse(
                                            Utils.getDateTimeInUtcFormat(
                                                DateTime.now(),
                                                true,
                                                context))!);
                                    if (duration.inSeconds < 0) {
                                      _dateTime = dateTime;
                                      _onStartDateSelected(dateTime);
                                    } else {
                                      debugPrint("Not Allowed");
                                      //Utils.showValidationErrorDialog(context, Constant.beyondDateErrorMessage, 'Alert!');
                                      Utils.showSnackBar(context,
                                          Constant.beyondDateErrorMessage);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Image(
                                      image: AssetImage(Constant.nextArrow),
                                      width: 17,
                                      height: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Table(
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(children: [
                                  Center(
                                    child: CustomTextWidget(
                                      text: 'Su',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                  Center(
                                    child: CustomTextWidget(
                                      text: 'M',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                  Center(
                                    child: CustomTextWidget(
                                      text: 'Tu',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                  Center(
                                    child: CustomTextWidget(
                                      text: 'W',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                  Center(
                                    child: CustomTextWidget(
                                      text: 'Th',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                  Center(
                                    child: CustomTextWidget(
                                      text: 'F',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                  Center(
                                    child: CustomTextWidget(
                                      text: 'Sa',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                            Container(
                              height: 290,
                              child: GridView.count(
                                  crossAxisCount: 7,
                                  padding: EdgeInsets.all(4.0),
                                  childAspectRatio: 8.0 / 9.0,
                                  children: currentMonthData.map((e) {
                                    return e;
                                  }).toList()),
                            ),
                            Container(
                              child: Column(
                                children: [
                                  Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Constant.headacheFreeDayColor,
                                          shape: BoxShape.circle,
                                        ),
                                        height: 23,
                                        width: 23,
                                        child: Center(
                                          child: CustomTextWidget(
                                            text: totalHeadacheFreeDays
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: Constant.jostRegular,
                                              color:
                                                  Constant.locationServiceGreen,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      CustomTextWidget(
                                        text: (totalHeadacheFreeDays == 1) ? 'Headache-free day' : 'Headache-free days',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostRegular),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Constant.headacheDayColor,
                                          shape: BoxShape.circle,
                                        ),
                                        height: 23,
                                        width: 23,
                                        child: Center(
                                          child: CustomTextWidget(
                                            text: totalHeadacheDays.toString(),
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: Constant.jostRegular,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      CustomTextWidget(
                                        text: (totalHeadacheDays == 1) ? 'Headache day' : 'Headache days',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostRegular),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Constant.migraineColor,
                                          shape: BoxShape.circle,
                                        ),
                                        height: 23,
                                        width: 23,
                                        child: Center(
                                          child: CustomTextWidget(
                                            text: totalMigraineDays.toString(),
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: Constant.jostRegular,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      CustomTextWidget(
                                        text: (totalMigraineDays == 1) ? 'Migraine day' : 'Migraine days',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostRegular),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          _showMigraineDaysVsHeadacheDaysDialog();
                                        },
                                        child: Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                              color: Constant
                                                  .backgroundTransparentColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color:
                                                      Constant.chatBubbleGreen,
                                                  width: 1.3)),
                                          child: Center(
                                            child: CustomTextWidget(
                                              text: 'i',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Constant
                                                      .locationServiceGreen,
                                                  fontFamily:
                                                      Constant.jostRegular),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        Utils.closeApiLoaderDialog(context);
                        return NetworkErrorScreen(
                          errorMessage: snapshot.error.toString(),
                          tapToRetryFunction: () {
                            _calendarScreenBloc
                                .enterSomeDummyDataToStreamController();
                            requestService(firstDayOfTheCurrentMonth!,
                                lastDayOfTheCurrentMonth);
                          },
                        );
                      } else {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    DateTime dateTime = DateTime(
                                        _dateTime.year, _dateTime.month - 1);
                                    _dateTime = dateTime;
                                    _onStartDateSelected(dateTime);
                                  },
                                  behavior: HitTestBehavior.translucent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Image(
                                      image: AssetImage(Constant.backArrow),
                                      width: 17,
                                      height: 17,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _openDatePickerBottomSheet(
                                        CupertinoDatePickerMode.date);
                                    //widget.openDatePickerCallback(CupertinoDatePickerMode.date, _getDateTimeCallbackFunction(0), _dateTime);
                                  },
                                  behavior: HitTestBehavior.translucent,
                                  child: CustomTextWidget(
                                    text: monthName! +
                                        " " +
                                        currentYear.toString(),
                                    style: TextStyle(
                                        color: Constant.chatBubbleGreen,
                                        fontSize: 15,
                                        fontFamily: Constant.jostRegular),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    DateTime dateTime = DateTime(
                                        _dateTime.year, _dateTime.month + 1);
                                    Duration duration =
                                        dateTime.difference(DateTime.now());
                                    if (duration.inSeconds < 0) {
                                      _dateTime = dateTime;
                                      _onStartDateSelected(dateTime);
                                    } else {
                                      ///To:Do
                                      debugPrint("Not Allowed");
                                      //Utils.showValidationErrorDialog(context, Constant.beyondDateErrorMessage, 'Alert!');
                                      Utils.showSnackBar(context,
                                          Constant.beyondDateErrorMessage);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Image(
                                      image: AssetImage(Constant.nextArrow),
                                      width: 17,
                                      height: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Table(
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(children: [
                                  Center(
                                    child: CustomTextWidget(
                                      text: 'Su',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                  Center(
                                    child: CustomTextWidget(
                                      text: 'M',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                  Center(
                                    child: CustomTextWidget(
                                      text: 'Tu',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                  Center(
                                    child: CustomTextWidget(
                                      text: 'W',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                  Center(
                                    child: CustomTextWidget(
                                      text: 'Th',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                  Center(
                                    child: CustomTextWidget(
                                      text: 'F',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                  Center(
                                    child: CustomTextWidget(
                                      text: 'Sa',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                            Container(
                              height: 290,
                            ),
                          ],
                        );
                      }
                    }),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Consumer<CalendarTriggerInfo>(builder: (context, data, child) {
            return StreamBuilder<dynamic>(
                stream: _calendarScreenBloc.triggersDataStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length == 0) {
                      userMonthTriggersListModel.clear();
                    }
                    if (userMonthTriggersListModel.length == 0) {
                      userMonthTriggersListModel.addAll(snapshot.data);
                    } else {
                      userMonthTriggersListModel.clear();
                      userMonthTriggersListModel.addAll(snapshot.data);
                    }

                    var foundElements =
                        userMonthTriggersListModel.where((e) => e.isSelected!);
                    var menstruatingElement = foundElements.firstWhereOrNull(
                        (element) =>
                            element.answerData ==
                            Constant.menstruatingTriggerOption);

                    bool isMenstruatingOptionSelected =
                        menstruatingElement != null;
                    totalTriggersCanBeSelected =
                        isMenstruatingOptionSelected ? 9 : 8;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Visibility(
                          visible: userMonthTriggersListModel.length > 0,
                          child: Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            child: CustomTextWidget(
                              text:
                                  "${Constant.sortedCalenderTextView} (Select up to $totalTriggersCanBeSelected at a time)",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Constant.locationServiceGreen,
                                  fontFamily: Constant.jostRegular),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 150),
                          child: Container(
                            margin: EdgeInsets.only(left: 20, right: 15),
                            child: SingleChildScrollView(
                              physics: Utils.getScrollPhysics(),
                              child: Wrap(
                                children: [
                                  for (var i = 0;
                                      i < userMonthTriggersListModel.length;
                                      i++)
                                    GestureDetector(
                                      onTap: () {
                                        var foundElements = userMonthTriggersListModel.where((e) => e.isSelected!);

                                        var menstruatingElement = foundElements.firstWhereOrNull((element) => element.answerData == Constant.menstruatingTriggerOption);

                                        bool isMenstruatingOptionSelected = menstruatingElement != null;
                                        totalTriggersCanBeSelected = isMenstruatingOptionSelected ? 9 : ((!userMonthTriggersListModel[i].isSelected! && userMonthTriggersListModel[i].answerData == Constant.menstruatingTriggerOption) ? 9 : 8);

                                        if (!userMonthTriggersListModel[i].isSelected!) {
                                          if (foundElements.length < totalTriggersCanBeSelected) {
                                            SelectedTriggersColorsModel? unSelectedColor = (userMonthTriggersListModel[i].answerData == Constant.menstruatingTriggerOption) ? triggersColorsListData[0] : triggersColorsListData.firstWhereOrNull((element) => (!element.isSelected! && element.triggersColorsValue != Constant.menstruatingTriggerColor));
                                            if (unSelectedColor != null) {
                                              userMonthTriggersListModel[i].color = unSelectedColor.triggersColorsValue;
                                              userMonthTriggersListModel[i].isSelected = true;
                                              unSelectedColor.isSelected = true;
                                            }
                                            userMonthTriggersListModel[i].isSelected = true;
                                          } else {
                                            Utils.showTriggerSelectionDialog(
                                                context,
                                                totalTriggersCanBeSelected);
                                            debugPrint(
                                                "PopUp will be show for more then 3 selected color");
                                          }
                                        } else {
                                          var selectedColor =
                                              triggersColorsListData.firstWhereOrNull((element) => element.triggersColorsValue == userMonthTriggersListModel[i].color);
                                          if (selectedColor != null) {
                                            selectedColor.isSelected = false;
                                            userMonthTriggersListModel[i]
                                                .isSelected = false;
                                          }
                                        }

                                        var calendarTriggerInfo =
                                            Provider.of<CalendarTriggerInfo>(
                                                context,
                                                listen: false);
                                        calendarTriggerInfo
                                            .updateCalendarTriggerInfo();
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          right: 10,
                                          bottom: 10,
                                        ),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Constant.chatBubbleGreen,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: userMonthTriggersListModel[i]
                                                    .isSelected!
                                                ? Constant.chatBubbleGreen
                                                : Colors.transparent),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: ConstrainedBox(
                                            constraints:
                                                BoxConstraints(minHeight: 10),
                                            child: Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                Visibility(
                                                  visible:
                                                      userMonthTriggersListModel[
                                                              i]
                                                          .isSelected!,
                                                  child: Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Constant
                                                                .triggerOutlineColor,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        color:
                                                            userMonthTriggersListModel[
                                                                    i]
                                                                .color),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                                CustomTextWidget(
                                                  text:
                                                      userMonthTriggersListModel[
                                                              i]
                                                          .answerData!,
                                                  style: TextStyle(
                                                      color: userMonthTriggersListModel[
                                                                  i]
                                                              .isSelected!
                                                          ? Constant
                                                              .bubbleChatTextView
                                                          : Constant
                                                              .locationServiceGreen,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily:
                                                          Constant.jostMedium),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                });
          }),
        ],
      ),
    );
  }

  void _showMigraineDaysVsHeadacheDaysDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          content: MigraineDaysVsHeadacheDaysDialog(isFromTrigger: true),
        );
      },
    );
  }

  Color? selectedTriggersColor() {
    Color? unselectedColor;
    var foundElements = triggersColorsListData.where((e) => e.isSelected!);
    if (foundElements == null) {
      unselectedColor = Colors.red;
    } else {
      if (foundElements.length < 3) {
        var unSelectedTriggerColor = triggersColorsListData
            .firstWhereOrNull((element) => !element.isSelected!);

        if (unSelectedTriggerColor == null) {
          unselectedColor = Colors.red;
        } else {
          unselectedColor = unSelectedTriggerColor.triggersColorsValue;
        }
      }
    }
    return unselectedColor;
  }

  void requestService(
      String firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth) async {
    debugPrint('call calender trigger service');
    _initTriggerColorListData();
    await _calendarScreenBloc.fetchCalendarTriggersData(
        firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth, context);
  }

  void setCurrentMonthData(
      UserLogHeadacheDataCalendarModel userLogHeadacheDataCalendarModel,
      int currentMonth,
      int currentYear) {
    var calendarUtil = CalendarUtil(
        calenderType: 1,
        userLogHeadacheDataCalendarModel: userLogHeadacheDataCalendarModel,
        userMonthTriggersListData: _calendarScreenBloc.userMonthTriggersData,
        navigateToOtherScreenCallback: (routeName, data) async {
          dynamic isDataUpdated =
              await widget.navigateToOtherScreenCallback!(routeName, data);
          if (isDataUpdated != null && isDataUpdated is bool && isDataUpdated) {
            widget.refreshCalendarDataSink!.add(true);
          }
          return isDataUpdated;
        });
    currentMonthData =
        calendarUtil.drawMonthCalendar(yy: currentYear, mm: currentMonth);
  }

  /// @param cupertinoDatePickerMode: for time and date mode selection
  void _openDatePickerBottomSheet(
      CupertinoDatePickerMode cupertinoDatePickerMode) async {
    /*showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (context) => DateTimePicker(
              cupertinoDatePickerMode: cupertinoDatePickerMode,
              onDateTimeSelected: _getDateTimeCallbackFunction(0),
            ));*/
    var resultFromActionSheet = await widget.openDatePickerCallback!(
        MonthYearCupertinoDatePickerMode.date,
        _getDateTimeCallbackFunction(0) ?? () {},
        _dateTime);

    if (resultFromActionSheet != null && resultFromActionSheet is DateTime)
      _onStartDateSelected(resultFromActionSheet);
  }

  Function? _getDateTimeCallbackFunction(int whichPickerClicked) {
    switch (whichPickerClicked) {
      case 0:
        return _onStartDateSelected;
      default:
        return null;
    }
  }

  void _onStartDateSelected(DateTime dateTime) {
    userMonthTriggersListModel = [];
    totalDaysInCurrentMonth =
        Utils.daysInCurrentMonth(dateTime.month, dateTime.year);
    firstDayOfTheCurrentMonth = Utils.firstDateWithCurrentMonthAndTimeInUTC(
        dateTime.month, dateTime.year, 1);
    lastDayOfTheCurrentMonth = Utils.lastDateWithCurrentMonthAndTimeInUTC(
        dateTime.month, dateTime.year, totalDaysInCurrentMonth!);
    monthName = Utils.getMonthName(dateTime.month);
    currentYear = dateTime.year;
    currentMonth = dateTime.month;
    _dateTime = dateTime;
    _calendarScreenBloc.initNetworkStreamController();
    print('show api loader 8');
    Utils.showApiLoaderDialog(context,
        networkStream: _calendarScreenBloc.networkDataStream,
        tapToRetryFunction: () {
      _calendarScreenBloc.enterSomeDummyDataToStreamController();
      requestService(firstDayOfTheCurrentMonth!, lastDayOfTheCurrentMonth);
    });
    requestService(firstDayOfTheCurrentMonth!, lastDayOfTheCurrentMonth);
  }

  @override
  bool get wantKeepAlive => true;

  void getCurrentPositionOfTabBar() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String isSeeMoreClicked =
        sharedPreferences.getString(Constant.isSeeMoreClicked) ??
            Constant.blankString;
    String isTrendsClicked =
        sharedPreferences.getString(Constant.isViewTrendsClicked) ??
            Constant.blankString;
    String updateCalendarTriggerData =
        sharedPreferences.getString(Constant.updateCalendarTriggerData) ??
            Constant.blankString;

    debugPrint(
        'isSeeMoreClicked?????$isSeeMoreClicked???isViewTrends?????$isSeeMoreClicked???updateCalendarTriggerData?????$updateCalendarTriggerData');

    if (isSeeMoreClicked.isEmpty &&
        isTrendsClicked.isEmpty &&
        updateCalendarTriggerData == Constant.trueString) {
      sharedPreferences.remove(Constant.updateCalendarTriggerData);
      _calendarScreenBloc.initNetworkStreamController();
      currentMonth = _dateTime.month;
      currentYear = _dateTime.year;
      monthName = Utils.getMonthName(currentMonth!);
      totalDaysInCurrentMonth =
          Utils.daysInCurrentMonth(currentMonth!, currentYear!);
      firstDayOfTheCurrentMonth = Utils.firstDateWithCurrentMonthAndTimeInUTC(
          currentMonth!, currentYear!, 1);
      lastDayOfTheCurrentMonth = Utils.lastDateWithCurrentMonthAndTimeInUTC(
          currentMonth!, currentYear!, totalDaysInCurrentMonth!);

      int? currentPositionOfTabBar =
          sharedPreferences.getInt(Constant.currentIndexOfTabBar);

      int? recordTabBarPosition =
          sharedPreferences.getInt(Constant.recordTabNavigatorState);

      if (currentPositionOfTabBar == 1 && recordTabBarPosition == 0) {
        _calendarScreenBloc.initNetworkStreamController();

        String isViewTrendsClicked =
            sharedPreferences.getString(Constant.isViewTrendsClicked) ??
                Constant.blankString;

        if (isViewTrendsClicked.isEmpty) {
          print('show api loader 3');
          _calendarScreenBloc.initNetworkStreamController();
          widget.showApiLoaderCallback!(_calendarScreenBloc.networkDataStream,
              () {
            _calendarScreenBloc.enterSomeDummyDataToStreamController();
            requestService(
                firstDayOfTheCurrentMonth!, lastDayOfTheCurrentMonth);
          });
        }

        requestService(firstDayOfTheCurrentMonth!, lastDayOfTheCurrentMonth);
      }
    } else {
      sharedPreferences.remove(Constant.isSeeMoreClicked);
    }
  }

  void callAPIService() async {
    //try {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? currentPositionOfTabBar =
        sharedPreferences.getInt(Constant.currentIndexOfTabBar);
    int? recordTabBarPosition =
        sharedPreferences.getInt(Constant.recordTabNavigatorState);
    String isViewTrendsClicked =
        sharedPreferences.getString(Constant.isViewTrendsClicked) ??
            Constant.blankString;

    if (currentPositionOfTabBar == 1 && recordTabBarPosition == 0) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (isViewTrendsClicked.isEmpty) {
          print('show api loader 1');
          widget.showApiLoaderCallback!(_calendarScreenBloc.networkDataStream,
              () {
            _calendarScreenBloc.enterSomeDummyDataToStreamController();
            requestService(
                firstDayOfTheCurrentMonth!, lastDayOfTheCurrentMonth);
          });
        }
      });
    }
    requestService(firstDayOfTheCurrentMonth!, lastDayOfTheCurrentMonth);
    //} catch(e) {
    //print(e);
    //}
  }

  void _removeDataFromSharedPreference() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(Constant.updateCalendarTriggerData);
  }

  void _countTotalDays(
      UserLogHeadacheDataCalendarModel userLogHeadacheDataCalendarModel) {
    totalHeadacheDays = 0;
    totalMigraineDays = 0;
    totalHeadacheFreeDays = 0;

    List<int> headacheLoggedDateList = [];

    userLogHeadacheDataCalendarModel.addHeadacheIntensityListData
        .forEach((element) {
      bool isDateFound = false;

      headacheLoggedDateList.forEach((dateTimeElement) {
        if (dateTimeElement.toString() == element.selectedDay) {
          isDateFound = true;
        }
      });

      if (!isDateFound) {
        headacheLoggedDateList.add(int.tryParse(element.selectedDay!)!);
        if (!element.isMigraine)
          totalHeadacheDays++;
        else{
          totalMigraineDays++;
          totalHeadacheDays++;
        }
      }
    });

    userLogHeadacheDataCalendarModel.addLogDayListData.forEach((element) {
      bool isHeadacheLogged = false;

      headacheLoggedDateList.forEach((dateTimeElement) {
        if (dateTimeElement.toString() == element.selectedDay) {
          isHeadacheLogged = true;
        }
      });

      if (!isHeadacheLogged) {
        totalHeadacheFreeDays++;
      }
    });

    debugPrint(
        "TotalMigraineDays=$totalMigraineDays&TotalHeadacheDays=$totalHeadacheDays&TotalHeadacheFreeDays=$totalHeadacheFreeDays");
  }

  void _initTriggerColorListData() {
    triggersColorsListData = [
      SelectedTriggersColorsModel(
          triggersColorsValue: Constant.menstruatingTriggerColor,
          isSelected: true),
      SelectedTriggersColorsModel(
          triggersColorsValue: Constant.triggerOneColor, isSelected: true),
      SelectedTriggersColorsModel(
          triggersColorsValue: Constant.triggerTwoColor, isSelected: true),
      SelectedTriggersColorsModel(
          triggersColorsValue: Constant.triggerThreeColor, isSelected: false),
      SelectedTriggersColorsModel(
          triggersColorsValue: Constant.triggerFourColor, isSelected: false),
      SelectedTriggersColorsModel(
          triggersColorsValue: Constant.triggerFiveColor, isSelected: false),
      SelectedTriggersColorsModel(
          triggersColorsValue: Constant.triggerSixColor, isSelected: false),
      SelectedTriggersColorsModel(
          triggersColorsValue: Constant.triggerSevenColor, isSelected: false),
      SelectedTriggersColorsModel(
          triggersColorsValue: Constant.triggerEightColor, isSelected: false),
    ];
  }
}

class CalendarTriggerInfo with ChangeNotifier {
  updateCalendarTriggerInfo() {
    notifyListeners();
  }
}
