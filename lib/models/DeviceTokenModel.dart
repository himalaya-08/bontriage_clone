import 'dart:convert';

DeviceTokenModel deviceTokenModelFromJson(String str) => DeviceTokenModel.fromJson(json.decode(str));

String deviceTokenModelToJson(DeviceTokenModel data) => json.encode(data.toJson());

class DeviceTokenModel {
  DeviceTokenModel({
    this.action,
    this.userId,
    this.tokenType,
    this.devicetoken,
  });

  String? action;
  int? userId;
  int? tokenType;
  String? devicetoken;

  factory DeviceTokenModel.fromJson(Map<String, dynamic> json) => DeviceTokenModel(
    action: json["action"],
    userId: json["user_id"],
    tokenType: json["tokenType"],
    devicetoken: json["devicetoken"],
  );

  Map<String, dynamic> toJson() => {
    "action": action,
    "user_id": userId,
    "tokenType": tokenType,
    "devicetoken": devicetoken,
  };
}