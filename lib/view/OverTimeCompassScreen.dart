import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile/blocs/RecordsCompassScreenBloc.dart';
import 'package:mobile/models/CompassTutorialModel.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/HeadacheListDataModel.dart';
import 'package:mobile/models/RecordsOverTimeCompassModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/MonthYearCupertinoDatePicker.dart';
import 'package:mobile/util/RadarChart.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/models/RecordsCompassAxesResultModel.dart';
import 'package:mobile/view/CompassHeadacheTypeActionSheet.dart';
import 'package:mobile/view/CustomRichTextWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CompassScreen.dart';

class OverTimeCompassScreen extends StatefulWidget {
  final Future<dynamic> Function(String, dynamic) openActionSheetCallback;
  final Function(Stream, Function) showApiLoaderCallback;
  final Future<dynamic> Function(String, dynamic) navigateToOtherScreenCallback;
  final Future<DateTime> Function(MonthYearCupertinoDatePickerMode, Function, DateTime)
      openDatePickerCallback;

  const OverTimeCompassScreen(
      {Key? key,
      required this.openActionSheetCallback,
      required this.showApiLoaderCallback,
      required this.navigateToOtherScreenCallback,
      required this.openDatePickerCallback})
      : super(key: key);

  @override
  _OverTimeCompassScreenState createState() => _OverTimeCompassScreenState();
}

