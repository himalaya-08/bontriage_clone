import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:collection/collection.dart';
import 'package:mobile/view/sign_up_on_board_screen.dart';
import 'package:provider/provider.dart';

import 'BottomSheetContainer.dart';

class SignUpBottomSheet extends StatefulWidget {
  final Questions question;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Future<dynamic> Function(Questions, List<String>) selectAnswerCallback;
  final List<SelectedAnswers>? selectAnswerListData;
  final bool isFromMoreScreen;
  final Function(Questions, Function(int))? openTriggerMedicationActionSheetCallback;
  final bool isFromOnboard;

  SignUpBottomSheet(
      {Key? key, required this.question, required this.selectAnswerCallback, required this.selectAnswerListData, this.isFromMoreScreen = false, this.openTriggerMedicationActionSheetCallback, required this.isFromOnboard})
      : super(key: key);

  @override
  _SignUpBottomSheetState createState() => _SignUpBottomSheetState();
}

class _SignUpBottomSheetState extends State<SignUpBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  List<String> _valuesSelectedList = [];
  late ScrollController _scrollController;
  GlobalKey _chipsKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _animationController.forward();

    if (widget.selectAnswerListData != null) {
      SelectedAnswers? selectedAnswers = widget.selectAnswerListData?.firstWhereOrNull((
          element) => element.questionTag == widget.question.tag);

      if (selectedAnswers != null) {
        try {
          _valuesSelectedList =
              (jsonDecode(selectedAnswers.answer!) as List<dynamic>).cast<
                  String>();
          _valuesSelectedList = _valuesSelectedList.toList();
          _valuesSelectedList.forEach((element) {
            Values? value = widget.question.values?.firstWhereOrNull((
                valueElement) => valueElement.text == element);

            if (value != null) {
              value.isSelected = true;
            }
            else
              widget.question.values!.add(Values(text: element,
                  isSelected: true,
                  isNewlyAdded: true,
                  valueNumber: (widget.question.values!.length + 1).toString()));
          });
        } catch (e) {
          print(e.toString());
        }
      }
    }
  }

  @override
  void didUpdateWidget(SignUpBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_animationController.isAnimating) {
      _animationController.reset();
      _animationController.forward();
    }

    if(widget.isFromMoreScreen) {

      if (widget.selectAnswerListData != null) {
        SelectedAnswers? selectedAnswers = widget.selectAnswerListData?.firstWhereOrNull((
            element) => element.questionTag == widget.question.tag);

        if (selectedAnswers != null) {
          try {
            _valuesSelectedList =
                (jsonDecode(selectedAnswers.answer!) as List<dynamic>).cast<
                    String>();
            _valuesSelectedList.forEach((element) {
              Values? value = widget.question.values?.firstWhereOrNull((
                  valueElement) => valueElement.text == element);

              if (value != null) {
                value.isSelected = true;
              }
              else {
                print('adding here 2');
                widget.question.values!.add(Values(text: element,
                    isSelected: true,
                    isNewlyAdded: true,
                    valueNumber: (widget.question.values!.length + 1).toString()));
              }
            });
          } catch (e) {
            print(e.toString());
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    widget.question.values!.removeWhere((element) => element.isNewlyAdded);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: (widget.isFromOnboard) ? Consumer<SignupOnboardErrorInfo>(
        builder: (context, data, child){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 100),
                child: Container(
                  key: _chipsKey,
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  child: AnimatedSize(
                    //vsync: this,
                    duration: Duration(milliseconds: 350),
                    child: RawScrollbar(
                      controller: _scrollController,
                      thickness: 2,
                      radius: Radius.circular(2),
                      thumbColor: Constant.locationServiceGreen,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        child: Wrap(
                          spacing: 20,
                          children: [
                            for (var i = 0; i < widget.question.values!.length; i++)
                              if (widget.question.values![i].isSelected)
                                Chip(
                                  label: CustomTextWidget(
                                    text: widget.question.values![i].text ?? '',
                                  ),
                                  backgroundColor: widget.isFromMoreScreen ? Constant.locationServiceGreen : Constant.chatBubbleGreen,
                                  deleteIcon: IconButton(
                                    icon: new Image.asset('images/cross.png'),
                                    onPressed: () {
                                      setState(() {
                                        widget.question.values![i].isSelected = false;
                                      });
                                      _valuesSelectedList.removeWhere((element) =>
                                      element == widget.question.values![i].text);
                                      widget.selectAnswerCallback(
                                          widget.question, _valuesSelectedList);
                                    },
                                  ),
                                  onDeleted: () {},
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    if(widget.isFromMoreScreen) {
                      _valuesSelectedList.forEach((element) {
                        Values? value = widget.question.values?.firstWhereOrNull((
                            valueElement) => valueElement.text == element);

                        if (value != null) {
                          value.isSelected = true;
                        }
                      });
                      Questions questions = Questions();
                      List<Values> valuesList = [];

                      widget.question.values?.forEach((element) {
                        Values v = Values(valueNumber: element.valueNumber, text: element.text, isValid: element.isValid, isNewlyAdded: element.isNewlyAdded, isSelected: element.isSelected, isDoubleTapped: element.isDoubleTapped, isMigraine: element.isMigraine);
                        valuesList.add(v);
                      });

                      questions.values = valuesList;
                      //questions.values = List<Values>.from(widget.question.values);

                      final result = await widget.openTriggerMedicationActionSheetCallback!(
                        questions, (index) {},
                      );

                      if (result != null) {
                        if (result is String && result == Constant.done) {
                          questions.values?.asMap().forEach((index, value) {
                            if (index >= widget.question.values!.length) {
                              if (value.isNewlyAdded) {
                                if (value.isSelected) {
                                  widget.question.values!.add(value);
                                  _valuesSelectedList.add(
                                      value.text ?? '');
                                } else {
                                  _valuesSelectedList.removeWhere((element) =>
                                  element == value.text);
                                }
                              }
                            } else {
                              Values v = widget.question.values![index];
                              if (value.isSelected) {
                                if(!value.isValid!) {
                                  _valuesSelectedList.clear();
                                  widget.question.values!.forEach((element) {
                                    element.isSelected = false;
                                  });
                                  v.isSelected = true;
                                } else {
                                  v.isSelected = true;
                                  Values? noneOfTheAboveValue = widget.question.values?.firstWhereOrNull((element) => !element.isValid!);
                                  if(noneOfTheAboveValue != null) {
                                    noneOfTheAboveValue.isSelected = false;
                                    _valuesSelectedList.removeWhere((element) =>
                                    element == noneOfTheAboveValue.text);
                                  }
                                }
                                _valuesSelectedList.add(
                                    value.text ?? '');
                              } else {
                                v.isSelected = false;
                                _valuesSelectedList.removeWhere((element) =>
                                element == value.text);
                              }
                            }
                            widget.selectAnswerCallback(
                                widget.question, _valuesSelectedList);
                            setState(() {});
                          });
                        }
                      }
                    }
                    else {
                      Questions questions = Questions();
                      List<Values> valuesList = [];

                      widget.question.values?.forEach((element) {
                        Values v = Values(valueNumber: element.valueNumber, text: element.text, isValid: element.isValid, isNewlyAdded: element.isNewlyAdded, isSelected: element.isSelected, isDoubleTapped: element.isDoubleTapped, isMigraine: element.isMigraine);
                        valuesList.add(v);
                      });

                      questions.values = valuesList;
                      final result = await showModalBottomSheet(
                        backgroundColor: Constant.transparentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                        ),
                        context: context,
                        builder: (context) => BottomSheetContainer(
                          question: questions,
                          isFromMoreScreen: widget.isFromMoreScreen,
                          selectedAnswerCallback: (index) {},
                        ),
                      );

                      if (result != null) {
                        if (result is String && result == Constant.done) {
                          questions.values?.asMap().forEach((index, value) {
                            if (index >= widget.question.values!.length) {
                              if (value.isNewlyAdded) {
                                if (value.isSelected) {
                                  widget.question.values?.add(value);
                                  _valuesSelectedList.add(
                                      value.text ?? '');
                                } else {
                                  _valuesSelectedList.remove(
                                      value.text);
                                }
                              }
                            } else {
                              Values v = widget.question.values![index];
                              if (value.isSelected) {
                                if(!value.isValid!) {
                                  _valuesSelectedList.clear();
                                  widget.question.values?.forEach((element) {
                                    element.isSelected = false;
                                  });
                                  v.isSelected = true;
                                } else {
                                  v.isSelected = true;
                                  Values? noneOfTheAboveValue = widget.question.values?.firstWhereOrNull((element) => !element.isValid!);
                                  if(noneOfTheAboveValue != null) {
                                    noneOfTheAboveValue.isSelected = false;
                                    _valuesSelectedList.removeWhere((element) =>
                                    element == noneOfTheAboveValue.text);
                                  }
                                }
                                _valuesSelectedList.add(
                                    value.text ?? '');
                              } else {
                                v.isSelected = false;
                                _valuesSelectedList.removeWhere((element) =>
                                element == value.text);
                              }
                            }
                            widget.selectAnswerCallback(
                                widget.question, _valuesSelectedList);
                            setState(() {});
                          });
                        }
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: CustomTextWidget(
                          text: Constant.searchYourType,
                          style: TextStyle(
                              color: Constant.selectTextColor,
                              fontSize: 14,
                              fontFamily: Constant.jostMedium),
                        ),
                      ),
                      Container(
                        child: Image(
                          image: AssetImage(widget.isFromMoreScreen ? Constant.downArrow2 : Constant.downArrow),
                          width: 16,
                          height: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: widget.isFromMoreScreen ? Constant.locationServiceGreen : Constant.chatBubbleGreen,
                thickness: 2,
                height: 10,
                indent: 30,
                endIndent: 30,
              ),
              const SizedBox(height: 10,),
              (data.getErrorString == Constant.blankString)
                  ? const SizedBox()
                  : Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                    children: [
                      const SizedBox(height: 5),
                      Container(
                        child: Row(
                          children: [
                            Image(
                              image: AssetImage(Constant.warningPink),
                              width: 17,
                              height: 17,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: CustomTextWidget(
                                text: data.getErrorString,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Constant.pinkTriggerColor,
                                    fontFamily: Constant.jostRegular),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //const SizedBox(height: 200),
                    ],
                ),
              ),
                  ),
            ],
          );
        }
      ) : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 100),
            child: Container(
              key: _chipsKey,
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: AnimatedSize(
                //vsync: this,
                duration: Duration(milliseconds: 350),
                child: RawScrollbar(
                  controller: _scrollController,
                  thickness: 2,
                  radius: Radius.circular(2),
                  thumbColor: Constant.locationServiceGreen,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: BouncingScrollPhysics(),
                    child: Wrap(
                      spacing: 20,
                      children: [
                        for (var i = 0; i < widget.question.values!.length; i++)
                          if (widget.question.values![i].isSelected)
                            Chip(
                              label: CustomTextWidget(
                                text: widget.question.values![i].text ?? '',
                              ),
                              backgroundColor: widget.isFromMoreScreen ? Constant.locationServiceGreen : Constant.chatBubbleGreen,
                              deleteIcon: IconButton(
                                icon: new Image.asset('images/cross.png'),
                                onPressed: () {
                                  setState(() {
                                    widget.question.values![i].isSelected = false;
                                  });
                                  _valuesSelectedList.removeWhere((element) =>
                                  element == widget.question.values![i].text);
                                  widget.selectAnswerCallback(
                                      widget.question, _valuesSelectedList);
                                },
                              ),
                              onDeleted: () {},
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                if(widget.isFromMoreScreen) {
                  _valuesSelectedList.forEach((element) {
                    Values? value = widget.question.values?.firstWhereOrNull((
                        valueElement) => valueElement.text == element);

                    if (value != null) {
                      value.isSelected = true;
                    }
                  });
                  Questions questions = Questions();
                  List<Values> valuesList = [];

                  widget.question.values?.forEach((element) {
                    Values v = Values(valueNumber: element.valueNumber, text: element.text, isValid: element.isValid, isNewlyAdded: element.isNewlyAdded, isSelected: element.isSelected, isDoubleTapped: element.isDoubleTapped, isMigraine: element.isMigraine);
                    valuesList.add(v);
                  });

                  questions.values = valuesList;
                  //questions.values = List<Values>.from(widget.question.values);

                  final result = await widget.openTriggerMedicationActionSheetCallback!(
                    questions, (index) {},
                  );

                  if (result != null) {
                    if (result is String && result == Constant.done) {
                      questions.values?.asMap().forEach((index, value) {
                        if (index >= widget.question.values!.length) {
                          if (value.isNewlyAdded) {
                            if (value.isSelected) {
                              widget.question.values!.add(value);
                              _valuesSelectedList.add(
                                  value.text ?? '');
                            } else {
                              _valuesSelectedList.removeWhere((element) =>
                              element == value.text);
                            }
                          }
                        } else {
                          Values v = widget.question.values![index];
                          if (value.isSelected) {
                            if(!value.isValid!) {
                              _valuesSelectedList.clear();
                              widget.question.values!.forEach((element) {
                                element.isSelected = false;
                              });
                              v.isSelected = true;
                            } else {
                              v.isSelected = true;
                              Values? noneOfTheAboveValue = widget.question.values?.firstWhereOrNull((element) => !element.isValid!);
                              if(noneOfTheAboveValue != null) {
                                noneOfTheAboveValue.isSelected = false;
                                _valuesSelectedList.removeWhere((element) =>
                                element == noneOfTheAboveValue.text);
                              }
                            }
                            _valuesSelectedList.add(
                                value.text ?? '');
                          } else {
                            v.isSelected = false;
                            _valuesSelectedList.removeWhere((element) =>
                            element == value.text);
                          }
                        }
                        widget.selectAnswerCallback(
                            widget.question, _valuesSelectedList);
                        setState(() {});
                      });
                    }
                  }
                }
                else {
                  Questions questions = Questions();
                  List<Values> valuesList = [];

                  widget.question.values?.forEach((element) {
                    Values v = Values(valueNumber: element.valueNumber, text: element.text, isValid: element.isValid, isNewlyAdded: element.isNewlyAdded, isSelected: element.isSelected, isDoubleTapped: element.isDoubleTapped, isMigraine: element.isMigraine);
                    valuesList.add(v);
                  });

                  questions.values = valuesList;
                  final result = await showModalBottomSheet(
                    backgroundColor: Constant.transparentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                    ),
                    context: context,
                    builder: (context) => BottomSheetContainer(
                      question: questions,
                      isFromMoreScreen: widget.isFromMoreScreen,
                      selectedAnswerCallback: (index) {},
                    ),
                  );

                  if (result != null) {
                    if (result is String && result == Constant.done) {
                      questions.values?.asMap().forEach((index, value) {
                        if (index >= widget.question.values!.length) {
                          if (value.isNewlyAdded) {
                            if (value.isSelected) {
                              widget.question.values?.add(value);
                              _valuesSelectedList.add(
                                  value.text ?? '');
                            } else {
                              _valuesSelectedList.remove(
                                  value.text);
                            }
                          }
                        } else {
                          Values v = widget.question.values![index];
                          if (value.isSelected) {
                            if(!value.isValid!) {
                              _valuesSelectedList.clear();
                              widget.question.values?.forEach((element) {
                                element.isSelected = false;
                              });
                              v.isSelected = true;
                            } else {
                              v.isSelected = true;
                              Values? noneOfTheAboveValue = widget.question.values?.firstWhereOrNull((element) => !element.isValid!);
                              if(noneOfTheAboveValue != null) {
                                noneOfTheAboveValue.isSelected = false;
                                _valuesSelectedList.removeWhere((element) =>
                                element == noneOfTheAboveValue.text);
                              }
                            }
                            _valuesSelectedList.add(
                                value.text ?? '');
                          } else {
                            v.isSelected = false;
                            _valuesSelectedList.removeWhere((element) =>
                            element == value.text);
                          }
                        }
                        widget.selectAnswerCallback(
                            widget.question, _valuesSelectedList);
                        setState(() {});
                      });
                    }
                  }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: CustomTextWidget(
                      text: Constant.searchYourType,
                      style: TextStyle(
                          color: Constant.selectTextColor,
                          fontSize: 14,
                          fontFamily: Constant.jostMedium),
                    ),
                  ),
                  Container(
                    child: Image(
                      image: AssetImage(widget.isFromMoreScreen ? Constant.downArrow2 : Constant.downArrow),
                      width: 16,
                      height: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: widget.isFromMoreScreen ? Constant.locationServiceGreen : Constant.chatBubbleGreen,
            thickness: 2,
            height: 10,
            indent: 30,
            endIndent: 30,
          ),
          const SizedBox(height: 10,),
        ],
      ),
    );
  }
}
