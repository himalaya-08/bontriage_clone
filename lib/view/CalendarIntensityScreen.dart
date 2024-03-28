import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/blocs/CalendarScreenBloc.dart';
import 'package:mobile/models/UserLogHeadacheDataCalendarModel.dart';
import 'package:mobile/util/CalendarUtil.dart';
import 'package:mobile/util/MonthYearCupertinoDatePicker.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/MigraineDaysVsHeadacheDaysDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CustomTextWidget.dart';

class CalendarIntensityScreen extends StatefulWidget {
  final Function(Stream, Function)? showApiLoaderCallback;
  final Future<dynamic> Function(String, dynamic)? navigateToOtherScreenCallback;
  final StreamSink<dynamic>? refreshCalendarDataSink;
  final Stream<dynamic>? refreshCalendarDataStream;
  final Future<DateTime> Function(MonthYearCupertinoDatePickerMode, Function, DateTime)?
      openDatePickerCallback;

  const CalendarIntensityScreen(
      {Key? key,
      this.showApiLoaderCallback,
      this.navigateToOtherScreenCallback,
      this.refreshCalendarDataStream,
      this.refreshCalendarDataSink,
      this.openDatePickerCallback})
      : super(key: key);

  @override
  _CalendarIntensityScreenState createState() =>
      _CalendarIntensityScreenState();
}

