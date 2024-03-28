import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/main.dart';
import 'package:mobile/models/HomeScreenArgumentModel.dart';
import 'package:mobile/models/LocalNotificationModel.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/NotificationUtil.dart';
import 'package:mobile/util/TabNavigator.dart';
import 'package:mobile/util/TabNavigatorRoutes.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CompassHeadacheTypeActionSheet.dart';
import 'package:mobile/view/DeleteHeadacheTypeActionSheet.dart';
import 'package:mobile/view/GenerateReportActionSheet.dart';
import 'package:mobile/view/MeScreenTutorial.dart';
import 'package:mobile/view/MedicalHelpActionSheet.dart';
import 'package:mobile/view/SaveAndExitActionSheet.dart';
import 'package:mobile/view/SelectTtsAccentActionSheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/MonthYearCupertinoDatePicker.dart';
import 'BottomSheetContainer.dart';
import 'CupertinoSingleList.dart';
import 'DatePicker.dart';
import 'EditGraphViewBottomSheet.dart';

class HomeScreen extends StatefulWidget {
  final HomeScreenArgumentModel? homeScreenArgumentModel;

  const HomeScreen({Key? key, this.homeScreenArgumentModel}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  GlobalKey _logDayGlobalKey = GlobalKey();
  GlobalKey _addHeadacheGlobalKey = GlobalKey();
  GlobalKey _recordsGlobalKey = GlobalKey();

  StreamController<dynamic> _pushNotificationStreamController = StreamController();

  bool _isTutorialHasSeen = false;

  StreamSink<dynamic> get pushNotificationDataSink =>
      _pushNotificationStreamController.sink;

  Stream<dynamic> get pushNotificationDataStream =>
      _pushNotificationStreamController.stream;

  bool _isBackButtonPressed = false;

  Map<int, GlobalKey<NavigatorState>> _navigatorKey = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
  };

