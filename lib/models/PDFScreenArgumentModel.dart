import 'package:flutter/material.dart';

class PDFScreenArgumentModel {
  String base64String;
  String monthYear;
  Function(BuildContext, String, dynamic)? onPush;

  PDFScreenArgumentModel({required this.base64String, required this.monthYear, this.onPush});
}