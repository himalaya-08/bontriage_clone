import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/LogDayQuestionnaire.dart';
import 'package:mobile/models/MedicationSelectedDataModel.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/TriggerWidgetModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CircleLogOptions.dart';
import 'package:mobile/view/CustomRichTextWidget.dart';
import 'package:mobile/view/CustomTextFormFieldWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/LogDayChipList.dart';
import 'package:mobile/view/TonixLogDayMedicationListActionSheet.dart';
import 'package:mobile/view/TonixTimeSection.dart';
import 'package:mobile/view/sign_up_age_screen.dart';
import 'package:provider/provider.dart';

import 'package:collection/collection.dart';

import 'LogDayMedidcationListActionSheet.dart';
import 'TonixAddHeadacheScreen.dart';

class TonixAddHeadacheSection extends StatefulWidget {
  final String headerText;
  final String subText;
  final String contentType;
  final String selectedCurrentValue;
  String? questionType;
  final double min;
  final double max;
  List<Questions>? allQuestionsList;
  List<Questions>? sleepExpandableWidgetList;
  final List<Questions>? dosageQuestionList;
  List<Questions>? genericMedicationQuestionList;
  List<Questions>? dosageTypeQuestionList;
  List<Questions>? triggerExpandableWidgetList;
  final List<Values> valuesList;
  List<Values>? chipsValuesList;
  final Function(String, String) addHeadacheDetailsData;
  final Function(String, String) removeHeadacheTypeData;
  final Function moveWelcomeOnBoardTwoScreen;
  final String? updateAtValue;
  final List<SelectedAnswers> selectedAnswers;
  List<SelectedAnswers>? doubleTapSelectedAnswer;
  final bool isHeadacheEnded;
  final CurrentUserHeadacheModel currentUserHeadacheModel;
  final bool isFromRecordsScreen;
  final String uiHints;
  DateTime? selectedDateTime;

  final List<List<SelectedAnswers>> medicationSelectedAnswerList;
  final Questions? headacheMigraineQuestion;
  List<Map>? recentMedicationMapList;
  final bool isMedicationLoggedEmpty;

  TonixAddHeadacheSection(
      {Key? key,
        required this.headerText,
        required this.subText,
        required this.contentType,
        required this.min,
        required this.max,
        required this.valuesList,
        this.chipsValuesList,
        this.sleepExpandableWidgetList,
        required this.dosageQuestionList,
        required this.addHeadacheDetailsData,
        required this.removeHeadacheTypeData,
        required this.selectedCurrentValue,
        required this.updateAtValue,
        required this.moveWelcomeOnBoardTwoScreen,
        this.triggerExpandableWidgetList,
        this.questionType,
        this.allQuestionsList,
        required this.selectedAnswers,
        required this.isHeadacheEnded,
        required this.currentUserHeadacheModel,
        this.doubleTapSelectedAnswer,
        this.isFromRecordsScreen = false,
        required this.uiHints,
        this.selectedDateTime,
        required this.medicationSelectedAnswerList,
        required this.headacheMigraineQuestion,
        this.dosageTypeQuestionList,
        this.genericMedicationQuestionList,
        this.recentMedicationMapList,
        this.isMedicationLoggedEmpty = false})
      : super(key: key);

  @override
  _TonixAddHeadacheSectionState createState() => _TonixAddHeadacheSectionState();
}

