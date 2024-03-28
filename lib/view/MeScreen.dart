import 'dart:async';
import 'package:collection/collection.dart';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/LogDayScreenArgumentModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/blocs/CalendarScreenBloc.dart';
import 'package:mobile/models/UserLogHeadacheDataCalendarModel.dart';
import 'package:mobile/util/CalendarUtil.dart';
import 'package:mobile/util/TabNavigatorRoutes.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomRichTextWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ConsecutiveSelectedDateWidget.dart';
import 'DateWidget.dart';
import 'LogStudyMedicationDialog.dart';
import 'YesterdayLogDialog.dart';

class MeScreen extends StatefulWidget {
  final Future<dynamic> Function(String, dynamic) navigateToOtherScreenCallback;
  final Function(Stream, Function) showApiLoaderCallback;
  final Function(GlobalKey, GlobalKey) getButtonsGlobalKeyCallback;
  final Stream pushNotificationStream;

  const MeScreen(
      {Key? key,
      required this.navigateToOtherScreenCallback,
      required this.showApiLoaderCallback,
      required this.getButtonsGlobalKeyCallback,
      required this.pushNotificationStream})
      : super(key: key);

  @override
  _MeScreenState createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen>
    with SingleTickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  List<Widget> currentWeekListData = [];
  AnimationController? _animationController;
  int? currentMonth;
  int? currentYear;
  String? monthName;
  String? firstDayOfTheCurrentWeek;
  String? lastDayOfTheCurrentWeek;
  CalendarScreenBloc _calendarScreenBloc = CalendarScreenBloc();
  UserLogHeadacheDataCalendarModel userLogHeadacheDataCalendarModel = UserLogHeadacheDataCalendarModel();

  GlobalKey _logDayGlobalKey = GlobalKey();
  GlobalKey _addHeadacheGlobalKey = GlobalKey();

  String userName = "";

  bool _isServiceCalling = false;
  bool _isTutorialHasSeen = false;
  bool _isButtonClicked = false;

