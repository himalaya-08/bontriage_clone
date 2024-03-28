import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/models/LocalNotificationModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextFormFieldWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/NotificationSection.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  bool _locationServicesSwitchState = false;
  StreamController<dynamic> _localNotificationStreamController = StreamController();

  StreamSink<dynamic> get localNotificationDataSink =>
      _localNotificationStreamController.sink;

  Stream<dynamic> get localNotificationDataStream =>
      _localNotificationStreamController.stream;

  var isAddedCustomNotification = false;

  TextEditingController textEditingController = TextEditingController();

  String customNotificationValue = "";

  bool isCustomTimerLayoutOpen = false;
  List<LocalNotificationModel> allNotificationListData = [];
  bool isSaveButtonVisible = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    _localNotificationStreamController = StreamController<dynamic>.broadcast();
    textEditingController = TextEditingController();
    Utils.saveUserProgress(0, Constant.notificationEventStep);
    //getNotificationListData();
  }

  @override
  void dispose() {
    _localNotificationStreamController.close();
    super.dispose();

  }

  Future<bool> _onBackPressed() async{
    Utils.navigateToExitScreen(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var appConfig = AppConfig.of(context);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Constant.backgroundColor,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(0, 20, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Utils.navigateToExitScreen(context);
                        },
                        child: Image(
                          image: AssetImage(Constant.closeIcon),
                          width: 26,
                          height: 26,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CustomTextWidget(
                      text: Constant.notifications,
                      style: TextStyle(
                          color: Constant.locationServiceGreen,
                          fontSize: 16,
                          fontFamily: Constant.jostMedium),
                    ),
                    Switch(
                      value: _locationServicesSwitchState,
                      onChanged: (bool state) {
                        setState(() {
                          _locationServicesSwitchState = state;
                          if(state){
                             isSaveButtonVisible = true;
                          }else{
                             isSaveButtonVisible = false;
                             //localNotificationDataSink.add('CancelAll');
                             //SignUpOnBoardProviders.db.deleteAllNotificationFromDatabase();
                             //allNotificationListData = [];
                             isAddedCustomNotification = false;
                             textEditingController.text = '';
                          }
                          print(state);
                        });
                      },
                      activeColor: Constant.chatBubbleGreen,
                      inactiveThumbColor: Constant.chatBubbleGreen,
                      inactiveTrackColor: Constant.chatBubbleGreenBlue,
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Visibility(
                  visible: _locationServicesSwitchState,
                  child: Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          NotificationSection(
                            notificationId: 0,
                            notificationName: 'Daily Log',
                            allNotificationListData: allNotificationListData,
                            localNotificationDataStream: localNotificationDataStream,
                            appConfig: appConfig!,
                          ),
                          SizedBox(height: 5),
                          NotificationSection(
                            notificationId: 1,
                            allNotificationListData: allNotificationListData,
                            notificationName: 'Medication',
                            localNotificationDataStream: localNotificationDataStream,
                            appConfig: appConfig,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          NotificationSection(
                            notificationId: 2,
                            notificationName: 'Exercise',
                            allNotificationListData: allNotificationListData,
                            localNotificationDataStream: localNotificationDataStream,
                            appConfig: appConfig,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Visibility(
                            visible: !isAddedCustomNotification,
                            child: GestureDetector(
                              onTap: () {
                                openCustomNotificationDialog(
                                    context, allNotificationListData);
                              },
                              child: CustomTextWidget(
                                text: Constant.addCustomNotification,
                                style: TextStyle(
                                    color:
                                        Constant.addCustomNotificationTextColor,
                                    fontSize: 16,
                                    fontFamily: Constant.jostRegular),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isAddedCustomNotification,
                            child: NotificationSection(
                              notificationId: 3,
                              customNotification: (){
                                openCustomNotificationDialog(context, allNotificationListData);
                              },
                              allNotificationListData: allNotificationListData,
                              notificationName: customNotificationValue,
                              isNotificationTimerOpen: isAddedCustomNotification,
                              localNotificationDataStream: localNotificationDataStream,
                              appConfig: appConfig,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Visibility(
                            visible: isSaveButtonVisible,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: GestureDetector(
                                onTap: () {
                                  _requestPermissionForNotification();
                                //  Utils.showValidationErrorDialog(context,'Your notification has been saved successfully.','Alert!');
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 13),
                                  decoration: BoxDecoration(
                                    color: Color(0xffafd794),
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
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(context,
                                    Constant.postNotificationOnBoardRouter);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 13),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                      width: 1,
                                      color: Constant.chatBubbleGreen),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: CustomTextWidget(
                                    text: 'Skip',
                                    style: TextStyle(
                                      color: Constant.chatBubbleGreen,
                                      fontSize: 15,
                                      fontFamily: Constant.jostMedium,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openCustomNotificationDialog(BuildContext context,
      List<LocalNotificationModel> allNotificationListData) {
    showDialog<void>(
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
                                  setState(() {
                                    if(textEditingController.text == ''){
                                      isAddedCustomNotification = false;
                                    }else {
                                      isAddedCustomNotification = true;
                                    }
                                  });
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
                            inputFormatters: [LengthLimitingTextInputFormatter(20, maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds),],
                            onEditingComplete: () {},
                            onFieldSubmitted: (String value) {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            controller: textEditingController,
                            onChanged: (String value) {
                              customNotificationValue =
                                  textEditingController.text;
                              //print(value);
                            },
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
                              setState(() {
                                isAddedCustomNotification = true;
                               /* allNotificationListData.clear();
                                LocalNotificationModel localNotificationModel =
                                    LocalNotificationModel();
                                localNotificationModel.isCustomNotificationAdded = true;
                                localNotificationModel.notificationName =
                                    customNotificationValue;

                                localNotificationModel.notificationTime =
                                    _selectedDateTime.toIso8601String();
                                allNotificationListData
                                    .add(localNotificationModel);*/
                                setNotificationName( textEditingController.text);
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Color(0xffafd794),
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
  }

 /* void openTimerLayout() {
    setState(() {
      if (isCustomTimerLayoutOpen) {
        isCustomTimerLayoutOpen = false;
      } else {
        isCustomTimerLayoutOpen = true;
      }
    });
  }*/

  /// this Method will be use for to get all notification data from the DB. If user has set any Local notifications from
  /// this screen.
 /* void getNotificationListData() async {
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
        setState(() {
          _locationServicesSwitchState = true;
          isSaveButtonVisible = true;
        });
      }
    }else{
      var notificationListData =  await SignUpOnBoardProviders.db.getAllLocalNotificationsData();
      if (notificationListData != null) {
        setState(() {
          _locationServicesSwitchState = true;
          isSaveButtonVisible = true;
          allNotificationListData = notificationListData;
        });
      }
    }

  }*/
  setNotificationName(String notificationName) {
    LocalNotificationModel? localNotificationNameModel = allNotificationListData
        .firstWhereOrNull(
            (element) => element.isCustomNotificationAdded);
    if (localNotificationNameModel != null) {
      localNotificationNameModel.notificationName = notificationName;
      customNotificationValue =  notificationName;
    }else{
      customNotificationValue = notificationName;
    }
  }
  void _requestPermissionForNotification() async{
    if(Platform.isIOS){
      var permissionResult  = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      if(permissionResult ?? false) {
        localNotificationDataSink.add('Clicked');
        Future.delayed(Duration(milliseconds: 500), () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString(Constant.isNotificationInitiallyAdded, Constant.trueString);

          SignUpOnBoardProviders.db.insertUserNotifications(allNotificationListData);
        });
        Navigator.pushReplacementNamed(context,
            Constant.postNotificationOnBoardRouter);
      }else{
        var result = await Utils.showConfirmationDialog(context, 'You haven\'t allowed notifications permissions to MigraineMentor. If you want to show notifications, please grant permissions.', 'Permission Required', 'Not now', 'Allow');
        if(result == 'Yes') {
          Geolocator.openAppSettings();
        }
      }
    } else {
      localNotificationDataSink.add('Clicked');
      Future.delayed(Duration(milliseconds: 500), () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(Constant.isNotificationInitiallyAdded, Constant.trueString);

        SignUpOnBoardProviders.db.insertUserNotifications(allNotificationListData);
      });
      Navigator.pushReplacementNamed(context, Constant.postNotificationOnBoardRouter);
    }

  }
}


