import 'dart:convert';

LogHeadacheResponseDataModel logHeadacheResponseDataModelFromJson(String str) => LogHeadacheResponseDataModel.fromJson(json.decode(str));

String logHeadacheResponseDataModelToJson(LogHeadacheResponseDataModel data) => json.encode(data.toJson());

class LogHeadacheResponseDataModel {
  LogHeadacheResponseDataModel({
    this.medication,
    this.headache,
  });

  List<Headache>? medication;
  List<Headache>? headache;

  factory LogHeadacheResponseDataModel.fromJson(Map<String, dynamic> json) => LogHeadacheResponseDataModel(
    medication: List<Headache>.from(json["medication"].map((x) => Headache.fromJson(x))),
    headache: List<Headache>.from(json["headache"].map((x) => Headache.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "medication": List<dynamic>.from(medication!.map((x) => x.toJson())),
    "headache": List<dynamic>.from(headache!.map((x) => x.toJson())),
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
  List<MobileEventDetail>? mobileEventDetails;
  List<dynamic>? headacheList;
  bool? isMigraine;

  factory Headache.fromJson(Map<String, dynamic> json) => Headache(
    id: json["id"],
    userId: json["user_id"],
    uploadedAt: DateTime.parse(json["uploaded_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    calendarEntryAt: DateTime.parse(json["calendar_entry_at"]),
    eventType: json["event_type"],
    mobileEventDetails: List<MobileEventDetail>.from(json["mobile_event_details"].map((x) => MobileEventDetail.fromJson(x))),
    headacheList: List<dynamic>.from(json["headache_list"].map((x) => x)),
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

class MobileEventDetail {
  MobileEventDetail({
    this.id,
    this.eventId,
    this.value,
    this.questionTag,
    this.questionJson,
    this.uploadedAt,
    this.updatedAt,
  });

  int? id;
  int? eventId;
  String? value;
  String? questionTag;
  String? questionJson;
  DateTime? uploadedAt;
  DateTime? updatedAt;

  factory MobileEventDetail.fromJson(Map<String, dynamic> json) => MobileEventDetail(
    id: json["id"],
    eventId: json["event_id"],
    value: json["value"],
    questionTag: json["question_tag"],
    questionJson: json["question_json"],
    uploadedAt: DateTime.parse(json["uploaded_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "event_id": eventId,
    "value": value,
    "question_tag": questionTag,
    "question_json": questionJson,
    "uploaded_at": uploadedAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
  };
}
