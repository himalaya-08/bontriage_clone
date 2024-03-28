// To parse this JSON data, do
//
//     final clinicalImpressionModel = clinicalImpressionModelFromJson(jsonString);

import 'dart:convert';

List<String> clinicalImpressionModelFromJson(String str) => List<String>.from(json.decode(str).map((x) => x));

String clinicalImpressionModelToJson(List<String> data) => json.encode(List<dynamic>.from(data.map((x) => x)));