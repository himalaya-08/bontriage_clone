import 'package:flutter/material.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class CircleLogOptions extends StatefulWidget {
  final List<Values> logOptions;
  final bool isForMedication;
  final bool isAnySleepItemSelected;
  final String preCondition;
  final int overlayNumber;
  final Function(int) onCircleItemSelected;
  final String questionType;
  final String? currentTag;
  final Function(String, String, String, bool, int)? onDoubleTapItem;
  final List<Questions>? genericMedicationQuestionList;
  final List<Questions>? dosageTypeQuestionList;

  const CircleLogOptions({
    Key? key,
    required this.logOptions,
    this.isForMedication = false,
    this.preCondition = '',
    this.overlayNumber = 0,
    required this.onCircleItemSelected,
    this.questionType = '',
    this.currentTag,
    this.onDoubleTapItem,
    this.isAnySleepItemSelected = false,
    this.dosageTypeQuestionList,
    this.genericMedicationQuestionList,
  }) : super(key: key);

  @override
  _CircleLogOptionsState createState() => _CircleLogOptionsState();
}

class _CircleLogOptionsState extends State<CircleLogOptions> {
  @override
  Widget build(BuildContext context) {
    var appConfig = AppConfig.of(context);
    if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
      debugPrint("current_tag=${widget.currentTag == Constant.triggersTag}");
      if (widget.currentTag == Constant.logDayMedicationTag) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Wrap(
            children: _getMedicationOptions(),
            spacing: 15,
            runSpacing: 5,
          ),
        );
      } else if (widget.currentTag == Constant.headacheTypeTag) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Wrap(
            children: _getMedicationOptions(),
            spacing: 10,
            runSpacing: 5,
          ),
        );
      } else if (widget.currentTag == 'device') {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Wrap(
            children: _getMedicationOptions(),
            spacing: 10,
            runSpacing: 5,
          ),
        );
      } else {
        return Center(
          child: Container(
            height: (widget.currentTag == Constant.triggersTag) ? 50 : 90,
            child: ListView.builder(
              itemCount: widget.logOptions.length,
              scrollDirection: Axis.horizontal,
              physics: Utils.getScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(left: (index == 0) ? 15 : 0),
                  child: Visibility(
                    visible: _getVisibility(widget.logOptions[index]),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (widget.logOptions[index].text !=
                                  Constant.plusText) {
                                if (widget.questionType == 'multi') {
                                  Values value = widget.logOptions[index];
                                  if (value.isSelected) {
                                    value.isSelected = false;
                                    value.isDoubleTapped = false;
                                  } else {
                                    value.isSelected = true;
                                  }
                                } else {
                                  widget.logOptions
                                      .asMap()
                                      .forEach((key, value) {
                                    if (key == index) {
                                      if (value.isSelected) {
                                        value.isSelected = false;
                                        value.isDoubleTapped = false;
                                      } else {
                                        value.isSelected = true;
                                      }
                                    } else {
                                      value.isSelected = false;
                                      value.isDoubleTapped = false;
                                    }
                                  });
                                }
                              }
                              if (widget.onCircleItemSelected != null)
                                widget.onCircleItemSelected(index);
                            });
                          },
                          onDoubleTap: () {
                            if (widget.onDoubleTapItem != null) {
                              if (widget.logOptions[index].text !=
                                  Constant.plusText) {
                                setState(() {
                                  if (widget.questionType == 'multi') {
                                    if (widget
                                        .logOptions[index].isDoubleTapped) {
                                      widget.logOptions[index].isDoubleTapped =
                                          false;
                                    } else {
                                      widget.logOptions[index].isSelected =
                                          true;
                                      widget.logOptions[index].isDoubleTapped =
                                          true;
                                    }
                                  } else {
                                    widget.logOptions
                                        .asMap()
                                        .forEach((key, value) {
                                      if (key == index) {
                                        if (value.isDoubleTapped) {
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
                                  widget.onDoubleTapItem!(
                                      widget.currentTag!,
                                      widget.logOptions[index].text!,
                                      widget.questionType,
                                      widget.logOptions[index].isDoubleTapped,
                                      index);
                                });

                                if (widget.onCircleItemSelected != null)
                                  widget.onCircleItemSelected(index);
                                debugPrint('onDoubleTap');
                              }
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            padding: EdgeInsets.all(10),
                            width: (widget.currentTag == Constant.triggersTag)
                                ? null
                                : 80,
                            height: (widget.currentTag == Constant.triggersTag)
                                ? 40
                                : 80,
                            decoration: BoxDecoration(
                                shape:
                                    (widget.currentTag == Constant.triggersTag)
                                        ? BoxShape.rectangle
                                        : BoxShape.circle,
                                borderRadius:
                                    (widget.currentTag == Constant.triggersTag)
                                        ? BorderRadius.all(Radius.circular(20))
                                        : null,
                                border: Border.all(
                                    color: widget
                                            .logOptions[index].isDoubleTapped
                                        ? Constant
                                            .addCustomNotificationTextColor
                                        : Constant.chatBubbleGreen,
                                    width: 1.5),
                                color: (widget.logOptions[index].isSelected)
                                    ? (widget.logOptions[index].isDoubleTapped)
                                        ? Constant
                                            .addCustomNotificationTextColor
                                        : Constant.chatBubbleGreen
                                    : Colors.transparent),
                            child: Center(
                              child: SingleChildScrollView(
                                physics: Utils.getScrollPhysics(),
                                child: CustomTextWidget(
                                  text: widget.logOptions[index].text!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: (widget.logOptions[index].text ==
                                            Constant.plusText)
                                        ? 20
                                        : 12,
                                    color: (widget.logOptions[index].isSelected)
                                        ? Constant.bubbleChatTextView
                                        : Constant.locationServiceGreen,
                                    fontFamily: Constant.jostMedium,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: (widget.currentTag == Constant.triggersTag)
                              ? null
                              : 79,
                          height: 79,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Visibility(
                              visible: ((widget.isForMedication &&
                                      widget.logOptions[index].isSelected) ||
                                  (widget.logOptions[index].isSelected &&
                                      (widget.preCondition.contains(
                                          widget.logOptions[index].text!)) &&
                                      widget.isAnySleepItemSelected)),
                              child: Container(
                                width: 25,
                                height: 25,
                                child: CircleAvatar(
                                  backgroundColor:
                                      Constant.backgroundTransparentColor,
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: CustomTextWidget(
                                      text: Constant.threeDots,
                                      style: TextStyle(
                                          color: Constant.locationServiceGreen,
                                          fontSize: 10,
                                          fontFamily: Constant.jostRegular,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } else {
      return Container(
        height: 91,
        child: ListView.builder(
          itemCount: widget.logOptions.length,
          scrollDirection: Axis.horizontal,
          physics: Utils.getScrollPhysics(),
          itemBuilder: (context, index) {
            String genericMedicationName =
                _getGenericMedicationName(widget.logOptions[index].text!);
            return Padding(
              padding: EdgeInsets.only(left: (index == 0) ? 15 : 0),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (widget.logOptions[index].text !=
                            Constant.plusText) {
                          if (widget.questionType == 'multi') {
                            Values value = widget.logOptions[index];
                            if (value.isSelected) {
                              value.isSelected = false;
                              value.isDoubleTapped = false;
                            } else {
                              value.isSelected = true;
                            }
                          } else {
                            widget.logOptions.asMap().forEach((key, value) {
                              if (key == index) {
                                if (value.isSelected) {
                                  /*value.isSelected = false;
                                value.isDoubleTapped = false;*/
                                } else {
                                  value.isSelected = true;
                                }
                              } else {
                                value.isSelected = false;
                                value.isDoubleTapped = false;
                              }
                            });
                          }
                        }
                        if (widget.onCircleItemSelected != null)
                          widget.onCircleItemSelected(index);
                      });
                    },
                    onDoubleTap: () {
                      if (widget.onDoubleTapItem != null) {
                        if (widget.logOptions[index].text !=
                            Constant.plusText) {
                          setState(() {
                            if (widget.questionType == 'multi') {
                              if (widget.logOptions[index].isDoubleTapped) {
                                widget.logOptions[index].isDoubleTapped = false;
                              } else {
                                widget.logOptions[index].isSelected = true;
                                widget.logOptions[index].isDoubleTapped = true;
                              }
                            } else {
                              widget.logOptions.asMap().forEach((key, value) {
                                if (key == index) {
                                  if (value.isDoubleTapped) {
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
                            widget.onDoubleTapItem!(
                                widget.currentTag!,
                                widget.logOptions[index].text!,
                                widget.questionType,
                                widget.logOptions[index].isDoubleTapped,
                                index);
                          });

                          if (widget.onCircleItemSelected != null)
                            widget.onCircleItemSelected(index);
                          print('onDoubleTap');
                        }
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.all(10),
                      width: 83,
                      height: 83,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: widget.logOptions[index].isDoubleTapped
                                  ? Constant.addCustomNotificationTextColor
                                  : Constant.chatBubbleGreen,
                              width: 1.5),
                          color: (widget.logOptions[index].isSelected)
                              ? (widget.logOptions[index].isDoubleTapped)
                                  ? Constant.addCustomNotificationTextColor
                                  : Constant.chatBubbleGreen
                              : Colors.transparent),
                      child: Center(
                        child: SingleChildScrollView(
                          physics: Utils.getScrollPhysics(),
                          child: CustomTextWidget(
                            text: _getOptionText(widget.logOptions[index].text!,
                                genericMedicationName /*Constant.blankString*/),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: (widget.logOptions[index].text ==
                                      Constant.plusText)
                                  ? 20
                                  : 12,
                              color: (widget.logOptions[index].isSelected)
                                  ? Constant.bubbleChatTextView
                                  : Constant.locationServiceGreen,
                              fontFamily: Constant.jostMedium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Visibility(
                        visible: ((widget.isForMedication &&
                                widget.logOptions[index].isSelected) ||
                            (widget.logOptions[index].isSelected &&
                                (widget.preCondition.contains(
                                    widget.logOptions[index].text!)) &&
                                widget.isAnySleepItemSelected)),
                        child: Container(
                          width: 22,
                          height: 22,
                          child: CircleAvatar(
                            backgroundColor:
                                Constant.backgroundTransparentColor,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: CustomTextWidget(
                                text: Constant.threeDots,
                                style: TextStyle(
                                    color: Constant.locationServiceGreen,
                                    fontSize: 10,
                                    fontFamily: Constant.jostRegular,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  ///This method is used to get generic medication name
  ///[medicationName] is used to identify the generic name of medication
  String _getGenericMedicationName(String medicationName) {
    String genericMedicationName = Constant.blankString;

    if (widget.currentTag == Constant.medicationEventType) {
      if (widget.dosageTypeQuestionList != null &&
          widget.genericMedicationQuestionList != null) {
        Questions typeQuestion = Utils.getDosageTypeQuestion(
            widget.dosageTypeQuestionList!, medicationName)!;

        if (typeQuestion != null) {
          String dosageType = typeQuestion.values!.first.text!;
          Questions genericQuestion = Utils.getGenericMedicationQuestion(
              widget.genericMedicationQuestionList ?? [],
              medicationName,
              dosageType)!;

          if (genericQuestion != null)
            genericMedicationName = genericQuestion.values!.first.text!;
        }
      }
    }

    return genericMedicationName;
  }

  bool _getVisibility(Values logOption) {
    if (widget.currentTag != Constant.logDayMedicationTag)
      return true;
    else {
      if (logOption.text == Constant.plusText)
        return true;
      else
        return /*logOption.isSelected*/ true;
    }
  }

  String _getOptionText(String optionValue, String genericMedicationName) {
    if (widget.currentTag == Constant.medicationEventType) {
      if (optionValue == Constant.plusText) {
        return optionValue;
      } else {
        if (optionValue == genericMedicationName)
          return '$optionValue';
        else
          return '$optionValue [$genericMedicationName]';
      }
    } else
      return optionValue != 'PO' ? optionValue : 'Oral';
  }

  List<Widget> _getMedicationOptions() {
    debugPrint('_getMedicationOptions');
    List<Widget> widgetList = [];

    widget.logOptions.asMap().forEach((index, _) {
      Values value = widget.logOptions[index];

      widgetList.add(Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                if (value.text != Constant.plusText) {
                  if (widget.questionType == 'multi') {
                    if (value.isSelected) {
                      value.isSelected = false;
                      value.isDoubleTapped = false;
                    } else {
                      value.isSelected = true;
                    }
                  } else {
                    widget.logOptions.asMap().forEach((key, value) {
                      if (key == index) {
                        if (value.isSelected) {
                          value.isSelected = false;
                          value.isDoubleTapped = false;
                        } else {
                          value.isSelected = true;
                        }
                      } else {
                        value.isSelected = false;
                        value.isDoubleTapped = false;
                      }
                    });
                  }
                }
                if (widget.onCircleItemSelected != null)
                  widget.onCircleItemSelected(index);
              });
            },
            onDoubleTap: () {
              if (widget.onDoubleTapItem != null) {
                if (value.text != Constant.plusText) {
                  setState(() {
                    if (widget.questionType == 'multi') {
                      if (value.isDoubleTapped) {
                        value.isDoubleTapped = false;
                      } else {
                        value.isSelected = true;
                        value.isDoubleTapped = true;
                      }
                    } else {
                      widget.logOptions.asMap().forEach((key, value) {
                        if (key == index) {
                          if (value.isDoubleTapped) {
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
                    widget.onDoubleTapItem!(widget.currentTag!, value.text!,
                        widget.questionType, value.isDoubleTapped, index);
                  });

                  if (widget.onCircleItemSelected != null)
                    widget.onCircleItemSelected(index);
                  debugPrint('onDoubleTap');
                }
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: (value.text == Constant.plusText) ? 30 : 10,
                  vertical: (value.text == Constant.plusText) ? 0 : 5),
              margin: EdgeInsets.only(
                  top: widget.logOptions.length > 1 ? 10 : 0, right: 5),
              decoration: BoxDecoration(
                color: (value.isSelected)
                    ? (value.isDoubleTapped)
                        ? Constant.addCustomNotificationTextColor
                        : Constant.chatBubbleGreen
                    : Colors.transparent,
                border: Border.all(
                  color: value.isDoubleTapped
                      ? Constant.addCustomNotificationTextColor
                      : Constant.chatBubbleGreen,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: CustomTextWidget(
                text: (widget.currentTag == Constant.headacheTypeTag)
                    ? (value.text == Constant.plusText
                        ? value.text
                        : (value.isMigraine!
                            ? '${value.text} (Migraine)'
                            : '${value.text} (Headache)'))!
                    : (widget.currentTag == Constant.logDayMedicationTag
                        ? (value.text == Constant.plusText
                            ? value.text
                            : value.selectedText ?? 'null')
                        : value.text)!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: (value.text == Constant.plusText) ? 20 : 12,
                  color: (value.isSelected)
                      ? Constant.bubbleChatTextView
                      : Constant.locationServiceGreen,
                  fontFamily: Constant.jostMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Visibility(
              maintainSize: (widget.currentTag == Constant.logDayMedicationTag)
                  ? widget.logOptions.length > 1
                  : false,
              maintainAnimation:
                  (widget.currentTag == Constant.logDayMedicationTag)
                      ? widget.logOptions.length > 1
                      : false,
              maintainState: (widget.currentTag == Constant.logDayMedicationTag)
                  ? widget.logOptions.length > 1
                  : false,
              visible: (widget.currentTag == Constant.logDayMedicationTag)
                  ? value.text != Constant.plusText
                  : false,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  value.isSelected = false;
                  value.isDoubleTapped = false;

                  if (widget.onCircleItemSelected != null)
                    widget.onCircleItemSelected(index);
                },
                child: Container(
                    padding: EdgeInsets.only(left: 5, bottom: 5),
                    child: Image(
                      width: 20,
                      height: 20,
                      image: AssetImage(Constant.medicationCloseIcon),
                    )),
              ),
            ),
          ),
        ],
      ));
    });

    return widgetList;
  }
}
