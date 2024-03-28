import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/EditGraphViewFilterModel.dart';
import 'package:mobile/models/RecordsTrendsDataModel.dart';
import 'package:mobile/util/MonthYearCupertinoDatePicker.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'CustomTextWidget.dart';
import 'package:mobile/models/TrendsFilterModel.dart';
import 'package:mobile/models/RecordsTrendsMultipleHeadacheDataModel.dart';

import 'package:collection/collection.dart';

class TrendsFrequencyScreen extends StatefulWidget {
  final EditGraphViewFilterModel editGraphViewFilterModel;
  final Function updateTrendsDataCallback;
  final Future<DateTime> Function (MonthYearCupertinoDatePickerMode, Function, DateTime) openDatePickerCallback;

  const TrendsFrequencyScreen(
      {Key? key, required this.editGraphViewFilterModel, required this.updateTrendsDataCallback, required this.openDatePickerCallback})
      : super(key: key);

  @override
  _TrendsFrequencyScreenState createState() => _TrendsFrequencyScreenState();
}

class _TrendsFrequencyScreenState extends State<TrendsFrequencyScreen> {
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
  List<Ity> frequencyListData = [];
  List<Data>? multipleFirstFrequencyListData = [];
  List<Data>? multipleSecondFrequencyListData = [];
  List<BarChartGroupData>? items;

  List<double> multipleFirstWeekFrequencyData = [];
  List<double> multipleSecondWeekFrequencyData = [];
  List<double> multipleThirdWeekFrequencyData = [];
  List<double> multipleFourthWeekFrequencyData = [];
  List<double> multipleFifthWeekFrequencyData = [];

  BarChartGroupData? barGroup2;
  BarChartGroupData? barGroup1;
  BarChartGroupData? barGroup3;
  BarChartGroupData? barGroup4;
  BarChartGroupData? barGroup5;
  List<double> firstWeekFrequencyData = [];
  List<double> secondWeekFrequencyData = [];
  List<double> thirdWeekFrequencyData = [];
  List<double> fourthWeekFrequencyData = [];
  List<double> fifthWeekFrequencyData = [];
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

