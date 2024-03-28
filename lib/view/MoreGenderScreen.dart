import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:provider/provider.dart';

import 'CustomTextWidget.dart';

class MoreGenderScreen extends StatefulWidget {
  final List<SelectedAnswers> selectedAnswerList;
  final Future<dynamic> Function(String,dynamic) openActionSheetCallback;

  const MoreGenderScreen({Key? key, required this.selectedAnswerList, required this.openActionSheetCallback}) : super(key: key);
  @override
  _MoreGenderScreenState createState() =>
      _MoreGenderScreenState();
}

class _MoreGenderScreenState
    extends State<MoreGenderScreen> {

  List<Values> _valuesList = [];
  SelectedAnswers? _selectedAnswers;
  String? _initialSelectedValue;
  String? _currentSelectedValue;

  @override
  void initState() {
    super.initState();

    _valuesList = [
      Values(isSelected: false, text: Constant.woman),
      Values(isSelected: false, text: Constant.man),
      Values(isSelected: false, text: Constant.nonBinary),
      Values(isSelected: false, text: Constant.preferNotToAnswer),
    ];

    _currentSelectedValue = Constant.blankString;

    if(widget.selectedAnswerList != null) {
      _selectedAnswers = widget.selectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.profileGenderTag);
      if(_selectedAnswers != null) {
        _valuesList[0].isSelected = false;
        if (_selectedAnswers?.answer == Constant.genderNonConforming) {
          _valuesList[2].isSelected = true;
          _initialSelectedValue = _valuesList[2].text;
          _currentSelectedValue = _valuesList[2].text;
        }
        Values? genderValue = _valuesList.firstWhereOrNull((element) => element.text == _selectedAnswers!.answer);
        if (genderValue != null) {
          _initialSelectedValue = _selectedAnswers!.answer;
          _currentSelectedValue = _selectedAnswers!.answer;
          genderValue.isSelected = true;
        }
      } else {
        _initialSelectedValue = Constant.blankString;
        _selectedAnswers = SelectedAnswers(questionTag: Constant.profileGenderTag, answer: Constant.blankString);
        widget.selectedAnswerList.add(_selectedAnswers!);
      }
    }
  }

  BoxDecoration _getBoxDecoration(int index) {
    if (!_valuesList[index].isSelected) {
      return BoxDecoration(
        border: Border.all(width: 1, color: Constant.chatBubbleGreen.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      );
    } else {
      return BoxDecoration(
          border: Border.all(width: 1, color: Constant.locationServiceGreen),
          borderRadius: BorderRadius.circular(4),
          color: Constant.locationServiceGreen);
    }
  }

  Color _getOptionTextColor(int index) {
    if (_valuesList[index].isSelected) {
      return Constant.bubbleChatTextView;
    } else {
      return Constant.locationServiceGreen;
    }
  }

  void _onOptionSelected(int index) {
    _valuesList.asMap().forEach((key, value) {
      _valuesList[key].isSelected = index == key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _openSaveAndExitActionSheet();
        return false;
      },
      child: Container(
        decoration: Constant.backgroundBoxDecoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _openSaveAndExitActionSheet();
                  },
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Constant.moreBackgroundColor,
                    ),
                    child: Row(
                      children: [
                        Image(
                          width: 20,
                          height: 20,
                          image: AssetImage(Constant.leftArrow),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        CustomTextWidget(
                          text: Constant.generalProfileSettings,
                          style: TextStyle(
                              color: Constant.locationServiceGreen,
                              fontSize: 16,
                              fontFamily: Constant.jostMedium),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextWidget(
                    text: Constant.selectOne,
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: Constant.jostMedium,
                        color: Constant.editTextBoarderColor.withOpacity(0.5)),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Consumer<MoreGenderInfo>(
                      builder: (context, data, child) {
                        return ListView.builder(
                          itemCount: _valuesList.length,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _currentSelectedValue = _valuesList[index].text;
                                    _onOptionSelected(index);
                                    data.updateMoreGenderInfo();
                                  },
                                  child: Container(
                                    decoration: _getBoxDecoration(index),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: CustomTextWidget(
                                        text: _valuesList[index].text!,
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
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 40,),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomTextWidget(
                      text: Constant.selectTheGender,
                      style: TextStyle(
                          color: Constant.locationServiceGreen,
                          fontSize: 14,
                          fontFamily: Constant.jostMedium
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSaveAndExitActionSheet() async {
    if (_initialSelectedValue != null) {
      if (_initialSelectedValue != _currentSelectedValue) {
        var result = await widget.openActionSheetCallback(Constant.saveAndExitActionSheet,null);
        if (result != null) {
          if (result == Constant.saveAndExit) {
            _selectedAnswers!.answer = _currentSelectedValue!;
          }
          Navigator.pop(context, result == Constant.saveAndExit);
        }
      } else {
        Navigator.pop(context);
      }
    } else {
      if(_currentSelectedValue != null) {
        var result = await widget.openActionSheetCallback(Constant.saveAndExitActionSheet,null);
        if (result != null) {
          if (result == Constant.saveAndExit) {
            _selectedAnswers!.answer = _currentSelectedValue!;
          }
          Navigator.pop(context, result == Constant.saveAndExit);
        }
      } else
        Navigator.pop(context);
    }
  }
}

class MoreGenderInfo with ChangeNotifier {
  updateMoreGenderInfo() {
    notifyListeners();
  }
}
