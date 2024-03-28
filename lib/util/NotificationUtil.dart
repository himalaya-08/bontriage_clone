import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/main.dart';
import 'package:mobile/models/LocalNotificationModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationUtil {
  static Future<void> notificationSelected(LocalNotificationModel localNotificationModel, DateTime defaultNotificationTime, AppConfig appConfig) async {
    var androidDetails = AndroidNotificationDetails(
        "ChannelId", appConfig.buildFlavor, channelDescription: 'Reminder to log your day.',
        importance: Importance.max, icon: appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? 'notification_icon' : 'tonix_notification_icon', color: Constant.chatBubbleGreen);
    var iosDetails = IOSNotificationDetails();
    var notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    int _selectedHour = defaultNotificationTime.hour;
    int _selectedMinute = defaultNotificationTime.minute;
    int weekDay = defaultNotificationTime.weekday + 1;
    weekDay = weekDay % 7;

    final tz.TZDateTime now = tz.TZDateTime(tz.local, defaultNotificationTime.year, defaultNotificationTime.month, defaultNotificationTime.day, _selectedHour, _selectedMinute);

    if (localNotificationModel.notificationName == Constant.dailyLogNotificationTitle) {
      if(localNotificationModel.notificationType == Constant.dailyNotificationType) {
        await flutterLocalNotificationsPlugin.zonedSchedule(01, appConfig.buildFlavor, appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.logDayNotification : Constant.dailyLogNotificationDetail, now, notificationDetails, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidAllowWhileIdle: true, matchDateTimeComponents: DateTimeComponents.time);
      } else {
        await flutterLocalNotificationsPlugin.zonedSchedule(02, appConfig.buildFlavor, appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.logDayNotification : Constant.dailyLogNotificationDetail, now, notificationDetails, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidAllowWhileIdle: true, matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
      }
    } else if (localNotificationModel.notificationName == (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.medicationNotificationTitle : Constant.amStudyMedicationNotification)) {
      if(localNotificationModel.notificationType == Constant.dailyNotificationType) {
        await flutterLocalNotificationsPlugin.zonedSchedule(03, appConfig.buildFlavor, appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.medicationNotification : Constant.morningMedicationNotificationDetail, now, notificationDetails, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidAllowWhileIdle: true, matchDateTimeComponents: DateTimeComponents.time);
      } else {
        await flutterLocalNotificationsPlugin.zonedSchedule(04, appConfig.buildFlavor, appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.medicationNotification : Constant.morningMedicationNotificationDetail, now, notificationDetails, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidAllowWhileIdle: true, matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
      }
    } else if (localNotificationModel.notificationName == (appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.exerciseNotificationTitle : Constant.pmStudyMedicationNotification)) {
      if(localNotificationModel.notificationType == Constant.dailyNotificationType) {
        await flutterLocalNotificationsPlugin.zonedSchedule(05, appConfig.buildFlavor, appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.exerciseNotification : Constant.eveningMedicationNotificationDetail, now, notificationDetails, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidAllowWhileIdle: true, matchDateTimeComponents: DateTimeComponents.time);
      } else {
        await flutterLocalNotificationsPlugin.zonedSchedule(06, appConfig.buildFlavor, appConfig.buildFlavor == Constant.migraineMentorBuildFlavor ? Constant.exerciseNotification : Constant.eveningMedicationNotificationDetail, now, notificationDetails, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidAllowWhileIdle: true, matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
      }
    } else if (localNotificationModel.isCustomNotificationAdded) {
      if(localNotificationModel.notificationType == Constant.dailyNotificationType) {
        await flutterLocalNotificationsPlugin.zonedSchedule(07, appConfig.buildFlavor, localNotificationModel.notificationName ?? 'Custom', now, notificationDetails, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidAllowWhileIdle: true, matchDateTimeComponents: DateTimeComponents.time);
      } else {
        await flutterLocalNotificationsPlugin.zonedSchedule(07, appConfig.buildFlavor, localNotificationModel.notificationName ?? 'Custom', now, notificationDetails, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidAllowWhileIdle: true, matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
      }
    }
  }
}