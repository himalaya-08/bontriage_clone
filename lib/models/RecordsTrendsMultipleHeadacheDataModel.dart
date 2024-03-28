// To parse this JSON data, do
//
//     final recordsTrendsMultipleHeadacheDataModel = recordsTrendsMultipleHeadacheDataModelFromJson(jsonString);

import 'dart:convert';

import 'RecordsTrendsDataModel.dart';

RecordsTrendsMultipleHeadacheDataModel recordsTrendsMultipleHeadacheDataModelFromJson(String str) => RecordsTrendsMultipleHeadacheDataModel.fromJson(json.decode(str));

String recordsTrendsMultipleHeadacheDataModelToJson(RecordsTrendsMultipleHeadacheDataModel data) => json.encode(data.toJson());

class RecordsTrendsMultipleHeadacheDataModel {
  RecordsTrendsMultipleHeadacheDataModel({
    this.headacheFirst,
    this.headacheSecond,
    this.behaviors,
    this.medication,
    this.triggers,
  });

  Headache? headacheFirst;
  Headache? headacheSecond;
  List<Behavior>? behaviors;
  List<Medication>? medication;
  List<Trigger>? triggers;

  factory RecordsTrendsMultipleHeadacheDataModel.fromJson(Map<String, dynamic> json) => RecordsTrendsMultipleHeadacheDataModel(
    headacheFirst: Headache.fromJson(json["headache_first"]),
    headacheSecond: Headache.fromJson(json["headache_second"]),
    behaviors: List<Behavior>.from(json["behaviors"].map((x) => Behavior.fromJson(x))),
    medication: List<Medication>.from(json["medication"].map((x) => Medication.fromJson(x))),
    triggers: List<Trigger>.from(json["triggers"].map((x) => Trigger.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "headache_first": headacheFirst!.toJson(),
    "headache_second": headacheSecond!.toJson(),
    "behaviors": List<dynamic>.from(behaviors!.map((x) => x.toJson())),
    "medication": List<dynamic>.from(medication!.map((x) => x.toJson())),
    "triggers": List<dynamic>.from(triggers!.map((x) => x.toJson())),
  };
}

class Headache {
  Headache({
    this.severity,
    this.duration,
    this.disability,
    this.frequency,
  });

  List<Data>? severity;
  List<Data>? duration;
  List<Data>? disability;
  List<Data>? frequency;

  factory Headache.fromJson(Map<String, dynamic> json) => Headache(
    severity: List<Data>.from(json["severity"].map((x) => Data.fromJson(x))),
    duration: List<Data>.from(json["duration"].map((x) => Data.fromJson(x))),
    disability: List<Data>.from(json["disability"].map((x) => Data.fromJson(x))),
    frequency: List<Data>.from(json["frequency"].map((x) => Data.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "severity": List<dynamic>.from(severity!.map((x) => x.toJson())),
    "duration": List<dynamic>.from(duration!.map((x) => x.toJson())),
    "disability": List<dynamic>.from(disability!.map((x) => x.toJson())),
    "frequency": List<dynamic>.from(frequency!.map((x) => x.toJson())),
  };
}

class Data {
  Data({
    this.date,
    this.value,
  });

  DateTime? date;
  double? value;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    date: DateTime.parse(json["date"]),
    value: json["value"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "date": date!.toIso8601String(),
    "value": value,
  };
}