class _OverTimeCompassScreenState extends State<OverTimeCompassScreen>
    with AutomaticKeepAliveClientMixin {
  late RecordsCompassScreenBloc _recordsCompassScreenBloc;
  bool darkMode = false;
  double numberOfFeatures = 4;
  late DateTime _dateTime;
  late int currentMonth;
  late int currentYear;
  late String monthName;
  late int totalDaysInCurrentMonth;
  late String firstDayOfTheCurrentMonth;
  late String lastDayOfTheCurrentMonth;

  CurrentUserHeadacheModel? currentUserHeadacheModel;

  late List<List<int>> compassAxesData;

  late List<int> ticks;

  late List<String> features;
  String? selectedHeadacheName;
  String? lastSelectedHeadacheName;

  String? currentSelectedHeadacheName;

  int? userCurrentMonthScoreData;
  int userPreviousMonthScoreData = 0;
  String headacheDownOrUp = '';
  String increaseOrDecrease = '';
  //String anOra = '';

  double currentIntensityValue = 0;
  double currentDisabilityValue = 0;
  double currentFrequencyValue = 0;
  double currentDurationValue = 0;

  double previousIntensityValue = 0;
  double previousDisabilityValue = 0;
  double previousFrequencyValue = 0;
  double previousDurationValue = 0;

  late CompassTutorialModel _compassTutorialModel;

  List<TextSpan> _getBubbleTextSpans() {
    List<TextSpan> list = [];
    list.add(TextSpan(
        text: 'Your Headache Score for $monthName was ',
        style: TextStyle(
            height: 1.3,
            fontSize: 14,
            fontFamily: Constant.jostRegular,
            color: Constant.chatBubbleGreen)));
    list.add(TextSpan(
        text: userCurrentMonthScoreData.toString(),
        style: TextStyle(
            height: 1.3,
            fontSize: 14,
            fontFamily: Constant.jostRegular,
            color: Constant.addCustomNotificationTextColor)));
    list.add(TextSpan(
        text: ' $headacheDownOrUp from ',
        style: TextStyle(
            height: 1.3,
            fontSize: 14,
            fontFamily: Constant.jostRegular,
            color: Constant.chatBubbleGreen)));
    list.add(TextSpan(
        text: userPreviousMonthScoreData.toString(),
        style: TextStyle(
            height: 1.3,
            fontSize: 14,
            fontFamily: Constant.jostRegular,
            color: Constant.addCustomNotificationTextColor)));
    list.add(TextSpan(
        text: ' last month. This was primarily due to ',
        style: TextStyle(
            height: 1.3,
            fontSize: 14,
            fontFamily: Constant.jostRegular,
            color: Constant.chatBubbleGreen)));
    list.add(TextSpan(
        text: '$increaseOrDecrease',
        style: TextStyle(
            height: 1.3,
            fontSize: 14,
            fontFamily: Constant.jostRegular,
            color: Constant.addCustomNotificationTextColor)));

    return list;
  }

  @override
  void initState() {
    super.initState();
    ticks = [2, 4, 6, 8, 10];

    _compassTutorialModel = CompassTutorialModel();

    features = [
      "A",
      "B",
      "C",
      "D",
    ];
    compassAxesData = [
      [14, 15, 7, 7]
    ];
    updateActionSheet();
    _recordsCompassScreenBloc = RecordsCompassScreenBloc();
    _dateTime = DateTime.now();
    currentMonth = _dateTime.month;
    currentYear = _dateTime.year;
    monthName = Utils.getMonthName(currentMonth);
    totalDaysInCurrentMonth =
        Utils.daysInCurrentMonth(currentMonth, currentYear);
    firstDayOfTheCurrentMonth = Utils.firstDateWithCurrentMonthAndTimeInUTC(
        currentMonth, currentYear, 1);
    lastDayOfTheCurrentMonth = Utils.lastDateWithCurrentMonthAndTimeInUTC(
        currentMonth, currentYear, totalDaysInCurrentMonth);
    debugPrint('init state of overTime compass');
    _recordsCompassScreenBloc.initNetworkStreamController();
    _removeDataFromSharedPreference();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _showApiLoaderDialog();
      requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
          selectedHeadacheName);
    });
    _compassTutorialModel.currentDateTime = _dateTime;
  }

  Future<void> updateActionSheet() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(Constant.updateCompassHeadacheList, Constant.falseString);
  }

  @override
  void didUpdateWidget(covariant OverTimeCompassScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _getUserCurrentHeadacheData();
    _updateCompassData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: StreamBuilder<dynamic>(
          stream: _recordsCompassScreenBloc.recordsCompassDataStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == Constant.noHeadacheData) {
                return Consumer<CompassScreenUpdateInfo>(
                  builder: (context, data, child){
                    if(data.getUpdateOverTimeScreenInfo){
                      data.updateOverTimeScreenInfo(false);
                      _updateCompassData();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 150,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CustomTextWidget(
                              text: 'We noticed you didn’t log any headache yet. So please add any headache to see your OverTime Compass data.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  height: 1.3,
                                  fontSize: 14,
                                  fontFamily: Constant.jostRegular,
                                  color: Constant.chatBubbleGreen)),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BouncingWidget(
                              onPressed: () async {
                                await widget.navigateToOtherScreenCallback(Constant.addNewHeadacheIntroScreen, Constant.compassScreenRouter);

                                SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                                String updateOverTimeValue = sharedPreferences.getString(Constant.updateOverTimeCompassData) ?? Constant.falseString;
                                String updateCompareValue = sharedPreferences.getString(Constant.updateCompareCompassData) ?? Constant.falseString;

                                if(updateOverTimeValue == Constant.trueString){
                                  if(updateCompareValue == Constant.trueString){
                                    data.updateCompareScreenInfo(true);
                                  }
                                  _recordsCompassScreenBloc.initNetworkStreamController();
                                  _updateCompassData();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Constant.chatBubbleGreen,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: CustomTextWidget(
                                    text: '+ Add a headache type',
                                    style: TextStyle(
                                        color: Constant.bubbleChatTextView,
                                        fontSize: 15,
                                        fontFamily: Constant.jostMedium),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                );
              }
              else if(snapshot.data is RecordsOverTimeCompassModel) {
                _compassTutorialModel.currentDateTime = _dateTime;
                if (selectedHeadacheName == null) {
                  List<HeadacheListDataModel> headacheListModelData =
                      snapshot.data.headacheListDataModel;
                  currentSelectedHeadacheName = headacheListModelData[headacheListModelData.length-1].text;
                  selectedHeadacheName = headacheListModelData[headacheListModelData.length-1].text;
                }
                setCompassAxesData(snapshot.data);
                if (userPreviousMonthScoreData < userCurrentMonthScoreData!) {
                  //anOra = 'an';
                  headacheDownOrUp = 'up';
                  setTextValue(1);
                } else if (userPreviousMonthScoreData > userCurrentMonthScoreData!) {
                  //anOra = 'a';
                  headacheDownOrUp = 'down';
                  setTextValue(0);
                } else {
                  //anOra = 'a';
                  headacheDownOrUp = 'same';
                  setTextValue(2);
                }
                return Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          _openHeadacheTypeActionSheet(
                              snapshot.data.headacheListDataModel);
                        },
                        child: Card(
                          elevation: 4,
                          color: Colors.transparent,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          semanticContainer: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 3, horizontal: 30),
                            decoration: BoxDecoration(
                              color: Constant.compassMyHeadacheTextColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CustomTextWidget(
                              text: currentSelectedHeadacheName != null
                                  ? currentSelectedHeadacheName ?? snapshot.data.headacheListDataModel[snapshot.data.headacheListDataModel.length-1].text
                                  : snapshot.data.headacheListDataModel[snapshot.data.headacheListDataModel.length-1].text,
                              style: TextStyle(
                                  color: Constant.locationServiceGreen,
                                  fontSize: 16,
                                  fontFamily: Constant.jostRegular),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Stack(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Utils.showCompassTutorialDialog(context, 0,
                                  compassTutorialModel: _compassTutorialModel);
                            },
                            child: Container(
                              alignment: Alignment.topRight,
                              margin: EdgeInsets.only(left: 65, top: 10),
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Constant.chatBubbleGreen,
                                      width: 1)),
                              child: Center(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    Utils.showCompassTutorialDialog(context, 0,
                                        compassTutorialModel:
                                            _compassTutorialModel);
                                  },
                                  child: CustomTextWidget(
                                    text: 'i',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Constant.chatBubbleGreen,
                                        fontFamily: Constant.jostBold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RotatedBox(
                                quarterTurns: 3,
                                child: GestureDetector(
                                  onTap: () {
                                    Utils.showCompassTutorialDialog(context, 3,
                                        compassTutorialModel:
                                            _compassTutorialModel);
                                  },
                                  child: CustomTextWidget(
                                    text: "Frequency",
                                    style: TextStyle(
                                        color: Color(0xffafd794),
                                        fontSize: 16,
                                        fontFamily: Constant.jostMedium),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Utils.showCompassTutorialDialog(
                                          context, 1,
                                          compassTutorialModel:
                                              _compassTutorialModel);
                                    },
                                    child: CustomTextWidget(
                                      text: "Intensity",
                                      style: TextStyle(
                                          color: Color(0xffafd794),
                                          fontSize: 16,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      width: 220,
                                      height: 220,
                                      child: Center(
                                        child: Stack(
                                          children: <Widget>[
                                            Container(
                                              child: darkMode
                                                  ? RadarChart.dark(
                                                      ticks: ticks,
                                                      features: features,
                                                      data: compassAxesData,
                                                      reverseAxis: false,
                                                      compassValue: 1,
                                                    )
                                                  : RadarChart.light(
                                                      ticks: ticks,
                                                      features: features,
                                                      data: compassAxesData,
                                                      outlineColor: Constant
                                                          .chatBubbleGreen
                                                          .withOpacity(0.5),
                                                      reverseAxis: false,
                                                      compassValue: 1,
                                                    ),
                                            ),
                                            Center(
                                              child: Container(
                                                width: 38,
                                                height: 38,
                                                child: Center(
                                                  child: CustomTextWidget(
                                                    text: userCurrentMonthScoreData !=
                                                            null
                                                        ? userCurrentMonthScoreData
                                                            .toString()
                                                        : '0',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff0E1712),
                                                        fontSize: 14,
                                                        fontFamily: Constant
                                                            .jostMedium),
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xff97c289),
                                                  border: Border.all(
                                                      color: Color(0xff97c289),
                                                      width: 1.2),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Utils.showCompassTutorialDialog(
                                          context, 2,
                                          compassTutorialModel:
                                              _compassTutorialModel);
                                    },
                                    child: CustomTextWidget(
                                      text: "Disability",
                                      style: TextStyle(
                                          color: Color(0xffafd794),
                                          fontSize: 16,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                ],
                              ),
                              RotatedBox(
                                quarterTurns: 1,
                                child: GestureDetector(
                                  onTap: () {
                                    Utils.showCompassTutorialDialog(context, 4,
                                        compassTutorialModel:
                                            _compassTutorialModel);
                                  },
                                  child: CustomTextWidget(
                                    text: "Duration",
                                    style: TextStyle(
                                        color: Color(0xffafd794),
                                        fontSize: 16,
                                        fontFamily: Constant.jostMedium),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              DateTime dateTime =
                                  DateTime(_dateTime.year, _dateTime.month - 1);
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
                              _openDatePickerBottomSheet(
                                  CupertinoDatePickerMode.date);
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
                                  DateTime(_dateTime.year, _dateTime.month + 1);
                              Duration duration =
                                  dateTime.difference(DateTime.now());
                              if (duration.inSeconds < 0) {
                                _dateTime = dateTime;
                                _onStartDateSelected(dateTime);
                              } else {
                                ///To:Do
                                print("Not Allowed");
                                /*Utils.showValidationErrorDialog(
                                    context, Constant.beyondDateErrorMessage);*/
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
                        height: 10,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        padding: EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: Constant.locationServiceGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: CustomRichTextWidget(
                            text: TextSpan(
                              children: _getBubbleTextSpans(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                );
              }else {
                return Container();
              }
            }  else {
              return Container();
            }
          }),
    );
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

    var resultFromActionSheet = await widget.openDatePickerCallback(
        MonthYearCupertinoDatePickerMode.date,
        _getDateTimeCallbackFunction(0) ?? (){},
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
    totalDaysInCurrentMonth =
        Utils.daysInCurrentMonth(dateTime.month, dateTime.year);
    firstDayOfTheCurrentMonth = Utils.firstDateWithCurrentMonthAndTimeInUTC(
        dateTime.month, dateTime.year, 1);
    lastDayOfTheCurrentMonth = Utils.lastDateWithCurrentMonthAndTimeInUTC(
        dateTime.month, dateTime.year, totalDaysInCurrentMonth);
    monthName = Utils.getMonthName(dateTime.month);
    currentYear = dateTime.year;
    currentMonth = dateTime.month;
    _dateTime = dateTime;
    _recordsCompassScreenBloc.initNetworkStreamController();
    Utils.showApiLoaderDialog(context,
        networkStream: _recordsCompassScreenBloc.networkDataStream,
        tapToRetryFunction: () {
      _recordsCompassScreenBloc.enterSomeDummyDataToStreamController();
      requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
          selectedHeadacheName ?? '');
    });
    requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
        selectedHeadacheName ?? '');
  }

  void requestService(String firstDayOfTheCurrentMonth,
      String lastDayOfTheCurrentMonth, String? selectedHeadacheName) async {
    await _recordsCompassScreenBloc.fetchAllHeadacheListData(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth, true, selectedHeadacheName, context);
  }

  void setCompassAxesData(RecordsOverTimeCompassModel recordsOverTimeCompassModel) {
    int userDisabilityValue,
        userFrequencyValue,
        userDurationValue,
        userIntensityValue;
    int baseMaxValue = 10;
    List<Axes> currentMonthCompassAxesListData = recordsOverTimeCompassModel
        .recordsCompareCompassAxesResultModel!.currentAxes!;
    print(recordsOverTimeCompassModel);
    var userFrequency = currentMonthCompassAxesListData.firstWhereOrNull(
        (frequencyElement) => frequencyElement.name == Constant.frequency);
    if (userFrequency != null) {
      // userFrequencyValue = userFrequency.value ~/ (userFrequency.max / baseMaxValue);
      _compassTutorialModel.currentMonthFrequency = userFrequency.total!.round();
      userFrequencyValue = (userFrequency.value !* baseMaxValue).round();
      if (userFrequencyValue > 10) {
        userFrequencyValue = 10;
      } else {
        userFrequencyValue = userFrequencyValue;
      }
    } else {
      userFrequencyValue = 0;
      _compassTutorialModel.currentMonthFrequency = 0;
    }
    var userDuration = currentMonthCompassAxesListData.firstWhereOrNull(
        (durationElement) => durationElement.name == Constant.duration);
    if (userDuration != null) {
      // userDurationValue = userDuration.value ~/ (userDuration.max / baseMaxValue);
      _compassTutorialModel.currentMonthDuration = userDuration.total!.round();
      userDurationValue = (userDuration.value !* baseMaxValue).round(); //0
      if (userDurationValue > 10) {
        userDurationValue = 10;
      } else {
        userDurationValue = userDurationValue;
      }
    } else {
      userDurationValue = 0;
      _compassTutorialModel.currentMonthDuration = 0;
    }
    var userIntensity = currentMonthCompassAxesListData.firstWhereOrNull(
        (intensityElement) => intensityElement.name == Constant.intensity);
    if (userIntensity != null) {
      // userIntensityValue = userIntensity.value ~/ (userIntensity.max / baseMaxValue);
      _compassTutorialModel.currentMonthIntensity = userIntensity.value!.round();
      userIntensityValue =
          (userIntensity.value !* baseMaxValue) ~/ userIntensity.max!; //10
    } else {
      userIntensityValue = 0;
      _compassTutorialModel.currentMonthIntensity = 0;
    }
    var userDisability = currentMonthCompassAxesListData.firstWhereOrNull(
        (disabilityElement) => disabilityElement.name == Constant.disability);
    if (userDisability != null) {
      // userDisabilityValue =  userDisability.value ~/ (userDisability.max / baseMaxValue);
      _compassTutorialModel.currentMonthDisability =
          userDisability.value!.round();
      userDisabilityValue =
          (userDisability.value !* baseMaxValue) ~/ userDisability.max!; //10
      if (userDisabilityValue > 10) {
        userDisabilityValue = 10;
      } else {
        userDisabilityValue = userDisabilityValue;
      }
    } else {
      _compassTutorialModel.currentMonthDisability = 0;
      userDisabilityValue = 0;
    }

    compassAxesData = [
      [
        userIntensityValue,
        userDurationValue,
        userDisabilityValue,
        userFrequencyValue
      ]
    ];

    debugPrint('OvertimeCompassAxesData????$compassAxesData');

    if (currentMonthCompassAxesListData.length > 0) {
      setCurrentMonthCompassDataScore(
          userIntensity!, userDisability!, userFrequency!, userDuration!);
    } else {
      currentIntensityValue = 0;
      currentDisabilityValue = 0;
      currentFrequencyValue = 0;
      currentDurationValue = 0;
      userCurrentMonthScoreData = 0;
    }

    setPreviousMonthAxesData(recordsOverTimeCompassModel);
  }

  @override
  bool get wantKeepAlive => true;

  void _openHeadacheTypeActionSheet(
      List<HeadacheListDataModel> headacheListData) async {
    if (lastSelectedHeadacheName != null) {
      var lastSelectedHeadacheNameData = headacheListData.firstWhereOrNull(
          (element) => element.text == lastSelectedHeadacheName);
      if (lastSelectedHeadacheNameData != null) {
        lastSelectedHeadacheNameData.isSelected = true;
      }
    }
    var resultFromActionSheet = await widget.openActionSheetCallback(
        Constant.compassHeadacheTypeActionSheet, CompassHeadacheTypeActionSheetModel(initialSelectedHeadacheName: selectedHeadacheName ?? headacheListData[headacheListData.length-1].text ?? '', headacheListModelData: headacheListData));
    lastSelectedHeadacheName = resultFromActionSheet;
    currentSelectedHeadacheName = resultFromActionSheet;
    if (resultFromActionSheet != null) {
      selectedHeadacheName = resultFromActionSheet.toString();
      _recordsCompassScreenBloc.initNetworkStreamController();
      debugPrint('show api loader 12');
      widget.showApiLoaderCallback(_recordsCompassScreenBloc.networkDataStream,
          () {
        _recordsCompassScreenBloc.enterSomeDummyDataToStreamController();
        requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
            selectedHeadacheName ?? '');
      });
      requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
          selectedHeadacheName ?? '');
      debugPrint(resultFromActionSheet);
    }
  }

  void _showApiLoaderDialog() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String isViewTrendsClicked =
        sharedPreferences.getString(Constant.isViewTrendsClicked) ??
            Constant.blankString;
    String isSeeMoreClicked =
        sharedPreferences.getString(Constant.isSeeMoreClicked) ??
            Constant.blankString;

    CompassInfo compassInfo = Provider.of<CompassInfo>(context, listen: false);
    if (isViewTrendsClicked.isEmpty && isSeeMoreClicked.isEmpty && compassInfo.getCurrentIndex() == 0) {
        debugPrint('show api loader 5');
        widget.showApiLoaderCallback(
            _recordsCompassScreenBloc.networkDataStream, () {
          _recordsCompassScreenBloc.enterSomeDummyDataToStreamController();
          requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
              selectedHeadacheName ?? '');
      });
    }
  }

  void setCurrentMonthCompassDataScore(
      Axes userIntensityValue,
      Axes userDisabilityValue,
      Axes userFrequencyValue,
      Axes userDurationValue) {
    var intensityScore, disabilityScore, frequencyScore, durationScore;
    currentIntensityValue = userIntensityValue.value!;
    currentDisabilityValue = userDisabilityValue.value!;
    currentFrequencyValue = userFrequencyValue.value!;
    currentDurationValue = userDurationValue.value!;

    if (userIntensityValue.value != null) {
      intensityScore =
          userIntensityValue.value !/ userIntensityValue.max! * 100.0; //44
    } else {
      intensityScore = 0;
    }
    if (userDisabilityValue.value != null) {
      disabilityScore =
          userDisabilityValue.value !/ userDisabilityValue.max! * 100.0; //88
    } else {
      disabilityScore = 0;
    }
    if (userFrequencyValue.value != null) {
      frequencyScore =
          userFrequencyValue.value !* 100.0; //~100

      if (frequencyScore > 100) frequencyScore = 100;
    } else {
      frequencyScore = 0;
    }
    if (userDurationValue.value != null) {
      durationScore =
          userDurationValue.value !* 100.0; //0
      if (durationScore > 100) durationScore = 100;
    } else {
      durationScore = 0;
    }

    print(
        'IntensityScore????$intensityScore????DisabilityScore????$disabilityScore????FrequencyScore????$frequencyScore????DurationScore????$durationScore');
    var userTotalScore =
        (intensityScore + disabilityScore + frequencyScore + durationScore) / 4;
    userCurrentMonthScoreData = userTotalScore.round();
    print(userCurrentMonthScoreData);
  }

  void _updateCompassData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String isSeeMoreClicked =
        sharedPreferences.getString(Constant.isSeeMoreClicked) ??
            Constant.blankString;
    String isTrendsClicked =
        sharedPreferences.getString(Constant.isViewTrendsClicked) ??
            Constant.blankString;
    String updateOverTimeCompassData =
        sharedPreferences.getString(Constant.updateOverTimeCompassData) ??
            Constant.blankString;
    String newHeadacheName = sharedPreferences.getString(Constant.userHeadacheName) ?? Constant.blankString;
    if (isSeeMoreClicked == "" && isTrendsClicked == "" && updateOverTimeCompassData == Constant.trueString) {
      sharedPreferences.remove(Constant.updateOverTimeCompassData);
      _dateTime = DateTime.now();
      currentMonth = _dateTime.month;
      currentYear = _dateTime.year;
      monthName = Utils.getMonthName(currentMonth);
      totalDaysInCurrentMonth =
          Utils.daysInCurrentMonth(currentMonth, currentYear);
      firstDayOfTheCurrentMonth = Utils.firstDateWithCurrentMonthAndTimeInUTC(
          currentMonth, currentYear, 1);
      lastDayOfTheCurrentMonth = Utils.lastDateWithCurrentMonthAndTimeInUTC(
          currentMonth, currentYear, totalDaysInCurrentMonth);
      debugPrint('updateData: overTime compass');
      if (newHeadacheName.isNotEmpty)
        selectedHeadacheName = newHeadacheName;
      _recordsCompassScreenBloc.initNetworkStreamController();
      _showApiLoaderDialog();
      requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth, selectedHeadacheName ?? '');
      sharedPreferences.setString(Constant.updateOverTimeCompassData, Constant.falseString);
      currentSelectedHeadacheName = selectedHeadacheName;
      this.selectedHeadacheName = selectedHeadacheName;
    }
  }

  void navigateToHeadacheStartScreen() async {
    await widget.navigateToOtherScreenCallback(
        Constant.headacheStartedScreenRouter, null);
    Utils.setAnalyticsCurrentScreen(Constant.compassScreen, context);
  }

  void setPreviousMonthAxesData(RecordsOverTimeCompassModel recordsOverTimeCompassModel) {
    int userDisabilityValue,
        userFrequencyValue,
        userDurationValue,
        userIntensityValue;

    int baseMaxValue = 10;
    List<Axes> previousMonthCompassAxesListData = recordsOverTimeCompassModel
        .recordsCompareCompassAxesResultModel!.previousAxes!;
    print(recordsOverTimeCompassModel);
    var userFrequency = previousMonthCompassAxesListData.firstWhereOrNull(
        (intensityElement) => intensityElement.name == Constant.frequency);
    if (userFrequency != null) {
      _compassTutorialModel.previousMonthFrequency =
          userFrequency.total!.round();
      userFrequencyValue = (userFrequency.value !* baseMaxValue).round();
      if (userFrequencyValue > 10) {
        userFrequencyValue = 10;
      } else {
        userFrequencyValue = userFrequencyValue;
      }
    } else {
      _compassTutorialModel.previousMonthFrequency = 0;
      userFrequencyValue = 0;
    }
    var userDuration = previousMonthCompassAxesListData.firstWhereOrNull(
        (intensityElement) => intensityElement.name == Constant.duration);
    if (userDuration != null) {
      _compassTutorialModel.previousMonthDuration =
          (userDuration.total)!.round();
      userDurationValue = (userDuration.value !* baseMaxValue).round(); //0
      if (userDurationValue > 10) {
        userDurationValue = 10;
      } else {
        userDurationValue = userDurationValue;
      }
    } else {
      _compassTutorialModel.previousMonthDuration = 0;
      userDurationValue = 0;
    }
    var userIntensity = previousMonthCompassAxesListData.firstWhereOrNull(
        (intensityElement) => intensityElement.name == Constant.intensity);
    if (userIntensity != null) {
      _compassTutorialModel.previousMonthIntensity =
          userIntensity.value!.round();
      userIntensityValue = userIntensity.value !~/ (userIntensity.max !/ baseMaxValue);
    } else {
      _compassTutorialModel.previousMonthIntensity = 0;
      userIntensityValue = 0;
    }
    var userDisability = previousMonthCompassAxesListData.firstWhereOrNull(
        (intensityElement) => intensityElement.name == Constant.disability);
    if (userDisability != null) {
      _compassTutorialModel.previousMonthDisability =
          userDisability.value!.round();
      userDisabilityValue = userDisability.value !~/ (userDisability.max !/ baseMaxValue);
    } else {
      _compassTutorialModel.previousMonthDisability = 0;
      userDisabilityValue = 0;
    }
    if (previousMonthCompassAxesListData.length > 0) {
      setPreviousMonthCompassDataScore(userIntensity!, userDisability!, userFrequency!, userDuration!);
    } else {
      previousIntensityValue = 0;
      previousDisabilityValue = 0;
      previousFrequencyValue = 0;
      previousDurationValue = 0;
      userPreviousMonthScoreData = 0;
    }
  }

  void setPreviousMonthCompassDataScore(
      Axes userIntensityValue,
      Axes userDisabilityValue,
      Axes userFrequencyValue,
      Axes userDurationValue) {
    var intensityScore, disabilityScore, frequencyScore, durationScore;

    previousIntensityValue = userIntensityValue.value!;
    previousDisabilityValue = userDisabilityValue.value!;
    previousFrequencyValue = userFrequencyValue.value!;
    previousDurationValue = userDurationValue.value!;

    if (userIntensityValue.value != null) {
      intensityScore =
          userIntensityValue.value !/ userIntensityValue.max! * 100.0;
    } else {
      intensityScore = 0;
    }
    if (userDisabilityValue.value != null) {
      disabilityScore =
          userDisabilityValue.value !/ userDisabilityValue.max! * 100.0;
    } else {
      disabilityScore = 0;
    }
    if (userFrequencyValue.value != null) {
      frequencyScore = userFrequencyValue.value !* 100.0; //~100
      if (frequencyScore > 100) frequencyScore = 100;
    } else {
      frequencyScore = 0;
    }
    if (userDurationValue.value != null) {
      durationScore = userDurationValue.value !* 100.0; //0
      if (durationScore > 100) durationScore = 100;
    } else {
      durationScore = 0;
    }

    var userTotalScore =
        (intensityScore + disabilityScore + frequencyScore + durationScore) / 4;
    userPreviousMonthScoreData = userTotalScore.round();
    print(userPreviousMonthScoreData);
  }

  void _navigateToAddHeadacheScreen() async {
    DateTime currentDateTime = DateTime.now();
    DateTime endHeadacheDateTime = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        currentDateTime.hour,
        currentDateTime.minute,
        0,
        0,
        0);

    currentUserHeadacheModel!.selectedEndDate =
        Utils.getDateTimeInUtcFormat(endHeadacheDateTime, true, context);

    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    currentUserHeadacheModel = await SignUpOnBoardProviders.db
        .getUserCurrentHeadacheData(userProfileInfoData.userId!);

    currentUserHeadacheModel!.isOnGoing = false;
    currentUserHeadacheModel!.selectedEndDate =
        Utils.getDateTimeInUtcFormat(endHeadacheDateTime, true, context);

    await widget.navigateToOtherScreenCallback(
        Constant.addHeadacheOnGoingScreenRouter, currentUserHeadacheModel);
    Utils.setAnalyticsCurrentScreen(Constant.compassScreen, context);
    _getUserCurrentHeadacheData();
  }

  void _navigateUserToHeadacheLogScreen() async {
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    CurrentUserHeadacheModel? currentUserHeadacheModel;

    if (userProfileInfoData != null)
      currentUserHeadacheModel = await SignUpOnBoardProviders.db
          .getUserCurrentHeadacheData(userProfileInfoData.userId!);

    if (currentUserHeadacheModel == null) {
      await widget.navigateToOtherScreenCallback(
          Constant.headacheStartedScreenRouter, null);
    } else {
      if (currentUserHeadacheModel.isOnGoing!) {
        await widget.navigateToOtherScreenCallback(
            Constant.currentHeadacheProgressScreenRouter, null);
      } else
        await widget.navigateToOtherScreenCallback(
            Constant.addHeadacheOnGoingScreenRouter, currentUserHeadacheModel);
    }

    Utils.setAnalyticsCurrentScreen(Constant.compassScreen, context);
    _getUserCurrentHeadacheData();
  }

  Future<void> _getUserCurrentHeadacheData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    int? currentPositionOfTabBar =
        sharedPreferences.getInt(Constant.currentIndexOfTabBar);
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    if (currentPositionOfTabBar == 1 && userProfileInfoData != null) {
      currentUserHeadacheModel = await SignUpOnBoardProviders.db
          .getUserCurrentHeadacheData(userProfileInfoData.userId!);
    }
  }

  void _removeDataFromSharedPreference() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(Constant.updateOverTimeCompassData);
  }

//'$increaseOrDecrease in Frequency.
  setTextValue(int predicateId) {
    if (predicateId == 0) {
      if (currentIntensityValue < previousIntensityValue) {
        increaseOrDecrease = 'decrease in Intensity.';
      } else if (currentDisabilityValue < previousDisabilityValue) {
        increaseOrDecrease = 'decrease in Disability.';
      } else if (currentFrequencyValue < previousFrequencyValue) {
        increaseOrDecrease = 'decrease in Frequency.';
      } else {
        increaseOrDecrease = 'decrease in Duration.';
      }
    }else if (predicateId == 1) {
      if (currentIntensityValue > previousIntensityValue) {
        increaseOrDecrease = 'increase in Intensity.';
      } else if (currentDisabilityValue > previousDisabilityValue) {
        increaseOrDecrease = 'increase in Disability.';
      } else if (currentFrequencyValue > previousFrequencyValue) {
        increaseOrDecrease = 'increase in Frequency.';
      } else {
        increaseOrDecrease = 'increase in Duration.';
      }
    }else{
      if (currentIntensityValue == previousIntensityValue) {
        increaseOrDecrease = 'neither increase or decrease in Intensity.';
      } else if (currentDisabilityValue == previousDisabilityValue) {
        increaseOrDecrease = 'neither increase or decrease in Disability.';
      } else if (currentFrequencyValue == previousFrequencyValue) {
        increaseOrDecrease = 'neither increase or decrease in Frequency.';
      } else {
        increaseOrDecrease = 'neither increase or decrease in Duration.';
      }
    }
  }
}
