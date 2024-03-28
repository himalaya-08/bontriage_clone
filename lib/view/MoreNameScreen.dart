import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/EmojiFilteringTextInputFormatter.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextFormFieldWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class MoreNameScreen extends StatefulWidget {
  final List<SelectedAnswers> selectedAnswerList;
  final Future<dynamic> Function(String, dynamic) openActionSheetCallback;
  const MoreNameScreen({Key? key, required this.selectedAnswerList, required this.openActionSheetCallback}): super(key: key);

  @override
  _MoreNameScreenState createState() =>
      _MoreNameScreenState();
}

class _MoreNameScreenState
    extends State<MoreNameScreen> {

  TextEditingController _textEditingController = TextEditingController();
  SelectedAnswers? _selectedAnswers;
  String? _initialNameValue;

  @override
  void initState() {
    super.initState();
    _initialNameValue = Constant.blankString;
    _selectedAnswers =
        widget.selectedAnswerList.firstWhereOrNull((element) =>
        element
            .questionTag == Constant.profileFirstNameTag);

    _textEditingController = TextEditingController();

    if (_selectedAnswers != null) {
      _initialNameValue = _selectedAnswers!.answer;
      _textEditingController.text = _initialNameValue!;
    } else {
      _selectedAnswers = SelectedAnswers(
          questionTag: Constant.profileFirstNameTag,
          answer: Constant.blankString);
      widget.selectedAnswerList.add(_selectedAnswers!);
    }
  }

  String _errorMessage = Constant.blankString;

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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery
                  .of(context)
                  .size
                  .height,
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
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
                        //Navigator.of(context).pop();
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
                                  fontFamily: Constant.jostRegular),
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
                      child: CustomTextFormFieldWidget(
                        inputFormatters: [EmojiFilteringTextInputFormatter()],
                        controller: _textEditingController,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                            color: Constant.locationServiceGreen,
                            fontSize: 15,
                            fontFamily: Constant.jostMedium),
                        cursorColor: Constant.locationServiceGreen,
                        decoration: InputDecoration(
                          hintText: Constant.nameHint,
                          hintStyle: TextStyle(
                              color: Constant.locationServiceGreen.withOpacity(
                                  0.5),
                              fontSize: 15,
                              fontFamily: Constant.jostMedium),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Constant.locationServiceGreen)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Constant.locationServiceGreen)),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5, horizontal: 0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomTextWidget(
                        text: Constant.tapToTypeYourName,
                        style: TextStyle(
                            color: Constant.locationServiceGreen,
                            fontSize: 14,
                            fontFamily: Constant.jostMedium
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Builder(
                        builder: (context) {
                          return (_errorMessage.isNotEmpty) ? Column(
                            children: [
                              const SizedBox(height: 25),
                              Container(
                                margin: EdgeInsets.only(
                                    left: 20, right: 10, top: 10),
                                child: Row(
                                  children: [
                                    Image(
                                      image:
                                      AssetImage(Constant.warningPink),
                                      width: 17,
                                      height: 17,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: CustomTextWidget(
                                        text: _errorMessage,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color:
                                            Constant.pinkTriggerColor,
                                            fontFamily:
                                            Constant.jostRegular),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 25),
                            ],
                          ) : const SizedBox();
                        }
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSaveAndExitActionSheet() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_initialNameValue != _textEditingController.text) {
      var result = await widget.openActionSheetCallback(
          Constant.saveAndExitActionSheet, null);
      if (result != null) {
        if (result == Constant.saveAndExit) {
          if (_textEditingController.text.isEmpty) {
            _errorMessage = 'Please enter a username';
          }
          else {
            _selectedAnswers!.answer = _textEditingController.text;
            Navigator.pop(context, result == Constant.saveAndExit);
          }
        }
        else {
          Navigator.pop(context, result == Constant.saveAndExit);
        }
      }
    }
    else {
      Navigator.pop(context);
    }
  }
}