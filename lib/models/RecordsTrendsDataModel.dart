// To parse this JSON data, do
//
//     final recordsTrendsDataModel = recordsTrendsDataModelFromJson(jsonString);

import 'dart:convert';
import 'package:mobile/models/HeadacheListDataModel.dart';
import 'package:mobile/models/RecordsTrendsMultipleHeadacheDataModel.dart';

RecordsTrendsDataModel recordsTrendsDataModelFromJson(String str) =>
    RecordsTrendsDataModel.fromJson(json.decode(str));

String recordsTrendsDataModelToJson(RecordsTrendsDataModel data) =>
    json.encode(data.toJson());

class RecordsTrendsDataModel {
  RecordsTrendsDataModel(
      {this.behaviors,
      this.medication,
      this.headache,
      this.triggers,
      this.headacheListModelData,
      this.recordsTrendsMultipleHeadacheDataModel});

  List<Behavior>? behaviors;
  List<Medication>? medication;
  Headache? headache;
  List<Trigger>? triggers;
  List<HeadacheListDataModel>? headacheListModelData;
  RecordsTrendsMultipleHeadacheDataModel? recordsTrendsMultipleHeadacheDataModel;

  factory RecordsTrendsDataModel.fromJson(Map<String, dynamic> json) =>
      RecordsTrendsDataModel(
        behaviors: List<Behavior>.from(
            json["behaviors"].map((x) => Behavior.fromJson(x))),
        medication: List<Medication>.from(
            json["medication"].map((x) => Medication.fromJson(x))),
        headache: Headache.fromJson(json["headache"]),
        triggers: List<Trigger>.from(
            json["triggers"].map((x) => Trigger.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "behaviors": List<dynamic>.from(behaviors!.map((x) => x.toJson())),
        "medication": List<dynamic>.from(medication!.map((x) => x.toJson())),
        "headache": headache!.toJson(),
        "triggers": List<dynamic>.from(triggers!.map((x) => x.toJson())),
      };
}

class Behavior {
  Behavior({
    this.date,
    this.data,
  });

  DateTime? date;
  List<BehaviorDatum>? data;

  factory Behavior.fromJson(Map<String, dynamic> json) => Behavior(
        date: DateTime.parse(json["date"]),
        data: List<BehaviorDatum>.from(
            json["data"].map((x) => BehaviorDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "date": date!.toIso8601String(),
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class BehaviorDatum {
  BehaviorDatum({
    this.behaviorPreexercise,
    this.behaviorPremeal,
    this.behaviorPresleep,
  });

  String? behaviorPreexercise;
  String? behaviorPremeal;
  String? behaviorPresleep;

  factory BehaviorDatum.fromJson(Map<String, dynamic> json) => BehaviorDatum(
        behaviorPreexercise: json["behavior.preexercise"] == null
            ? null
            : (json["behavior.preexercise"] is List<dynamic>
                ? json["behavior.preexercise"][0]
                : json["behavior.preexercise"]),
        behaviorPremeal: json["behavior.premeal"] == null
            ? null
            : (json["behavior.premeal"] is List<dynamic>
                ? json["behavior.premeal"][0]
                : json["behavior.premeal"]),
        behaviorPresleep: json["behavior.presleep"] == null
            ? null
            : (json["behavior.presleep"] is List<dynamic>
                ? json["behavior.presleep"][0]
                : json["behavior.presleep"]),
      );

  Map<String, dynamic> toJson() => {
        "behavior.preexercise":
            behaviorPreexercise == null ? null : behaviorPreexercise,
        "behavior.premeal": behaviorPremeal == null ? null : behaviorPremeal,
        "behavior.presleep": behaviorPresleep == null ? null : behaviorPresleep,
      };
}

class Headache {
  Headache({
    this.severity,
    this.disability,
    this.frequency,
    this.duration,
  });

  List<Ity>? severity;
  List<Ity>? disability;
  List<Ity>? frequency;
  List<Ity1>? duration;

  factory Headache.fromJson(Map<String, dynamic> json) => Headache(
        severity: List<Ity>.from(json["severity"].map((x) => Ity.fromJson(x))),
        disability:
            List<Ity>.from(json["disability"].map((x) => Ity.fromJson(x))),
        frequency:
            List<Ity>.from(json["frequency"].map((x) => Ity.fromJson(x))),
        duration:
            List<Ity1>.from(json["duration"].map((x) => Ity1.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "severity": List<dynamic>.from(severity!.map((x) => x.toJson())),
        "disability": List<dynamic>.from(disability!.map((x) => x.toJson())),
        "frequency": List<dynamic>.from(frequency!.map((x) => x.toJson())),
        "duration": List<dynamic>.from(duration!.map((x) => x.toJson())),
      };
}

class Ity {
  Ity({
    this.date,
    this.value,
  });

  DateTime? date;
  double? value;

  factory Ity.fromJson(Map<String, dynamic> json) => Ity(
        date: DateTime.parse(json["date"]),
        value: double.parse(json["value"].toString()).roundToDouble(),
      );

  Map<String, dynamic> toJson() => {
        "date": date!.toIso8601String(),
        "value": value,
      };
}

class Medication {
  Medication({
    this.date,
    this.data,
  });

  DateTime? date;
  List<MedicationDatum>? data;

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        date: DateTime.parse(json["date"]),
        data: List<MedicationDatum>.from(
            json["data"].map((x) => MedicationDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "date": date!.toIso8601String(),
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class MedicationDatum {
  MedicationDatum({
    this.medication,
  });

  List<String>? medication;

  factory MedicationDatum.fromJson(Map<String, dynamic> json) =>
      MedicationDatum(
        medication: _getMedicationList(json['medication']),
      );

  Map<String, dynamic> toJson() => {
        "medication": List<dynamic>.from(medication!.map((x) => x)),
      };

  static List<String> _getMedicationList(dynamic data) {
    List<String> medicationValueList = [];
    if (data is String) {
      medicationValueList.add(data);
    } else {
      medicationValueList = List<String>.from(data.map((x) => x));
    }
    return medicationValueList;
  }
}

class Trigger {
  Trigger({
    this.date,
    this.data,
  });

  DateTime? date;
  List<TriggerDatum>? data;

  factory Trigger.fromJson(Map<String, dynamic> json) => Trigger(
        date: DateTime.parse(json["date"]),
        data: List<TriggerDatum>.from(
            json["data"].map((x) => TriggerDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "date": date!.toIso8601String(),
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class TriggerDatum {
  TriggerDatum({
    this.triggers1,
  });

  List<String>? triggers1;

  factory TriggerDatum.fromJson(Map<String, dynamic> json) => TriggerDatum(
        triggers1: (json["triggers1"] is String)
            ? [json["triggers1"]]
            : List<String>.from(json["triggers1"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "triggers1": List<dynamic>.from(triggers1!.map((x) => x)),
      };
}
class Ity1 {
  Ity1({
    this.date,
    this.value,
  });

  DateTime? date;
  double? value;

  factory Ity1.fromJson(Map<String, dynamic> json) => Ity1(
    date: DateTime.parse(json["date"]),
    value: double.parse(json["value"].toString()),
  );

  Map<String, dynamic> toJson() => {
    "date": date!.toIso8601String(),
    "value": value,
  };
}
