import 'package:flutter/material.dart';

class SlideFromBottomPageRoute extends PageRouteBuilder {
  final Widget widget;
  final RouteSettings? routeSettings;

  SlideFromBottomPageRoute({required this.widget, this.routeSettings}) : super(
    pageBuilder: (context, animation, secondaryAnimation) => widget,
    transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child
      );
    },
    transitionDuration: Duration(milliseconds: 350),
    settings: routeSettings
  );
}