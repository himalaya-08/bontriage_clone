import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
//import 'package:health/health.dart';
import 'package:mobile/blocs/LogDayBloc.dart';
import 'package:mobile/main.dart';
import 'package:mobile/models/LogDayScreenArgumentModel.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/AddANoteWidget.dart';
import 'package:mobile/view/AddHeadacheSection.dart';
import 'package:mobile/view/AddNoteBottomSheet.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/DiscardChangesBottomSheet.dart';
import 'package:mobile/view/LogDayDoubleTapDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'NetworkErrorScreen.dart';
import 'medicationlist/medication_list_action_sheet.dart';

class LogDayScreen extends StatefulWidget {
  final LogDayScreenArgumentModel? logDayScreenArgumentModel;

  const LogDayScreen({Key? key, this.logDayScreenArgumentModel})
      : super(key: key);

  @override
  _LogDayScreenState createState() => _LogDayScreenState();
}

class _LogDayScreenState extends State<LogDayScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime _dateTime = DateTime.now();
  LogDayBloc? _logDayBloc = LogDayBloc(null);
  List<Widget> _sectionWidgetList = [];
  List<Questions> _questionsList = [];
  List<Questions> _sleepValuesList = [];
  List<Questions> _medicationValuesList = [];
  List<Questions> _triggerValuesList = [];
  List<SelectedAnswers> selectedAnswers = [];

  bool _isDataPopulated = false;
  bool _isButtonClicked = false;

  List<Map> _selectedMedicationMapList = [];
  List<Map> _recentMedicationMapList = [];

  List<MedicationListActionSheetModel> _preventiveMedicationActionSheetModelList = [];
  List<MedicationListActionSheetModel> _acuteMedicationActionSheetModelList = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (widget.logDayScreenArgumentModel == null) {
      _dateTime = DateTime.now();
    } else {
      _dateTime = widget.logDayScreenArgumentModel!.selectedDateTime!;
    }
    if (widget.logDayScreenArgumentModel != null) {
      _logDayBloc =
          LogDayBloc(widget.logDayScreenArgumentModel!.selectedDateTime!);
    } else {
      _logDayBloc = LogDayBloc(null);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestService();
      Utils.showApiLoaderDialog(context);
    });

    Utils.setAnalyticsCurrentScreen(Constant.logDayScreen, context);
  }

  void requestService() async {
    _selectedMedicationMapList =
        await SignUpOnBoardProviders.db.getLogHeadacheMedication();
    _recentMedicationMapList =
        await SignUpOnBoardProviders.db.getRecentMedicationLogged();

    List<Map>? logDayDataList;
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    logDayDataList = await _logDayBloc?.getAllLogDayData(userProfileInfoData.userId!);
    if (logDayDataList!.length > 0 && selectedAnswers.length == 0) {
      logDayDataList.forEach((element) {
        List<dynamic> map = jsonDecode(element['selectedAnswers']);
        map.forEach((element) {
          if (element['questionTag'] != Constant.administeredTag)
          selectedAnswers.add(SelectedAnswers(
              questionTag: element['questionTag'],
              answer: element['answer'],
              isDoubleTapped: true));
        });
      });
    }

    List<SelectedAnswers> doubleTappedSelectedAnswerList = [];
    doubleTappedSelectedAnswerList.addAll(selectedAnswers);

    String selectedDate = Utils.getDateTimeInUtcFormat(DateTime(_dateTime.year, _dateTime.month, _dateTime.day), true, context);

    await _logDayBloc!.fetchCalendarHeadacheLogDayData(selectedDate, context);

    selectedAnswers =
        _logDayBloc!.getSelectedAnswerList(doubleTappedSelectedAnswerList);

    if (selectedAnswers.length == 0)
      selectedAnswers = doubleTappedSelectedAnswerList;
  }

  @override
  void dispose() {
    _logDayBloc!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        _onBackPressed();
        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            decoration: Constant.backgroundBoxDecoration,
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
                                  '${Utils.getMonthName(_dateTime.month)} ${_dateTime.day}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Constant.chatBubbleGreen,
                                  fontFamily: Constant.jostMedium),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                _onBackPressed();
                                //Navigator.pop(context);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, bottom: 5),
                                child: Image(
                                  image: AssetImage(Constant.closeIcon),
                                  width: 22,
                                  height: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Divider(
                          thickness: 1,
                          color: Constant.chatBubbleGreen,
                          height: 30,
                        ),
                      ),
                      StreamBuilder<dynamic>(
                        stream: _logDayBloc!.logDayDataStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (!_isDataPopulated) {
                              Utils.closeApiLoaderDialog(context);
                              Future.delayed(Duration(milliseconds: 200),
                                      () {
                                    _showDoubleTapDialog();
                                  });
                              addNewWidgets(snapshot.data);
                            }
                            return Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: RawScrollbar(
                                      thickness: 2,
                                      thumbColor: Constant.locationServiceGreen,
                                      thumbVisibility: true,
                                      child: SingleChildScrollView(
                                        physics: BouncingScrollPhysics(),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 15),
                                              child: CustomTextWidget(
                                                text: Constant.doubleTapAnItem,
                                                style: TextStyle(
                                                    fontSize:
                                                    Platform.isAndroid ? 13 : 14,
                                                    color: Constant.doubleTapTextColor,
                                                    fontFamily: Constant.jostRegular),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Column(children: _sectionWidgetList),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15,),
                                  AddANoteWidget(
                                    scaffoldKey: scaffoldKey,
                                    selectedAnswerList: selectedAnswers,
                                    noteTag: 'logday.note',
                                  ),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            Utils.closeApiLoaderDialog(context);
                            return Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: NetworkErrorScreen(
                                      errorMessage: snapshot.error.toString(),
                                      tapToRetryFunction: () {
                                        Utils.showApiLoaderDialog(context);
                                        requestService();
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 15,),
                                  AddANoteWidget(
                                    scaffoldKey: scaffoldKey,
                                    selectedAnswerList: selectedAnswers,
                                    noteTag: 'logday.note',
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(),
                                  ),
                                  const SizedBox(height: 15,),
                                  AddANoteWidget(
                                    scaffoldKey: scaffoldKey,
                                    selectedAnswerList: selectedAnswers,
                                    noteTag: 'logday.note',
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BouncingWidget(
                            onPressed: () {
                              _onSaveButtonClicked();
                            },
                            child: Container(
                              width: 110,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Constant.chatBubbleGreen,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: CustomTextWidget(
                                  text: Constant.save,
                                  style: TextStyle(
                                      color: Constant.bubbleChatTextView,
                                      fontSize: 15,
                                      fontFamily: Constant.jostMedium),
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
                              _onBackPressed();
                            },
                            child: Container(
                              width: 110,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1.3,
                                    color: Constant.chatBubbleGreen),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: CustomTextWidget(
                                  text: Constant.cancel,
                                  style: TextStyle(
                                      color: Constant.chatBubbleGreen,
                                      fontSize: 15,
                                      fontFamily: Constant.jostMedium),
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
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showAddNoteBottomSheet() async {
    scaffoldKey.currentState!.showBottomSheet(
        (context) => AddNoteBottomSheet(
              addNoteCallback: (note) {
                if (note != null) {
                  if (note.trim() != '') {
                    SelectedAnswers? noteSelectedAnswer =
                        selectedAnswers.firstWhereOrNull(
                            (element) => element.questionTag == 'logday.note');
                    if (noteSelectedAnswer == null)
                      selectedAnswers.add(SelectedAnswers(
                          questionTag: 'logday.note', answer: note));
                    else
                      noteSelectedAnswer.answer = note;
                  }
                }
              },
            ),
        backgroundColor: Colors.transparent);
  }

  void addNewWidgets(List<Questions> questionList) {
    _questionsList.addAll(questionList);

    if (_sectionWidgetList.length == 0) {
      if (selectedAnswers.length != 0) {
        selectedAnswers.forEach((element) {
          Questions? questions = questionList.firstWhereOrNull(
              (element1) => element1.tag == element.questionTag);
          if (questions != null &&
              (questions.questionType == 'multi' ||
                  questions.questionType == 'single')) {
            try {
              Values? values = questions.values!.firstWhereOrNull((e) => e.text == element.answer);
              values!.isSelected = true;
              values.isDoubleTapped =
                  element.isDoubleTapped ?? true;
            } catch (e) {
              debugPrint(e.toString());
            }
          }
        });
      }
      List<Questions> allQuestionList = [];
      allQuestionList.addAll(questionList);
      _sectionWidgetList = [];
      questionList.forEach((element) {
        if (element.precondition!.contains('behavior.presleep')) {
          _sleepValuesList.add(element);
        } else if (element.precondition!.contains('.formulation')) {
          _medicationValuesList.add(element);
        } else if (element.precondition!.contains('triggers1')) {
          _triggerValuesList.add(element);
        }
      });

      questionList.removeWhere((element) => _sleepValuesList.contains(element));
      questionList
          .removeWhere((element) => _medicationValuesList.contains(element));
      questionList
          .removeWhere((element) => _triggerValuesList.contains(element));

      List<SelectedAnswers> doubleTapSelectedAnswerList = [];

      selectedAnswers.forEach((element) {
        if (element.isDoubleTapped == true) {
          doubleTapSelectedAnswerList.addAll(selectedAnswers);
        }
      });

      questionList.forEach((element) {
        if (element.precondition == null || element.precondition!.isEmpty) {
          _sectionWidgetList.add(
            AddHeadacheSection(
              headerText: element.text!,
              subText: element.helpText!,
              contentType: element.tag!,
              sleepExpandableWidgetList: _sleepValuesList,
              medicationExpandableWidgetList: _medicationValuesList,
              triggerExpandableWidgetList: _triggerValuesList,
              valuesList: element.values!,
              questionType: element.questionType!,
              allQuestionsList: allQuestionList,
              selectedAnswers: selectedAnswers,
              doubleTapSelectedAnswer: doubleTapSelectedAnswerList,
              isFromRecordsScreen: (widget.logDayScreenArgumentModel != null)
                  ? widget.logDayScreenArgumentModel!.isFromRecordScreen
                  : false,
              uiHints: element.uiHints!,
              selectedDateTime: _logDayBloc!.selectedDateTime ?? DateTime.now(),
              recentMedicationMapList: _recentMedicationMapList,
              selectedMedicationMapList: _selectedMedicationMapList,
              userMedicationHistoryList: _logDayBloc?.medicationHistoryDataModelList ?? [],
              preventiveMedicationActionSheetModelList: _preventiveMedicationActionSheetModelList,
              acuteMedicationActionSheetModelList: _acuteMedicationActionSheetModelList,
            ),
          );
        }
      });
    }
    _isDataPopulated = true;
  }

  void _showDiscardChangesBottomSheet() async {
    var resultOfDiscardChangesBottomSheet = await showCupertinoModalPopup(
        context: context, builder: (context) => DiscardChangesBottomSheet());
    if (resultOfDiscardChangesBottomSheet == Constant.discardChanges) {
      if (widget.logDayScreenArgumentModel == null) {
        Navigator.popUntil(context, ModalRoute.withName(Constant.homeRouter));
      } else {
        Navigator.pop(context, false);
      }
    } else if (resultOfDiscardChangesBottomSheet == Constant.saveAndExit) {
      _onSaveButtonClicked();
    }
  }

  Future<void> _showDoubleTapDialog() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isDialogDisplayed =
        sharedPreferences.getBool(Constant.logDayDoubleTapDialog) ?? false;

    if (!isDialogDisplayed) {
      sharedPreferences.setBool(Constant.logDayDoubleTapDialog, true);
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            backgroundColor: Colors.transparent,
            content: LogDayDoubleTapDialog(),
          );
        },
      );
    }
  }

  void _onSubmitClicked() async {
    Utils.showApiLoaderDialog(
      context,
      networkStream: _logDayBloc!.sendLogDayDataStream,
      tapToRetryFunction: () {
        _logDayBloc!.enterSomeDummyDataToStreamController();
        _callSendLogDayDataApi();
      },
    );
    _callSendLogDayDataApi();
  }

  void _callSendLogDayDataApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await _logDayBloc!.sendMedicationHistoryData(
        selectedAnswers, _questionsList, context);
    if (response is String) {
      if (response == Constant.success) {
        //SignUpOnBoardProviders.db.deleteAllUserLogDayData();
        prefs.setString(Constant.updateCalendarTriggerData, 'true');
        prefs.setString(Constant.updateCalendarIntensityData, 'true');
        prefs.setString(Constant.updateOverTimeCompassData, 'true');
        prefs.setString(Constant.updateCompareCompassData, 'true');
        prefs.setString(Constant.updateMeScreenData, 'true');
        Navigator.pop(context);

        if (widget.logDayScreenArgumentModel == null) {
          Navigator.pushReplacementNamed(
              context, Constant.logDaySuccessScreenRouter);
        } else {
          if (widget.logDayScreenArgumentModel!.isFromRecordScreen) {
            Navigator.pop(context, true);
          } else {
            Navigator.pushReplacementNamed(
                context, Constant.logDaySuccessScreenRouter);
          }
        }
      }
    }
    _isButtonClicked = false;
  }

  void _onSaveButtonClicked() {
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_isButtonClicked) {
      _isButtonClicked = true;
      if (selectedAnswers.length > 0) {
        SelectedAnswers? logDayNoteSelectedAnswer = selectedAnswers.firstWhereOrNull(
            (element) => element.questionTag == Constant.logDayNoteTag);
        if (logDayNoteSelectedAnswer == null)
          selectedAnswers.add(
              SelectedAnswers(
                questionTag: Constant.logDayNoteTag,
                answer: Constant.blankString,
              )
          );

        if (selectedAnswers.length == 1) {
          if (selectedAnswers.first.questionTag == Constant.logDayNoteTag) {
            if (selectedAnswers.first.answer!.trim().isEmpty) {
              Utils.showValidationErrorDialog(
                  context,
                  Constant.selectAtLeastOneOptionLogDayError,
                  'Cannot log your day!',
                  true);
              _isButtonClicked = false;
            } else {
              if (_medicationValidation())
                _onSubmitClicked();
            }
          } else {
            if (_medicationValidation())
              _onSubmitClicked();
          }
        } else {
          if (_medicationValidation())
            _onSubmitClicked();
        }
      } else {
        Utils.showValidationErrorDialog(
            context,
            Constant.selectAtLeastOneOptionLogDayError,
            'Cannot log your day!',
            true);
        _isButtonClicked = false;
      }
    }
  }

  bool _medicationValidation() {
    bool isValidated = true;

    SelectedAnswers? administeredSelectedAnswer = selectedAnswers.firstWhereOrNull((element) => element.questionTag == Constant.administeredTag);

    if (administeredSelectedAnswer != null) {
      List<MedicationListActionSheetModel> medicationListActionSheetModelList = medicationListActionSheetModelFromJson(administeredSelectedAnswer.answer ?? '[]');

      for (int i = 0; i < medicationListActionSheetModelList.length; i++) {
        MedicationListActionSheetModel actionSheetElement = medicationListActionSheetModelList[i];

        if (actionSheetElement.formulationText.isEmpty) {
          Utils.showValidationErrorDialog(context, 'Please select valid formulation for ${actionSheetElement.medicationText}!', 'Alert!', true);
          _isButtonClicked = false;
          return false;
        } else if (actionSheetElement.dosageTag.isEmpty) {
          Utils.showValidationErrorDialog(context, 'Please select valid dosage for ${actionSheetElement.medicationText}!', 'Alert!', true);
          _isButtonClicked = false;
          return false;
        } else if (actionSheetElement.numberOfDosage == null) {
          Utils.showValidationErrorDialog(context, 'Please enter number of dosage for ${actionSheetElement.medicationText}!', 'Alert!', true);
          _isButtonClicked = false;
          return false;
        }
      }
    }

    return isValidated;
  }

  /// This method invokes when user presses either back button, close button or cancel button
  void _onBackPressed() {
    if (selectedAnswers.length > 0)
      _showDiscardChangesBottomSheet();
    else {
      if (widget.logDayScreenArgumentModel == null) {
        Navigator.popUntil(
            context, ModalRoute.withName(Constant.homeRouter));
      } else {
        Navigator.pop(context, false);
        /*Navigator.popUntil(
                context, ModalRoute.withName(Constant.homeRouter));*/
      }
    }
  }
}
