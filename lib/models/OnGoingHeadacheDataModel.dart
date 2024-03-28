import 'dart:convert';

import 'package:mobile/models/CalendarInfoDataModel.dart';

OnGoingHeadacheDataModel onGoingHeadacheDataModelDartFromJson(String str) => OnGoingHeadacheDataModel.fromJson(json.decode(str));

String onGoingHeadacheDataModelDartToJson(OnGoingHeadacheDataModel data) => json.encode(data.toJson());

class OnGoingHeadacheDataModel {
  OnGoingHeadacheDataModel({
    this.isExists,
    this.headaches,
  });

  bool? isExists;
  List<Headache>? headaches;

  factory OnGoingHeadacheDataModel.fromJson(Map<String, dynamic> json) => OnGoingHeadacheDataModel(
    isExists: json["isExists"],
    headaches: List<Headache>.from(json["headaches"].map((x) => Headache.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "isExists": isExists,
    "headaches": List<dynamic>.from(headaches!.map((x) => x.toJson())),
  };
}