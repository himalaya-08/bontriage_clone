import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/animations/ScaleInPageRoute.dart';
import 'package:mobile/animations/SlideFromBottomPageRoute.dart';
import 'package:mobile/animations/SlideFromRightPageRoute.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/HomeScreenArgumentModel.dart';
import 'package:mobile/models/PostClinicalImpressionArgumentModel.dart';
import 'package:mobile/providers/UserNameInfo.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/view/HeadacheQuestionnaireDisclaimer.dart';
import 'package:mobile/models/LogDayScreenArgumentModel.dart';
import 'package:mobile/models/PartTwoOnBoardArgumentModel.dart';
import 'package:mobile/util/TabNavigatorRoutes.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/AddHeadacheOnGoingScreen.dart';
import 'package:mobile/view/AddHeadacheSuccessScreen.dart';
import 'package:mobile/view/CalendarHeadacheLogDayDetailsScreen.dart';
import 'package:mobile/view/CalendarIntensityScreen.dart';
import 'package:mobile/view/CalendarScreen.dart';
import 'package:mobile/view/CalendarTriggersScreen.dart';
import 'package:mobile/view/ChangePasswordScreen.dart';
import 'package:mobile/view/CompassScreen.dart';
import 'package:mobile/view/AddNewHeadacheIntroScreen.dart';
import 'package:mobile/view/CurrentHeadacheProgressScreen.dart';
import 'package:mobile/view/HeadacheStartedScreen.dart';
import 'package:mobile/view/HomeScreen.dart';
import 'package:mobile/view/LogDayScreen.dart';
import 'package:mobile/view/LogDaySuccessScreen.dart';
import 'package:mobile/view/NotificationScreen.dart';
import 'package:mobile/view/OnBoardCreateAccountScreen.dart';
import 'package:mobile/view/OnBoardExitScreen.dart';
import 'package:mobile/view/OnBoardHeadacheInfoScreen.dart';
import 'package:mobile/view/OnBoardHeadacheNameScreen.dart';
import 'package:mobile/view/OnBoardingSignUpScreen.dart';
import 'package:mobile/view/OtpValidationScreen.dart';
import 'package:mobile/view/PDFScreen.dart';
import 'package:mobile/view/PartOneOnBoardScreenTwo.dart';
import 'package:mobile/view/PartThreeOnBoardScreens.dart';
import 'package:mobile/view/PartTwoOnBoardMoveOnScreen.dart';
import 'package:mobile/view/PostClinicalImpressionScreen.dart';
import 'package:mobile/view/PostNotificationOnBoardScreen.dart';
import 'package:mobile/view/PostPartThreeOnBoardScreen.dart';
import 'package:mobile/view/PrePartThreeOnBoardScreen.dart';
import 'package:mobile/view/PrePartTwoOnBoardScreen.dart';
import 'package:mobile/view/ProfileComplete.dart';
import 'package:mobile/view/SignUpFirstStepCompassResult.dart';
import 'package:mobile/view/SignUpOnBoardPersonalizedHeadacheCompass.dart';
import 'package:mobile/view/SignUpOnBoardSecondStepPersonalizedHeadacheCompass..dart';
import 'package:mobile/view/SignUpOnBoardSplash.dart';
import 'package:mobile/view/SignUpOnBoardStartAssessment.dart';
import 'package:mobile/view/SignUpScreen.dart';
import 'package:mobile/view/SignUpSecondStepCompassResult.dart';
import 'package:mobile/view/Splash.dart';
import 'package:mobile/view/TimeSection.dart';
import 'package:mobile/view/TonixAddHeadacheScreen.dart';
import 'package:mobile/view/TonixTimeSection.dart';
import 'package:mobile/view/WebViewScreen.dart';
import 'package:mobile/view/WelcomeScreen.dart';
import 'package:mobile/view/WelcomeStartAssessmentScreen.dart';
import 'package:mobile/view/login_screen.dart';
import 'package:mobile/view/part_two_on_board_screens.dart';
import 'package:mobile/view/sign_up_age_screen.dart';
import 'package:mobile/view/sign_up_location_services.dart';
import 'package:mobile/view/sign_up_name_screen.dart';
import 'package:mobile/view/sign_up_on_board_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'animations/SlideFromLeftPageRoute.dart';
import 'models/PDFScreenArgumentModel.dart';
import 'view/SignUpOnBoardBubbleTextView.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:health/health.dart';

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

