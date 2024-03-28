import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:health/health.dart';
import 'package:mobile/blocs/MoreLocationServicesBloc.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/ChangePasswordScreen.dart';
import 'package:mobile/view/MoreSection.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/MoreLocationSevicesArgumentModel.dart';
import '../util/TabNavigatorRoutes.dart';
import 'package:collection/collection.dart';

class MoreSettingScreen extends StatefulWidget {
  final Future<dynamic> Function(BuildContext, String, dynamic) onPush;
  final Future<dynamic> Function(String, dynamic) navigateToOtherScreenCallback;
  final Function(Stream, Function) showApiLoaderCallback;

  const MoreSettingScreen({
    Key? key,
    required this.onPush,
    required this.showApiLoaderCallback,
    required this.navigateToOtherScreenCallback,}) : super(key: key);

  @override
  _MoreSettingScreenState createState() => _MoreSettingScreenState();
}

class _MoreSettingScreenState extends State<MoreSettingScreen> {
  //String _locationStatus = Constant.notAllowed;

  late MoreLocationServicesBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = MoreLocationServicesBloc();

    _checkNotificationStatus();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      widget.showApiLoaderCallback(
          _bloc.stream, () {
        _bloc.enterDummyDataToStreamController();
        _bloc.fetchMyProfileData(context);
      });

      _bloc.fetchMyProfileData(context);

      addListenerToStream();
    });
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Constant.backgroundBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Constant.moreBackgroundColor,
                      ),
                      child: Row(
                        children: [
                          Image(
                            width: 16,
                            height: 16,
                            image: AssetImage(Constant.leftArrow),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          CustomTextWidget(
                            text: Constant.more,
                            style: TextStyle(
                                color: Constant.locationServiceGreen,
                                fontSize: 16,
                                fontFamily: Constant.jostRegular),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<MoreSettingNotificationInfo>(
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
                        Consumer<MoreSettingLocationInfo>(
                          builder: (context, data, child) {
                            return MoreSection(
                              currentTag: Constant.locationServices,
                              text: Constant.locationServices,
                              moreStatus: data.getLocationStatus(),
                              isShowDivider: true,
                              navigateToOtherScreenCallback: _navigateToOtherScreen,
                            );
                          },
                        ),
                        MoreSection(
                          currentTag: Constant.changePassword,
                          text: Constant.changePassword,
                          moreStatus: Constant.blankString,
                          isShowDivider: true,
                          navigateToOtherScreenCallback: _navigateToOtherScreen,
                        ),
                        MoreSection(
                          currentTag: Constant.voiceSelection,
                          text: Constant.selectTextToSpeechAccent,
                          moreStatus: Constant.blankString,
                          isShowDivider: false,
                          navigateToOtherScreenCallback: _navigateToOtherScreen,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToOtherScreen(String routeName, dynamic arguments) async {
    if(routeName == Constant.changePasswordScreenRouter) {
      UserProfileInfoModel userProfileInfoModel = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
      widget.navigateToOtherScreenCallback(routeName, ChangePasswordArgumentModel(
        emailValue: userProfileInfoModel.email,
        isFromMoreSettings: true,
        isFromSignUp: false,
      ));
    } else if (routeName == TabNavigatorRoutes.moreLocationServicesScreenRoute) {
      await widget.onPush(context, routeName, MoreLocationServicesArgumentModel(profileId: _bloc.profileId ?? -1, profileSelectedAnswerList: _bloc.profileSelectedAnswerList));
      _checkNotificationStatus();
    } else if (routeName == TabNavigatorRoutes.moreVoiceSelectionScreenRoute) {
      await widget.onPush(context, routeName, MoreLocationServicesArgumentModel(profileId: _bloc.profileId ?? -1, profileSelectedAnswerList: _bloc.profileSelectedAnswerList));
    } else {
      await widget.onPush(context, routeName, arguments);
      _checkNotificationStatus();
    }
  }

  void _checkNotificationStatus() async {
    var notificationListData =
        await SignUpOnBoardProviders.db.getAllLocalNotificationsData();

    var moreSettingNotificationInfo = Provider.of<MoreSettingNotificationInfo>(context, listen: false);

    bool isLocationAllowed = await Utils.checkLocationPermission();

    if(isLocationAllowed) {
      bool locationSwitchState = await Utils.getLocationSwitchState();

      var moreSettingLocationInfo = Provider.of<MoreSettingLocationInfo>(context, listen: false);

      String locationStatus;

      if(locationSwitchState) {
        SelectedAnswers? locationSelectedAnswer = _bloc.profileSelectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.profileLocationTag);
        if (locationSelectedAnswer != null) {
          if (locationSelectedAnswer.answer != null && (locationSelectedAnswer.answer?.isNotEmpty == true)) {
            locationStatus = Constant.allowed;
          } else {
            locationStatus = Constant.notAllowed;
          }
        } else {
          locationStatus = Constant.notAllowed;
        }
      } else
        locationStatus = Constant.notAllowed;

      moreSettingLocationInfo.updateMoreSettingLocationInfo(locationStatus);
    } else {
      Utils.changeLocationSwitchState(false);
    }


    if (Platform.isIOS) {
      var permissionResult = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      /*if (permissionResult ?? false) {
        moreSettingNotificationInfo.updateMoreSettingNotificationInfo(Constant.allowed);
      } else {
        moreSettingNotificationInfo.updateMoreSettingNotificationInfo(Constant.notAllowed);
      }*/
      if (notificationListData == null || notificationListData.isEmpty) {
        moreSettingNotificationInfo.updateMoreSettingNotificationInfo(Constant.notAllowed);
      } else {
        moreSettingNotificationInfo.updateMoreSettingNotificationInfo(Constant.allowed);
      }
    } else {
      if (notificationListData == null || notificationListData.isEmpty) {
        moreSettingNotificationInfo.updateMoreSettingNotificationInfo(Constant.notAllowed);
      } else {
        moreSettingNotificationInfo.updateMoreSettingNotificationInfo(Constant.allowed);
      }
    }
  }

  void addListenerToStream() {
    _bloc.stream.listen((event) {
      if (event is String && event == Constant.success) {
        _checkNotificationStatus();
      }
    });
  }
}

class MoreSettingNotificationInfo with ChangeNotifier {
  String _notificationStatus = Constant.notAllowed;
  String getNotificationStatus() => _notificationStatus;

  updateMoreSettingNotificationInfo(String notificationStatus) {
    _notificationStatus = notificationStatus;
    notifyListeners();
  }
}

class MoreSettingLocationInfo with ChangeNotifier {
  String _locationStatus = Constant.notAllowed;
  String getLocationStatus() => _locationStatus;

  updateMoreSettingLocationInfo(String locationStatus) {
    _locationStatus = locationStatus;
    notifyListeners();
  }
}
