import 'dart:async';
import 'package:collection/collection.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/EditGraphViewFilterModel.dart';
import 'package:mobile/models/RecordsTrendsDataModel.dart';
import 'package:mobile/models/RecordsTrendsMultipleHeadacheDataModel.dart';
import 'package:mobile/models/TrendsFilterModel.dart';
import 'package:mobile/util/MonthYearCupertinoDatePicker.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class TrendsIntensityScreen extends StatefulWidget {
  final EditGraphViewFilterModel editGraphViewFilterModel;
  final Function updateTrendsDataCallback;
  final Future<DateTime> Function(MonthYearCupertinoDatePickerMode, Function, DateTime)
      openDatePickerCallback;

  const TrendsIntensityScreen(
      {Key? key,
      required this.editGraphViewFilterModel,
      required this.updateTrendsDataCallback,
      required this.openDatePickerCallback})
      : super(key: key);

  @override
  _TrendsIntensityScreenState createState() => _TrendsIntensityScreenState();
}

class _TrendsIntensityScreenState extends State<TrendsIntensityScreen>
    with AutomaticKeepAliveClientMixin {
  DateTime? _dateTime;
  int? currentMonth;
  int? currentYear;
  String? monthName;
  int? totalDaysInCurrentMonth;
  String? firstDayOfTheCurrentMonth;
  String? lastDayOfTheCurrentMonth;
  final Color leftBarColor = const Color(0xff000000);
  final Color rightBarColor = const Color(0xffff5182);
  final double width = 7;

  List<BarChartGroupData>? rawBarGroups;
  List<BarChartGroupData>? showingBarGroups;

  int? touchedGroupIndex;

  int? clickedValue;
  bool isClicked = false;
  List<Ity> intensityListData = [];
  List<Data>? multipleFirstIntensityListData = [];
  List<Data>? multipleSecondIntensityListData = [];
  List<BarChartGroupData>? items;
  List<double> firstWeekIntensityData = [];
  List<double> secondWeekIntensityData = [];
  List<double> thirdWeekIntensityData = [];
  List<double> fourthWeekIntensityData = [];
  List<double> fifthWeekIntensityData = [];

  List<double> multipleFirstWeekIntensityData = [];
  List<double> multipleSecondWeekIntensityData = [];
  List<double> multipleThirdWeekIntensityData = [];
  List<double> multipleFourthWeekIntensityData = [];
  List<double> multipleFifthWeekIntensityData = [];

  BarChartGroupData? barGroup2;
  BarChartGroupData? barGroup1;
  BarChartGroupData? barGroup3;
  BarChartGroupData? barGroup4;
  BarChartGroupData? barGroup5;

  bool headacheColorChanged = false;

  @override
  void initState() {
    super.initState();

    _dateTime = widget.editGraphViewFilterModel.selectedDateTime;
    currentMonth = _dateTime!.month;
    currentYear = _dateTime!.year;
    monthName = Utils.getMonthName(currentMonth!);
    totalDaysInCurrentMonth =
        Utils.daysInCurrentMonth(currentMonth!, currentYear!);
    firstDayOfTheCurrentMonth = Utils.firstDateWithCurrentMonthAndTimeInUTC(
        currentMonth!, currentYear!, 1);
    lastDayOfTheCurrentMonth = Utils.lastDateWithCurrentMonthAndTimeInUTC(
        currentMonth!, currentYear!, totalDaysInCurrentMonth!);
    setIntensityValuesData();
  }

  @override
  void didUpdateWidget(covariant TrendsIntensityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('in did update widget of trends intensity screen');
    _dateTime = widget.editGraphViewFilterModel.selectedDateTime;
    currentMonth = _dateTime!.month;
    currentYear = _dateTime!.year;
    monthName = Utils.getMonthName(currentMonth!);
    totalDaysInCurrentMonth =
        Utils.daysInCurrentMonth(currentMonth!, currentYear!);
    firstDayOfTheCurrentMonth = Utils.firstDateWithCurrentMonthAndTimeInUTC(
        currentMonth!, currentYear!, 1);
    lastDayOfTheCurrentMonth = Utils.lastDateWithCurrentMonthAndTimeInUTC(
        currentMonth!, currentYear!, totalDaysInCurrentMonth!);
    setIntensityValuesData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height/3,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Container(
                  //height: 250,
                  width: totalDaysInCurrentMonth !<= 28 ? 340 : 420,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            SizedBox(
                              height: 85,
                              child: Transform.rotate(
                                angle: -1.5708,
                                child: Text(
                                  'Maximum Intensity',
                                  style: TextStyle(
                                      color: Color(0xffCAD7BF),
                                      fontFamily: 'JostRegular',
                                      fontSize: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 22),
                        child: BarChart(
                         BarChartData(
                            maxY: 10,
                            minY: 0,
                            groupsSpace: 10,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                  tooltipBgColor: setToolTipColor(),
                                  tooltipPadding:
                                      EdgeInsets.symmetric(horizontal: 13, vertical: 1),
                                  tooltipRoundedRadius: 20,
                                 // tooltipBottomMargin: 10,
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    String weekDay =
                                        '${Utils.getShortMonthName(_dateTime!.month)} ${(groupIndex * 7) + rodIndex + 1}';
                                    return BarTooltipItem(
                                        weekDay +
                                            '\n' +
                                            (rod.toY.toInt()).toString() +
                                            '/10 Int.',
                                        TextStyle(
                                            color: setToolTipTextColor(),
                                            fontFamily: Constant.jostRegular,
                                            fontSize: 12));
                                  },
                                  fitInsideHorizontally: true,
                                  fitInsideVertically: true),
                              touchCallback: (touchEvent, response) {
                                if (response?.spot != null) {
                                  if (response?.spot!.spot != null) {
                                    if (response?.spot!.spot.y != null) {
                                      setState(() {
                                        clickedValue = response?.spot!.spot.y.toInt();
                                        if (touchEvent is FlLongPressEnd ||
                                            touchEvent is FlPanEndEvent) {
                                          isClicked = true;
                                        }
                                      });
                                    }
                                  }
                                }
                              },
                              handleBuiltInTouches: true,
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                left: BorderSide(color: const Color(0x800E4C47)),
                                top: BorderSide(color: Colors.transparent),
                                bottom: BorderSide(color: const Color(0x800E4C47)),
                                right: BorderSide(color: Colors.transparent),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              checkToShowHorizontalLine: (value) => value % 2 == 0,
                              getDrawingHorizontalLine: (value) {
                                if (value == 0) {
                                  return FlLine(
                                      color: const Color(0x800E4C47), strokeWidth: 1);
                                }
                                return FlLine(
                                  color: const Color(0x800E4C47),
                                  strokeWidth: 0.8,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  //margin: 2,
                                  getTitlesWidget: (val, meta){
                                    return Text(
                                    getHorizontalTileText(val),
                                    style: const TextStyle(
                                        color: Color(0xffCAD7BF),
                                        fontFamily: 'JostRegular',
                                        fontSize: 10),
                                    );
                                  }
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                            showTitles: true,
                              //margin: 10,
                              reservedSize: 11,
                              getTitlesWidget: (val, meta){
                              return Text(
                                getVerticalTileText(val),
                                style: const TextStyle(
                                    color: Color(0xffCAD7BF),
                                    fontFamily: 'JostRegular',
                                    fontSize: 10),
                              );
                              }
                            ),
                            ),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false),),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false),),
                            ),
                            barGroups: showingBarGroups,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible:
                  widget.editGraphViewFilterModel.whichOtherFactorSelected !=
                      Constant.noneRadioButtonText,
              child: Column(
                children: [
                  SizedBox(
                    height: 18,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5, top: 10),
                        child: Container(
                          width: 60,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: getDotText(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: getDotsWidget()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    DateTime dateTime =
                        DateTime(_dateTime!.year, _dateTime!.month - 1);
                    _dateTime = dateTime;
                    print('clicked');
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
                  onTap: () {
                    _openDatePickerBottomSheet(CupertinoDatePickerMode.date);
                  },
                  child: CustomTextWidget(
                    text: '$monthName $currentYear',
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
                    DateTime dateTime =
                        DateTime(_dateTime!.year, _dateTime!.month + 1);
                    print("clicked");
                    Duration duration = dateTime.difference(DateTime.now());
                    if (duration.inSeconds < 0) {
                      _dateTime = dateTime;
                      _onStartDateSelected(dateTime);
                    } else {
                      ///To:Do
                      print("Not Allowed");
                      //Utils.showValidationErrorDialog(context, Constant.beyondDateErrorMessage);
                      Utils.showSnackBar(context, Constant.beyondDateErrorMessage);
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
              height: 5,
            ),
            Visibility(
              visible: widget.editGraphViewFilterModel
                      .headacheTypeRadioButtonSelected ==
                  Constant.viewSingleHeadache,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Constant.mildTriggerColor,
                      shape: BoxShape.rectangle,
                    ),
                    height: 13,
                    width: 13,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CustomTextWidget(
                    text: 'Mild',
                    style: TextStyle(
                        fontSize: 14,
                        color: Constant.locationServiceGreen,
                        fontFamily: Constant.jostRegular),
                  ),
                  SizedBox(
                    width: 14,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Constant.moderateTriggerColor,
                      shape: BoxShape.rectangle,
                    ),
                    height: 13,
                    width: 13,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CustomTextWidget(
                    text: 'Moderate',
                    style: TextStyle(
                        fontSize: 14,
                        color: Constant.locationServiceGreen,
                        fontFamily: Constant.jostRegular),
                  ),
                  SizedBox(
                    width: 14,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Constant.severeTriggerColor,
                      shape: BoxShape.rectangle,
                    ),
                    height: 13,
                    width: 13,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CustomTextWidget(
                    text: 'Severe',
                    style: TextStyle(
                        fontSize: 14,
                        color: Constant.locationServiceGreen,
                        fontFamily: Constant.jostRegular),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget.editGraphViewFilterModel
                      .headacheTypeRadioButtonSelected !=
                  Constant.viewSingleHeadache,
              child: Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: /*setHeadacheColor()*/Constant.otherHeadacheColor,
                            shape: BoxShape.rectangle,
                          ),
                          height: 13,
                          width: 13,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        CustomTextWidget(
                          text: widget.editGraphViewFilterModel.compareHeadacheTypeSelected1 ?? Constant.blankString,
                          style: TextStyle(
                              fontSize: 14,
                              color: Constant.locationServiceGreen,
                              fontFamily: Constant.jostRegular),
                        ),
                        SizedBox(
                          width: 14,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: /*headacheColorChanged? Constant.otherHeadacheColor: */Constant.migraineColor,
                            shape: BoxShape.rectangle,
                          ),
                          height: 13,
                          width: 13,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        CustomTextWidget(
                          text: widget.editGraphViewFilterModel.compareHeadacheTypeSelected2 ?? Constant.blankString,
                          style: TextStyle(
                              fontSize: 14,
                              color: Constant.locationServiceGreen,
                              fontFamily: Constant.jostRegular),
                        ),
                        SizedBox(
                          width: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2, double y3,
      double y4, double y5, double y6, double y7) {
    return BarChartGroupData(barsSpace: 2.5, x: x, barRods: [
      BarChartRodData(
        toY: y1,
        color: setBarChartColor(y1),
        width: width,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3), topRight: Radius.circular(3)),
      ),
      BarChartRodData(
        toY: y2,
        color: setBarChartColor(y2),
        width: width,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3), topRight: Radius.circular(3)),
      ),
      BarChartRodData(
        toY: y3,
        color: setBarChartColor(y3),
        width: width,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3), topRight: Radius.circular(3)),
      ),
      BarChartRodData(
        toY: y4,
        color: setBarChartColor(y4),
        width: width,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3), topRight: Radius.circular(3)),
      ),
      BarChartRodData(
        toY: y5,
        color: setBarChartColor(y5),
        width: width,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3), topRight: Radius.circular(3)),
      ),
      BarChartRodData(
        toY: y6,
        color: setBarChartColor(y6),
        width: width,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3), topRight: Radius.circular(3)),
      ),
      BarChartRodData(
        toY: y7,
        color: setBarChartColor(y7),
        width: width,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3), topRight: Radius.circular(3)),
      ),
    ]);
  }

  BarChartGroupData makeMultipleGroupData(
      int x,
      double firstMultipleHeadache1,
      double firstMultipleHeadache2,
      double firstMultipleHeadache3,
      double firstMultipleHeadache4,
      double firstMultipleHeadache5,
      double firstMultipleHeadache6,
      double firstMultipleHeadache7,
      double secondMultipleHeadache1,
      double secondMultipleHeadache2,
      double secondMultipleHeadache3,
      double secondMultipleHeadache4,
      double secondMultipleHeadache5,
      double secondMultipleHeadache6,
      double secondMultipleHeadache7) {
    return BarChartGroupData(barsSpace: 2.5, x: x, barRods: [
      BarChartRodData(
        toY: setAxisValue(firstMultipleHeadache1, secondMultipleHeadache1),
        rodStackItems:
            setRodStack(firstMultipleHeadache1, secondMultipleHeadache1),
        width: width,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2), topRight: Radius.circular(2)),
      ),
      BarChartRodData(
        toY: setAxisValue(firstMultipleHeadache2, secondMultipleHeadache2),
        color: Colors.transparent,
        rodStackItems:
            setRodStack(firstMultipleHeadache2, secondMultipleHeadache2),
        width: width,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2), topRight: Radius.circular(2)),
      ),
      BarChartRodData(
        toY: setAxisValue(firstMultipleHeadache3, secondMultipleHeadache3),
        color: Colors.transparent,
        rodStackItems:
            setRodStack(firstMultipleHeadache3, secondMultipleHeadache3),
        width: width,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2), topRight: Radius.circular(2)),
      ),
      BarChartRodData(
        toY: setAxisValue(firstMultipleHeadache4, secondMultipleHeadache4),
        color: Colors.transparent,
        rodStackItems:
            setRodStack(firstMultipleHeadache4, secondMultipleHeadache4),
        width: width,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2), topRight: Radius.circular(2)),
      ),
      BarChartRodData(
        toY: setAxisValue(firstMultipleHeadache5, secondMultipleHeadache5),
        color: Colors.transparent,
        rodStackItems:
            setRodStack(firstMultipleHeadache5, secondMultipleHeadache5),
        width: width,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2), topRight: Radius.circular(2)),
      ),
      BarChartRodData(
        toY: setAxisValue(firstMultipleHeadache6, secondMultipleHeadache6),
        color: Colors.transparent,
        rodStackItems:
            setRodStack(firstMultipleHeadache6, secondMultipleHeadache6),
        width: width,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2), topRight: Radius.circular(2)),
      ),
      BarChartRodData(
        toY: setAxisValue(firstMultipleHeadache7, secondMultipleHeadache7),
        color: Colors.transparent,
        rodStackItems:
            setRodStack(firstMultipleHeadache7, secondMultipleHeadache7),
        width: width,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2), topRight: Radius.circular(2)),
      ),
    ]);
  }

  /// @param cupertinoDatePickerMode: for time and date mode selection
  void _openDatePickerBottomSheet(
      CupertinoDatePickerMode cupertinoDatePickerMode) async {
    var resultFromActionSheet = await widget.openDatePickerCallback(
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
    _dateTime = dateTime;
    widget.editGraphViewFilterModel.selectedDateTime = _dateTime!;
    totalDaysInCurrentMonth =
        Utils.daysInCurrentMonth(dateTime.month, dateTime.year);
    firstDayOfTheCurrentMonth = Utils.firstDateWithCurrentMonthAndTimeInUTC(
        dateTime.month, dateTime.year, 1);
    lastDayOfTheCurrentMonth = Utils.lastDateWithCurrentMonthAndTimeInUTC(
        dateTime.month, dateTime.year, totalDaysInCurrentMonth!);
    monthName = Utils.getMonthName(dateTime.month);
    currentYear = dateTime.year;
    currentMonth = dateTime.month;
    widget.updateTrendsDataCallback();
  }

  Color setToolTipColor() {
    if (clickedValue != null) {
      if (widget.editGraphViewFilterModel.headacheTypeRadioButtonSelected ==
          Constant.viewSingleHeadache) {
        if (clickedValue !>= 1 && clickedValue !<= 3) {
          return Constant.mildTriggerColor;
        } else if (clickedValue !>= 4 && clickedValue !<= 7) {
          return Constant.moderateTriggerColor;
        } else if (clickedValue !> 7)
          return Constant.severeTriggerColor;
        else
          return Colors.transparent;
      } else {
        return Constant.migraineColor;
      }
    }
    return Colors.transparent;
  }

  Color setBarChartColor(double barChartValue) {
    if (barChartValue >= 1 && barChartValue <= 3) {
      return Constant.mildTriggerColor;
    } else if (barChartValue >= 4 && barChartValue <= 7) {
      return Constant.moderateTriggerColor;
    } else if (barChartValue > 7) {
      return Constant.severeTriggerColor;
    } else
      return Colors.transparent;
  }

  void setAllWeekIntensityData(int i, double intensityData) {
    if (i <= 7) {
      firstWeekIntensityData.add(intensityData);
    }
    if (i > 7 && i <= 14) {
      secondWeekIntensityData.add(intensityData);
    }
    if (i > 14 && i <= 21) {
      thirdWeekIntensityData.add(intensityData);
    }
    if (i > 21 && i <= 28) {
      fourthWeekIntensityData.add(intensityData);
    }
    if (i > 28) {
      fifthWeekIntensityData.add(intensityData);
    }
  }

  void setAllMultipleWeekIntensityData(int i, double intensityData) {
    if (i <= 7) {
      multipleFirstWeekIntensityData.add(intensityData);
    }
    if (i > 7 && i <= 14) {
      multipleSecondWeekIntensityData.add(intensityData);
    }
    if (i > 14 && i <= 21) {
      multipleThirdWeekIntensityData.add(intensityData);
    }
    if (i > 21 && i <= 28) {
      multipleFourthWeekIntensityData.add(intensityData);
    }
    if (i > 28) {
      multipleFifthWeekIntensityData.add(intensityData);
    }
  }

  void setIntensityValuesData() {
    if (widget.editGraphViewFilterModel.headacheTypeRadioButtonSelected ==
        Constant.viewSingleHeadache) {
      intensityListData = widget
          .editGraphViewFilterModel.recordsTrendsDataModel!.headache!.severity!;
      firstWeekIntensityData = [];
      secondWeekIntensityData = [];
      thirdWeekIntensityData = [];
      fourthWeekIntensityData = [];
      fifthWeekIntensityData = [];

      for (int i = 1; i <= totalDaysInCurrentMonth!; i++) {
        String date;
        String month;
        if (i < 10) {
          date = '0$i';
        } else {
          date = i.toString();
        }
        if (currentMonth !< 10) {
          month = '0$currentMonth';
        } else {
          month = currentMonth.toString();
        }
        DateTime dateTime =
            DateTime.parse('$currentYear-$month-$date 00:00:00.000Z');
        var intensityData = intensityListData.firstWhereOrNull(
            (element) => element.date!.isAtSameMomentAs(dateTime));
        if (intensityData != null) {
          setAllWeekIntensityData(i, intensityData.value!.toDouble());
        } else {
          setAllWeekIntensityData(i, 0);
        }
      }

      print(
          'AllIntensityListData $firstWeekIntensityData $secondWeekIntensityData $thirdWeekIntensityData $fourthWeekIntensityData');

      barGroup1 = makeGroupData(
          0,
          firstWeekIntensityData[0],
          firstWeekIntensityData[1],
          firstWeekIntensityData[2],
          firstWeekIntensityData[3],
          firstWeekIntensityData[4],
          firstWeekIntensityData[5],
          firstWeekIntensityData[6]);
      barGroup2 = makeGroupData(
          1,
          secondWeekIntensityData[0],
          secondWeekIntensityData[1],
          secondWeekIntensityData[2],
          secondWeekIntensityData[3],
          secondWeekIntensityData[4],
          secondWeekIntensityData[5],
          secondWeekIntensityData[6]);
      barGroup3 = makeGroupData(
          2,
          thirdWeekIntensityData[0],
          thirdWeekIntensityData[1],
          thirdWeekIntensityData[2],
          thirdWeekIntensityData[3],
          thirdWeekIntensityData[4],
          thirdWeekIntensityData[5],
          thirdWeekIntensityData[6]);
      barGroup4 = makeGroupData(
          3,
          fourthWeekIntensityData[0],
          fourthWeekIntensityData[1],
          fourthWeekIntensityData[2],
          fourthWeekIntensityData[3],
          fourthWeekIntensityData[4],
          fourthWeekIntensityData[5],
          fourthWeekIntensityData[6]);

      if (totalDaysInCurrentMonth !> 28) {
        if (totalDaysInCurrentMonth == 29) {
          barGroup5 = makeGroupData(
            4,
            fifthWeekIntensityData[0],
            0,
            0,
            0,
            0,
            0,
            0,
          );
        } else if (totalDaysInCurrentMonth == 30) {
          barGroup5 = makeGroupData(
            4,
            fifthWeekIntensityData[0],
            fifthWeekIntensityData[1],
            0,
            0,
            0,
            0,
            0,
          );
        } else {
          barGroup5 = makeGroupData(
            4,
            fifthWeekIntensityData[0],
            fifthWeekIntensityData[1],
            fifthWeekIntensityData[2],
            0,
            0,
            0,
            0,
          );
        }
      }
      if (totalDaysInCurrentMonth !> 28) {
        items = [barGroup1!, barGroup2!, barGroup3!, barGroup4!, barGroup5!];
      } else {
        items = [barGroup1!, barGroup2!, barGroup3!, barGroup4!];
      }

      rawBarGroups = items;
      showingBarGroups = rawBarGroups;
    } else {
      multipleFirstIntensityListData = widget
          .editGraphViewFilterModel
          .recordsTrendsDataModel
          ?.recordsTrendsMultipleHeadacheDataModel
          ?.headacheFirst
          ?.severity;

      multipleSecondIntensityListData = widget
          .editGraphViewFilterModel
          .recordsTrendsDataModel
          ?.recordsTrendsMultipleHeadacheDataModel
          ?.headacheSecond
          ?.severity;

      firstWeekIntensityData = [];
      secondWeekIntensityData = [];
      thirdWeekIntensityData = [];
      fourthWeekIntensityData = [];
      fifthWeekIntensityData = [];

      multipleFirstWeekIntensityData = [];
      multipleSecondWeekIntensityData = [];
      multipleThirdWeekIntensityData = [];
      multipleFourthWeekIntensityData = [];
      multipleFifthWeekIntensityData = [];

      for (int i = 1; i <= totalDaysInCurrentMonth!; i++) {
        String date;
        String month;
        if (i < 10) {
          date = '0$i';
        } else {
          date = i.toString();
        }
        if (currentMonth !< 10) {
          month = '0$currentMonth';
        } else {
          month = currentMonth.toString();
        }
        DateTime dateTime =
            DateTime.parse('$currentYear-$month-$date 00:00:00.000Z');
        var firstIntensityData = multipleFirstIntensityListData?.firstWhereOrNull(
            (element) => element.date!.isAtSameMomentAs(dateTime),);
        if (firstIntensityData != null) {
          setAllWeekIntensityData(i, firstIntensityData.value!.toDouble());
        } else {
          setAllWeekIntensityData(i, 0);
        }
        var secondIntensityData = multipleSecondIntensityListData?.firstWhereOrNull(
            (element) => element.date!.isAtSameMomentAs(dateTime),);
        if (secondIntensityData != null) {
          setAllMultipleWeekIntensityData(
              i, secondIntensityData.value!.toDouble());
        } else {
          setAllMultipleWeekIntensityData(i, 0);
        }
      }
      debugPrint(
          'AllIntensityListData $firstWeekIntensityData $secondWeekIntensityData $thirdWeekIntensityData $fourthWeekIntensityData');

      debugPrint(
          'AllIntensityListData $multipleFirstWeekIntensityData $multipleSecondWeekIntensityData $multipleThirdWeekIntensityData $multipleFourthWeekIntensityData');

      barGroup1 = makeMultipleGroupData(
          0,
          firstWeekIntensityData[0],
          firstWeekIntensityData[1],
          firstWeekIntensityData[2],
          firstWeekIntensityData[3],
          firstWeekIntensityData[4],
          firstWeekIntensityData[5],
          firstWeekIntensityData[6],
          multipleFirstWeekIntensityData[0],
          multipleFirstWeekIntensityData[1],
          multipleFirstWeekIntensityData[2],
          multipleFirstWeekIntensityData[3],
          multipleFirstWeekIntensityData[4],
          multipleFirstWeekIntensityData[5],
          multipleFirstWeekIntensityData[6]);
      barGroup2 = makeMultipleGroupData(
          1,
          secondWeekIntensityData[0],
          secondWeekIntensityData[1],
          secondWeekIntensityData[2],
          secondWeekIntensityData[3],
          secondWeekIntensityData[4],
          secondWeekIntensityData[5],
          secondWeekIntensityData[6],
          multipleSecondWeekIntensityData[0],
          multipleSecondWeekIntensityData[1],
          multipleSecondWeekIntensityData[2],
          multipleSecondWeekIntensityData[3],
          multipleSecondWeekIntensityData[4],
          multipleSecondWeekIntensityData[5],
          multipleSecondWeekIntensityData[6]);
      barGroup3 = makeMultipleGroupData(
          2,
          thirdWeekIntensityData[0],
          thirdWeekIntensityData[1],
          thirdWeekIntensityData[2],
          thirdWeekIntensityData[3],
          thirdWeekIntensityData[4],
          thirdWeekIntensityData[5],
          thirdWeekIntensityData[6],
          multipleThirdWeekIntensityData[0],
          multipleThirdWeekIntensityData[1],
          multipleThirdWeekIntensityData[2],
          multipleThirdWeekIntensityData[3],
          multipleThirdWeekIntensityData[4],
          multipleThirdWeekIntensityData[5],
          multipleThirdWeekIntensityData[6]);
      barGroup4 = makeMultipleGroupData(
          3,
          fourthWeekIntensityData[0],
          fourthWeekIntensityData[1],
          fourthWeekIntensityData[2],
          fourthWeekIntensityData[3],
          fourthWeekIntensityData[4],
          fourthWeekIntensityData[5],
          fourthWeekIntensityData[6],
          multipleFourthWeekIntensityData[0],
          multipleFourthWeekIntensityData[1],
          multipleFourthWeekIntensityData[2],
          multipleFourthWeekIntensityData[3],
          multipleFourthWeekIntensityData[4],
          multipleFourthWeekIntensityData[5],
          multipleFourthWeekIntensityData[6]);

      if (totalDaysInCurrentMonth !> 28) {
        if (totalDaysInCurrentMonth == 29) {
          barGroup5 = makeMultipleGroupData(
            4,
            fifthWeekIntensityData[0],
            0,
            0,
            0,
            0,
            0,
            0,
            multipleFifthWeekIntensityData[0],
            0,
            0,
            0,
            0,
            0,
            0,
          );
        } else if (totalDaysInCurrentMonth == 30) {
          barGroup5 = makeMultipleGroupData(
            4,
            fifthWeekIntensityData[0],
            fifthWeekIntensityData[1],
            0,
            0,
            0,
            0,
            0,
            multipleFifthWeekIntensityData[0],
            multipleFifthWeekIntensityData[1],
            0,
            0,
            0,
            0,
            0,
          );
        } else {
          barGroup5 = makeMultipleGroupData(
            4,
            fifthWeekIntensityData[0],
            fifthWeekIntensityData[1],
            fifthWeekIntensityData[2],
            0,
            0,
            0,
            0,
            multipleFifthWeekIntensityData[0],
            multipleFifthWeekIntensityData[1],
            multipleFifthWeekIntensityData[2],
            0,
            0,
            0,
            0,
          );
        }
      }
    }
    if (totalDaysInCurrentMonth !> 28) {
      items = [barGroup1!, barGroup2!, barGroup3!, barGroup4!, barGroup5!];
    } else {
      items = [barGroup1!, barGroup2!, barGroup3!, barGroup4!];
    }

    rawBarGroups = items;
    showingBarGroups = rawBarGroups;
  }

  List<Widget> _getDots(TrendsFilterModel trendsFilterModel) {
    List<Widget> dotsList = [];

    for (int i = 1;
        i <= widget.editGraphViewFilterModel.numberOfDaysInMonth;
        i++) {
      var dotData = trendsFilterModel.occurringDateList
          !.firstWhereOrNull((element) => element.day == i);

      dotsList.add(Expanded(
        child: Container(
          height: 10,
          child: Center(
            child: Icon(
              dotData != null ? Icons.circle : Icons.brightness_1_outlined,
              size: 8,
              color: Constant.locationServiceGreen,
            ),
          ),
        ),
      ));
    }
    return dotsList;
  }

  @override
  bool get wantKeepAlive => true;

  List<Widget> getDotText() {
    List<Widget> widgetListData = [];
    List<TrendsFilterModel> dotTextModelDataList = [];
    if (widget.editGraphViewFilterModel.whichOtherFactorSelected ==
        Constant.loggedBehaviors) {
      dotTextModelDataList = widget
          .editGraphViewFilterModel.trendsFilterListModel!.behavioursListData;
    } else if (widget.editGraphViewFilterModel.whichOtherFactorSelected ==
        Constant.loggedPotentialTriggers) {
      dotTextModelDataList = widget
          .editGraphViewFilterModel.trendsFilterListModel!.triggersListData;
    } else {
      dotTextModelDataList = widget
          .editGraphViewFilterModel.trendsFilterListModel!.medicationListData;
    }
    for (int i = 0; i < dotTextModelDataList.length; i++) {
      if (i > 2) {
        break;
      }
      widgetListData.add(
        CustomTextWidget(
          text: dotTextModelDataList[i].dotName!,
          style: TextStyle(
            color: Constant.locationServiceGreen,
            fontSize: 12,
            fontFamily: Constant.jostRegular,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
      widgetListData.add(SizedBox(
        height: 6,
      ));
    }
    return widgetListData;
  }

  List<Widget> getDotsWidget() {
    List<Widget> widgetListData = [];
    List<TrendsFilterModel> dotTextModelDataList;
    if (widget.editGraphViewFilterModel.whichOtherFactorSelected ==
        Constant.loggedBehaviors) {
      dotTextModelDataList = widget
          .editGraphViewFilterModel.trendsFilterListModel!.behavioursListData;
    } else if (widget.editGraphViewFilterModel.whichOtherFactorSelected ==
        Constant.loggedPotentialTriggers) {
      dotTextModelDataList = widget
          .editGraphViewFilterModel.trendsFilterListModel!.triggersListData;
    } else {
      dotTextModelDataList = widget
          .editGraphViewFilterModel.trendsFilterListModel!.medicationListData;
    }
    for (int i = 0; i < dotTextModelDataList.length; i++) {
      if (i > 2) {
        break;
      }
      widgetListData.add(Container(
        padding: const EdgeInsets.only(left: 5, right: 10),
        child: Row(
          children: _getDots(dotTextModelDataList[i]),
        ),
      ));
      widgetListData.add(SizedBox(
        height: 14,
      ));
    }
    return widgetListData;
  }

  List<BarChartRodStackItem> setRodStack(
      double firstMultipleHeadache1, double secondMultipleHeadache1) {
    //var maxValue, minValue = 0.0;
    if (firstMultipleHeadache1 >= secondMultipleHeadache1) {
      /*maxValue = firstMultipleHeadache1;
      minValue = secondMultipleHeadache1;*/
      return [
        BarChartRodStackItem(0, secondMultipleHeadache1, Constant.migraineColor),
        BarChartRodStackItem(secondMultipleHeadache1, firstMultipleHeadache1, Constant.otherHeadacheColor),
      ];
    } else {
      /*minValue = firstMultipleHeadache1;
      maxValue = secondMultipleHeadache1;*/
      return [
        BarChartRodStackItem(0, firstMultipleHeadache1, Constant.otherHeadacheColor),
        BarChartRodStackItem(firstMultipleHeadache1, secondMultipleHeadache1, Constant.migraineColor),
      ];
    }
    /*return [
      BarChartRodStackItem(0, minValue, Constant.otherHeadacheColor),
      BarChartRodStackItem(minValue, maxValue, Constant.migraineColor),
    ];*/
  }

  double setAxisValue(
      double firstMultipleHeadache1, double secondMultipleHeadache1) {
    var maxValue;
    if (firstMultipleHeadache1 >= secondMultipleHeadache1) {
      maxValue = firstMultipleHeadache1;
    } else {
      maxValue = secondMultipleHeadache1;
    }
    return maxValue;
  }

  Color setHeadacheColor() {
    if (firstWeekIntensityData.length > 0 &&
        multipleFirstWeekIntensityData.length > 0) {
        var firstHeadacheWeekMaxValue = firstWeekIntensityData
            .reduce((curr, next) => curr > next ? curr : next);
        print('Maximum ListData Value $firstHeadacheWeekMaxValue');

        var secondHeadacheWeekMaxValue = multipleFirstWeekIntensityData
            .reduce((curr, next) => curr > next ? curr : next);
        print('Maximum ListData Value $secondHeadacheWeekMaxValue');
      if (firstHeadacheWeekMaxValue >= secondHeadacheWeekMaxValue) {
        headacheColorChanged = true;
        return Constant.migraineColor;
      } else {
        headacheColorChanged = false;
        return Constant.otherHeadacheColor;
      }
    } else
      return Colors.transparent;
  }

  setToolTipTextColor() {
    if (widget.editGraphViewFilterModel.headacheTypeRadioButtonSelected ==
        Constant.viewSingleHeadache) {
      if (clickedValue != null) {
        if (clickedValue == 0) {
          return Colors.transparent;
        } else
          return Colors.white;
      }
    } else {
      if (clickedValue != null) {
        if (clickedValue == 0) {
          return Colors.transparent;
        } else
          return Colors.black;
      }
    }
  }

  String getHorizontalTileText(double value){
    switch (value.toInt()) {
      case 0:
        return 'Week 1';
      case 1:
        return 'Week 2';
      case 2:
        return 'Week 3';
      case 3:
        return 'Week 4';
      case 4:
        if (totalDaysInCurrentMonth !> 28) {
          return 'Week 5';
        }
        return '';
      case 5:
        return 'St';
      case 6:
        return 'Sn';
      default:
        return '';
    }
  }

  String getVerticalTileText(double value){
    if (value == 0) {
      return '0';
    } else if (value == 2) {
      return '2';
    } else if (value == 4) {
      return '4';
    } else if (value == 6) {
      return '6';
    } else if (value == 8) {
      return '8';
    } else if (value == 10) {
      return '10';
    } else {
      return '';
    }
  }
}
