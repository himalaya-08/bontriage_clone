import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:mobile/blocs/MoreTriggerMedicationsBloc.dart';
import 'package:mobile/models/MoreMedicationArgumentModel.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/SignUpBottomSheet.dart';
import 'package:mobile/view/sign_up_on_board_screen.dart';
import 'package:provider/provider.dart';

import 'CustomTextWidget.dart';

class MoreMedicationScreen extends StatefulWidget {
  final Function(BuildContext, String)? onPush;
  final Future<dynamic> Function(String, dynamic) openActionSheetCallback;
  final Function(Questions, Function(int)) openTriggerMedicationActionSheetCallback;
  final MoreMedicationArgumentModel moreMedicationArgumentModel;
  final Function(Stream, Function) showApiLoaderCallback;

  const MoreMedicationScreen({Key? key, this.onPush, required this.openActionSheetCallback, required this.openTriggerMedicationActionSheetCallback, required this.moreMedicationArgumentModel, required this.showApiLoaderCallback})
      : super(key: key);
  @override
  _MoreMedicationScreenState createState() => _MoreMedicationScreenState();
}

class _MoreMedicationScreenState extends State<MoreMedicationScreen> with SingleTickerProviderStateMixin {

  MoreTriggerMedicationBloc _bloc = MoreTriggerMedicationBloc();

  String _initialSelectedAnswerListJson = '';

  @override
  void initState() {
    super.initState();

    _bloc = MoreTriggerMedicationBloc();

    _bloc.editStream.listen((event) {
      if(event == Constant.success) {
        Navigator.pop(context, event);
      }
    });

    List<SelectedAnswers> initialSelectedAnswerList = [];

    _initialSelectedAnswerListJson = Constant.blankString;

    if(widget.moreMedicationArgumentModel.selectedAnswerList != null && widget.moreMedicationArgumentModel.selectedAnswerList!.length > 0) {
      initialSelectedAnswerList.addAll(widget.moreMedicationArgumentModel.selectedAnswerList ?? []);

      initialSelectedAnswerList.removeWhere((element) => element.questionTag == Constant.headacheTriggerTag);

      if(initialSelectedAnswerList.length > 0)
        _initialSelectedAnswerListJson = jsonEncode(initialSelectedAnswerList);
    }
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(_checkIfAnyChangesMade()) {
          _showSaveAndExitBottomSheet();
          return false;
        } else {
          return true;
        }
      },
      child: Container(
        decoration: Constant.backgroundBoxDecoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
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
                        if(_checkIfAnyChangesMade())
                          _showSaveAndExitBottomSheet();
                        else
                          Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Constant.moreBackgroundColor,
                        ),
                        child: Row(
                          children: [
                            Image(
                              width: 16,
                              height: 16,
                              image: AssetImage(Constant.leftArrow),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CustomTextWidget(
                              text: Constant.myProfile,
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
                    SignUpBottomSheet(
                      isFromOnboard: false,
                      question: Questions(tag: 'headache.medications', values: widget.moreMedicationArgumentModel.medicationValues),
                      isFromMoreScreen: true,
                      selectAnswerListData: widget.moreMedicationArgumentModel.selectedAnswerList ?? [],
                      selectAnswerCallback: (question, valuesList) async {
                        SelectedAnswers? medicationSelectedAnswer = widget.moreMedicationArgumentModel.selectedAnswerList?.firstWhereOrNull((element) => element.questionTag == 'headache.medications');
                        if(medicationSelectedAnswer != null) {
                          medicationSelectedAnswer.answer = jsonEncode(valuesList);
                        } else {
                          widget.moreMedicationArgumentModel.selectedAnswerList!.add(SelectedAnswers(questionTag: 'headache.medications', answer: jsonEncode(valuesList)));
                        }
                      },
                      openTriggerMedicationActionSheetCallback: widget.openTriggerMedicationActionSheetCallback,
                    ),
                    SizedBox(height: 40,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomTextWidget(
                        text: Constant.whichOfTheFollowingMedication,
                        style: TextStyle(
                            color: Constant.locationServiceGreen,
                            fontSize: 14,
                            fontFamily: Constant.jostMedium
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSaveAndExitBottomSheet() async {
    var resultFromActionSheet = await widget.openActionSheetCallback(Constant.saveAndExitActionSheet, null);
    if(resultFromActionSheet != null && resultFromActionSheet is String) {
      if(resultFromActionSheet == Constant.saveAndExit) {
        //call edit info api
        SelectedAnswers? selectedAnswers = widget.moreMedicationArgumentModel.selectedAnswerList?.firstWhereOrNull((element) => element.questionTag == 'headache.medications');
        if(selectedAnswers != null) {
          _bloc.initNetworkStreamController();
          widget.showApiLoaderCallback(_bloc.networkStream, () {
            _bloc.enterLoadingDataToNetworkStreamController();
            _bloc.callEditApi(widget.moreMedicationArgumentModel.eventId ?? '',
                widget.moreMedicationArgumentModel.selectedAnswerList ?? [],
                widget.moreMedicationArgumentModel.responseModel!, context);
          });
          _bloc.callEditApi(widget.moreMedicationArgumentModel.eventId ?? '',
              widget.moreMedicationArgumentModel.selectedAnswerList ?? [],
              widget.moreMedicationArgumentModel.responseModel!, context);
        }
      } else {
        Navigator.pop(context, resultFromActionSheet);
      }
    }
  }

  bool _checkIfAnyChangesMade() {
    bool isChangesMade = false;
    if(widget.moreMedicationArgumentModel.selectedAnswerList != null) {
      List<SelectedAnswers> selectedAnswerList = [];

      selectedAnswerList.addAll(widget.moreMedicationArgumentModel.selectedAnswerList ?? []);

      selectedAnswerList.removeWhere((element) => element.questionTag == Constant.headacheTriggerTag);


      String selectedAnswerListJson = Constant.blankString;

      if(selectedAnswerList.length > 0) {
        selectedAnswerListJson = jsonEncode(selectedAnswerList);
      }

      if (_initialSelectedAnswerListJson.isEmpty) {
        isChangesMade = selectedAnswerList.length > 0;
      } else {
        isChangesMade = _initialSelectedAnswerListJson != selectedAnswerListJson;
      }
    }

    return isChangesMade;
  }
}