  String? _title;
  @override
  void initState() {
    super.initState();

    _getUserProfileDetails();

    _calendarScreenBloc = CalendarScreenBloc();
    userLogHeadacheDataCalendarModel = UserLogHeadacheDataCalendarModel();
    _animationController = AnimationController(
        duration: Duration(milliseconds: 350),
        reverseDuration: Duration(milliseconds: 0),
        vsync: this);

    _dateTime = DateTime.now();
    currentMonth = _dateTime.month;
    currentYear = _dateTime.year;
    monthName = Utils.getMonthName(currentMonth!);

    debugPrint('_dateTime.weekday???${_dateTime.weekday}');
    var currentWeekDate =
        _dateTime.subtract(Duration(days: _dateTime.weekday != 7 ? _dateTime.weekday : 0));
    debugPrint('CurrentWeekDate????$currentWeekDate');
    /*firstDayOfTheCurrentWeek = Utils.firstDateWithCurrentMonthAndTimeInUTC(
        currentWeekDate.month, currentWeekDate.year, currentWeekDate.day);

    var currentWeekLastDate = currentWeekDate.add(Duration(days: 6));
    lastDayOfTheCurrentWeek = Utils.firstDateWithCurrentMonthAndTimeInUTC(
        currentWeekLastDate.month,
        currentWeekLastDate.year,
        currentWeekLastDate.day);*/


    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      lastDayOfTheCurrentWeek = Utils.firstDateWithCurrentMonthAndTimeInUTC(_dateTime.month, _dateTime.year, _dateTime.day);

      DateTime firstDayOfWeekDateTime = _dateTime.subtract(Duration(days: 6));
      firstDayOfTheCurrentWeek = Utils.firstDateWithCurrentMonthAndTimeInUTC(firstDayOfWeekDateTime.month, firstDayOfWeekDateTime.year, firstDayOfWeekDateTime.day);

      widget.showApiLoaderCallback(_calendarScreenBloc.networkDataStream, () {
        _calendarScreenBloc.enterSomeDummyDataToStreamController();
        print('called service 2');
        _isServiceCalling = true;
        requestService(firstDayOfTheCurrentWeek!, lastDayOfTheCurrentWeek);
      });

      requestService(firstDayOfTheCurrentWeek!, lastDayOfTheCurrentWeek);
    });
    print('called service 1');
    _isServiceCalling = true;

    _saveRecordTabBarPosition();
    widget.pushNotificationStream.listen((event) async {
      if(event is String) {
        _title = event;
        Future.delayed(Duration(milliseconds: 500), () {
          debugPrint('isServiceCalling????$_isServiceCalling');
          if(!_isServiceCalling) {
            _handlePushNotificationData();
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant MeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('in did update widget of me screen');
    _getCurrentIndexOfTabBar();
    _updateMeScreenData();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('me screen build func');

    debugPrint('appconfig1');
    var appConfig = AppConfig.of(context);
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizeTransition(
              sizeFactor: _animationController!,
              child: Container(
                color: Constant.addCustomNotificationTextColor,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if(_isTutorialHasSeen)
                          _navigateToOtherScreen();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Consumer<CurrentUserHeadacheInfo>(
                            builder: (context, data, child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  CustomRichTextWidget(
                                    text: TextSpan(
                                      children: _getBannerTextSpan(data.getCurrentUserHeadacheModel(), appConfig!)
                                    ),
                                  ),
                                  /*CustomTextWidget(
                                    text: _getNotificationText(data.getCurrentUserHeadacheModel()),
                                    style: TextStyle(
                                        color: Constant.bubbleChatTextView,
                                        fontFamily: Constant.jostRegular,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                  ),
                                  CustomTextWidget(
                                    text: _getNotificationBottomText(data.getCurrentUserHeadacheModel()),
                                    style: TextStyle(
                                        color: Constant.bubbleChatTextView,
                                        fontFamily: Constant.jostMedium,
                                        fontSize: 14),
                                  ),*/
                                ],
                              );
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<OnBoardAssessIncompleteInfo>(
                      builder: (context, data, child) {
                        return SizedBox(
                          height: data.isOnBoardAssessmentInComplete() ? 0 : 70,
                        );
                      },
                    ),
                    StreamBuilder<dynamic>(
                        stream: _calendarScreenBloc.calendarDataStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            userLogHeadacheDataCalendarModel = snapshot.data;

                            if(appConfig?.buildFlavor == Constant.tonixBuildFlavor)
                              _getUserCurrentHeadacheData();

                            setUserWeekData(userLogHeadacheDataCalendarModel);
                            Future.delayed(Duration(milliseconds: 450), () {
                              _isTutorialHasSeen = true;
                            });
                            widget.getButtonsGlobalKeyCallback(
                                _logDayGlobalKey, _addHeadacheGlobalKey);
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12),
                              decoration: BoxDecoration(
                                color: Color(0xCC0E232F),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                                        child: CustomTextWidget(
                                          text: 'THIS WEEK:',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Constant.chatBubbleGreen,
                                              fontFamily: Constant.jostMedium),
                                        ),
                                      ),
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          if(_isTutorialHasSeen) {
                                            if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
                                              widget.navigateToOtherScreenCallback(
                                                  TabNavigatorRoutes
                                                      .calenderRoute,
                                                  null);
                                              Utils.saveDataInSharedPreference(
                                                  Constant.isSeeMoreClicked, Constant.trueString);
                                            } else {
                                              _showYesterdayLogDialog();
                                            }
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
                                          child: CustomTextWidget(
                                            text: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? 'SEE MORE >' : _getYesterdayLogText().toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Constant.chatBubbleGreen,
                                                fontFamily: Constant.jostMedium,
                                              decorationColor: Constant.chatBubbleGreen,
                                              decoration: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? TextDecoration.none : TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Table(
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    children: [
                                      TableRow(children: _getWeekDaysWidgetList()),
                                      TableRow(children: currentWeekListData),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              ),
                            );
                          } else {
                            return Container(
                              height: 100,
                            );
                          }
                        }),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 65, vertical: 40),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: <Color>[
                                Color(0xff0E4C47),
                                Color(0x910E4C47),
                              ]),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Constant.chatBubbleGreen,
                            width: 2,
                          )),
                      child: Column(
                        children: [
                          Consumer<UserNameInfo>(
                            builder: (context, data, child) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: CustomTextWidget(
                                  text: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? 'Hey ${nameLengthChecker(data.getUserName())}!' : 'Hi!',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: Constant.jostMedium,
                                      color: Constant.chatBubbleGreen),
                                ),
                              );
                            },
                          ),
                          CustomTextWidget(
                              text: '${appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? '\n' : Constant.blankString}What\'s been\ngoing on today?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: Constant.jostMedium,
                                  color: Constant.chatBubbleGreen)),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? _getLogDayButton(appConfig!) : _getAddHeadacheButton(appConfig!),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? _getAddHeadacheButton(appConfig) : _getLogDayButton(appConfig),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _calendarScreenBloc.dispose();
    super.dispose();
  }

  void _checkForProfileIncomplete() async {
    debugPrint('appconfig2');
    var appConfig = AppConfig.of(context);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    bool? isProfileInComplete = sharedPreferences.getBool(Constant.isProfileInCompleteStatus);

    var onBoardAssessmentInCompleteInfo = Provider.of<OnBoardAssessIncompleteInfo>(context, listen: false);

    String bannerMessage = Constant.blankString;
    String bannerBottomMessage = Constant.blankString;


    if (appConfig?.buildFlavor == Constant.tonixBuildFlavor) {
      var headacheData = userLogHeadacheDataCalendarModel.addHeadacheListData.firstWhereOrNull((element) => element.selectedDay == DateTime.now().subtract(Duration(days: 1)).day.toString());
      var studyMedicationData = userLogHeadacheDataCalendarModel.studyMedicationList.firstWhereOrNull((element) => element.selectedDay == DateTime.now().subtract(Duration(days: 1)).day.toString());

      debugPrint("Banner 2");
      if(headacheData == null && studyMedicationData == null) {
        isProfileInComplete = true;
        bannerMessage = "Missing entry and record for yesterday's log and AM/PM study medications.";
        bannerBottomMessage = "(Click here to add and record this now)";
      } else if (headacheData == null) {
        isProfileInComplete = true;
        bannerMessage = "Missing entry for yesterday's log.";
        bannerBottomMessage = "(Click here to add this now)";
      } else if(studyMedicationData == null) {
        isProfileInComplete = true;
        bannerMessage = "Missing record for yesterday's AM/PM study medication.";
        bannerBottomMessage = "(Click here to record this now)";
      } else {
        isProfileInComplete = false;
      }
    }

    onBoardAssessmentInCompleteInfo.updateOnBoardAssessmentInComplete(isProfileInComplete!, bannerMessage, bannerBottomMessage);

    var currentHeadacheModelInfo = Provider.of<CurrentUserHeadacheInfo>(context, listen: false);
    currentHeadacheModelInfo.updateCurrentUserHeadacheModel(currentHeadacheModelInfo.getCurrentUserHeadacheModel());

    if (onBoardAssessmentInCompleteInfo.isOnBoardAssessmentInComplete() && (isProfileInComplete)) {
      if (onBoardAssessmentInCompleteInfo.isOnBoardAssessmentInComplete()) {
        _animationController!.forward();
      }
    } else {
      //onBoardAssessmentInCompleteInfo.updateOnBoardAssessmentInComplete(false);
      _animationController!.reverse();
    }
  }

  void _navigateUserToHeadacheLogScreen(AppConfig appConfig) async {
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    CurrentUserHeadacheModel? currentUserHeadacheModel;

    if (userProfileInfoData != null)
      currentUserHeadacheModel = await SignUpOnBoardProviders.db.getUserCurrentHeadacheData(userProfileInfoData.userId!);

    if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor) {
      if (currentUserHeadacheModel == null) {
        await widget.navigateToOtherScreenCallback(
            Constant.headacheStartedScreenRouter, null);
      } else {
        if (currentUserHeadacheModel.isOnGoing!) {
          await widget.navigateToOtherScreenCallback(
              Constant.currentHeadacheProgressScreenRouter, null);
        } else {
          var appConfig = AppConfig.of(context);

          if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
            await widget.navigateToOtherScreenCallback(Constant.addHeadacheOnGoingScreenRouter, currentUserHeadacheModel);
          else
            await widget.navigateToOtherScreenCallback(Constant.tonixAddHeadacheScreen, currentUserHeadacheModel);
        }
      }
    } else {
      if (currentUserHeadacheModel == null) {
        currentUserHeadacheModel = CurrentUserHeadacheModel(
          userId: userProfileInfoData.userId,
          selectedDate: Utils.getDateTimeInUtcFormat(DateTime.now(), true, context),
          isOnGoing: true,
          isFromServer: false,
          isFromRecordScreen: false,
        );

        var appConfig = AppConfig.of(context);

        if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
          await widget.navigateToOtherScreenCallback(Constant.addHeadacheOnGoingScreenRouter, currentUserHeadacheModel);
        else
          await widget.navigateToOtherScreenCallback(Constant.tonixAddHeadacheScreen, currentUserHeadacheModel);
      } else {
        if (currentUserHeadacheModel.isOnGoing!) {
          await widget.navigateToOtherScreenCallback(
              Constant.currentHeadacheProgressScreenRouter, null);
        } else {
          if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
            await widget.navigateToOtherScreenCallback(Constant.addHeadacheOnGoingScreenRouter, currentUserHeadacheModel);
          else
            await widget.navigateToOtherScreenCallback(Constant.tonixAddHeadacheScreen, currentUserHeadacheModel);
        }
      }
    }

    Utils.setAnalyticsCurrentScreen(Constant.meScreen, context);

    _getUserCurrentHeadacheData();
    _updateMeScreenData();
  }

  void requestService(
      String firstDayOfTheCurrentWeek, lastDayOfTheCurrentWeek) async {
    var currentUserHeadacheInfo = Provider.of<CurrentUserHeadacheInfo>(context, listen: false);
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    debugPrint('appconfig3');
    var appConfig = AppConfig.of(context);

    if(currentUserHeadacheInfo.getCurrentUserHeadacheModel() == null) {
      await _calendarScreenBloc.fetchUserOnGoingHeadache(context);

      if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
        if (userProfileInfoData != null) {
          await _getUserCurrentHeadacheData();
        }
      }

      if(currentUserHeadacheInfo.getCurrentUserHeadacheModel() != null) {
        var onBoardAssessmentInCompleteInfo = Provider.of<OnBoardAssessIncompleteInfo>(context, listen: false);

        if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
          onBoardAssessmentInCompleteInfo.updateOnBoardAssessmentInComplete(true, Constant.blankString, Constant.blankString);
          _animationController!.forward();
        } else {
          var headacheData = userLogHeadacheDataCalendarModel.addHeadacheListData.firstWhereOrNull((element) => element.selectedDay == DateTime.now().subtract(Duration(days: 1)).day.toString());
          var studyMedicationData = userLogHeadacheDataCalendarModel.studyMedicationList.firstWhereOrNull((element) => element.selectedDay == DateTime.now().subtract(Duration(days: 1)).day.toString());

          String bannerMessage = Constant.blankString;
          String bannerBottomMessage = Constant.blankString;

          bool isProfileInComplete;

          debugPrint("Banner 1");
          if(headacheData == null && studyMedicationData == null) {
            isProfileInComplete = true;
            bannerMessage = "Missing entry and record for yesterday's log and AM/PM study medications.";
            bannerBottomMessage = "(Click here to add and record this now)";
          } else if (headacheData == null) {
            isProfileInComplete = true;
            bannerMessage = "Missing entry for yesterday's log.";
            bannerBottomMessage = "(Click here to add this now)";
          } else if(studyMedicationData == null) {
            isProfileInComplete = true;
            bannerMessage = "Missing record for yesterday's AM/PM study medication.";
            bannerBottomMessage = "(Click here to record this now)";
          } else {
            isProfileInComplete = false;
          }

          onBoardAssessmentInCompleteInfo.updateOnBoardAssessmentInComplete(isProfileInComplete, bannerMessage, bannerBottomMessage);

          var currentHeadacheModelInfo = Provider.of<CurrentUserHeadacheInfo>(context, listen: false);
          currentHeadacheModelInfo.updateCurrentUserHeadacheModel(currentHeadacheModelInfo.getCurrentUserHeadacheModel());

          if(isProfileInComplete)
            _animationController!.forward();
          else
            _animationController!.reverse();
        }
      }
    }
    await _calendarScreenBloc.fetchCalendarTriggersData(
        firstDayOfTheCurrentWeek, lastDayOfTheCurrentWeek, context);
    _isServiceCalling = false;
    Future.delayed(Duration(milliseconds: 500), () {
      _handlePushNotificationData();
    });
  }

  void setUserWeekData(UserLogHeadacheDataCalendarModel userLogHeadacheDataCalendarModel) {
    debugPrint('appconfig4');
    var appConfig = AppConfig.of(context);

    List<CurrentWeekConsData> currentWeekConsData = [];
    currentWeekListData = [];
    var _firstDayOfTheWeek =
        /*_dateTime.subtract(new Duration(days: _dateTime.weekday != 7 ? _dateTime.weekday : 0));*/
      DateTime.now().subtract(Duration(days: 6));
    filterSelectedLogAndHeadacheDayList(currentWeekConsData, userLogHeadacheDataCalendarModel, _firstDayOfTheWeek);

    debugPrint('$currentWeekConsData');

    /*if(currentWeekConsData.length < 7){
      int count = 7 - currentWeekConsData.length;
      for(int i = 0 ; i<count ; i++){
        currentWeekConsData.add(CurrentWeekConsData(widgetType: 2, eventIdList: []));
      }
    }*/

    for (int i = 0; i < 7; i++) {
      SelectedDayHeadacheIntensity? selectedDayHeadacheIntensity;
      selectedDayHeadacheIntensity = userLogHeadacheDataCalendarModel.addHeadacheIntensityListData.firstWhereOrNull((element) => int.parse(element.selectedDay!) == _firstDayOfTheWeek.day);

      if (selectedDayHeadacheIntensity == null)
        selectedDayHeadacheIntensity = SelectedDayHeadacheIntensity();

      if (currentWeekConsData[i].widgetType == 0 ||
          currentWeekConsData[i].widgetType == 1) {
        var j = i + 1;
        if (j < 7 &&
            (currentWeekConsData[i].widgetType == 0) &&
            (currentWeekConsData[j].widgetType == 0) &&
            _checkForConsecutiveHeadacheId(
                currentWeekConsData[i], currentWeekConsData[j])) {
          if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
            currentWeekListData.add(ConsecutiveSelectedDateWidget(
              weekDateData: _firstDayOfTheWeek,
              calendarType: 0,
              calendarDateViewType: currentWeekConsData[i].widgetType!,
              triggersListData: [],
              userMonthTriggersListData: [],
              isMigraine: selectedDayHeadacheIntensity.isMigraine,
              selectedDayHeadacheIntensity: selectedDayHeadacheIntensity,
              navigateToOtherScreenCallback: _navigateToOtherScreenFromDate,));
          } else {
            currentWeekListData.add(DateWidget(
              weekDateData: _firstDayOfTheWeek,
              calendarType: 0,
              calendarDateViewType: currentWeekConsData[i].widgetType!,
              triggersListData: [],
              userMonthTriggersListData: [],
              selectedDayHeadacheIntensity: selectedDayHeadacheIntensity,
              navigateToOtherScreenCallback: _navigateToOtherScreenFromDate,));
          }
        } else {
          currentWeekListData.add(DateWidget(
              weekDateData: _firstDayOfTheWeek,
              calendarType: 0,
              calendarDateViewType: currentWeekConsData[i].widgetType!,
              triggersListData: [],
              userMonthTriggersListData: [],
              selectedDayHeadacheIntensity: selectedDayHeadacheIntensity,
              navigateToOtherScreenCallback: _navigateToOtherScreenFromDate,
          ));
        }
      } else {
        currentWeekListData.add(DateWidget(
          weekDateData: _firstDayOfTheWeek,
          calendarType: 0,
          calendarDateViewType: currentWeekConsData[i].widgetType!,
          triggersListData: [],
          userMonthTriggersListData: [],
          navigateToOtherScreenCallback: _navigateToOtherScreenFromDate,
          selectedDayHeadacheIntensity: selectedDayHeadacheIntensity,
        ));
      }

      _firstDayOfTheWeek = DateTime(_firstDayOfTheWeek.year,
          _firstDayOfTheWeek.month, _firstDayOfTheWeek.day + 1);
    }
  }

  Future<bool> _navigateToOtherScreenFromDate(String routeName, dynamic data) async {
    var appConfig = AppConfig.of(context);
    if(appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
      dynamic isDataUpdated = await widget
          .navigateToOtherScreenCallback(routeName, data);
      if (isDataUpdated != null && isDataUpdated is bool &&
          isDataUpdated) {
        Utils.setAnalyticsCurrentScreen(Constant.meScreen,context);
        _getUserCurrentHeadacheData();

        _updateMeScreenData();
      }
      return isDataUpdated;
    }
    return false;
  }

  // 0- Headache Data
  // 1- LogDay Data
  // 2- No Headache and No Log
  void filterSelectedLogAndHeadacheDayList(
      List<CurrentWeekConsData> currentWeekConsDataList,
      UserLogHeadacheDataCalendarModel userLogHeadacheDataCalendarModel,
      DateTime firstDayOfTheWeek) {
    for (int i = 0; i < 7; i++) {
      var userCalendarData = userLogHeadacheDataCalendarModel.addHeadacheListData.firstWhereOrNull((element) => int.parse(element.selectedDay!) == firstDayOfTheWeek.day);
      if (userCalendarData == null) {
        SelectedHeadacheLogDate? res = userLogHeadacheDataCalendarModel.addLogDayListData.firstWhereOrNull((element) => int.parse(element.selectedDay!) == firstDayOfTheWeek.day);

        if(res == null) {
          CurrentWeekConsData currentWeekConsData = CurrentWeekConsData();
          currentWeekConsData.widgetType = 2;
          currentWeekConsData.eventIdList = [];
          currentWeekConsDataList.add(currentWeekConsData);
        } else {
          CurrentWeekConsData currentWeekConsData = CurrentWeekConsData();
          currentWeekConsData.widgetType = 1;
          currentWeekConsData.eventIdList = [];
          currentWeekConsDataList.add(currentWeekConsData);
        }
      } else {
        CurrentWeekConsData currentWeekConsData = CurrentWeekConsData();
        currentWeekConsData.widgetType = 0;
        currentWeekConsData.eventIdList = [];
        if(userCalendarData.headacheListData != null) {
          userCalendarData.headacheListData!.forEach((headacheElement) {
            currentWeekConsData.eventIdList!.add(headacheElement.id!);
          });
        }
        currentWeekConsDataList.add(currentWeekConsData);
      }
      // currentWeekConsData.add(a);
      firstDayOfTheWeek = DateTime(firstDayOfTheWeek.year,
          firstDayOfTheWeek.month, firstDayOfTheWeek.day + 1);
    }
    debugPrint("adasdasd");
  }

  bool _checkForConsecutiveHeadacheId(CurrentWeekConsData currentWeekConsData1,
      CurrentWeekConsData currentWeekConsData2) {
    bool isSatisfied = false;

    for (int i = 0; i < currentWeekConsData1.eventIdList!.length; i++) {
      int eventId = currentWeekConsData1.eventIdList![i];

      var eventIdElement = currentWeekConsData2.eventIdList
          !.firstWhereOrNull((element) => element == eventId);

      if (eventIdElement != null) {
        isSatisfied = true;
        break;
      }
    }

    return isSatisfied;
  }

  void _getUserProfileDetails() async {
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    var userNameInfo = Provider.of<UserNameInfo>(context, listen: false);
    userNameInfo.updateUserName(userProfileInfoData.profileName!);
  }

  Future<void> _getUserCurrentHeadacheData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? currentPositionOfTabBar = sharedPreferences.getInt(Constant.currentIndexOfTabBar);

    String isViewTrendsClicked =
        sharedPreferences.getString(Constant.isViewTrendsClicked) ??
            Constant.blankString;

    if (isViewTrendsClicked == Constant.trueString) {
      await widget.navigateToOtherScreenCallback(
          TabNavigatorRoutes.trendsRoute, null);
      Utils.setAnalyticsCurrentScreen(Constant.trendsScreen, context);
    }
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    if(currentPositionOfTabBar == 0) {
      CurrentUserHeadacheModel? currentUserHeadacheModel = await SignUpOnBoardProviders.db.getUserCurrentHeadacheData(userProfileInfoData.userId!);

      var currentUserHeadacheInfo = Provider.of<CurrentUserHeadacheInfo>(context, listen: false);
      currentUserHeadacheInfo.updateCurrentUserHeadacheModel(currentUserHeadacheModel);

      if(currentUserHeadacheInfo.getCurrentUserHeadacheModel() != null && currentUserHeadacheInfo.getCurrentUserHeadacheModel()!.isOnGoing!) {
        var onBoardAssessmentInCompleteInfo = Provider.of<OnBoardAssessIncompleteInfo>(context, listen: false);
        onBoardAssessmentInCompleteInfo.updateOnBoardAssessmentInComplete(true, Constant.blankString, Constant.blankString);
        _animationController!.forward();

      } else {
        _checkForProfileIncomplete();
      }
    }
  }

  ///This method is used to get text of notification banner
  String _getNotificationText(CurrentUserHeadacheModel? currentUserHeadacheModel) {
    if(currentUserHeadacheModel != null && currentUserHeadacheModel.isOnGoing!) {
      DateTime startDateTime = DateTime.tryParse(currentUserHeadacheModel.selectedDate!)!;
      if(startDateTime == null) {
        return 'Ongoing Headache currently in progress.';
      } else {
        startDateTime = startDateTime;
        return 'Ongoing Headache currently in progress (started on ${Utils.getShortMonthName(startDateTime.month)} ${startDateTime.day} at ${Utils.getTimeInAmPmFormat(startDateTime.hour, startDateTime.minute)}).';
      }
    }
    return Constant.onBoardingAssessmentIncomplete;
  }

  ///This method is used to get bottom text of notification banner
  String _getNotificationBottomText(CurrentUserHeadacheModel currentUserHeadacheModel) {
    if(currentUserHeadacheModel != null && currentUserHeadacheModel.isOnGoing!) {
      return 'Click here to view or end your current headache.';
    }
    return Constant.clickHereToFinish;
  }

  void _navigateToAddHeadacheScreen(CurrentUserHeadacheModel? currentUserHeadacheModel) async {
    var appConfig = AppConfig.of(context);
    DateTime currentDateTime = DateTime.now();
    DateTime endHeadacheDateTime = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day, currentDateTime.hour, currentDateTime.minute, 0, 0, 0);

    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    currentUserHeadacheModel = await SignUpOnBoardProviders.db
        .getUserCurrentHeadacheData(userProfileInfoData.userId!);

    var currentUserHeadacheInfo = Provider.of<CurrentUserHeadacheInfo>(context, listen: false);
    currentUserHeadacheInfo.updateCurrentUserHeadacheModel(currentUserHeadacheModel);

    CurrentUserHeadacheModel currentUserHeadacheModel1 = CurrentUserHeadacheModel(
      userId: currentUserHeadacheModel?.userId,
      selectedDate: currentUserHeadacheModel?.selectedDate,
      isOnGoing: false,
      selectedEndDate: Utils.getDateTimeInUtcFormat(endHeadacheDateTime, true, context),
      isFromRecordScreen: currentUserHeadacheModel?.isFromRecordScreen,
      isFromServer: currentUserHeadacheModel?.isFromServer,
      headacheId: currentUserHeadacheModel?.headacheId,
      mobileEventDetails: currentUserHeadacheModel?.mobileEventDetails,
    );

    if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
      await widget.navigateToOtherScreenCallback(Constant.addHeadacheOnGoingScreenRouter, currentUserHeadacheModel1);
    } else {
      await widget.navigateToOtherScreenCallback(Constant.tonixAddHeadacheScreen, currentUserHeadacheModel1);
    }
    Utils.setAnalyticsCurrentScreen(Constant.meScreen, context);
    _getUserCurrentHeadacheData();

    _updateMeScreenData();
  }

  String _getHeadacheButtonText(CurrentUserHeadacheModel? currentUserHeadacheModel) {
    debugPrint('appconfig5');
    var appConfig = AppConfig.of(context);

    if(currentUserHeadacheModel != null && currentUserHeadacheModel.isOnGoing == true) {
      return Constant.endHeadache;
    }

    if(appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
      return 'Add Headache';
    else
      return 'Log Your Day';
  }

  void _navigateToOtherScreen() async {
    var currentUserHeadacheInfo = Provider.of<CurrentUserHeadacheInfo>(context, listen: false);
    CurrentUserHeadacheModel currentUserHeadacheModel = currentUserHeadacheInfo.getCurrentUserHeadacheModel() ?? CurrentUserHeadacheModel();

    debugPrint('appconfig6');
    var appConfig = AppConfig.of(context);

    if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
      if(currentUserHeadacheModel != null && currentUserHeadacheModel.isOnGoing!) {
        await widget.navigateToOtherScreenCallback(Constant.currentHeadacheProgressScreenRouter, null);
        Utils.setAnalyticsCurrentScreen(Constant.meScreen, context);
      } else {
        await widget.navigateToOtherScreenCallback(
            Constant.welcomeStartAssessmentScreenRouter, null);
      }
      _getUserCurrentHeadacheData();
    } else {
      if(currentUserHeadacheModel != null && currentUserHeadacheModel.isOnGoing!) {
        await widget.navigateToOtherScreenCallback(Constant.currentHeadacheProgressScreenRouter, null);
        Utils.setAnalyticsCurrentScreen(Constant.meScreen, context);
        _getUserCurrentHeadacheData();
      } else {
        _clickHandlingForYesterdayBanner();
      }
    }
  }

  void _saveRecordTabBarPosition() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(Constant.recordTabNavigatorState, 0);
  }

  void _getCurrentIndexOfTabBar() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? currentPositionOfTabBar =
        sharedPreferences.getInt(Constant.currentIndexOfTabBar);
    if (currentPositionOfTabBar == 0) {
      _getUserCurrentHeadacheData();
      _getUserProfileDetails();
    }
  }

  void _updateMeScreenData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? currentPositionOfTabBar =
        sharedPreferences.getInt(Constant.currentIndexOfTabBar);

    String? updateMeScreenData =
        sharedPreferences.getString(Constant.updateMeScreenData);

    if (currentPositionOfTabBar == 0 &&
        updateMeScreenData == Constant.trueString) {
      sharedPreferences.remove(Constant.updateMeScreenData);
      await _calendarScreenBloc.fetchCalendarTriggersData(
          firstDayOfTheCurrentWeek!, lastDayOfTheCurrentWeek!, context);
    }
  }

  void _handlePushNotificationData() async {
    if(_title != null) {
      if (_title == Constant.HeadacheNotification) {
        /*var currentUserHeadacheModel = Provider.of<CurrentUserHeadacheInfo>(context, listen: false);
        if(currentUserHeadacheModel.getCurrentUserHeadacheModel() != null && currentUserHeadacheModel.getCurrentUserHeadacheModel().isOnGoing) {
          _navigateToAddHeadacheScreen(currentUserHeadacheModel.getCurrentUserHeadacheModel());
        } else {
          _navigateUserToHeadacheLogScreen();
        }*/

        var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

        DateTime dateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          DateTime.now().hour,
          DateTime.now().minute,
          0,
          0,
          0,
        );

        dateTime = dateTime.subtract(Duration(days: 1));

        CurrentUserHeadacheModel currentUserHeadacheModel =
        CurrentUserHeadacheModel(
          userId: userProfileInfoData.userId,
          isOnGoing: false,
          selectedDate: Utils.getDateTimeInUtcFormat(dateTime, true, context),
          selectedEndDate: Utils.getDateTimeInUtcFormat(dateTime, true, context),
          isFromRecordScreen: true,
        );

        var appConfig = AppConfig.of(context);

        if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
          await widget.navigateToOtherScreenCallback(
              Constant.addHeadacheOnGoingScreenRouter, currentUserHeadacheModel);
        else
          await widget.navigateToOtherScreenCallback(
              Constant.tonixAddHeadacheScreen, currentUserHeadacheModel);

        Utils.setAnalyticsCurrentScreen(Constant.meScreen, context);
      } else if (_title == Constant.LogDayNotification)  {
        DateTime dateTime = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            DateTime.now().hour,
            DateTime.now().minute, 0, 0, 0);

        dateTime = dateTime.subtract(Duration(days: 1));

        await widget.navigateToOtherScreenCallback(
            Constant.logDayScreenRouter, LogDayScreenArgumentModel(selectedDateTime: dateTime, isFromRecordScreen: true));
        _updateMeScreenData();
      }
    }
    _title = null;
  }

  List<InlineSpan> _getBannerTextSpan(CurrentUserHeadacheModel? currentUserHeadacheModel, AppConfig appConfig) {
    List<TextSpan> textSpanList = [];

    if(currentUserHeadacheModel != null && currentUserHeadacheModel.isOnGoing == true) {

      DateTime? startDateTime;

      if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
        startDateTime = DateTime.tryParse(currentUserHeadacheModel.selectedDate!);
      else
        startDateTime = DateTime.tryParse(currentUserHeadacheModel.selectedDate!)!.toLocal();

      if(startDateTime == null) {
        textSpanList = [
          TextSpan(
            text: 'Ongoing Headache currently in progress.\n',
            style: TextStyle(
              color: Constant.bubbleChatTextView,
              fontFamily: Constant.jostRegular,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          TextSpan(
            text: 'Click here to view or end your current headache.',
            style: TextStyle(
              color: Constant.bubbleChatTextView,
              fontFamily: Constant.jostMedium,
              fontSize: 14,
            ),
          ),
        ];
      } else {
        startDateTime = startDateTime;
        textSpanList = [
          TextSpan(
            text: 'Ongoing Headache currently in progress (started on ${Utils.getShortMonthName(startDateTime.month)} ${startDateTime.day} at ${Utils.getTimeInAmPmFormat(startDateTime.hour, startDateTime.minute)}).\n',
            style: TextStyle(
              color: Constant.bubbleChatTextView,
              fontFamily: Constant.jostRegular,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          TextSpan(
            text: 'Click here to view or end your current headache.',
            style: TextStyle(
              color: Constant.bubbleChatTextView,
              fontFamily: Constant.jostMedium,
              fontSize: 14,
            ),
          ),
        ];
      }
    } else {
      debugPrint('appconfig7');
      var appConfig = AppConfig.of(context);

      if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
        textSpanList = [
          TextSpan(
            text: Constant.onBoardingAssessmentIncomplete,
            style: TextStyle(
              color: Constant.bubbleChatTextView,
              fontFamily: Constant.jostRegular,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          TextSpan(
            text: Constant.clickHereToFinish,
            style: TextStyle(
              color: Constant.bubbleChatTextView,
              fontFamily: Constant.jostMedium,
              fontSize: 14,
            ),
          ),
        ];
      } else {
        var onBoardAssessmentInCompleteInfo = Provider.of<OnBoardAssessIncompleteInfo>(context, listen: false);

        textSpanList = [
          TextSpan(
            text: '${onBoardAssessmentInCompleteInfo.getBannerMessage()}\n',
            style: TextStyle(
              color: Constant.bubbleChatTextView,
              fontFamily: Constant.jostRegular,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          TextSpan(
            text: onBoardAssessmentInCompleteInfo.getBannerBottomMessage(),
            style: TextStyle(
              color: Constant.bubbleChatTextView,
              fontFamily: Constant.jostMedium,
              fontSize: 14,
            ),
          ),
        ];
      }
    }
    return textSpanList;
  }

  List<Widget> _getWeekDaysWidgetList() {
    List<Widget> widgetList = [];

    DateTime dateTime = DateTime.now().subtract(Duration(days: 6));

    for (int i = 1; i <= 7; i++) {

      widgetList.add(Center(
        child: CustomTextWidget(
          text: Utils.getWeekDayText(Utils.getWeekDayInteger(dateTime.weekday)),
          style: TextStyle(
              fontSize: 15,
              color: Constant
                  .locationServiceGreen,
              fontFamily:
              Constant.jostMedium),
        ),
      ));

      dateTime = dateTime.add(Duration(days: 1));
    }

    return widgetList;
  }

  ///This method is to handle the click event for banner and opens the screen on the basis of the missing record.
  ///Whether it is log my day or study medication.
  void _clickHandlingForYesterdayBanner() {
    var headacheData = userLogHeadacheDataCalendarModel.addHeadacheListData.firstWhereOrNull((element) => element.selectedDay == DateTime.now().subtract(Duration(days: 1)).day.toString());
    var studyMedicationData = userLogHeadacheDataCalendarModel.studyMedicationList.firstWhereOrNull((element) => element.selectedDay == DateTime.now().subtract(Duration(days: 1)).day.toString());

    if(headacheData == null && studyMedicationData == null) {
      _showYesterdayLogDialog();
    } else if (headacheData == null) {
      _openLogMyDayForYesterday();
    } else if(studyMedicationData == null) {
      _openStudyMedicationForYesterday();
    }
  }

  /// This method is used to open yesterday's log dialog
  Future<void> _showYesterdayLogDialog() async {
    var result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          content: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => LogStudyMedicationInfo(),
              ),
              ChangeNotifierProvider(
                create: (context) => LogStudyMedicationErrorInfo(),
              ),
            ],
            child: YesterdayLogDialog(
              title: _getYesterdayLogText(),
            ),
          ),
        );
      },
    );

    if(result != null && result is String) {
      if(result == Constant.addEditLogYourDay) {
        _openLogMyDayForYesterday();
      } else if (result == Constant.addEditLogStudyMedication) {
        _openStudyMedicationForYesterday();
      }
    }
  }

  /// This method is to open log my day screen for yesterday
  Future<void> _openLogMyDayForYesterday() async {
    var headacheData = userLogHeadacheDataCalendarModel.addHeadacheIntensityListData.firstWhereOrNull((element) => element.selectedDay == DateTime.now().subtract(Duration(days: 1)).day.toString());
    var appConfig = AppConfig.of(context);

    if(headacheData != null) {
      if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
        await widget.navigateToOtherScreenCallback(
            Constant.addHeadacheOnGoingScreenRouter, CurrentUserHeadacheModel(
          selectedDate: Utils.getDateTimeInUtcFormat(
              DateTime.tryParse(headacheData.headacheStartDate!)!.toLocal(), true,
              context),
          isFromRecordScreen: true,
        ));
      } else {
        await widget.navigateToOtherScreenCallback(
            Constant.tonixAddHeadacheScreen, CurrentUserHeadacheModel(
          selectedDate: Utils.getDateTimeInUtcFormat(
              DateTime.tryParse(headacheData.headacheStartDate!)!.toLocal(), true,
              context),
          isFromRecordScreen: true,
        ));
      }

      Utils.setAnalyticsCurrentScreen(Constant.meScreen, context);
    } else {
      var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

      CurrentUserHeadacheModel currentUserHeadacheModel = CurrentUserHeadacheModel(
        userId: userProfileInfoData.userId,
        selectedDate: Utils.getDateTimeInUtcFormat(DateTime.now().subtract(Duration(days: 1)), true, context),
        selectedEndDate: Utils.getDateTimeInUtcFormat(DateTime.now().subtract(Duration(days: 1)), true, context),
        isOnGoing: false,
        isFromServer: false,
        isFromRecordScreen: true,
      );

      if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
        await widget.navigateToOtherScreenCallback(
            Constant.addHeadacheOnGoingScreenRouter, currentUserHeadacheModel);
      } else {
        await widget.navigateToOtherScreenCallback(
            Constant.tonixAddHeadacheScreen, currentUserHeadacheModel);
      }
    }

    _getUserCurrentHeadacheData();
    _updateMeScreenData();
  }

  ///This method is to open log study medication for yesterday
  Future<void> _openStudyMedicationForYesterday() async {
    await _showLogStudyMedicationDialog(DateTime.now().subtract(Duration(days: 1)), true);
    Utils.setAnalyticsCurrentScreen(Constant.meScreen, context);
    _updateMeScreenData();
  }

  Future<void> _showLogStudyMedicationDialog(DateTime dateTime, bool isYesterdayLog) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          content: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => LogStudyMedicationInfo(),
              ),
              ChangeNotifierProvider(
                create: (context) => LogStudyMedicationErrorInfo(),
              ),
            ],
            child: LogStudyMedicationDialog(
              showApiLoaderCallback: widget.showApiLoaderCallback,
              dateTime: dateTime,
              isYesterdayLog: isYesterdayLog,
            ),
          ),
        );
      },
    );
    _isButtonClicked = false;
  }

  String _getYesterdayLogText() {
    String yesterdayLogText = Constant.addYesterdayLogText;

    DateTime yesterdayDateTime = _dateTime.subtract(Duration(days: 1));

    var headacheData = userLogHeadacheDataCalendarModel.addHeadacheIntensityListData.firstWhereOrNull((element) => element.selectedDay == yesterdayDateTime.day.toString());

    if(headacheData != null)
      yesterdayLogText = Constant.viewYesterdayLogText;

    return yesterdayLogText;
  }

  Widget _getLogDayButton(AppConfig appConfig) {
    return BouncingWidget(
      key: _logDayGlobalKey,
      onPressed: () async {
        if(_isTutorialHasSeen) {
          if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor) {
            await widget.navigateToOtherScreenCallback(
                Constant.logDayScreenRouter, null);
          } else {
            if(!_isButtonClicked) {
              _isButtonClicked = true;
              await _showLogStudyMedicationDialog(
                  DateTime.now(), false);
            }
          }
          Utils.setAnalyticsCurrentScreen(Constant.meScreen, context);
          _updateMeScreenData();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 22, vertical: 6),
        decoration: BoxDecoration(
          color: Constant.chatBubbleGreen,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: CustomTextWidget(
            textAlign: TextAlign.center,
            text: appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? 'Log Day' : 'Log Study\nMedication',
            style: TextStyle(
                color: Constant.bubbleChatTextView,
                fontSize: 15,
                fontFamily: Constant.jostMedium),
          ),
        ),
      ),
    );
  }

  Widget _getAddHeadacheButton(AppConfig appConfig) {
    return BouncingWidget(
      key: _addHeadacheGlobalKey,
      onPressed: () async {
        if(_isTutorialHasSeen) {
          var currentUserHeadacheInfo = Provider.of<CurrentUserHeadacheInfo>(context, listen: false);

          if (currentUserHeadacheInfo.getCurrentUserHeadacheModel() != null && currentUserHeadacheInfo.getCurrentUserHeadacheModel()!.isOnGoing!) {
            _navigateToAddHeadacheScreen(currentUserHeadacheInfo.getCurrentUserHeadacheModel());
          } else {
            if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
              _navigateUserToHeadacheLogScreen(appConfig);
            else {
              if(userLogHeadacheDataCalendarModel != null) {
                var headacheData = userLogHeadacheDataCalendarModel.addHeadacheIntensityListData.firstWhereOrNull((element) => element.selectedDay == DateTime.now().day.toString());

                if(headacheData != null) {
                  if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
                    await widget.navigateToOtherScreenCallback(Constant.addHeadacheOnGoingScreenRouter, CurrentUserHeadacheModel(selectedDate: Utils.getDateTimeInUtcFormat(DateTime.tryParse(headacheData.headacheStartDate!)!.toLocal(), true, context)));
                  else
                    await widget.navigateToOtherScreenCallback(Constant.tonixAddHeadacheScreen, CurrentUserHeadacheModel(selectedDate: Utils.getDateTimeInUtcFormat(DateTime.tryParse(headacheData.headacheStartDate!)!.toLocal(), true, context)));

                  Utils.setAnalyticsCurrentScreen(Constant.meScreen, context);

                  _getUserCurrentHeadacheData();
                  _updateMeScreenData();
                } else {
                  _navigateUserToHeadacheLogScreen(appConfig);
                }
              } else {
                _navigateUserToHeadacheLogScreen(appConfig);
              }
            }
          }
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
          child: Consumer<CurrentUserHeadacheInfo>(
            builder: (context, data, child) {
              return CustomTextWidget(
                text: _getHeadacheButtonText(data.getCurrentUserHeadacheModel()),
                style: TextStyle(
                    color: Constant.bubbleChatTextView,
                    fontSize: 15,
                    fontFamily: Constant.jostMedium),
              );
            },
          ),
        ),
      ),
    );
  }

  //username length checker:
