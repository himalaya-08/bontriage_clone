class LocalNotificationModel {
  String? notificationName;
  String? notificationTime;
  String? notificationType;
  String? userId;
  bool isCustomNotificationAdded = false;

  LocalNotificationModel(
      {this.notificationName,
      this.notificationTime,
      this.notificationType,
      this.userId,
      this.isCustomNotificationAdded = false});

  factory LocalNotificationModel.fromJson(Map<String, dynamic> json) =>
      LocalNotificationModel(
        notificationName: json["notificationName"],
        notificationTime: json["notificationTime"],
        notificationType: json["notificationType"],
        isCustomNotificationAdded: json["isCustomNotificationAdded"],
        userId: json["userId"],
      );

  Map<String, dynamic> toJson() => {
        "notificationName": notificationName,
        "notificationTime": notificationTime,
        "notificationType": notificationType,
        "isCustomNotificationAdded": isCustomNotificationAdded,
        "userId": userId,
      };
}
