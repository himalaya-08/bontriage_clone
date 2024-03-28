import 'package:flutter/material.dart';
import 'package:mobile/models/CompassTutorialModel.dart';
import 'package:mobile/util/TutorialsSliderDots.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomScrollBar.dart';
import 'package:mobile/view/CustomTextWidget.dart';

import 'CustomRichTextWidget.dart';

class SecondStepCompassResultTutorials extends StatefulWidget {
  final CompassTutorialModel compassTutorialModel;

  final int tutorialsIndex;

  const SecondStepCompassResultTutorials({Key? key, required this.compassTutorialModel, required this.tutorialsIndex})
      : super(key: key);

  @override
  _SecondStepCompassResultTutorialsState createState() =>
      _SecondStepCompassResultTutorialsState();
}

class _SecondStepCompassResultTutorialsState
    extends State<SecondStepCompassResultTutorials> {
  int currentPageIndex = 0;
  List<Widget>? _pageViewWidgets;

  PageController? _pageController;
  List<ScrollController>? _scrollControllerList;

  TextStyle _normalTextStyle = TextStyle(
      color: Constant.locationServiceGreen,
      fontSize: 14,
      fontFamily: Constant.jostRegular,);

  TextStyle _valueTextStyle = TextStyle(
      color: Constant.addCustomNotificationTextColor,
      fontSize: 14,
      fontFamily: Constant.jostRegular);

  Widget _getThreeDotsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TutorialsSliderDots(isActive: currentPageIndex == 0),
        TutorialsSliderDots(isActive: currentPageIndex == 1),
        TutorialsSliderDots(isActive: currentPageIndex == 2),
        TutorialsSliderDots(isActive: currentPageIndex == 3),
        TutorialsSliderDots(isActive: currentPageIndex == 4),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.tutorialsIndex);
    currentPageIndex = widget.tutorialsIndex;
  }

  @override
  Widget build(BuildContext context) {
    _initPageViewWidgetList();
    return Container(
      decoration: BoxDecoration(
        color: Constant.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.only(top: 20),
                  child: CustomTextWidget(
                    text: tutorialTitleByIndex(),
                    style: TextStyle(
                        color: Constant.chatBubbleGreen,
                        fontSize: 16,
                        fontFamily: Constant.jostMedium),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                    Constant.chatBubbleHorizontalPadding, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image(
                        image: AssetImage(Constant.closeIcon),
                        width: 22,
                        height: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 180,
            width: 250,
            child: PageView.builder(
              itemCount: _pageViewWidgets!.length,
              controller: _pageController,
              onPageChanged: (currentPage) {
                setState(() {
                  currentPageIndex = currentPage;
                });
                print(currentPage);
              },
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CustomScrollBar(
                    isAlwaysShown: true,
                    controller: _scrollControllerList![index],
                    child: SingleChildScrollView(
                      physics: Utils.getScrollPhysics(),
                      controller: _scrollControllerList![index],
                      child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: _pageViewWidgets![index],
                          )),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
              padding: EdgeInsets.only(bottom: 15),
              child: _getThreeDotsWidget())
        ],
      ),
    );
  }

  String tutorialTitleByIndex() {
    switch (currentPageIndex) {
      case 0:
        return Constant.compass;
      case 1:
        return Constant.intensity;
      case 2:
        return Constant.disability;
      case 3:
        return Constant.frequency;
      case 4:
        return Constant.duration;
    }
    return "";
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _scrollControllerList!.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  List<TextSpan> _getPreviousMonthIntensitySpan() {
    List<TextSpan> textSpanList = [];

    if(widget.compassTutorialModel.previousMonthIntensity == null) {
      textSpanList.add(
        TextSpan(
          text: '',
        ),
      );
    } else {
      textSpanList.add(
        TextSpan(
          text: ' This is ',
          style: _normalTextStyle
        ),
      );
      textSpanList.add(
        TextSpan(
          text: _getComparisonText(widget.compassTutorialModel.currentMonthIntensity, widget.compassTutorialModel.previousMonthIntensity!),
          style: _valueTextStyle,
        ),
      );
      textSpanList.add(
        TextSpan(
          text: 'from ${widget.compassTutorialModel.previousMonthIntensity} in the previous month.',
          style: _normalTextStyle
        ),
      );
    }

    return textSpanList;
  }

  List<TextSpan> _getPreviousMonthDurationSpan() {
    List<TextSpan> textSpanList = [];

    if(widget.compassTutorialModel.previousMonthDuration == null) {
      textSpanList.add(
        TextSpan(
          text: '',
        ),
      );
    } else {
      textSpanList.add(
        TextSpan(
            text: ' This is ',
            style: _normalTextStyle
        ),
      );
      textSpanList.add(
        TextSpan(
          text: _getComparisonText(widget.compassTutorialModel.currentMonthDuration, widget.compassTutorialModel.previousMonthDuration!),
          style: _valueTextStyle,
        ),
      );
      textSpanList.add(
        TextSpan(
            text: 'from ${_getDurationValue(widget.compassTutorialModel
                .previousMonthDuration!)} in the previous month.',
            style: _normalTextStyle
        ),
      );
    }

    return textSpanList;
  }

  List<TextSpan> _getPreviousMonthDisabilitySpan() {
    List<TextSpan> textSpanList = [];

    if(widget.compassTutorialModel.previousMonthIntensity == null) {
      textSpanList.add(
        TextSpan(
          text: '',
        ),
      );
    } else {
      textSpanList.add(
        TextSpan(
            text: ' This is ',
            style: _normalTextStyle
        ),
      );
      textSpanList.add(
        TextSpan(
          text: _getComparisonText(widget.compassTutorialModel.currentMonthDisability, widget.compassTutorialModel.previousMonthDisability!),
          style: _valueTextStyle,
        ),
      );
      textSpanList.add(
        TextSpan(
            text: 'from ${widget.compassTutorialModel.previousMonthDisability} in the previous month.',
            style: _normalTextStyle
        ),
      );
    }

    return textSpanList;
  }

  List<TextSpan> _getPreviousMonthFrequencySpan() {
    List<TextSpan> textSpanList = [];

    if(widget.compassTutorialModel.previousMonthIntensity == null) {
      textSpanList.add(
        TextSpan(
          text: '',
        ),
      );
    } else {
      textSpanList.add(
        TextSpan(
            text: ' This is ',
            style: _normalTextStyle
        ),
      );
      textSpanList.add(
        TextSpan(
          text: _getComparisonText(widget.compassTutorialModel.currentMonthFrequency!, widget.compassTutorialModel.previousMonthFrequency!),
          style: _valueTextStyle,
        ),
      );
      textSpanList.add(
        TextSpan(
            text: 'from ${widget.compassTutorialModel.previousMonthFrequency} times in the previous month.',
            style: _normalTextStyle
        ),
      );
    }

    return textSpanList;
  }

  String _getComparisonText(int currentMonthValue, int previousMonthValue) {
    if(currentMonthValue == previousMonthValue) {
      return 'Same ';
    } else if (previousMonthValue < currentMonthValue) {
      return 'Up ';
    } else {
      return 'Down ';
    }
  }

  String _getFrequencyScale() {
    if(widget.compassTutorialModel.isFromOnBoard) {
      return 'scale of 0-${Utils.daysInCurrentMonth(widget.compassTutorialModel.currentDateTime!.month, widget.compassTutorialModel.currentDateTime!.year)} days.';
    } else {
      return 'number of times headache occurred in a month.';
    }
  }

  String _getFrequencyUnit() {
    if(widget.compassTutorialModel.isFromOnBoard) {
      return 'days';
    } else {
      return 'times';
    }
  }

  String _getDurationValue(int currentMonthDuration) {
    String duration = '';

    if(currentMonthDuration > 72) {
      int days = currentMonthDuration ~/ 24;
      int hours = currentMonthDuration % 24;

      if(days == 1) {
        if(hours == 1) {
          duration = '$days day $hours hour';
        } else {
          duration = '$days day $hours hours';
        }
      } else {
        if(hours == 1) {
          duration = '$days days $hours hour';
        } else {
          duration = '$days days $hours hours';
        }
      }
    } else {
      if(currentMonthDuration == 1) {
        duration = '$currentMonthDuration hour';
      } else {
        duration = '$currentMonthDuration hours';
      }
    }

    return duration;
  }

  void _initPageViewWidgetList() {
    if(_pageViewWidgets == null) {
      _pageViewWidgets = [
        CustomTextWidget(
          text: Constant.compassTextView,
          textAlign: TextAlign.center,
          style: _normalTextStyle,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomRichTextWidget(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Intensity is defined as how much pain you experience with each headache. It is measured on a ',
                    style: _normalTextStyle,
                  ),
                  TextSpan(
                    text: 'scale of 1-10.',
                    style: _valueTextStyle,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            CustomRichTextWidget(
              textAlign: TextAlign.center,
              text: TextSpan(
                  children: [
                    TextSpan(
                        text: 'Your average intensity in ${Utils.getMonthName(
                            widget.compassTutorialModel.currentDateTime
                                !.month)} was ',
                        style: _normalTextStyle
                    ),
                    TextSpan(
                      text: '${widget.compassTutorialModel
                          .currentMonthIntensity}.',
                      style: _valueTextStyle,
                    ),
                    TextSpan(
                        children: _getPreviousMonthIntensitySpan()
                    ),
                  ]
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomRichTextWidget(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: 'Disability is defined by how much your headache prevents you from doing the things you normally do. It is measured on a ',
                      style: _normalTextStyle
                  ),
                  TextSpan(
                    text: 'scale of 0-4.',
                    style: _valueTextStyle,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            CustomRichTextWidget(
              textAlign: TextAlign.center,
              text: TextSpan(
                  children: [
                    TextSpan(
                        text: 'Your average disability in ${Utils.getMonthName(
                            widget.compassTutorialModel.currentDateTime
                                !.month)} was ',
                        style: _normalTextStyle
                    ),
                    TextSpan(
                      text: '${widget.compassTutorialModel
                          .currentMonthDisability}.',
                      style: _valueTextStyle,
                    ),
                    TextSpan(
                        children: _getPreviousMonthDisabilitySpan()
                    ),
                  ]
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomRichTextWidget(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: 'Frequency is defined by how many headaches you experience per month. It is measured on a ',
                      style: _normalTextStyle
                  ),
                  TextSpan(
                    text: _getFrequencyScale(),
                    style: _valueTextStyle,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            CustomRichTextWidget(
              textAlign: TextAlign.center,
              text: TextSpan(
                  children: [
                    TextSpan(
                        text: 'Your average frequency in ${Utils.getMonthName(
                            widget.compassTutorialModel.currentDateTime
                                !.month)} was ',
                        style: _normalTextStyle
                    ),
                    TextSpan(
                      text: '${widget.compassTutorialModel
                          .currentMonthFrequency} ${_getFrequencyUnit()}.',
                      style: _valueTextStyle,
                    ),
                    TextSpan(
                        children: _getPreviousMonthFrequencySpan()
                    ),
                  ]
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomRichTextWidget(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: 'Duration refers to how long your headache persists. It is measured on a ',
                      style: _normalTextStyle
                  ),
                  TextSpan(
                    text: 'scale of hours.',
                    style: _valueTextStyle,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            CustomRichTextWidget(
              textAlign: TextAlign.center,
              text: TextSpan(
                  children: [
                    TextSpan(
                        text: 'Your average duration in ${Utils.getMonthName(
                            widget.compassTutorialModel.currentDateTime
                                !.month)} was ',
                        style: _normalTextStyle
                    ),
                    TextSpan(
                      text: _getDurationValue(widget.compassTutorialModel
                          .currentMonthDuration) /*'${widget.compassTutorialModel.currentMonthDuration} hours.'*/,
                      style: _valueTextStyle,
                    ),
                    TextSpan(
                        children: _getPreviousMonthDurationSpan()
                    ),
                  ]
              ),
            ),
          ],
        ),
      ];
      _scrollControllerList =
          List.generate(_pageViewWidgets!.length, (index) => ScrollController());
    }
  }
}
