import 'dart:convert';

UserProfileInfoModel userProfileInfoModelFromJson(String str) =>
    UserProfileInfoModel.fromJson(json.decode(str));

String userProfileInfoModelToJson(UserProfileInfoModel data) =>
    json.encode(data.toJson());

class UserProfileInfoModel {
  UserProfileInfoModel({
    this.userId,
    this.email,
    this.sex,
    this.age,
    this.updatedAt,
    this.createdAt,
    this.firstName,
    this.lastName,
    this.notificationKey,
    this.profileName,
    this.subjectId,
    this.siteId,
    this.siteCode,
    this.siteName,
    this.siteCoordinatorName,
    this.sitePhNumber,
    this.siteEmail,
  });

  String? userId;
  String? email;
  String? sex;
  String? age;
  DateTime? updatedAt;
  DateTime? createdAt;
  String? firstName;
  String? lastName;
  String? notificationKey;
  String? profileName;
  String? subjectId;
  String? siteId;
  String? siteCode;
  String? siteName;
  String? siteCoordinatorName;
  String? sitePhNumber;
  String? siteEmail;

  factory UserProfileInfoModel.fromJson(Map<String, dynamic> json) =>
      UserProfileInfoModel(
        userId: json['id'] != null
            ? json["id"].toString()
            : json["userId"].toString(),
        email: json["email"],
        sex: json["sex"],
        age: json["age"] != null ? json["age"].toString() : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json["updatedAt"]) : null,
        createdAt: json['createdAt'] != null ? DateTime.parse(json["createdAt"]) : null,
        firstName: json["firstName"],
        lastName: json["lastName"],
        notificationKey: json["notificationKey"],
        profileName: json['profileName'],
        subjectId: json['subjectId'],
        siteId: json['siteId'].toString(),
        siteName: json['siteName'],
        siteCoordinatorName: json['siteCoordinatorName'],
        sitePhNumber: json['sitePhNumber'],
        siteEmail: json['siteEmail'],
        siteCode: json['siteCode'],
      );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "email": email,
    "sex": sex,
    "age": age,
    "updatedAt": updatedAt != null ? updatedAt!.toIso8601String() : null,
    "createdAt": createdAt != null ? createdAt!.toIso8601String() : null,
    "firstName": firstName,
    "lastName": lastName,
    "notificationKey": notificationKey,
    'profileName': profileName,
    'subjectId': subjectId,
    'siteId': siteId,
    'siteCode': siteCode,
    'siteName': siteName,
    'siteCoordinatorName': siteCoordinatorName,
    'sitePhNumber': sitePhNumber,
    'siteEmail': siteEmail,
  };
}
