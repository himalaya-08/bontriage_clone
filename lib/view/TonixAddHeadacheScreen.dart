import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/blocs/TonixAddHeadacheBloc.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/PartTwoOnBoardArgumentModel.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserAddHeadacheLogModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/TonixAddHeadacheSection.dart';
import 'package:provider/provider.dart';
import 'DiscardChangesBottomSheet.dart';
import 'NetworkErrorScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TonixAddHeadacheScreen extends StatefulWidget {
  final CurrentUserHeadacheModel? currentUserHeadacheModel;

  const TonixAddHeadacheScreen({Key? key, this.currentUserHeadacheModel})
      : super(key: key);

  @override
  _TonixAddHeadacheScreenState createState() =>
      _TonixAddHeadacheScreenState();
}

class _TonixAddHeadacheScreenState extends State<TonixAddHeadacheScreen>
    with SingleTickerProviderStateMixin {
  DateTime? _dateTime;
  TonixAddHeadacheBloc _addHeadacheLogBloc = TonixAddHeadacheBloc();
  String headacheType = Constant.blankString;
  SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel =
  SignUpOnBoardSelectedAnswersModel();

  List<List<SelectedAnswers>> _medicationSelectedAnswerList = [];

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<Questions> _addHeadacheUserListData = [];

  List<SelectedAnswers> selectedAnswers = [];

  bool _isUserHeadacheEnded = false;

  bool _isDataPopulated = false;
  bool _isFromRecordScreen = false;
  CurrentUserHeadacheModel _currentUserHeadacheModel = CurrentUserHeadacheModel();
  bool _isButtonClicked = false;

  List<Map> _selectedMedicationMapList = [];

  AnimationController? _animationController;

  List<String> _selectedHeadacheMigraineList = [];

  bool _isMedicationSelected = false;

  List<Map> _recentMedicationMapList = [];

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _animationController.reverse();
    });*/

    signUpOnBoardSelectedAnswersModel.selectedAnswers = [];

    _currentUserHeadacheModel = widget.currentUserHeadacheModel!;

    _isFromRecordScreen =
        widget.currentUserHeadacheModel!.isFromRecordScreen ?? false;

    Utils.setAnalyticsCurrentScreen(Constant.addHeadacheScreen, context);

    if(widget.currentUserHeadacheModel!.isFromRecordScreen ?? false)
      try {
        //_dateTime = DateTime.tryParse(widget.currentUserHeadacheModel.selectedDate).toLocal();
        _dateTime = DateTime.now().subtract(Duration(days: 1));
      } catch (e) {
        debugPrint(e.toString());
      }

    signUpOnBoardSelectedAnswersModel.eventType = "Headache";
    signUpOnBoardSelectedAnswersModel.selectedAnswers = [];

    _addHeadacheLogBloc = TonixAddHeadacheBloc();
    _addHeadacheLogBloc.currentUserHeadacheModel =
        widget.currentUserHeadacheModel!;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Utils.showApiLoaderDialog(context);
      requestService();
    });
  }

  @override
  void dispose() {
    _addHeadacheLogBloc.dispose();
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (signUpOnBoardSelectedAnswersModel.selectedAnswers!.length > 0)
          _showDiscardChangesBottomSheet();
        else {
          if (_isFromRecordScreen)
            Navigator.pop(context, _addHeadacheLogBloc.isHeadacheLogged);
          else
            Navigator.popUntil(
                context, ModalRoute.withName(Constant.homeRouter));
        }
        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        body: Container(
          decoration: Constant.backgroundBoxDecoration,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: SafeArea(
                child: Container(
                  margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                  decoration: BoxDecoration(
                    color: Constant.backgroundColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextWidget(
                              text:
                              '${Utils.getMonthName(_dateTime!.month)} ${_dateTime!.day}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Constant.chatBubbleGreen,
                                  fontFamily: Constant.jostMedium),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if (signUpOnBoardSelectedAnswersModel
                                    .selectedAnswers!.length >
                                    0)
                                  _showDiscardChangesBottomSheet();
                                else {
                                  if (_isFromRecordScreen)
                                    Navigator.pop(context,
                                        _addHeadacheLogBloc.isHeadacheLogged);
                                  else
                                    Navigator.popUntil(
                                        context,
                                        ModalRoute.withName(
                                            Constant.homeRouter));
                                }
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Divider(
                          height: 30,
                          thickness: 1,
                          color: Constant.chatBubbleGreen,
                        ),
                      ),
                      Container(
                        child: StreamBuilder<dynamic>(
                          stream: _addHeadacheLogBloc.addHeadacheLogDataStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (!_isDataPopulated) {
                                Utils.closeApiLoaderDialog(context);
                              }
                              return Consumer<TonixVisibilityHeadacheInfo>(
                                builder: (context, data, child) {
                                  return Column(
                                    children: [
                                      _getHeadacheTypeWidget(snapshot.data),
                                      SizeTransition(
                                        sizeFactor: _animationController!,
                                        child: Visibility(
                                          visible: data.isVisible(),
                                          child: Column(
                                            children: _getAddHeadacheSection(snapshot.data),
                                          ),
                                        ),
                                      ),
                                      _getMedicationSection(snapshot.data),
                                      /*  AddANoteWidget(
                                      selectedAnswerList: signUpOnBoardSelectedAnswersModel.selectedAnswers,
                                      scaffoldKey: scaffoldKey,
                                      noteTag: 'headache.note',
                                    ),*/
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          BouncingWidget(
                                            onPressed: () {
                                              if (!_isButtonClicked) {
                                                _isButtonClicked = true;
                                                saveDataInLocalDataBaseOrServer();
                                              }
                                            },
                                            child: Container(
                                              width: 110,
                                              padding:
                                              EdgeInsets.symmetric(vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Constant.chatBubbleGreen,
                                                borderRadius:
                                                BorderRadius.circular(30),
                                              ),
                                              child: Center(
                                                child: CustomTextWidget(
                                                  text: Constant.save,
                                                  style: TextStyle(
                                                      color: Constant
                                                          .bubbleChatTextView,
                                                      fontSize: 15,
                                                      fontFamily:
                                                      Constant.jostMedium),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          BouncingWidget(
                                            onPressed: () {
                                              if (signUpOnBoardSelectedAnswersModel
                                                  .selectedAnswers!.length >
                                                  0)
                                                _showDiscardChangesBottomSheet();
                                              else {
                                                if (_isFromRecordScreen)
                                                  Navigator.pop(
                                                      context,
                                                      _addHeadacheLogBloc
                                                          .isHeadacheLogged);
                                                else
                                                  Navigator.popUntil(
                                                      context,
                                                      ModalRoute.withName(
                                                          Constant.homeRouter));
                                              }
                                            },
                                            child: Container(
                                              width: 110,
                                              padding:
                                              EdgeInsets.symmetric(vertical: 8),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1.3,
                                                    color:
                                                    Constant.chatBubbleGreen),
                                                borderRadius:
                                                BorderRadius.circular(30),
                                              ),
                                              child: Center(
                                                child: CustomTextWidget(
                                                  text: Constant.cancel,
                                                  style: TextStyle(
                                                      color:
                                                      Constant.chatBubbleGreen,
                                                      fontSize: 15,
                                                      fontFamily:
                                                      Constant.jostMedium),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (snapshot.hasError) {
                              Utils.closeApiLoaderDialog(context);
                              return NetworkErrorScreen(
                                errorMessage: snapshot.error.toString(),
                                tapToRetryFunction: () {
                                  Utils.showApiLoaderDialog(context);
                                  requestService();
                                },
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// This method will be use for add widget from the help of ADDHeadacheSection class.
  List<Widget> _getAddHeadacheSection(List<Questions> addHeadacheListData) {
    List<Widget> listOfWidgets = [];
    _addHeadacheUserListData = addHeadacheListData;
    selectedAnswers.forEach((element) {
      Questions? questionsTag = _addHeadacheUserListData.firstWhereOrNull(
              (element1) => element1.tag == element.questionTag);
      if (questionsTag != null) {
        switch (questionsTag.questionType) {
          case Constant.singleTypeTag:
            Values? answerValuesData = questionsTag.values!.firstWhereOrNull(
                    (element1) => element1.text == element.answer);
            if (answerValuesData != null) answerValuesData.isSelected = true;
            break;
          case Constant.numberTypeTag:
            questionsTag.currentValue = element.answer;
            break;
          case Constant.dateTimeTypeTag:
            questionsTag.updatedAt = element.answer;
            break;
        }
      }
    });

    var headacheMigraineQuestion = _addHeadacheUserListData.firstWhereOrNull(
            (element) => element.tag == Constant.headacheMigraineTag);

    var headacheMigraineSelectedAnswer =
    signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull(
            (element) => element.questionTag == Constant.headacheMigraineTag);
    /*var headacheTypeSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers.firstWhere((element) => element.questionTag == Constant.headacheTypeTag, orElse: () => null);

    if(headacheTypeSelectedAnswer != null) {
      if(headacheTypeSelectedAnswer.answer == Constant.noHeadacheValue) {
        _animationController.reverse();
      } else
        _animationController.forward();
    }*/

    if (headacheMigraineSelectedAnswer != null &&
        headacheMigraineQuestion != null) {
      if(headacheMigraineSelectedAnswer.answer!.contains("%@")) {
        List<String> selectedValues = headacheMigraineSelectedAnswer.answer!.split("%@");

        selectedValues.forEach((element) {
          Values? values = headacheMigraineQuestion.values!.firstWhereOrNull(
                  (element1) => element1.text == element);
          if (values != null) values.isSelected = true;
        });

        headacheMigraineSelectedAnswer.answer = jsonEncode(selectedValues);

        headacheMigraineQuestion.values!.forEach((element) {
          if (element.text == headacheMigraineSelectedAnswer.answer)
            element.isSelected = true;
        });
      } else if (headacheMigraineSelectedAnswer.answer!.isNotEmpty) {
        List<String> selectedValues = [];

        try {
          selectedValues = List<String>.from(
              jsonDecode(headacheMigraineSelectedAnswer.answer!));
        } catch (e) {
          selectedValues = [headacheMigraineSelectedAnswer.answer!];
        }

        selectedValues.forEach((element) {
          Values? values = headacheMigraineQuestion.values!.firstWhereOrNull(
                  (element1) => element1.text == element);
          if (values != null) values.isSelected = true;
        });

        headacheMigraineSelectedAnswer.answer = jsonEncode(selectedValues);

        headacheMigraineQuestion.values!.forEach((element) {
          if (element.text == headacheMigraineSelectedAnswer.answer)
            element.isSelected = true;
        });
      }
    } else {
      if (headacheMigraineQuestion != null) {
        /*_selectedHeadacheMigraineList.forEach((element) {
          Values values = headacheMigraineQuestion.values.firstWhere(
              (element1) => element1.text == element,
              orElse: () => null);
          if (values != null) values.isSelected = true;
        });

        if (_selectedHeadacheMigraineList.isEmpty) {
          headacheMigraineQuestion.values.forEach((element) {
            element.isSelected = true;
          });
        }*/
      }
    }

    Questions? headacheIntensityQuestion = _addHeadacheUserListData.firstWhereOrNull((element) => element.tag == Constant.severityTag);

    if(headacheIntensityQuestion != null) {
      headacheIntensityQuestion.helpText = 'How painful was your headache today?';
      if(headacheIntensityQuestion.values != null) {
        if(headacheIntensityQuestion.values!.isEmpty) {
          List<Values> valuesList = [];

          /*valuesList.add(Values(valueNumber: '1', text: 'No Pain'));*/
          valuesList.add(Values(valueNumber: '1', text: 'Mild Pain'));
          valuesList.add(Values(valueNumber: '2', text: 'Moderate Pain'));
          valuesList.add(Values(valueNumber: '3', text: 'Severe Pain'));

          var intensitySelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull((element) => element.questionTag == Constant.severityTag);

          if(intensitySelectedAnswer != null) {
            Values? selectedValue = valuesList.firstWhereOrNull((element) => (int.tryParse(element.valueNumber!)) == int.tryParse(intensitySelectedAnswer.answer!));

            if (selectedValue != null)
              selectedValue.isSelected = true;
          } else {
            valuesList.first.isSelected = true;

            signUpOnBoardSelectedAnswersModel.selectedAnswers!.add(SelectedAnswers(questionTag: Constant.severityTag, answer: 1.toString()));
          }

          headacheIntensityQuestion.values = valuesList;
        }
      }
    }

    _addHeadacheUserListData.forEach((element) {
      if (!(element.tag!.contains('.dosage') ||
          element.tag == Constant.headacheMigraineTag ||
          element.tag == Constant.headacheTypeTag ||
          element.tag == Constant.logDayMedicationTag)) {
        listOfWidgets.add(TonixAddHeadacheSection(
          headerText: element.text!,
          subText: element.helpText!,
          contentType: element.tag!,
          min: element.min!.toDouble(),
          max: element.max!.toDouble(),
          valuesList: element.values!,
          updateAtValue: null,
          selectedCurrentValue: element.currentValue!,
          selectedAnswers: signUpOnBoardSelectedAnswersModel.selectedAnswers!,
          addHeadacheDetailsData: addSelectedHeadacheDetailsData,
          moveWelcomeOnBoardTwoScreen: moveOnWelcomeBoardSecondStepScreens,
          isHeadacheEnded: widget.currentUserHeadacheModel!.isOnGoing != null ? !widget.currentUserHeadacheModel!.isOnGoing! : false,
          removeHeadacheTypeData: (tag, headacheType) {
            if (signUpOnBoardSelectedAnswersModel.selectedAnswers!.length > 0) {
              signUpOnBoardSelectedAnswersModel.selectedAnswers
                  !.removeWhere((element) => element.questionTag == tag);
            }
          },
          currentUserHeadacheModel: _currentUserHeadacheModel,
          uiHints: element.uiHints!,
          dosageQuestionList: null,
          medicationSelectedAnswerList: _medicationSelectedAnswerList,
          headacheMigraineQuestion: headacheMigraineQuestion,
          dosageTypeQuestionList: null,
          genericMedicationQuestionList: null,
          recentMedicationMapList: _recentMedicationMapList,
        ));
      }
    });

    _isDataPopulated = true;
    return listOfWidgets;
  }

  /// This method will be use for to insert and update his answer in the local model. So we will save his answer on the basis of current Tag
  void addSelectedHeadacheDetailsData(String currentTag, String selectedValue) {
    SelectedAnswers? selectedAnswers;
    if (signUpOnBoardSelectedAnswersModel.selectedAnswers!.length > 0) {
      selectedAnswers = signUpOnBoardSelectedAnswersModel.selectedAnswers
          !.firstWhereOrNull((model) => model.questionTag == currentTag);
    }
    if (selectedAnswers != null) {
      selectedAnswers.answer = selectedValue;
    } else {
      signUpOnBoardSelectedAnswersModel.selectedAnswers
          !.add(SelectedAnswers(questionTag: currentTag, answer: selectedValue));
      debugPrint(signUpOnBoardSelectedAnswersModel.selectedAnswers.toString());
    }

    var visibilityHeadacheInfo = Provider.of<TonixVisibilityHeadacheInfo>(context, listen: false);

    if (selectedValue == Constant.noHeadacheValue) {
      var addHeadacheSectionSubTextInfo = Provider.of<TonixAddHeadacheSectionSubTextInfo>(context, listen: false);
      addHeadacheSectionSubTextInfo.updateAddHeadacheSectionSubTextInfo();
      _animationController!.reverse();
    } else {
      if(!visibilityHeadacheInfo.isVisible()) {
        visibilityHeadacheInfo.updateVisibilityHeadacheInfo(true, true);
        _animationController!.forward();
      } else {
        visibilityHeadacheInfo.updateVisibilityHeadacheInfo(true, false);
        _animationController!.forward();
      }
      /*if (!_isVisible) {
        setState(() {
          _isVisible = true;
        });
        _animationController.forward();
      } else
        _animationController.forward();*/
    }

    if (currentTag == "ongoing") {
      if (selectedValue == "Yes") {
        _isUserHeadacheEnded = false;
      } else {
        _isUserHeadacheEnded = true;
      }
    }
  }

  /// This method will be use for if user click Headache Plus Icon and he want to add another headache name of Add headache Screen.
  /// So we will move to the user  2nd Step of welcome OnBoard Screen in which he will add all information related to his headache.
  moveOnWelcomeBoardSecondStepScreens() async {
    final pushToScreenResult = await Navigator.pushNamed(
        context, Constant.partTwoOnBoardScreenRouter,
        arguments: PartTwoOnBoardArgumentModel(
            argumentName: Constant.clinicalImpressionEventType));
    if (pushToScreenResult != null) {
      if (_addHeadacheUserListData != null) {
        Questions? questions = _addHeadacheUserListData.firstWhereOrNull(
                (element) => element.tag == "headacheType");
        if (questions != null) {
          questions.values!.removeLast();
          Values? values = questions.values
              !.firstWhereOrNull((element) => element.isSelected);
          if (values != null) {
            values.isSelected = false;
          }
          questions.values
              !.add(Values(text: pushToScreenResult.toString(), isSelected: true));
        }

        addSelectedHeadacheDetailsData("headacheType", pushToScreenResult.toString());

        var headacheTypeInfo =
        Provider.of<TonixHeadacheTypeInfo>(context, listen: false);
        headacheTypeInfo.updateHeadacheTypeInfo();
      }
    }
    print(pushToScreenResult);
  }

  void saveDataInLocalDataBaseOrServer() async {
    SelectedAnswers? headacheTypeSelectedAnswer =
    signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull(
            (element) => element.questionTag == Constant.headacheTypeTag);
    SelectedAnswers? onGoingSelectedAnswer = signUpOnBoardSelectedAnswersModel
        .selectedAnswers
        !.firstWhereOrNull((element) => element.questionTag == Constant.onGoingTag);
    SelectedAnswers? onSetSelectedAnswer = signUpOnBoardSelectedAnswersModel
        .selectedAnswers
        !.firstWhereOrNull((element) => element.questionTag == Constant.onSetTag);
    SelectedAnswers? endTimeSelectedAnswer = signUpOnBoardSelectedAnswersModel
        .selectedAnswers
        !.firstWhereOrNull((element) => element.questionTag == Constant.endTimeTag);

    if(onSetSelectedAnswer != null && endTimeSelectedAnswer != null && endTimeSelectedAnswer.answer!.isNotEmpty)
      _addHeadacheLogBloc.checkIfHeadacheLastsForTheNextDate(onSetSelectedAnswer, endTimeSelectedAnswer, context);

    bool isTimeValidationSatisfied = true;
    String errorMessage = '';

    String timeErrorTitle = 'Start and end times cannot be the same.';

    if(headacheTypeSelectedAnswer != null) {
      if(headacheTypeSelectedAnswer.answer == Constant.noHeadacheValue) {
        DateTime currentDateTime = DateTime.now();

        if (_isFromRecordScreen)
          currentDateTime = currentDateTime.subtract(Duration(days: 1));

        if (onSetSelectedAnswer == null)
          signUpOnBoardSelectedAnswersModel.selectedAnswers!.add(SelectedAnswers(questionTag: Constant.onSetTag, answer: Utils.getDateTimeInUtcFormat(currentDateTime, true, context)));
        else
          onSetSelectedAnswer.answer = Utils.getDateTimeInUtcFormat(currentDateTime, true, context);

        if (endTimeSelectedAnswer == null)
          signUpOnBoardSelectedAnswersModel.selectedAnswers!.add(SelectedAnswers(questionTag: Constant.endTimeTag, answer: Utils.getDateTimeInUtcFormat(currentDateTime, true, context)));
        else
          endTimeSelectedAnswer.answer = Utils.getDateTimeInUtcFormat(currentDateTime, true, context);
      }
    }

    if (headacheTypeSelectedAnswer != null &&
        onGoingSelectedAnswer != null &&
        onSetSelectedAnswer != null) {
      if (headacheTypeSelectedAnswer.answer == Constant.noHeadacheValue) {
        //_medicationSelectedAnswerList.clear();
        onGoingSelectedAnswer.answer = 'No';
        if (endTimeSelectedAnswer == null)
          signUpOnBoardSelectedAnswersModel.selectedAnswers!.add(SelectedAnswers(
              questionTag: Constant.endTimeTag,
              answer: onSetSelectedAnswer.answer));
        else
          endTimeSelectedAnswer.answer = onSetSelectedAnswer.answer;

      } else {
        if (_isUserHeadacheEnded) {
          if (onSetSelectedAnswer != null && endTimeSelectedAnswer != null) {
            DateTime onSetDateTime =
            DateTime.tryParse(onSetSelectedAnswer.answer!)!.toLocal();
            DateTime endDateTime =
            DateTime.tryParse(endTimeSelectedAnswer.answer!)!.toLocal();

            debugPrint('Onset???$onSetDateTime\nEndtime???$endDateTime');

            if (onSetDateTime.isAtSameMomentAs(endDateTime)) {
              if(_currentUserHeadacheModel.isFromRecordScreen ?? false){
                errorMessage =
                'Please double-check the start and end times you\'ve entered to ensure that these are both accurate.\nIf your headache is still in progress, please reopen the app when your headache ends to record the time. We hope you feel better soon!';
              } else {
                errorMessage =
                'Please double-check the start and end times you\'ve entered to ensure that these are both accurate.\nIf your headache is still in progress, please reopen the app when your headache ends to record the time. We hope you feel better soon!';
              }
              isTimeValidationSatisfied = false;
            } else if (onSetDateTime.isAfter(endDateTime)) {
              timeErrorTitle = 'Alert!';
              errorMessage = 'Please double-check the start and end times you\'ve entered to ensure that these are both accurate.\nIf your headache is still in progress, please reopen the app when your headache ends to record the time. We hope you feel better soon!';
              isTimeValidationSatisfied = false;
            } else {
              isTimeValidationSatisfied = true;
            }
          }
        }
      }
    }

    if (headacheTypeSelectedAnswer != null) {
      if (isTimeValidationSatisfied) {
        /*if(headacheTypeSelectedAnswer.answer != Constant.noHeadacheValue && _medicationSelectedAnswerList.isEmpty) {
          Utils.showValidationErrorDialog(context, 'Please select medication.');
          _isButtonClicked = false;
        } else {
          String medicationErrorMessage;

          for (int i = 0; i < _medicationSelectedAnswerList.length; i++) {
            List<SelectedAnswers> medicationSelectedAnswerList = _medicationSelectedAnswerList[i];

            SelectedAnswers medicationSelectedAnswer = medicationSelectedAnswerList.firstWhere((element) => element.questionTag == Constant.logDayMedicationTag, orElse: () => null);
            SelectedAnswers typeSelectedAnswer = medicationSelectedAnswerList.firstWhere((element) => element.questionTag.contains('.type'), orElse: () => null);

            if (typeSelectedAnswer == null) {
              if(medicationSelectedAnswer != null)
                medicationErrorMessage = 'Please select dosage type of ${medicationSelectedAnswer.answer} medication.';
              else
                medicationErrorMessage = 'Please select dosage type of medication';

              break;
            }
          }

          if(medicationErrorMessage == null) {
            Utils.showApiLoaderDialog(
                context,
                networkStream: _addHeadacheLogBloc.sendAddHeadacheLogDataStream,
                tapToRetryFunction: () {
                  _addHeadacheLogBloc.enterSomeDummyData();
                  _callSendAddHeadacheLogApi();
                }
            );
            _callSendAddHeadacheLogApi();
          } else {
            Utils.showValidationErrorDialog(context, medicationErrorMessage);
            _isButtonClicked = false;
          }
        }*/
        String? medicationErrorMessage;

        for (int i = 0; i < _medicationSelectedAnswerList.length; i++) {
          List<SelectedAnswers> medicationSelectedAnswerList =
          _medicationSelectedAnswerList[i];

          SelectedAnswers? medicationSelectedAnswer =
          medicationSelectedAnswerList.firstWhereOrNull(
                  (element) =>
              element.questionTag == Constant.logDayMedicationTag);
          SelectedAnswers? typeSelectedAnswer = medicationSelectedAnswerList
              .firstWhereOrNull((element) => element.questionTag!.contains('.type'));

          SelectedAnswers? dosageSelectedAnswer = medicationSelectedAnswerList
              .firstWhereOrNull((element) => element.questionTag!.contains('.dosage'));

          SelectedAnswers? numberOfDosageAnswer = medicationSelectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.numberOfDosageTag);

          if (typeSelectedAnswer == null) {
            if (medicationSelectedAnswer != null)
              medicationErrorMessage =
              'Please select dosage type of ${medicationSelectedAnswer.answer} medication.';
            else
              medicationErrorMessage =
              'Please select dosage type of medication';

            break;
          }

          if (numberOfDosageAnswer != null && numberOfDosageAnswer.answer == '0') {
            var genericMedicationQuestionList = _addHeadacheUserListData
                .where((element) => element.tag!.contains('.generic'))
                .toList();

            if (medicationSelectedAnswer != null && typeSelectedAnswer != null && dosageSelectedAnswer != null) {
              var dosageQuestion = _addHeadacheUserListData.firstWhereOrNull((element) => element.tag == dosageSelectedAnswer.questionTag);

              if(dosageQuestion != null) {
                var dosageSelectedValue = dosageQuestion.values!.firstWhereOrNull((element) => element.text == dosageSelectedAnswer.answer);

                if (dosageSelectedValue != null) {
                  var unitSelectedValue = dosageSelectedValue.unitList!.firstWhereOrNull((element) => element.isSelected);

                  String medUnit = Constant.blankString;

                  if(unitSelectedValue != null) {
                    medUnit = unitSelectedValue.text!;
                  } else {
                    medUnit = dosageSelectedValue.unitList!.first.text!;
                  }

                  Questions? genericMedicationQuestion = Utils.getGenericMedicationQuestion(genericMedicationQuestionList, medicationSelectedAnswer.answer ?? '', typeSelectedAnswer.answer ?? '');
                  medicationErrorMessage = 'Error! ${Utils.getMedicationOptionText(medicationSelectedAnswer.answer ?? '', genericMedicationQuestion!.values!.first.text ?? '')} Medication $medUnit cannot be 0.';
                } else {
                  medicationErrorMessage = 'Error! Medication dose cannot be 0.';
                }
              } else {
                medicationErrorMessage = 'Error! Medication dose cannot be 0.';
              }
            } else {
              medicationErrorMessage = 'Error! Medication dose cannot be 0.';
            }
            break;
          }
        }

        if (medicationErrorMessage == null) {
          Utils.showApiLoaderDialog(context,
              networkStream: _addHeadacheLogBloc.sendAddHeadacheLogDataStream,
              tapToRetryFunction: () {
                _addHeadacheLogBloc.enterSomeDummyData();
                _callSendAddHeadacheLogApi();
              });
          _callSendAddHeadacheLogApi();
        } else {
          Utils.showValidationErrorDialog(context, medicationErrorMessage, 'Alert!');
          _isButtonClicked = false;
        }
      } else {
        Utils.showValidationErrorDialog(context, errorMessage, timeErrorTitle);
        _isButtonClicked = false;
      }
    } else {
      //show headacheType selection error
      debugPrint('headache type error');
      Utils.showValidationErrorDialog(
          context, 'Please select a headache type.', 'Alert!');
      _isButtonClicked = false;
    }
  }

  void _callSendAddHeadacheLogApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    SelectedAnswers? onSetSelectedAnswer = signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull((element) => element.questionTag == Constant.onSetTag);

    DateTime calendarEntryAt = DateTime.now();
    if (onSetSelectedAnswer != null)
      calendarEntryAt = DateTime.tryParse(onSetSelectedAnswer.answer ?? '')!.toLocal();

    var response = await _addHeadacheLogBloc.sendAddHeadacheDetailsData(
        signUpOnBoardSelectedAnswersModel, _medicationSelectedAnswerList, calendarEntryAt, context);

    if (response == Constant.success) {
      prefs.setString(Constant.updateCalendarTriggerData, Constant.trueString);
      prefs.setString(Constant.updateCalendarIntensityData, Constant.trueString);
      prefs.setString(Constant.updateOverTimeCompassData, Constant.trueString);
      prefs.setString(Constant.updateCompareCompassData, Constant.trueString);
      prefs.setString(Constant.updateTrendsData, Constant.trueString);
      prefs.setString(Constant.updateMeScreenData, Constant.trueString);
      Navigator.pop(context);
      if (!_isFromRecordScreen) {
        if (_isUserHeadacheEnded) {
          await SignUpOnBoardProviders.db.deleteUserCurrentHeadacheData();
        } else {
          var userProfileInfoData =
          await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

          CurrentUserHeadacheModel? currentUserHeadacheModel =
          await SignUpOnBoardProviders.db
              .getUserCurrentHeadacheData(userProfileInfoData.userId ?? '');

          if (currentUserHeadacheModel != null) {
            currentUserHeadacheModel.isFromServer = true;

            await SignUpOnBoardProviders.db
                .insertOrUpdateCurrentHeadacheData(currentUserHeadacheModel);
          }
        }
        //Navigator.pushNamed(context, Constant.addHeadacheSuccessScreenRouter);
        Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
      } else {
        if (_isFromRecordScreen)
          //Navigator.pop(context, _addHeadacheLogBloc.isHeadacheLogged);
          Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
        else
          Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
      }
    }
    _isButtonClicked = false;
  }

  void saveAndUpdateDataInLocalDatabase(
      UserAddHeadacheLogModel userAddHeadacheLogModel) async {
    try {
      int? userProgressDataCount = await SignUpOnBoardProviders.db
          .checkUserProgressDataAvailable(
          SignUpOnBoardProviders.TABLE_ADD_HEADACHE);
      if (userProgressDataCount == 0) {
        SignUpOnBoardProviders.db
            .insertAddHeadacheDetails(userAddHeadacheLogModel);
      } else {
        SignUpOnBoardProviders.db
            .updateAddHeadacheDetails(userAddHeadacheLogModel);
      }
    } catch (e) {
      e.toString();
    }
  }

  void requestService() async {
    _selectedMedicationMapList =
    await SignUpOnBoardProviders.db.getLogHeadacheMedication();
    _selectedHeadacheMigraineList =
    await SignUpOnBoardProviders.db.getLogHeadacheMigraine();

    _recentMedicationMapList = await SignUpOnBoardProviders.db.getRecentMedicationLogged();

    List<Map>? userHeadacheDataList;
    var userProfileInfoData =
    await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    if (userProfileInfoData != null)
      userHeadacheDataList = await _addHeadacheLogBloc
          .fetchDataFromLocalDatabase(userProfileInfoData.userId!);
    else
      userHeadacheDataList =
      await _addHeadacheLogBloc.fetchDataFromLocalDatabase("4214");
    if (userHeadacheDataList!.length > 0) {
      userHeadacheDataList.forEach((element) {
        List<dynamic> map = jsonDecode(element['selectedAnswers']);
        map.forEach((element) {
          selectedAnswers.add(SelectedAnswers(
              questionTag: element['questionTag'], answer: element['answer']));
        });
      });
      signUpOnBoardSelectedAnswersModel.selectedAnswers = selectedAnswers;
    }

    if (_isFromRecordScreen) {
      await _addHeadacheLogBloc
          .fetchCalendarHeadacheLogDayData(widget.currentUserHeadacheModel!, context);
      signUpOnBoardSelectedAnswersModel.selectedAnswers =
          _addHeadacheLogBloc.selectedAnswersList;
      _medicationSelectedAnswerList =
          _addHeadacheLogBloc.medicationSelectedAnswerList;

      SelectedAnswers? startTimeSelectedAnswer =
      signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull(
              (element) => element.questionTag == Constant.onSetTag);
      SelectedAnswers? endTimeSelectedAnswer = signUpOnBoardSelectedAnswersModel
          .selectedAnswers
          !.firstWhereOrNull((element) => element.questionTag == Constant.endTimeTag);
      SelectedAnswers? onGoingSelectedAnswer = signUpOnBoardSelectedAnswersModel
          .selectedAnswers
          !.firstWhereOrNull((element) => element.questionTag == Constant.onGoingTag);

      if (startTimeSelectedAnswer != null) {
        _currentUserHeadacheModel.selectedDate = startTimeSelectedAnswer.answer;
      }

      if (endTimeSelectedAnswer != null) {
        _currentUserHeadacheModel.selectedEndDate =
            endTimeSelectedAnswer.answer;
      }

      if (onGoingSelectedAnswer != null) {
        _currentUserHeadacheModel.isOnGoing =
            onGoingSelectedAnswer.answer!.toLowerCase() != 'no';
      }

      print(_currentUserHeadacheModel);
    } else {
      await _addHeadacheLogBloc
          .fetchCalendarHeadacheLogDayData(widget.currentUserHeadacheModel!, context);
      signUpOnBoardSelectedAnswersModel.selectedAnswers =
          _addHeadacheLogBloc.selectedAnswersList;
      _medicationSelectedAnswerList =
          _addHeadacheLogBloc.medicationSelectedAnswerList;
    }
  }

  void _showDiscardChangesBottomSheet() async {
    var resultOfDiscardChangesBottomSheet = await showCupertinoModalPopup(
        context: context, builder: (context) => DiscardChangesBottomSheet());
    if (resultOfDiscardChangesBottomSheet == Constant.discardChanges) {
      if(!_isFromRecordScreen) {
        if (!widget.currentUserHeadacheModel!.isFromServer!) {
          await SignUpOnBoardProviders.db.deleteUserCurrentHeadacheData();
        }
      }
      //SignUpOnBoardProviders.db.deleteAllUserLogDayData();
      if (_isFromRecordScreen)
        Navigator.pop(context, _addHeadacheLogBloc.isHeadacheLogged);
      else
        Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
    } else if (resultOfDiscardChangesBottomSheet == Constant.saveAndExit) {
      if (!_isButtonClicked) {
        _isButtonClicked = true;
        saveDataInLocalDataBaseOrServer();
      }
    }
  }

  Widget _getHeadacheTypeWidget(List<Questions> addHeadacheListData) {
    Widget? widget;

    List<Questions> questionsList = addHeadacheListData;

    var headacheTypeSelectedAnswer =
    signUpOnBoardSelectedAnswersModel.selectedAnswers!.firstWhereOrNull(
            (element) => element.questionTag == Constant.headacheTypeTag);
    var headacheTypeQuestion = questionsList.firstWhereOrNull(
            (element) => element.tag == Constant.headacheTypeTag);

    var headacheMigraineQuestion = questionsList.firstWhereOrNull(
            (element) => element.tag == Constant.headacheMigraineTag);

    if (headacheTypeSelectedAnswer != null) {
      if (headacheTypeSelectedAnswer.answer == Constant.noHeadacheValue) {
        _animationController!.reverse();
      } else {
        var visibilityHeadacheInfo = Provider.of<TonixVisibilityHeadacheInfo>(context, listen: false);

        visibilityHeadacheInfo.updateVisibilityHeadacheInfo(true, false);
        _animationController!.forward();
      }
    } else {
      if (headacheTypeQuestion != null) {
        Values? noHeadacheValue = headacheTypeQuestion.values!.firstWhereOrNull(
                (element) => element.text == Constant.noHeadacheValue);
        if (noHeadacheValue != null) {
          noHeadacheValue.isSelected = true;
          signUpOnBoardSelectedAnswersModel.selectedAnswers!.add(SelectedAnswers(
              questionTag: headacheTypeQuestion.tag,
              answer: noHeadacheValue.text));
        }
      }
      _animationController!.reverse();
    }

    if (headacheTypeQuestion != null) {
      widget = TonixAddHeadacheSection(
        headerText: headacheTypeQuestion.text!,
        subText: headacheTypeQuestion.helpText!,
        contentType: headacheTypeQuestion.tag!,
        min: headacheTypeQuestion.min!.toDouble(),
        max: headacheTypeQuestion.max!.toDouble(),
        valuesList: headacheTypeQuestion.values!,
        updateAtValue: null,
        selectedCurrentValue: headacheTypeQuestion.currentValue!,
        selectedAnswers: signUpOnBoardSelectedAnswersModel.selectedAnswers!,
        addHeadacheDetailsData: addSelectedHeadacheDetailsData,
        moveWelcomeOnBoardTwoScreen: moveOnWelcomeBoardSecondStepScreens,
        isHeadacheEnded: true,
        removeHeadacheTypeData: (tag, headacheType) {
          if (signUpOnBoardSelectedAnswersModel.selectedAnswers!.length > 0) {
            signUpOnBoardSelectedAnswersModel.selectedAnswers
                !.removeWhere((element) => element.questionTag == tag);
          }
        },
        currentUserHeadacheModel: _currentUserHeadacheModel,
        uiHints: headacheTypeQuestion.uiHints!,
        dosageQuestionList: null,
        medicationSelectedAnswerList: _medicationSelectedAnswerList,
        headacheMigraineQuestion: headacheMigraineQuestion,
      );
    }

    return widget ?? Container();
  }

  Widget _getMedicationSection(List<dynamic> addHeadacheListData) {

    Widget widget;

    List<Questions> medicationExpandableWidgetList = [];

    var dosageTypeQuestionList = _addHeadacheUserListData
        .where((element) => element.tag!.contains('.type'))
        .toList();
    var dosageQuestionList = _addHeadacheUserListData
        .where((element) => element.tag!.contains('.dosage'))
        .toList();
    var genericMedicationQuestion = _addHeadacheUserListData
        .where((element) => element.tag!.contains('.generic'))
        .toList();

    medicationExpandableWidgetList.addAll(dosageQuestionList);

    Questions? medicationQuestionObj = _addHeadacheUserListData.firstWhereOrNull(
            (element) => element.tag == 'medication');

    if (medicationQuestionObj != null) {
      debugPrint('MEDICATIONLISTLENGTH???${_medicationSelectedAnswerList.isNotEmpty}');
      if (_medicationSelectedAnswerList.isEmpty) {
        if(!_addHeadacheLogBloc.isMedicationLoggedEmpty) {
          if(!_isMedicationSelected) {
            _selectedMedicationMapList.forEach((medName) {
              Values? medValue = medicationQuestionObj.values!.firstWhereOrNull(
                      (element) => element.text == medName[SignUpOnBoardProviders.MEDICATION_NAME]);

              /*Questions dosageTypeQuestion = Utils.getDosageTypeQuestion(dosageTypeQuestionList, medName[SignUpOnBoardProviders.MEDICATION_NAME]);

              Questions dosageQuestion = Utils.getDosageQuestion(dosageQuestionList, medName[SignUpOnBoardProviders.MEDICATION_NAME], medName[SignUpOnBoardProviders.DOSAGE_TYPE]);

              if(dosageTypeQuestion != null && dosageQuestion != null) {
                Values dosageTypeValue = dosageTypeQuestion.values.firstWhere((element) => element.text == medName[SignUpOnBoardProviders.DOSAGE_TYPE], orElse: () => null);

                if(dosageTypeValue != null)
                  dosageTypeValue.isSelected = true;

                Values dosageValue = dosageQuestion.values.firstWhere((element) => element.text == medName[SignUpOnBoardProviders.DOSAGE], orElse: () => null);

                if(dosageValue != null) {
                  dosageValue.isSelected = true;

                  Values selectedUnitValue = dosageValue.unitList.firstWhere((element) => element.text == medName[SignUpOnBoardProviders.UNITS], orElse: () => null);

                  if(selectedUnitValue != null)
                    selectedUnitValue.isSelected = true;
                }
              }*/

              if (medValue != null) {
                debugPrint('Selecting medication1');
                //medValue.isSelected = true;
                //medValue.numberOfDosage = int.tryParse(medName[SignUpOnBoardProviders.NUMBER_OF_DOSAGE]);
              }
            });

            _isMedicationSelected = true;
          }
        }
      } else {
        _medicationSelectedAnswerList.forEach((selectedMedicationAnswerList) {
          SelectedAnswers? medicationSelectedAnswer =
          selectedMedicationAnswerList.firstWhereOrNull(
                  (element) =>
              element.questionTag == Constant.logDayMedicationTag);
          SelectedAnswers? numberOfDosageSelectedAnswer =
          selectedMedicationAnswerList.firstWhereOrNull(
                  (element) =>
              element.questionTag == Constant.numberOfDosageTag);
          SelectedAnswers? typeSelectedAnswer = selectedMedicationAnswerList
              .firstWhereOrNull((element) => element.questionTag!.contains('.type'));
          SelectedAnswers? dosageSelectedAnswer = selectedMedicationAnswerList
              .firstWhereOrNull((element) => element.questionTag!.contains('.dosage'));
          SelectedAnswers? genericSelectedAnswer = selectedMedicationAnswerList
              .firstWhere((element) => element.questionTag!.contains('.generic'));
          SelectedAnswers? unitSelectedAnswer =
          selectedMedicationAnswerList.firstWhereOrNull(
                  (element) =>
              element.questionTag == Constant.unitTag);

          if (medicationSelectedAnswer != null &&
              numberOfDosageSelectedAnswer != null &&
              typeSelectedAnswer != null &&
              dosageSelectedAnswer != null &&
              genericSelectedAnswer != null &&
              unitSelectedAnswer != null) {
            String? medName = medicationSelectedAnswer.answer;

            Questions? medicationQuestion = _addHeadacheUserListData.firstWhereOrNull(
                    (element) => element.tag == Constant.logDayMedicationTag);

            if (medicationQuestion != null) {
              Values? medValue = medicationQuestionObj.values!.firstWhereOrNull(
                      (element) => element.text == medName);

              if (medValue != null) {
                debugPrint('Selecting medication2');
                medValue.isSelected = true;
                if (numberOfDosageSelectedAnswer != null)
                  medValue.numberOfDosage =
                      int.tryParse(numberOfDosageSelectedAnswer.answer!)!;
              }
            }

            Questions? dosageQuestion = dosageQuestionList.firstWhereOrNull(
                    (element) => element.tag == dosageSelectedAnswer.questionTag);
            Questions? typeQuestion = dosageTypeQuestionList.firstWhereOrNull(
                    (element) => element.tag == typeSelectedAnswer.questionTag);

            if (dosageQuestion != null) {
              Values? dosageValue = dosageQuestion.values!.firstWhereOrNull(
                      (element) => element.text == dosageSelectedAnswer.answer);

              if (dosageValue != null) {
                dosageValue.isSelected = true;

                Values? selectedUnitValue = dosageValue.unitList!.firstWhereOrNull((element) => element.text == unitSelectedAnswer.answer);

                if(selectedUnitValue != null)
                  selectedUnitValue.isSelected = true;
              }
            }

            if (typeQuestion != null) {
              Values? typeValue = typeQuestion.values!.firstWhereOrNull(
                      (element) => element.text == typeSelectedAnswer.answer);

              if (typeValue != null) typeValue.isSelected = true;
            }
          }
        });
      }
    }

    widget = TonixAddHeadacheSection(
      headerText: (medicationQuestionObj == null) ? '' : medicationQuestionObj.text ?? '',
      subText: (medicationQuestionObj == null) ? '' : medicationQuestionObj.helpText ?? '',
      contentType: (medicationQuestionObj == null) ? '' : medicationQuestionObj.tag ?? '',
      min: (medicationQuestionObj == null) ? 0 : medicationQuestionObj.min!.toDouble(),
      max: (medicationQuestionObj == null) ? 0 : medicationQuestionObj.max!.toDouble(),
      valuesList: (medicationQuestionObj == null) ? [] : medicationQuestionObj.values ?? [],
      updateAtValue: null,
      selectedCurrentValue: (medicationQuestionObj == null) ? '' : medicationQuestionObj.currentValue ?? '',
      selectedAnswers: signUpOnBoardSelectedAnswersModel.selectedAnswers ?? [],
      addHeadacheDetailsData: addSelectedHeadacheDetailsData,
      moveWelcomeOnBoardTwoScreen: moveOnWelcomeBoardSecondStepScreens,
      isHeadacheEnded: this.widget.currentUserHeadacheModel!.isOnGoing != null ? !this.widget.currentUserHeadacheModel!.isOnGoing! : false,
      removeHeadacheTypeData: (tag, headacheType) {
        if (signUpOnBoardSelectedAnswersModel.selectedAnswers!.length > 0) {
          signUpOnBoardSelectedAnswersModel.selectedAnswers
              !.removeWhere((element) => element.questionTag == tag);
        }
      },
      currentUserHeadacheModel: _currentUserHeadacheModel,
      uiHints: (medicationQuestionObj == null) ? '' : medicationQuestionObj.uiHints ?? '',
      dosageQuestionList: dosageQuestionList,
      medicationSelectedAnswerList: _medicationSelectedAnswerList,
      headacheMigraineQuestion: medicationQuestionObj,
      dosageTypeQuestionList: dosageTypeQuestionList,
      genericMedicationQuestionList: genericMedicationQuestion,
      recentMedicationMapList: _recentMedicationMapList,
      isMedicationLoggedEmpty: _addHeadacheLogBloc.isMedicationLoggedEmpty,
    );

    return widget;
  }
}

class TonixHeadacheTypeInfo with ChangeNotifier {
  updateHeadacheTypeInfo() {
    notifyListeners();
  }
}

class TonixVisibilityHeadacheInfo with ChangeNotifier {
  bool _isVisible = false;

  bool isVisible() => _isVisible;

  updateVisibilityHeadacheInfo(bool isVisible, bool shouldNotify) {
    _isVisible = isVisible;

    if(shouldNotify)
      notifyListeners();
  }
}

class TonixAddHeadacheSectionSubTextInfo with ChangeNotifier {
  updateAddHeadacheSectionSubTextInfo() {
    notifyListeners();
  }
}
