import 'dart:io';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health/health.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/models/DeviceTokenModel.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/LoginScreenRepository.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/MoreSection.dart';
import 'package:mobile/view/login_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'ChangePasswordScreen.dart';
import 'MoreSettingScreen.dart';

class MoreScreen extends StatefulWidget {
  final Function(BuildContext, String, dynamic) onPush;
  final Future<dynamic> Function(String, dynamic) navigateToOtherScreenCallback;
  final Function(String, dynamic) openActionSheetCallback;
  final Function(Stream, Function) showApiLoaderCallback;

  const MoreScreen(
      {Key? key,
      required this.onPush,
      required this.openActionSheetCallback,
      required this.navigateToOtherScreenCallback,
      required this.showApiLoaderCallback})
      : super(key: key);

  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _versionName = Constant.blankString;

  @override
  void initState() {
    super.initState();

    _updateVersionName();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 500), () {
        _checkNotificationStatus();
      });
    });
  }

  List<HealthDataType> appleHealthDataTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.WALKING_HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.ELECTRODERMAL_ACTIVITY,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.HEADACHE_MILD,
    HealthDataType.HEADACHE_MODERATE,
    HealthDataType.HEADACHE_SEVERE,
  ];

  List<HealthDataType> googleFitDataTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BODY_TEMPERATURE,
    //HealthDataType.MOVE_MINUTES,
  ];

  @override
  Widget build(BuildContext context) {
    debugPrint('More Screen build func');
    var appConfig = AppConfig.of(context);
    return Container(
      decoration: Constant.backgroundBoxDecoration,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Constant.moreBackgroundColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Visibility(
                      visible: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                      child: MoreSection(
                        currentTag: Constant.myProfile,
                        text: Constant.myProfile,
                        moreStatus: '',
                        isShowDivider: true,
                        navigateToOtherScreenCallback: _navigateToOtherScreen,
                      ),
                    ),
                    Visibility(
                      visible: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                      child: MoreSection(
                        currentTag: Constant.headacheTypes,
                        text: Constant.headacheTypes,
                        moreStatus: '',
                        isShowDivider: true,
                        navigateToOtherScreenCallback: _navigateToOtherScreen,
                      ),
                    ),
                    Visibility(
                      visible: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                      child: MoreSection(
                        currentTag: Constant.generateReport,
                        text: Constant.generateReport,
                        moreStatus: '',
                        isShowDivider: true,
                        navigateToOtherScreenCallback: _navigateToOtherScreen,
                      ),
                    ),
                    Visibility(
                      visible: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                      child: MoreSection(
                        currentTag: Constant.settings,
                        text: 'Settings',
                        moreStatus: '',
                        isShowDivider: true,
                        navigateToOtherScreenCallback: _navigateToOtherScreen,
                      ),
                    ),
                    Visibility(
                      visible: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                      child: MoreSection(
                        currentTag: Platform.isAndroid ? Constant.googleFit : Constant.appleHealth,
                        text: Platform.isAndroid ? Constant.googleFit : Constant.appleHealth,
                        moreStatus: Constant.blankString,
                        isShowDivider: true,
                        navigateToOtherScreenCallback: _navigateToOtherScreen,
                        healthDataTypeList: Platform.isAndroid ? googleFitDataTypes : appleHealthDataTypes,
                      ),
                    ),
                    Visibility(
                      visible: appConfig?.buildFlavor == Constant.tonixBuildFlavor,
                      child: Consumer<MoreSettingNotificationInfo>(
                        builder: (context, data, child) {
                          return MoreSection(
                            currentTag: Constant.notifications,
                            text: Constant.notifications,
                            moreStatus: data.getNotificationStatus(),
                            isShowDivider: true,
                            navigateToOtherScreenCallback: _navigateToOtherScreen,
                          );
                        },
                      ),
                    ),
                    Visibility(
                      visible: appConfig?.buildFlavor == Constant.tonixBuildFlavor,
                      child: MoreSection(
                        currentTag: Constant.changePassword,
                        text: Constant.changePassword,
                        moreStatus: Constant.blankString,
                        isShowDivider: true,
                        navigateToOtherScreenCallback: _navigateToOtherScreen,
                      ),
                    ),
                    MoreSection(
                      currentTag: Constant.support,
                      text: Constant.support,
                      moreStatus: '',
                      isShowDivider: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                      navigateToOtherScreenCallback: _navigateToOtherScreen,
                    ),
                    Visibility(
                      visible: appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor,
                      child: MoreSection(
                        currentTag: Constant.inviteFriends,
                        text: Constant.inviteFriends,
                        moreStatus: '',
                        isShowDivider: false,
                        navigateToOtherScreenCallback: _navigateToOtherScreen,
                      ),
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
                  BouncingWidget(
                    onPressed: () {
                      _logOutFromApp();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Constant.locationServiceGreen, width: 2)),
                      child: CustomTextWidget(
                        text: Constant.logOut,
                        style: TextStyle(
                          fontSize: 14,
                          color: Constant.locationServiceGreen,
                          fontFamily: Constant.jostMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: CustomTextWidget(
                    text: 'v$_versionName',
                    style: TextStyle(
                      color: Constant.locationServiceGreen,
                      fontFamily: Constant.jostRegular,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(),
              ),
              Visibility(
                visible: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BouncingWidget(
                      onPressed: () {
                        //_showDeleteLogOptionBottomSheet();
                        widget.openActionSheetCallback(
                            Constant.medicalHelpActionSheet, null);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Constant.chatBubbleGreen),
                        child: CustomTextWidget(
                          text: 'I need medical help',
                          style: TextStyle(
                            fontSize: 14,
                            color: Constant.bubbleChatTextView,
                            fontFamily: Constant.jostMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: false,
                child: SizedBox(
                  height: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToOtherScreen(String routeName, dynamic arguments) async {
    if(routeName == Constant.changePasswordScreenRouter) {
      UserProfileInfoModel userProfileInfoModel = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
      widget.navigateToOtherScreenCallback(routeName, ChangePasswordArgumentModel(
        emailValue: userProfileInfoModel.subjectId,
        isFromMoreSettings: true,
        isFromSignUp: false,
      ));
    } else {
      await widget.onPush(context, routeName, arguments);
      _checkNotificationStatus();
    }
  }

  ///This method is used to log out from the app and redirecting to the welcome start assessment screen
  void _logOutFromApp() async {
    var result = await Utils.showConfirmationDialog(
        context, 'Are you sure want to log out?', Constant.logoutConfirmation, 'No', 'Yes');
    if (result == 'Yes') {
      FirebaseMessaging _fcm = FirebaseMessaging.instance;
      var deviceToken = await _fcm.getToken();
      UserProfileInfoModel userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
      deleteDeviceTokenOfTheUser(deviceToken!, userProfileInfoData.userId!, context);
      await Utils.clearAllDataFromDatabaseAndCache();
      await Utils.setAnalyticsUserId(Constant.blankString, context);
      await FirebaseCrashlytics.instance.setUserIdentifier(Constant.blankString);
      var appConfig = AppConfig.of(context);

      if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
        widget.navigateToOtherScreenCallback(
            Constant.welcomeStartAssessmentScreenRouter, null);
      else
        widget.navigateToOtherScreenCallback(Constant.loginScreenRouter,
            LoginScreenArgumentModel(
                isFromSignUp: false, isFromMore: true));
    }
  }
  /// this method will be use for to delete Device Token from server.
  void deleteDeviceTokenOfTheUser(String deviceToken, String userId, BuildContext context) async{
    try {
      int tokenType;
      LoginScreenRepository _loginScreenRepository = LoginScreenRepository();
      String url = '${WebservicePost.getServerUrl(context)}notification/push';
      if(Platform.isAndroid){
        tokenType = 1;
      }else{
        tokenType = 2;
      }
      DeviceTokenModel deviceTokenModel = DeviceTokenModel();
      deviceTokenModel.userId = int.tryParse(userId);
      deviceTokenModel.devicetoken = deviceToken;
      deviceTokenModel.tokenType = tokenType;
      deviceTokenModel.action = 'delete';
      var response =
      await _loginScreenRepository.createAndDeletePushNotificationServiceCall(url, RequestMethod.POST,deviceTokenModelToJson(deviceTokenModel));
      debugPrint(response.toString());
    } catch (e) {}
  }

  void _updateVersionName() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _versionName = packageInfo.version;
    });
  }

  void _checkNotificationStatus() async {
    var notificationListData =
    await SignUpOnBoardProviders.db.getAllLocalNotificationsData();

    var moreSettingNotificationInfo = Provider.of<MoreSettingNotificationInfo>(context, listen: false);


    if (Platform.isIOS) {
      var permissionResult = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (permissionResult ?? false) {
        moreSettingNotificationInfo.updateMoreSettingNotificationInfo(Constant.allowed);
      } else {
        moreSettingNotificationInfo.updateMoreSettingNotificationInfo(Constant.notAllowed);
      }
    } else {
      if (notificationListData == null || notificationListData.isEmpty) {
        moreSettingNotificationInfo.updateMoreSettingNotificationInfo(Constant.notAllowed);
      } else {
        moreSettingNotificationInfo.updateMoreSettingNotificationInfo(Constant.allowed);
      }
    }
  }
}
