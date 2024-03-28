import 'dart:convert';

import 'SignUpOnBoardAnswersRequestModel.dart';

class LogDaySendDataModel {
  SignUpOnBoardAnswersRequestModel? behaviors;
  List<SignUpOnBoardAnswersRequestModel>? medication;
  SignUpOnBoardAnswersRequestModel? triggers;
  SignUpOnBoardAnswersRequestModel? note;
  SignUpOnBoardAnswersRequestModel? headache;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['behaviors'] = behaviors!.toJson();
    data['medication'] = medication;
    data['triggers'] = triggers!.toJson();
    data['note'] = note!.toJson();
    return data;
  }

  Map<String, dynamic> toJsonForHeadache() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['headache'] = headache;
    data['medication'] = medication;
    return data;
  }
}