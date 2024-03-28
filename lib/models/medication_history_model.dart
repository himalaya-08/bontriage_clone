// To parse this JSON data, do
//
//     final medicationHistoryModel = medicationHistoryModelFromJson(jsonString);

import 'dart:convert';

import '../util/Utils.dart';

List<MedicationHistoryModel> medicationHistoryModelFromJson(String str) => List<MedicationHistoryModel>.from(json.decode(str).map((x) => MedicationHistoryModel.fromJson(x)));

String medicationHistoryModelToJson(List<MedicationHistoryModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MedicationHistoryModel {
  int? id;
  int userId;
  String medicationName;
  String medicationTime;
  String dosage;
  String numberOfDosage;
  String formulation;
  DateTime? startDate;
  DateTime? endDate;
  String reason;
  String comments;
  bool isPreventive;
  DateTime? calenderEntryAt;
  String? title;

  MedicationHistoryModel({
    this.id,
    required this.userId,
    required this.medicationName,
    this.medicationTime = 'Bedtime',
    required this.dosage,
    required this.numberOfDosage,
    required this.formulation,
    required this.startDate,
    this.endDate,
    required this.reason,
    required this.comments,
    this.isPreventive = true,
    this.calenderEntryAt,
  });

  factory MedicationHistoryModel.fromJson(Map<String, dynamic> json) => MedicationHistoryModel(
    id: json["id"],
    userId: json["user_id"],
    medicationName: json["medication_name"],
    medicationTime: json["medication_time"],
    dosage: json["dosage"],
    numberOfDosage: json["number_of_dosage"],
    formulation: json["formulation"],
    startDate: DateTime.tryParse(json["start_date"] ?? ''),
    endDate: DateTime.tryParse(json["end_date"] ?? ''),
    reason: json["reason"],
    comments: json["comments"],
    isPreventive: json['is_preventive'],
    calenderEntryAt: DateTime.tryParse(json['calender_entry_at'] ?? ''),
  );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "id": id,
      "user_id": userId,
      "medication_name": medicationName,
      "medication_time": medicationTime,
      "dosage": dosage,
      "number_of_dosage": numberOfDosage,
      "formulation": formulation,
      "start_date": Utils.getDateTimeInUtcFormat(startDate ?? DateTime.now(), true, null),
      "end_date": (endDate != null) ? Utils.getDateTimeInUtcFormat(endDate ?? DateTime.now(), true, null) : null,
      "reason": reason,
      "comments": comments,
      "is_preventive": isPreventive,
      "calender_entry_at": (calenderEntryAt != null) ? Utils.getDateTimeInUtcFormat(calenderEntryAt ?? DateTime.now(), true, null) : null,
    };

    if (id == null)
      map.remove('id');

    return map;
  }
}