InitializationSettings? initializationSettings;

FirebaseAnalytics analytics = FirebaseAnalytics.instance;
FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

HealthFactory healthFactory = HealthFactory();

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

Future<void> mainCommon(AppConfig appConfig) async {
  await _configureLocalTimeZone();

  // Initialize Firebase.
  await Firebase.initializeApp();
  await initNotification(appConfig);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  appConfig.appFlavour = packageInfo.packageName;

  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    /*FlutterError.onError = (flutterErrorDetails) {
      debugPrint('FatalError?????recordFlutterError');
      FirebaseCrashlytics.instance.recordFlutterError(flutterErrorDetails);
    };*/
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = (flutterErrorDetails) {
      debugPrint('FatalError?????recordFlutterError');
      FirebaseCrashlytics.instance.recordFlutterError(flutterErrorDetails);
    };
  }

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('FatalError?????PlatformDispatcher.instance.onError');
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  ///Checks whether the server is prod & flavour is migraineMentor or not, if not sending analytics data is disabled
  if (WebservicePost.migraineMentorServerUrl != Constant.prodServerUrl){
    await analytics.setAnalyticsCollectionEnabled(false);
  }
  else {
    if (packageInfo.packageName != Constant.migraineMentorPackageName){
      await analytics.setAnalyticsCollectionEnabled(false);
    }
  }
}

/// This method will be use for when app was killed.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  debugPrint('Got a message whilst in the background app!');
  debugPrint('Message data: ${message.data}');
  if (message.notification != null) {
    debugPrint('Message also contained a notification: ${message.notification!.title}');
       /*Utils.saveDataInSharedPreference(
        Constant.pushNotificationTitle, message.notification.title.toString());*/

    //Utils.showValidationErrorDialog(context, 'From Background ${message.data.toString()}');
  }
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  String timeZoneName = await FlutterTimezone.getLocalTimezone();
  if(timeZoneName == 'Asia/Calcutta') {
    timeZoneName = 'Asia/Kolkata';
  }
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

/// This Method will be use for initialize all android and IOs Plugin and other required variables.
Future<void> initNotification(AppConfig appConfig) async {
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? 'app_icon' : 'tonix_app_icon');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          onDidReceiveLocalNotification:
              (int? id, String? title, String? body, String? payload) async {
            didReceiveLocalNotificationSubject.add(ReceivedNotification(
                id: 1,
                title: 'BonTriage',
                body: 'Log Kar diya',
                payload: 'Reminder to log your day.'));
          });
  initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
}

