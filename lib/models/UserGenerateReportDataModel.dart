// To parse this JSON data, do
//
//     final userGenerateReportDataModel = userGenerateReportDataModelFromJson(jsonString);

import 'dart:convert';

UserGenerateReportDataModel userGenerateReportDataModelFromJson(String str) => UserGenerateReportDataModel.fromJson(json.decode(str));

String userGenerateReportDataModelToJson(UserGenerateReportDataModel data) => json.encode(data.toJson());

class UserGenerateReportDataModel {
  UserGenerateReportDataModel({
    this.map,
  });

  MapClass? map;

  factory UserGenerateReportDataModel.fromJson(Map<String, dynamic> json) => UserGenerateReportDataModel(
    map: MapClass.fromJson(json["map"]),
  );

  Map<String, dynamic> toJson() => {
    "map": map!.toJson(),
  };
}

class MapClass {
  MapClass({
    this.base64,
  });

  String? base64;

  factory MapClass.fromJson(Map<String, dynamic> json) => MapClass(
    base64: json["base64"],
  );

  Map<String, dynamic> toJson() => {
    "base64": base64,
  };
}
