// To parse this JSON data, do
//
//     final addHeadacheResponseModel = addHeadacheResponseModelFromJson(jsonString);

import 'dart:convert';

AddHeadacheResponseModel addHeadacheResponseModelFromJson(String str) => AddHeadacheResponseModel.fromJson(json.decode(str));

String addHeadacheResponseModelToJson(AddHeadacheResponseModel data) => json.encode(data.toJson());

class AddHeadacheResponseModel {
  AddHeadacheResponseModel({
    required this.id,
    required this.userId,
    required this.uploadedAt,
    required this.updatedAt,
    required this.calendarEntryAt,
    required this.eventType,
    required this.mobileEventDetails,
  });

  final int id;
  final int userId;
  final DateTime uploadedAt;
  final DateTime updatedAt;
  final DateTime calendarEntryAt;
  final String eventType;
  final List<AddHeadacheMobileEventDetail> mobileEventDetails;

  factory AddHeadacheResponseModel.fromJson(Map<String, dynamic> json) => AddHeadacheResponseModel(
    id: json["id"],
    userId: json["user_id"],
    uploadedAt: DateTime.tryParse(json["uploaded_at"])!,
    updatedAt: DateTime.tryParse(json["updated_at"])!,
    calendarEntryAt: DateTime.tryParse(json["calendar_entry_at"])!,
    eventType: json["event_type"],
    mobileEventDetails: List<AddHeadacheMobileEventDetail>.from(json["mobile_event_details"].map((x) => AddHeadacheMobileEventDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "uploaded_at": uploadedAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "calendar_entry_at": calendarEntryAt.toIso8601String(),
    "event_type": eventType,
    "mobile_event_details": List<dynamic>.from(mobileEventDetails.map((x) => x.toJson())),
  };
}

class AddHeadacheMobileEventDetail {
  AddHeadacheMobileEventDetail({
    required this.id,
    required this.eventId,
    required this.value,
    required this.questionTag,
    required this.questionJson,
    required this.uploadedAt,
    required this.updatedAt,
  });

  final int id;
  final int eventId;
  final String value;
  final String questionTag;
  final String questionJson;
  final DateTime uploadedAt;
  final DateTime updatedAt;

  factory AddHeadacheMobileEventDetail.fromJson(Map<String, dynamic> json) => AddHeadacheMobileEventDetail(
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
    "uploaded_at": uploadedAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
