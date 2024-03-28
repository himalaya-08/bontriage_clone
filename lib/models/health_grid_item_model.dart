import 'package:flutter/material.dart';

class HealthGridItemModel {
  Image icon;
  String title;
  String value;
  String unit;
  String averageValue;
  DateTime? dateFrom;

  HealthGridItemModel({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.averageValue,
    required this.dateFrom
  });
}