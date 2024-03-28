import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/sign_up_on_board_screen.dart';
import 'package:provider/provider.dart';

class OnBoardMultiSelectOptions extends StatefulWidget {
  final List<Values> selectOptionList;
  final Function(String, String) selectedAnswerCallBack;
  final String questionTag;
  final List<SelectedAnswers> selectedAnswerListData;

  const OnBoardMultiSelectOptions(
      {Key? key,
        required this.selectOptionList,
        required this.questionTag,
        required this.selectedAnswerListData,
        required this.selectedAnswerCallBack})
      : super(key: key);

  @override
  _OnBoardMultiSelectOptionsState createState() => _OnBoardMultiSelectOptionsState();
}

class _OnBoardMultiSelectOptionsState extends State<OnBoardMultiSelectOptions>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  String? selectedValue;
  SelectedAnswers? selectedAnswers;
  List<String> _valuesSelectedList = [];

  BoxDecoration _getBoxDecoration(int index) {
    if (!widget.selectOptionList[index].isSelected) {
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
    if (widget.selectOptionList[index].isSelected) {
      return Constant.bubbleChatTextView;
    } else {
      return Constant.chatBubbleGreen;
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.selectedAnswerListData != null) {
      selectedAnswers = widget.selectedAnswerListData.firstWhereOrNull(
              (model) => model.questionTag == widget.questionTag);
      if (selectedAnswers != null) {
        try {
          var decodeJson = jsonDecode(selectedAnswers?.answer ?? '');
          _valuesSelectedList = (decodeJson as List<dynamic>).cast<String>();

          _valuesSelectedList.forEach((element) {
            Values? value = widget.selectOptionList.firstWhereOrNull((valueElement) => valueElement.text == element);

            if (value != null)
              value.isSelected = true;
            else {
              debugPrint('NewElementAdding1?????ValueStart$element????ValueEnd');
              widget.selectOptionList.add(Values(valueNumber: (widget.selectOptionList.length + 1).toString(), text: element, isSelected: true));
            }
          });
        } on FormatException {
          _valuesSelectedList.add(selectedAnswers?.answer ?? '');
          _valuesSelectedList.forEach((element) {
            Values? value = widget.selectOptionList.firstWhereOrNull((valueElement) => valueElement.text == element);

            if (value != null)
              value.isSelected = true;
            else {
              debugPrint('NewElementAdding2?????ValueStart$element????ValueEnd');
              widget.selectOptionList.add(Values(
                  valueNumber: (widget.selectOptionList.length + 1).toString(),
                  text: element,
                  isSelected: true));
            }
          });

          widget.selectedAnswerCallBack(widget.questionTag, jsonEncode(_valuesSelectedList));
        } catch (e) {
          print(e.toString());
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
  void didUpdateWidget(OnBoardMultiSelectOptions oldWidget) {
    super.didUpdateWidget(oldWidget);

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

  void _onOptionSelected(int index) {
    widget.selectOptionList[index].isSelected = !widget.selectOptionList[index].isSelected;
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
                CustomTextWidget(
                  text: Constant.selectAllThatApply,
                  style: TextStyle(
                      fontSize: 13,
                      fontFamily: Constant.jostMedium,
                      color: Constant.chatBubbleGreen.withOpacity(0.5)),
                ),
                const SizedBox(width: 10,),
                Consumer<SignupOnboardErrorInfo>(
                  builder: (context, data, child){
                    return Flexible(
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
                            bool isSelected = widget.selectOptionList[index].isSelected;
                            bool isValid = widget.selectOptionList[index].isValid!;
                            if(!isValid && !isSelected) {
                              widget.selectOptionList.forEach((element) {
                                element.isSelected = false;
                              });
                              widget.selectOptionList[index].isSelected = true;
                              _valuesSelectedList.clear();
                            } else {
                              Values? noneOfTheAboveOption = widget.selectOptionList.firstWhereOrNull((element) => !element.isValid!);
                              if(noneOfTheAboveOption != null)
                                noneOfTheAboveOption.isSelected = false;

                              _valuesSelectedList.removeWhere((element) => element == (noneOfTheAboveOption == null ? '' : noneOfTheAboveOption.text));
                              _onOptionSelected(index);
                            }

                            if (widget.selectOptionList[index].isSelected) {
                              _valuesSelectedList.add(
                                  widget.selectOptionList[index].text!);
                            } else {
                              _valuesSelectedList.remove(
                                  widget.selectOptionList[index].text);
                            }

                            widget.selectedAnswerCallBack(widget.questionTag, jsonEncode(_valuesSelectedList));
                          });
                        },
                        child: Container(
                          decoration: _getBoxDecoration(index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: CustomTextWidget(
                              text: widget.selectOptionList[index].text!,
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
