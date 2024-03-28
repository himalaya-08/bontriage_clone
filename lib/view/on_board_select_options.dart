import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:mobile/models/OnBoardSelectOptionModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/sign_up_on_board_screen.dart';
import 'package:provider/provider.dart';

class OnBoardSelectOptions extends StatefulWidget {
  final List<OnBoardSelectOptionModel> selectOptionList;
  final Function(String, String) selectedAnswerCallBack;
  final String questionTag;
  final List<SelectedAnswers> selectedAnswerListData;

  const OnBoardSelectOptions(
      {Key? key,
      required this.selectOptionList,
      required this.questionTag,
      required this.selectedAnswerListData,
      required this.selectedAnswerCallBack,})
      : super(key: key);

  @override
  _OnBoardSelectOptionsState createState() => _OnBoardSelectOptionsState();
}

class _OnBoardSelectOptionsState extends State<OnBoardSelectOptions>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  String? selectedValue;
  SelectedAnswers? selectedAnswers;

  BoxDecoration _getBoxDecoration(int index) {
    if (!widget.selectOptionList[index].isSelected!) {
      return BoxDecoration(
        border: Border.all(width: 1, color: Constant.selectTextColor),
        borderRadius: BorderRadius.circular(4),
      );
    } else {
      return BoxDecoration(
          border: Border.all(width: 1, color: Constant.chatBubbleGreen),
          borderRadius: BorderRadius.circular(4),
          color: Constant.chatBubbleGreen);
    }
  }

  Color _getOptionTextColor(int index) {
    if (widget.selectOptionList[index].isSelected!) {
      return Constant.bubbleChatTextView;
    } else {
      return Constant.chatBubbleGreen;
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.selectedAnswerListData != null) {
      selectedAnswers = widget.selectedAnswerListData
          .firstWhereOrNull((model) => model.questionTag == widget.questionTag);
      if (selectedAnswers != null) {
        OnBoardSelectOptionModel? onBoardSelectOptionModelData =
            widget.selectOptionList.firstWhereOrNull((element) =>
                element.optionText!.toLowerCase() ==
                selectedAnswers!.answer!.toLowerCase());
        if (onBoardSelectOptionModelData != null) {
          onBoardSelectOptionModelData.isSelected = true;
        }

        if (widget.questionTag == 'headache.number') {
          try {
            int headacheTimesValue = int.tryParse(selectedAnswers!.answer!)!;

            if (headacheTimesValue != null) {
              for (int i = 0; i < widget.selectOptionList.length; i++) {
                OnBoardSelectOptionModel element = widget.selectOptionList[i];
                List<String> splitValue = element.optionText!.split('-');

                if (splitValue.length > 1) {
                  int? value1 = int.tryParse(splitValue[0]);
                  int? value2 = int.tryParse(splitValue[1]);
                  if (headacheTimesValue >= value1! &&
                      headacheTimesValue <= value2!) {
                    element.isSelected = true;
                    widget.selectedAnswerCallBack(
                        widget.questionTag, element.optionText!);
                    break;
                  }
                } else {
                  element.isSelected = true;
                  widget.selectedAnswerCallBack(
                      widget.questionTag, element.optionText!);
                  break;
                }
              }
            }
          } catch (e) {
            print(e);
          }
        }

        OnBoardSelectOptionModel? onBoardSelectOptionModelData1 = widget
            .selectOptionList
            .firstWhereOrNull((element) => element.isSelected!);

        if (onBoardSelectOptionModelData1 == null) {
          widget.selectedAnswerListData.removeWhere(
              (element) => element.questionTag == widget.questionTag);
        }
      }
    }

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _animationController!.forward();
  }

  @override
  void didUpdateWidget(OnBoardSelectOptions oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_animationController!.isAnimating) {
      _animationController!.reset();
      _animationController!.forward();
    }
  }

  @override
  void dispose() {
    _animationController!.dispose();
    //widget.selectedAnswerCallBack(widget.questionTag, selectedValue);
    super.dispose();
  }

  void _onOptionSelected(int index) {
    widget.selectOptionList.asMap().forEach((key, value) {
      widget.selectOptionList[key].isSelected = index == key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController!,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: Constant.chatBubbleHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Flexible(
                  child: CustomTextWidget(
                    text: Constant.selectOne,
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: Constant.jostMedium,
                        color: Constant.chatBubbleGreen.withOpacity(0.5)),
                  ),
                ),
                const SizedBox(width: 10,),
                Consumer<SignupOnboardErrorInfo>(
                  builder: (context, data, child){
                    return SizedBox(
                      width: 200,
                      child: (data.getErrorString == Constant.blankString)
                          ? const SizedBox()
                          : Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              height: 20,
                              child: Row(
                                children: [
                                  Image(
                                    image: AssetImage(Constant.warningPink),
                                    width: 17,
                                    height: 17,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: CustomTextWidget(
                                      text:
                                      data.getErrorString,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Constant.pinkTriggerColor,
                                          fontFamily: Constant.jostRegular),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              flex: 5,
              child: ListView.builder(
                itemCount: widget.selectOptionList.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedValue =
                                widget.selectOptionList[index].optionText;
                            widget.selectedAnswerCallBack(
                                widget.questionTag, selectedValue!);
                            _onOptionSelected(index);
                          });
                        },
                        child: Container(
                          decoration: _getBoxDecoration(index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: CustomTextWidget(
                              text: widget.selectOptionList[index].optionText!,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: _getOptionTextColor(index),
                                  fontFamily: Constant.jostRegular,
                                  height: 1.2),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
