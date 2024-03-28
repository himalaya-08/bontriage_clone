import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/blocs/RecordsCompassScreenBloc.dart';
import 'package:mobile/models/CompassTutorialModel.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/HeadacheListDataModel.dart';
import 'package:mobile/models/RecordsCompareCompassModel.dart';
import 'package:mobile/models/RecordsCompassAxesResultModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/MonthYearCupertinoDatePicker.dart';
import 'package:mobile/util/RadarChart.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CompassHeadacheTypeActionSheet.dart';
import 'package:mobile/view/CompassScreen.dart';
import 'package:mobile/view/CustomRichTextWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:collection/collection.dart';

class CompareCompassScreen extends StatefulWidget {
  final Future<dynamic> Function(String, dynamic) openActionSheetCallback;
  final Function(Stream, Function) showApiLoaderCallback;
  final Future<dynamic> Function(String, dynamic) navigateToOtherScreenCallback;
  final Future<DateTime> Function(MonthYearCupertinoDatePickerMode, Function, DateTime)
  openDatePickerCallback;

  const CompareCompassScreen(
      {Key? key,
        required this.openActionSheetCallback,
        required this.showApiLoaderCallback,
        required this.navigateToOtherScreenCallback,
        required this.openDatePickerCallback})
      : super(key: key);

  @override
  _CompareCompassScreenState createState() => _CompareCompassScreenState();
}