Map<int, Color> color = {
  50: Constant.chatBubbleGreen,
  100: Constant.chatBubbleGreen,
  200: Constant.chatBubbleGreen,
  300: Constant.chatBubbleGreen,
  400: Constant.chatBubbleGreen,
  500: Constant.chatBubbleGreen,
  600: Constant.chatBubbleGreen,
  700: Constant.chatBubbleGreen,
  800: Constant.chatBubbleGreen,
  900: Constant.chatBubbleGreen,
};

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        hintColor: Constant.backgroundColor,

        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primarySwatch: MaterialColor(0xffafd794, color),
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      home: Splash(),
      initialRoute: Constant.splashRouter,
      onGenerateRoute: (settings) {
        RouteSettings routeSettings = RouteSettings(name: settings.name);
        debugPrint(routeSettings.name);
        switch (settings.name) {
          case Constant.splashRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: Splash(), routeSettings: routeSettings);
            }
          case Constant.welcomeScreenRouter:
            {
              return SlideFromRightPageRoute(
                widget: ChangeNotifierProvider(
                  create: (context) => WelcomePageInfo(),
                  child: WelcomeScreen(),
                ),
                routeSettings: routeSettings,
              );
            }
          case Constant.headacheQuestionnaireDisclaimerScreenRouter:
            {
              return SlideFromRightPageRoute(
                widget: MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (context) => UserNameInfo(),
                    ),
                  ],
                  child: HeadacheQuestionnaireDisclaimerScreen(
                    fromScreenRouter: settings.arguments as String,
                  ),
                ),
                routeSettings: routeSettings,
              );
            }
          case Constant.postClinicalImpressionScreenRouter: {
            return SlideFromRightPageRoute(
              widget: PostClinicalImpressionScreen(
                postClinicalImpressionArgumentModel: settings.arguments != null ? settings.arguments as PostClinicalImpressionArgumentModel : null,
              ), routeSettings: routeSettings,
            );
          }
          case Constant.homeRouter:
            {
              return SlideFromRightPageRoute(
                  widget:
                      HomeScreen(homeScreenArgumentModel: settings.arguments != null ? settings.arguments as HomeScreenArgumentModel : null),
                  routeSettings: routeSettings);
            }

          case Constant.signUpOnBoardSplashRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: SignUpOnBoardSplash(), routeSettings: routeSettings);
            }
          case Constant.signUpOnBoardStartAssessmentRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: SignUpOnBoardStartAssessment(),
                  routeSettings: routeSettings);
            }
          case Constant.signUpNameScreenRouter:
            {
              return SlideFromRightPageRoute(
                  widget: SignUpNameScreen(), routeSettings: routeSettings);
            }
          case Constant.signUpAgeScreenRouter:
            {
              return SlideFromRightPageRoute(
                  widget: SignUpAgeScreen(), routeSettings: routeSettings);
            }
          case Constant.addNewHeadacheIntroScreen:
            {
              return SlideFromRightPageRoute(
                widget: MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (context) => UserNameInfo(),
                    ),
                  ],
                  child: AddNewHeadacheIntroScreen(
                    fromScreenRouter: settings.arguments as String,
                  ),
                ),
                routeSettings: routeSettings,
              );
            }
          case Constant.signUpLocationServiceRouter:
            {
              return SlideFromRightPageRoute(
                  widget: SignUpLocationServices(),
                  routeSettings: routeSettings);
            }
          case Constant.signUpOnBoardProfileQuestionRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: SignUpOnBoardScreen(), routeSettings: routeSettings);
            }
          case Constant.signUpFirstStepHeadacheResultRouter:
            {
              return ScaleInPageRoute(
                  widget: SignUpFirstStepCompassResult(),
                  routeSettings: routeSettings);
            }
          case Constant.signUpOnBoardPersonalizedHeadacheResultRouter:
            {
              return ScaleInPageRoute(
                  widget: SignUpOnBoardPersonalizedHeadacheCompass(),
                  routeSettings: routeSettings);
            }
          case Constant.partTwoOnBoardScreenRouter:
            {
              return SlideFromRightPageRoute(
                widget: PartTwoOnBoardScreens(
                    partTwoOnBoardArgumentModel: settings.arguments != null ? settings.arguments as PartTwoOnBoardArgumentModel : null
                ),
                routeSettings: routeSettings,
              );
            }
          case Constant.partThreeOnBoardScreenRouter:
            {
              return SlideFromRightPageRoute(
                  widget: PartThreeOnBoardScreens(),
                  routeSettings: routeSettings);
            }
          case Constant.loginScreenRouter:
            {
              return SlideFromRightPageRoute(
                widget: MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (context) => PasswordHiddenInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => ForgotPasswordClickedInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => LoginErrorInfo(),
                    ),
                  ],
                  child: LoginScreen(
                      loginScreenArgumentModel: settings.arguments != null ? settings.arguments as LoginScreenArgumentModel : null
                  ),
                ),
                routeSettings: routeSettings,
              );
            }
          case Constant.onBoardingScreenSignUpRouter:
            {
              return SlideFromRightPageRoute(
                widget: MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (context) => SignUpErrorInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => PasswordVisibilityInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => TermConditionInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => EmailUpdatesInfo(),
                    ),
                  ],
                  child: OnBoardingSignUpScreen(),
                ),
                routeSettings: routeSettings,
              );
            }
          case Constant.signUpScreenRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: MultiProvider(
                    providers: [
                      ChangeNotifierProvider(create: (context) => SignupPasswordHiddenInfo(),),
                      ChangeNotifierProvider(create: (context) => SignupConfirmPasswordHiddenInfo(),),
                      ChangeNotifierProvider(create: (context) => TonixSignUpErrorInfo(),)
                    ],
                    child: SignUpScreen(),
                  ),
                  routeSettings: routeSettings);
            }
          case Constant.signUpSecondStepHeadacheResultRouter:
            {
              return ScaleInPageRoute(
                  widget: SignUpSecondStepCompassResult(),
                  routeSettings: routeSettings);
            }
          case Constant.signUpOnBoardSecondStepPersonalizedHeadacheResultRouter:
            {
              return ScaleInPageRoute(
                  widget: SignUpOnBoardSecondStepPersonalizedHeadacheCompass(),
                  routeSettings: routeSettings);
            }
          case Constant.welcomeScreenRouter:
            {
              return SlideFromRightPageRoute(
                  widget: WelcomeScreen(), routeSettings: routeSettings);
            }
          case Constant.welcomeStartAssessmentScreenRouter:
            {
              return SlideFromRightPageRoute(
                widget: ChangeNotifierProvider(
                  create: (context) => WelcomeStartAssessmentInfo(),
                  child: WelcomeStartAssessmentScreen(),
                ),
                routeSettings: routeSettings,
              );
            }
          case Constant.onBoardHeadacheInfoScreenRouter:
            {
              return SlideFromRightPageRoute(
                  widget: OnBoardHeadacheInfoScreen(),
                  routeSettings: routeSettings);
            }
          case Constant.partOneOnBoardScreenTwoRouter:
            {
              return SlideFromRightPageRoute(
                  widget: PartOneOnBoardScreenTwo(),
                  routeSettings: routeSettings);
            }
          case Constant.onBoardCreateAccountScreenRouter:
            {
              return SlideFromRightPageRoute(
                  widget: OnBoardCreateAccount(), routeSettings: routeSettings);
            }
          case Constant.prePartTwoOnBoardScreenRouter:
            {
              return SlideFromRightPageRoute(
                  widget: PrePartTwoOnBoardScreen(),
                  routeSettings: routeSettings);
            }
          case Constant.onBoardHeadacheNameScreenRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: OnBoardHeadacheNameScreen(),
                  routeSettings: routeSettings);
            }
          case Constant.partTwoOnBoardMoveOnScreenRouter:
            {
              return SlideFromRightPageRoute(
                  widget: PartTwoOnBoardMoveOnScreen(),
                  routeSettings: routeSettings);
            }
          case Constant.prePartThreeOnBoardScreenRouter:
            {
              return SlideFromRightPageRoute(
                  widget: PrePartThreeOnBoardScreen(),
                  routeSettings: routeSettings);
            }
          case Constant.signUpOnBoardBubbleTextViewRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: SignUpOnBoardBubbleTextView(),
                  routeSettings: routeSettings);
            }
          case Constant.postPartThreeOnBoardRouter:
            {
              return SlideFromRightPageRoute(
                  widget: PostPartThreeOnBoardScreen(),
                  routeSettings: routeSettings);
            }
          case Constant.postNotificationOnBoardRouter:
            {
              return SlideFromRightPageRoute(
                  widget: PostNotificationOnBoardScreen(),
                  routeSettings: routeSettings);
            }
          case Constant.notificationScreenRouter:
            {
              return SlideFromRightPageRoute(
                  widget: NotificationScreen(), routeSettings: routeSettings);
            }
          case Constant.headacheStartedScreenRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: HeadacheStartedScreen(),
                  routeSettings: routeSettings);
            }
          case Constant.currentHeadacheProgressScreenRouter:
            {
              return SlideFromBottomPageRoute(
                widget: ChangeNotifierProvider(
                  create: (context) => CurrentHeadacheTimerInfo(),
                  child: CurrentHeadacheProgressScreen(
                      currentUserHeadacheModel: settings.arguments != null ? settings.arguments as CurrentUserHeadacheModel : null
                  ),
                ),
                routeSettings: routeSettings,
              );
            }
          case Constant.addHeadacheOnGoingScreenRouter:
            {
              final Widget widget = AddHeadacheOnGoingScreen(
                  currentUserHeadacheModel: settings.arguments != null ? settings.arguments as CurrentUserHeadacheModel : null
              );
              return SlideFromBottomPageRoute(
                widget: MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (context) => StartDateTimeInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => EndDateTimeInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => EndTimeExpandedInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => HeadacheTypeInfo(),
                    ),
                  ],
                  child: widget,
                ),
                routeSettings: routeSettings,
              );
            }

          case Constant.logDayScreenRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: LogDayScreen(
                      logDayScreenArgumentModel: settings.arguments != null ? settings.arguments as LogDayScreenArgumentModel : null),
                  routeSettings: routeSettings);
            }
          case Constant.addHeadacheSuccessScreenRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: AddHeadacheSuccessScreen(),
                  routeSettings: routeSettings);
            }
          case Constant.logDaySuccessScreenRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: LogDaySuccessScreen(), routeSettings: routeSettings);
            }
          case Constant.profileCompleteScreenRouter:
            {
              return SlideFromRightPageRoute(
                  widget: ProfileComplete(), routeSettings: routeSettings);
            }
          case Constant.calendarTriggersScreenRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: CalendarTriggersScreen(),
                  routeSettings: routeSettings);
            }
          case Constant.calendarSeverityScreenRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: CalendarIntensityScreen(),
                  routeSettings: routeSettings);
            }
          case Constant.calenderScreenRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: CalendarScreen(), routeSettings: routeSettings);
            }
          case Constant.onCalendarHeadacheLogDayDetailsScreenRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: CalendarHeadacheLogDayDetailsScreen(
                    dateTime: settings.arguments != null ? settings.arguments as DateTime : null,
                  ),
                  routeSettings: routeSettings);
            }

          case Constant.onBoardExitScreenRouter:
            {
              bool isUserAlreadyLoggedIn = settings.arguments as bool;
              return SlideFromLeftPageRoute(
                  widget: OnBoardExitScreen(
                      isAlreadyLoggedIn: (isUserAlreadyLoggedIn != null)
                          ? isUserAlreadyLoggedIn
                          : false),
                  routeSettings: routeSettings);
            }
          case Constant.compassScreenRouter:
            {
              return SlideFromBottomPageRoute(
                  widget: CompassScreen(), routeSettings: routeSettings);
            }
          case Constant.webViewScreenRouter:
            {
              return SlideFromRightPageRoute(
                  widget: WebViewScreen(
                    url: settings.arguments != null ? settings.arguments as String : null,
                  ),
                  routeSettings: routeSettings);
            }
          case Constant.otpValidationScreenRouter:
            {
              return SlideFromRightPageRoute(
                  widget: MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                        create: (context) => OTPTimerInfo(),
                      ),
                      ChangeNotifierProvider(
                        create: (context) => OTPErrorInfo(),
                      ),
                    ],
                    child: OtpValidationScreen(
                      otpValidationArgumentModel: settings.arguments != null ? settings.arguments as OTPValidationArgumentModel : null,
                    ),
                  ),
                  routeSettings: routeSettings);
            }
          case Constant.changePasswordScreenRouter:
            {
              return SlideFromRightPageRoute(
                widget: MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (context) => ChangePasswordVisibilityInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) =>
                          ChangeConfirmPasswordVisibilityInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => ChangePasswordErrorInfo(),
                    ),
                  ],
                  child: ChangePasswordScreen(
                    changePasswordArgumentModel: settings.arguments != null ? settings.arguments as ChangePasswordArgumentModel : null,
                  ),
                ),
                routeSettings: routeSettings,
              );
            }
          case TabNavigatorRoutes.pdfScreenRoute:
            {
              return SlideFromBottomPageRoute(
                  widget: PDFScreen(pdfScreenArgumentModel: settings.arguments != null ? settings.arguments as PDFScreenArgumentModel : null,),
                  routeSettings: routeSettings);
            }
/*          case TabNavigatorRoutes.moreHealthDescriptionScreenRoute:
            {
              return SlideFromRightPageRoute(
                  widget: MoreHealthDescriptionScreen(moreHealthDescriptionArgumentModel: settings.arguments as MoreHealthDescriptionArgumentModel,),
                  routeSettings: routeSettings);
            }*/
          case Constant.tonixAddHeadacheScreen:
            {
              final Widget widget = TonixAddHeadacheScreen(
                currentUserHeadacheModel: settings.arguments != null ? settings.arguments as CurrentUserHeadacheModel : null,
              );
              return SlideFromBottomPageRoute(
                widget: MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (context) => TonixStartDateTimeInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => TonixEndDateTimeInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => TonixEndTimeExpandedInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => TonixHeadacheTypeInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => TonixVisibilityHeadacheInfo(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => TonixAddHeadacheSectionSubTextInfo(),
                    ),
                  ],
                  child: widget,
                ),
                routeSettings: routeSettings,
              );
            }
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
