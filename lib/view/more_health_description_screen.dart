import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/MoreSection.dart';

class MoreHealthDescriptionScreen extends StatefulWidget {
  final MoreHealthDescriptionArgumentModel moreHealthDescriptionArgumentModel;

  const MoreHealthDescriptionScreen(
      {Key? key, required this.moreHealthDescriptionArgumentModel})
      : super(key: key);

  @override
  State<MoreHealthDescriptionScreen> createState() =>
      _MoreHealthDescriptionScreenState();
}

class _MoreHealthDescriptionScreenState
    extends State<MoreHealthDescriptionScreen> {
  List<MoreHealthDescriptionModel> _list = [];

  @override
  void initState() {
    super.initState();

    while (widget.moreHealthDescriptionArgumentModel
            .moreHealthDescriptionModelList.length >
        1) {
      if (widget.moreHealthDescriptionArgumentModel
          .moreHealthDescriptionModelList[0].vitalTime
          .isAtSameMomentAs(widget.moreHealthDescriptionArgumentModel
              .moreHealthDescriptionModelList[1].vitalTime)) {
        widget.moreHealthDescriptionArgumentModel.moreHealthDescriptionModelList
            .removeAt(1);
      } else {
        break;
      }
    }

    widget.moreHealthDescriptionArgumentModel.moreHealthDescriptionModelList
        .forEach((element) {
      _list.add(element.copy());
    });

    _list.forEach((element) {
      if (widget.moreHealthDescriptionArgumentModel.title == Constant.bloodOxygen) {
        if (Platform.isIOS) {
          double? vitalValue = double.tryParse(element.vitalValue);
          if (vitalValue != null) {
            vitalValue = vitalValue * 100;
            element.vitalValue = vitalValue.toInt().toString();
          }
        } else {
          double? vitalValue = double.tryParse(element.vitalValue);
          if (vitalValue != null) {
            //vitalValue = vitalValue * 100;
            element.vitalValue = vitalValue.toInt().toString();
          }
        }
      } else if (widget.moreHealthDescriptionArgumentModel.title ==
              Constant.heartRate ||
          widget.moreHealthDescriptionArgumentModel.title ==
              Constant.restingHeartRate ||
          widget.moreHealthDescriptionArgumentModel.title ==
              Constant.walkingHeartRate ||
          widget.moreHealthDescriptionArgumentModel.title ==
              Constant.heartRateVariability ||
          widget.moreHealthDescriptionArgumentModel.title ==
              Constant.exerciseTime) {
        double? vitalValue = double.tryParse(element.vitalValue);
        if (vitalValue != null) {
          element.vitalValue = vitalValue.toInt().toString();
        }
      } else if (widget.moreHealthDescriptionArgumentModel.title ==
          Constant.bodyTemperature) {
        double? celsius = double.tryParse(element.vitalValue);
        if (celsius != null) {
          double fahrenheit = (celsius * 9 / 5) + 32;

          int fractionDigits = Utils.countFractionDigits(fahrenheit);

          element.vitalValue = fractionDigits > 2
              ? fahrenheit.toStringAsFixed(2)
              : fahrenheit.toString();
        }
      } else if (widget.moreHealthDescriptionArgumentModel.title ==
          Constant.electrodermalActivity) {
        double? electrodermalActivityValue =
            double.tryParse(element.vitalValue.toString());

        if (electrodermalActivityValue != null) {
          if (Platform.isIOS) {
            electrodermalActivityValue = electrodermalActivityValue * 1e6;

            element.vitalValue = electrodermalActivityValue.toInt().toString();
          } else {
            element.vitalValue = electrodermalActivityValue.toInt().toString();
          }
        }
      } else if (widget.moreHealthDescriptionArgumentModel.title ==
          Constant.bloodPressure) {
        List<String> bloodPressureValues = element.vitalValue.split('/');
        if (bloodPressureValues.isNotEmpty) {
          String systolicBloodPressure =
              double.parse(bloodPressureValues[0]).toStringAsFixed(0) ?? '--';
          String diastolicBloodPressure =
              double.parse(bloodPressureValues[1]).toStringAsFixed(0) ?? '--';
          element.vitalValue = '$systolicBloodPressure/$diastolicBloodPressure';
        }
      }
    });
  }

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    //_list = List.generate(400, (index) => MoreHealthDescriptionModel(vitalValue: 'vitalValue', vitalUnit: 'vitalUnit', vitalTime: DateTime.now()));

    return SafeArea(
        child: Scaffold(
      body: Container(
        decoration: Constant.backgroundBoxDecoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Constant.moreBackgroundColor,
                    ),
                    child: Row(
                      children: [
                        Image(
                          width: 16,
                          height: 16,
                          image: AssetImage(Constant.leftArrow),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        CustomTextWidget(
                          text: widget.moreHealthDescriptionArgumentModel.title,
                          style: TextStyle(
                              color: Constant.locationServiceGreen,
                              fontSize: 16,
                              fontFamily: Constant.jostRegular),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Container(
                    //height: (_list.length > 11) ? 630 : 53.0 * _list.length,
                    child: RawScrollbar(
                      controller: _scrollController,
                      thickness: 1.5,
                      radius: Radius.circular(2),
                      thumbColor: Constant.locationServiceGreen,
                      thumbVisibility: true,
                      padding: EdgeInsets.only(right: 7, top: 10, bottom: 10),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _list.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.only(
                              top: (index == 0) ? 15 : 0,
                              bottom: (index == _list.length - 1) ? 15 : 0,
                              left: 15,
                              right: 15,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: (index == 0
                                    ? Radius.circular(20)
                                    : Radius.circular(0)),
                                topRight: (index == 0
                                    ? Radius.circular(20)
                                    : Radius.circular(0)),
                                bottomLeft: (index == _list.length - 1
                                    ? Radius.circular(20)
                                    : Radius.circular(0)),
                                bottomRight: (index == _list.length - 1
                                    ? Radius.circular(20)
                                    : Radius.circular(0)),
                              ),
                              color: Constant.moreBackgroundColor,
                            ),
                            child: MoreSection(
                              currentTag: Constant.healthDescription,
                              text: (_list.isNotEmpty)
                                  ? '${_list[index].vitalValue} ${_list[index].vitalUnit}'
                                  : '--',
                              moreStatus: (_list.isNotEmpty)
                                  ? '${_getDateString(_list[index].vitalTime)}, ${Utils.getTimeInAmPmFormat(_list[index].vitalTime.hour, _list[index].vitalTime.minute)}'
                                  : '--',
                              isShowDivider:
                                  (index < _list.length - 1) ? true : false,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  ///gets the date date string for a particular entry in the screen
  String _getDateString(DateTime date) {
    if (date.day == DateTime.now().day) {
      return 'Today';
    } else if (date.day ==
        DateTime.now().subtract(const Duration(days: 1)).day) {
      return 'Yesterday';
    } else {
      return Utils.getDateText(date, true);
    }
  }
}

class MoreHealthDescriptionArgumentModel {
  String title;
  List<MoreHealthDescriptionModel> moreHealthDescriptionModelList;

  MoreHealthDescriptionArgumentModel(
      {required this.title, required this.moreHealthDescriptionModelList});
}

class MoreHealthDescriptionModel {
  String vitalValue;
  String vitalUnit;
  DateTime vitalTime;
  List<String>? vitalInfo;

  MoreHealthDescriptionModel({
    required this.vitalValue,
    required this.vitalUnit,
    required this.vitalTime,
    this.vitalInfo,
  });

  MoreHealthDescriptionModel copy() {
    String strValue = vitalValue;
    if (!strValue.contains('/')) {
      double value = double.parse(strValue);

      int fractionDigits = Utils.countFractionDigits(value);

      if (fractionDigits > 2) strValue = value.toStringAsFixed(2);
    }

    return MoreHealthDescriptionModel(
        vitalValue: vitalValue,
        vitalUnit: vitalUnit,
        vitalTime: vitalTime,
        vitalInfo: vitalInfo);
  }
}