    setFrequencyValuesData();
  }

  @override
  void didUpdateWidget(covariant TrendsFrequencyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    setFrequencyValuesData();
  }

  @override
  Widget build(BuildContext context) {
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
                  width: totalDaysInCurrentMonth !<= 28 ? 350 : 420,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            SizedBox(
                              height: 120,
                              child: Transform.rotate(
                                angle: -1.5708,
                                child: Text(
                                  'Headache Frequency (Times)',
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
                            minY: 0,
                            maxY: 5,
                            groupsSpace: 10,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                  tooltipBgColor: setToolTipColor(),
                                  tooltipPadding:
                                      EdgeInsets.symmetric(horizontal: 13, vertical: 1),
                                  tooltipRoundedRadius: 20,
                                  //tooltipBottomMargin: 10,
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    String weekDay =
                                        '${Utils.getShortMonthName(_dateTime!.month)} ${(groupIndex * 7) + rodIndex + 1}';
                                    String barTooltipTimeSuffix = (rod.toY.toInt() < 2) ? ' Time' : ' Times';
                                    return BarTooltipItem(
                                        weekDay +
                                            '\n' +
                                            (rod.toY.toInt()).toString() +
                                            barTooltipTimeSuffix,
                                        TextStyle(
                                            color: setToolTipTextColor(),
                                            fontFamily: 'JostRegular',
                                            fontSize: 12));
                                  },
                                  fitInsideHorizontally: true,
                                  fitInsideVertically: true),
                              touchCallback: (event, response) {
                                if (response?.spot != null) {
                                  if (response?.spot!.spot != null) {
                                    if (response?.spot!.spot.y != null) {
                                      setState(() {
                                        clickedValue = response?.spot!.spot.y.toInt();
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
                              drawHorizontalLine: true,
                              checkToShowHorizontalLine: (value) => value % 1 == 0,
                              getDrawingHorizontalLine: (value) {
                                if (value == 0) {
                                  return FlLine(
                                      color: const Color(0x800E4C47), strokeWidth: 1);
                                } else {
                                  return FlLine(
                                      color: const Color(0x800E4C47), strokeWidth: 1);
                                }
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
                              reservedSize: 10,
                              getTitlesWidget: (val, meta){
                              return Text(
                                getVerticalTileText(val),
                                style: const TextStyle(
                                    color: Color(0xffCAD7BF),
                                    fontFamily: 'JostRegular',
                                    fontSize: 10)
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
                    height: 5,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
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
                          padding: const EdgeInsets.only(top: 12),
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
                          /*widget.editGraphViewFilterModel.recordsTrendsDataModel
                                      .headacheListModelData.length >
                                  0
                              ? widget
                                  .editGraphViewFilterModel
                                  .recordsTrendsDataModel
                                  .headacheListModelData[0]
                                  .text
                              : ''*/
                          text:  widget.editGraphViewFilterModel.compareHeadacheTypeSelected1 ?? Constant.blankString,
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
                            color: /*headacheColorChanged
                                ? Constant.migraineColor
                                : Constant.otherHeadacheColor*/
                            Constant.migraineColor,
                            shape: BoxShape.rectangle,
                          ),
                          height: 13,
                          width: 13,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        CustomTextWidget(
                          /*widget.editGraphViewFilterModel.recordsTrendsDataModel
                                      .headacheListModelData.length >
                                  1
                              ? widget
                                  .editGraphViewFilterModel
                                  .recordsTrendsDataModel
                                  .headacheListModelData[1]
                                  .text
                              : ''*/
                          text:  widget.editGraphViewFilterModel.compareHeadacheTypeSelected2 ?? Constant.blankString,
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
    var resultFromActionSheet = await widget.openDatePickerCallback(MonthYearCupertinoDatePickerMode.date, _getDateTimeCallbackFunction(0)!, _dateTime!);

    if(resultFromActionSheet is DateTime)
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
    if(clickedValue != null){
      if(clickedValue !> 0){
        return Constant.migraineColor;
      }else return Colors.transparent;
    }else return Colors.transparent;
  }

//3315662,4d7483,658c9f,82aac0,99c1db
  Color setBarChartColor(double barChartValue) {
    return Constant.migraineColor;
  }

  void setFrequencyValuesData() {
    if (widget.editGraphViewFilterModel.headacheTypeRadioButtonSelected ==
        Constant.viewSingleHeadache) {
      frequencyListData = widget
          .editGraphViewFilterModel.recordsTrendsDataModel!.headache!.frequency!;
      firstWeekFrequencyData = [];
      secondWeekFrequencyData = [];
      thirdWeekFrequencyData = [];
      fourthWeekFrequencyData = [];
      fifthWeekFrequencyData = [];

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
        var intensityData = frequencyListData.firstWhereOrNull(
            (element) => element.date!.isAtSameMomentAs(dateTime),);
        if (intensityData != null) {
          setAllWeekIntensityData(i, intensityData.value!.toDouble());
        } else {
          setAllWeekIntensityData(i, 0);
        }
      }

      print(
          'AllIntensityListData $firstWeekFrequencyData $secondWeekFrequencyData $thirdWeekFrequencyData $fourthWeekFrequencyData');

      barGroup1 = makeGroupData(
          0,
          firstWeekFrequencyData[0],
          firstWeekFrequencyData[1],
          firstWeekFrequencyData[2],
          firstWeekFrequencyData[3],
          firstWeekFrequencyData[4],
          firstWeekFrequencyData[5],
          firstWeekFrequencyData[6]);
      barGroup2 = makeGroupData(
          1,
          secondWeekFrequencyData[0],
          secondWeekFrequencyData[1],
          secondWeekFrequencyData[2],
          secondWeekFrequencyData[3],
          secondWeekFrequencyData[4],
          secondWeekFrequencyData[5],
          secondWeekFrequencyData[6]);
      barGroup3 = makeGroupData(
          2,
          thirdWeekFrequencyData[0],
          thirdWeekFrequencyData[1],
          thirdWeekFrequencyData[2],
          thirdWeekFrequencyData[3],
          thirdWeekFrequencyData[4],
          thirdWeekFrequencyData[5],
          thirdWeekFrequencyData[6]);
      barGroup4 = makeGroupData(
          3,
          fourthWeekFrequencyData[0],
          fourthWeekFrequencyData[1],
          fourthWeekFrequencyData[2],
          fourthWeekFrequencyData[3],
          fourthWeekFrequencyData[4],
          fourthWeekFrequencyData[5],
          fourthWeekFrequencyData[6]);

      if (totalDaysInCurrentMonth !> 28) {
        if(totalDaysInCurrentMonth == 29) {
          barGroup5 = makeGroupData(
            4,
            fifthWeekFrequencyData[0],
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
            fifthWeekFrequencyData[0],
            fifthWeekFrequencyData[1],
            0,
            0,
            0,
            0,
            0,
          );
        } else {
          barGroup5 = makeGroupData(
            4,
            fifthWeekFrequencyData[0],
            fifthWeekFrequencyData[1],
            fifthWeekFrequencyData[2],
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
      multipleFirstFrequencyListData = widget
          .editGraphViewFilterModel
          .recordsTrendsDataModel
          ?.recordsTrendsMultipleHeadacheDataModel
          ?.headacheFirst
          ?.frequency;
      multipleSecondFrequencyListData = widget
          .editGraphViewFilterModel
          .recordsTrendsDataModel
          ?.recordsTrendsMultipleHeadacheDataModel
          ?.headacheSecond
          ?.frequency;

      firstWeekFrequencyData = [];
      secondWeekFrequencyData = [];
      thirdWeekFrequencyData = [];
      fourthWeekFrequencyData = [];
      fifthWeekFrequencyData = [];

      multipleFirstWeekFrequencyData = [];
      multipleSecondWeekFrequencyData = [];
      multipleThirdWeekFrequencyData = [];
      multipleFourthWeekFrequencyData = [];
      multipleFifthWeekFrequencyData = [];

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
        var firstIntensityData = multipleFirstFrequencyListData?.firstWhereOrNull(
            (element) => element.date!.isAtSameMomentAs(dateTime));
        if (firstIntensityData != null) {
          setAllWeekIntensityData(i, firstIntensityData.value!.toDouble());
        } else {
          setAllWeekIntensityData(i, 0);
        }
        var secondIntensityData = multipleSecondFrequencyListData?.firstWhereOrNull(
            (element) => element.date!.isAtSameMomentAs(dateTime));
        if (secondIntensityData != null) {
          setAllMultipleWeekDisabilityData(
              i, secondIntensityData.value!.toDouble());
        } else {
          setAllMultipleWeekDisabilityData(i, 0);
        }
      }
      print(
          'AllDisabilityListData $firstWeekFrequencyData $secondWeekFrequencyData $thirdWeekFrequencyData $fourthWeekFrequencyData');

      print(
          'AllMultipleDisabilityListData $multipleFirstWeekFrequencyData $multipleSecondWeekFrequencyData $multipleThirdWeekFrequencyData $multipleFourthWeekFrequencyData');

      barGroup1 = makeMultipleGroupData(
          0,
          firstWeekFrequencyData[0],
          firstWeekFrequencyData[1],
          firstWeekFrequencyData[2],
          firstWeekFrequencyData[3],
          firstWeekFrequencyData[4],
          firstWeekFrequencyData[5],
          firstWeekFrequencyData[6],
          multipleFirstWeekFrequencyData[0],
          multipleFirstWeekFrequencyData[1],
          multipleFirstWeekFrequencyData[2],
          multipleFirstWeekFrequencyData[3],
          multipleFirstWeekFrequencyData[4],
          multipleFirstWeekFrequencyData[5],
          multipleFirstWeekFrequencyData[6]);
      barGroup2 = makeMultipleGroupData(
          1,
          secondWeekFrequencyData[0],
          secondWeekFrequencyData[1],
          secondWeekFrequencyData[2],
          secondWeekFrequencyData[3],
          secondWeekFrequencyData[4],
          secondWeekFrequencyData[5],
          secondWeekFrequencyData[6],
          multipleSecondWeekFrequencyData[0],
          multipleSecondWeekFrequencyData[1],
          multipleSecondWeekFrequencyData[2],
          multipleSecondWeekFrequencyData[3],
          multipleSecondWeekFrequencyData[4],
          multipleSecondWeekFrequencyData[5],
          multipleSecondWeekFrequencyData[6]);
      barGroup3 = makeMultipleGroupData(
          2,
          thirdWeekFrequencyData[0],
          thirdWeekFrequencyData[1],
          thirdWeekFrequencyData[2],
          thirdWeekFrequencyData[3],
          thirdWeekFrequencyData[4],
          thirdWeekFrequencyData[5],
          thirdWeekFrequencyData[6],
          multipleThirdWeekFrequencyData[0],
          multipleThirdWeekFrequencyData[1],
          multipleThirdWeekFrequencyData[2],
          multipleThirdWeekFrequencyData[3],
          multipleThirdWeekFrequencyData[4],
          multipleThirdWeekFrequencyData[5],
          multipleThirdWeekFrequencyData[6]);
      barGroup4 = makeMultipleGroupData(
          3,
          fourthWeekFrequencyData[0],
          fourthWeekFrequencyData[1],
          fourthWeekFrequencyData[2],
          fourthWeekFrequencyData[3],
          fourthWeekFrequencyData[4],
          fourthWeekFrequencyData[5],
          fourthWeekFrequencyData[6],
          multipleFourthWeekFrequencyData[0],
          multipleFourthWeekFrequencyData[1],
          multipleFourthWeekFrequencyData[2],
          multipleFourthWeekFrequencyData[3],
          multipleFourthWeekFrequencyData[4],
          multipleFourthWeekFrequencyData[5],
          multipleFourthWeekFrequencyData[6]);

      if (totalDaysInCurrentMonth !> 28) {
        if(totalDaysInCurrentMonth == 29) {
          barGroup5 = makeMultipleGroupData(
            4,
            fifthWeekFrequencyData[0],
            0,
            0,
            0,
            0,
            0,
            0,
            multipleFifthWeekFrequencyData[0],
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
            fifthWeekFrequencyData[0],
            fifthWeekFrequencyData[1],
            0,
            0,
            0,
            0,
            0,
            multipleFifthWeekFrequencyData[0],
            multipleFifthWeekFrequencyData[1],
            0,
            0,
            0,
            0,
            0,
          );
        } else {
          barGroup5 = makeMultipleGroupData(
            4,
            fifthWeekFrequencyData[0],
            fifthWeekFrequencyData[1],
            fifthWeekFrequencyData[2],
            0,
            0,
            0,
            0,
            multipleFifthWeekFrequencyData[0],
            multipleFifthWeekFrequencyData[1],
            multipleFifthWeekFrequencyData[2],
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

  void setAllWeekIntensityData(int i, double intensityData) {
    if (i <= 7) {
      firstWeekFrequencyData.add(intensityData);
    }
    if (i > 7 && i <= 14) {
      secondWeekFrequencyData.add(intensityData);
    }
    if (i > 14 && i <= 21) {
      thirdWeekFrequencyData.add(intensityData);
    }
    if (i > 21 && i <= 28) {
      fourthWeekFrequencyData.add(intensityData);
    }
    if (i > 28) {
      fifthWeekFrequencyData.add(intensityData);
    }
  }

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
              fontFamily: Constant.jostRegular),
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
      widgetListData.add(Padding(
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

  void setAllMultipleWeekDisabilityData(int i, double intensityData) {
    if (i <= 7) {
      multipleFirstWeekFrequencyData.add(intensityData);
    }
    if (i > 7 && i <= 14) {
      multipleSecondWeekFrequencyData.add(intensityData);
    }
    if (i > 14 && i <= 21) {
      multipleThirdWeekFrequencyData.add(intensityData);
    }
    if (i > 21 && i <= 28) {
      multipleFourthWeekFrequencyData.add(intensityData);
    }
    if (i > 28) {
      multipleFifthWeekFrequencyData.add(intensityData);
    }
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

  List<BarChartRodStackItem> setRodStack(
      double firstMultipleHeadache1, double secondMultipleHeadache1) {
    if (firstMultipleHeadache1 >= secondMultipleHeadache1) {
      return [
        BarChartRodStackItem(0, secondMultipleHeadache1, Constant.migraineColor),
        BarChartRodStackItem(secondMultipleHeadache1, firstMultipleHeadache1, Constant.otherHeadacheColor),
      ];
    } else {
      return [
        BarChartRodStackItem(0, firstMultipleHeadache1, Constant.otherHeadacheColor),
        BarChartRodStackItem(firstMultipleHeadache1, secondMultipleHeadache1, Constant.migraineColor),
      ];
    }
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
    if (firstWeekFrequencyData.length > 0 &&
        multipleFirstWeekFrequencyData.length > 0) {
      if (firstWeekFrequencyData[0] >= multipleFirstWeekFrequencyData[0]) {
        headacheColorChanged = true;
        return Constant.otherHeadacheColor;
      } else {
        headacheColorChanged = false;
        return Constant.migraineColor;
      }
    } else
      return Colors.transparent;
  }

  setToolTipTextColor() {
    if (clickedValue != null) {
      if (clickedValue == 0) {
        return Colors.transparent;
      } else
        return Colors.black;
    }
  }

  String getHorizontalTileText(double value) {
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

  String getVerticalTileText(double value) {
    if (value == 0) {
      return '0';
    } else if (value == 1) {
      return '1';
    } else if (value == 2) {
      return '2';
    } else if (value == 3) {
      return '3';
    } else if (value == 4) {
      return '4';
    } else if (value == 5) {
      return '5';
    }  else {
      return '';
    }
  }
}
