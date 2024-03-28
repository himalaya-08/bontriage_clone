import 'dart:convert';

import 'ResponseModel.dart';
import 'WelcomeOnBoardProfileModel.dart';

class LogDayResponseModel {
  WelcomeOnBoardProfileModel? medication;
  WelcomeOnBoardProfileModel? behaviors;
  WelcomeOnBoardProfileModel? triggers;
  List<ResponseModel>? profile;

  LogDayResponseModel({this.medication, this.behaviors, this.triggers, this.profile});

  LogDayResponseModel.fromJson(Map<String, dynamic> json) {
    medication = WelcomeOnBoardProfileModel.fromJson(json['medication']);
    behaviors = WelcomeOnBoardProfileModel.fromJson(json['behaviors']);
    triggers = WelcomeOnBoardProfileModel.fromJson(json['triggers']);
    profile = responseModelFromJson(jsonEncode(json['profile']));
  }
}