import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mobile/blocs/RecordsTrendsScreenBloc.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/EditGraphViewFilterModel.dart';
import 'package:mobile/models/HeadacheListDataModel.dart';
import 'package:mobile/models/RecordsTrendsDataModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/MonthYearCupertinoDatePicker.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/TrendsDisabilityScreen.dart';
import 'package:mobile/view/TrendsDurationScreen.dart';
import 'package:mobile/view/TrendsFrequencyScreen.dart';
import 'package:mobile/view/TrendsIntensityScreen.dart';
import 'package:mobile/view/slide_dots.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/models/TrendsFilterModel.dart';

import 'CustomTextWidget.dart';

class TrendsScreen extends StatefulWidget {
  final Function(Stream, Function) showApiLoaderCallback;
  final Future<dynamic> Function(String, dynamic) navigateToOtherScreenCallback;
  final Future<dynamic> Function(String, dynamic) openActionSheetCallback;
  final Future<DateTime> Function(
          MonthYearCupertinoDatePickerMode, Function, DateTime)
      openDatePickerCallback;

  const TrendsScreen({
    Key? key,
    required this.showApiLoaderCallback,
    required this.navigateToOtherScreenCallback,
    required this.openActionSheetCallback,
    required this.openDatePickerCallback,
  }) : super(key: key);

  @override
  _TrendsScreenState createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  PageController? _pageController;
  List<Widget>? pageViewWidgetList;
  RecordsTrendsScreenBloc? _recordsTrendsScreenBloc;
  String? selectedHeadacheName;
  RecordsTrendsDataModel? recordsTrendsDataModel;
  DateTime? _dateTime;
  int? currentMonth;
  int? currentYear;
  int? totalDaysInCurrentMonth;
  String? firstDayOfTheCurrentMonth;
  String? lastDayOfTheCurrentMonth;
  EditGraphViewFilterModel? _editGraphViewFilterModel;

  CurrentUserHeadacheModel? currentUserHeadacheModel;

  var lastSelectedHeadacheName;
  List<TrendsFilterModel> behavioursListData = [];

  List<TrendsFilterModel> medicationsListData = [];

  List<TrendsFilterModel> triggersListData = [];

  String? secondSelectedHeadacheName;
  bool _isInitiallyServiceHit = false;

  @override
  void initState() {
    super.initState();
    recordsTrendsDataModel = RecordsTrendsDataModel();
    _recordsTrendsScreenBloc = RecordsTrendsScreenBloc();
    _pageController = PageController(initialPage: 0);
    pageViewWidgetList = [Container()];

    _editGraphViewFilterModel = EditGraphViewFilterModel();
    _editGraphViewFilterModel!.selectedDateTime = DateTime.now();
    _dateTime = _editGraphViewFilterModel!.selectedDateTime;
    currentMonth = _dateTime!.month;
    currentYear = _dateTime!.year;
    totalDaysInCurrentMonth =
        Utils.daysInCurrentMonth(currentMonth!, currentYear!);
    firstDayOfTheCurrentMonth = Utils.firstDateWithCurrentMonthAndTimeInUTC(
        currentMonth!, currentYear!, 1);
    lastDayOfTheCurrentMonth = Utils.lastDateWithCurrentMonthAndTimeInUTC(
        currentMonth!, currentYear!, totalDaysInCurrentMonth!);
    _isInitiallyServiceHit = false;
  }

  @override
  void didUpdateWidget(TrendsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('in did update widget of trends screen');
    _getUserCurrentHeadacheData();
    requestService(
        firstDayOfTheCurrentMonth!,
        lastDayOfTheCurrentMonth!,
        selectedHeadacheName,
        secondSelectedHeadacheName ?? Constant.blankString,
        secondSelectedHeadacheName != null);
  }

