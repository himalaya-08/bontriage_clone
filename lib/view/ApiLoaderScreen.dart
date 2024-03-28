import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/util/RadarChart.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class ApiLoaderScreen extends StatefulWidget {
  @override
  _ApiLoaderScreenState createState() => _ApiLoaderScreenState();
}

class _ApiLoaderScreenState extends State<ApiLoaderScreen> {

  bool darkMode = false;
  double numberOfFeatures = 4;
  double sliderValue = 1;
  int startingValue = 1;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _timer = Timer.periodic(Duration(milliseconds: 1200), (Timer t) {
        if (startingValue == 1) {
          startingValue = 2;
          setState(() {
            sliderValue = 2;
            // numberOfFeatures = 4;
          });
        } else if (startingValue == 2) {
          sliderValue = 3;
          startingValue = 3;
          setState(() {
            //sliderValue = 3;
            // numberOfFeatures = 4;
          });
        } else if (startingValue == 3) {
          sliderValue = 4;
          startingValue = 4;
          setState(() {
            //  sliderValue = 4;
            // numberOfFeatures = 4;
          });
        } else if (startingValue == 4) {
          sliderValue = 5;
          startingValue = 5;
          setState(() {
            // sliderValue = 5;
            // numberOfFeatures = 4;
          });
        } else {
          setState(() {
            sliderValue = 1;
            startingValue = 1;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<int> ticks = [7, 14, 21, 28, 35];
    List<String> features = [
      "A",
      "B",
      "C",
      "D",
    ];
    List<List<int>> data = [
      [7, 7, 7, 7],
      [9, 10, 12, 14]
    ];

    List<List<int>> data1 = [
      [7, 10, 17, 27],
      [9, 15, 19, 23]
    ];

    List<List<int>> data2 = [
      [7, 14, 30, 7],
      [9, 10, 12, 14]
    ];

    List<List<int>> data3 = [
      [7, 17, 27, 7],
      [9, 10, 12, 14]
    ];

    features = features.sublist(0, numberOfFeatures.floor());
    if (sliderValue.round() == 1) {
      data = data
          .map((graph) => graph.sublist(0, numberOfFeatures.floor()))
          .toList();
    } else if (sliderValue.round() == 2) {
      data1 = data1
          .map((graph) => graph.sublist(0, numberOfFeatures.floor()))
          .toList();
      data = data1;
    } else if (sliderValue.round() == 3) {
      data2 = data2
          .map((graph) => graph.sublist(0, numberOfFeatures.floor()))
          .toList();
      data = data2;
    } else if (sliderValue.round() == 4) {
      data3 = data3
          .map((graph) => graph.sublist(0, numberOfFeatures.floor()))
          .toList();
      data = data3;
    } else if (sliderValue.round() == 5) {
      data = data
          .map((graph) => graph.sublist(0, numberOfFeatures.floor()))
          .toList();
    }

    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 70,
                height: 70,
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        child: RadarChart.light(
                          ticks: ticks,
                          features: features,
                          data: data,
                          reverseAxis: true,
                          compassValue: 0,
                          axisColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            CustomTextWidget(
              text: Constant.loading,
              style: TextStyle(
                fontFamily: Constant.jostRegular,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Constant.chatBubbleGreen
              ),
            ),
          ],
        ),
      );
  }
}
