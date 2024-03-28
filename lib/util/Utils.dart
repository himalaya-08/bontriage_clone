import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

//import 'package:health/health.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/models/CompassTutorialModel.dart';
import 'package:mobile/models/HomeScreenArgumentModel.dart';
import 'package:mobile/models/PartTwoOnBoardArgumentModel.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserProgressDataModel.dart';
import 'package:mobile/models/health_authorization_status.dart';
import 'package:mobile/models/medication_history_model.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/view/ApiLoaderDialog.dart';
import 'package:mobile/view/ConfirmationDialog.dart';
import 'package:mobile/view/CriticalUpdateVersionDialog.dart';
import 'package:mobile/view/MoreAgeScreen.dart';
import 'package:mobile/view/MoreEmailScreen.dart';
import 'package:mobile/view/MoreFaqScreen.dart';
import 'package:mobile/view/MoreGenderScreen.dart';
import 'package:mobile/view/MoreGenerateReportScreen.dart';
import 'package:mobile/view/MoreHeadachesScreen.dart';
import 'package:mobile/view/MoreLocationServicesScreen.dart';
import 'package:mobile/view/MoreMedicationScreen.dart';
import 'package:mobile/view/MoreMyProfileScreen.dart';
import 'package:mobile/view/MoreNameScreen.dart';
import 'package:mobile/view/MoreNotificationScreen.dart';
import 'package:mobile/view/MoreScreen.dart';
import 'package:mobile/view/MoreSettingScreen.dart';
import 'package:mobile/view/MoreSexScreen.dart';
import 'package:mobile/view/MoreSupportScreen.dart';
import 'package:mobile/view/MoreTriggersScreen.dart';
import 'package:mobile/view/SecondStepCompassResultTutorials.dart';
import 'package:mobile/view/TrendsScreenTutorialDialog.dart';
import 'package:mobile/view/TriggerSelectionDialog.dart';
import 'package:mobile/view/ValidationErrorDialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'constant.dart';