class _CompareCompassScreenState extends State<CompareCompassScreen>
    with AutomaticKeepAliveClientMixin {
  bool darkMode = false;
  double numberOfFeatures = 4;
  DateTime _dateTime = DateTime.now();
  late int currentMonth;

  int currentYear = 2021;
  String monthName = 'Feb';
  late int totalDaysInCurrentMonth;
  late String firstDayOfTheCurrentMonth;
  late String lastDayOfTheCurrentMonth;
  late RecordsCompassScreenBloc _recordsCompassScreenBloc;

  List<int> ticks = [];

  late HeadacheComponentsModel headacheComponentsModel1;
  late HeadacheComponentsModel headacheComponentsModel2;

  List<String> features =[];
  List<HeadacheListDataModel> headacheListModelData = [];

  CompassTutorialModel _compassTutorialModelMonthly = CompassTutorialModel();
  CompassTutorialModel _compassTutorialModelFirstLogged = CompassTutorialModel();

  DateTime firstLoggedSignUpData = DateTime.now();

  CurrentUserHeadacheModel? currentUserHeadacheModel;

  bool _isShowAlert = false;
  String _errorMsg = Constant.blankString;

  int userFirstLoggedCompassScoreData = 0;

  late List<List<int>> compassGraphAxesData;

  int monthlyIntensityValue = 0;
  int monthlyDurationValue = 0;
  int monthlyDisabilityValue = 0;
  int monthlyFrequencyValue = 0;

  int monthlyCompareIntensityValue = 0;
  int monthlyCompareDurationValue = 0;
  int monthlyCompareDisabilityValue = 0;
  int monthlyCompareFrequencyValue = 0;

  int headacheLogged = 2;
  int headacheDeleted = 2;
  bool firstHeadacheAdded = false;
  bool newHeadacheAdded = true;

  List<TextSpan> _getBubbleTextSpans() {
    List<TextSpan> list = [];
    list.add(TextSpan(
        text: 'Your first logged Headache score was ',
        style: TextStyle(
            height: 1.2,
            fontSize: 14,
            fontFamily: Constant.jostRegular,
            color: Constant.chatBubbleGreen)));
    list.add(TextSpan(
        text: userFirstLoggedCompassScoreData.toString(),
        style: TextStyle(
            height: 1.2,
            fontSize: 14,
            fontFamily: Constant.jostRegular,
            color: Constant.addCustomNotificationTextColor)));
    list.add(TextSpan(
        text:
        ' in ${Utils.getMonthName(firstLoggedSignUpData.month)} ${firstLoggedSignUpData.year}. Tap the Compass axes to view $monthName $currentYear.',
        style: TextStyle(
            height: 1.2,
            fontSize: 14,
            fontFamily: Constant.jostRegular,
            color: Constant.chatBubbleGreen)));

    return list;
  }

  @override
  void initState() {
    super.initState();

    _compassTutorialModelMonthly = CompassTutorialModel();
    _compassTutorialModelFirstLogged = CompassTutorialModel();

    headacheComponentsModel1 = HeadacheComponentsModel(headacheName: null, compassAxisData: [], headacheScore: -1);

    headacheComponentsModel2 = HeadacheComponentsModel(headacheName: null,  compassAxisData: [], headacheScore: -1);

    compassGraphAxesData = [
      headacheComponentsModel2.compassAxisData,
      headacheComponentsModel1.compassAxisData
    ];

    _compassTutorialModelFirstLogged.isFromOnBoard = true;

    ticks = [2, 4, 6, 8, 10];

    features = [
      "A",
      "B",
      "C",
      "D",
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
    debugPrint('init state of compare compass');

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      debugPrint('show api loader 18');
      CompassInfo compassInfo = Provider.of<CompassInfo>(context, listen: false);
      if (compassInfo.getCurrentIndex() == 1) {
        widget.showApiLoaderCallback(
            _recordsCompassScreenBloc.networkDataStream,
                () {
              _recordsCompassScreenBloc.enterSomeDummyDataToStreamController();
              requestService(
                  firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
                  headacheComponentsModel1.headacheName ?? '');
            });
      }
      requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
          headacheComponentsModel1.headacheName);
    });
    _removeDataFromSharedPreference();

    _compassTutorialModelMonthly.currentDateTime = _dateTime;
  }

  Future<void> updateActionSheet() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(Constant.updateCompassHeadacheList, Constant.falseString);
  }

  @override
  void didUpdateWidget(covariant CompareCompassScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('didUpdateWidget of compare compass');
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
                      if(data.getUpdateCompareScreenInfo){
                        data.updateCompareScreenInfo(false);
                        _updateCompassData();
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 150,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomTextWidget(
                                text: 'We noticed you didn\'t log any headache yet. So please add any headache to see your Compare Compass data.',
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
                                  String updateCompareValue = sharedPreferences.getString(Constant.updateCompareCompassData) ?? Constant.falseString;
                                  String updateOverTimeValue = sharedPreferences.getString(Constant.updateOverTimeCompassData) ?? Constant.falseString;

                                  if(updateCompareValue == Constant.trueString){
                                    if(updateOverTimeValue == Constant.trueString){
                                      data.updateOverTimeScreenInfo(true);
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
              else if (snapshot.data is RecordsCompareCompassModel) {
                _compassTutorialModelMonthly.currentDateTime = _dateTime;
                if (headacheComponentsModel1.headacheName == null) {
                  List<HeadacheListDataModel> headacheListModelData =
                      snapshot.data.headacheListDataModel;
                  headacheComponentsModel1.headacheName  = headacheListModelData[headacheListModelData.length-1].text;
                  headacheComponentsModel2.headacheName  = Constant.firstLoggedScore;
                }

                return Consumer<CompareCompassInfo>(
                  builder: (context, data, child){

                   // Future.delayed(const Duration(seconds: 2)).then((value) => _deletedHeadacheHandler(data, snapshot.data));

                    setCompassAxesData(snapshot.data, data);
                    return Container(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              _openHeadacheTypeActionSheet(
                                  snapshot.data.headacheListDataModel, false, data);
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
                                  text: headacheComponentsModel1.headacheName != Constant.blankString
                                      ? headacheComponentsModel1.headacheName : snapshot.data.headacheListDataModel[snapshot.data.headacheListDataModel.length-1].text,
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
                          Stack(children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Utils.showCompassTutorialDialog(context, 0,
                                    compassTutorialModel:
                                    _getCompassTutorialModelObj());
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
                                        color: Constant.chatBubbleGreen, width: 1)),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Utils.showCompassTutorialDialog(context, 0,
                                          compassTutorialModel:
                                          _getCompassTutorialModelObj());
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
                                          _getCompassTutorialModelObj());
                                    },
                                    child: CustomTextWidget(
                                      text: "Frequency",
                                      style: TextStyle(
                                          color: Constant.chatBubbleGreen,
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
                                        Utils.showCompassTutorialDialog(context, 1,
                                            compassTutorialModel:
                                            _getCompassTutorialModelObj());
                                      },
                                      child: CustomTextWidget(
                                        text: "Intensity",
                                        style: TextStyle(
                                            color: Constant.chatBubbleGreen,
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
                                                child: Consumer<CompareCompassInfo>(
                                                  builder: (context, data, child) {
                                                    int compassValue = data.getCompassValue();
                                                    return RadarChart.light(
                                                      ticks: ticks,
                                                      features: features,
                                                      data: compassGraphAxesData,
                                                      outlineColor: Constant
                                                          .chatBubbleGreen
                                                          .withOpacity(0.5),
                                                      reverseAxis: false,
                                                      compassValue: compassValue,
                                                    );
                                                  },
                                                ),
                                              ),
                                              Center(
                                                child: Consumer<CompareCompassInfo>(
                                                  builder: (context, data, child) {
                                                    bool isMonthTapSelected = data.isMonthTapSelected();
                                                    return Container(
                                                      width: 38,
                                                      height: 38,
                                                      child: Center(
                                                        child: CustomTextWidget(
                                                          text: isMonthTapSelected
                                                              ? headacheComponentsModel1.headacheScore
                                                              .toString()
                                                              : headacheComponentsModel2.headacheScore
                                                              .toString(),
                                                          style: TextStyle(
                                                              color: isMonthTapSelected
                                                                  ? Colors.white
                                                                  : Colors.black,
                                                              fontSize: 14,
                                                              fontFamily:
                                                              Constant.jostMedium),
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: isMonthTapSelected
                                                            ? Constant
                                                            .compareCompassHeadacheValueColor
                                                            : Constant
                                                            .compareCompassMonthSelectedColor,
                                                        border: Border.all(
                                                            color: isMonthTapSelected
                                                                ? Constant
                                                                .compareCompassHeadacheValueColor
                                                                : Constant
                                                                .compareCompassMonthSelectedColor,
                                                            width: 1.2),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Utils.showCompassTutorialDialog(context, 2,
                                            compassTutorialModel:
                                            _getCompassTutorialModelObj());
                                      },
                                      child: CustomTextWidget(
                                        text: "Disability",
                                        style: TextStyle(
                                            color: Constant.chatBubbleGreen,
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
                                          _getCompassTutorialModelObj());
                                    },
                                    child: CustomTextWidget(
                                      text: "Duration",
                                      style: TextStyle(
                                          color: Constant.chatBubbleGreen,
                                          fontSize: 16,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ]),
                          SizedBox(
                            height: 20,
                          ),
                          AnimatedSize(
                            duration: Duration(milliseconds: 300),
                            //vsync: this,
                            child: Visibility(
                              visible: _isShowAlert,
                              child: Container(
                                padding: EdgeInsets.only(bottom: 20,),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 23,),
                                    Image(
                                      image: AssetImage(Constant.warningPink),
                                      width: 22,
                                      height: 22,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    CustomTextWidget(
                                      text: _errorMsg,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Constant.pinkTriggerColor,
                                          fontFamily: Constant.jostRegular),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Consumer<CompareCompassInfo>(
                              builder: (context, data, child) {
                                bool isMonthTapSelected = data.isMonthTapSelected();
                                return GestureDetector(
                                  onTap: () {
                                    data.updateCompareCompassInfo(3, true);
                                  },
                                  child: Container(
                                    height: 35,
                                    color: isMonthTapSelected
                                        ? Constant.locationServiceGreen.withOpacity(0.1)
                                        : Colors.transparent,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 25,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 15,
                                                  height: 15,
                                                  color: Constant
                                                      .compareCompassHeadacheValueColor,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                CustomTextWidget(
                                                  text: headacheComponentsModel1.headacheName != Constant.blankString
                                                      ? headacheComponentsModel1.headacheName : snapshot.data.headacheListDataModel[snapshot.data.headacheListDataModel.length-1].text,
                                                  style: TextStyle(
                                                      color: Constant.chatBubbleGreen,
                                                      fontSize: 14,
                                                      fontFamily: Constant.jostRegular),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              CustomTextWidget(
                                                text: '$monthName $currentYear',
                                                style: TextStyle(
                                                    color: Constant.chatBubbleGreen,
                                                    fontSize: 14,
                                                    fontFamily: Constant.jostRegular),
                                              ),
                                              SizedBox(width: 15,),
                                              GestureDetector(
                                                onTap: () {
                                                  _openDatePickerBottomSheet(
                                                      CupertinoDatePickerMode.date, data);
                                                },
                                                child: CustomTextWidget(
                                                  text: 'Change',
                                                  style: TextStyle(
                                                      color: Constant
                                                          .addCustomNotificationTextColor,
                                                      fontSize: 14,
                                                      fontFamily: Constant.jostRegular),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Consumer<CompareCompassInfo>(
                            builder: (context, data, child) {
                              bool isMonthTapSelected = data.isMonthTapSelected();
                              return GestureDetector(
                                onTap: (){
                                  data.updateCompareCompassInfo(2, false);
                                },
                                child: Container(
                                  height: 35,
                                  color: (!isMonthTapSelected)
                                      ? Constant.locationServiceGreen.withOpacity(0.1)
                                      : Colors.transparent,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 25,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 15,
                                              height: 15,
                                              color: Color(0xffB8FFFF),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            CustomTextWidget(
                                              text: headacheComponentsModel2.headacheName != Constant.blankString
                                                  ? headacheComponentsModel2.headacheName ?? snapshot.data.headacheListDataModel[snapshot.data.headacheListDataModel.length-1].text
                                                  : snapshot.data.headacheListDataModel[snapshot.data.headacheListDataModel.length-1].text,
                                              style: TextStyle(
                                                  color: Constant.chatBubbleGreen,
                                                  fontSize: 14,
                                                  fontFamily: Constant.jostRegular),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _openHeadacheTypeActionSheet(
                                                snapshot.data.headacheListDataModel, true, data);
                                          },
                                          child: CustomTextWidget(
                                            text: 'Change',
                                            style: TextStyle(
                                                color: Constant
                                                    .addCustomNotificationTextColor,
                                                fontSize: 14,
                                                fontFamily: Constant.jostRegular),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            padding: EdgeInsets.symmetric(vertical: 0),
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
                  },
                );
              } else {
                return Container();
              }
            } else {
              return Container();
            }
          }),
    );
  }

  /// @param cupertinoDatePickerMode: for time and date mode selection
  void _openDatePickerBottomSheet(
      CupertinoDatePickerMode cupertinoDatePickerMode, CompareCompassInfo data) async {
    dynamic resultFromActionSheet = await widget.openDatePickerCallback(
        MonthYearCupertinoDatePickerMode.date,
        _getDateTimeCallbackFunction(0) ?? (){},
        _dateTime);

    if (resultFromActionSheet != null && resultFromActionSheet is DateTime)
      _onStartDateSelected(resultFromActionSheet, data);
  }

  Function? _getDateTimeCallbackFunction(int whichPickerClicked) {
    switch (whichPickerClicked) {
      case 0:
        return _onStartDateSelected;
      default:
        return null;
    }
  }

  void _onStartDateSelected(DateTime dateTime, CompareCompassInfo data) {
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
    debugPrint('show api loader 11');
    Utils.showApiLoaderDialog(context,
        networkStream: _recordsCompassScreenBloc.networkDataStream,
        tapToRetryFunction: () {
          _recordsCompassScreenBloc.enterSomeDummyDataToStreamController();
          requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
              headacheComponentsModel1.headacheName ?? '');
        });
    requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
        headacheComponentsModel1.headacheName ?? '');

    data.updateIsFirstHeadacheChanged(true);
  }

  void requestService(String firstDayOfTheCurrentMonth,
      String lastDayOfTheCurrentMonth, String? selectedHeadacheName) async {
    await _recordsCompassScreenBloc.fetchAllHeadacheListData(
        firstDayOfTheCurrentMonth,
        lastDayOfTheCurrentMonth,
        false,
        selectedHeadacheName, context);
  }

  void setCompassAxesData(
      RecordsCompareCompassModel recordsCompassAxesResultModel, CompareCompassInfo data) {
    int userMonthlyDisabilityValue,
        userMonthlyFrequencyValue,
        userMonthlyDurationValue,
        userMonthlyIntensityValue;

    int baseMaxValue = 10;

    List<Axes>? recordsCompareCompassAxesListData = recordsCompassAxesResultModel
        .recordsCompareCompassAxesResultModel!.currentAxes;

    var userFrequency = recordsCompareCompassAxesListData!.firstWhereOrNull(
            (frequencyElement) => frequencyElement.name == Constant.frequency);
    if (userFrequency != null) {
      _compassTutorialModelMonthly.currentMonthFrequency =
          userFrequency.total!.round();
      userMonthlyFrequencyValue = (userFrequency.value !* baseMaxValue).round();
      if (userMonthlyFrequencyValue > 10) {
        userMonthlyFrequencyValue = 10;
      } else {
        userMonthlyFrequencyValue = userMonthlyFrequencyValue;
      }
    } else {
      userMonthlyFrequencyValue = 0;
      _compassTutorialModelMonthly.currentMonthFrequency = 0;
    }
    var userDuration = recordsCompareCompassAxesListData.firstWhereOrNull(
            (intensityElement) => intensityElement.name == Constant.duration);
    if (userDuration != null) {
      //userMonthlyDurationValue = userDuration.value ~/ (userDuration.max / baseMaxValue);
      userMonthlyDurationValue = (userDuration.value !* baseMaxValue).round();
      if (userMonthlyDurationValue > 10) {
        userMonthlyDurationValue = 10;
      } else {
        userMonthlyDurationValue = userMonthlyDurationValue;
      }

      _compassTutorialModelMonthly.currentMonthDuration =
          (userDuration.total)!.round();
    } else {
      userMonthlyDurationValue = 0;
      _compassTutorialModelMonthly.currentMonthDuration = 0;
    }
    var userIntensity = recordsCompareCompassAxesListData.firstWhereOrNull(
            (intensityElement) => intensityElement.name == Constant.intensity);
    if (userIntensity != null) {
      // userMonthlyIntensityValue = userIntensity.value ~/ (userIntensity.max / baseMaxValue);
      _compassTutorialModelMonthly.currentMonthIntensity =
          userIntensity.value!.round();
      userMonthlyIntensityValue =
          (userIntensity.value !* baseMaxValue) ~/ userIntensity.max!;
    } else {
      _compassTutorialModelMonthly.currentMonthIntensity = 0;
      userMonthlyIntensityValue = 0;
    }
    var userDisability = recordsCompareCompassAxesListData.firstWhereOrNull(
            (intensityElement) => intensityElement.name == Constant.disability);
    if (userDisability != null) {
      // userMonthlyDisabilityValue = userDisability.value ~/ (userDisability.max / baseMaxValue);
      _compassTutorialModelMonthly.currentMonthDisability =
          userDisability.value!.round();
      userMonthlyDisabilityValue =
          (userDisability.value !* baseMaxValue) ~/ userDisability.max!;
      if (userMonthlyDisabilityValue > 10) {
        userMonthlyDisabilityValue = 10;
      } else {
        userMonthlyDisabilityValue = userMonthlyDisabilityValue;
      }
    } else {
      _compassTutorialModelMonthly.currentMonthDisability = 0;
      userMonthlyDisabilityValue = 0;
    }

    _setPreviousMonthAxesData(recordsCompassAxesResultModel);

    int userOverTimeIntensityValue;

    int userOvertimeNormalisedFrequencyValue,
        userOverTimeNormalisedDurationValue,
        userOverTimeNormalisedDisabilityValue;

    List<Axes> recordsOverTimeCompassAxesListData =
    recordsCompassAxesResultModel.signUpCompassAxesResultModel!.signUpAxes!;
    debugPrint(
        'CompareCompassDateFirstLogged???${recordsCompassAxesResultModel.signUpCompassAxesResultModel!.calendarEntryAt}');
    firstLoggedSignUpData = DateTime.parse(recordsCompassAxesResultModel
        .signUpCompassAxesResultModel!.calendarEntryAt ??
        DateTime.now().toIso8601String());

    _compassTutorialModelFirstLogged.currentDateTime = firstLoggedSignUpData;

    var userOverTimeFrequency = recordsOverTimeCompassAxesListData.firstWhereOrNull(
            (intensityElement) => intensityElement.name == Constant.frequency);
    if (userOverTimeFrequency != null) {
      // userOvertimeFrequencyValue = userOverTimeFrequency.value ~/(userOverTimeFrequency.max / baseMaxValue);
      _compassTutorialModelFirstLogged.currentMonthFrequency =
          (userOverTimeFrequency.max !- userOverTimeFrequency.value!).round();
      userOvertimeNormalisedFrequencyValue =
          (userOverTimeFrequency.max !- userOverTimeFrequency.value!).round() ~/
              (userOverTimeFrequency.max !/ baseMaxValue);
    } else {
      _compassTutorialModelFirstLogged.currentMonthFrequency = 0;
      userOvertimeNormalisedFrequencyValue = 0;
    }
    var userOvertimeDuration = recordsOverTimeCompassAxesListData.firstWhereOrNull(
            (intensityElement) => intensityElement.name == Constant.duration);
    if (userOvertimeDuration != null) {
      // userOverTimeDurationValue = userOvertimeDuration.value ~/(userOvertimeDuration.max / baseMaxValue);
      userOverTimeNormalisedDurationValue =
          userOvertimeDuration.value !~/ (userOvertimeDuration.max !/ 10);
      _compassTutorialModelFirstLogged.currentMonthDuration = userOvertimeDuration.value!.round();
    } else {
      userOverTimeNormalisedDurationValue = 0;
      _compassTutorialModelFirstLogged.currentMonthDuration = 0;
    }
    var userOverTimeIntensity = recordsOverTimeCompassAxesListData.firstWhereOrNull(
            (intensityElement) => intensityElement.name == Constant.intensity);
    if (userOverTimeIntensity != null) {
      //  userOverTimeIntensityValue = userOverTimeIntensity.value ~/(userOverTimeIntensity.max / baseMaxValue);
      _compassTutorialModelFirstLogged.currentMonthIntensity =
          userOverTimeIntensity.value!.round();
      userOverTimeIntensityValue = (userOverTimeIntensity.value)!.round();
    } else {
      userOverTimeIntensityValue = 0;
      _compassTutorialModelFirstLogged.currentMonthIntensity = 0;
    }
    var userOverTimeDisability = recordsOverTimeCompassAxesListData.firstWhereOrNull(
            (intensityElement) => intensityElement.name == Constant.disability);
    if (userOverTimeDisability != null) {
      // userOverTimeDisabilityValue = userOverTimeDisability.value ~/(userOverTimeDisability.max / baseMaxValue);
      _compassTutorialModelFirstLogged.currentMonthDisability =
          userOverTimeDisability.value!.round();
      userOverTimeNormalisedDisabilityValue = userOverTimeDisability.value !~/
          (userOverTimeDisability.max !/ baseMaxValue);
    } else {
      _compassTutorialModelFirstLogged.currentMonthDisability = 0;
      userOverTimeNormalisedDisabilityValue = 0;
    }

    bool isFirstHeadacheChanged = data.isFirstHeadacheChanged();
    int compareHeadacheChecker = data.getCompareHeadacheChecker();

    if(headacheComponentsModel1.compassAxisData.isEmpty || headacheComponentsModel2.compassAxisData.isEmpty){
      headacheComponentsModel1.compassAxisData = [userMonthlyIntensityValue, userMonthlyDurationValue, userMonthlyDisabilityValue, userMonthlyFrequencyValue];
      headacheComponentsModel2.compassAxisData = [userOverTimeIntensityValue, userOverTimeNormalisedDurationValue, userOverTimeNormalisedDisabilityValue, userOvertimeNormalisedFrequencyValue];
    }
    else{
      if(isFirstHeadacheChanged || headacheLogged == 0 || headacheDeleted == 0 || firstHeadacheAdded){
        headacheComponentsModel1.compassAxisData = [userMonthlyIntensityValue, userMonthlyDurationValue, userMonthlyDisabilityValue, userMonthlyFrequencyValue];
     print('dfgh');
      }
      else{
        if(compareHeadacheChecker == 0 || firstHeadacheAdded){
          headacheComponentsModel2.compassAxisData = [userOverTimeIntensityValue, userOverTimeNormalisedDurationValue, userOverTimeNormalisedDisabilityValue, userOvertimeNormalisedFrequencyValue];
          print('dfgh');
        }
        else if(compareHeadacheChecker == 1 || headacheLogged == 1 || headacheDeleted == 1){
          if(newHeadacheAdded){
            headacheComponentsModel2.compassAxisData = [userMonthlyIntensityValue, userMonthlyDurationValue, userMonthlyDisabilityValue, userMonthlyFrequencyValue];
          }
          print('dfgh');
        }
      }
    }

    compassGraphAxesData = [
      headacheComponentsModel2.compassAxisData,
      headacheComponentsModel1.compassAxisData
    ];

    debugPrint('Compare Compass Axes Data?????${headacheComponentsModel1.compassAxisData}');
    debugPrint('Compare Compass Axes Data?????${headacheComponentsModel2.compassAxisData}');

    setFirstLoggedCompassDataScore(userOverTimeIntensity,
        userOverTimeDisability, userOverTimeFrequency, userOvertimeDuration);

    if (recordsCompareCompassAxesListData.length > 0) {
      setMonthlyCompassDataScore(
          userIntensity!, userDisability!, userFrequency!, userDuration!, data);
    } else {
      bool isFirstHeadacheChanged = data.isFirstHeadacheChanged();
      int compareHeadacheChecker = data.getCompareHeadacheChecker();

      if(headacheComponentsModel1.headacheScore == -1 || headacheComponentsModel2 == -1){
        headacheComponentsModel1.headacheScore = 0;
        headacheComponentsModel2.headacheScore = userFirstLoggedCompassScoreData;
      }
      else{
        if(isFirstHeadacheChanged || headacheLogged == 0 || headacheDeleted == 0){
          headacheComponentsModel1.headacheScore = 0;
          headacheLogged = 2;
          headacheDeleted = 2;
          data.updateIsFirstHeadacheChanged(false);
        }
        else{
          if(compareHeadacheChecker == 0 || firstHeadacheAdded){
            headacheComponentsModel2.headacheScore = userFirstLoggedCompassScoreData;
            firstHeadacheAdded = false;
            data.updateCompareHeadacheChecker(2);
          }
          else if(compareHeadacheChecker == 1 || headacheLogged == 1 || headacheDeleted == 1){
            headacheComponentsModel2.headacheScore = 0;
            headacheLogged = 2;
            headacheDeleted = 2;
            data.updateCompareHeadacheChecker(2);
          }
        }
      }
      data.updateIsFirstHeadacheChanged(false);
      data.updateCompareHeadacheChecker(2);
    }
  }

  void setMonthlyCompassDataScore(
      Axes userIntensityValue,
      Axes userDisabilityValue,
      Axes userFrequencyValue,
      Axes userDurationValue, CompareCompassInfo data) {
    var intensityScore, disabilityScore, frequencyScore, durationScore;
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
      frequencyScore =
          userFrequencyValue.value /*/ userFrequencyValue.max*/ !* 100.0;

      if (frequencyScore > 100) frequencyScore = 100;
    } else {
      frequencyScore = 0;
    }

    if (userDurationValue.value != null) {
      durationScore =
          userDurationValue.value /*/ userDurationValue.max*/ !* 100.0;
      if (durationScore > 100) durationScore = 100;
    } else {
      durationScore = 0;
    }

    var userTotalScore =
        (intensityScore + disabilityScore + frequencyScore + durationScore) / 4;

    bool isFirstHeadacheChanged = data.isFirstHeadacheChanged();
    int compareHeadacheChecker = data.getCompareHeadacheChecker();

    if(headacheComponentsModel1.headacheScore == -1 || headacheComponentsModel2 == -1){
      headacheComponentsModel1.headacheScore = userTotalScore.round();
      headacheComponentsModel2.headacheScore = userFirstLoggedCompassScoreData;
    }
    else{
      if(isFirstHeadacheChanged || headacheLogged == 0 || headacheDeleted == 0){
        headacheComponentsModel1.headacheScore = userTotalScore.round();
        headacheLogged = 2;
        headacheDeleted = 2;
        data.updateIsFirstHeadacheChanged(false);
      }
      else{
        if(compareHeadacheChecker == 0 || firstHeadacheAdded){
          headacheComponentsModel2.headacheScore = userFirstLoggedCompassScoreData;
          firstHeadacheAdded = false;
          if(firstHeadacheAdded)
            data.updateCompareHeadacheChecker(0);
          data.updateCompareHeadacheChecker(2);
        }
        else if(compareHeadacheChecker == 1 || headacheLogged == 1 || headacheDeleted == 1){
          if(newHeadacheAdded){
            headacheComponentsModel2.headacheScore = userTotalScore.round();
            headacheLogged = 2;
            headacheDeleted = 2;
            data.updateCompareHeadacheChecker(2);
          }
        }
      }
    }
  }

  void setFirstLoggedCompassDataScore(
      Axes? userOverTimeIntensity,
      Axes? userOverTimeDisability,
      Axes? userOverTimeFrequency,
      Axes? userOvertimeDuration) {
    var intensityScore, disabilityScore, frequencyScore, durationScore;
    if (userOverTimeIntensity != null) {
      intensityScore =
          userOverTimeIntensity.value !/ userOverTimeIntensity.max! * 100.0;
    } else {
      intensityScore = 0;
    }
    if (userOverTimeDisability != null) {
      disabilityScore =
          userOverTimeDisability.value !/ userOverTimeDisability.max! * 100.0;
    } else {
      disabilityScore = 0;
    }
    if (userOverTimeFrequency != null) {
      frequencyScore = (31 - userOverTimeFrequency.value!) /
          userOverTimeFrequency.max! *
          100.0;
    } else {
      frequencyScore = 0;
    }
    if (userOvertimeDuration != null) {
      durationScore =
          userOvertimeDuration.value !/ userOvertimeDuration.max! * 100.0;
    } else {
      durationScore = 0;
    }

    debugPrint(
        'intensityScore???$intensityScore???disabilityScore???$disabilityScore???frequencyScore???$frequencyScore???durationScore???$durationScore');

    var userTotalScore =
        (intensityScore + disabilityScore + frequencyScore + durationScore) / 4;
      userFirstLoggedCompassScoreData = userTotalScore.round();
    debugPrint('userTotalScore???$userFirstLoggedCompassScoreData');
    debugPrint('$userFirstLoggedCompassScoreData');
  }

  @override
  bool get wantKeepAlive => true;

  void _openHeadacheTypeActionSheet(
      List<HeadacheListDataModel> headacheListData, bool isFirstLoggedScore, CompareCompassInfo data) async {

    setState(() {
      _isShowAlert = false;
    });

    if(isFirstLoggedScore && headacheListData[0].text != Constant.firstLoggedScore)
      headacheListData.insert(0, HeadacheListDataModel(text: Constant.firstLoggedScore, isSelected: (data.getCompareHeadacheChecker() == 0)));
    if(!isFirstLoggedScore){
      if(headacheListData[0].text == Constant.firstLoggedScore){
        headacheListData.removeAt(0);
      }
    }

    if(isFirstLoggedScore){
      if(headacheComponentsModel2.headacheName != Constant.blankString){
        var lastSelectedHeadacheNameData = headacheListData.firstWhereOrNull(
                (element) => element.text == headacheComponentsModel2.headacheName);
        for(int i=0 ; i<headacheListData.length ; i++){
          headacheListData[i].isSelected = false;
        }
        if (lastSelectedHeadacheNameData != null) {
          lastSelectedHeadacheNameData.isSelected = true;
        }
      }
    }
    else{
      if(headacheComponentsModel1.headacheName != Constant.blankString){
        var lastSelectedHeadacheNameData = headacheListData.firstWhereOrNull(
                (element) => element.text == headacheComponentsModel1.headacheName);
        for(int i=0 ; i<headacheListData.length ; i++){
          headacheListData[i].isSelected = false;
        }
        if (lastSelectedHeadacheNameData != null) {
          lastSelectedHeadacheNameData.isSelected = true;
        }
      }
    }

    ///opening sheets:
    if(isFirstLoggedScore){
      var resultFromActionSheet = await widget.openActionSheetCallback(
          Constant.compassHeadacheTypeActionSheet, CompassHeadacheTypeActionSheetModel(initialSelectedHeadacheName: headacheComponentsModel2.headacheName ?? headacheListData[headacheListData.length-1].text ?? '', headacheListModelData: headacheListData));
      if(resultFromActionSheet != null){
        newHeadacheAdded = true;
        if(resultFromActionSheet == Constant.firstLoggedScore){
          data.updateCompareHeadacheChecker(0);
          data.updateCompareCompassInfo(3, false);
          headacheComponentsModel2.headacheName = resultFromActionSheet;
          headacheListModelData = headacheListData;
        }
        else{
          if(resultFromActionSheet != headacheComponentsModel1.headacheName){
            data.updateCompareHeadacheChecker(1);
            headacheComponentsModel2.headacheName = resultFromActionSheet;
            headacheListModelData = headacheListData;
            _recordsCompassScreenBloc.initNetworkStreamController();
            debugPrint('show api loader 14');
            CompassInfo compassInfo = Provider.of<CompassInfo>(context, listen: false);
            if (compassInfo.getCurrentIndex() == 1) {
              widget.showApiLoaderCallback(
                  _recordsCompassScreenBloc.networkDataStream,
                      () {
                    _recordsCompassScreenBloc.enterSomeDummyDataToStreamController();
                    requestService(
                        firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
                        headacheComponentsModel2.headacheName ?? '');
                  });
            }
            requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
                headacheComponentsModel2.headacheName ?? '');

            debugPrint(resultFromActionSheet);
          }
          else{
            setState(() {
              _isShowAlert = true;
              _errorMsg = Constant.compareHeadacheErrorMessage;
            });
          }
        }
      }
    }
    else{
      var resultFromActionSheet = await widget.openActionSheetCallback(
          Constant.compassHeadacheTypeActionSheet, CompassHeadacheTypeActionSheetModel(initialSelectedHeadacheName: headacheComponentsModel1.headacheName ?? headacheListData[headacheListData.length-1].text ?? '', headacheListModelData: headacheListData));
      if(resultFromActionSheet != null) {
        newHeadacheAdded = true;
        if (resultFromActionSheet != headacheComponentsModel2.headacheName) {
          data.updateIsFirstHeadacheChanged(true);
          headacheComponentsModel1.headacheName = resultFromActionSheet;
          headacheListModelData = headacheListData;
          _recordsCompassScreenBloc.initNetworkStreamController();
          debugPrint('show api loader 14');
          CompassInfo compassInfo =
          Provider.of<CompassInfo>(context, listen: false);
          if (compassInfo.getCurrentIndex() == 1) {
            widget.showApiLoaderCallback(
                _recordsCompassScreenBloc.networkDataStream, () {
              _recordsCompassScreenBloc
                  .enterSomeDummyDataToStreamController();
              requestService(firstDayOfTheCurrentMonth,
                  lastDayOfTheCurrentMonth, headacheComponentsModel1.headacheName ?? '');
            });
          }
          requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
              headacheComponentsModel1.headacheName ?? '');

          debugPrint(resultFromActionSheet);
        }
        else{
          setState(() {
            _isShowAlert = true;
            _errorMsg = Constant.compareHeadacheErrorMessage;
          });
        }
      }
    }
  }

  void _updateCompassData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String isSeeMoreClicked = sharedPreferences.getString(Constant.isSeeMoreClicked) ?? Constant.blankString;
    String isTrendsClicked = sharedPreferences.getString(Constant.isViewTrendsClicked) ?? Constant.blankString;
    String updateCompareCompassData = sharedPreferences.getString(Constant.updateCompareCompassData) ?? Constant.blankString;
    String newHeadacheName = sharedPreferences.getString(Constant.userHeadacheName) ?? Constant.blankString;

    if (isSeeMoreClicked.isEmpty && isTrendsClicked.isEmpty && updateCompareCompassData == Constant.trueString) {
      sharedPreferences.remove(Constant.updateCompareCompassData);
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
      debugPrint('updateData: compare compass');
      _recordsCompassScreenBloc.initNetworkStreamController();
      debugPrint('show api loader 17');
      CompassInfo compassInfo = Provider.of<CompassInfo>(context, listen: false);

      if (newHeadacheName != Constant.blankString) {
        headacheComponentsModel1.headacheName = newHeadacheName;
        headacheComponentsModel2.headacheName = Constant.firstLoggedScore;
        firstHeadacheAdded = true;
        sharedPreferences.setString(Constant.userHeadacheName, Constant.blankString);
      }

      _loggedHeadacheHandler(sharedPreferences, compassInfo);


      sharedPreferences.setString(Constant.updateCompareCompassData, Constant.falseString);
    }
  }

  ///handeles the deletion of headache in updateCompass]
  void _deletedHeadacheHandler(CompareCompassInfo compassInfoData, RecordsCompareCompassModel snapshotData) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    CompassInfo compassInfo = Provider.of<CompassInfo>(context, listen: false);

    String deletedHeadache = sharedPreferences.getString(Constant.deletedHeadacheName) ?? Constant.blankString;

    List<HeadacheListDataModel> headacheListModelData = snapshotData.headacheListDataModel ?? [];

    if (compassInfo.getCurrentIndex() == 1) {
      if(deletedHeadache != Constant.blankString && headacheListModelData.isNotEmpty){
        if(deletedHeadache == headacheComponentsModel1.headacheName){
          headacheDeleted = 0;
          headacheComponentsModel1.headacheName =
              headacheListModelData[headacheListModelData.length - 1]
                  .text;
          compassInfoData.updateIsFirstHeadacheChanged(true);
          if(headacheListModelData.length == 1){
            headacheComponentsModel2.headacheName =
                Constant.firstLoggedScore;
            compassInfoData.updateCompareHeadacheChecker(0);
          }

          widget.showApiLoaderCallback(
              _recordsCompassScreenBloc.networkDataStream,
                  () {
                _recordsCompassScreenBloc.enterSomeDummyDataToStreamController();
                requestService(
                    firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
                    headacheComponentsModel1.headacheName ?? '');
              });
        }
        else if(deletedHeadache == headacheComponentsModel2.headacheName){
          headacheDeleted = 1;
          headacheComponentsModel2.headacheName =
              Constant.firstLoggedScore;
          compassInfoData.updateCompareHeadacheChecker(0);
        }
      }
    }

    if(deletedHeadache != Constant.blankString){
      if(deletedHeadache == headacheComponentsModel1.headacheName){
        requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
            headacheComponentsModel1.headacheName ?? '');
      }
      else if(deletedHeadache == headacheComponentsModel2.headacheName){
        requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
            headacheComponentsModel2.headacheName ?? '');
      }
    }
    sharedPreferences.setString(Constant.deletedHeadacheName, Constant.blankString);
  }


  ///handeles the logging of headache in updateCompass
  void _loggedHeadacheHandler(SharedPreferences sharedPreferences, CompassInfo compassInfo){
    String loggedHeadache = sharedPreferences.getString(Constant.loggedHeadacheName) ?? Constant.blankString;

    if (compassInfo.getCurrentIndex() == 1) {
      if(loggedHeadache != Constant.blankString){
        if(loggedHeadache == headacheComponentsModel1.headacheName){
          headacheLogged = 0;
          widget.showApiLoaderCallback(
              _recordsCompassScreenBloc.networkDataStream,
                  () {
                _recordsCompassScreenBloc.enterSomeDummyDataToStreamController();
                requestService(
                    firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
                    headacheComponentsModel1.headacheName ?? '');
              });
        }
        else if(loggedHeadache == headacheComponentsModel2.headacheName){
          headacheLogged = 1;
          widget.showApiLoaderCallback(
              _recordsCompassScreenBloc.networkDataStream,
                  () {
                _recordsCompassScreenBloc.enterSomeDummyDataToStreamController();
                requestService(
                    firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
                    headacheComponentsModel2.headacheName ?? '');
              });
        }
      }
      else{
        newHeadacheAdded = false;
        widget.showApiLoaderCallback(
            _recordsCompassScreenBloc.networkDataStream,
                () {
              _recordsCompassScreenBloc.enterSomeDummyDataToStreamController();
              requestService(
                  firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
                  headacheComponentsModel1.headacheName ?? '');
            });
      }
    }

    if(loggedHeadache != Constant.blankString){
      if(loggedHeadache == headacheComponentsModel1.headacheName){
        requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
            headacheComponentsModel1.headacheName ?? '');
      }
      else if(loggedHeadache == headacheComponentsModel2.headacheName){
        requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
            headacheComponentsModel2.headacheName ?? '');
      }
    }
    else{
      requestService(firstDayOfTheCurrentMonth, lastDayOfTheCurrentMonth,
          headacheComponentsModel1.headacheName ?? '');
    }
    sharedPreferences.setString(Constant.loggedHeadacheName, Constant.blankString);
  }



  void navigateToHeadacheStartScreen() async {
    await widget.navigateToOtherScreenCallback(
        Constant.headacheStartedScreenRouter, null);
    Utils.setAnalyticsCurrentScreen(Constant.compassScreen,context);
  }

  void _setPreviousMonthAxesData(
      RecordsCompareCompassModel recordsCompassAxesResultModel) {
    List<Axes> previousMonthCompassAxesListData = recordsCompassAxesResultModel
        .recordsCompareCompassAxesResultModel!.previousAxes!;
    print(recordsCompassAxesResultModel);
    var userFrequency = previousMonthCompassAxesListData.firstWhereOrNull(
            (intensityElement) => intensityElement.name == Constant.frequency);
    if (userFrequency != null) {
      _compassTutorialModelMonthly.previousMonthFrequency =
          userFrequency.total!.round();
    } else {
      _compassTutorialModelMonthly.previousMonthFrequency = 0;
    }
    var userDuration = previousMonthCompassAxesListData.firstWhereOrNull(
            (intensityElement) => intensityElement.name == Constant.duration);
    if (userDuration != null) {
      _compassTutorialModelMonthly.previousMonthDuration =
          (userDuration.total)!.round();
    } else {
      _compassTutorialModelMonthly.previousMonthDuration = 0;
    }
    var userIntensity = previousMonthCompassAxesListData.firstWhereOrNull(
            (intensityElement) => intensityElement.name == Constant.intensity);
    if (userIntensity != null) {
      _compassTutorialModelMonthly.previousMonthIntensity =
          userIntensity.value!.round();
    } else {
      _compassTutorialModelMonthly.previousMonthIntensity = 0;
    }
    var userDisability = previousMonthCompassAxesListData.firstWhereOrNull(
            (intensityElement) => intensityElement.name == Constant.disability);
    if (userDisability != null) {
      _compassTutorialModelMonthly.previousMonthDisability =
          userDisability.value!.round();
    } else {
      _compassTutorialModelMonthly.previousMonthDisability = 0;
    }
  }

  CompassTutorialModel _getCompassTutorialModelObj() {
    var compareCompassInfo = Provider.of<CompareCompassInfo>(context, listen: false);
    bool isMonthTapSelected = compareCompassInfo.isMonthTapSelected();

    if (!isMonthTapSelected) {
      return _compassTutorialModelFirstLogged;
    } else {
      return _compassTutorialModelMonthly;
    }
  }

  Future<void> _getUserCurrentHeadacheData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    int? currentPositionOfTabBar =
    sharedPreferences.getInt(Constant.currentIndexOfTabBar);
    dynamic userProfileInfoData =
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
}

class CompareCompassInfo with ChangeNotifier {

  ///for handling the graph animation color and tap on different options
  int _compassValue = 2;
  bool _isMonthTapSelected = true;

  ///0 --> First logged score , 1 --> for compare headache
  int _compareHeadacheChecker = 0;
  ///tells whether the first headache has recently changed or not
  bool _isFirstHeadacheChanged = true;

  int getCompassValue() => _compassValue;
  bool isMonthTapSelected() => _isMonthTapSelected;
  bool isFirstHeadacheChanged() => _isFirstHeadacheChanged;
  int getCompareHeadacheChecker() => _compareHeadacheChecker;

  updateCompareHeadacheChecker(int headacheCheckerValue){
    _compareHeadacheChecker = headacheCheckerValue;
    //notifyListeners();
  }

  updateIsFirstHeadacheChanged(bool isFirstHeadacheChanged){
    _isFirstHeadacheChanged = isFirstHeadacheChanged;
    //notifyListeners();
  }

  updateCompareCompassInfo(int compassValue, bool isMonthTapSelected) {
    _compassValue = compassValue;
    _isMonthTapSelected = isMonthTapSelected;
    notifyListeners();
  }
}

class HeadacheComponentsModel{
  String? headacheName;
  List<int> compassAxisData;
  int headacheScore;

  HeadacheComponentsModel({required this.headacheName, required this.compassAxisData, required this.headacheScore});
}