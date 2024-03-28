
import 'dart:convert';

SignUpScreenOnBoardModel signUpScreenOnBoardModelFromJson(String str) => SignUpScreenOnBoardModel.fromJson(json.decode(str));

String signUpScreenOnBoardModelToJson(SignUpScreenOnBoardModel data) => json.encode(data.toJson());

class SignUpScreenOnBoardModel {
  SignUpScreenOnBoardModel({
    this.age,
    this.email,
    this.firstName,
    this.lastName,
    this.location,
    this.notificationKey,
    this.password,
    this.sex,
    this.termsAndPolicy = false,
    this.emailNotification = false,
    this.subjectId = '',
    this.birthYear = '',
    this.siteId,
    this.siteCode,
    this.siteName,
    this.siteCoordinatorName,
    this.sitePhNumber,
    this.siteEmail
  });

  String? age;
  String? email;
  String? firstName;
  String? lastName;
  String? location;
  String? notificationKey;
  String? password;
  String? sex;
  bool? termsAndPolicy;
  bool? emailNotification;
  String? subjectId;
  String? birthYear;
  String? siteId;
  String? siteName;
  String? siteCoordinatorName;
  String? sitePhNumber;
  String? siteEmail;
  String? siteCode;


  factory SignUpScreenOnBoardModel.fromJson(Map<String, dynamic> json) => SignUpScreenOnBoardModel(
      age: json["age"],
      email: json["email"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      location: json["location"],
      notificationKey: json["notification_key"],
      password: json["password"],
      sex: json["sex"],
      termsAndPolicy: json['terms_and_policy'],
      emailNotification: json['email_notification'],
      siteId: json['site_id'],
      siteCode: json['site_code'],
      siteName: json['site_name'],
      siteCoordinatorName: json['site_coordinator_name'],
      sitePhNumber: json['site_ph_number'],
      siteEmail: json['site_email'],
  );

  Map<String, dynamic> toJson() => {
    "age": age,
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
    "location": location,
    "notification_key": notificationKey,
    "password": password,
    "sex": sex,
    'terms_and_policy': termsAndPolicy,
    'email_notification': emailNotification,
  };

  Map<String, dynamic> toTonixSignUpJson() => {
    "age": age,
    "subject_id": subjectId,
    "first_name": firstName,
    "last_name": lastName,
    "location": location,
    "notification_key": notificationKey,
    "password": password,
    "sex": sex,
    'terms_and_policy': termsAndPolicy,
    'email_notification': emailNotification,
    'birth_year': birthYear,
    'site_id': siteId,
    'site_code': siteCode,
    'site_name': siteName,
    'site_coordinator_name': siteCoordinatorName,
    'site_ph_number': sitePhNumber,
    'site_email': siteEmail
  };
}
