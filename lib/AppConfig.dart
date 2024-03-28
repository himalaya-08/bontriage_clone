import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget{
  final String appTitle;
  final String buildFlavor;
  String appFlavour;
  final Widget child;

   AppConfig({required this.appTitle, required this.buildFlavor, required this.appFlavour, required this.child}) : super(child: child);

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(aspect: AppConfig);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}