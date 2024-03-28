import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:provider/provider.dart';

import 'CustomTextWidget.dart';

class MoreSexScreen extends StatefulWidget {

  final List<SelectedAnswers> selectedAnswerList;
  final Future<dynamic> Function(String,dynamic) openActionSheetCallback;

  const MoreSexScreen({Key? key, required this.selectedAnswerList, required this.openActionSheetCallback}) : super(key: key);

  @override
  _MoreSexScreenState createState() =>
      _MoreSexScreenState();
}

class _MoreSexScreenState
    extends State<MoreSexScreen> {

  List<Values> _valuesList = [];
  SelectedAnswers? _selectedAnswers;
  String? _initialSelectedValue;
  String? _currentSelectedValue;

  @override
  void initState() {
    super.initState();

    _valuesList = [
      Values(isSelected: true, text: Constant.female),
      Values(isSelected: false, text: Constant.male),
      Values(isSelected: false, text: Constant.interSex),
      Values(isSelected: false, text: Constant.preferNotToAnswer),
    ];

    _currentSelectedValue = _valuesList[0].text;

    if(widget.selectedAnswerList != null) {
      _selectedAnswers = widget.selectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.profileSexTag);
      if(_selectedAnswers != null) {
        _valuesList[0].isSelected = false;
        Values? value = _valuesList.firstWhereOrNull((element) => element.text == _selectedAnswers!.answer);
        if (value != null) {
          _initialSelectedValue = _selectedAnswers!.answer;
          _currentSelectedValue = _selectedAnswers!.answer;
          value.isSelected = true;
        }
      } else {
        _initialSelectedValue = Constant.blankString;
        _selectedAnswers = SelectedAnswers(questionTag: Constant.profileSexTag, answer: Constant.blankString);
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
                    child: Consumer<MoreSexInfo>(
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
                                    data.updateMoreSexInfo();
                                  },
                                  child: Container(
                                    decoration: _getBoxDecoration(index),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      text: Constant.toProvideDiagnosticInfo,
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
      Navigator.pop(context);
    }
  }
}

class MoreSexInfo with ChangeNotifier {
  updateMoreSexInfo() {
    notifyListeners();
  }
}
