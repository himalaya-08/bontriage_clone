import 'dart:async';
import 'dart:io';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/models/LocalNotificationModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextFormFieldWidget.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'CustomTextWidget.dart';
import 'NotificationSection.dart';

class MoreNotificationScreen extends StatefulWidget {
  final Future<dynamic> Function(String, dynamic) openActionSheetCallback;

  const MoreNotificationScreen(
      {Key? key, required this.openActionSheetCallback})
      : super(key: key);

  @override
  _MoreNotificationScreenState createState() => _MoreNotificationScreenState();
}

class _MoreNotificationScreenState extends State<MoreNotificationScreen>
    with SingleTickerProviderStateMixin {
  String dailyLogStatus = 'Daily, 8:00 PM';
  String medicationStatus = 'Daily, 2:30 PM';
  String exerciseStatus = 'Off';

  late AnimationController _animationController;

  List<LocalNotificationModel> allNotificationListData = [];

  List<LocalNotificationModel> lastAllNotificationListData = [];
  bool lastToggleSwitchData = false;

  StreamController<dynamic> _localNotificationStreamController =
      StreamController();

  //bool isSaveButtonVisible = false;

  bool _isClickedOnSaveAndExit = false;

  bool _isButtonClicked = false;

  Stream<dynamic> get localNotificationDataStream =>
      _localNotificationStreamController.stream;
  late TextEditingController textEditingController;

  StreamSink<dynamic> get localNotificationDataSink =>
      _localNotificationStreamController.sink;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    _localNotificationStreamController = StreamController<dynamic>.broadcast();
    _animationController = AnimationController(
        duration: Duration(milliseconds: 350),
        reverseDuration: Duration(milliseconds: 350),
        vsync: this);
    getNotificationListData();
  }

  @override
  void dispose() {
    _localNotificationStreamController.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appConfig = AppConfig.of(context);
    return WillPopScope(
      onWillPop: () async {
        _openSaveAndExitActionSheet();
        return false;
      },
      child: Container(
        decoration: Constant.backgroundBoxDecoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        //Navigator.of(context).pop();
                        _openSaveAndExitActionSheet();
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
                              width: 20,
                              height: 20,
                              image: AssetImage(Constant.leftArrow),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CustomTextWidget(
                              text: 'Settings',
                              style: TextStyle(
                                  color: Constant.locationServiceGreen,
                                  fontSize: 16,
                                  fontFamily: Constant.jostMedium),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Constant.moreBackgroundColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15, top: 15, bottom: 15),
                            child: CustomTextWidget(
                              text: Constant.notifications,
                              style: TextStyle(
                                  color: Constant.locationServiceGreen,
                                  fontSize: 16,
                                  fontFamily: Constant.jostMedium),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Consumer<MoreNotificationSwitchInfo>(
                              builder: (_, data, child) {
                                return Switch(
                                  value: data.getNotificationSwitchState(),
                                  onChanged: (state) {
                                    if (state) {
                                      _animationController.forward();
                                      //isSaveButtonVisible = true;
                                    } else {
                                      //localNotificationDataSink.add('CancelAll');
                                      //allNotificationListData = [];

                                      if (appConfig?.buildFlavor ==
                                          Constant.tonixBuildFlavor) {
                                        var moreNotificationInfo =
                                            Provider.of<MoreNotificationInfo>(
                                                context,
                                                listen: false);
                                        moreNotificationInfo
                                            .updateIsAlreadyAddedCustomNotification(
                                                false);
                                      }
                                      /*var moreNotificationInfo = Provider.of<MoreNotificationInfo>(context, listen: false);
                                      moreNotificationInfo.updateIsAlreadyAddedCustomNotification(false);*/
                                      textEditingController.text = '';
                                      _animationController.reverse();
                                      //isSaveButtonVisible = false;
                                    }
                                    data.updateNotificationSwitchState(
                                        state, true);
                                  },
                                  activeColor: Constant.chatBubbleGreen,
                                  inactiveThumbColor: Constant.chatBubbleGreen,
                                  inactiveTrackColor:
                                      Constant.chatBubbleGreenBlue,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    SizeTransition(
                      sizeFactor: _animationController,
                      child: FadeTransition(
                        opacity: _animationController,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Constant.moreBackgroundColor,
                              ),
                              child: Consumer2<MoreNotificationSwitchInfo,
                                  MoreNotificationInfo>(
                                builder: (_, switchData, moreNotificationData,
                                    child) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      NotificationSection(
                                        notificationId: 0,
                                        notificationName:
                                            Constant.dailyLogNotificationTitle,
                                        localNotificationDataStream:
                                            localNotificationDataStream,
                                        allNotificationListData:
                                            allNotificationListData,
                                        isShowBorder: true,
                                        appConfig: appConfig!,
                                      ),
                                      SizedBox(height: 5),
                                      NotificationSection(
                                        notificationId: 1,
                                        localNotificationDataStream:
                                            localNotificationDataStream,
                                        allNotificationListData:
                                            allNotificationListData,
                                        notificationName: appConfig.buildFlavor ==
                                                Constant
                                                    .migraineMentorBuildFlavor
                                            ? Constant
                                                .medicationNotificationTitle
                                            : Constant
                                                .amStudyMedicationNotification,
                                        isShowBorder: true,
                                        appConfig: appConfig,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      NotificationSection(
                                        notificationId: 2,
                                        notificationName: appConfig
                                                    .buildFlavor ==
                                                Constant
                                                    .migraineMentorBuildFlavor
                                            ? Constant.exerciseNotificationTitle
                                            : Constant
                                                .pmStudyMedicationNotification,
                                        localNotificationDataStream:
                                            localNotificationDataStream,
                                        allNotificationListData:
                                            allNotificationListData,
                                        isShowBorder: appConfig.buildFlavor ==
                                            Constant.migraineMentorBuildFlavor,
                                        appConfig: appConfig,
                                      ),
                                      Visibility(
                                        visible: appConfig.buildFlavor ==
                                                Constant
                                                    .migraineMentorBuildFlavor
                                            ? moreNotificationData
                                                    .isAlreadyAddedCustomNotification() ??
                                                false
                                            : false,
                                        child: NotificationSection(
                                          customNotification: () {
                                            openCustomNotificationDialog(
                                                context,
                                                allNotificationListData);
                                          },
                                          notificationId: 3,
                                          allNotificationListData:
                                              allNotificationListData,
                                          notificationName: moreNotificationData
                                              .getCustomNotificationValue(),
                                          isNotificationTimerOpen: false,
                                          localNotificationDataStream:
                                              localNotificationDataStream,
                                          isShowBorder: true,
                                          appConfig: appConfig,
                                        ),
                                      ),
                                      Visibility(
                                        visible: appConfig.buildFlavor ==
                                                Constant
                                                    .migraineMentorBuildFlavor
                                            ? !moreNotificationData
                                                .isAlreadyAddedCustomNotification()
                                            : false,
                                        child: GestureDetector(
                                          onTap: () {
                                            openCustomNotificationDialog(
                                                context,
                                                allNotificationListData);
                                          },
                                          child: Container(
                                            child: CustomTextWidget(
                                              text: Constant
                                                  .addCustomNotification,
                                              style: TextStyle(
                                                  color: Constant
                                                      .addCustomNotificationTextColor,
                                                  fontSize: 16,
                                                  fontFamily:
                                                      Constant.jostMedium),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: GestureDetector(
                                onTap: () {
                                  _isClickedOnSaveAndExit = true;

                                  if (!_isButtonClicked) {
                                    _isButtonClicked = true;
                                    requestPermissionForNotification();
                                  }

                                  // Utils.showValidationErrorDialog(context,'Your notification has been saved successfully.','Alert!');
                                  //saveAllNotification();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 13),
                                  decoration: BoxDecoration(
                                    color: Color(0xffafd794),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Text(
                                      Constant.save,
                                      style: TextStyle(
                                          color: Constant.bubbleChatTextView,
                                          fontSize: 15,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Visibility(
                              visible: appConfig?.buildFlavor ==
                                  Constant.migraineMentorBuildFlavor,
                              child: Consumer<MoreNotificationSwitchInfo>(
                                builder: (_, data, child) {
                                  return Visibility(
                                    visible: data.getNotificationSwitchState(),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: CustomTextWidget(
                                        text: Constant.weKnowItCanBeEasy,
                                        style: TextStyle(
                                            color:
                                                Constant.locationServiceGreen,
                                            fontSize: 14,
                                            fontFamily: Constant.jostMedium),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void openCustomNotificationDialog(BuildContext context,
      List<LocalNotificationModel> allNotificationListData) async {
    textEditingController.text = setInitialValue();
    var result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          content: WillPopScope(
            onWillPop: () async => false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Constant.backgroundTransparentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Image(
                                  image: AssetImage(Constant.closeIcon),
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: CustomTextFormFieldWidget(
                            maxLength: 20,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(20,
                                  maxLengthEnforcement: MaxLengthEnforcement
                                      .truncateAfterCompositionEnds),
                            ],
                            onFieldSubmitted: (String value) {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            controller: textEditingController,
                            style: TextStyle(
                                color: Constant.chatBubbleGreen,
                                fontSize: 15,
                                fontFamily: Constant.jostMedium),
                            cursorColor: Constant.chatBubbleGreen,
                            decoration: InputDecoration(
                              hintText: 'Tap to Title notification',
                              hintStyle: TextStyle(
                                  color: Color.fromARGB(50, 175, 215, 148),
                                  fontSize: 15,
                                  fontFamily: Constant.jostMedium),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Constant.chatBubbleGreen)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Constant.chatBubbleGreen)),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 0),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 80),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(
                                  context, textEditingController.text.trim());
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Constant.chatBubbleGreen,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: CustomTextWidget(
                                  text: Constant.save,
                                  style: TextStyle(
                                      color: Constant.bubbleChatTextView,
                                      fontSize: 15,
                                      fontFamily: Constant.jostMedium),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Visibility(
                          visible: false,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 80),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: CustomTextWidget(
                                    text: 'Delete',
                                    style: TextStyle(
                                        color: Constant.chatBubbleGreen,
                                        fontSize: 15,
                                        fontFamily: Constant.jostMedium),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && result is String) {
      var moreNotificationInfo =
          Provider.of<MoreNotificationInfo>(context, listen: false);
      if (result == Constant.blankString) {
        moreNotificationInfo.updateIsAlreadyAddedCustomNotification(false);
      } else {
        moreNotificationInfo.updateIsAlreadyAddedCustomNotification(true);
      }
      setNotificationName(result);
    }
  }

  /// this Method will be use for to get all notification data from the DB. If user has set any Local notifications from
  /// this screen.
  void getNotificationListData() async {
    var notificationListData =
        await SignUpOnBoardProviders.db.getAllLocalNotificationsData();
    var moreNotificationInfo =
        Provider.of<MoreNotificationSwitchInfo>(context, listen: false);
    if (notificationListData != null && notificationListData.length > 0) {
      var customNotificationData = notificationListData
          .firstWhereOrNull((element) => element.isCustomNotificationAdded);
      if (customNotificationData != null) {
        var moreNotificationSwitchInfo =
            Provider.of<MoreNotificationInfo>(context, listen: false);
        moreNotificationSwitchInfo.updateIsAlreadyAddedCustomNotification(true);
      }
      //isSaveButtonVisible = true;
      var moreNotificationSwitchInfo =
          Provider.of<MoreNotificationSwitchInfo>(context, listen: false);
      lastAllNotificationListData = notificationListData;
      lastToggleSwitchData = moreNotificationInfo.getNotificationSwitchState();
      allNotificationListData = notificationListData;
      lastToggleSwitchData = moreNotificationInfo.getNotificationSwitchState();
      moreNotificationSwitchInfo.updateNotificationSwitchState(true, true);
      _animationController.forward();
    }
  }

  setNotificationName(String notificationName) {
    LocalNotificationModel? localNotificationNameModel = allNotificationListData
        .firstWhereOrNull((element) => element.isCustomNotificationAdded);
    var moreNotificationInfo =
        Provider.of<MoreNotificationInfo>(context, listen: false);
    if (localNotificationNameModel != null) {
      localNotificationNameModel.notificationName = notificationName;
      moreNotificationInfo.updateCustomNotificationValue(notificationName);
    } else {
      moreNotificationInfo.updateCustomNotificationValue(notificationName);
    }
    moreNotificationInfo.notify();
  }

  /// This Method will be use for to set initial value of custom notification edit text.
  String setInitialValue() {
    LocalNotificationModel? localNotificationNameModel = allNotificationListData
        .firstWhereOrNull((element) => element.isCustomNotificationAdded);
    if (localNotificationNameModel != null) {
      return localNotificationNameModel.notificationName ?? '';
    } else
      return textEditingController.text;
  }

  void requestPermissionForNotification() async {
    var appConfig = AppConfig.of(context);
    var moreNotificationInfo =
        Provider.of<MoreNotificationSwitchInfo>(context, listen: false);

    if (!moreNotificationInfo.getNotificationSwitchState()) {
      allNotificationListData = [];
      localNotificationDataSink.add('CancelAll');
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

      if (permissionResult ?? false) {
        localNotificationDataSink.add('Clicked');
        Future.delayed(Duration(milliseconds: 500), () async {
          await SignUpOnBoardProviders.db
              .insertUserNotifications(allNotificationListData);
          if (_isClickedOnSaveAndExit) {
            Navigator.pop(context);
            Future.delayed(Duration(milliseconds: 500), () {
              Navigator.pop(context);
              Future.delayed(Duration(milliseconds: 500), () {
                _isButtonClicked = false;
              });
            });
          }
        });
        /*final snackBar = SnackBar(content: CustomTextWidget(text: 'Your notification has been saved successfully.',style: TextStyle(
           height: 1.3,
           fontSize: 16,
           fontFamily: Constant.jostRegular,
           color: Colors.black)),backgroundColor: Constant.chatBubbleGreen,);
       ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
      } else {
        _isClickedOnSaveAndExit = false;
        var result = await Utils.showConfirmationDialog(
            context,
            'You haven\'t allowed notifications permissions to ${appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor ? 'MigraineMentor' : 'BonTriage'}. If you want to show notifications, please grant permissions.',
            'Permission Required',
            'Not now',
            'Allow');
        if (result == 'Yes') {
          Geolocator.openAppSettings();
        }
      }
    } else {
      localNotificationDataSink.add('Clicked');
      Future.delayed(Duration(milliseconds: 500), () async {
        await SignUpOnBoardProviders.db
            .insertUserNotifications(allNotificationListData);
        if (_isClickedOnSaveAndExit) {
          Navigator.pop(context);
          Future.delayed(Duration(milliseconds: 500), () {
            _isButtonClicked = false;
          });
        }
      });
      /*final snackBar = SnackBar(content: CustomTextWidget(text: 'Your notification has been saved successfully.', style: TextStyle(
         height: 1.3,
         fontSize: 16,
         fontFamily: Constant.jostRegular,
         color: Colors.black)),backgroundColor: Constant.chatBubbleGreen,);
     ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
    }
  }

  Future<void> _openSaveAndExitActionSheet() async {
    var result = await widget.openActionSheetCallback(
        Constant.saveAndExitActionSheet, null);
    if (result != null) {
      if (result == Constant.saveAndExit) {
        _isClickedOnSaveAndExit = true;
        requestPermissionForNotification();
      } else {
        Navigator.pop(context);
      }
    }
  }
}

class MoreNotificationSwitchInfo with ChangeNotifier {
  bool _notificationSwitchState = false;

  bool getNotificationSwitchState() => _notificationSwitchState;

  updateNotificationSwitchState(
      bool notificationSwitchState, bool shouldNotify) {
    _notificationSwitchState = notificationSwitchState;

    if (shouldNotify) notifyListeners();
  }
}

class MoreNotificationInfo with ChangeNotifier {
  bool _isAlreadyAddedCustomNotification = false;
  String _customNotificationValue = Constant.blankString;

  bool isAlreadyAddedCustomNotification() => _isAlreadyAddedCustomNotification;

  String getCustomNotificationValue() => _customNotificationValue;

  updateIsAlreadyAddedCustomNotification(
      bool isAlreadyAddedCustomNotification) {
    _isAlreadyAddedCustomNotification = isAlreadyAddedCustomNotification;
  }

  updateCustomNotificationValue(String customNotificationValue) {
    _customNotificationValue = customNotificationValue;
  }

  notify() {
    notifyListeners();
  }
}
