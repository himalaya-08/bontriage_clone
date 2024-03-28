import 'dart:convert';

List<HeadacheLogDataModel> headacheLogDataModelFromJson(String str) => List<HeadacheLogDataModel>.from(json.decode(str).map((x) => HeadacheLogDataModel.fromJson(x)));

String headacheLogDataModelToJson(List<HeadacheLogDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HeadacheLogDataModel {
  HeadacheLogDataModel({
    this.id,
    this.userId,
    this.uploadedAt,
    this.updatedAt,
    this.calendarEntryAt,
    this.eventType,
    this.mobileEventDetails,
  });

  int? id;
  int? userId;
  DateTime? uploadedAt;
  DateTime? updatedAt;
  DateTime? calendarEntryAt;
  String? eventType;
  List<MobileEventDetail>? mobileEventDetails;

  factory HeadacheLogDataModel.fromJson(Map<String, dynamic> json) => HeadacheLogDataModel(
    id: json["id"],
    userId: json["user_id"],
    uploadedAt: DateTime.parse(json["uploaded_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    calendarEntryAt: DateTime.parse(json["calendar_entry_at"]),
    eventType: json["event_type"],
    mobileEventDetails: List<MobileEventDetail>.from(json["mobile_event_details"].map((x) => MobileEventDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "uploaded_at": uploadedAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
    "calendar_entry_at": calendarEntryAt!.toIso8601String(),
    "event_type": eventType,
    "mobile_event_details": List<dynamic>.from(mobileEventDetails!.map((x) => x.toJson())),
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