class Utils {
  static String getMonthName(int monthNum) {
    String month = '';
    switch (monthNum) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
    }
    return month;
  }

  static String getShortMonthName(int monthNum) {
    String month = '';
    switch (monthNum) {
      case 1:
        month = "Jan";
        break;
      case 2:
        month = "Feb";
        break;
      case 3:
        month = "Mar";
        break;
      case 4:
        month = "Apr";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "Jun";
        break;
      case 7:
        month = "Jul";
        break;
      case 8:
        month = "Aug";
        break;
      case 9:
        month = "Sep";
        break;
      case 10:
        month = "Oct";
        break;
      case 11:
        month = "Nov";
        break;
      case 12:
        month = "Dec";
        break;
    }
    return month;
  }

  /// Method to get total no of days in the month
  static daysInCurrentMonth(int monthNum, int year) {
    List<int> monthLength = new List.filled(12, 1);

    monthLength[0] = 31;
    monthLength[2] = 31;
    monthLength[4] = 31;
    monthLength[6] = 31;
    monthLength[7] = 31;
    monthLength[9] = 31;
    monthLength[11] = 31;
    monthLength[3] = 30;
    monthLength[8] = 30;
    monthLength[5] = 30;
    monthLength[10] = 30;

    if (leapYear(year) == true)
      monthLength[1] = 29;
    else
      monthLength[1] = 28;

    return monthLength[monthNum - 1];
  }

  static String getTimeInAmPmFormat(int hours, int minutes) {
    String time = '';
    int hrs = hours;
    String hrsString = hours.toString();
    String minString = minutes.toString();
    String amPm = 'AM';

    if (hrs > 12) {
      hrs = hours % 12;
    }

    if (hrs == 0) {
      hrsString = '12';
    } else {
      hrsString = hrs.toString();
    }

    if (minutes < 10) {
      minString = '0$minutes';
    }

    if (hours >= 12) {
      amPm = 'PM';
    }

    time = '$hrsString:$minString $amPm';

    return time;
  }

  static String getWeekDay(DateTime date) {
    int weekDay = date.weekday;
    if (weekDay == 0) {
      return 'Sun';
    } else if (weekDay == 1) {
      return 'Mon';
    } else if (weekDay == 2) {
      return 'Tues';
    } else if (weekDay == 3) {
      return 'Weds';
    } else if (weekDay == 4) {
      return 'Thurs';
    } else if (weekDay == 5) {
      return 'Fri';
    } else {
      return 'Sat';
    }
  }

  static String getStringFromJson(dynamic jsonObject) {
    return jsonEncode(jsonObject);
  }

  static void saveTutorialsState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constant.tutorialsState, true);
  }

  // this returns the last date of the month using DateTime
  static int daysInMonth(DateTime date) {
    var firstDayThisMonth = new DateTime(date.year, date.month, date.day);
    var firstDayNextMonth = new DateTime(firstDayThisMonth.year,
        firstDayThisMonth.month + 1, firstDayThisMonth.day);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  static Future<void> saveDataInSharedPreference(
      String keyName, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(keyName, value);
  }

  /// For Validate Email
  static bool validateEmail(String value) {
    Pattern pattern =
        r"^[a-z0-9.a-z0-9.!#$%&'*+-/=?^_`{|}~]+@([a-z0-9]+\.[a-z]+)$";
    //r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern.toString());
    return (!regex.hasMatch(value)) ? false : true;
  }

  /// For Validate Password
  // r'^
  //   (?=.*[A-Z])       // should contain at least one upper case
  //   (?=.*[a-z])       // should contain at least one lower case
  //   (?=.*?[0-9])          // should contain at least one digit
  static bool validatePassword(String value) {
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  ///This method is used to validate the data of on-boarding
  static bool validationForOnBoard(
      List<SelectedAnswers> selectedAnswerList, Questions questions) {
    switch (questions.questionType) {
      case Constant.QuestionMultiType:
        SelectedAnswers? selectedAnswersData =
            selectedAnswerList.firstWhereOrNull(
                (element) => element.questionTag == questions.tag);
        if (selectedAnswersData != null) {
          try {
            List<String> _valuesSelectedList =
                (jsonDecode(selectedAnswersData.answer!) as List<dynamic>)
                    .cast<String>();

            return _valuesSelectedList.length != 0;
          } catch (e) {
            debugPrint(e.toString());
            return false;
          }
        }
        return false;
      case Constant.QuestionSingleType:
        SelectedAnswers? selectedAnswersData =
            selectedAnswerList.firstWhereOrNull(
                (element) => element.questionTag == questions.tag);
        return (selectedAnswersData != null) &&
            selectedAnswersData.answer!.trim().isNotEmpty;
      case Constant.QuestionNumberType:
        SelectedAnswers? selectedAnswersData =
            selectedAnswerList.firstWhereOrNull(
                (element) => element.questionTag == questions.tag);
        return (selectedAnswersData != null) &&
            selectedAnswersData.answer!.trim().isNotEmpty;
      case Constant.QuestionTextType:
        SelectedAnswers? selectedAnswersData =
            selectedAnswerList.firstWhereOrNull(
                (element) => element.questionTag == questions.tag);
        return (selectedAnswersData != null) &&
            selectedAnswersData.answer!.trim().isNotEmpty;
      case Constant.QuestionLocationType:
        return true;
      case Constant.QuestionInfoType:
        return true;
      default:
        return true;
    }
  }

  ///This method is used to navigate the user to the screen where he/she left off.
  static void navigateToUserOnProfileBoard(BuildContext context) async {
    UserProgressDataModel? userProgressModel =
        await SignUpOnBoardProviders.db.getUserProgress();
    if (userProgressModel != null) {
      switch (userProgressModel.step) {
        case Constant.zeroEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.signUpOnBoardProfileQuestionRouter);
          break;
        case Constant.firstEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.partOneOnBoardScreenTwoRouter);
          break;
        case Constant.firstCompassEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.signUpFirstStepHeadacheResultRouter);
          break;
        case Constant.secondCompassEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.signUpSecondStepHeadacheResultRouter);
          break;
        case Constant.secondEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.partTwoOnBoardScreenRouter,
              arguments: PartTwoOnBoardArgumentModel(
                  argumentName: Constant.clinicalImpressionShort1,
                  isFromSignUp: true));
          break;
        case Constant.thirdEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.partThreeOnBoardScreenRouter);
          break;
        case Constant.headacheInfoEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.onBoardHeadacheInfoScreenRouter);
          break;
        case Constant.createAccountEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.onBoardCreateAccountScreenRouter);
          break;
        case Constant.prePartTwoEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.prePartTwoOnBoardScreenRouter);
          break;
        case Constant.signUpEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.onBoardingScreenSignUpRouter);
          break;
        case Constant.onBoardMoveOnForNowEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.partTwoOnBoardMoveOnScreenRouter);
          break;
        case Constant.prePartThreeEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.prePartThreeOnBoardScreenRouter);
          break;
        case Constant.postPartThreeEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.postPartThreeOnBoardRouter);
          break;
        case Constant.notificationEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.notificationScreenRouter);
          break;
        case Constant.postNotificationEventStep:
          Navigator.pushReplacementNamed(
              context, Constant.postNotificationOnBoardRouter);
          break;
        default:
          Navigator.pushReplacementNamed(
              context, Constant.signUpOnBoardSplashRouter);
      }
    } else {
      Navigator.pushReplacementNamed(
          context, Constant.signUpOnBoardSplashRouter);
    }
  }

  /// This method will be use for to get current tag from respective API and if the current table from database is empty then insert the
  /// data on respective position of the questions list.and if not then update the data on respective position.
  static void saveUserProgress(int userScreenPosition, String eventStep) async {
    var isDataBaseExists = await SignUpOnBoardProviders.db.isDatabaseExist();
    UserProgressDataModel userProgressDataModel = UserProgressDataModel();

    if (isDataBaseExists) {
      int? userProgressDataCount = await SignUpOnBoardProviders.db
          .checkUserProgressDataAvailable(
              SignUpOnBoardProviders.TABLE_USER_PROGRESS);
      userProgressDataModel.userId = Constant.userID;
      userProgressDataModel.step = eventStep;
      userProgressDataModel.userScreenPosition = userScreenPosition;
      userProgressDataModel.questionTag = '';

      if (userProgressDataCount == 0) {
        SignUpOnBoardProviders.db.insertUserProgress(userProgressDataModel);
      } else {
        SignUpOnBoardProviders.db.updateUserProgress(userProgressDataModel);
      }
    }
  }

  static void navigateToExitScreen(BuildContext buildContext) async {
    var isUserAlreadyLoggedIn =
        await SignUpOnBoardProviders.db.isUserAlreadyLoggedIn();
    if (ModalRoute.of(buildContext)!.isFirst) {
      Navigator.pushReplacementNamed(
          buildContext, Constant.onBoardExitScreenRouter,
          arguments: isUserAlreadyLoggedIn);
    } else {
      Navigator.pushNamed(buildContext, Constant.onBoardExitScreenRouter,
          arguments: isUserAlreadyLoggedIn);
    }
  }

  void getUserInformation() {}

  static Future<void> clearAllDataFromDatabaseAndCache() async {
    try {
      await SignUpOnBoardProviders.db.deleteAllTableData();
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      bool isVolume =
          sharedPreferences.getBool(Constant.chatBubbleVolumeState) ?? true;
      String ttsAccent =
          sharedPreferences.getString(Constant.ttsAccentKey) ?? 'en-US';
      sharedPreferences.clear();
      sharedPreferences.setString(Constant.ttsAccentKey, ttsAccent);
      sharedPreferences.setBool(Constant.chatBubbleVolumeState, isVolume);
      sharedPreferences.setBool(Constant.tutorialsState, true);
      flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('in here $e');
    }
  }

  ///This method is used to show api loader dialog
  ///@param context: context of the screen where the dialog will be shown
  ///@param networkStream: this variable is used to listen to the network events
  ///@param tapToRetryFunction: this variable is used to pass the reference of the tap to retry button function functionality
  static void showApiLoaderDialog(BuildContext context,
      {Stream<dynamic>? networkStream, Function? tapToRetryFunction}) {
    showGeneralDialog(
      context: context,
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        return Builder(
          builder: (context) {
            return Material(
              color: Colors.black26,
              child: Align(
                alignment: Alignment.center,
                child: ApiLoaderDialog(
                  networkStream: networkStream ?? Stream.empty(),
                  tapToRetryFunction: tapToRetryFunction ?? () {},
                ),
              ),
            );
          },
        );
      },
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 150),
    );
  }

  static void navigateToHomeScreen(
      BuildContext context, bool isProfileInComplete,
      {HomeScreenArgumentModel? homeScreenArgumentModel}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(
        Constant.isProfileInCompleteStatus, isProfileInComplete);
    Navigator.pushReplacementNamed(context, Constant.homeRouter,
        arguments: homeScreenArgumentModel);
  }

  static void closeApiLoaderDialog(BuildContext context) {
    Future.delayed(Duration(milliseconds: 200), () {
      Navigator.pop(context);
    });
  }

  static String getDateTimeInUtcFormat(
      DateTime dateTime, bool convert, BuildContext? context) {
    /*String dateTimeIsoString = dateTime
        .toUtc()
        .toIso8601String();
    List<String> splitedString = dateTimeIsoString.split('.');*/

    if (context != null) {
      var appConfig = AppConfig.of(context);

      if (appConfig?.buildFlavor == Constant.tonixBuildFlavor) {
        if (convert) dateTime = dateTime.toUtc();
      }
    }

    String year, month, date, hour, minute, second;

    year = dateTime.year.toString();

    if (dateTime.month < 10) {
      month = '0${dateTime.month}';
    } else {
      month = dateTime.month.toString();
    }

    if (dateTime.day < 10) {
      date = '0${dateTime.day}';
    } else {
      date = dateTime.day.toString();
    }

    if (dateTime.hour < 10) {
      hour = '0${dateTime.hour}';
    } else {
      hour = dateTime.hour.toString();
    }

    if (dateTime.minute < 10) {
      minute = '0${dateTime.minute}';
    } else {
      minute = dateTime.minute.toString();
    }

    if (dateTime.second < 10) {
      second = '0${dateTime.second}';
    } else {
      second = dateTime.second.toString();
    }

    debugPrint('$year-$month-${date}T$hour:$minute:${second}Z');

    return '$year-$month-${date}T$hour:$minute:${second}Z';
  }

  //returns String in format of: 1/1/2023 (dd/mm/yyyy) using DateTime
  static String getDateText(DateTime date, bool firstMonth) {
    String day = (date.day < 10)
        ? date.day.toString().substring(0)
        : date.day.toString();
    String month = date.month.toString();
    String year = date.year.toString();
    if (!firstMonth)
      return '$day/$month/$year';
    else
      return '$month/$day/$year';
  }

  static void showTriggerSelectionDialog(BuildContext context, int maxTrigger) {
    showGeneralDialog(
      context: context,
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        return Builder(
          builder: (context) {
            return Material(
              color: Colors.black26,
              child: Align(
                alignment: Alignment.center,
                child: TriggerSelectionDialog(
                  maxTrigger: maxTrigger,
                ),
              ),
            );
          },
        );
      },
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 150),
    );
  }

  ///method to find, the given year is a leap year or not
  static leapYear(int year) {
    bool leapYear = false;

    bool leap = ((year % 100 == 0) && (year % 400 != 0));
    if (leap == true)
      leapYear = false;
    else if (year % 4 == 0) leapYear = true;

    return leapYear;
  }

  /// Current Date with Time
  static firstDateWithCurrentMonthAndTimeInUTC(
      int currentMonth, int currentYear, int totalDaysInCurrentMonth) {
    //String currentDate;

    DateTime _dateTime = DateTime.now();
    DateTime firstDayDateTime = DateTime(
        currentYear,
        currentMonth,
        totalDaysInCurrentMonth,
        _dateTime.hour,
        _dateTime.minute,
        _dateTime.second);

    String month, day;

    if (firstDayDateTime.month < 10) {
      month = '0${firstDayDateTime.month}';
    } else {
      month = '${firstDayDateTime.month}';
    }

    if (firstDayDateTime.day < 10) {
      day = '0${firstDayDateTime.day}';
    } else {
      day = '${firstDayDateTime.day}';
    }

    return '${firstDayDateTime.year}-$month-${day}T00:00:00Z';

    //return '${firstDayDateTime.year}-${firstDayDateTime.month}-${firstDayDateTime.day}T00:00:00Z';
  }

  /// Current Date with Time
  static lastDateWithCurrentMonthAndTimeInUTC(
      int currentMonth, int currentYear, int totalDaysInCurrentMonth) {
    //String currentDate;
    DateTime _dateTime = DateTime.now();
    DateTime firstDayDateTime = DateTime(
        currentYear,
        currentMonth,
        totalDaysInCurrentMonth,
        _dateTime.hour,
        _dateTime.minute,
        _dateTime.second);

    String month, day;

    if (firstDayDateTime.month < 10) {
      month = '0${firstDayDateTime.month}';
    } else {
      month = '${firstDayDateTime.month}';
    }

    if (firstDayDateTime.day < 10) {
      day = '0${firstDayDateTime.day}';
    } else {
      day = '${firstDayDateTime.day}';
    }

    return '${firstDayDateTime.year}-$month-${day}T00:00:00Z';
  }

  ///This method is used to return scroll physics based on the platform
  static ScrollPhysics getScrollPhysics() {
    return Platform.isIOS ? BouncingScrollPhysics() : ClampingScrollPhysics();
  }

  ///This method is used to show validation error message to the user
  static void showValidationErrorDialog(
      BuildContext context, String errorMessage,
      [String? errorTitle, bool isShowErrorIcon = false]) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          content: ValidationErrorDialog(
            errorMessage: errorMessage,
            errorTitle: errorTitle ?? 'Alert!',
            isShowErrorIcon: isShowErrorIcon,
          ),
        );
      },
    );
  }

  ///This method is used to show Critical update  popup to the user
  static void showCriticalUpdateDialog(
    BuildContext context,
    String errorMessage,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          content: CriticalUpdateVersionDialog(errorMessage: errorMessage),
        );
      },
    );
  }

  ///This method is used to show  error message to the user
  static void showIOSSettingScreenDialog(
      BuildContext context, String errorMessage,
      [String? errorTitle]) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          content: ValidationErrorDialog(
            errorMessage: errorMessage,
            errorTitle: errorTitle!,
          ),
        );
      },
    );
  }

  ///This method is used to show compass tutorial dialog.
  ///@param context: build context of the screen
  ///@param indexValue: 0 for compass, 1 for Intensity, 2 for Disability, 3 for Frequency, and 4 for Duration.
  static Future<void> showCompassTutorialDialog(
      BuildContext context, int indexValue,
      {CompassTutorialModel? compassTutorialModel}) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          content: SecondStepCompassResultTutorials(
            tutorialsIndex: indexValue,
            compassTutorialModel: compassTutorialModel!,
          ),
        );
      },
    );
  }

  /// Determine the current position of the device.
  /// When the location services are not enabled or permissions
  /// are denied the 'Future' will null.
  static Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    Position? position;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    permission = await Geolocator.checkPermission();

    debugPrint('Permission???$permission');

    if (permission == LocationPermission.denied &&
        permission != LocationPermission.deniedForever) {
      debugPrint('before permission');
      permission = await Geolocator.requestPermission();
      debugPrint('Permission???$permission');
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        position = await Geolocator.getCurrentPosition();
      }
    } else {
      if (permission != LocationPermission.deniedForever)
        position = await Geolocator.getCurrentPosition();
    }

    return position!;
  }

  static void showTrendsTutorialDialog(BuildContext context) {
    showGeneralDialog(
        context: context,
        barrierColor: Colors.transparent,
        pageBuilder: (buildContext, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: TrendsScreenTutorialDialog(),
          );
        });
  }

  static Future<dynamic> showConfirmationDialog(
      BuildContext context, String dialogContent,
      [String? dialogTitle,
      String? negativeOption,
      String? positiveOption]) async {
    var result = await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          content: ConfirmationDialog(
            dialogContent: dialogContent,
            dialogTitle: dialogTitle,
            positiveOption: positiveOption,
            negativeOption: negativeOption,
          ),
        );
      },
    );

    return result;
  }

  static void customLaunch(Uri command) async {
    debugPrint("canLaunch ${await canLaunchUrl(command)}");
    if (await canLaunchUrl(command)) {
      await launchUrl(command);
    }
  }

  ///Method to create a file of pdf from base64 string and save that file into the app directory.
  ///[base64String] is the parameter of base64 string.
  static Future<File> createFileOfPdfUrl(String base64String) async {
    var bytes = base64Decode(base64String);
    String filename = 'BonTriage_Report.pdf';
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File.fromUri(Uri.parse('$dir/$filename'));
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static Future<void> changeLocationSwitchState(bool state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constant.locationSwitchState, state);
  }

  static Future<bool> getLocationSwitchState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool locationSwitchState =
        prefs.getBool(Constant.locationSwitchState) ?? true;

    return locationSwitchState;
  }

  static Future<void> setAnalyticsUserId(String? userId, BuildContext context) async {
    if (WebservicePost.migraineMentorServerUrl == Constant.prodServerUrl) {
      var appConfig = AppConfig.of(context);
      if (appConfig?.appFlavour == Constant.migraineMentorPackageName) {
        if (userId != null)
          await analytics.setUserId(id: userId);
        else {
          await analytics.setUserId(id: userId);
        }
      }
    }
  }

  static Future<void> sendAnalyticsEvent(String eventName,
      Map<String, dynamic> params, BuildContext context) async {
    if (WebservicePost.migraineMentorServerUrl == Constant.prodServerUrl) {
      var appConfig = AppConfig.of(context);
      if (appConfig?.appFlavour == Constant.migraineMentorPackageName){
        await analytics.logEvent(
          name: eventName,
          parameters: params,
        );
        debugPrint('user event logged');
      }
    }
  }

  static Future<void> sendShareAnalyticsEvent(BuildContext context) async {
    if (WebservicePost.migraineMentorServerUrl == Constant.prodServerUrl) {
      var appConfig = AppConfig.of(context);
      if (appConfig?.appFlavour == Constant.migraineMentorPackageName) {
        await analytics.logShare(
            contentType: 'text/plain', itemId: '1', method: 'invite');
      }
    }
  }

  static Future<void> setAnalyticsCurrentScreen(String screenName, BuildContext context) async {
    if (WebservicePost.migraineMentorServerUrl == Constant.prodServerUrl) {
      var appConfig = AppConfig.of(context);
      if (appConfig?.appFlavour == Constant.migraineMentorPackageName)
        await analytics.setCurrentScreen(screenName: screenName);
    }
  }

  static String getMoreScreenName(Widget widget) {
    String screenName;

    if (widget is MoreScreen) {
      screenName = Constant.moreScreen;
    } else if (widget is MoreSettingScreen) {
      screenName = Constant.moreSettingScreen;
    } else if (widget is MoreMyProfileScreen) {
      screenName = Constant.moreMyProfileScreen;
    } else if (widget is MoreGenerateReportScreen) {
      screenName = Constant.moreGenerateReportScreen;
    } else if (widget is MoreSupportScreen) {
      screenName = Constant.moreSupportScreen;
    } else if (widget is MoreFaqScreen) {
      screenName = Constant.moreFaqScreen;
    } else if (widget is MoreNotificationScreen) {
      screenName = Constant.moreNotificationScreen;
    } else if (widget is MoreHeadachesScreen) {
      screenName = Constant.moreHeadachesScreen;
    } else if (widget is MoreLocationServicesScreen) {
      screenName = Constant.moreLocationServicesScreen;
    } else if (widget is MoreNameScreen) {
      screenName = Constant.moreNameScreen;
    } else if (widget is MoreAgeScreen) {
      screenName = Constant.moreAgeScreen;
    } else if (widget is MoreGenderScreen) {
      screenName = Constant.moreGenderScreen;
    } else if (widget is MoreSexScreen) {
      screenName = Constant.moreSexScreen;
    } else if (widget is MoreTriggersScreen) {
      screenName = Constant.moreTriggersScreen;
    } else if (widget is MoreMedicationScreen) {
      screenName = Constant.moreMedicationScreen;
    } else if (widget is MoreEmailScreen) {
      screenName = Constant.moreEmailScreen;
    } else {
      screenName = Constant.blankString;
    }

    return screenName;
  }

  static void showSnackBar(BuildContext context, String errorMessage) {
    final snackBar = SnackBar(
      content: Text(
        errorMessage,
        style: TextStyle(
          height: 1.3,
          fontSize: 16,
          fontFamily: Constant.jostRegular,
          color: Colors.black,
        ),
      ),
      backgroundColor: Constant.chatBubbleGreen,
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static bool validateSubjectId(String subjectId) {
    RegExp regExp = RegExp("[0-9]{3}[-][0-9]{3}", caseSensitive: true);

    return regExp.hasMatch(subjectId);
  }

  ///This method is to get week day string text
  ///[weekDay] is the week day number
  static String getWeekDayText(int weekday) {
    String weekDayText = Constant.blankString;

    switch (weekday) {
      case 1:
        weekDayText = 'Su';
        break;
      case 2:
        weekDayText = 'M';
        break;
      case 3:
        weekDayText = 'Tu';
        break;
      case 4:
        weekDayText = 'W';
        break;
      case 5:
        weekDayText = 'Th';
        break;
      case 6:
        weekDayText = 'F';
        break;
      case 7:
        weekDayText = 'Sa';
        break;
    }

    return weekDayText;
  }

  ///This method is to get week day integer value
  ///[weekDay] is the weekDay number
  static int getWeekDayInteger(int weekDay) {
    int weekDayInt = 1;
    switch (weekDay) {
      case 1:
        weekDayInt = 2;
        break;
      case 2:
        weekDayInt = 3;
        break;
      case 3:
        weekDayInt = 4;
        break;
      case 4:
        weekDayInt = 5;
        break;
      case 5:
        weekDayInt = 6;
        break;
      case 6:
        weekDayInt = 7;
        break;
      case 7:
        weekDayInt = 1;
        break;
    }

    return weekDayInt;
  }

  ///This method is to get date time zone offset value
  ///[offset] is the offset number came from date time obj
  ///[isReplacePlus] is used replace + character from offset string.
  static String getDateTimeOffset(String offset, [bool isReplacePlus = true]) {
    List<String> splitString = offset.split(":");

    String timeZoneOffset = Constant.blankString;

    if (splitString.length >= 2) {
      if (!splitString[0].contains("-")) {
        if (isReplacePlus)
          splitString[0] = '%2B${splitString[0]}';
        else
          splitString[0] = '+${splitString[0]}';
      }

      timeZoneOffset = '${splitString[0]}:${splitString[1]}';
    }

    return timeZoneOffset;
  }

  /// This method is used to get DateTime object of time 12AM.
  static DateTime getDateTimeOf12AM(DateTime dateTime) {
    dateTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0, 0, 0);

    return dateTime;
  }

  ///This method is used to get the object of generic medication question
  ///[genericQuestionList] parameter is used to get generic question list
  ///[medicationName] parameter is used for searching medication
  ///[dosageType] parameter is used for searching dosageType
  static Questions? getGenericMedicationQuestion(
      List<Questions> genericQuestionList,
      String medicationName,
      String dosageType) {
    Questions? genericQuestion =
        genericQuestionList.firstWhereOrNull((element) {
      if (element.precondition!.contains("AND")) {
        List<String> splitAndConditionList = element.precondition!.split('AND');
        if (splitAndConditionList.length == 2) {
          splitAndConditionList[0] = splitAndConditionList[0].trim();
          splitAndConditionList[1] = splitAndConditionList[1].trim();

          List<String> splitMedicationConditionList =
              splitAndConditionList[0].split('=');
          List<String> splitDosageTypeConditionList =
              splitAndConditionList[1].split('=');

          if (splitMedicationConditionList.length == 2 &&
              splitDosageTypeConditionList.length == 2) {
            splitMedicationConditionList[0] =
                splitMedicationConditionList[0].trim();
            splitMedicationConditionList[1] =
                splitMedicationConditionList[1].trim();

            splitDosageTypeConditionList[0] =
                splitDosageTypeConditionList[0].trim();
            splitDosageTypeConditionList[1] =
                splitDosageTypeConditionList[1].trim();

            return (medicationName == splitMedicationConditionList[1] &&
                dosageType == splitDosageTypeConditionList[1]);
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    });

    return genericQuestion;
  }

  static String getMedicationOptionText(
      String medicationOptionValue, String genericMedicationName) {
    if (medicationOptionValue == Constant.plusText) {
      return medicationOptionValue;
    } else {
      if (medicationOptionValue == genericMedicationName)
        return '$medicationOptionValue';
      else
        return '$medicationOptionValue [$genericMedicationName]';
    }
  }

  ///This method is used to get the object of dosage type question
  ///[questionList] parameter is used to get dosage question list
  ///[medicationName] parameter is used for searching medication
  static Questions? getDosageTypeQuestion(
      List<Questions> questionList, String medicationName) {
    Questions? typeQuestion = questionList.firstWhereOrNull((element) {
      List<String> splitConditionList = element.precondition!.split('=');
      if (splitConditionList.length == 2) {
        splitConditionList[0] = splitConditionList[0].trim();
        splitConditionList[1] = splitConditionList[1].trim();

        return (medicationName == splitConditionList[1]);
      } else {
        return false;
      }
    });

    return typeQuestion;
  }

  ///This method is used to get the object of dosage question
  ///[dosageQuestionList] parameter is used to get dosage question list
  ///[medicationName] parameter is used for searching medication
  ///[dosageType] parameter is used for searching dosageType
  static Questions? getDosageQuestion(List<Questions> dosageQuestionList,
      String medicationName, String dosageType) {
    Questions? dosageQuestion = dosageQuestionList.firstWhereOrNull((element) {
      if (element.precondition!.contains("AND")) {
        List<String> splitAndConditionList = element.precondition!.split('AND');
        if (splitAndConditionList.length == 2) {
          splitAndConditionList[0] = splitAndConditionList[0].trim();
          splitAndConditionList[1] = splitAndConditionList[1].trim();

          List<String> splitMedicationConditionList =
              splitAndConditionList[0].split('=');
          List<String> splitDosageTypeConditionList =
              splitAndConditionList[1].split('=');

          if (splitMedicationConditionList.length == 2 &&
              splitDosageTypeConditionList.length == 2) {
            splitMedicationConditionList[0] =
                splitMedicationConditionList[0].trim();
            splitMedicationConditionList[1] =
                splitMedicationConditionList[1].trim();

            splitDosageTypeConditionList[0] =
                splitDosageTypeConditionList[0].trim();
            splitDosageTypeConditionList[1] =
                splitDosageTypeConditionList[1].trim();

            return (medicationName == splitMedicationConditionList[1] &&
                dosageType == splitDosageTypeConditionList[1]);
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    });

    return dosageQuestion;
  }

  static dynamic calculateAge(String birthDate) {
    if (birthDate != Constant.blankString) {
      int birthYear = int.parse(birthDate.substring(0, 4));
      debugPrint(birthYear.toString());
      int birthMonth = int.parse(birthDate.substring(4, 6));
      debugPrint(birthMonth.toString());
      int birthDay = int.parse(birthDate.substring(6));
      debugPrint(birthDay.toString());

      int age = DateTime.now().year - birthYear;
      if (birthMonth > DateTime.now().month) {
        age--;
      } else if (birthMonth == DateTime.now().month) {
        if (birthDay > DateTime.now().day) {
          age--;
        }
      }
      return age.toString();
    } else {
      return 'age';
    }
  }

  ///This method is used to validate medication values of type "GenericName [BrandName, BrandName]"
  static bool getMedicationValidation(String medicationText) {
    Pattern pattern = '[\\w]* \\([\\w]*(, [\\w \\w]*)+\\)*';
    RegExp regExp = RegExp(pattern.toString());

    return regExp.hasMatch(medicationText);
  }

  static String getMonthYearText(DateTime dateTime) {
    return '${Constant.monthMapper[dateTime.month]} ${dateTime.year}';
  }

  static int fetchQuestionTag(
      {required int currentPageIndex,
      required List<Questions> currentQuestionListData,
      required SignUpOnBoardSelectedAnswersModel
          signUpOnBoardSelectedAnswersModel}) {
    if (currentPageIndex < currentQuestionListData.length - 1) {
      currentPageIndex++;
      Questions questions = currentQuestionListData[currentPageIndex];

      if (questions.precondition!.isEmpty) {
        debugPrint('QUESTION TAG???${questions.tag}');
      } else {
        //write logic for precondition

        //replacing the parenthesis with the blank string
        String preCondition = questions.precondition!;
        preCondition = preCondition.replaceAll('(', Constant.blankString);
        preCondition = preCondition.replaceAll(')', Constant.blankString);
        preCondition = preCondition.replaceAll(' ', Constant.blankString);

        if (preCondition.contains('AND')) {
          bool? isConditionSatisfied;

          List<String> splitANDCondition = preCondition.split('AND');

          for (int i = 0; i < splitANDCondition.length; i++) {
            String splitANDConditionElement = splitANDCondition[i];
            if (splitANDConditionElement.contains('<=')) {
              List<String> splitConditionList =
                  splitANDConditionElement.split('<=');
              if (evaluatePreCondition(
                  splitConditionList: splitConditionList,
                  predicate: '<=',
                  signUpOnBoardSelectedAnswersModel:
                      signUpOnBoardSelectedAnswersModel)) {
                if (isConditionSatisfied == null) {
                  isConditionSatisfied = true;
                }
              } else {
                isConditionSatisfied = false;
                break;
              }
            } else if (splitANDConditionElement.contains('>=')) {
              List<String> splitConditionList =
                  splitANDConditionElement.split('>=');
              if (evaluatePreCondition(
                  splitConditionList: splitConditionList,
                  predicate: '>=',
                  signUpOnBoardSelectedAnswersModel:
                      signUpOnBoardSelectedAnswersModel)) {
                if (isConditionSatisfied == null) {
                  isConditionSatisfied = true;
                }
              } else {
                isConditionSatisfied = false;
                break;
              }
            } else if (splitANDConditionElement.contains('=')) {
              if (splitANDConditionElement.contains('NOT')) {
                splitANDConditionElement = splitANDConditionElement.replaceAll(
                    'NOT', Constant.blankString);
                List<String> splitConditionList =
                    splitANDConditionElement.split('=');
                if (!evaluatePreCondition(
                    splitConditionList: splitConditionList,
                    predicate: '=',
                    signUpOnBoardSelectedAnswersModel:
                        signUpOnBoardSelectedAnswersModel)) {
                  if (isConditionSatisfied == null) {
                    isConditionSatisfied = true;
                  }
                } else {
                  isConditionSatisfied = false;
                  break;
                }
              } else {
                List<String> splitConditionList =
                    splitANDConditionElement.split('=');
                if (evaluatePreCondition(
                    splitConditionList: splitConditionList,
                    predicate: '=',
                    signUpOnBoardSelectedAnswersModel:
                        signUpOnBoardSelectedAnswersModel)) {
                  if (isConditionSatisfied == null) {
                    isConditionSatisfied = true;
                  }
                } else {
                  isConditionSatisfied = false;
                  break;
                }
              }
            }
          }

          if (isConditionSatisfied != null && !isConditionSatisfied)
            currentPageIndex = fetchQuestionTag(
                currentPageIndex: currentPageIndex,
                currentQuestionListData: currentQuestionListData,
                signUpOnBoardSelectedAnswersModel:
                    signUpOnBoardSelectedAnswersModel);
          else
            return currentPageIndex;
        } else if (preCondition.contains('OR')) {
          bool isConditionSatisfied = false;

          List<String> splitANDCondition = preCondition.split('OR');

          for (int i = 0; i < splitANDCondition.length; i++) {
            String splitANDConditionElement = splitANDCondition[i];
            if (splitANDConditionElement.contains('<=')) {
              List<String> splitConditionList =
                  splitANDConditionElement.split('<=');
              if (evaluatePreCondition(
                  splitConditionList: splitConditionList,
                  predicate: '<=',
                  signUpOnBoardSelectedAnswersModel:
                      signUpOnBoardSelectedAnswersModel)) {
                isConditionSatisfied = true;
                break;
              } else {
                isConditionSatisfied = isConditionSatisfied || false;
              }
            } else if (splitANDConditionElement.contains('>=')) {
              List<String> splitConditionList =
                  splitANDConditionElement.split('>=');
              if (evaluatePreCondition(
                  splitConditionList: splitConditionList,
                  predicate: '>=',
                  signUpOnBoardSelectedAnswersModel:
                      signUpOnBoardSelectedAnswersModel)) {
                isConditionSatisfied = true;
                break;
              } else {
                isConditionSatisfied = isConditionSatisfied || false;
              }
            } else if (splitANDConditionElement.contains('=')) {
              if (splitANDConditionElement.contains('NOT')) {
                splitANDConditionElement =
                    preCondition.replaceAll('NOT', Constant.blankString);
                List<String> splitConditionList =
                    splitANDConditionElement.split('=');
                if (!evaluatePreCondition(
                    splitConditionList: splitConditionList,
                    predicate: '=',
                    signUpOnBoardSelectedAnswersModel:
                        signUpOnBoardSelectedAnswersModel)) {
                  isConditionSatisfied = true;
                  break;
                } else {
                  isConditionSatisfied = isConditionSatisfied || false;
                }
              } else {
                List<String> splitConditionList =
                    splitANDConditionElement.split('=');
                if (evaluatePreCondition(
                    splitConditionList: splitConditionList,
                    predicate: '=',
                    signUpOnBoardSelectedAnswersModel:
                        signUpOnBoardSelectedAnswersModel)) {
                  isConditionSatisfied = true;
                  break;
                } else {
                  isConditionSatisfied = isConditionSatisfied || false;
                }
              }
            }
          }

          if (!isConditionSatisfied)
            currentPageIndex = fetchQuestionTag(
                currentPageIndex: currentPageIndex,
                currentQuestionListData: currentQuestionListData,
                signUpOnBoardSelectedAnswersModel:
                    signUpOnBoardSelectedAnswersModel);
          else
            return currentPageIndex;
        } else {
          if (preCondition.contains('<=')) {
            List<String> splitConditionList = preCondition.split('<=');
            if (evaluatePreCondition(
                splitConditionList: splitConditionList,
                predicate: '<=',
                signUpOnBoardSelectedAnswersModel:
                    signUpOnBoardSelectedAnswersModel)) {
              debugPrint('QUESTION TAG???${questions.tag}');
              return currentPageIndex;
            } else {
              currentPageIndex = fetchQuestionTag(
                  currentPageIndex: currentPageIndex,
                  currentQuestionListData: currentQuestionListData,
                  signUpOnBoardSelectedAnswersModel:
                      signUpOnBoardSelectedAnswersModel);
            }
          } else if (preCondition.contains('>=')) {
            List<String> splitConditionList = preCondition.split('>=');
            if (evaluatePreCondition(
                splitConditionList: splitConditionList,
                predicate: '>=',
                signUpOnBoardSelectedAnswersModel:
                    signUpOnBoardSelectedAnswersModel)) {
              debugPrint('QUESTION TAG???${questions.tag}');
              return currentPageIndex;
            } else {
              currentPageIndex = fetchQuestionTag(
                  currentPageIndex: currentPageIndex,
                  currentQuestionListData: currentQuestionListData,
                  signUpOnBoardSelectedAnswersModel:
                      signUpOnBoardSelectedAnswersModel);
            }
          } else if (preCondition.contains('>')) {
            List<String> splitConditionList = preCondition.split('>');
            if (evaluatePreCondition(
                splitConditionList: splitConditionList,
                predicate: '>',
                signUpOnBoardSelectedAnswersModel:
                    signUpOnBoardSelectedAnswersModel)) {
              debugPrint('QUESTION TAG???${questions.tag}');
              return currentPageIndex;
            } else {
              currentPageIndex = fetchQuestionTag(
                  currentPageIndex: currentPageIndex,
                  currentQuestionListData: currentQuestionListData,
                  signUpOnBoardSelectedAnswersModel:
                      signUpOnBoardSelectedAnswersModel);
            }
          } else if (preCondition.contains('<')) {
            List<String> splitConditionList = preCondition.split('<');
            if (evaluatePreCondition(
                splitConditionList: splitConditionList,
                predicate: '<',
                signUpOnBoardSelectedAnswersModel:
                    signUpOnBoardSelectedAnswersModel)) {
              debugPrint('QUESTION TAG???${questions.tag}');
              return currentPageIndex;
            } else {
              currentPageIndex = fetchQuestionTag(
                  currentPageIndex: currentPageIndex,
                  currentQuestionListData: currentQuestionListData,
                  signUpOnBoardSelectedAnswersModel:
                      signUpOnBoardSelectedAnswersModel);
            }
          } else if (preCondition.contains('=')) {
            List<String> splitConditionList = preCondition.split('=');
            if (evaluatePreCondition(
                splitConditionList: splitConditionList,
                predicate: '=',
                signUpOnBoardSelectedAnswersModel:
                    signUpOnBoardSelectedAnswersModel)) {
              debugPrint('QUESTION TAG???${questions.tag}');
              return currentPageIndex;
            } else {
              currentPageIndex = fetchQuestionTag(
                  currentPageIndex: currentPageIndex,
                  currentQuestionListData: currentQuestionListData,
                  signUpOnBoardSelectedAnswersModel:
                      signUpOnBoardSelectedAnswersModel);
            }
          }
        }
      }
    }
    return currentPageIndex;
  }

  static bool evaluatePreCondition(
      {List<String>? splitConditionList,
      String? predicate,
      required SignUpOnBoardSelectedAnswersModel
          signUpOnBoardSelectedAnswersModel}) {
    String questionTag = splitConditionList![0];
    if (splitConditionList.length == 2) {
      switch (predicate) {
        case '<=':
          int answer = int.tryParse(splitConditionList[1])!;
          SelectedAnswers? selectedAnswer = signUpOnBoardSelectedAnswersModel
              .selectedAnswers
              ?.firstWhereOrNull(
                  (element) => element.questionTag == questionTag);
          if (selectedAnswer != null) {
            return int.tryParse(selectedAnswer.answer!)! <= answer;
          } else {
            return false;
          }
        case '>=':
          int answer = int.tryParse(splitConditionList[1])!;
          SelectedAnswers? selectedAnswer = signUpOnBoardSelectedAnswersModel
              .selectedAnswers
              ?.firstWhereOrNull(
                  (element) => element.questionTag == questionTag);
          if (selectedAnswer != null) {
            return int.tryParse(selectedAnswer.answer!)! >= answer;
          } else {
            return false;
          }
        case '<':
          int answer = int.tryParse(splitConditionList[1])!;
          SelectedAnswers? selectedAnswer = signUpOnBoardSelectedAnswersModel
              .selectedAnswers
              ?.firstWhereOrNull(
                  (element) => element.questionTag == questionTag);
          if (selectedAnswer != null) {
            return int.tryParse(selectedAnswer.answer!)! < answer;
          } else {
            return false;
          }
        case '>':
          int answer = int.tryParse(splitConditionList[1])!;
          SelectedAnswers? selectedAnswer = signUpOnBoardSelectedAnswersModel
              .selectedAnswers
              ?.firstWhereOrNull(
                  (element) => element.questionTag == questionTag);
          if (selectedAnswer != null) {
            return int.tryParse(selectedAnswer.answer!)! > answer;
          } else {
            return false;
          }
        case '=':
          String answer = splitConditionList[1];
          SelectedAnswers? selectedAnswer = signUpOnBoardSelectedAnswersModel
              .selectedAnswers
              ?.firstWhereOrNull(
                  (element) => element.questionTag == questionTag);
          if (selectedAnswer != null) {
            int? intSelectedAnswer = int.tryParse(selectedAnswer.answer!
                    .replaceAll(' ', Constant.blankString)) ??
                null;
            int? intAnswer = int.tryParse(answer) ?? null;

            if (intSelectedAnswer != null && intAnswer != null) {
              return intAnswer == intSelectedAnswer;
            } else {
              return selectedAnswer.answer!
                  .replaceAll(' ', Constant.blankString)
                  .contains(answer);
            }
          } else {
            return false;
          }
        default:
          return false;
      }
    } else {
      return false;
    }
  }

  static String dateDifferenceTextGenerator(
      String? medicationName, Map<String, DateTime> unitMedicationsLastDate) {
    int days = (DateTime.now()
                    .difference(unitMedicationsLastDate[medicationName]!)
                    .inHours /
                24)
            .round() -
        1;
    if (days > 0) {
      if (days == 1) {
        return '($days day ago)';
      } else {
        return '($days days ago)';
      }
    } else {
      return Constant.blankString;
    }
  }

  //last given date generator for unit dosage medications:
  static void lastGivenDateGenerator(
      List<MedicationHistoryModel> medicationHistoryDataModelList,
      Map<String, DateTime> unitMedicationsLastDate) {
    for (MedicationHistoryModel medication in medicationHistoryDataModelList) {
      if (medication.dosage.contains('units')) {
        if (unitMedicationsLastDate.isNotEmpty) {
          if (unitMedicationsLastDate.containsKey(medication.medicationName)) {
            if (medication.startDate!
                .isAfter(unitMedicationsLastDate[medication.medicationName]!)) {
              unitMedicationsLastDate[medication.medicationName] =
                  medication.startDate ??
                      unitMedicationsLastDate[medication.medicationName]!;
            }
          } else {
            unitMedicationsLastDate[medication.medicationName] =
                medication.startDate ?? DateTime.now();
          }
        } else {
          unitMedicationsLastDate[medication.medicationName] =
              medication.startDate ?? DateTime.now();
        }
      }
    }
  }

  static int countFractionDigits(double value) {
    String valueStr = value.toString();
    int decimalPointIndex = valueStr.indexOf('.');
    if (decimalPointIndex == -1) {
      return 0; // No decimal point found, so there are no fraction digits.
    }
    return valueStr.length - decimalPointIndex - 1;
  }

/*  static Future<Map<HealthDataType, HealthAuthorizationStatus>> getHealthDataPermissionResult(MethodChannel platform, List<HealthDataType> healthDataTypeList) async {
    Map<HealthDataType, HealthAuthorizationStatus> map = HashMap();

    for (HealthDataType type in healthDataTypeList) {
      final args = {
        'dataTypeName': type.name,
      };
      
      dynamic result = await platform.invokeMethod('checkPermission', args);

      if (result is Map<dynamic, dynamic> && result.isNotEmpty) {
        dynamic dataType = result.keys.first;
        dynamic status = result[result.keys.first];

        if (dataType is String && status is String) {
          map[_getHealthDataType(dataType)] = _getHealthAuthorizationStatus(status);
        }
      }
    }
    return map;
  }*/

/*  static HealthDataType _getHealthDataType(String dataTypeString) {
    switch (dataTypeString) {
      case "BLOOD_OXYGEN":
        return HealthDataType.BLOOD_OXYGEN;
      case "BLOOD_PRESSURE_DIASTOLIC":
        return HealthDataType.BLOOD_PRESSURE_DIASTOLIC;
      case "BLOOD_PRESSURE_SYSTOLIC":
        return HealthDataType.BLOOD_PRESSURE_SYSTOLIC;
      case "BODY_TEMPERATURE":
        return HealthDataType.BODY_TEMPERATURE;
      case "ELECTRODERMAL_ACTIVITY":
        return HealthDataType.ELECTRODERMAL_ACTIVITY;
      case "HEART_RATE":
        return HealthDataType.HEART_RATE;
      case "HEART_RATE_VARIABILITY_SDNN":
        return HealthDataType.HEART_RATE_VARIABILITY_SDNN;
      case "RESTING_HEART_RATE":
        return HealthDataType.RESTING_HEART_RATE;
      case "WALKING_HEART_RATE":
        return HealthDataType.WALKING_HEART_RATE;
      case "EXERCISE_TIME":
        return HealthDataType.EXERCISE_TIME;
      case "HEADACHE_UNSPECIFIED":
        return HealthDataType.HEADACHE_UNSPECIFIED;
      case "HEADACHE_NOT_PRESENT":
        return HealthDataType.HEADACHE_NOT_PRESENT;
      case "HEADACHE_MILD":
        return HealthDataType.HEADACHE_MILD;
      case "HEADACHE_MODERATE":
        return HealthDataType.HEADACHE_MODERATE;
      case "HEADACHE_SEVERE":
        return HealthDataType.HEADACHE_SEVERE;
      default:
        return HealthDataType.ACTIVE_ENERGY_BURNED;
    }
  }*/

  static HealthAuthorizationStatus _getHealthAuthorizationStatus(
      String? status) {
    switch (status) {
      case "NOT_DETERMINED":
        return HealthAuthorizationStatus.NOT_DETERMINED;
      case "SHARING_AUTHORIZED":
        return HealthAuthorizationStatus.SHARING_AUTHORIZED;
      case "SHARING_DENIED":
        return HealthAuthorizationStatus.SHARING_DENIED;
      default:
        return HealthAuthorizationStatus.SHARING_DENIED;
    }
  }
}
