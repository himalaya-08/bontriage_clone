import 'package:flutter/material.dart';
import 'package:mobile/util/TabNavigatorRoutes.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class DiscoverScreen extends StatefulWidget {
  final Function(BuildContext, String) onPush;

  const DiscoverScreen({Key? key, required this.onPush}) : super(key: key);
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {

  @override
  void initState() {
    super.initState();
    debugPrint('Discover Screen');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: GestureDetector(
          onTap: () {
            widget.onPush(context, TabNavigatorRoutes.moreSupportRoute);
          },
          child: CustomTextWidget(
            text: 'Demo Discover Screen',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
