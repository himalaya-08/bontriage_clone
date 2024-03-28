import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/blocs/CheckVersionUpdateBloc.dart';
import 'package:mobile/models/VersionUpdateModel.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppConfig.dart';
import '../main.dart';
import 'login_screen.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Timer? _timer;
  CheckVersionUpdateBloc? _checkVersionUpdateBloc;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    _checkVersionUpdateBloc = CheckVersionUpdateBloc();
    _listenToNetworkStreamController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _checkForNotificationPermission();
    });
    //FirebaseCrashlytics.instance.crash();
  }

  @override
  void dispose() {
    try {
      _checkVersionUpdateBloc!.dispose();
      _timer!.cancel();
    } catch (e) {
      print(e);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appConfig = AppConfig.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? AssetImage(Constant.splashCompass) : AssetImage(Constant.tonixSplash),
                    width: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? 78 : 128,
                    height: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? 78 : 128,
                  ),
                  Visibility(
                    visible: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                    child: SizedBox(
                      width: 10,
                    ),
                  ),
                  Visibility(
                    visible: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                    child: CustomTextWidget(
                      text: Constant.migraineMentor,
                      style: TextStyle(
                          color: Constant.splashTextColor,
                          fontSize: 22,
                          fontFamily: Constant.jostRegular),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: appConfig?.buildFlavor == Constant.tonixBuildFlavor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomTextWidget(
                      text: Constant.poweredBy,
                      style: TextStyle(
                          color: Constant.splashTextColor.withOpacity(0.6),
                          fontSize: 14,
                          fontFamily: Constant.jostRegular),
                    ),
                    CustomTextWidget(
                      text: Constant.bonTriageMigraineMentor,
                      style: TextStyle(
                          color: Constant.splashTextColor,
                          fontSize: 14,
                          fontFamily: Constant.jostMedium),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Constant.splashColor,
    );
  }

  void getTutorialsState() async {
    var appConfig = AppConfig.of(context);

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? isTutorialsHasSeen =
    sharedPreferences.getBool(Constant.tutorialsState);
    var userAlreadyLoggedIn =
    sharedPreferences.getBool(Constant.userAlreadyLoggedIn);

    _removeKeysFromSharedPreference(sharedPreferences);
    if(userAlreadyLoggedIn != null && userAlreadyLoggedIn) {
      _timer = Timer.periodic(Duration(seconds: 2), (timer) {
        Navigator.pushReplacementNamed(context, Constant.homeRouter);
        timer.cancel();
      });
    } else {
      if (isTutorialsHasSeen != null && isTutorialsHasSeen) {
        _timer = Timer.periodic(Duration(seconds: 3), (timer) {
          if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
            Navigator.pushReplacementNamed(context, Constant.welcomeStartAssessmentScreenRouter);
          else
            Navigator.pushReplacementNamed(context, Constant.loginScreenRouter,
                arguments: LoginScreenArgumentModel(
                    isFromSignUp: false, isFromMore: true));
          timer.cancel();
        });
      } else {
        if (userAlreadyLoggedIn == null || !userAlreadyLoggedIn) {
          _timer = Timer.periodic(Duration(seconds: 2), (timer) {
            if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
              Navigator.pushReplacementNamed(context, Constant.welcomeScreenRouter);
            else
              Navigator.pushReplacementNamed(context, Constant.loginScreenRouter,
                  arguments: LoginScreenArgumentModel(
                      isFromSignUp: false, isFromMore: true));
            timer.cancel();
          });
        } else {
          _timer = Timer.periodic(Duration(seconds: 2), (timer) {
            Navigator.pushReplacementNamed(context, Constant.homeRouter);
            timer.cancel();
          });
        }
      }
    }
  }

  void _removeKeysFromSharedPreference(SharedPreferences sharedPreferences) {
    sharedPreferences.remove(Constant.updateCalendarTriggerData);
    sharedPreferences.remove(Constant.updateCalendarIntensityData);
    sharedPreferences.remove(Constant.updateOverTimeCompassData);
    sharedPreferences.remove(Constant.updateCompareCompassData);
    sharedPreferences.remove(Constant.updateTrendsData);
    sharedPreferences.remove(Constant.isSeeMoreClicked);
    sharedPreferences.remove(Constant.isViewTrendsClicked);
    sharedPreferences.remove(Constant.updateMeScreenData);
  }

  void _checkForNotificationPermission() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled() ?? false;
      if (!granted) {
        var result = await Constant.platform.invokeMethod('getNotificationPermission');

        _checkCriticalVersionUpdate();
      } else {
        _checkCriticalVersionUpdate();
      }
    } else {
      _checkCriticalVersionUpdate();
    }
    //_checkCriticalVersionUpdate();
  }

  void _listenToNetworkStreamController() {
    _checkVersionUpdateBloc!.networkStream.listen((event) {
      if(event is String && event != null && event.isNotEmpty) {
        final snackBar = SnackBar(
          content: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragStart: (_) => debugPrint("no can do!"),
          child: CustomTextWidget(
            text: event,
            style: TextStyle(
              height: 1.3,
              fontSize: 16,
              fontFamily: Constant.jostRegular,
              color: Colors.black,
            ),
          ),),
          backgroundColor: Constant.chatBubbleGreen,
          duration: Duration(days: 3),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Constant.backgroundColor,
            onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _checkForNotificationPermission();
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  /// This method will be use for to check critical update from server.So if get critical update from server. So
  /// we will show a popup to the user. if it's nt then we move to user into Home Screen.
  void _checkCriticalVersionUpdate() async {
    VersionUpdateModel responseData = await _checkVersionUpdateBloc
        !.checkVersionUpdateData(context);
    if (responseData != null) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      debugPrint('PackageName=${packageInfo.packageName}');
      int appVersionNumber = int.tryParse(
          packageInfo.version.replaceAll('.', ''))!;
      if (Platform.isAndroid) {
        int serverVersionNumber = int.tryParse(
            responseData.androidVersion!.replaceAll('.', ''))!;
        if (serverVersionNumber > appVersionNumber &&
            responseData.androidCritical!) {
          Utils.showCriticalUpdateDialog(
              context, responseData.androidBuildDetails!);
        } else {
          getTutorialsState();
        }
      } else {
        int serverVersionNumber = int.tryParse(
            responseData.iosVersion!.replaceAll('.', ''))!;
        if (serverVersionNumber > appVersionNumber &&
            responseData.iosCritical!) {
          Utils.showCriticalUpdateDialog(context, responseData.description!);
        } else {
          int serverVersionNumber = int.tryParse(
              responseData.iosVersion!.replaceAll('.', ''))!;
          if (serverVersionNumber > appVersionNumber &&
              responseData.iosCritical!) {
            Utils.showCriticalUpdateDialog(context, responseData.description!);
          } else {
            getTutorialsState();
          }
        }
      }
    }
  }
}