String nameLengthChecker(String userName){
    List<String> name = userName.split(' ');
    if(userName.length > 14){
      return name[0];
    }
    return userName;
}
}

class OnBoardAssessIncompleteInfo with ChangeNotifier {
  bool _isOnBoardAssessmentInComplete = false;
  String _bannerMessage = Constant.blankString;
  String _bannerBottomMessage = Constant.blankString;

  bool isOnBoardAssessmentInComplete() => _isOnBoardAssessmentInComplete;
  String getBannerMessage() => _bannerMessage;
  String getBannerBottomMessage() => _bannerBottomMessage;

  updateOnBoardAssessmentInComplete(bool isOnBoardAssessmentInComplete, String bannerMessage, String bannerBottomMessage) {
    _isOnBoardAssessmentInComplete = isOnBoardAssessmentInComplete;
    _bannerMessage = bannerMessage;
    _bannerBottomMessage = bannerBottomMessage;
    notifyListeners();
  }
}

class CurrentUserHeadacheInfo with ChangeNotifier {
   CurrentUserHeadacheModel? _currentUserHeadacheModel;

   CurrentUserHeadacheModel? getCurrentUserHeadacheModel() => _currentUserHeadacheModel;

   updateCurrentUserHeadacheModel(CurrentUserHeadacheModel? currentUserHeadacheModel) {
     _currentUserHeadacheModel = currentUserHeadacheModel;
     notifyListeners();
   }
}

class UserNameInfo with ChangeNotifier {
  String _userName = Constant.blankString;
  String getUserName() => _userName;

  updateUserName(String userName) {
    _userName = userName;
    notifyListeners();
  }
}