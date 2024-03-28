import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/models/LocalNotificationModel.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:timezone/timezone.dart' as tz;

import '../main.dart';

class NotificationSection extends StatefulWidget {
  final String notificationName;
  final int notificationId;
  final Stream localNotificationDataStream;
  final List<LocalNotificationModel> allNotificationListData;
  final bool? isNotificationTimerOpen;
  final Function? customNotification;
  final bool isShowBorder;
  final AppConfig appConfig;

  const NotificationSection({Key? key,
    required this.notificationName,
    required this.notificationId,
    required this.localNotificationDataStream,
    this.customNotification,
    required this.allNotificationListData,
    this.isNotificationTimerOpen,
    this.isShowBorder = true,
    required this.appConfig,}) : super(key: key);

  @override
  _NotificationSectionState createState() => _NotificationSectionState();
}

class _NotificationSectionState extends State<NotificationSection>
    with TickerProviderStateMixin {
  bool isDailyLogTimerLayoutOpen = false;
  bool isMedicationTimerLayoutOpen = false;
  bool isExerciseTimerLayoutOpen = false;
  bool isCustomTimerLayoutOpen = false;
  String selectedTimerValue = "";
  LocalNotificationModel? localNotificationNameModel;

  bool isDailySelected = false;
  bool isWeekDaysSelected = false;
  bool isOffSelected = true;

  DateTime _dateTime = DateTime.now();
  int _selectedHour = 0;
  int _selectedMinute = 0;
  String? whichButtonSelected;

  String dailyNotificationLogTime = "Off";

  String medicationNotificationLogTime = "Off";

  String exerciseNotificationLogTime = "Off";

  String customNotificationLogTime = "Off";

  String customNotificationValue = '';


  //String customNotificationName = 'Custom';

  DateTime? dailyCurrentTimeValue;
  DateTime? medicationCurrentTimeValue;
  DateTime? exerciseCurrentTimeValue;


  @override
  void initState() {
    super.initState();

    var appConfig = widget.appConfig;
    _dateTime = DateTime.now();
    _selectedHour = _dateTime.hour;
    _selectedMinute = _dateTime.minute;
    widget.localNotificationDataStream.listen((event) {
      if(event == 'Clicked') {
        _setAllNotifications();
      }
      else if(event == 'CancelAll') {
        widget.allNotificationListData.clear();
        //_setInItNotificationData();
        isDailySelected = false;
        isWeekDaysSelected = false;
        isOffSelected = true;
        _setAllNotifications();
        //flutterLocalNotificationsPlugin?.cancelAll();
      }
    });

    _setInItNotificationData();

    if(widget.isNotificationTimerOpen != null) {
      isDailyLogTimerLayoutOpen = widget.isNotificationTimerOpen!;
    }else{
      isDailyLogTimerLayoutOpen = false;
    }
    DateTime? dateTime;
    if (widget.notificationId == 0) {
      localNotificationNameModel = widget.allNotificationListData.firstWhereOrNull(
          (element) => element.notificationName == Constant.dailyLogNotificationTitle);
      if (localNotificationNameModel != null) {
        dateTime =
            DateTime.tryParse(localNotificationNameModel!.notificationTime!);
        if (dateTime != null) {

          if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
            selectedTimerValue = '${localNotificationNameModel!.notificationType ?? Constant.dailyNotificationType}, ${Utils.getTimeInAmPmFormat(dateTime.hour, dateTime.minute)}';
          else
            selectedTimerValue = Utils.getTimeInAmPmFormat(dateTime.hour, dateTime.minute);
        } else {
          if(localNotificationNameModel!.notificationTime != null && localNotificationNameModel!.notificationType != 'Off'){
            if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
              selectedTimerValue = '${localNotificationNameModel!.notificationType ?? Constant.dailyNotificationType}, ${localNotificationNameModel!.notificationTime}';
            else
              selectedTimerValue = localNotificationNameModel!.notificationTime!;
          } else {
            selectedTimerValue = 'Off';
          }
        }
      } else {
        selectedTimerValue = 'Off';
      }
    } else if (widget.notificationId == 1) {
      localNotificationNameModel = widget.allNotificationListData.firstWhereOrNull(
          (element) => element.notificationName == (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.medicationNotificationTitle : Constant.amStudyMedicationNotification));
      if (localNotificationNameModel != null) {
        dateTime =
            DateTime.tryParse(localNotificationNameModel!.notificationTime!);
        if (dateTime != null) {
          if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
            selectedTimerValue = '${localNotificationNameModel!.notificationType ?? 'Daily'}, ${Utils.getTimeInAmPmFormat(dateTime.hour, dateTime.minute)}';
          else
            selectedTimerValue = Utils.getTimeInAmPmFormat(dateTime.hour, dateTime.minute);
        } else {
          if(localNotificationNameModel!.notificationTime != null && localNotificationNameModel!.notificationType != 'Off') {
            if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
              selectedTimerValue = '${localNotificationNameModel!.notificationType ?? 'Daily'}, ${localNotificationNameModel!.notificationTime}';
            else
              selectedTimerValue = localNotificationNameModel!.notificationTime!;
          }else{
            selectedTimerValue = 'Off';
          }
        }
      } else {
        selectedTimerValue = 'Off';
      }
    } else if (widget.notificationId == 2) {
      localNotificationNameModel = widget.allNotificationListData.firstWhereOrNull(
          (element) => element.notificationName == (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.exerciseNotificationTitle : Constant.pmStudyMedicationNotification));
      if (localNotificationNameModel != null) {
        dateTime = DateTime.tryParse(localNotificationNameModel!.notificationTime!);
        if (dateTime != null) {
          if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
            selectedTimerValue = '${localNotificationNameModel!.notificationType ?? 'Daily'}, ${Utils.getTimeInAmPmFormat(dateTime.hour, dateTime.minute)}';
          else
            selectedTimerValue = localNotificationNameModel!.notificationTime!;
        } else {
          if(localNotificationNameModel!.notificationTime != null && localNotificationNameModel!.notificationType != 'Off') {
            if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
              selectedTimerValue = '${localNotificationNameModel!.notificationType ?? 'Daily'}, ${localNotificationNameModel!.notificationTime}';
            else
              selectedTimerValue = Utils.getTimeInAmPmFormat(dateTime!.hour, dateTime.minute);
          } else {
            selectedTimerValue = 'Off';
          }
        }
      } else {
        selectedTimerValue = 'Off';
      }
    } else {

      if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor) {
        localNotificationNameModel = widget.allNotificationListData.firstWhereOrNull(
                (element) => element.isCustomNotificationAdded);
        if (localNotificationNameModel != null) {
          dateTime =
              DateTime.tryParse(localNotificationNameModel!.notificationTime!);
          if (dateTime != null) {
            selectedTimerValue =
            '${localNotificationNameModel!.notificationType ?? 'Daily'}, ${Utils
                .getTimeInAmPmFormat(dateTime.hour, dateTime.minute)}';
          } else {
            if (localNotificationNameModel!.notificationTime != null &&
                localNotificationNameModel!.notificationType != 'Off') {
              selectedTimerValue =
              '${localNotificationNameModel!.notificationType ??
                  'Daily'}, ${localNotificationNameModel!.notificationTime}';
            } else {
              selectedTimerValue = 'Off';
            }
          }
        } else {
          selectedTimerValue = 'Off';
        }
      }
    }

    debugPrint('initState?????${widget.notificationId}?????$selectedTimerValue');
  }

  @override
  void didUpdateWidget(NotificationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setInItNotificationData();
    var appConfig = widget.appConfig;
    if(widget.isNotificationTimerOpen != null) {
      isDailyLogTimerLayoutOpen = widget.isNotificationTimerOpen!;
    }else{
      isDailyLogTimerLayoutOpen = false;
    }
    DateTime? dateTime;
    if (widget.notificationId == 0) {
      localNotificationNameModel = widget.allNotificationListData.firstWhereOrNull((element) => element.notificationName == Constant.dailyLogNotificationTitle);
      if (localNotificationNameModel != null) {
        dateTime = DateTime.tryParse(localNotificationNameModel!.notificationTime!);
        if (dateTime != null) {
          if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
            selectedTimerValue = '${localNotificationNameModel!.notificationType ?? 'Daily'}, ${Utils.getTimeInAmPmFormat(dateTime.hour, dateTime.minute)}';
          else
            selectedTimerValue = Utils.getTimeInAmPmFormat(dateTime.hour, dateTime.minute);
        } else {
          if(localNotificationNameModel!.notificationTime != null && localNotificationNameModel!.notificationType != 'Off') {
            if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
              selectedTimerValue = '${localNotificationNameModel!.notificationType ?? 'Daily'}, ${localNotificationNameModel!.notificationTime}';
            else
              selectedTimerValue = localNotificationNameModel!.notificationTime!;
          } else {
            selectedTimerValue = 'Off';
          }
        }
      } else {
        selectedTimerValue = 'Off';
      }
    } else if (widget.notificationId == 1) {
      localNotificationNameModel = widget.allNotificationListData.firstWhereOrNull(
              (element) => element.notificationName == (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.medicationNotificationTitle : Constant.amStudyMedicationNotification));
      if (localNotificationNameModel != null) {
        dateTime =
            DateTime.tryParse(localNotificationNameModel!.notificationTime!);
        if (dateTime != null) {
          if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
            selectedTimerValue = '${localNotificationNameModel!.notificationType ?? 'Daily'}, ${Utils.getTimeInAmPmFormat(dateTime.hour, dateTime.minute)}';
          else
            selectedTimerValue = Utils.getTimeInAmPmFormat(dateTime.hour, dateTime.minute);
        } else {
          if (localNotificationNameModel!.notificationTime != null && localNotificationNameModel!.notificationType != 'Off') {
            if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
              selectedTimerValue = '${localNotificationNameModel!.notificationType ?? 'Daily'}, ${localNotificationNameModel!.notificationTime}';
            else
              selectedTimerValue = localNotificationNameModel!.notificationTime!;
          } else {
            selectedTimerValue = 'Off';
          }
        }
      } else {
        selectedTimerValue = 'Off';
      }
    } else if (widget.notificationId == 2) {
      localNotificationNameModel = widget.allNotificationListData.firstWhereOrNull(
              (element) => element.notificationName == (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.exerciseNotificationTitle : Constant.pmStudyMedicationNotification));
      if (localNotificationNameModel != null) {
        dateTime =
            DateTime.tryParse(localNotificationNameModel!.notificationTime!);
        if (dateTime != null) {
          if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
            selectedTimerValue = '${localNotificationNameModel!.notificationType ?? 'Daily'}, ${Utils.getTimeInAmPmFormat(dateTime.hour, dateTime.minute)}';
          else
            selectedTimerValue = Utils.getTimeInAmPmFormat(dateTime.hour, dateTime.minute);
        } else {
          if(localNotificationNameModel!.notificationTime != null && localNotificationNameModel!.notificationType != 'Off'){
            selectedTimerValue = '${localNotificationNameModel!.notificationType ?? 'Daily'}, ${localNotificationNameModel!.notificationTime}';
          } else {
            selectedTimerValue = 'Off';
          }
        }
      } else {
        selectedTimerValue = 'Off';
      }
    } else {
      if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor) {
        localNotificationNameModel = widget.allNotificationListData.firstWhereOrNull(
                (element) => element.isCustomNotificationAdded);
        if (localNotificationNameModel != null) {
          dateTime =
              DateTime.tryParse(localNotificationNameModel!.notificationTime!);
          if (dateTime != null) {
            selectedTimerValue =
            '${localNotificationNameModel!.notificationType ?? 'Daily'}, ${Utils
                .getTimeInAmPmFormat(dateTime.hour, dateTime.minute)}';
          } else {
            if (localNotificationNameModel!.notificationTime != null &&
                localNotificationNameModel!.notificationType != 'Off') {
              selectedTimerValue =
              '${localNotificationNameModel!.notificationType ??
                  'Daily'}, ${localNotificationNameModel!.notificationTime}';
            } else {
              selectedTimerValue = 'Off';
            }
          }
        } else {
          selectedTimerValue = 'Off';
        }
      }
    }
    debugPrint('initState?????${widget.notificationId}?????$selectedTimerValue');
  }

  @override
  Widget build(BuildContext context) {
    var appConfig = widget.appConfig;
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _setAllNotifications(false);
            setState(() {
              if (isDailyLogTimerLayoutOpen) {
                isDailyLogTimerLayoutOpen = false;
              } else {
                isDailyLogTimerLayoutOpen = true;
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                text: setNotificationName(),
                style: TextStyle(
                    color: Constant.locationServiceGreen,
                    fontSize: 14,
                    fontFamily: Constant.jostMedium),
              ),
              Row(
                children: [
                  CustomTextWidget(
                    text: appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? ((selectedTimerValue != 'Off') ? (!selectedTimerValue.contains('WeekDay')) ? selectedTimerValue : selectedTimerValue.replaceAll('WeekDay', 'Weekdays only') : 'None') : selectedTimerValue.replaceAll(',', Constant.blankString).trim(),
                    style: TextStyle(
                        color: Constant.notificationTextColor,
                        fontSize: appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? 16 : 14,
                        fontFamily: Constant.jostRegular),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Image(
                    image: AssetImage(isDailyLogTimerLayoutOpen
                        ? Constant.notificationDownArrow
                        : Constant.rightArrow),
                    width: 16,
                    height: 16,
                  )
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5,
        ),
        AnimatedSize(
          //vsync: this,
          duration: Duration(milliseconds: 350),
          child: Visibility(
            visible: isDailyLogTimerLayoutOpen,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      CustomTextWidget(
                        text: 'Notify Me:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Constant.locationServiceGreen,
                          fontFamily: Constant.jostRegular,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      _getNotifyMeWidget(),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 180,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                              fontSize: 18,
                              color: Constant.locationServiceGreen,
                              fontFamily: Constant.jostRegular),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        initialDateTime: _dateTime,
                        backgroundColor: Colors.transparent,
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: false,
                        onDateTimeChanged: (dateTime) {
                          _selectedHour = dateTime.hour;
                          _selectedMinute = dateTime.minute;
                          _dateTime = dateTime;
                          print(_selectedHour);
                          print(_selectedMinute);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: widget.isShowBorder,
          child: Divider(
            thickness: 1,
            color: Constant.locationServiceGreen,
          ),
        ),
      ],
    );
  }

  String setNotificationName() {
    if(widget.notificationId == 3){
      localNotificationNameModel = widget.allNotificationListData.firstWhereOrNull(
              (element) => element.isCustomNotificationAdded);
      if (localNotificationNameModel != null && localNotificationNameModel!.notificationName!.isNotEmpty) {
        print('2CustomNotificationText????${localNotificationNameModel!.notificationName}');
        return localNotificationNameModel!.notificationName ?? '';
      }else {
        debugPrint('1CustomNotificationText?????${widget.notificationName.isNotEmpty ? widget.notificationName :'Custom Notification'}');
        return widget.notificationName.isNotEmpty ? widget.notificationName :'Custom Notification';
      }
    }else return localNotificationNameModel != null ? localNotificationNameModel!.notificationName ?? '' : widget.notificationName;

  }

  void _selectedTimerValueFunc(String userSelectedTimerValue, [bool? isSchedule = true]) {
    print(userSelectedTimerValue);
    setState(() {
      if(isSchedule ?? true)
        isDailyLogTimerLayoutOpen = false;
      selectedTimerValue = userSelectedTimerValue;
    });
  }

  /// This Method will be use for Delete Notification from respective Notification Section.
  Future<void> _deleteNotificationChannel(int channelId) async {
    debugPrint('ChannelId????$channelId');
    await flutterLocalNotificationsPlugin.cancel(channelId);
  }

  /// This Method will be use for to set Daily, Weekly Notifications on respective Notifications Section.
  void _setAllNotifications([bool? isSchedule]) async {
    var appConfig = widget.appConfig;
    if (isDailySelected) {
      whichButtonSelected = appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? 'Daily' : Constant.blankString;
    } else if (isWeekDaysSelected) {
      //whichButtonSelected = 'WeekDay';
      whichButtonSelected = 'Weekdays only';
    } else {
      //whichButtonSelected = 'Off';
      whichButtonSelected = 'None';
    }
    if (isDailySelected || isWeekDaysSelected) {
      _selectedTimerValueFunc('$whichButtonSelected, ${Utils.getTimeInAmPmFormat(_selectedHour, _selectedMinute)}', isSchedule);
      debugPrint('Save Ho GYa');
    } else {
      _selectedTimerValueFunc(whichButtonSelected!, isSchedule);
    }

    await _notificationSelected("", isSchedule ?? true);

    debugPrint('hello');
  }

  /// This Method will be use for to set all UI related data whatever user has saved last time on the current screen.
  void _setInItNotificationData() {
    var appConfig = widget.appConfig;
    if (widget.notificationId == 0) {
      localNotificationNameModel = widget.allNotificationListData.firstWhereOrNull((element) => element.notificationName == Constant.dailyLogNotificationTitle);
      if (localNotificationNameModel != null && localNotificationNameModel!.notificationTime != null) {
        _dateTime = DateTime.tryParse(localNotificationNameModel!.notificationTime!)!;
      } else {
        _dateTime = DateTime.now();
        isDailySelected = false;
        isWeekDaysSelected = false;
        isOffSelected = true;

        if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
          whichButtonSelected = 'Off';
        else
          whichButtonSelected = 'None';
      }
      if (localNotificationNameModel != null && localNotificationNameModel!.notificationType != null) {
        if (localNotificationNameModel!.notificationType == Constant.dailyNotificationType) {
          isDailySelected = true;
          isWeekDaysSelected = false;
          isOffSelected = false;

          if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
            whichButtonSelected = Constant.dailyNotificationType;
          else
            whichButtonSelected = Constant.blankString;
        } else if (localNotificationNameModel!.notificationType == 'WeekDay') {
          isDailySelected = false;
          isWeekDaysSelected = true;
          isOffSelected = false;

          whichButtonSelected = 'Weekdays only';
        } else {
          isDailySelected = false;
          isWeekDaysSelected = false;
          isOffSelected = true;

          if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
            whichButtonSelected = 'None';
          else
            whichButtonSelected = 'Off';
        }
      }
    } else if (widget.notificationId == 1) {
      localNotificationNameModel = widget.allNotificationListData.firstWhereOrNull(
              (element) => element.notificationName == (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.medicationNotificationTitle : Constant.amStudyMedicationNotification));
      if (localNotificationNameModel != null &&
          localNotificationNameModel!.notificationTime != null) {
        _dateTime =
            DateTime.tryParse(localNotificationNameModel!.notificationTime!)!;
      } else {
        _dateTime = DateTime.now();

        isDailySelected = false;
        isWeekDaysSelected = false;
        isOffSelected = true;

        if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
          whichButtonSelected = 'None';
        else
          whichButtonSelected = 'Off';
      }
      if (localNotificationNameModel != null &&
          localNotificationNameModel!.notificationType != null) {
        if (localNotificationNameModel!.notificationType == Constant.dailyNotificationType) {
          isDailySelected = true;
          isWeekDaysSelected = false;
          isOffSelected = false;

          if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
            whichButtonSelected = Constant.dailyNotificationType;
          else
            whichButtonSelected = Constant.blankString;
        } else if (localNotificationNameModel!.notificationType == 'WeekDay') {
          isDailySelected = false;
          isWeekDaysSelected = true;
          isOffSelected = false;

          whichButtonSelected = 'Weekdays only';
        } else {
          isDailySelected = false;
          isWeekDaysSelected = false;
          isOffSelected = true;

          if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
            whichButtonSelected = 'None';
          else
            whichButtonSelected = 'Off';
        }
      }
    } else if (widget.notificationId == 2) {
      localNotificationNameModel = widget.allNotificationListData.firstWhereOrNull(
              (element) => element.notificationName == (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.exerciseNotificationTitle : Constant.pmStudyMedicationNotification));
      if (localNotificationNameModel != null &&
          localNotificationNameModel!.notificationTime != null) {
        _dateTime =
            DateTime.tryParse(localNotificationNameModel!.notificationTime!)!;
      } else {
        _dateTime = DateTime.now();

        isDailySelected = false;
        isWeekDaysSelected = false;
        isOffSelected = true;

        if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
          whichButtonSelected = 'None';
        else
          whichButtonSelected = 'Off';
      }
      if (localNotificationNameModel != null &&
          localNotificationNameModel!.notificationType != null) {
        if (localNotificationNameModel!.notificationType == Constant.dailyNotificationType) {
          isDailySelected = true;
          isWeekDaysSelected = false;
          isOffSelected = false;

          if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
            whichButtonSelected = Constant.dailyNotificationType;
          else
            whichButtonSelected = Constant.blankString;
        } else if (localNotificationNameModel!.notificationType == 'WeekDay') {
          isDailySelected = false;
          isWeekDaysSelected = true;
          isOffSelected = false;

          whichButtonSelected = 'Weekdays only';
        } else {
          isDailySelected = false;
          isWeekDaysSelected = false;
          isOffSelected = true;

          if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor)
            whichButtonSelected = 'None';
          else
            whichButtonSelected = 'Off';
        }
      }
    } else {
      localNotificationNameModel = widget.allNotificationListData.firstWhereOrNull(
              (element) => element.isCustomNotificationAdded);
      if (localNotificationNameModel != null &&
          localNotificationNameModel!.notificationTime != null) {
        _dateTime =
            DateTime.tryParse(localNotificationNameModel!.notificationTime!)!;
      } else {
        _dateTime = DateTime.now();

        isDailySelected = false;
        isWeekDaysSelected = false;
        isOffSelected = true;

        whichButtonSelected = 'None';
      }
      if (localNotificationNameModel != null &&
          localNotificationNameModel!.notificationType != null) {
        if (localNotificationNameModel!.notificationType == 'Daily') {
          isDailySelected = true;
          isWeekDaysSelected = false;
          isOffSelected = false;

          whichButtonSelected = 'Daily';
        } else if (localNotificationNameModel!.notificationType == 'WeekDay') {
          isDailySelected = false;
          isWeekDaysSelected = true;
          isOffSelected = false;

          whichButtonSelected = 'Weekdays only';
        } else {
          isDailySelected = false;
          isWeekDaysSelected = false;
          isOffSelected = true;

          whichButtonSelected = 'None';
        }
      }
    }

    if(_dateTime == null) {
      _dateTime = DateTime.now();
    }

    _selectedHour = _dateTime.hour;
    _selectedMinute = _dateTime.minute;
  }

  /// This Method will be use to set for Daily, Weekly notification on respective notification section.
  Future<void> _notificationSelected(String payload, [bool isSchedule = true]) async {
    var appConfig = widget.appConfig;
    var androidDetails = AndroidNotificationDetails(
      "ChannelId",
      appConfig.buildFlavor,
      channelDescription: 'Reminder to log your day.',
      importance: Importance.max,
      icon: appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? 'notification_icon' : 'tonix_notification_icon',
      color: Constant.chatBubbleGreen,
    );
    var iosDetails = IOSNotificationDetails();
    var notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);
    if (widget.notificationId == 0) {
      if (isDailySelected) {
        dailyNotificationLogTime = 'Daily';

        final tz.TZDateTime now = tz.TZDateTime(tz.local, _dateTime.year, _dateTime.month, _dateTime.day, _selectedHour, _selectedMinute);
        if(isSchedule) {
          await _deleteNotificationChannel(1);
          await flutterLocalNotificationsPlugin.zonedSchedule(
              0, appConfig.buildFlavor, appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.logDayNotification : Constant.dailyLogNotificationDetail, now,
              notificationDetails,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
              androidAllowWhileIdle: true,
              matchDateTimeComponents: DateTimeComponents.time);
        }
      } else if (isWeekDaysSelected) {
        dailyNotificationLogTime = 'WeekDay';
        int weekDay = _dateTime.weekday + 1;
        weekDay = weekDay % 7;

        final tz.TZDateTime now = tz.TZDateTime(tz.local, _dateTime.year, _dateTime.month, _dateTime.day, _selectedHour, _selectedMinute);
        if(isSchedule) {
          await _deleteNotificationChannel(0);
          await flutterLocalNotificationsPlugin.zonedSchedule(
            1,
            appConfig.buildFlavor,
            appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.logDayNotification : Constant.dailyLogNotificationDetail,
            now,
            notificationDetails,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      } else {
        dailyNotificationLogTime = 'Off';
      }
      var dailyLogNotificationData = widget.allNotificationListData.firstWhereOrNull(
              (element) => element.notificationName == Constant.dailyLogNotificationTitle);
      if (dailyLogNotificationData != null) {
        dailyLogNotificationData.notificationName = Constant.dailyLogNotificationTitle;
        dailyLogNotificationData.notificationType = dailyNotificationLogTime;
        if (dailyNotificationLogTime == 'Off') {
          dailyLogNotificationData.notificationTime = Constant.blankString;
          widget.allNotificationListData.remove(dailyLogNotificationData);
        } else {
          print("scheduled notification at $_dateTime");
          dailyLogNotificationData.notificationTime =  _dateTime.toIso8601String();
        }
      } else {
        LocalNotificationModel localNotificationModel = LocalNotificationModel();
        localNotificationModel.notificationName = Constant.dailyLogNotificationTitle;
        localNotificationModel.notificationType = dailyNotificationLogTime;
        if (dailyNotificationLogTime == 'Off') {
          localNotificationModel.notificationTime = Constant.blankString;
          if(isSchedule) {
            await _deleteNotificationChannel(0);
            await _deleteNotificationChannel(1);
          }
        } else {
          localNotificationModel.notificationTime = _dateTime.toIso8601String();
        }
        if(dailyNotificationLogTime != 'Off') {
          widget.allNotificationListData.add(localNotificationModel);
        }else{
          widget.allNotificationListData.remove(localNotificationModel);
          if(isSchedule) {
            await _deleteNotificationChannel(0);
            await _deleteNotificationChannel(1);
          }
        }
      }
    } else if (widget.notificationId == 1) {
      if (isDailySelected) {
        medicationNotificationLogTime = Constant.dailyNotificationType;
        final tz.TZDateTime now = tz.TZDateTime(tz.local, _dateTime.year, _dateTime.month, _dateTime.day, _selectedHour, _selectedMinute);

        if(isSchedule) {
          await _deleteNotificationChannel(3);
          await flutterLocalNotificationsPlugin.zonedSchedule(
            2,
            appConfig.buildFlavor,
            appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.medicationNotification : Constant.morningMedicationNotificationDetail,
            now,
            notificationDetails,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        }
      } else if (isWeekDaysSelected) {
        medicationNotificationLogTime = 'WeekDay';
        int weekDay = _dateTime.weekday + 1;
        weekDay = weekDay % 7;

        final tz.TZDateTime now = tz.TZDateTime(tz.local, _dateTime.year, _dateTime.month, _dateTime.day, _selectedHour, _selectedMinute);

        if(isSchedule) {
          await _deleteNotificationChannel(2);
          await flutterLocalNotificationsPlugin.zonedSchedule(
              3, appConfig.buildFlavor, appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.medicationNotification : Constant.morningMedicationNotificationDetail, now,
              notificationDetails,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
                  .absoluteTime,
              androidAllowWhileIdle: true,
              matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
        }
      } else {
        medicationNotificationLogTime = 'Off';
      }
      var medicationNotificationData = widget.allNotificationListData
          .firstWhereOrNull((element) => element.notificationName == (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.medicationNotificationTitle : Constant.amStudyMedicationNotification));
      if (medicationNotificationData != null) {
        medicationNotificationData.notificationName = appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.medicationNotificationTitle : Constant.amStudyMedicationNotification;
        medicationNotificationData.notificationType =
            medicationNotificationLogTime;
        if (medicationNotificationLogTime == 'Off') {
          medicationNotificationData.notificationTime = Constant.blankString;
          widget.allNotificationListData.remove(medicationNotificationData);
          if(isSchedule) {
            await _deleteNotificationChannel(2);
            await _deleteNotificationChannel(3);
          }
        } else {
          medicationNotificationData.notificationTime = _dateTime.toIso8601String();
        }
      } else {
        LocalNotificationModel localNotificationModel = LocalNotificationModel();
        localNotificationModel.notificationName = appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.medicationNotificationTitle : Constant.amStudyMedicationNotification;
        localNotificationModel.notificationType = medicationNotificationLogTime;
        if (medicationNotificationLogTime == 'Off') {
          localNotificationModel.notificationTime = Constant.blankString;
        } else {
          localNotificationModel.notificationTime = _dateTime.toIso8601String();
        }
        if(medicationNotificationLogTime != 'Off') {
          widget.allNotificationListData.add(localNotificationModel);
        }else{
          widget.allNotificationListData.remove(localNotificationModel);
          if(isSchedule) {
            await _deleteNotificationChannel(2);
            await _deleteNotificationChannel(3);
          }
        }
      }
    } else if (widget.notificationId == 2) {
      if (isDailySelected) {
        exerciseNotificationLogTime = Constant.dailyNotificationType;
        final tz.TZDateTime now = tz.TZDateTime(tz.local, _dateTime.year, _dateTime.month, _dateTime.day, _selectedHour, _selectedMinute);

        if(isSchedule) {
          await _deleteNotificationChannel(5);
          await flutterLocalNotificationsPlugin.zonedSchedule(
              4, appConfig.buildFlavor, appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.exerciseNotification : Constant.eveningMedicationNotificationDetail, now,
              notificationDetails,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
                  .absoluteTime,
              androidAllowWhileIdle: true,
              matchDateTimeComponents: DateTimeComponents.time);
        }
      } else if (isWeekDaysSelected) {
        exerciseNotificationLogTime = 'WeekDay';
        int weekDay = _dateTime.weekday + 1;
        weekDay = weekDay % 7;

        final tz.TZDateTime now = tz.TZDateTime(tz.local, _dateTime.year, _dateTime.month, _dateTime.day, _selectedHour, _selectedMinute);

        if(isSchedule) {
          await _deleteNotificationChannel(4);
          await flutterLocalNotificationsPlugin.zonedSchedule(
              5, appConfig.buildFlavor, appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.exerciseNotification : Constant.eveningMedicationNotificationDetail, now,
              notificationDetails,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
              androidAllowWhileIdle: true,
              matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
        }
      } else {
        exerciseNotificationLogTime = 'Off';
      }

      var exerciseNotificationData = widget.allNotificationListData.firstWhereOrNull(
              (element) => element.notificationName == (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.exerciseNotificationTitle : Constant.pmStudyMedicationNotification));
      if (exerciseNotificationData != null) {
        exerciseNotificationData.notificationName = appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.exerciseNotificationTitle : Constant.pmStudyMedicationNotification;
        exerciseNotificationData.notificationType = exerciseNotificationLogTime;
        if (exerciseNotificationLogTime == 'Off') {
          exerciseNotificationData.notificationTime = Constant.blankString;
          widget.allNotificationListData.remove(exerciseNotificationData);
          if(isSchedule) {
            await _deleteNotificationChannel(4);
            await _deleteNotificationChannel(5);
          }
        } else {
          exerciseNotificationData.notificationTime =  _dateTime.toIso8601String();
        }
      } else {
        LocalNotificationModel localNotificationModel = LocalNotificationModel();
        localNotificationModel.notificationName = appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.exerciseNotificationTitle : Constant.pmStudyMedicationNotification;
        localNotificationModel.notificationType = exerciseNotificationLogTime;
        if (exerciseNotificationLogTime == 'Off') {
          localNotificationModel.notificationTime = Constant.blankString;
        } else {
          localNotificationModel.notificationTime = _dateTime.toIso8601String();
        }
        if(exerciseNotificationLogTime != 'Off') {
          widget.allNotificationListData.add(localNotificationModel);
        }else{
          if(isSchedule) {
            await _deleteNotificationChannel(4);
            await _deleteNotificationChannel(5);
          }
          widget.allNotificationListData.remove(localNotificationModel);
        }
      }
    } else {
      var customNotificationData = widget.allNotificationListData.firstWhereOrNull(
              (element) => element.isCustomNotificationAdded);
      if (customNotificationData != null) {
        customNotificationValue = customNotificationData.notificationName!;
      }else{
        customNotificationValue = widget.notificationName;
      }

      print('customNotificationValue???$customNotificationValue');
      if (isDailySelected) {
        customNotificationLogTime = 'Daily';
        final tz.TZDateTime now = tz.TZDateTime(tz.local, _dateTime.year, _dateTime.month, _dateTime.day, _selectedHour, _selectedMinute);

        if(isSchedule) {
          await _deleteNotificationChannel(7);
          await flutterLocalNotificationsPlugin.zonedSchedule(
              6, appConfig.buildFlavor, customNotificationValue, now,
              notificationDetails,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
                  .absoluteTime,
              androidAllowWhileIdle: true,
              matchDateTimeComponents: DateTimeComponents.time);
        }
      } else if (isWeekDaysSelected) {
        customNotificationLogTime = 'WeekDay';
        int weekDay = _dateTime.weekday + 1;
        weekDay = weekDay % 7;

        final tz.TZDateTime now = tz.TZDateTime(tz.local, _dateTime.year, _dateTime.month, _dateTime.day, _selectedHour, _selectedMinute);

        if(isSchedule) {
          await _deleteNotificationChannel(6);
          await flutterLocalNotificationsPlugin.zonedSchedule(
              7, appConfig.buildFlavor, customNotificationValue, now,
              notificationDetails,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
                  .absoluteTime,
              androidAllowWhileIdle: true,
              matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
        }

        /*await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
            7,
            'MigraineMentor',
            customNotificationValue,
            Day(weekDay),
            Time(_selectedHour, _selectedMinute),
            notificationDetails);*/
      } else {
        customNotificationLogTime = 'Off';
      }
      if (customNotificationData != null) {
        customNotificationData.notificationType = customNotificationLogTime;
        if (customNotificationLogTime == 'Off') {
          customNotificationData.notificationTime = "";
          if(isSchedule) {
            await _deleteNotificationChannel(6);
            await _deleteNotificationChannel(7);
            widget.allNotificationListData.remove(customNotificationData);
          }
        } else {
          customNotificationData.notificationTime =  _dateTime.toIso8601String();
        }
      }else {
        LocalNotificationModel localNotificationModel = LocalNotificationModel();
        debugPrint('3CustomNotificationText??????${widget.notificationName}');
        localNotificationModel.notificationName = widget.notificationName;
        localNotificationModel.notificationType = customNotificationLogTime;
        localNotificationModel.isCustomNotificationAdded = true;
        if (customNotificationLogTime == 'Off') {
          localNotificationModel.notificationTime = "";
          if(isSchedule) {
            await _deleteNotificationChannel(6);
            await _deleteNotificationChannel(7);
          }
        } else {
          localNotificationModel.notificationTime = _dateTime.toIso8601String();
        }
        if(customNotificationLogTime != 'Off') {
          widget.allNotificationListData.add(localNotificationModel);
        }else {
          if(isSchedule) {
            widget.allNotificationListData.remove(localNotificationModel);
            await _deleteNotificationChannel(6);
            await _deleteNotificationChannel(7);
          }
        }
      }
    }
  }

  void _removeNotificationDataFromList() {
    var appConfig = widget.appConfig;
    if(widget.notificationId == 0) {
      var dailyLogNotificationData = widget.allNotificationListData.firstWhereOrNull(
              (element) => element.notificationName == Constant.dailyLogNotificationTitle);

      if(dailyLogNotificationData != null) {
        widget.allNotificationListData.remove(dailyLogNotificationData);
      }
    } else if(widget.notificationId == 1) {
      var medicationNotificationData = widget.allNotificationListData
          .firstWhereOrNull((element) => element.notificationName == (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.medicationNotificationTitle : Constant.amStudyMedicationNotification));

      if(medicationNotificationData != null) {
        widget.allNotificationListData.remove(medicationNotificationData);
      }
    } else if(widget.notificationId == 2) {
      var exerciseNotificationData = widget.allNotificationListData.firstWhereOrNull(
              (element) => element.notificationName == (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.exerciseNotificationTitle : Constant.pmStudyMedicationNotification));

      if(exerciseNotificationData != null) {
        widget.allNotificationListData.remove(exerciseNotificationData);
      }
    } else if (widget.notificationId == 3) {
      var customNotificationData = widget.allNotificationListData.firstWhereOrNull(
              (element) => element.isCustomNotificationAdded);

      if(customNotificationData != null) {
        //widget.allNotificationListData.remove(customNotificationData);
        customNotificationData.notificationType = 'Off';
        customNotificationData.notificationTime = Constant.blankString;
      }
    }
  }

  int _getGroupValue() {
    int grpValue = 0;
    if(isDailySelected)
      grpValue = 0;

    if(isWeekDaysSelected)
      grpValue = 1;

    if(isOffSelected)
      grpValue = 2;

    return grpValue;
  }

  Widget _getNotifyMeWidget() {
    var appConfig = widget.appConfig;

    if (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Theme(
                    data: ThemeData(
                        unselectedWidgetColor:
                        Constant.chatBubbleGreen),
                    child: Radio(
                      value: 0,
                      activeColor: Constant.chatBubbleGreen,
                      hoverColor: Constant.chatBubbleGreen,
                      focusColor: Constant.chatBubbleGreen,
                      groupValue: _getGroupValue(),
                      onChanged: (int? value) {
                        setState(() {
                          isWeekDaysSelected = false;
                          isOffSelected = false;
                          if (!isDailySelected) {
                            isDailySelected = true;

                            if(selectedTimerValue != null) {
                              selectedTimerValue = 'Daily, ${Utils.getTimeInAmPmFormat(_dateTime.hour, _dateTime.minute)}';
                            }
                          }
                        });
                      },
                    ),
                  ),
                ),
                CustomTextWidget(
                  text: 'Daily',
                  style: TextStyle(
                      color: Constant.chatBubbleGreen,
                      fontSize: 12,
                      fontFamily: Constant.jostRegular),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Theme(
                    data: ThemeData(
                        unselectedWidgetColor:
                        Constant.chatBubbleGreen),
                    child: Radio(
                      value: 1,
                      activeColor: Constant.chatBubbleGreen,
                      hoverColor: Constant.chatBubbleGreen,
                      focusColor: Constant.chatBubbleGreen,
                      groupValue: _getGroupValue(),
                      onChanged: (int? value) {
                        setState(() {
                          isDailySelected = false;
                          isOffSelected = false;
                          if (!isWeekDaysSelected) {
                            isWeekDaysSelected = true;

                            if(selectedTimerValue != null) {
                              if(selectedTimerValue != null) {
                                selectedTimerValue = 'WeekDay, ${Utils.getTimeInAmPmFormat(_dateTime.hour, _dateTime.minute)}';
                              }
                            }
                          }
                        });
                      },
                    ),
                  ),
                ),
                CustomTextWidget(
                  text: 'Weekdays only',
                  style: TextStyle(
                      color: Constant.chatBubbleGreen,
                      fontSize: 12,
                      fontFamily: Constant.jostRegular),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Theme(
                    data: ThemeData(
                        unselectedWidgetColor:
                        Constant.chatBubbleGreen),
                    child: Radio(
                      value: 2,
                      activeColor: Constant.chatBubbleGreen,
                      hoverColor: Constant.chatBubbleGreen,
                      focusColor: Constant.chatBubbleGreen,
                      groupValue: _getGroupValue(),
                      onChanged: (int? value) {
                        setState(() {
                          isWeekDaysSelected = false;
                          isDailySelected = false;
                          if (!isOffSelected) {
                            isOffSelected = true;

                            _selectedTimerValueFunc('Off');
                            _removeNotificationDataFromList();
                          }
                        });
                      },
                    ),
                  ),
                ),
                CustomTextWidget(
                  text: 'None',
                  style: TextStyle(
                      color: Constant.chatBubbleGreen,
                      fontSize: 12,
                      fontFamily: Constant.jostRegular),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Transform.scale(
        scale:0.7,
        child: CupertinoSwitch(
          value: isDailySelected,
          onChanged: (bool state) {
            if (state) {
              setState(() {
                isWeekDaysSelected = false;
                isOffSelected = false;
                if (!isDailySelected) {
                  isDailySelected = true;
                  if (selectedTimerValue != null) {
                    selectedTimerValue = Utils.getTimeInAmPmFormat(_dateTime.hour, _dateTime.minute);
                    _notificationSelected('',false);
                  }
                }
              });
            } else {
              setState(() {
                isWeekDaysSelected = false;
                isDailySelected = false;
                if (!isOffSelected) {
                  isOffSelected = true;

                  _selectedTimerValueFunc('Off');
                  if (widget.notificationId == 0) {
                    _deleteNotificationChannel(0);
                    _deleteNotificationChannel(1);
                  } else if (widget.notificationId == 1) {
                    _deleteNotificationChannel(2);
                    _deleteNotificationChannel(3);
                  } else if (widget.notificationId == 2) {
                    _deleteNotificationChannel(4);
                    _deleteNotificationChannel(5);
                  } else {
                    _deleteNotificationChannel(6);
                    _deleteNotificationChannel(7);
                  }

                  _removeNotificationDataFromList();
                }
              });
            }
          },
          activeColor:
          Constant.chatBubbleGreen.withOpacity(0.6),
          trackColor:
          Constant.chatBubbleGreen.withOpacity(0.2),
        ),
      );
    }
  }
}
