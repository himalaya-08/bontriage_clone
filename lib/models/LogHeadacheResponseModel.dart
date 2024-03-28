import 'dart:convert';

import 'package:mobile/models/AddHeadacheResponseModel.dart';

LogHeadacheResponseModel logHeadacheResponseModelFromJson(String str) => LogHeadacheResponseModel.fromJson(json.decode(str));

String logHeadacheResponseModelToJson(LogHeadacheResponseModel data) => json.encode(data.toJson());

class LogHeadacheResponseModel {
  LogHeadacheResponseModel({
    this.headache,
    this.medication,
  });

  Headache? headache;
  List<Headache>? medication;

  factory LogHeadacheResponseModel.fromJson(Map<String, dynamic> json) => LogHeadacheResponseModel(
    headache: Headache.fromJson(json["headache"]),
    medication: json['medication'] != null ? List<Headache>.from(json["medication"].map((x) => Headache.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "headache": headache!.toJson(),
    "medication": List<dynamic>.from(medication!.map((x) => x.toJson())),
  };
}

class Headache {
  Headache({
    this.id,
    this.userId,
    this.uploadedAt,
    this.updatedAt,
    this.calendarEntryAt,
    this.eventType,
    this.mobileEventDetails,
    this.headacheList,
    this.isMigraine,
  });

  int? id;
  int? userId;
  DateTime? uploadedAt;
  DateTime? updatedAt;
  DateTime? calendarEntryAt;
  String? eventType;
  List<AddHeadacheMobileEventDetail>? mobileEventDetails;
  List<dynamic>? headacheList;
  bool? isMigraine;

  factory Headache.fromJson(Map<String, dynamic> json) => Headache(
    id: json["id"],
    userId: json["user_id"],
    uploadedAt: DateTime.tryParse(json["uploaded_at"]),
    updatedAt: DateTime.tryParse(json["updated_at"]),
    calendarEntryAt: DateTime.tryParse(json["calendar_entry_at"]),
    eventType: json["event_type"],
    mobileEventDetails: json["mobile_event_details"] != null ? List<AddHeadacheMobileEventDetail>.from(json["mobile_event_details"].map((x) => AddHeadacheMobileEventDetail.fromJson(x))) : [],
    headacheList: json["headache_list"] != null ? List<dynamic>.from(json["headache_list"].map((x) => x)) : [],
    isMigraine: json["is_migraine"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "uploaded_at": uploadedAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
    "calendar_entry_at": calendarEntryAt!.toIso8601String(),
    "event_type": eventType,
    "mobile_event_details": List<dynamic>.from(mobileEventDetails!.map((x) => x.toJson())),
    "headache_list": List<dynamic>.from(headacheList!.map((x) => x)),
    "is_migraine": isMigraine,
  };
}
