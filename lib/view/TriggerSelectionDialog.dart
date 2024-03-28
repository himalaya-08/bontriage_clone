import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/util/constant.dart';

import 'CustomTextWidget.dart';

class TriggerSelectionDialog extends StatefulWidget {
  final int maxTrigger;

  const TriggerSelectionDialog({Key? key, this.maxTrigger = 0}) : super(key: key);

  @override
  _TriggerSelectionDialogState createState() => _TriggerSelectionDialogState();
}

class _TriggerSelectionDialogState extends State<TriggerSelectionDialog> {
  List<TriggerDialogModel> _triggerList = [];
  Timer? _timer;
  double? _totalTime;

  @override
  void initState() {
    super.initState();

    _totalTime = 0;

    _triggerList.add(TriggerDialogModel(
        triggerName: 'Dehydration', color: Colors.blue, isSelected: true));
    _triggerList.add(TriggerDialogModel(
        triggerName: 'Poor Sleep', color: Colors.red, isSelected: true));
    _triggerList.add(TriggerDialogModel(
        triggerName: 'Stress', color: Colors.purple, isSelected: true));
    _triggerList.add(TriggerDialogModel(
        triggerName: 'Menstruation', color: Colors.blue, isSelected: false));
    _triggerList.add(TriggerDialogModel(
        triggerName: 'High Humidity', color: Colors.red, isSelected: false));
    _triggerList.add(TriggerDialogModel(
        triggerName: 'Caffeine', color: Colors.blue, isSelected: false));

    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      if(_totalTime != null) _totalTime = _totalTime! + 2;

      setState(() {
        if (_totalTime! % 4 == 0) {
          _triggerList[4].isSelected = false;
          _triggerList[1].isSelected = true;
        } else {
          _triggerList[1].isSelected = false;
          _triggerList[4].isSelected = true;
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            decoration: BoxDecoration(
              color: Constant.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image(
                        image: AssetImage(Constant.closeIcon),
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: CustomTextWidget(
                      text: Constant.multipleTriggers,
                      style: TextStyle(
                          color: Constant.chatBubbleGreen,
                          fontSize: 16,
                          fontFamily: Constant.jostRegular),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: CustomTextWidget(
                      text: 'You can only select up to ${widget.maxTrigger} triggers at a time. In order to look at different triggers, please unselect one or more of the active triggers before selecting new ones.',
                      style: TextStyle(
                          color: Constant.locationServiceGreen,
                          fontSize: 14,
                          fontFamily: Constant.jostRegular),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: Wrap(
                      children: _getChipWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _getChipWidget() {
    List<Widget> widgetList = [];
    _triggerList.forEach((element) {
      widgetList.add(AnimatedCrossFade(
        duration: Duration(milliseconds: 250),
        firstChild: Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Constant.chatBubbleGreen, width: 1),
              color: Constant.chatBubbleGreen),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                    color: element.color),
              ),
              SizedBox(
                width: 3,
              ),
              CustomTextWidget(
                text: element.triggerName,
                style: TextStyle(
                    fontSize: 10,
                    color: Constant.bubbleChatTextView,
                    fontFamily: Constant.jostRegular),
              ),
            ],
          ),
        ),
        secondChild: Container(
          margin: EdgeInsets.only(right: 10, bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Constant.chatBubbleGreen, width: 1),
          ),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: CustomTextWidget(
            text: element.triggerName,
            style: TextStyle(
                fontSize: 10,
                color: Constant.locationServiceGreen,
                fontFamily: Constant.jostRegular),
          ),
        ),
        crossFadeState: element.isSelected
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
      ));
      /*if(element.isSelected) {
        widgetList.add(Container(
          margin: EdgeInsets.only(right: 10, bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Constant.chatBubbleGreen,
                width: 1
            ),
            color: Constant.chatBubbleGreen
          ),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: element.color
                ),
              ),
              SizedBox(width: 3,),
              CustomTextWidget(
                text: element.triggerName,
                style: TextStyle(
                    fontSize: 12,
                    color: Constant.bubbleChatTextView,
                    fontFamily: Constant.jostRegular
                ),
              ),
            ],
          ),
        ));
      } else {
        widgetList.add(Container(
          margin: EdgeInsets.only(right: 10, bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Constant.chatBubbleGreen,
              width: 1
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: CustomTextWidget(
            text: element.triggerName,
            style: TextStyle(
              fontSize: 12,
              color: Constant.locationServiceGreen,
              fontFamily: Constant.jostRegular
            ),
          ),
        ));
      }*/
    });
    return widgetList;
  }
}

class TriggerDialogModel {
  String triggerName;
  Color color;
  bool isSelected;

  TriggerDialogModel({required this.triggerName, required this.color, required this.isSelected});
}