  @override
  void dispose() {
    _pushNotificationStreamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    saveHomePosition();
    _recordsGlobalKey = GlobalKey();
    _pushNotificationStreamController = StreamController<dynamic>.broadcast();
    saveCurrentIndexOfTabBar(0);

    Utils.setAnalyticsCurrentScreen(Constant.homeScreen, context);

    /// When application is on Foreground state
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;

      var appConfig = AppConfig.of(context);

      var androidDetails = AndroidNotificationDetails(
          "ChannelId1",
          appConfig!.buildFlavor,
          channelDescription: notification.body!,
          importance: Importance.max,
          icon: appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? 'notification_icon' : 'tonix_notification_icon',
          color: Constant.chatBubbleGreen);
      var iosDetails = IOSNotificationDetails();
      var notificationDetails =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      flutterLocalNotificationsPlugin.show(notification.hashCode,
          notification.title, notification.body, notificationDetails, payload: notification.title);
    });

    flutterLocalNotificationsPlugin.initialize(initializationSettings!,
        onSelectNotification: (String? payload) async {
          if (payload != null && payload.isNotEmpty) {
            Map<String, dynamic> params = {
              'isFrom': 'foreground',
            };

            var userProfileInfoModel = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
            params['user_id'] = userProfileInfoModel.userId;

            Utils.sendAnalyticsEvent(Constant.pushNotificationClicked, params, context);
             debugPrint('notificationAdd1');
            pushNotificationDataSink.add(payload);
          }
        });

    /// When application is on background state but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('Got a message whilst in the opened app!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove(Constant.pushNotificationTitle);

        Map<String, dynamic> params = {
          'isFrom': 'background',
        };

        var userProfileInfoModel = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
        params['user_id'] = userProfileInfoModel.userId;

        Utils.sendAnalyticsEvent(Constant.pushNotificationClicked, params, context);

        debugPrint('notificationAdd2');
        pushNotificationDataSink.add(message.notification!.title);
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) async {
      if(message != null) {
        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove(Constant.pushNotificationTitle);

          Map<String, dynamic> params = {
            'isFrom': 'terminated',
          };

          var userProfileInfoModel = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
          params['user_id'] = userProfileInfoModel.userId;

          Utils.sendAnalyticsEvent(Constant.pushNotificationClicked, params, context);

          debugPrint('notificationAdd3');
          pushNotificationDataSink.add(message.notification!.title);
        }
      }
    });

    setPushNotificationData();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _insertDataIntoLocalDatabase();

      Utils.setAnalyticsCurrentScreen(Constant.meScreen, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('in build func of home screen');
    var appConfig = AppConfig.of(context);
    return WillPopScope(
      onWillPop: _backButtonHandling,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: Constant.backgroundBoxDecoration,
          child: Stack(
            children: _getStackWidgets(appConfig!),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Constant.backgroundColor,
          currentIndex: currentIndex,
          selectedItemColor: Constant.chatBubbleGreen,
          unselectedItemColor: Constant.unselectedTextColor,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontFamily: Constant.jostMedium,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontFamily: Constant.jostMedium,
          ),
          items: _getBottomNavigationBarItemList(appConfig),
          onTap: (index) {
            if(_isTutorialHasSeen) {
              if(index != currentIndex) {
                setState(() {
                  debugPrint(index.toString());
                  currentIndex = index;
                  saveCurrentIndexOfTabBar(currentIndex);
                });
                _getCurrentScreen(index);
              } else {
                int lastIndex = _navigatorKey.length - 1;
                if(index == lastIndex) {
                  Navigator.popUntil(_navigatorKey[index]!.currentContext!, ModalRoute.withName(TabNavigatorRoutes.moreRoot));
                }
              }
            }
          },
        ),
      ),
    );
  }

  ///This method is used to get initial route for the tab navigator widget based
  ///on the [index] of bottom navigation tab selected
  String _getRootRoute(int index) {
    var appConfig = AppConfig.of(context);
    switch (index) {
      case 0:
        return TabNavigatorRoutes.meRoot;
      case 1:
        if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
          return TabNavigatorRoutes.recordsRoot;
        else
          return TabNavigatorRoutes.moreRoot;
      default:
        return TabNavigatorRoutes.moreRoot;
    }
  }

  ///This method is used to get offstage navigator widget based on the [index]
  ///of bottom navigation tab selected
  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: currentIndex != index,
      child: TabNavigator(
        navigatorKey: _navigatorKey[index]!,
        root: _getRootRoute(index),
        navigateToOtherScreenCallback: navigateToOtherScreen,
        openActionSheetCallback: _openActionSheet,
        openTriggerMedicationActionSheetCallback: _openTriggersMedicationActionSheet,
        showApiLoaderCallback: showApiLoader,
        getButtonsGlobalKeyCallback: getButtonsGlobalKey,
        openDatePickerCallback: _openDatePickerBottomSheet,
        pushNotificationStream: pushNotificationDataStream,
        openBirthDateBottomSheet: _openBirthDateBottomSheet,
      ),
    );
  }


  ///This method is used to open action sheet [actionSheetType] is used as
  ///identifier for action sheet and [argument] is used to pass data to action
  ///sheet.
  Future<dynamic> _openActionSheet(String actionSheetType, dynamic argument) async {
    switch (actionSheetType) {
      case Constant.medicalHelpActionSheet:
        var resultOfActionSheet = await showCupertinoModalPopup(
            context: context, builder: (context) => MedicalHelpActionSheet());
        return resultOfActionSheet;
      case Constant.generateReportActionSheet:
        UserProfileInfoModel userProfileInfoData =
            await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

        var resultOfActionSheet = await showCupertinoModalPopup(
            context: context,
            builder: (context) => GenerateReportActionSheet(
                  userProfileInfoModel: userProfileInfoData,
                ));
        return resultOfActionSheet;
      case Constant.deleteHeadacheTypeActionSheet:
        var resultOfActionSheet = await showCupertinoModalPopup(
            context: context,
            builder: (context) => DeleteHeadacheTypeActionSheet());
        return resultOfActionSheet;
      case Constant.saveAndExitActionSheet:
        var resultOfActionSheet = await showCupertinoModalPopup(
            context: context, builder: (context) => SaveAndExitActionSheet());
        return resultOfActionSheet;
      case Constant.selectTtsAccentActionSheet:
        var resultOfActionSheet = await showCupertinoModalPopup(
            context: context, builder: (context) => SelectTtsAccentActionSheet());
        return resultOfActionSheet;
      case Constant.dateRangeActionSheet:
        DateTime initialDateTime = argument as DateTime;
        var resultOfActionSheet = await showModalBottomSheet(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            context: context,
            builder: (context) => DatePicker(
              cupertinoDatePickerMode: MonthYearCupertinoDatePickerMode.date,
              onDateTimeSelected: null,
              initialDateTime: initialDateTime,
              miniDateTime: null,
              isFromHomeScreen: true,
            ));
        return resultOfActionSheet;
      case Constant.compassHeadacheTypeActionSheet:
        var resultOfActionSheet = await showModalBottomSheet(
            backgroundColor: Constant.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            context: context,
            builder: (context) => CompassHeadacheTypeActionSheet(
                compassHeadacheTypeActionSheetModel: argument));
        return resultOfActionSheet;
      case Constant.editGraphViewBottomSheet:
        var resultOfActionSheet = showModalBottomSheet(
          context: context,
          backgroundColor: Constant.backgroundColor,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          builder: (context) =>
              EditGraphViewBottomSheet(editGraphViewFilterModel: argument),
        );
        return resultOfActionSheet;
      default:
        return null;
    }
  }


  /// This method is used to navigate to other screen
  /// [routeName] is used as the identifier of screen
  /// [argument] is used to pass data to the screen.
  Future<dynamic> navigateToOtherScreen(String routerName, dynamic argument) async {
    if (routerName == TabNavigatorRoutes.calenderRoute || routerName == TabNavigatorRoutes.trendsRoute) {
      await Utils.saveDataInSharedPreference(Constant.tabNavigatorState, "1");
      await saveCurrentIndexOfTabBar(1);
      setState(() {
        debugPrint('set state 4');
        currentIndex = 1;
      });
    } else if (routerName == Constant.welcomeStartAssessmentScreenRouter || routerName == Constant.loginScreenRouter) {
      return await Navigator.pushReplacementNamed(context, routerName, arguments: argument);
    } else if (routerName == Constant.replayTutorial) {
      await saveCurrentIndexOfTabBar(0);
      setState(() {
        currentIndex = 0;
      });
      return false;
    } else {
      return await Navigator.pushNamed(context, routerName, arguments: argument);
    }
  }

  ///This method is used to open triggers and medication action sheet which are
  ///used on more my profile screen [questions] is used to get data of triggers
  ///and medications list and [selectedAnswerCallback] is used as the callback
  ///function which is used to handle click events.
  Future<dynamic> _openTriggersMedicationActionSheet(Questions questions, Function(int) selectedAnswerCallback) async {
    /*Questions q = Questions();
    q.values = List<Values>.from(questions.values);*/
    final result = await showModalBottomSheet(
        backgroundColor: Constant.transparentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        builder: (context) => BottomSheetContainer(
              question: questions,
              selectedAnswerCallback: selectedAnswerCallback,
              isFromMoreScreen: true,
            ));
    return result;
  }

  void _openBirthDateBottomSheet(
      List<String> listData, String initialData, int initialIndex, bool month, Function(String, int) selectedAgeCallback, bool disableFurtherOptions) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (context) => SizedBox(
          child: CupertinoSingleList(
              listData: listData,
              initialData: initialData,
              initialIndex: initialIndex,
              onItemSelected: selectedAgeCallback,
            disableFurtherOptions: disableFurtherOptions,
          ),
        ));
  }

  ///This method is used to save data to shared pref storage for is user already
  ///logged in.
  void saveHomePosition() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(Constant.userAlreadyLoggedIn, true);
    //print('Device Token Start???${await _fcm.getToken()}???End');
    //  Utils.showValidationErrorDialog(context, 'Terminated App ${sharedPreferences.getString('notification_data')}');
    sharedPreferences.remove('notification_data');
  }

  ///This method is used to save current index of tab bar [currentIndex]
  Future<void> saveCurrentIndexOfTabBar(int currentIndex) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove("userHeadacheName");
    sharedPreferences.remove("isMigraine");
    sharedPreferences.setInt(Constant.currentIndexOfTabBar, currentIndex);
  }

  ///This method is used to show api loader dialog
  void showApiLoader(Stream networkStream, Function tapToRetryFunction) {
    Utils.showApiLoaderDialog(context, networkStream: networkStream, tapToRetryFunction: tapToRetryFunction);
  }

  ///This method is used get buttons global keys of log day and add headache buttons
  void getButtonsGlobalKey(GlobalKey logDayGlobalKey, GlobalKey addHeadacheGlobalKey) {
    _logDayGlobalKey = logDayGlobalKey;
    _addHeadacheGlobalKey = addHeadacheGlobalKey;

    Future.delayed(Duration(milliseconds: 350), () {
      _showTutorialDialog();
    });
  }

  ///This method is used to show tutorial dialog
  void _showTutorialDialog() async {
    try {
      bool isTutorialHasSeen = await SignUpOnBoardProviders.db
          .isUserHasAlreadySeenTutorial(1);
      Future.delayed(Duration(milliseconds: 300), () {
        _isTutorialHasSeen = true;
      });
      if (!isTutorialHasSeen) {
        await SignUpOnBoardProviders.db.insertTutorialData(1);
        showGeneralDialog(
            context: context,
            barrierColor: Colors.transparent,
            pageBuilder: (buildContext, animation, secondaryAnimation) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: MeScreenTutorialDialog(
                  logDayGlobalKey: _logDayGlobalKey,
                  recordsGlobalKey: _recordsGlobalKey,
                  addHeadacheGlobalKey: _addHeadacheGlobalKey,
                  isFromOnBoard: widget.homeScreenArgumentModel != null ? widget
                      .homeScreenArgumentModel!.isFromOnBoard : false,
                  appConfig: AppConfig.of(context)!,
                ),
              );
            }
        );
      }
    } catch (e) {
      debugPrint('Error occurred!');
    }
  }

  /// @param cupertinoDatePickerMode: for time and date mode selection
  Future<DateTime> _openDatePickerBottomSheet(
      MonthYearCupertinoDatePickerMode cupertinoDatePickerMode,
      Function dateTimeCallbackFunction,
      DateTime initialDateTime) async {
    var resultFromActionSheet = await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (context) => DatePicker(
          cupertinoDatePickerMode: cupertinoDatePickerMode,
          onDateTimeSelected: dateTimeCallbackFunction,
          initialDateTime: initialDateTime,
          isFromHomeScreen: true,
        ),
    );

    return resultFromActionSheet;
  }

  void _insertDataIntoLocalDatabase() async {
    var appConfig = AppConfig.of(context);

    var notificationListData =
        await SignUpOnBoardProviders.db.getAllLocalNotificationsData();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String isNotificationInitiallyAdded =
        prefs.getString(Constant.isNotificationInitiallyAdded) ??
            Constant.blankString;

    if (notificationListData == null && isNotificationInitiallyAdded.isEmpty) {
      prefs.setString(
          Constant.isNotificationInitiallyAdded, Constant.trueString);
      List<LocalNotificationModel> allNotificationListData = [];

      DateTime currentDateTime = DateTime.now();

      DateTime defaultNotificationTime = DateTime(currentDateTime.year,
          currentDateTime.month, currentDateTime.day, appConfig?.buildFlavor == Constant.migraineMentor ? 6 : 20, 0, 0, 0, 0);

      DateTime amDefaultNotificationTime = DateTime(currentDateTime.year,
          currentDateTime.month, currentDateTime.day, 8, 0, 0, 0, 0);

      allNotificationListData.add(LocalNotificationModel(
          notificationName: Constant.dailyLogNotificationTitle,
          notificationType: Constant.dailyNotificationType,
          notificationTime: defaultNotificationTime.toIso8601String(),
          isCustomNotificationAdded: false));

      if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
        allNotificationListData.add(LocalNotificationModel(
            notificationName: Constant.medicationNotificationTitle,
            notificationType: Constant.dailyNotificationType,
            notificationTime: defaultNotificationTime.toIso8601String(),
            isCustomNotificationAdded: false));

        allNotificationListData.add(LocalNotificationModel(
            notificationName: Constant.exerciseNotificationTitle,
            notificationType: Constant.dailyNotificationType,
            notificationTime: defaultNotificationTime.toIso8601String(),
            isCustomNotificationAdded: false));
      } else {
        allNotificationListData.add(LocalNotificationModel(
            notificationName: Constant.amStudyMedicationNotification,
            notificationType: Constant.dailyNotificationType,
            notificationTime: amDefaultNotificationTime.toIso8601String(),
            isCustomNotificationAdded: false));

        allNotificationListData.add(LocalNotificationModel(
            notificationName: Constant.pmStudyMedicationNotification,
            notificationType: Constant.dailyNotificationType,
            notificationTime: defaultNotificationTime.toIso8601String(),
            isCustomNotificationAdded: false));
      }

      allNotificationListData.forEach((localNotificationModel) {
        NotificationUtil.notificationSelected(
            localNotificationModel, DateTime.tryParse(localNotificationModel.notificationTime!)!, appConfig!);
      });

      await SignUpOnBoardProviders.db
          .insertUserNotifications(allNotificationListData);
    }
  }

  void setPushNotificationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? titleValue = prefs.getString(Constant.pushNotificationTitle);
    prefs.remove(Constant.pushNotificationTitle);
    if (titleValue != null) {
      debugPrint('notificationAdd4');
      pushNotificationDataSink.add(titleValue);
    }
  }

  ///This method is used to show snack bar for press again to exit
  void _showAppExitSnackBar() {
    final snackBar = SnackBar(content: Text('Press back again to exit.', style: TextStyle(
        height: 1.3,
        fontSize: 16,
        fontFamily: Constant.jostRegular,
        color: Colors.black)),
      backgroundColor: Constant.chatBubbleGreen,
      duration: Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  ///This method is used to handle hardware back button function
  Future<bool> _backButtonHandling() async {
    bool onWillPopResult = !await _navigatorKey[currentIndex]!.currentState!.maybePop();

    if(onWillPopResult) {
      if (!_isBackButtonPressed) {
        _isBackButtonPressed = true;
        _showAppExitSnackBar();

        Future.delayed(Duration(seconds: 5), () {
          _isBackButtonPressed = false;
        });

        return false;
      }
    }
    return onWillPopResult;
  }

  void _getCurrentScreen(int index) async {
    String? screenName;

    switch(index) {
      case 0:
        screenName = Constant.meScreen;
        break;
      case 1:
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        int recordTabIndex = sharedPreferences.getInt(Constant.recordTabNavigatorState) ?? 0;

        if(recordTabIndex == 0)
          screenName = Constant.calendarScreen;
        else if (recordTabIndex == 1)
          screenName = Constant.compassScreen;
        else
          screenName = Constant.trendsScreen;

        break;
      case 2:
        //screenName = Utils.getMoreScreenName(navigatorKey[index].currentState.widget);
        screenName = Constant.moreScreen;
        break;
    }

    Utils.setAnalyticsCurrentScreen(screenName!, context);
  }

  List<BottomNavigationBarItem> _getBottomNavigationBarItemList(AppConfig appConfig) {
    List<BottomNavigationBarItem> list;

    if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor) {
      list = [
        BottomNavigationBarItem(
          icon: Image.asset(
            Constant.meUnselected,
            height: 25,
          ),
          activeIcon: Image.asset(
            Constant.meSelected,
            height: 25,
          ),
          label: Constant.me,
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            Constant.recordsUnselected,
            height: 25,
            key: _recordsGlobalKey,
          ),
          activeIcon: Image.asset(
            Constant.recordsSelected,
            height: 25,
          ),
          label: Constant.records,
        ),
        /*BottomNavigationBarItem(
              icon: Image.asset(
                Constant.discoverUnselected,
                height: 25,
              ),
              activeIcon: Image.asset(
                Constant.discoverSelected,
                height: 25,
              ),
              label: Constant.discover,
            ),*/
        BottomNavigationBarItem(
          icon: Image.asset(
            Constant.moreUnselected,
            height: 25,
            width: 30,
          ),
          activeIcon: Image.asset(
            Constant.moreSelected,
            height: 25,
            width: 30,
          ),
          label: Constant.moreCap,
        ),
      ];
    } else {
      list = [
        BottomNavigationBarItem(
          icon: Image.asset(
            Constant.meUnselected,
            height: 25,
          ),
          activeIcon: Image.asset(
            Constant.meSelected,
            height: 25,
          ),
          label: Constant.myDay,
        ),
        /*   BottomNavigationBarItem(
              icon: Image.asset(
                Constant.recordsUnselected,
                height: 25,
                key: _recordsGlobalKey,
              ),
              activeIcon: Image.asset(
                Constant.recordsSelected,
                height: 25,
              ),
              label: Constant.records,
            ),*/
        /*BottomNavigationBarItem(
              icon: Image.asset(
                Constant.discoverUnselected,
                height: 25,
              ),
              activeIcon: Image.asset(
                Constant.discoverSelected,
                height: 25,
              ),
              label: Constant.discover,
            ),*/
        BottomNavigationBarItem(
          icon: Image.asset(
            Constant.moreUnselected,
            height: 25,
            width: 30,
          ),
          activeIcon: Image.asset(
            Constant.moreSelected,
            height: 25,
            width: 30,
          ),
          label: 'SETTINGS',
        ),
      ];
    }

    return list;
  }

  List<Widget> _getStackWidgets(AppConfig appConfig) {
    List<Widget> widgetList;

    if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor) {
      widgetList = [
        _buildOffstageNavigator(0),
        _buildOffstageNavigator(1),
        /*_buildOffstageNavigator(2),*/
        _buildOffstageNavigator(2),
      ];
    } else {
      widgetList = [
        _buildOffstageNavigator(0),
        _buildOffstageNavigator(1),
        /*_buildOffstageNavigator(2),*/
        /*_buildOffstageNavigator(2),*/
      ];
    }

    return widgetList;
  }
}