class _TonixAddHeadacheSectionState extends State<TonixAddHeadacheSection>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  int _numberOfSleepItemSelected = 0;
  int _whichSleepItemSelected = 0;
  List<int> _whichMedicationItemSelected = [];
  int _whichTriggerItemSelected = 0;
  bool _isValuesUpdated = false;
  List<List<String>> _medicineTimeList = [];
  List<List<Questions>> _medicationDosageList = [];
  MedicationSelectedDataModel? _medicationSelectedDataModel;
  List<TriggerWidgetModel> _triggerWidgetList = [];
  String? _previousMedicationTag;
  List<SelectedAnswers> _selectedAnswerListOfTriggers = [];
  List<List<String>> _additionalMedicationDosage = [];
  List<Values> _medicationList = [];
  List<Values> _medicationValueSelectedList = [];

  ///Method to get section widget
  Widget _getSectionWidget() {
    switch (widget.contentType) {
      case 'headacheType':
        var value = widget.valuesList.firstWhereOrNull(
                (model) => model.text == Constant.plusText,);
        if (value == null) {
          /*widget.valuesList.add(Values(
              text: Constant.plusText,
              valueNumber: widget.valuesList.length.toString()));*/
        }

        if (widget.selectedAnswers != null) {
          SelectedAnswers? selectedAnswers = widget.selectedAnswers.firstWhereOrNull(
                  (element) => element.questionTag == widget.contentType);

          if (selectedAnswers != null) {
            Values? selectedValue = widget.valuesList.firstWhere(
                    (element) => element.text == selectedAnswers.answer);
            if (selectedValue != null) {
              selectedValue.isSelected = true;
              if(selectedValue.text == Constant.migraineProbableMigraine)
                _animationController!.forward();
            }
          }
        }
        return _getWidget(Consumer<TonixHeadacheTypeInfo>(
          builder: (context, data, child) {
            return CircleLogOptions(
              logOptions: widget.valuesList,
              onCircleItemSelected: _onHeadacheTypeItemSelected,
            );
          },
        ));
      case 'onset':
        return _getWidget(TonixTimeSection(
          currentTag: widget.contentType,
          updatedDateValue: widget.updateAtValue!,
          addHeadacheDateTimeDetailsData: _onHeadacheDateTimeSelected,
          isHeadacheEnded: widget.isHeadacheEnded,
          currentUserHeadacheModel: widget.currentUserHeadacheModel,
        ));
      case 'severity':
        String? selectedCurrentValue;
        if (widget.selectedAnswers != null) {
          SelectedAnswers? intensitySelectedAnswer = widget.selectedAnswers
              .firstWhereOrNull((element) => element.questionTag == 'severity');
          if (intensitySelectedAnswer != null) {
            selectedCurrentValue = intensitySelectedAnswer.answer;
          } else {
            widget.selectedAnswers.add(SelectedAnswers(
                questionTag: 'severity',
                answer: widget.min.toInt().toString()));
          }
        }

        if (selectedCurrentValue == null)
          selectedCurrentValue = widget.selectedCurrentValue;
        return _getWidget(/*SignUpAgeScreen(
          sliderValue:
              (selectedCurrentValue == null || selectedCurrentValue.isEmpty)
                  ? widget.min
                  : double.parse(selectedCurrentValue),
          minText: Constant.one,
          maxText: Constant.ten,
          currentTag: widget.contentType,
          sliderMinValue: widget.min,
          sliderMaxValue: widget.max,
          minTextLabel: Constant.mild,
          maxTextLabel: Constant.veryPainful,
          labelText: '',
          horizontalPadding: 0,
          selectedAnswerCallBack: _onHeadacheIntensitySelected,
          isAnimate: false,
          uiHints: widget.uiHints,
        )*/_getHeadacheIntensityWidget());
/*      case 'disability':
        String selectedCurrentValue;
        if (widget.selectedAnswers != null) {
          SelectedAnswers intensitySelectedAnswer = widget.selectedAnswers
              .firstWhere((element) => element.questionTag == 'disability',
                  orElse: () => null);
          if (intensitySelectedAnswer != null) {
            selectedCurrentValue = intensitySelectedAnswer.answer;
          } else {
            widget.selectedAnswers.add(SelectedAnswers(
                questionTag: 'disability',
                answer: widget.min.toInt().toString()));
          }
        }

        if (selectedCurrentValue == null)
          selectedCurrentValue = widget.selectedCurrentValue;
        return _getWidget(SignUpAgeScreen(
          sliderValue:
              (selectedCurrentValue == null || selectedCurrentValue.isEmpty)
                  ? widget.min
                  : double.parse(selectedCurrentValue),
          minText: Constant.one,
          maxText: Constant.ten,
          currentTag: widget.contentType,
          sliderMinValue: widget.min,
          sliderMaxValue: widget.max,
          minTextLabel: Constant.noneAtALL,
          maxTextLabel: Constant.totalDisability,
          labelText: '',
          horizontalPadding: 0,
          selectedAnswerCallBack: _onHeadacheIntensitySelected,
          isAnimate: false,
          uiHints: widget.uiHints,
        ));*/

      case 'behavior.presleep':
        if (!_isValuesUpdated) {
          _isValuesUpdated = true;
          Values? value = widget.valuesList.firstWhereOrNull(
                  (element) => element.isDoubleTapped || element.isSelected);
          if (value != null) {
            try {
              _onSleepItemSelected(int.parse(value.valueNumber!) - 1);
            } catch (e) {
              print(e.toString());
            }
          }
        }

        _numberOfSleepItemSelected = 0;
        widget.sleepExpandableWidgetList![0].values!.forEach((element) {
          if (element.isSelected != null && element.isSelected) {
            _numberOfSleepItemSelected++;
          }
        });

        Values? selectedExpandedSleepItemValue = widget
            .sleepExpandableWidgetList![0].values
            !.firstWhereOrNull((element) => element.isSelected);
        return _getWidget(CircleLogOptions(
          logOptions: widget.valuesList,
          preCondition: widget.sleepExpandableWidgetList![0].precondition!,
          overlayNumber: _numberOfSleepItemSelected,
          onCircleItemSelected: _onSleepItemSelected,
          onDoubleTapItem: _onDoubleTapItem,
          isAnySleepItemSelected: selectedExpandedSleepItemValue != null,
          currentTag: widget.contentType,
        ));
      case 'behavior.premeal':
        return _getWidget(CircleLogOptions(
          logOptions: widget.valuesList,
          onDoubleTapItem: _onDoubleTapItem,
          onCircleItemSelected: _onExerciseItemSelected,
          currentTag: widget.contentType,
        ));
      case 'behavior.preexercise':
        return _getWidget(CircleLogOptions(
          logOptions: widget.valuesList,
          onDoubleTapItem: _onDoubleTapItem,
          onCircleItemSelected: _onExerciseItemSelected,
          currentTag: widget.contentType,
        ));
      case Constant.logDayMedicationTag:
        return _getWidget(CircleLogOptions(
          logOptions: _medicationList,
          currentTag: widget.contentType,
          dosageTypeQuestionList: widget.dosageTypeQuestionList,
          genericMedicationQuestionList: widget.genericMedicationQuestionList,
          questionType: 'multi',
          onCircleItemSelected: _onMedicationItemSelected,
        ));
      case 'triggers1':
        if (!_isValuesUpdated) {
          _isValuesUpdated = true;
          widget.valuesList.asMap().forEach((index, element) {
            if (element.isSelected || element.isDoubleTapped) {
              print('coming in here');
              _animationController!.forward();
              /*Future.delayed(Duration(milliseconds: index * 400), () {
                _onTriggerItemSelected(index);
              });*/

              SelectedAnswers? selectedAnswersValue = widget.selectedAnswers
                  .firstWhereOrNull(
                      (element1) =>
                  element1.questionTag == widget.contentType &&
                      element1.answer == element.text);
              if (selectedAnswersValue == null)
                widget.selectedAnswers.add(SelectedAnswers(
                    questionTag: widget.contentType, answer: element.text));

              Questions? questionTriggerData = widget.triggerExpandableWidgetList
                  !.firstWhereOrNull(
                      (element1) =>
                      element1.precondition!.contains(element.text!));
              if (questionTriggerData != null) {
                SelectedAnswers? selectedAnswerTriggerData =
                _selectedAnswerListOfTriggers.firstWhereOrNull(
                        (element1) =>
                    element1.questionTag == questionTriggerData.tag);
                if (selectedAnswerTriggerData != null) {
                  SelectedAnswers? selectedAnswerData = widget.selectedAnswers
                      .firstWhereOrNull(
                          (element1) =>
                      element1.questionTag ==
                          selectedAnswerTriggerData.questionTag &&
                          element1.answer ==
                              selectedAnswerTriggerData.answer);
                  if (selectedAnswerData == null) {
                    widget.selectedAnswers.add(SelectedAnswers(
                        questionTag: selectedAnswerTriggerData.questionTag,
                        answer: selectedAnswerTriggerData.answer));
                  } else {
                    selectedAnswerData.answer =
                        selectedAnswerTriggerData.answer;
                  }
                }
              }

              _generateTriggerWidgetList(index);
            }
          });
        }
        return _getWidget(CircleLogOptions(
          logOptions: widget.valuesList,
          questionType: widget.questionType!,
          onCircleItemSelected: _onTriggerItemSelected,
          onDoubleTapItem: _onDoubleTapItem,
          currentTag: widget.contentType,
        ));
      default:
        return Container();
    }
  }

  void _onHeadacheTypeItemSelected(int index) {
    if (widget.valuesList[index].text == Constant.plusText) {
      widget.moveWelcomeOnBoardTwoScreen();
    } else {
      Values headacheTypeValue = widget.valuesList[index];
      if (headacheTypeValue.isSelected) {
        if(headacheTypeValue.text == Constant.migraineProbableMigraine) {
          _animationController!.forward();

          SelectedAnswers? headacheTypeSelectedAnswer = widget.selectedAnswers.firstWhereOrNull((element) => element.questionTag == Constant.headacheTypeTag);

          if(headacheTypeSelectedAnswer != null)
            headacheTypeSelectedAnswer.answer = headacheTypeValue.text;
          else
            widget.selectedAnswers.add(SelectedAnswers(questionTag: Constant.headacheTypeTag, answer: headacheTypeValue.text));

          _addMultiValuesToSelectedAnswer(widget.headacheMigraineQuestion!);
        } else {
          SelectedAnswers? headacheMigraineSelectedAnswer = widget.selectedAnswers.firstWhereOrNull((element) => element.questionTag == Constant.headacheMigraineTag);

          if(headacheMigraineSelectedAnswer == null)
            widget.selectedAnswers.add(SelectedAnswers(questionTag: widget.headacheMigraineQuestion!.tag, answer: jsonEncode([])));
          else
            headacheMigraineSelectedAnswer.answer = jsonEncode([]);

          _animationController!.reverse();
        }
        widget.addHeadacheDetailsData(
            widget.contentType, headacheTypeValue.text!);
      } else {
        SelectedAnswers? headacheMigraineSelectedAnswer = widget.selectedAnswers.firstWhereOrNull((element) => element.questionTag == Constant.headacheMigraineTag);

        if(headacheMigraineSelectedAnswer == null)
          widget.selectedAnswers.add(SelectedAnswers(questionTag: widget.headacheMigraineQuestion!.tag, answer: jsonEncode([])));
        else
          headacheMigraineSelectedAnswer.answer = jsonEncode([]);

        //widget.selectedAnswers.removeWhere((element) => element.questionTag == Constant.headacheMigraineTag);
        _animationController!.reverse();
        widget.removeHeadacheTypeData(widget.contentType, headacheTypeValue.text!);
      }
    }
  }

  void _onHeadacheIntensitySelected(String currentTag, String currentValue) {
    widget.addHeadacheDetailsData(currentTag, currentValue);
  }

  void _onHeadacheDateTimeSelected(String currentTag, String currentValue) {
    widget.addHeadacheDetailsData(currentTag, currentValue);
  }

  void _onDoubleTapItem(String currentTag, String selectedAnswer,
      String questionType, bool isDoubleTapped, int index) {
    _whichSleepItemSelected = index;

    int? indexValue = _whichMedicationItemSelected
        .firstWhereOrNull((element) => element == index);

    if (indexValue == null) _whichMedicationItemSelected.add(index);

    _whichTriggerItemSelected = index;

    if (widget.contentType == 'medication')
      _updateMedicationSelectedDataModel();

    if (widget.valuesList[index].text!.toLowerCase() == Constant.none) {
      setState(() {
        debugPrint('set State6');
        widget.valuesList.asMap().forEach((key, element) {
          if (index != key) {
            element
              ..isSelected = false
              ..isDoubleTapped = false;
          }
        });
        _triggerWidgetList.clear();
      });

      widget.selectedAnswers
          .removeWhere((element) => element.questionTag!.contains('triggers1'));
      widget.doubleTapSelectedAnswer
          !.removeWhere((element) => element.questionTag!.contains('triggers1'));
    }

    if (isDoubleTapped) {
      if (questionType == 'multi') {
        SelectedAnswers? selectedAnswerValue = widget.selectedAnswers.firstWhereOrNull(
                (element) => (element.questionTag == currentTag &&
                element.answer == selectedAnswer));
        if (selectedAnswerValue == null) {
          widget.selectedAnswers.add(
              SelectedAnswers(questionTag: currentTag, answer: selectedAnswer));
        }

        SelectedAnswers? doubleTapSelectedAnswer = widget.doubleTapSelectedAnswer
            !.firstWhereOrNull(
                (element) => (element.questionTag == currentTag &&
                element.answer == selectedAnswer));
        if (doubleTapSelectedAnswer == null)
          widget.doubleTapSelectedAnswer!.add(
              SelectedAnswers(questionTag: currentTag, answer: selectedAnswer));
      } else {
        widget.selectedAnswers.removeWhere(
                (element) => element.questionTag == widget.contentType);
        SelectedAnswers? selectedAnswerObj = widget.selectedAnswers.firstWhereOrNull(
                (element) =>
            element.questionTag == currentTag &&
                element.answer == selectedAnswer);
        if (selectedAnswerObj == null) {
          widget.selectedAnswers.add(
              SelectedAnswers(questionTag: currentTag, answer: selectedAnswer));
        } else {
          selectedAnswerObj.answer = selectedAnswer;
        }

        widget.doubleTapSelectedAnswer!.removeWhere(
                (element) => element.questionTag == widget.contentType);
        SelectedAnswers? doubleTapSelectedAnswerObj = widget
            .doubleTapSelectedAnswer
            !.firstWhereOrNull((element) => element.questionTag == currentTag);
        if (doubleTapSelectedAnswerObj == null) {
          widget.doubleTapSelectedAnswer!.add(
              SelectedAnswers(questionTag: currentTag, answer: selectedAnswer));
        } else {
          doubleTapSelectedAnswerObj.answer = selectedAnswer;
        }
      }
    } else {
      if (questionType == 'multi') {
        List<SelectedAnswers> selectedAnswerList = [];
        widget.selectedAnswers.forEach((element) {
          if (element.questionTag == currentTag &&
              element.answer == selectedAnswer) {
            selectedAnswerList.add(element);
          }
        });

        selectedAnswerList.forEach((element) {
          widget.selectedAnswers.remove(element);
        });

        List<SelectedAnswers> doubleTapSelectedAnswerList = [];
        widget.doubleTapSelectedAnswer!.forEach((element) {
          if (element.questionTag == currentTag &&
              element.answer == selectedAnswer) {
            doubleTapSelectedAnswerList.add(element);
          }
        });

        doubleTapSelectedAnswerList.forEach((element) {
          widget.doubleTapSelectedAnswer!.remove(element);
        });
      } else {
        SelectedAnswers? selectedAnswerObj = widget.selectedAnswers.firstWhereOrNull(
                (element) => element.questionTag == currentTag);

        if (selectedAnswerObj != null) {
          widget.selectedAnswers.remove(selectedAnswerObj);
        }

        SelectedAnswers? doubleTapSelectedAnswerObj = widget
            .doubleTapSelectedAnswer
            !.firstWhereOrNull((element) => element.questionTag == currentTag);

        if (doubleTapSelectedAnswerObj != null) {
          widget.doubleTapSelectedAnswer!.remove(doubleTapSelectedAnswerObj);
        }
      }
    }
    storeExpandableViewSelectedData(isDoubleTapped);
    storeLogDayDataIntoDatabase();
    print(widget.selectedAnswers.length);
  }

  void storeExpandableViewSelectedData(bool isDoubleTapped) {
    switch (widget.contentType) {
      case 'behavior.presleep':
        String text = widget.valuesList[_whichSleepItemSelected].text!;
        String preCondition = widget.sleepExpandableWidgetList![0].precondition!;

        if (preCondition.contains(text)) {
          List<Values> values = widget.sleepExpandableWidgetList![0].values!;
          values.forEach((element) {
            if (element.isSelected) {
              SelectedAnswers? selectedAnswers = widget.selectedAnswers
                  .firstWhereOrNull(
                      (element1) =>
                  element1.questionTag == 'behavior.sleep' &&
                      element1.answer == element.valueNumber);
              if (selectedAnswers == null)
                widget.selectedAnswers.add(SelectedAnswers(
                    questionTag: 'behavior.sleep',
                    answer: element.valueNumber));

              SelectedAnswers? doubleTapSelectedAnswer =
              widget.doubleTapSelectedAnswer!.firstWhereOrNull(
                      (element1) =>
                  element1.questionTag == 'behavior.sleep' &&
                      element1.answer == element.valueNumber);
              if (doubleTapSelectedAnswer == null)
                widget.doubleTapSelectedAnswer!.add(SelectedAnswers(
                    questionTag: 'behavior.sleep',
                    answer: element.valueNumber));
            }
          });
        } else {
          widget.selectedAnswers.removeWhere(
                  (element) => element.questionTag == 'behavior.sleep');
          widget.doubleTapSelectedAnswer!.removeWhere(
                  (element) => element.questionTag == 'behavior.sleep');
        }
        break;
      case 'medication':
        if (isDoubleTapped) {
          SelectedAnswers? selectedAnswers = widget.selectedAnswers.firstWhereOrNull(
                  (element) => element.questionTag == 'administered');

          if (selectedAnswers == null) {
            if (_medicationSelectedDataModel != null) {
              if (_medicationSelectedDataModel
                  !.selectedMedicationIndex.isNotEmpty)
                widget.selectedAnswers.add(SelectedAnswers(
                    questionTag: 'administered',
                    answer: medicationSelectedDataModelToJson(
                        _medicationSelectedDataModel!)));
            }
          } else {
            if (_medicationSelectedDataModel != null) {
              if (_medicationSelectedDataModel
                  !.selectedMedicationIndex.isNotEmpty)
                selectedAnswers.answer = medicationSelectedDataModelToJson(
                    _medicationSelectedDataModel!);
              else
                widget.selectedAnswers.removeWhere(
                        (element) => element.questionTag == 'administered');
            }
          }
        } else {
          if (_medicationSelectedDataModel!.selectedMedicationIndex.isEmpty)
            widget.selectedAnswers.removeWhere(
                    (element) => element.questionTag == 'administered');
        }

        MedicationSelectedDataModel medicationSelectedDataModel =
        MedicationSelectedDataModel.fromJson(
            jsonDecode(jsonEncode(_medicationSelectedDataModel)));

        List<Values> nonDoubleTappedMedicationList = [];
        List<List<String>> nonDoubleTappedDosageList = [];
        List<List<String>> nonDoubleTappedDateList = [];

        medicationSelectedDataModel.selectedMedicationIndex
            .asMap()
            .forEach((index, element) {
          if (!element.isDoubleTapped) {
            nonDoubleTappedMedicationList.add(element);

            nonDoubleTappedDosageList.add(medicationSelectedDataModel
                .selectedMedicationDosageList![index]);
            nonDoubleTappedDateList.add(
                medicationSelectedDataModel.selectedMedicationDateList![index]);
          }
        });

        medicationSelectedDataModel.selectedMedicationIndex
            !.retainWhere((element) => element.isDoubleTapped);

        nonDoubleTappedDosageList.forEach((element) {
          medicationSelectedDataModel.selectedMedicationDosageList
              !.remove(element);
        });

        nonDoubleTappedDateList.forEach((element) {
          medicationSelectedDataModel.selectedMedicationDateList
              !.remove(element);
        });

        print(
            'BeforeLengthOfMeds???${medicationSelectedDataModel.selectedMedicationIndex!.length}');

        print('Meds???${medicationSelectedDataModel.selectedMedicationIndex}');

        medicationSelectedDataModel.selectedMedicationIndex
            !.retainWhere((element) => element.isDoubleTapped);

        print(
            'AfterLengthOfMeds???${medicationSelectedDataModel.selectedMedicationIndex!.length}');

        if (isDoubleTapped) {
          SelectedAnswers? selectedAnswers = widget.doubleTapSelectedAnswer
              !.firstWhereOrNull((element) => element.questionTag == 'administered');
          if (selectedAnswers == null) {
            if (_medicationSelectedDataModel != null) {
              if (_medicationSelectedDataModel
                  !.selectedMedicationIndex!.isNotEmpty)
                widget.doubleTapSelectedAnswer!.add(SelectedAnswers(
                    questionTag: 'administered',
                    answer: medicationSelectedDataModelToJson(
                        _medicationSelectedDataModel!)));
            }
            //print('MedicationDataDoubleTappedSave???${widget.doubleTapSelectedAnswer.last.answer}');
          } else {
            if (_medicationSelectedDataModel != null) {
              if (_medicationSelectedDataModel
                  !.selectedMedicationIndex!.isNotEmpty)
                selectedAnswers.answer = medicationSelectedDataModelToJson(
                    _medicationSelectedDataModel!);
              else
                widget.doubleTapSelectedAnswer!.removeWhere(
                        (element) => element.questionTag == 'administered');
            }
            //print('MedicationDataDoubleTappedSave???${selectedAnswers.answer}');
          }
        } else {
          MedicationSelectedDataModel medicationSelectedDataModel =
          MedicationSelectedDataModel.fromJson(
              jsonDecode(jsonEncode(_medicationSelectedDataModel)));

          print(
              'BeforeLengthOfMeds???${medicationSelectedDataModel.selectedMedicationIndex!.length}');

          medicationSelectedDataModel.selectedMedicationIndex
              !.retainWhere((element) => element.isDoubleTapped);

          print(
              'AfterLengthOfMeds???${medicationSelectedDataModel.selectedMedicationIndex!.length}');

          if (medicationSelectedDataModel.selectedMedicationIndex!.isEmpty)
            widget.doubleTapSelectedAnswer!.removeWhere(
                    (element) => element.questionTag == 'administered');
        }
        break;
      case 'triggers1':
        widget.valuesList.forEach((element) {
          if (element.isDoubleTapped && element.isSelected) {
            Questions? questionTriggerData = widget.triggerExpandableWidgetList
                !.firstWhereOrNull(
                    (element1) => element1.precondition!.contains(element.text!));
            if (questionTriggerData != null) {
              SelectedAnswers? selectedAnswerTriggerData =
              _selectedAnswerListOfTriggers.firstWhereOrNull(
                      (element1) =>
                  element1.questionTag == questionTriggerData.tag);
              if (selectedAnswerTriggerData != null) {
                SelectedAnswers? selectedAnswerData = widget.selectedAnswers
                    .firstWhereOrNull(
                        (element1) =>
                    element1.questionTag ==
                        selectedAnswerTriggerData.questionTag);
                if (selectedAnswerData == null) {
                  widget.selectedAnswers.add(SelectedAnswers(
                      questionTag: selectedAnswerTriggerData.questionTag,
                      answer: selectedAnswerTriggerData.answer));
                } else {
                  selectedAnswerData.answer = selectedAnswerTriggerData.answer;
                }
              }
            }
          }
        });

        widget.valuesList.forEach((element) {
          if (element.isDoubleTapped && element.isSelected) {
            Questions? questionTriggerData = widget.triggerExpandableWidgetList
                !.firstWhereOrNull(
                    (element1) => element1.precondition!.contains(element.text!));
            if (questionTriggerData != null) {
              SelectedAnswers? selectedAnswerTriggerData =
              _selectedAnswerListOfTriggers.firstWhereOrNull(
                      (element1) =>
                  element1.questionTag == questionTriggerData.tag);
              if (selectedAnswerTriggerData != null) {
                SelectedAnswers? selectedAnswerData =
                widget.doubleTapSelectedAnswer!.firstWhereOrNull(
                        (element1) =>
                    element1.questionTag ==
                        selectedAnswerTriggerData.questionTag);
                if (selectedAnswerData == null) {
                  widget.doubleTapSelectedAnswer!.add(SelectedAnswers(
                      questionTag: selectedAnswerTriggerData.questionTag,
                      answer: selectedAnswerTriggerData.answer));
                } else {
                  selectedAnswerData.answer = selectedAnswerTriggerData.answer;
                }
              }
            }
          }
        });
        break;
    }
  }

  void storeLogDayDataIntoDatabase() async {
    print(widget.doubleTapSelectedAnswer);
    List<Map>? userLogDataMap;
    var userProfileInfoData =
    await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    if (userProfileInfoData != null)
      userLogDataMap = await SignUpOnBoardProviders.db
          .getLogDayData(userProfileInfoData.userId!);
    else
      userLogDataMap = await SignUpOnBoardProviders.db.getLogDayData('4214');

    if (userLogDataMap == null || userLogDataMap.length == 0) {
      LogDayQuestionnaire logDayQuestionnaire = LogDayQuestionnaire();
      var userProfileInfoData =
      await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
      if (userProfileInfoData != null)
        logDayQuestionnaire.userId = userProfileInfoData.userId;
      else
        logDayQuestionnaire.userId = '4214';

      logDayQuestionnaire.selectedAnswers =
          jsonEncode(widget.doubleTapSelectedAnswer);
      SignUpOnBoardProviders.db.insertLogDayData(logDayQuestionnaire);
    } else {
      var userProfileInfoData =
      await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

      if (userProfileInfoData != null)
        SignUpOnBoardProviders.db.updateLogDayData(
            jsonEncode(widget.doubleTapSelectedAnswer),
            userProfileInfoData.userId!);
      else
        SignUpOnBoardProviders.db.updateLogDayData(
            jsonEncode(widget.doubleTapSelectedAnswer), '4214');
    }
  }

  void _onSleepItemSelected(int index) {
    String preCondition = widget.sleepExpandableWidgetList![0].precondition!;
    String text = widget.valuesList[index].text!;
    String valueNumber = widget.valuesList[index].valueNumber!;
    bool isSelected = widget.valuesList[index].isSelected;

    _whichSleepItemSelected = index;

    _updateSelectedAnswerListWhenCircleItemSelected(valueNumber, isSelected);

    if (preCondition.contains(text) && isSelected) {
      _animationController!.forward();
      _storeExpandedWidgetDataIntoLocalModel();
    } else {
      _animationController!.reverse();
      widget.selectedAnswers.removeWhere((element) =>
      element.questionTag == widget.sleepExpandableWidgetList![0].tag);
      widget.doubleTapSelectedAnswer!.removeWhere((element) =>
      element.questionTag == widget.sleepExpandableWidgetList![0].tag);
    }
  }

  void _onExerciseItemSelected(int index) {
    String valueNumber = widget.valuesList![index].valueNumber!;
    bool isSelected = widget.valuesList[index].isSelected;
    _updateSelectedAnswerListWhenCircleItemSelected(valueNumber, isSelected);
  }

  void _onTriggerItemSelected(int index) {
    setState(() {
      debugPrint('set State5');
      _whichTriggerItemSelected = index;
    });

    Values? value = widget.valuesList
        .firstWhereOrNull((element) => element.isSelected);

    if (value != null) {
      _animationController!.forward();
    } else {
      _animationController!.reverse();
    }

    String valueNumber = widget.valuesList[index].valueNumber!;
    String valueText = widget.valuesList[index].text!;
    bool isSelected = widget.valuesList[index].isSelected;

    if (valueText.toLowerCase() == Constant.none && isSelected) {
      setState(() {
        debugPrint('set State4');
        widget.valuesList.asMap().forEach((key, element) {
          if (index != key) {
            element
              ..isSelected = false
              ..isDoubleTapped = false;
          }
        });
        _triggerWidgetList.clear();
      });

      widget.selectedAnswers
          .removeWhere((element) => element.questionTag!.contains('triggers1'));
    } else if (isSelected) {
      Values? noneValue = widget.valuesList.firstWhereOrNull(
              (element) => element.text!.toLowerCase() == Constant.none);
      if (noneValue != null) {
        setState(() {
          debugPrint('set State3');
          noneValue
            ..isSelected = false
            ..isDoubleTapped = false;
        });
      }

      //'1' for none option
      widget.selectedAnswers.removeWhere((element) =>
      element.questionTag == 'triggers1' && element.answer == '1');
    }

    if (!isSelected) {
      Questions? triggerExpandableQuestionObj =
      widget.triggerExpandableWidgetList!.firstWhereOrNull(
              (element) => element.precondition
              !.toLowerCase()
              .contains(valueText.toLowerCase()));
      if (triggerExpandableQuestionObj != null)
        widget.selectedAnswers.removeWhere((element) =>
        element.questionTag == triggerExpandableQuestionObj.tag);
    }

    _updateSelectedAnswerListWhenCircleItemSelected(valueNumber, isSelected);
    _storeExpandedWidgetDataIntoLocalModel();
  }

  ///Method to get sectional widget
  ///[mainWidget] is the widget holding circle options or the sliders.
  Widget _getWidget(Widget mainWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CustomTextWidget(
                  text: widget.headerText,
                  style: TextStyle(
                      fontSize: Platform.isAndroid ? 16 : 17,
                      color: Constant.chatBubbleGreen,
                      fontFamily: Constant.jostMedium),
                ),
              ),
              Visibility(
                visible: widget.contentType == Constant.logDayMedicationTag,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _openSearchMedicationActionSheet();
                  },
                  child: Icon(
                    Icons.search,
                    color: Constant.chatBubbleGreen,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 7,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Consumer<TonixAddHeadacheSectionSubTextInfo>(
              builder: (context, data, child) {
                SelectedAnswers? headacheTypeSelectedAnswer = widget.selectedAnswers.firstWhereOrNull((element) => element.questionTag == Constant.headacheTypeTag);
                String headacheTypeSelected = (headacheTypeSelectedAnswer != null) ? headacheTypeSelectedAnswer.answer! : Constant.noHeadacheValue;

                return CustomTextWidget(
                  text: (widget.contentType == Constant.logDayMedicationTag) ? (headacheTypeSelected == Constant.noHeadacheValue) ? Constant.noHeadacheMedication : widget.subText : widget.subText,
                  style: TextStyle(
                      fontSize: Platform.isAndroid ? 14 : 15,
                      color: Constant.locationServiceGreen,
                      fontFamily: Constant.jostRegular),
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        mainWidget,
        SizeTransition(
          sizeFactor: _animationController!,
          child: FadeTransition(
              opacity: _animationController!,
              child: AnimatedSize(
                alignment: Alignment.bottomLeft,
                //vsync: this,
                duration: Duration(milliseconds: 350),
                child: _getOptionOnSelectWidget(),
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Divider(
            height: 40,
            thickness: 0.5,
            color: Constant.chatBubbleGreen,
          ),
        ),
      ],
    );
  }

  /// This method is used to get the widget which will get displayed when user select any option of any of a section
  Widget _getOptionOnSelectWidget() {
    switch (widget.contentType) {
      case 'headacheType':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomTextWidget(
                text: '${widget.headacheMigraineQuestion!.helpText}\n\nCHECK ALL SYMPTOMS THAT APPLY:',
                style: TextStyle(
                    color: Constant.locationServiceGreen,
                    fontFamily: Constant.jostRegular,
                    fontWeight: FontWeight.w500,
                    fontSize: Platform.isAndroid ? 14 : 15),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(right: 15),
              child: _getHeadacheTypeCheckListWidget(widget.headacheMigraineQuestion!),
            ),
          ],
        );
      case 'behavior.presleep':
        Questions expandableWidgetData = widget.sleepExpandableWidgetList![0];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomTextWidget(
                text: expandableWidgetData.helpText!,
                style: TextStyle(
                    color: Constant.locationServiceGreen,
                    fontFamily: Constant.jostRegular,
                    fontWeight: FontWeight.w500,
                    fontSize: Platform.isAndroid ? 14 : 15),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 100),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: SingleChildScrollView(
                  physics: Utils.getScrollPhysics(),
                  child: Wrap(children: _getChipsWidget()),
                ),
              ),
            ),
          ],
        );
      case Constant.logDayMedicationTag:
        List<Widget> widgetList = [];

        List<Values> selectedMedicationValues = _medicationValueSelectedList.where((element) => element.isSelected).toList();

        selectedMedicationValues.reversed.forEach((medValue) {
          String medName = medValue.text!;

          if(medValue.numberOfDosage == null)
            medValue.numberOfDosage = 0;

          Questions typeQuestion = Utils.getDosageTypeQuestion(widget.dosageTypeQuestionList!, medName)!;

          Values? selectedDosageType;

          if(typeQuestion != null) {
            typeQuestion.questionType = "single";

            selectedDosageType = typeQuestion.values!.firstWhereOrNull((element) => element.isSelected);
          }

          int index = selectedMedicationValues.indexOf(medValue);

          String genericMedicationName = _getGenericMedicationName(medValue.text!);

          widgetList.add(medValue.isSelected ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Visibility(
                visible: index == selectedMedicationValues.length - 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(
                    thickness: 0.5,
                    color: Constant.chatBubbleGreen,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomRichTextWidget(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${typeQuestion.helpText} for ',
                        style: TextStyle(
                          color: Constant.locationServiceGreen,
                          fontFamily: Constant.jostRegular,
                          fontSize: Platform.isAndroid ? 14 : 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: _getMedicationText(medValue.text!, genericMedicationName),
                        style: TextStyle(
                          color: Constant.locationServiceGreen,
                          fontFamily: Constant.jostMedium,
                          fontSize: Platform.isAndroid ? 14 : 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '.',
                        style: TextStyle(
                          color: Constant.locationServiceGreen,
                          fontFamily: Constant.jostRegular,
                          fontSize: Platform.isAndroid ? 14 : 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                height: 30,
                child: LogDayChipList(
                  question: typeQuestion,
                  onSelectCallback: (val1, val2, val3) {
                    if(val3) {
                      setState(() {
                        debugPrint('set State2');
                      });
                    }
                    _addOrRemoveMedicationFromSelectedAnswerList(medValue, true);

                  },
                ),
              ),
              Visibility(
                visible: (selectedDosageType == null && index != 0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Divider(
                        height: 0,
                        thickness: 0.5,
                        color: Constant.chatBubbleGreen,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: Duration(milliseconds: 350),
                //vsync: this,
                child: _getMedicationDosageList(medValue, typeQuestion, selectedMedicationValues),
              ),
            ],
          ) : Container());
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widgetList,
        );
      case 'triggers1':
        if (_triggerWidgetList == null) {
          _triggerWidgetList = [];
        }

        _generateTriggerWidgetList(_whichTriggerItemSelected);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(_triggerWidgetList.length,
                  (index) => _triggerWidgetList[index].widget!),
        );
      default:
        return Container();
    }
  }

  void _onValueChangedCallback(String currentTag, String value,
      [bool isFromTextField = false]) {
    SelectedAnswers? selectedAnswersObj = _selectedAnswerListOfTriggers
        .firstWhereOrNull((element) => element.questionTag == currentTag);
    if (selectedAnswersObj != null) {
      selectedAnswersObj.answer = value;
    } else {
      _selectedAnswerListOfTriggers
          .add(SelectedAnswers(questionTag: currentTag, answer: value));
    }

    _storeExpandedWidgetDataIntoLocalModel(-1, isFromTextField);

    setState(() {
      debugPrint('set State1');
    });
  }

  /// This method is used to get list of chips widget which will be shown when user taps on the options of sleep section
  List<Widget> _getChipsWidget() {
    List<Widget> chipsList = [];

    widget.sleepExpandableWidgetList![0].values!.forEach((element) {
      chipsList.add(GestureDetector(
        onTap: () {
          setState(() {
            debugPrint('set State17');
            if (element.isSelected) {
              element.isSelected = false;
              element.isDoubleTapped = false;
            } else {
              element.isSelected = true;
            }
            _storeExpandedWidgetDataIntoLocalModel();
          });
        },
        onDoubleTap: () {
          /*setState(() {
            if(element.isDoubleTapped) {
              element.isDoubleTapped = false;
            } else {
              element.isDoubleTapped = true;
              if(!element.isSelected) {
                numberOfSleepItemSelected++;
              }
              element.isSelected = true;
            }
          });*/
        },
        child: Container(
          margin: EdgeInsets.only(
            right: 5,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            border: Border.all(
                color: /*element.isDoubleTapped ? Constant.doubleTapTextColor : Constant.chatBubbleGreen*/ Constant
                    .chatBubbleGreen,
                width: element.isDoubleTapped ? /*2*/ 1 : 1),
            color: element.isSelected
                ? Constant.chatBubbleGreen
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: CustomTextWidget(
              text: element.text!,
              style: TextStyle(
                  color: element.isSelected
                      ? Constant.bubbleChatTextView
                      : Constant.locationServiceGreen,
                  fontSize: Platform.isAndroid ? 12 : 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: Constant.jostRegular),
            ),
          ),
        ),
      ));
    });

    return chipsList;
  }

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);

    if(widget.contentType == Constant.logDayMedicationTag) {

      /*List<String> dosageTypeList = [];

      widget.dosageTypeQuestion.forEach((dosageTypeElement) {
        dosageTypeElement.values.forEach((element) {
          String dosageType = dosageTypeList.firstWhere((el) => el == element.text, orElse: () => null);
          if(dosageType == null)
            dosageTypeList.add(element.text);
        });
      });

      debugPrint('DosageTypeList?????');
      dosageTypeList.forEach((el) {
        debugPrint(el);
      });*/

      widget.valuesList.forEach((element) {
        if(element.isSelected) {
          _medicationList.add(element);
          _medicationValueSelectedList.add(element);

          _addOrRemoveMedicationFromSelectedAnswerList(element, true);
          _animationController!.forward();
        }
      });
      if(!widget.isMedicationLoggedEmpty) {
        widget.recentMedicationMapList!.forEach((recentMedicationElement) {
          Values? medicationValue = _medicationValueSelectedList.firstWhereOrNull((element) => element.text == recentMedicationElement[SignUpOnBoardProviders.MEDICATION_NAME]);

          if(medicationValue == null) {
            Values? recentMedicationValue = widget.valuesList.firstWhereOrNull((element) => element.text == recentMedicationElement[SignUpOnBoardProviders.MEDICATION_NAME]);

            if(recentMedicationValue != null) {
              recentMedicationValue.isRecentMedication = true;
              _medicationList.add(recentMedicationValue);
              _medicationValueSelectedList.add(recentMedicationValue);
            }
          }
        });
      }

      _medicationList.add(Values(valueNumber: 1.toString(), isValid: true, text: Constant.plusText));
    }

    if (widget.isFromRecordsScreen) _updateDoubleTapSelectedAnswersList();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _getSectionWidget();
  }

  ///This method is to update medication Data Model
  void _updateMedicationSelectedDataModel() {
    List<List<String>> selectedMedicationDosageList = [];
    List<List<String>> selectedMedicationDateList = [];

    var selectedMedicationValueList =
    widget.valuesList.where((element) => element.isSelected).toList();

    selectedMedicationValueList.forEach((element1) {
      int medicationIndex = widget.valuesList.indexOf(element1);
      List<String> selectedDosageList = [];

      selectedMedicationDateList.add(_medicineTimeList[medicationIndex]);

      if (element1.isNewlyAdded) {
        selectedMedicationDosageList
            .add(_additionalMedicationDosage[medicationIndex]);
      } else {
        _medicationDosageList[medicationIndex].forEach((element2) {
          if (element2.values != null) {
            element2.values!.forEach((element3) {
              if (element3.isSelected) {
                selectedDosageList.add(element3.valueNumber!);
              }
            });
          }
        });
        selectedMedicationDosageList.add(selectedDosageList);
      }
    });

    _medicationSelectedDataModel = MedicationSelectedDataModel(
      selectedMedicationIndex: selectedMedicationValueList,
      selectedMedicationDateList: selectedMedicationDateList,
      selectedMedicationDosageList: selectedMedicationDosageList,
    );
  }

  void _updateSelectedAnswerListWhenCircleItemSelected(
      String selectedAnswer, bool isSelected) {
    if (isSelected) {
      if (widget.questionType == 'multi') {
        SelectedAnswers? selectedAnswersValue = widget.selectedAnswers
            .firstWhereOrNull(
                (element) =>
            element.questionTag == widget.contentType &&
                element.answer == selectedAnswer);
        if (selectedAnswersValue == null)
          widget.selectedAnswers.add(SelectedAnswers(
              questionTag: widget.contentType, answer: selectedAnswer));
      } else {
        SelectedAnswers? selectedAnswerObj = widget.selectedAnswers.firstWhereOrNull(
                (element) =>
            element.questionTag == widget.contentType &&
                element.answer == selectedAnswer);
        if (selectedAnswerObj == null) {
          widget.selectedAnswers.removeWhere(
                  (element1) => element1.questionTag == widget.contentType);
          widget.selectedAnswers.add(SelectedAnswers(
              questionTag: widget.contentType, answer: selectedAnswer));
        } else {
          selectedAnswerObj.answer = selectedAnswer;
        }
      }
    } else {
      if (widget.questionType == 'multi') {
        List<SelectedAnswers> selectedAnswerList = [];
        widget.selectedAnswers.forEach((element) {
          if (element.questionTag == widget.contentType &&
              element.answer == selectedAnswer) {
            selectedAnswerList.add(element);
          }
        });

        selectedAnswerList.forEach((element) {
          widget.selectedAnswers.remove(element);
        });
      } else {
        /*SelectedAnswers selectedAnswerObj = widget.selectedAnswers.firstWhere(
                (element) => element.questionTag == widget.contentType,
            orElse: () => null);

        if (selectedAnswerObj != null) {
          widget.selectedAnswers.remove(selectedAnswerObj);
        }*/
        widget.selectedAnswers.removeWhere(
                (element1) => element1.questionTag == widget.contentType);
      }
    }
  }

  void _storeExpandedWidgetDataIntoLocalModel(
      [int? selectedMedicationIndex, bool? isFromTextField]) {
    switch (widget.contentType) {
      case 'behavior.presleep':
        String text = widget.valuesList[_whichSleepItemSelected].text!;
        String preCondition = widget.sleepExpandableWidgetList![0].precondition!;

        if (preCondition.contains(text)) {
          List<Values> values = widget.sleepExpandableWidgetList![0].values!;

          widget.selectedAnswers.removeWhere(
                  (element) => element.questionTag == 'behavior.sleep');

          values.forEach((element) {
            if (element.isSelected) {
              SelectedAnswers? selectedAnswers = widget.selectedAnswers
                  .firstWhereOrNull(
                      (element1) =>
                  element1.questionTag == 'behavior.sleep' &&
                      element1.answer == element.valueNumber);
              if (selectedAnswers == null)
                widget.selectedAnswers.add(SelectedAnswers(
                    questionTag: 'behavior.sleep',
                    answer: element.valueNumber));
            }
          });
        } else {
          widget.selectedAnswers.removeWhere(
                  (element) => element.questionTag == 'behavior.sleep');
        }
        break;
      case Constant.logDayMedicationTag:
        widget.selectedAnswers
            .removeWhere((element) => element.questionTag == 'administered');
        SelectedAnswers? selectedAnswers = widget.selectedAnswers.firstWhereOrNull(
                (element) => element.questionTag == 'administered');
        if (selectedAnswers == null) {
          if (_medicationSelectedDataModel != null) {
            if (_medicationSelectedDataModel!.selectedMedicationIndex!.isNotEmpty)
              widget.selectedAnswers.add(SelectedAnswers(
                  questionTag: 'administered',
                  answer: medicationSelectedDataModelToJson(
                      _medicationSelectedDataModel!)));
          }
        } else {
          if (_medicationSelectedDataModel != null) {
            if (_medicationSelectedDataModel!.selectedMedicationIndex!.isNotEmpty)
              selectedAnswers.answer = medicationSelectedDataModelToJson(
                  _medicationSelectedDataModel!);
            else
              widget.selectedAnswers.removeWhere(
                      (element) => element.questionTag == 'administered');
          }
        }

        if (_previousMedicationTag != null) {
          widget.selectedAnswers.removeWhere(
                  (element) => element.questionTag == _previousMedicationTag);
        }

        try {
          _previousMedicationTag = widget
              .dosageQuestionList![selectedMedicationIndex!].tag;
          Values? selectedDosageValue = widget
              .dosageQuestionList![selectedMedicationIndex].values
              !.firstWhereOrNull((element) => element.isSelected);
          if (selectedDosageValue != null) {
            widget.selectedAnswers.add(SelectedAnswers(
                questionTag: _previousMedicationTag!,
                answer: selectedDosageValue.valueNumber));
          }
        } catch (e) {
          print(e);
        }
        break;
      case 'triggers1':
        widget.valuesList.forEach((element) {
          if (element.isSelected) {
            Questions? questionTriggerData = widget.triggerExpandableWidgetList
                !.firstWhereOrNull(
                    (element1) => element1.precondition
                    !.toLowerCase()
                    .contains(element.text!.toLowerCase()));
            if (questionTriggerData != null) {
              if (questionTriggerData.tag != 'triggers1.travel') {
                SelectedAnswers? selectedAnswerTriggerData =
                _selectedAnswerListOfTriggers.firstWhereOrNull(
                        (element1) =>
                    element1.questionTag == questionTriggerData.tag);
                if (selectedAnswerTriggerData != null) {
                  SelectedAnswers? selectedAnswerData;
                  if ((isFromTextField == null) ? false : !isFromTextField) {
                    selectedAnswerData = widget.selectedAnswers.firstWhereOrNull(
                            (element1) =>
                        element1.questionTag ==
                            selectedAnswerTriggerData.questionTag &&
                            element1.answer == selectedAnswerTriggerData.answer);
                  } else {
                    selectedAnswerData = widget.selectedAnswers.firstWhereOrNull(
                            (element1) =>
                        element1.questionTag ==
                            selectedAnswerTriggerData.questionTag);
                  }
                  if (selectedAnswerData == null) {
                    widget.selectedAnswers.add(SelectedAnswers(
                        questionTag: selectedAnswerTriggerData.questionTag,
                        answer: selectedAnswerTriggerData.answer));
                  } else {
                    selectedAnswerData.answer =
                        selectedAnswerTriggerData.answer;
                  }
                }
              } else {
                SelectedAnswers selectedAnswerTriggerData =
                _selectedAnswerListOfTriggers.firstWhere(
                        (element1) =>
                    element1.questionTag == questionTriggerData.tag);
                if (selectedAnswerTriggerData != null) {
                  SelectedAnswers? selectedAnswerData = widget.selectedAnswers
                      .firstWhereOrNull(
                          (element1) =>
                      element1.questionTag ==
                          selectedAnswerTriggerData.questionTag);
                  if (selectedAnswerData == null) {
                    widget.selectedAnswers.add(SelectedAnswers(
                        questionTag: selectedAnswerTriggerData.questionTag,
                        answer: selectedAnswerTriggerData.answer));
                  } else {
                    selectedAnswerData.answer =
                        selectedAnswerTriggerData.answer;
                  }
                }
              }
            }
          }
        });
        break;
    }
  }

  ///Method to update double tap selected answers list
  void _updateDoubleTapSelectedAnswersList() {
    widget.doubleTapSelectedAnswer!.clear();
    widget.selectedAnswers.forEach((element) {
      if (element.isDoubleTapped ?? false) {
        widget.doubleTapSelectedAnswer!.add(element);
      }
    });
  }

  void _generateTriggerWidgetList(int whichTriggerItemSelected) {
    String triggerName = widget.valuesList[whichTriggerItemSelected].text!;

    bool isSelected = widget.valuesList[whichTriggerItemSelected].isSelected;
    Questions? questions = widget.triggerExpandableWidgetList!.firstWhereOrNull(
            (element) => element.precondition
            !.toLowerCase()
            .contains(triggerName.toLowerCase()));
    String questionTag = (questions == null) ? '' : questions.tag!;
    TriggerWidgetModel? triggerWidgetModel = _triggerWidgetList.firstWhereOrNull(
            (element) => element.questionTag == questionTag);

    String? selectedTriggerValue;
    SelectedAnswers? selectedAnswerTriggerData = _selectedAnswerListOfTriggers
        .firstWhereOrNull((element) => element.questionTag == questionTag);
    if (selectedAnswerTriggerData != null) {
      selectedTriggerValue = selectedAnswerTriggerData.answer;
    }

    if (triggerWidgetModel == null) {
      if (questions == null) {
        _triggerWidgetList
            .add(TriggerWidgetModel(questionTag: "", widget: Container()));
      } else {
        switch (questions.questionType) {
          case 'number':
            _triggerWidgetList.add(TriggerWidgetModel(
                questionTag: questions.tag,
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomTextWidget(
                        text: questions.helpText!,
                        style: TextStyle(
                            color: Constant.locationServiceGreen,
                            fontFamily: Constant.jostRegular,
                            fontSize: Platform.isAndroid ? 14 : 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SignUpAgeScreen(
                      currentTag: questions.tag!,
                      sliderValue: (selectedTriggerValue != null)
                          ? double.parse(selectedTriggerValue)
                          : questions.min!.toDouble(),
                      sliderMinValue: questions.min!.toDouble(),
                      sliderMaxValue: questions.max!.toDouble(),
                      minText: questions.min.toString(),
                      maxText: questions.max.toString(),
                      labelText: '',
                      isAnimate: false,
                      horizontalPadding: 0,
                      onValueChangeCallback: _onValueChangedCallback,
                      uiHints: questions.uiHints!,
                    ),
                  ],
                )));
            break;
          case 'text':
            _triggerWidgetList.add(TriggerWidgetModel(
                questionTag: questions.tag,
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomTextWidget(
                        text: questions.helpText!,
                        style: TextStyle(
                            color: Constant.locationServiceGreen,
                            fontFamily: Constant.jostRegular,
                            fontSize: Platform.isAndroid ? 14 : 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomTextFormFieldWidget(
                        minLines: 5,
                        maxLines: 6,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        onChanged: (text) {
                          _onValueChangedCallback(
                              questionTag, text.trim(), true);
                        },
                        controller: TextEditingController(text: (selectedTriggerValue != null)
                            ? selectedTriggerValue
                            : ''),
                        style: TextStyle(
                            fontSize: Platform.isAndroid ? 14 : 15,
                            fontFamily: Constant.jostMedium,
                            color: Constant.unselectedTextColor),
                        cursorColor: Constant.unselectedTextColor,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          hintText: Constant.tapToType,
                          hintStyle: TextStyle(
                              fontSize: Platform.isAndroid ? 14 : 15,
                              color: Constant.unselectedTextColor,
                              fontFamily: Constant.jostRegular),
                          filled: true,
                          fillColor: Constant.backgroundTransparentColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                            borderSide: BorderSide(
                                color: Constant.backgroundTransparentColor,
                                width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                            borderSide: BorderSide(
                                color: Constant.backgroundTransparentColor,
                                width: 1),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                )));
            break;
          case 'multi':
            try {
              if (selectedTriggerValue != null) {
                Questions questionTrigger =
                Questions.fromJson(jsonDecode(selectedTriggerValue));
                questions = questionTrigger;
                print(questionTrigger);
              }
            } catch (e) {
              print(e.toString());
            }
            _triggerWidgetList.add(TriggerWidgetModel(
                questionTag: questions!.tag,
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomTextWidget(
                        text: questions.helpText!,
                        style: TextStyle(
                            color: Constant.locationServiceGreen,
                            fontFamily: Constant.jostRegular,
                            fontSize: Platform.isAndroid ? 14 : 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        height: 30,
                        child: LogDayChipList(
                          question: questions,
                          onSelectCallback: _onValueChangedCallback,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                )));
            break;
          default:
            _triggerWidgetList.add(TriggerWidgetModel(
                questionTag: questions.tag, widget: Container()));
        }
      }
    } else {
      if (!isSelected) {
        _triggerWidgetList.remove(triggerWidgetModel);
        _selectedAnswerListOfTriggers
            .removeWhere((element) => element.questionTag == questionTag);
      }
    }
  }

  ///This method is used to handle tap event of circle medication item
  ///[index] which index of medication item is selected or deselected.
  void _onMedicationItemSelected(int index) async {
    Values medicationValue = _medicationList[index];

    if (medicationValue.text == Constant.plusText) {
      _openSearchMedicationActionSheet();
    } else {
      if(!medicationValue.isSelected) {
        setState(() {
          debugPrint('set State16');
          medicationValue.numberOfDosage = 0;
          _medicationValueSelectedList.remove(medicationValue);
          _medicationList.remove(medicationValue);
        });

        _addOrRemoveMedicationFromSelectedAnswerList(medicationValue, false);
      } else {
        if(widget.medicationSelectedAnswerList.length < 4) {
          setState(() {
            debugPrint('set State15');
            var medValueSelected = _medicationValueSelectedList.firstWhereOrNull((
                element) => element == medicationValue);

            if (medValueSelected == null)
              _medicationValueSelectedList.add(medicationValue);

            _animationController!.forward();


            _addOrRemoveMedicationFromSelectedAnswerList(medicationValue, true);
          });
        } else {
          setState(() {
            debugPrint('set State14');
            medicationValue.isSelected = false;
          });
          Utils.showValidationErrorDialog(context, "You cannot select more than 4 medications.", 'Alert!');
        }
      }

      //_updateMedicationDbData();
    }
  }

  ///This method is used to open search medication action sheet when user
  ///clicked on search icon or the plus button.
  void _openSearchMedicationActionSheet() async {
    int medicationListLength = widget.medicationSelectedAnswerList.length;

    if(medicationListLength < 4) {
      Values value = await showModalBottomSheet(
        backgroundColor: Constant.transparentColor,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: TonixLogDayMedicationListActionSheet(
            medicationValuesList: widget.valuesList,
            dosageTypeQuestionList: widget.dosageTypeQuestionList!,
            genericMedicationQuestionList: widget.genericMedicationQuestionList!,
            recentMedicationMapList: widget.recentMedicationMapList!,
            onItemDeselect: (value) {
              if (value != null) {
                setState(() {
                  debugPrint('set State13');
                  value.numberOfDosage = 0;
                  _medicationList.remove(value);
                  _medicationValueSelectedList.remove(value);

                  _addOrRemoveMedicationFromSelectedAnswerList(value, false);
                });
                //_updateMedicationDbData();
              }
            },
          ),
        ),
      );

      if (value != null) {
        setState(() {
          debugPrint('set State12');
          _medicationList.remove(value);
          _medicationValueSelectedList.remove(value);
          _medicationList.insert(0, value);
          _medicationValueSelectedList.add(value);
          _animationController!.forward();

          _addOrRemoveMedicationFromSelectedAnswerList(value, true);
        });
        //_updateMedicationDbData();
      }
    } else {
      Utils.showValidationErrorDialog(context, "You cannot select more than 4 medications.", 'Alert!');
    }
  }

  /*void _updateMedicationDbData() async {
    List<String> medicationValues = [];

    _medicationValueSelected.forEach((element) {
      medicationValues.add(element.text);
    });

    await SignUpOnBoardProviders.db.insertOrUpdateLogHeadacheMedication(medicationValues);
  }*/

  ///This method is used to add or remove medication from selected answers list.
  ///[value] is the medication item in the form of Values object.
  ///[isAdd] is used to determine whether medication item is adding or removing from the list.
  void _addOrRemoveMedicationFromSelectedAnswerList(Values value, bool isAdd) {
    String dosageType = Constant.blankString;

    Questions typeQuestion = Utils.getDosageTypeQuestion(widget.dosageTypeQuestionList!, value.text!)!;

    debugPrint('MedName?????${value.text}');

    typeQuestion.questionType = "single";

    typeQuestion.values!.forEach((element) {
      if(element.isSelected)
        dosageType = element.text!;
    });

    if(typeQuestion.values!.length == 1) {
      typeQuestion.values!.first.isSelected = true;
      dosageType = typeQuestion.values!.first.text!;
    }

    Questions dosageQuestion = Utils.getDosageQuestion(widget.dosageQuestionList!, value.text!, dosageType)!;

    Questions genericQuestion = Utils.getGenericMedicationQuestion(widget.genericMedicationQuestionList!, value.text!, dosageType)!;

    if(isAdd) {
      //This block is called when medication item is adding to the selected answer list
      bool isFound = false;

      for(int i = 0; i < widget.medicationSelectedAnswerList.length; i++) {
        SelectedAnswers? medicationAnswer = widget.medicationSelectedAnswerList[i].firstWhereOrNull((element) => element.questionTag == widget.contentType);
        if(medicationAnswer != null) {
          //This block is called when medication is found in the list.
          if(medicationAnswer.answer == value.text) {
            widget.medicationSelectedAnswerList[i].removeWhere((element) => element.questionTag!.contains('.type') || element.questionTag!.contains('.dosage') || element.questionTag!.contains('.generic'));
            isFound = true;

            if(dosageQuestion != null) {
              SelectedAnswers? dosageAnswer = widget.medicationSelectedAnswerList[i].firstWhereOrNull((element) => element.questionTag == dosageQuestion.tag);

              Values? selectedDosageValue = dosageQuestion.values!.firstWhereOrNull((element) => element.isSelected);

              if(dosageAnswer != null) {
                dosageAnswer.answer = selectedDosageValue != null ? selectedDosageValue.text : dosageQuestion.values![0].text;
              } else {
                Values? selectedDosageValue = dosageQuestion.values!.firstWhereOrNull((element) => element.isSelected);
                widget.medicationSelectedAnswerList[i].add(SelectedAnswers(questionTag: dosageQuestion.tag, answer: (selectedDosageValue != null) ? selectedDosageValue.text : dosageQuestion.values!.first.text));
              }
            }

            if(dosageQuestion != null) {
              SelectedAnswers? unitAnswer = widget.medicationSelectedAnswerList[i].firstWhereOrNull((element) => element.questionTag == Constant.unitTag);
              Values? selectedDosageValue = dosageQuestion.values!.firstWhereOrNull((element) => element.isSelected);

              if(selectedDosageValue != null) {

                String unitValue = Constant.blankString;

                if(selectedDosageValue != null) {
                  Values? unitSelected = selectedDosageValue.unitList!.firstWhereOrNull((element) => element.isSelected);

                  if(unitSelected != null)
                    unitValue = unitSelected.text!;
                  else {
                    selectedDosageValue.unitList!.forEach((el) {
                      el.isSelected = false;
                    });
                    selectedDosageValue.unitList!.first.isSelected = true;
                    unitValue = selectedDosageValue.unitList!.first.text!;
                  }
                } else {
                  Values? unitSelected = dosageQuestion.values!.first.unitList!.firstWhereOrNull((element) => element.isSelected);

                  if(unitSelected != null)
                    unitValue = unitSelected.text!;
                  else {
                    dosageQuestion.values!.first.unitList!.forEach((el) {
                      el.isSelected = false;
                    });
                    dosageQuestion.values!.first.unitList!.first.isSelected = true;
                    unitValue = dosageQuestion.values!.first.unitList!.first.text!;
                  }
                }

                if(unitAnswer != null) {
                  unitAnswer.answer = unitValue;
                } else {
                  widget.medicationSelectedAnswerList[i].add(SelectedAnswers(questionTag: Constant.unitTag, answer: unitValue));
                }
              }
            }

            if(dosageQuestion != null) {
              SelectedAnswers? numberOfDosage = widget.medicationSelectedAnswerList[i].firstWhereOrNull((element) => element.questionTag == Constant.numberOfDosageTag);

              if(numberOfDosage != null) {
                numberOfDosage.answer = value.numberOfDosage != null ? value.numberOfDosage.toString() : '0';
              } else {
                widget.medicationSelectedAnswerList[i].add(SelectedAnswers(questionTag: Constant.numberOfDosageTag, answer: value.numberOfDosage != null ? value.numberOfDosage.toString() : '0'));
              }
            }

            if(genericQuestion != null) {
              SelectedAnswers? genericAnswer = widget.medicationSelectedAnswerList[i].firstWhereOrNull((element) => element.questionTag == genericQuestion.tag);

              if(genericAnswer != null)
                genericAnswer.answer = genericQuestion.values![0].text;
              else
                widget.medicationSelectedAnswerList[i].add(SelectedAnswers(questionTag: genericQuestion.tag, answer: genericQuestion.values![0].text));
            }

            if(typeQuestion != null) {
              SelectedAnswers? typeAnswer = widget.medicationSelectedAnswerList[i].firstWhereOrNull((element) => element.questionTag == typeQuestion.tag);

              Values? selectedTypeValue = typeQuestion.values!.firstWhereOrNull((element) => element.isSelected);

              if(typeAnswer != null) {
                if(selectedTypeValue != null) {
                  typeAnswer.answer = selectedTypeValue.text;
                } else {
                  widget.medicationSelectedAnswerList[i].remove(typeAnswer);
                }
              } else {
                if(selectedTypeValue != null)
                  widget.medicationSelectedAnswerList[i].add(SelectedAnswers(questionTag: typeQuestion.tag, answer: selectedTypeValue.text));
              }
            }
            break;
          }
        }
      }

      if(!isFound) {
        //This block is called when medication is not found in the list.
        List<SelectedAnswers> selectedAnswerList = [];

        selectedAnswerList.add(SelectedAnswers(questionTag: widget.contentType, answer: value.text));

        if(dosageQuestion != null) {
          Values? selectedDosageValue = dosageQuestion.values!.firstWhereOrNull((element) => element.isSelected);
          selectedAnswerList.add(SelectedAnswers(questionTag: dosageQuestion.tag, answer: (selectedDosageValue != null) ? selectedDosageValue.text : dosageQuestion.values!.first.text));
        }

        if(dosageQuestion != null) {
          Values? selectedDosageValue = dosageQuestion.values!.firstWhereOrNull((element) => element.isSelected);

          if(selectedDosageValue != null) {

            String unitValue = Constant.blankString;

            if(selectedDosageValue != null) {
              Values? unitSelected = selectedDosageValue.unitList!.firstWhereOrNull((element) => element.isSelected);

              if(unitSelected != null)
                unitValue = unitSelected.text!;
              else {
                selectedDosageValue.unitList!.forEach((el) {
                  el.isSelected = false;
                });
                selectedDosageValue.unitList!.first.isSelected = true;
                unitValue = selectedDosageValue.unitList!.first.text!;
              }
            } else {
              Values? unitSelected = dosageQuestion.values!.first.unitList!.firstWhereOrNull((element) => element.isSelected);

              if(unitSelected != null)
                unitValue = unitSelected.text!;
              else {
                dosageQuestion.values!.first.unitList!.forEach((el) {
                  el.isSelected = false;
                });
                dosageQuestion.values!.first.unitList!.first.isSelected = true;
                unitValue = dosageQuestion.values!.first.unitList!.first.text!;
              }
            }

            selectedAnswerList.add(SelectedAnswers(questionTag: Constant.unitTag, answer: unitValue));
          }
        }


        if(dosageQuestion != null)
          selectedAnswerList.add(SelectedAnswers(questionTag: Constant.numberOfDosageTag, answer: value.numberOfDosage != null ? value.numberOfDosage.toString() : '0'));

        if(typeQuestion != null) {
          Values? selectedDosageTypeValue = typeQuestion.values!.firstWhereOrNull((element) => element.isSelected);
          if(selectedDosageTypeValue != null)
            selectedAnswerList.add(SelectedAnswers(questionTag: typeQuestion.tag, answer: selectedDosageTypeValue.text));
        }

        if(genericQuestion != null) {
          selectedAnswerList.add(SelectedAnswers(questionTag: genericQuestion.tag, answer: genericQuestion.values!.first.text));
        }

        widget.medicationSelectedAnswerList.add(selectedAnswerList);
      }
    } else {
      //This block is called when medication item is removing from the list.

      if(dosageQuestion != null) {
        dosageQuestion.values!.forEach((element) {
          element.isSelected = false;
        });
      }

      if(typeQuestion != null) {
        typeQuestion.values!.forEach((element) {
          element.isSelected = false;
        });
      }

      int? index;

      for(int i = 0; i < widget.medicationSelectedAnswerList.length; i++) {
        SelectedAnswers? medicationAnswer = widget.medicationSelectedAnswerList[i].firstWhereOrNull((element) => element.questionTag == widget.contentType);
        if (medicationAnswer != null) {
          if(medicationAnswer.answer == value.text) {
            index = i;
            break;
          }
        }
      }

      if(index != null) {
        widget.medicationSelectedAnswerList.removeAt(index);
      }
    }
  }

  ///This method is used to return the headache type check list for migraine option.
  ///[headacheMigraineQuestion] is holding migraine hedache type check list option.
  Widget _getHeadacheTypeCheckListWidget(Questions headacheMigraineQuestion) {
    List<Widget> chipsList = [];

    headacheMigraineQuestion.values!.forEach((element) {
      chipsList.add(Row(
        children: <Widget>[
          Theme(
              data: ThemeData(
                  unselectedWidgetColor:
                  Constant.editTextBoarderColor),
              child: Checkbox(
                value: element.isSelected,
                checkColor: Constant.bubbleChatTextView,
                activeColor: Constant.chatBubbleGreen,
                focusColor: Constant.chatBubbleGreen,
                autofocus: true,
                onChanged: (bool? value) {
                  setState(() {
                    debugPrint('set State11');
                    element.isSelected = value!;
                    _addMultiValuesToSelectedAnswer(headacheMigraineQuestion);
                  });
                },
              )
          ),
          Expanded(
            child: Wrap(
              children: [
                CustomTextWidget(
                  text: element.text!,
                  style: TextStyle(
                      height: 1.3,
                      fontFamily: Constant.jostRegular,
                      fontSize: 12,
                      color: Constant.chatBubbleGreen),
                ),
              ],
            ),
          ),
        ],
      ));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: chipsList,
    );
  }

  ///This method is used to return the widget of expanded view of medication
  ///
  Widget _getMedicationDosageList(Values medValue, Questions typeQuestion, List<Values> selectedMedicationValues) {
    Widget? widgetObj;

    String dosageType = Constant.blankString;

    int index = selectedMedicationValues.indexOf(medValue);

    debugPrint('IndexOf????$index');

    typeQuestion.values!.forEach((element) {
      if(element.isSelected)
        dosageType = element.text!;
    });

    Questions dosageQuestion = Utils.getDosageQuestion(widget.dosageQuestionList!, medValue.text!, dosageType)!;

    if(dosageQuestion != null) {
      List<Values> unitList = [];

      Values? selectedDosageValue = dosageQuestion.values!.firstWhereOrNull((element) => element.isSelected);

      String unitValue = Constant.blankString;

      if(selectedDosageValue != null) {
        Values? unitSelected = selectedDosageValue.unitList!.firstWhere((element) => element.isSelected);

        unitList = selectedDosageValue.unitList!;
        if(unitSelected != null)
          unitValue = unitSelected.text!;
        else
          unitValue = selectedDosageValue.unitList!.first.text!;
      } else {
        Values? unitSelected = dosageQuestion.values!.first.unitList!.firstWhereOrNull((element) => element.isSelected);


        unitList = dosageQuestion.values!.first.unitList!;

        if(unitSelected != null)
          unitValue = unitSelected.text!;
        else
          unitValue = dosageQuestion.values!.first.unitList!.first.text!;
      }

      Questions unitQuestion = Questions(tag: 'units', values: unitList);

      widgetObj = Padding(
        padding: const EdgeInsets.only(top: 15,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomRichTextWidget(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${dosageQuestion.helpText} for ',
                      style: TextStyle(
                        color: Constant.locationServiceGreen,
                        fontFamily: Constant.jostRegular,
                        fontSize: Platform.isAndroid ? 14 : 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: medValue.text,
                      style: TextStyle(
                        color: Constant.locationServiceGreen,
                        fontFamily: Constant.jostMedium,
                        fontSize: Platform.isAndroid ? 14 : 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '.',
                      style: TextStyle(
                        color: Constant.locationServiceGreen,
                        fontFamily: Constant.jostRegular,
                        fontSize: Platform.isAndroid ? 14 : 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              height: 30,
              child: LogDayChipList(
                question: dosageQuestion,
                onSelectCallback: (val1, val2, val3) {
                  if(val3) {
                    setState(() {
                      debugPrint('set State10');
                    });
                  }

                  _addOrRemoveMedicationFromSelectedAnswerList(medValue, true);
                },
              ),
            ),
            SizedBox(height: 15,),
            Visibility(
              visible: unitList.isNotEmpty && unitList.length > 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: CustomRichTextWidget(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Please indicate the unit for ',
                            style: TextStyle(
                              color: Constant.locationServiceGreen,
                              fontFamily: Constant.jostRegular,
                              fontSize: Platform.isAndroid ? 14 : 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: medValue.text,
                            style: TextStyle(
                              color: Constant.locationServiceGreen,
                              fontFamily: Constant.jostMedium,
                              fontSize: Platform.isAndroid ? 14 : 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: '.',
                            style: TextStyle(
                              color: Constant.locationServiceGreen,
                              fontFamily: Constant.jostRegular,
                              fontSize: Platform.isAndroid ? 14 : 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15,),
                  Container(
                    height: 30,
                    child: LogDayChipList(
                      question: unitQuestion,
                      onSelectCallback: (val1, val2, val3) {
                        if(val3) {
                          setState(() {
                            debugPrint('set State15');
                          });
                        }

                        _addOrRemoveMedicationFromSelectedAnswerList(medValue, true);
                      },
                    ),
                  ),
                  SizedBox(height: 15,),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomRichTextWidget(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Number of $unitValue of ',
                      style: TextStyle(
                        color: Constant.locationServiceGreen,
                        fontFamily: Constant.jostRegular,
                        fontSize: Platform.isAndroid ? 14 : 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: medValue.text,
                      style: TextStyle(
                        color: Constant.locationServiceGreen,
                        fontFamily: Constant.jostMedium,
                        fontSize: Platform.isAndroid ? 14 : 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '.',
                      style: TextStyle(
                        color: Constant.locationServiceGreen,
                        fontFamily: Constant.jostRegular,
                        fontSize: Platform.isAndroid ? 14 : 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      height: 30,
                      width: 30,
                      color: Constant.backgroundTransparentColor,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              debugPrint('set State9');
                              if (medValue.numberOfDosage != 0 &&
                                  medValue.numberOfDosage != null)
                                medValue.numberOfDosage =
                                    medValue.numberOfDosage! - 1;

                              _addOrRemoveMedicationFromSelectedAnswerList(
                                  medValue, true);
                            });
                          },
                          child: Center(
                            child: CustomTextWidget(
                              text: '-',
                              style: TextStyle(
                                  color: Constant.splashColor,
                                  fontFamily: Constant.jostMedium,
                                  fontSize: Platform.isAndroid ? 14 : 15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                //SizedBox(width: 10,),
                CustomTextWidget(
                  text: '${medValue.numberOfDosage ?? 0}',
                  style: TextStyle(
                      color: Constant.splashColor,
                      fontFamily: Constant.jostRegular,
                      fontSize: Platform.isAndroid ? 14 : 15),
                ),
                //SizedBox(width: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      height: 30,
                      width: 30,
                      color: Constant.backgroundTransparentColor,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              debugPrint('set State8');
                              //if(medValue.numberOfDosage != 1)
                              medValue.numberOfDosage = (medValue.numberOfDosage ?? 1) + 1;

                              _addOrRemoveMedicationFromSelectedAnswerList(medValue, true);
                            });
                          },
                          child: Center(
                            child: CustomTextWidget(
                              text: '+',
                              style: TextStyle(
                                  color: Constant.splashColor,
                                  fontFamily: Constant.jostMedium,
                                  fontSize: Platform.isAndroid ? 14 : 15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Visibility(
              visible: (index != 0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Divider(
                      height: 0,
                      thickness: 0.5,
                      color: Constant.chatBubbleGreen,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return widgetObj ?? Container(
      margin: const EdgeInsets.only(bottom: 15),
    );
  }

  void _addMultiValuesToSelectedAnswer(Questions headacheMigraineQuestion) {
    List<String> valuesSelectedList = [];

    headacheMigraineQuestion.values!.forEach((element) {
      if(element.isSelected)
        valuesSelectedList.add(element.text!);
    });

    SelectedAnswers? selectedAnswer = widget.selectedAnswers.firstWhereOrNull((element) => element.questionTag == headacheMigraineQuestion.tag);

    if(selectedAnswer != null)
      selectedAnswer.answer = jsonEncode(valuesSelectedList);
    else
      widget.selectedAnswers.add(SelectedAnswers(questionTag: headacheMigraineQuestion.tag, answer: jsonEncode(valuesSelectedList)));

    debugPrint(widget.selectedAnswers.toString());
  }

  Widget _getHeadacheIntensityWidget() {
    List<Widget> headacheIntensityWidgetList = [];

    Values? selectedValue = widget.valuesList.firstWhereOrNull((element) => element.isSelected);

    String groupValue = widget.valuesList.first.text!;

    if(selectedValue != null)
      groupValue = selectedValue.text!;


    widget.valuesList.asMap().forEach((index, element) {
      //String headacheIntensityText = _getHeadacheIntensityValueText(index);

      headacheIntensityWidgetList.add(/*Row(
        children: <Widget>[
          Theme(
              data: ThemeData(
                  unselectedWidgetColor:
                  Constant.editTextBoarderColor),
              child: Checkbox(
                value: element.isSelected,
                checkColor: Constant.bubbleChatTextView,
                activeColor: Constant.chatBubbleGreen,
                focusColor: Constant.chatBubbleGreen,
                autofocus: true,
                onChanged: (bool value) {
                  setState(() {
                    if(value) {
                      widget.valuesList.forEach((intensityElement) {
                        intensityElement.isSelected = false;
                      });

                      element.isSelected = value;

                      SelectedAnswers intensitySelectedAnswer = widget.selectedAnswers.firstWhere((answerElement) => answerElement.questionTag == Constant.severityTag, orElse: () => null);

                      if(intensitySelectedAnswer != null)
                        intensitySelectedAnswer.answer = element.text;
                      else {
                        widget.selectedAnswers.add(SelectedAnswers(questionTag: Constant.severityTag, answer: element.text));
                      }
                    }
                  });
                },
              )
          ),
          Expanded(
            child: Wrap(
              children: [
                CustomTextWidget(
                  text: *//*'${element.text} - $headacheIntensityText' *//*'$headacheIntensityText',
                  style: TextStyle(
                      height: 1.3,
                      fontFamily: Constant.jostRegular,
                      fontSize: 12,
                      color: Constant.chatBubbleGreen),
                ),
              ],
            ),
          ),
        ],
      )*/Row(
        children: [
          Theme(
            data: ThemeData(
              unselectedWidgetColor: Constant.chatBubbleGreen,
            ),
            child: Radio<String>(
              value: element.text!,
              activeColor: Constant.chatBubbleGreen,
              hoverColor: Constant.chatBubbleGreen,
              focusColor: Constant.chatBubbleGreen,
              groupValue: groupValue,
              onChanged: (String? value) {
                setState(() {
                  debugPrint('set State7');
                  widget.valuesList.forEach((intensityElement) {
                    intensityElement.isSelected = false;
                  });

                  element.isSelected = true;

                  SelectedAnswers? intensitySelectedAnswer = widget.selectedAnswers.firstWhere((answerElement) => answerElement.questionTag == Constant.severityTag);

                  if(intensitySelectedAnswer != null)
                    intensitySelectedAnswer.answer = element.valueNumber;
                  else {
                    widget.selectedAnswers.add(SelectedAnswers(questionTag: Constant.severityTag, answer: element.valueNumber));
                  }
                });
              },
            ),
          ),
          CustomTextWidget(
            text: '${element.text}',
            style: TextStyle(
                height: 1.3,
                fontFamily: Constant.jostRegular,
                fontSize: 12,
                color: Constant.chatBubbleGreen),
          ),
        ],
      ));
    });

    return Column(
      children: headacheIntensityWidgetList,
    );
  }

  ///This method is used to get generic medication name
  ///[medicationName] is used to identify the generic name of medication
  String _getGenericMedicationName(String medicationName) {
    String genericMedicationName = Constant.blankString;

    if(widget.dosageTypeQuestionList != null && widget.genericMedicationQuestionList != null) {
      Questions typeQuestion = Utils.getDosageTypeQuestion(widget.dosageTypeQuestionList!, medicationName)!;

      if (typeQuestion != null) {
        String dosageType = typeQuestion.values!.first.text!;
        Questions genericQuestion = Utils.getGenericMedicationQuestion(widget.genericMedicationQuestionList!, medicationName, dosageType)!;

        if (genericQuestion != null)
          genericMedicationName = genericQuestion.values!.first.text!;
      }
    }

    return genericMedicationName;
  }

  String _getMedicationText(String optionValue, String genericMedicationName) {
    if(optionValue == Constant.plusText) {
      return optionValue;
    } else {
      if(optionValue == genericMedicationName)
        return '$optionValue';
      else
        return '$optionValue [$genericMedicationName]';
    }
  }
}