class _CalendarIntensityScreenState extends State<CalendarIntensityScreen>
    with AutomaticKeepAliveClientMixin {
  List<Widget> currentMonthData = [];
  CalendarScreenBloc _calendarScreenBloc = CalendarScreenBloc();
  DateTime? _dateTime;
  int? currentMonth;
  int? currentYear;
  String? monthName;
  int? totalDaysInCurrentMonth;
  String? firstDayOfTheCurrentMonth;
  String? lastDayOfTheCurrentMonth;
  int totalHeadacheDays = 0;
  int totalMigraineDays = 0;
  int totalHeadacheFreeDays = 0;

  @override
  void initState() {
    super.initState();
    _calendarScreenBloc = CalendarScreenBloc();
    _dateTime = DateTime.now();
    currentMonth = _dateTime!.month;
    currentYear = _dateTime!.year;
    monthName = Utils.getMonthName(currentMonth!);
    totalDaysInCurrentMonth =
        Utils.daysInCurrentMonth(currentMonth!, currentYear!);
    firstDayOfTheCurrentMonth = Utils.firstDateWithCurrentMonthAndTimeInUTC(
        currentMonth!, currentYear!, 1);
    lastDayOfTheCurrentMonth = Utils.lastDateWithCurrentMonthAndTimeInUTC(
        currentMonth!, currentYear!, totalDaysInCurrentMonth!);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _showApiLoaderDialog();
      _removeDataFromSharedPreference();
      debugPrint('call api service 1');
      _callApiService();
    });
      widget.refreshCalendarDataStream!.listen((event) {
      if (event is bool && event) {
        _removeDataFromSharedPreference();
        currentMonth = _dateTime!.month;
        currentYear = _dateTime!.year;
        monthName = Utils.getMonthName(currentMonth!);
        totalDaysInCurrentMonth =
            Utils.daysInCurrentMonth(currentMonth!, currentYear!);
        firstDayOfTheCurrentMonth = Utils.firstDateWithCurrentMonthAndTimeInUTC(
            currentMonth!, currentYear!, 1);
        lastDayOfTheCurrentMonth = Utils.lastDateWithCurrentMonthAndTimeInUTC(
            currentMonth!, currentYear!, totalDaysInCurrentMonth!);
        //_calendarScreenBloc.initNetworkStreamController();

        debugPrint('call api service 2');
        _callApiService();
      }
    });
  }

  @override
  void didUpdateWidget(CalendarIntensityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('did update widget of calendar intensity screen');
    _updateCalendarData();
  }

  @override
  Widget build(BuildContext context) {

    super.build(context);
    return Container(
      child: SingleChildScrollView(
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
                          _setCurrentMonthData(
                              snapshot.data, currentMonth!, currentYear!);
                          _countTotalDays(snapshot.data);
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      DateTime dateTime = DateTime(
                                          _dateTime!.year,
                                          _dateTime!.month - 1);
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
                                          _dateTime!.year,
                                          _dateTime!.month + 1);
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
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostMedium),
                                      ),
                                    ),
                                    Center(
                                      child: CustomTextWidget(
                                        text: 'M',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostMedium),
                                      ),
                                    ),
                                    Center(
                                      child: CustomTextWidget(
                                        text: 'Tu',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostMedium),
                                      ),
                                    ),
                                    Center(
                                      child: CustomTextWidget(
                                        text: 'W',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostMedium),
                                      ),
                                    ),
                                    Center(
                                      child: CustomTextWidget(
                                        text: 'Th',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostMedium),
                                      ),
                                    ),
                                    Center(
                                      child: CustomTextWidget(
                                        text: 'F',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostMedium),
                                      ),
                                    ),
                                    Center(
                                      child: CustomTextWidget(
                                        text: 'Sa',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Constant.locationServiceGreen,
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
                              SizedBox(
                                height: 5,
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
                                            color:
                                                Constant.headacheFreeDayColor,
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
                                                fontFamily:
                                                    Constant.jostRegular,
                                                color: Constant
                                                    .locationServiceGreen,
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
                                              text:
                                                  totalHeadacheDays.toString(),
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontFamily:
                                                    Constant.jostRegular,
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
                                              text:
                                                  totalMigraineDays.toString(),
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontFamily:
                                                    Constant.jostRegular,
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
                                                    color: Constant
                                                        .chatBubbleGreen,
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
                          return Container();
                        } else {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      DateTime dateTime = DateTime(
                                          _dateTime!.year,
                                          _dateTime!.month - 1);
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
                                          _dateTime!.year,
                                          _dateTime!.month + 1);
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
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostMedium),
                                      ),
                                    ),
                                    Center(
                                      child: CustomTextWidget(
                                        text: 'M',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostMedium),
                                      ),
                                    ),
                                    Center(
                                      child: CustomTextWidget(
                                        text: 'Tu',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostMedium),
                                      ),
                                    ),
                                    Center(
                                      child: CustomTextWidget(
                                        text: 'W',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostMedium),
                                      ),
                                    ),
                                    Center(
                                      child: CustomTextWidget(
                                        text: 'Th',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostMedium),
                                      ),
                                    ),
                                    Center(
                                      child: CustomTextWidget(
                                        text: 'F',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Constant.locationServiceGreen,
                                            fontFamily: Constant.jostMedium),
                                      ),
                                    ),
                                    Center(
                                      child: CustomTextWidget(
                                        text: 'Sa',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Constant.locationServiceGreen,
                                          fontFamily: Constant.jostMedium,
                                        ),
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
            Container(
              margin: EdgeInsets.only(left: 15, right: 15, top: 10),
              child: CustomTextWidget(
                text: 'Pain intensity (range)',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 14,
                    color: Constant.locationServiceGreen,
                    fontFamily: Constant.jostRegular),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Constant.mildTriggerColor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        height: 8,
                        width: 16,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      CustomTextWidget(
                        text: 'Mild',
                        style: TextStyle(
                            fontSize: 14,
                            color: Constant.locationServiceGreen,
                            fontFamily: Constant.jostMedium),
                      ),
                      CustomTextWidget(
                        text: ' (1-3)',
                        style: TextStyle(
                            fontSize: 14,
                            color: Constant.locationServiceGreen,
                            fontFamily: Constant.jostRegular),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Constant.moderateTriggerColor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        height: 8,
                        width: 16,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      CustomTextWidget(
                        text: 'Moderate',
                        style: TextStyle(
                            fontSize: 14,
                            color: Constant.locationServiceGreen,
                            fontFamily: Constant.jostMedium),
                      ),
                      CustomTextWidget(
                        text: ' (4-7)',
                        style: TextStyle(
                            fontSize: 14,
                            color: Constant.locationServiceGreen,
                            fontFamily: Constant.jostRegular),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Constant.severeTriggerColor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        height: 8,
                        width: 16,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      CustomTextWidget(
                        text: 'Severe',
                        style: TextStyle(
                            fontSize: 14,
                            color: Constant.locationServiceGreen,
                            fontFamily: Constant.jostMedium),
                      ),
                      CustomTextWidget(
                        text: ' (8-10)',
                        style: TextStyle(
                            fontSize: 14,
                            color: Constant.locationServiceGreen,
                            fontFamily: Constant.jostRegular),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void requestService(
      String firstDayOfTheCurrentMonth, String lastDayOfTheCurrentMonth) async {
    debugPrint('call calender intensity service');
    await _calendarScreenBloc.fetchCalendarTriggersData(
        firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth, context);
  }

  void _setCurrentMonthData(
      UserLogHeadacheDataCalendarModel userLogHeadacheDataCalendarModel,
      int currentMonth,
      int currentYear) {
    var calendarUtil = CalendarUtil(
      calenderType: 2,
      userLogHeadacheDataCalendarModel: userLogHeadacheDataCalendarModel,
      userMonthTriggersListData: [],
      navigateToOtherScreenCallback: (routeName, data) async {
        dynamic isDataUpdated =
            await widget.navigateToOtherScreenCallback!(routeName, data);
        if (isDataUpdated != null && isDataUpdated is bool && isDataUpdated) {
          widget.refreshCalendarDataSink!.add(true);
        }
        return isDataUpdated;
      },
    );
    currentMonthData = calendarUtil.drawMonthCalendar(yy: currentYear, mm: currentMonth);
  }

  /// @param cupertinoDatePickerMode: for time and date mode selection
  void _openDatePickerBottomSheet(
      CupertinoDatePickerMode cupertinoDatePickerMode) async {
    var resultFromActionSheet = await widget.openDatePickerCallback!(
        MonthYearCupertinoDatePickerMode.date,
        _getDateTimeCallbackFunction(0)!,
        _dateTime!);

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
    debugPrint('show api loader 9');
    Utils.showApiLoaderDialog(context,
        networkStream: _calendarScreenBloc.networkDataStream,
        tapToRetryFunction: () {
      _calendarScreenBloc.enterSomeDummyDataToStreamController();
      debugPrint('call api service 3');
      _callApiService();
    });
    debugPrint('call api service 4');
    _callApiService();
  }

  @override
  bool get wantKeepAlive => true;

  void _showMigraineDaysVsHeadacheDaysDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          content: MigraineDaysVsHeadacheDaysDialog(),
        );
      },
    );
  }

  void _callApiService() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    int? currentPositionOfTabBar =
        sharedPreferences.getInt(Constant.currentIndexOfTabBar);
    int? recordTabBarPosition = 0;

    try {
      recordTabBarPosition =
          sharedPreferences.getInt(Constant.recordTabNavigatorState);
    } catch (e) {
      debugPrint(e.toString());
    }

    if (currentPositionOfTabBar == 1 && recordTabBarPosition == 0) {
      requestService(firstDayOfTheCurrentMonth!, lastDayOfTheCurrentMonth!);
    }
  }

  void _showApiLoaderDialog() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String isViewTrendsClicked =
        sharedPreferences.getString(Constant.isViewTrendsClicked) ??
            Constant.blankString;

    if (isViewTrendsClicked.isEmpty) {
      _calendarScreenBloc.initNetworkStreamController();
      debugPrint('show api loader 4');
      widget.showApiLoaderCallback!(_calendarScreenBloc.networkDataStream, () {
        _calendarScreenBloc.enterSomeDummyDataToStreamController();
        debugPrint('call api service 5');
        _callApiService();
      });
    }
  }

  void _updateCalendarData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String isSeeMoreClicked =
        sharedPreferences.getString(Constant.isSeeMoreClicked) ??
            Constant.blankString;
    String isTrendsClicked =
        sharedPreferences.getString(Constant.isViewTrendsClicked) ??
            Constant.blankString;
    String updateCalendarIntensityData =
        sharedPreferences.getString(Constant.updateCalendarIntensityData) ??
            Constant.blankString;

    if (isSeeMoreClicked.isEmpty &&
        isTrendsClicked.isEmpty &&
        updateCalendarIntensityData == Constant.trueString) {
      Future.delayed(Duration(seconds: 4), () {
        sharedPreferences.remove(Constant.updateCalendarIntensityData);
        currentMonth = _dateTime!.month;
        currentYear = _dateTime!.year;
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
          debugPrint('show api loader 10');
          widget.showApiLoaderCallback!(_calendarScreenBloc.networkDataStream,
              () {
            _calendarScreenBloc.enterSomeDummyDataToStreamController();
            requestService(
                firstDayOfTheCurrentMonth!, lastDayOfTheCurrentMonth!);
          });
        }
        debugPrint('call api service 6');
        _callApiService();
      });
    }
  }

  void _removeDataFromSharedPreference() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(Constant.updateCalendarIntensityData);
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
}
