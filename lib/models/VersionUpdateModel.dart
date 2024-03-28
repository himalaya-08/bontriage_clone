// To parse this JSON data, do
//
//     final versionUpdateModel = versionUpdateModelFromJson(jsonString);

import 'dart:convert';

VersionUpdateModel versionUpdateModelFromJson(String str) => VersionUpdateModel.fromJson(json.decode(str));

String versionUpdateModelToJson(VersionUpdateModel data) => json.encode(data.toJson());

class VersionUpdateModel {
  VersionUpdateModel({
    this.id,
    this.name,
    this.description,
    this.iosVersion,
    this.iosCritical,
    this.iosBuildDate,
    this.androidVersion,
    this.androidCritical,
    this.androidBuildDate,
    this.androidBuildDetails,
    this.active,
  });

  int? id;
  String? name;
  String? description;
  String? iosVersion;
  bool? iosCritical;
  DateTime? iosBuildDate;
  String? androidVersion;
  bool? androidCritical;
  DateTime? androidBuildDate;
  String? androidBuildDetails;
  bool? active;

  factory VersionUpdateModel.fromJson(Map<String, dynamic> json) => VersionUpdateModel(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    iosVersion: json["ios_version"],
    iosCritical: json["ios_critical"],
    iosBuildDate: DateTime.parse(json["ios_build_date"]),
    androidVersion: json["android_version"],
    androidCritical: json["android_critical"],
    androidBuildDate: DateTime.parse(json["android_build_date"]),
    androidBuildDetails: json["android_build_details"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "ios_version": iosVersion,
    "ios_critical": iosCritical,
    "ios_build_date": iosBuildDate!.toIso8601String(),
    "android_version": androidVersion,
    "android_critical": androidCritical,
    "android_build_date": androidBuildDate!.toIso8601String(),
    "android_build_details": androidBuildDetails,
    "active": active,
  };
}