  @override
  void dispose() {
    _recordsTrendsScreenBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<dynamic>(
            stream: _recordsTrendsScreenBloc?.recordsTrendsDataStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == Constant.noHeadacheData) {
                  _editGraphViewFilterModel?.currentTabIndex = 0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CustomTextWidget(
                          text:
                              'We noticed you didn\'t log any headache yet. So please add any headache to see your Trends data.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.3,
                            fontSize: 14,
                            fontFamily: Constant.jostRegular,
                            color: Constant.chatBubbleGreen,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BouncingWidget(
                            onPressed: () async {
                              await widget.navigateToOtherScreenCallback(
                                  Constant.addNewHeadacheIntroScreen,
                                  Constant.trendsScreen);

                              SharedPreferences sharedPreferences =
                                  await SharedPreferences.getInstance();
                              String value = sharedPreferences
                                      .getString(Constant.updateTrendsData) ??
                                  Constant.falseString;

                              if (value == Constant.trueString) {
                                _recordsTrendsScreenBloc
                                    ?.initNetworkStreamController();
                                _updateTrendsData();

                                sharedPreferences.setString(
                                    Constant.updateTrendsData,
                                    Constant.falseString);
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
                                    fontFamily: Constant.jostMedium,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else if (snapshot.data is RecordsTrendsDataModel) {
                  recordsTrendsDataModel = snapshot.data;
                  List<HeadacheListDataModel> headacheListModelData =
                      recordsTrendsDataModel?.headacheListModelData ?? [];

                  if (selectedHeadacheName == null) {
                    selectedHeadacheName = headacheListModelData[headacheListModelData.length - 1].text;
                  }

                  getDotsFilterListData();
                  getCurrentPositionOfTabBar();

                  var trendsInfo =
                      Provider.of<TrendsInfo>(context, listen: false);

                  return Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          CustomTextWidget(
                            text: secondSelectedHeadacheName != null
                                ? '$selectedHeadacheName Vs $secondSelectedHeadacheName'
                                : selectedHeadacheName ??
                                    '$selectedHeadacheName Vs $secondSelectedHeadacheName',
                            style: TextStyle(
                                color: Constant.locationServiceGreen,
                                fontSize: 14,
                                fontFamily: Constant.jostRegular),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  var trendsInfo = Provider.of<TrendsInfo>(
                                      context,
                                      listen: false);
                                  int currentIndex =
                                      trendsInfo.getCurrentIndex();
                                  if (currentIndex != 0) {
                                    currentIndex = currentIndex - 1;
                                    _pageController!.animateToPage(currentIndex,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeIn);
                                    trendsInfo.updateTrendsInfo(currentIndex);
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Constant.backgroundColor
                                      .withOpacity(0.85),
                                  child: Image(
                                    image:
                                        AssetImage(Constant.calenderBackArrow),
                                    width: 15,
                                    height: 15,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 60,
                              ),
                              Consumer<TrendsInfo>(
                                builder: (context, data, child) {
                                  return CustomTextWidget(
                                    text: getCurrentTextView(
                                        data.getCurrentIndex()),
                                    style: TextStyle(
                                        color: Constant.locationServiceGreen,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: Constant.jostMedium),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 60,
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  var trendsInfo = Provider.of<TrendsInfo>(
                                      context,
                                      listen: false);
                                  int currentIndex =
                                      trendsInfo.getCurrentIndex();

                                  if (currentIndex != 3) {
                                    currentIndex = currentIndex + 1;
                                    _pageController!.animateToPage(currentIndex,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeIn);
                                    trendsInfo.updateTrendsInfo(currentIndex);
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Constant.backgroundColor
                                      .withOpacity(0.85),
                                  child: Image(
                                    image:
                                        AssetImage(Constant.calenderNextArrow),
                                    width: 15,
                                    height: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Consumer<TrendsInfo>(
                            builder: (context, data, child) {
                              int currentIndex = data.getCurrentIndex();
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SlideDots(isActive: currentIndex == 0),
                                  SlideDots(isActive: currentIndex == 1),
                                  SlideDots(isActive: currentIndex == 2),
                                  SlideDots(isActive: currentIndex == 3)
                                ],
                              );
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  openEditGraphViewBottomSheet();
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
                                        vertical: 4, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color:
                                          Constant.backgroundTransparentColor,
                                    ),
                                    child: CustomTextWidget(
                                      text: 'Edit graph view',
                                      style: TextStyle(
                                          color: Constant.locationServiceGreen,
                                          fontSize: 12,
                                          fontFamily: Constant.jostRegular),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Visibility(
                                visible: false,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Constant.backgroundColor,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        topLeft: Radius.circular(12)),
                                  ),
                                  child: Image(
                                    image: AssetImage(Constant.barGraph),
                                    width: 15,
                                    height: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: PageView.builder(
                              itemBuilder: (context, index) {
                                MediaQueryData mediaQueryData =
                                    MediaQuery.of(context);
                                return MediaQuery(
                                  data: mediaQueryData.copyWith(
                                    textScaleFactor:
                                        mediaQueryData.textScaleFactor.clamp(
                                            Constant.minTextScaleFactor,
                                            Constant.maxTextScaleFactor),
                                  ),
                                  child: pageViewWidgetList![index],
                                );
                              },
                              controller: _pageController,
                              scrollDirection: Axis.horizontal,
                              onPageChanged: (index) {
                                debugPrint('trends set state 2');
                                int currentIndex = trendsInfo.getCurrentIndex();
                                currentIndex = index;
                                _editGraphViewFilterModel!.currentTabIndex =
                                    currentIndex;
                                trendsInfo.updateTrendsInfo(currentIndex);
                              },
                              reverse: false,
                              itemCount: pageViewWidgetList!.length,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 100),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Constant.barTutorialsTapColor,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  topLeft: Radius.circular(12)),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Utils.showTrendsTutorialDialog(context);
                              },
                              child: Image(
                                image: AssetImage(Constant.barQuestionMark),
                                width: 15,
                                height: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              } else {
                return Container();
              }
            }),
      ),
    );
  }

  void getCurrentPositionOfTabBar() async {
    _editGraphViewFilterModel!.recordsTrendsDataModel = recordsTrendsDataModel;
    if (_editGraphViewFilterModel!.singleTypeHeadacheSelected == null) {
      String? headacheName = recordsTrendsDataModel!
          .headacheListModelData![
              recordsTrendsDataModel!.headacheListModelData!.length - 1]
          .text;
      _editGraphViewFilterModel!
        ..singleTypeHeadacheSelected = headacheName
        ..compareHeadacheTypeSelected1 = headacheName
        ..compareHeadacheTypeSelected2 = headacheName;
    }
    pageViewWidgetList = [
      TrendsIntensityScreen(
        editGraphViewFilterModel: _editGraphViewFilterModel!,
        updateTrendsDataCallback: _updateTrendsData,
        openDatePickerCallback: widget.openDatePickerCallback,
      ),
      TrendsDisabilityScreen(
        editGraphViewFilterModel: _editGraphViewFilterModel!,
        updateTrendsDataCallback: _updateTrendsData,
        openDatePickerCallback: widget.openDatePickerCallback,
      ),
      TrendsFrequencyScreen(
        editGraphViewFilterModel: _editGraphViewFilterModel!,
        updateTrendsDataCallback: _updateTrendsData,
        openDatePickerCallback: widget.openDatePickerCallback,
      ),
      TrendsDurationScreen(
        editGraphViewFilterModel: _editGraphViewFilterModel!,
        updateTrendsDataCallback: _updateTrendsData,
        openDatePickerCallback: widget.openDatePickerCallback,
      ),
    ];
  }

  String getCurrentTextView(int currentIndex) {
    if (currentIndex == 0) {
      return 'Intensity';
    } else if (currentIndex == 1) {
      return 'Disability';
    } else if (currentIndex == 2) {
      return 'Frequency';
    } else if (currentIndex == 3) {
      return 'Duration';
    }
    return 'Intensity';
  }

  void requestService(
      String firstDayOfTheCurrentMonth,
      String lastDayOfTheCurrentMonth,
      String? selectedHeadacheName,
      String? selectedAnotherHeadacheName,
      bool isMultipleHeadacheSelected) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? currentPositionOfTabBar =
        sharedPreferences.getInt(Constant.currentIndexOfTabBar);
    int? recordTabBarPosition =
        sharedPreferences.getInt(Constant.recordTabNavigatorState);
    String isSeeMoreClicked =
        sharedPreferences.getString(Constant.isSeeMoreClicked) ??
            Constant.blankString;
    String updateTrendsData =
        sharedPreferences.getString(Constant.updateTrendsData) ??
            Constant.blankString;

    if (!_isInitiallyServiceHit &&
        currentPositionOfTabBar == 1 &&
        recordTabBarPosition == 2 &&
        isSeeMoreClicked.isEmpty) {
      sharedPreferences.remove(Constant.updateTrendsData);
      _isInitiallyServiceHit = true;
      _recordsTrendsScreenBloc!.initNetworkStreamController();
      print('show api loader 16');
      widget.showApiLoaderCallback(_recordsTrendsScreenBloc!.networkDataStream,
          () {
        _recordsTrendsScreenBloc!.enterSomeDummyDataToStream();
        _recordsTrendsScreenBloc!.fetchAllHeadacheListData(
            firstDayOfTheCurrentMonth,
            lastDayOfTheCurrentMonth,
            selectedHeadacheName,
            selectedAnotherHeadacheName,
            isMultipleHeadacheSelected,
            context);
      });
      _recordsTrendsScreenBloc!.fetchAllHeadacheListData(
          firstDayOfTheCurrentMonth,
          lastDayOfTheCurrentMonth,
          selectedHeadacheName,
          selectedAnotherHeadacheName,
          isMultipleHeadacheSelected,
          context);
    } else if (currentPositionOfTabBar == 1 &&
        recordTabBarPosition == 2 &&
        isSeeMoreClicked.isEmpty &&
        updateTrendsData == Constant.trueString) {
      sharedPreferences.remove(Constant.updateTrendsData);
      var dateTime = _editGraphViewFilterModel!.selectedDateTime;
      int tabIndex = _editGraphViewFilterModel?.currentTabIndex ?? 0;
      _editGraphViewFilterModel = EditGraphViewFilterModel();
      _editGraphViewFilterModel?.currentTabIndex = tabIndex;
      _editGraphViewFilterModel?.selectedDateTime = dateTime;
      this.selectedHeadacheName = null;
      secondSelectedHeadacheName = null;
      _recordsTrendsScreenBloc!.initNetworkStreamController();
      debugPrint('show api loader 15');
      debugPrint('updateData: trends screen');
      widget.showApiLoaderCallback(_recordsTrendsScreenBloc!.networkDataStream,
          () {
        _recordsTrendsScreenBloc!.enterSomeDummyDataToStream();
        _recordsTrendsScreenBloc!.fetchAllHeadacheListData(
            firstDayOfTheCurrentMonth,
            lastDayOfTheCurrentMonth,
            this.selectedHeadacheName,
            selectedAnotherHeadacheName,
            isMultipleHeadacheSelected,
            context);
      });
      debugPrint(
          'Start Day: $firstDayOfTheCurrentMonth ????? LastDay: $lastDayOfTheCurrentMonth');
      _recordsTrendsScreenBloc!.fetchAllHeadacheListData(
          firstDayOfTheCurrentMonth,
          lastDayOfTheCurrentMonth,
          this.selectedHeadacheName,
          selectedAnotherHeadacheName,
          isMultipleHeadacheSelected,
          context);
    }
  }

  void navigateToHeadacheStartScreen() async {
    await widget.navigateToOtherScreenCallback(
        Constant.headacheStartedScreenRouter, null);
    Utils.setAnalyticsCurrentScreen(Constant.trendsScreen, context);
  }

  void openEditGraphViewBottomSheet() async {
    var resultFromActionSheet = await widget.openActionSheetCallback(
        Constant.editGraphViewBottomSheet, _editGraphViewFilterModel);
    if (resultFromActionSheet == Constant.success) {
      _isInitiallyServiceHit = false;

      if (_editGraphViewFilterModel!.headacheTypeRadioButtonSelected ==
          Constant.viewSingleHeadache) {
        secondSelectedHeadacheName = null;
        selectedHeadacheName =
            _editGraphViewFilterModel!.singleTypeHeadacheSelected;
        _pageController!.animateToPage(
            _editGraphViewFilterModel!.currentTabIndex,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn);
        secondSelectedHeadacheName = null;

        requestService(firstDayOfTheCurrentMonth!, lastDayOfTheCurrentMonth!,
            selectedHeadacheName!, '', false);
      } else {
        selectedHeadacheName =
            _editGraphViewFilterModel!.compareHeadacheTypeSelected1;
        secondSelectedHeadacheName =
            _editGraphViewFilterModel!.compareHeadacheTypeSelected2;
        _pageController!.animateToPage(
            _editGraphViewFilterModel!.currentTabIndex,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn);
        requestService(firstDayOfTheCurrentMonth!, lastDayOfTheCurrentMonth!,
            selectedHeadacheName!, secondSelectedHeadacheName!, true);
      }
    }
    debugPrint(resultFromActionSheet);
  }

  //it is used to check whether any or both of the compared headaches are already deleted or not
  void compareHeadachesChecker(
      List<HeadacheListDataModel> headacheListDataModelList) {
    HeadacheListDataModel? firstHeadache =
        headacheListDataModelList.firstWhereOrNull((element) =>
            element.text ==
            _editGraphViewFilterModel!.compareHeadacheTypeSelected1);
    HeadacheListDataModel? secondHeadache =
        headacheListDataModelList.firstWhereOrNull((element) =>
            element.text ==
            _editGraphViewFilterModel!.compareHeadacheTypeSelected2);
    if (firstHeadache == null && secondHeadache == null) {
      _editGraphViewFilterModel!.headacheTypeRadioButtonSelected =
          Constant.viewSingleHeadache;
      _editGraphViewFilterModel!.singleTypeHeadacheSelected =
          headacheListDataModelList[0].text;
    } else if (firstHeadache == null || secondHeadache == null) {
      _editGraphViewFilterModel!.headacheTypeRadioButtonSelected =
          Constant.viewSingleHeadache;
      _editGraphViewFilterModel!.singleTypeHeadacheSelected =
          firstHeadache?.text ?? secondHeadache?.text;
    }
  }

  void getDotsFilterListData() {
    triggersListData = [];
    medicationsListData = [];
    behavioursListData = [];
    _editGraphViewFilterModel!.trendsFilterListModel = TrendsFilterListModel();
    _editGraphViewFilterModel!.trendsFilterListModel!.triggersListData = [];
    _editGraphViewFilterModel!.trendsFilterListModel!.medicationListData = [];
    _editGraphViewFilterModel!.trendsFilterListModel!.behavioursListData = [];

    behavioursListData
        .add(TrendsFilterModel(dotName: 'Exercise', occurringDateList: []));
    behavioursListData
        .add(TrendsFilterModel(dotName: 'Reg. meals', occurringDateList: []));
    behavioursListData
        .add(TrendsFilterModel(dotName: 'Good sleep', occurringDateList: []));

    recordsTrendsDataModel!.behaviors!.forEach((behavioursElement) {
      behavioursElement.data!.forEach((dataElement) {
        if (dataElement.behaviorPreexercise == 'Yes') {
          behavioursListData[0].occurringDateList!.add(behavioursElement.date!);
        } else if (dataElement.behaviorPremeal == 'Yes') {
          behavioursListData[1].occurringDateList!.add(behavioursElement.date!);
        } else if (dataElement.behaviorPresleep == 'Yes') {
          behavioursListData[2].occurringDateList!.add(behavioursElement.date!);
        }
      });
    });

    recordsTrendsDataModel!.triggers!.forEach((triggersElement) {
      triggersElement.data!.forEach((dataElement) {
        dataElement.triggers1!.forEach((triggers1Element) {
          var triggersDotName = triggersListData.firstWhereOrNull(
              (element) => element.dotName == triggers1Element);
          if (triggersDotName == null) {
            triggersListData.add(TrendsFilterModel(
                dotName: triggers1Element,
                occurringDateList: [triggersElement.date!],
                numberOfOccurrence: 1));
          } else {
            triggersDotName.occurringDateList!.add(triggersElement.date!);
            triggersDotName.numberOfOccurrence =
                triggersDotName.numberOfOccurrence! + 1;
          }
        });
      });
    });

    triggersListData
        .sort((a, b) => b.numberOfOccurrence!.compareTo(a.numberOfOccurrence!));

    print('TriggersListData $triggersListData');

    recordsTrendsDataModel!.medication!.forEach((medicationElement) {
      medicationElement.data!.forEach((dataElement) {
        dataElement.medication!.forEach((medicationDataElement) {
          var medicationDotName = medicationsListData.firstWhereOrNull(
              (element) => element.dotName == medicationDataElement);
          if (medicationDotName == null) {
            medicationsListData.add(TrendsFilterModel(
                dotName: medicationDataElement,
                occurringDateList: [medicationElement.date!],
                numberOfOccurrence: 1));
          } else {
            medicationDotName.occurringDateList!.add(medicationElement.date!);
            medicationDotName.numberOfOccurrence =
                medicationDotName.numberOfOccurrence! + 1;
          }
        });
      });
    });

    medicationsListData
        .sort((a, b) => b.numberOfOccurrence!.compareTo(a.numberOfOccurrence!));
    print('MedicationListData $triggersListData');
    _editGraphViewFilterModel!.trendsFilterListModel!.triggersListData =
        triggersListData;
    _editGraphViewFilterModel!.trendsFilterListModel!.behavioursListData =
        behavioursListData;
    _editGraphViewFilterModel!.trendsFilterListModel!.medicationListData =
        medicationsListData;
    print('AllModelsData $_editGraphViewFilterModel');
    _editGraphViewFilterModel!.numberOfDaysInMonth = totalDaysInCurrentMonth!;
  }

  void _updateTrendsData() async {
    _isInitiallyServiceHit = false;
    _dateTime = _editGraphViewFilterModel!.selectedDateTime;
    currentMonth = _dateTime!.month;
    currentYear = _dateTime!.year;
    totalDaysInCurrentMonth =
        Utils.daysInCurrentMonth(currentMonth!, currentYear!);
    firstDayOfTheCurrentMonth = Utils.firstDateWithCurrentMonthAndTimeInUTC(
        currentMonth!, currentYear!, 1);
    lastDayOfTheCurrentMonth = Utils.lastDateWithCurrentMonthAndTimeInUTC(
        currentMonth!, currentYear!, totalDaysInCurrentMonth!);
    if (_editGraphViewFilterModel!.headacheTypeRadioButtonSelected ==
        Constant.viewSingleHeadache) {
      requestService(firstDayOfTheCurrentMonth!, lastDayOfTheCurrentMonth!,
          selectedHeadacheName ?? '', '', false);
    } else {
      requestService(firstDayOfTheCurrentMonth!, lastDayOfTheCurrentMonth!,
          selectedHeadacheName ?? '', secondSelectedHeadacheName!, true);
    }
  }

  Future<void> _getUserCurrentHeadacheData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    int? currentPositionOfTabBar =
        sharedPreferences.getInt(Constant.currentIndexOfTabBar);
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    if (currentPositionOfTabBar == 1) {
      currentUserHeadacheModel = await SignUpOnBoardProviders.db
          .getUserCurrentHeadacheData(userProfileInfoData.userId!);
    }
  }
}

class TrendsInfo with ChangeNotifier {
  int _currentIndex = 0;

  int getCurrentIndex() => _currentIndex;

  updateTrendsInfo(int currentIndex) {
    _currentIndex = currentIndex;
    notifyListeners();
  }
}
