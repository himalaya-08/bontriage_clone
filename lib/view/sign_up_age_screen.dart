import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class SignUpAgeScreen extends StatefulWidget {
  double? sliderValue;
  final double? sliderMinValue;
  final double? sliderMaxValue;
  final String? minText;
  final String? maxText;
  String? minTextLabel;
  String? maxTextLabel;
  final String? labelText;
  final double? horizontalPadding;
  final bool isAnimate;
  final String? currentTag;
  Function(String, String)? selectedAnswerCallBack;
  List<SelectedAnswers>? selectedAnswerListData;
  Function(String, String)? onValueChangeCallback;
  final String? uiHints;

  SignUpAgeScreen(
      {Key? key,
         this.sliderValue,
         this.sliderMinValue,
         this.sliderMaxValue,
         this.labelText,
         this.minText,
         this.maxText,
         this.minTextLabel,
         this.maxTextLabel,
        this.horizontalPadding,
        this.isAnimate = true,
         this.currentTag,
        this.selectedAnswerListData,
         this.selectedAnswerCallBack,
        this.onValueChangeCallback,
         this.uiHints})
      : super(key: key);

  @override
  _SignUpAgeScreenState createState() => _SignUpAgeScreenState();
}

class _SignUpAgeScreenState extends State<SignUpAgeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  SelectedAnswers? selectedAnswers;
  double? sliderValue;

  String _sliderText = Constant.blankString;

  String _minText = '';
  String _maxText = '';
  String _minLabel = '';
  String _maxLabel = '';
  String _label = '';

  @override
  void initState() {
    super.initState();

    sliderValue = widget.sliderValue;

    _sliderText = widget.sliderValue!.toInt().toString();

    _animationController = AnimationController(
        duration: Duration(milliseconds: widget.isAnimate ? 800 : 0),
        vsync: this);

    _animationController!.forward();

    if (widget.selectedAnswerListData != null) {
      selectedAnswers = widget.selectedAnswerListData!.firstWhereOrNull(
          (model) => model.questionTag == widget.currentTag,);
      if (selectedAnswers != null) {
        String selectedValue = selectedAnswers!.answer!;
        try {
          widget.sliderValue = double.parse(selectedValue);
          sliderValue = widget.sliderValue;
          _sliderText = widget.sliderValue!.toInt().toString();
        } catch (e) {
          e.toString();
        }
      }
    }
    if (widget.selectedAnswerCallBack != null && widget.isAnimate)
      widget.selectedAnswerCallBack!(
          widget.currentTag!, widget.sliderValue!.toInt().toString());

    _minText = widget.sliderMinValue!.toInt().toString();
    _maxText = widget.sliderMaxValue!.toInt().toString();
    _initLabelValues();
  }

  @override
  void didUpdateWidget(SignUpAgeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    _sliderText = widget.sliderValue!.toInt().toString();

    if (!_animationController!.isAnimating) {
      _animationController!.reset();
      _animationController!.forward();
    }
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController!,
      child: Container(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: (widget.horizontalPadding == null)
                    ? 15
                    : widget.horizontalPadding!),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: (widget.horizontalPadding == null) ? 0 : 15,
                ),
                Container(
                  child: Center(
                    child: Wrap(
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: Constant.sliderTrackColor,
                            inactiveTrackColor: Constant.sliderTrackColor,
                            inactiveTickMarkColor: Colors.transparent,
                            activeTickMarkColor: Colors.transparent,
                            thumbColor: Constant.chatBubbleGreen,
                            overlayColor: Constant.chatBubbleGreenTransparent,
                            trackHeight: 7,
                            valueIndicatorShape:
                                PaddleSliderValueIndicatorShape(),
                            valueIndicatorColor: Constant.chatBubbleGreenBlue,
                            valueIndicatorTextStyle: TextStyle(
                              color: Constant.chatBubbleGreen,
                              fontFamily: Constant.jostRegular,
                              fontSize: 12,
                            ),
                          ),
                          child: Slider(
                            value: widget.sliderValue!,
                            min: widget.sliderMinValue!,
                            max: widget.sliderMaxValue!,
                            /*label: _sliderText,
                            divisions: (widget.sliderMaxValue - widget.sliderMinValue).toInt(),*/
                            onChangeEnd: (age) {
                              //   if(!widget.isAnimate)
                              widget.sliderValue = age;
                              /*sliderValue = age.roundToDouble();
                              if(widget.selectedAnswerCallBack != null)
                                widget.selectedAnswerCallBack(widget.currentTag, sliderValue.ceil().toInt().toString());*/

                              if (widget.sliderMinValue == 1)
                                sliderValue = widget.sliderValue;
                              else
                                sliderValue =
                                    widget.sliderValue!.roundToDouble();

                              if (sliderValue !> widget.sliderMinValue! &&
                                  sliderValue !< (widget.sliderMinValue !+ 1)) {
                                _sliderText = sliderValue!.ceil().toString();
                              } else {
                                _sliderText = sliderValue!.toInt().toString();
                              }

                              if (widget.selectedAnswerCallBack != null)
                                widget.selectedAnswerCallBack!(
                                    widget.currentTag!, _sliderText);
                            },
                            onChanged: (double age) {
                              setState(() {
                                widget.sliderValue = age;
                                debugPrint(
                                    'BeforeRound??????${widget.sliderValue}');

                                if (widget.sliderMinValue == 1)
                                  sliderValue = widget.sliderValue;
                                else
                                  sliderValue =
                                      widget.sliderValue!.roundToDouble();

                                if (sliderValue !> widget.sliderMinValue! &&
                                    sliderValue !< (widget.sliderMinValue !+ 1)) {
                                  _sliderText = sliderValue!.ceil().toString();
                                } else {
                                  _sliderText = sliderValue!.toInt().toString();
                                }
                                debugPrint(
                                    'AfterRound??????${widget.sliderValue}');
                                if (widget.onValueChangeCallback != null)
                                  widget.onValueChangeCallback!(
                                      widget.currentTag!, _sliderText);
                              });
                            },
                          ),
                        ),
                        Stack(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomTextWidget(
                                        text: _minText,
                                        style: TextStyle(
                                          color: Constant.chatBubbleGreen,
                                          fontFamily: Constant.jostMedium,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      CustomTextWidget(
                                        text: _minLabel,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Constant.chatBubbleGreen,
                                          fontFamily: Constant.jostRegular,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      CustomTextWidget(
                                        text: _maxText,
                                        style: TextStyle(
                                          color: Constant.chatBubbleGreen,
                                          fontFamily: Constant.jostMedium,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      CustomTextWidget(
                                        text: _maxLabel,
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: Constant.chatBubbleGreen,
                                          fontFamily: Constant.jostRegular,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: widget.currentTag == Constant.disabilityTag ? 110 : 50,
                                    height: widget.currentTag == Constant.disabilityTag ? 30 : 50,
                                    decoration: widget.currentTag == Constant.disabilityTag ? BoxDecoration(
                                      color: Constant.chatBubbleGreenBlue,
                                      borderRadius: BorderRadius.circular(30),
                                    ) : BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Constant.chatBubbleGreenBlue),
                                    child: Center(
                                      child: CustomTextWidget(
                                        text: widget.currentTag == Constant.disabilityTag ? _getDisabilitySliderText(int.tryParse(_sliderText)!) : _sliderText,
                                        style: TextStyle(
                                          color: Constant.chatBubbleGreen,
                                          fontFamily: Constant.jostMedium,
                                          fontSize: widget.currentTag == Constant.disabilityTag ? 14 : 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  CustomTextWidget(
                                    text: _label,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Constant.chatBubbleGreen,
                                      fontFamily: Constant.jostMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _initLabelValues() {
    List<String> uiHintsSplitList = widget.uiHints!.split(';');
    uiHintsSplitList.forEach((uiHintsElement) {
      List<String> labelSplitList = uiHintsElement.split('=');
      if (labelSplitList.length == 2) {
        labelSplitList[1] = labelSplitList[1].replaceAll('\\n', '\n');
        switch (labelSplitList[0]) {
          case Constant.minLabel1:
            _minLabel = labelSplitList[1];
            break;
          case Constant.maxLabel1:
            _maxLabel = labelSplitList[1];
            break;
          case Constant.minLabel:
            _minLabel = labelSplitList[1];
            break;
          case Constant.maxLabel:
            _maxLabel = labelSplitList[1];
            break;
          case Constant.minText:
            _minText = labelSplitList[1];
            break;
          case Constant.maxText:
            _maxText = labelSplitList[1];
            break;
          case Constant.label:
            _label = labelSplitList[1];
            break;
        }
      }
    });
  }

  String _getDisabilitySliderText(int disabilityValue) {
    String text = Constant.blankString;
    switch(disabilityValue) {
      case 0:
        text = Constant.noneDisability;
        break;
      case 1:
        text = Constant.mildDisability;
        break;
      case 2:
        text = Constant.moderateDisability;
        break;
      case 3:
        text = Constant.severeDisability;
        break;
      case 4:
        text = Constant.bedriddenDisability;
        break;
    }
    return text;
  }
}
