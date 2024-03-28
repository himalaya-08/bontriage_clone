import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class LogDayChipList extends StatefulWidget {
  final Questions question;
  final Function(String, String, bool) onSelectCallback;

  const LogDayChipList({Key? key, required this.question, required this.onSelectCallback})
      : super(key: key);

  @override
  _LogDayChipListState createState() => _LogDayChipListState();
}

class _LogDayChipListState extends State<LogDayChipList> {

  @override
  void initState() {
    super.initState();

    if(widget.question.tag!.contains('.dosage')) {
      Values? selectedValueObj = widget.question.values!.firstWhereOrNull((element) => element.isSelected);

      if(selectedValueObj == null) {
        widget.question.values!.first.isSelected = true;

        widget.onSelectCallback(widget.question.tag!, jsonEncode(widget.question), false);
      }
    }

    widget.question.values!.forEach((element) {
      if(element.isSelected) {
        print('${widget.question.tag}????${element.text}');
      }
    });
  }

  @override
  void didUpdateWidget(covariant LogDayChipList oldWidget) {
    super.didUpdateWidget(oldWidget);

    //print('MedicationDosageTag???${widget.question.tag}');


    if(widget.question.tag!.contains('.dosage')) {
      Values? selectedValueObj = widget.question.values!.firstWhereOrNull((element) => element.isSelected);

      if(selectedValueObj == null) {
        widget.question.values!.first.isSelected = true;

        widget.onSelectCallback(widget.question.tag!, jsonEncode(widget.question), false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.question.values!.length,
      physics: Utils.getScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(left: (index == 0) ? 15 : 0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (widget.question.questionType == 'multi') {
                  if (widget.question.values![index].isSelected) {
                    widget.question.values![index].isSelected = false;
                    widget.question.values![index].isDoubleTapped = false;
                  } else {
                    if(!widget.question.values![index].isValid!) {
                      widget.question.values!.forEach((element) {
                        element.isSelected = false;
                        element.isDoubleTapped = false;
                      });
                    } else {
                      Values? inValidValue = widget.question.values!.firstWhereOrNull((element) => !element.isValid!);
                      if(inValidValue != null) {
                        inValidValue.isSelected = false;
                        inValidValue.isDoubleTapped = false;
                      }
                    }
                    widget.question.values![index].isSelected = true;
                  }
                } else {
                  widget.question.values!.asMap().forEach((key, value) {
                    if (key == index) {
                      if (!value.isSelected) {
                        value.isSelected = true;
                        //value.isDoubleTapped = false;
                      } else {
                        //value.isSelected = true;
                      }
                    } else {
                      value.isSelected = false;
                      value.isDoubleTapped = false;
                    }
                  });
                }
              });

              if (widget.onSelectCallback != null) {
                widget.onSelectCallback(
                    widget.question.tag!, jsonEncode(widget.question), true);
              }
            },
            onDoubleTap: () {
              /*setState(() {
                if(widget.question.questionType == 'multi') {
                  if(widget.question.values[index].isDoubleTapped) {
                    widget.question.values[index].isDoubleTapped = false;
                  } else {
                    widget.question.values[index].isSelected = true;
                    widget.question.values[index].isDoubleTapped = true;
                  }
                } else {
                  widget.question.values.asMap().forEach((key, value) {
                    if(key == index) {
                      if(value.isDoubleTapped) {
                        value.isDoubleTapped = false;
                      } else {
                        value.isSelected = true;
                        value.isDoubleTapped = true;
                      }
                    } else {
                      value.isSelected = false;
                      value.isDoubleTapped = false;
                    }
                  });
                }
              });*/
            },
            child: Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(
                    color: /*widget.question.values[index].isDoubleTapped ? Constant.doubleTapTextColor : Constant.chatBubbleGreen*/ Constant
                        .chatBubbleGreen,
                    width: widget.question.values![index].isDoubleTapped
                        ? /*2*/ 1
                        : 1),
                color: widget.question.values![index].isSelected
                    ? Constant.chatBubbleGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: CustomTextWidget(
                  text: widget.question.values![index].text!,
                  style: TextStyle(
                      color: widget.question.values![index].isSelected
                          ? Constant.bubbleChatTextView
                          : Constant.locationServiceGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: Constant.jostRegular),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
