import 'dart:convert';
import 'dart:core';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/models/LogDayQuestionnaire.dart';
import 'package:mobile/models/MedicationSelectedDataModel.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/TriggerWidgetModel.dart';
import 'package:mobile/models/medication_data_model.dart';
import 'package:mobile/models/medication_history_model.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/AddHeadacheOnGoingScreen.dart';
import 'package:mobile/view/AddNewMedicationDialog.dart';
import 'package:mobile/view/CircleLogOptions.dart';
import 'package:mobile/view/CustomRichTextWidget.dart';
import 'package:mobile/view/CustomTextFormFieldWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/DatePicker.dart';
import 'package:mobile/view/LogDayChipList.dart';
import 'package:mobile/view/MedicationDosagePicker.dart';
import 'package:mobile/view/TimeSection.dart';
import 'package:mobile/view/medication_delete_dialog.dart';
import 'package:mobile/view/medicationlist/medication_list_action_sheet.dart';
import 'package:mobile/view/medication_history_action_sheet.dart';
import 'package:mobile/view/sign_up_age_screen.dart';
import 'medication_item_view.dart';
import 'dart:io' show Platform;
import 'package:flutter/gestures.dart';

import 'package:provider/provider.dart';

import '../models/MedicationTimeModel.dart';
import '../util/MonthYearCupertinoDatePicker.dart';
import 'checkbox_widget.dart';
import 'device_list_action_sheet.dart';

class AddHeadacheSection extends StatefulWidget {
  final String headerText;
  final String subText;
  final String contentType;
  final String? selectedCurrentValue;
  final String? questionType;
  final double? min;
  final double? max;
  final List<Questions>? allQuestionsList;
  final List<Questions>? sleepExpandableWidgetList;
  final List<Questions>? medicationExpandableWidgetList;
  final List<Questions>? triggerExpandableWidgetList;
  final List<Values> valuesList;
  final List<Values>? chipsValuesList;
  final Function(String, String)? addHeadacheDetailsData;
  final Function(String, String)? removeHeadacheTypeData;
  final Function? moveWelcomeOnBoardTwoScreen;
  final String? updateAtValue;
  final List<SelectedAnswers> selectedAnswers;
  final List<SelectedAnswers>? doubleTapSelectedAnswer;
  final bool? isHeadacheEnded;
  final CurrentUserHeadacheModel? currentUserHeadacheModel;
  final bool isFromRecordsScreen;
  final String uiHints;
  final DateTime? selectedDateTime;
  final List<Map>? recentMedicationMapList;
  final List<Map>? selectedMedicationMapList;
  final List<MedicationHistoryModel> userMedicationHistoryList;
  final List<MedicationListActionSheetModel> preventiveMedicationActionSheetModelList;
  final List<MedicationListActionSheetModel> acuteMedicationActionSheetModelList;

  AddHeadacheSection({
    Key? key,
    required this.headerText,
    required this.subText,
    required this.contentType,
    this.min,
    this.max,
    required this.valuesList,
    this.chipsValuesList,
    this.sleepExpandableWidgetList,
    this.medicationExpandableWidgetList,
    this.addHeadacheDetailsData,
    this.removeHeadacheTypeData,
    this.selectedCurrentValue,
    this.updateAtValue,
    this.moveWelcomeOnBoardTwoScreen,
    this.triggerExpandableWidgetList,
    this.questionType,
    this.allQuestionsList,
    required this.selectedAnswers,
    this.isHeadacheEnded,
    this.currentUserHeadacheModel,
    this.doubleTapSelectedAnswer,
    this.isFromRecordsScreen = false,
    required this.uiHints,
    this.selectedDateTime,
    this.recentMedicationMapList,
    this.selectedMedicationMapList,
    required this.userMedicationHistoryList,
    this.preventiveMedicationActionSheetModelList = const [],
    this.acuteMedicationActionSheetModelList = const [],
  })
      : super(key: key);

  @override
  _AddHeadacheSectionState createState() => _AddHeadacheSectionState();
}

class _AddHeadacheSectionState extends State<AddHeadacheSection>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  int numberOfSleepItemSelected = 0;
  int whichSleepItemSelected = 0;
  List<int> whichMedicationItemSelected = [];
  int _whichExpandedMedicationItemSelected = 0;
  int whichTriggerItemSelected = 0;
  bool isValuesUpdated = false;
  List<List<String>> _medicineTimeList = [];
  List<List<Questions>> _medicationDosageList = [];
  List<int> _numberOfDosageAddedList = [];
  MedicationSelectedDataModel _medicationSelectedDataModel =
      MedicationSelectedDataModel();
  List<TriggerWidgetModel> _triggerWidgetList = [];
  String? previousMedicationTag;
  List<SelectedAnswers> selectedAnswerListOfTriggers = [];
  List<List<String>> _additionalMedicationDosage = [];
  DateTime? _selectedDateTime;
  List<Values> _medicationList = [];
  List<Values> _devicesList = [];
  MedicationListActionSheetModel? _medicationListActionSheetModel;
  List<Questions> _formulationQuestionList = [];

  List<MedicationDataModel> _preventiveMedicationDataModelList = [];
  List<MedicationDataModel> _acuteMedicationDataModelList = [];
  List<MedicationDataModel> _preventiveMedicationDataModelListBackup = [];

  bool _medicationCheckBoxValue = false;
  List<MedicationListActionSheetModel> _preventiveMedicationActionSheetModelList = [];
  List<MedicationListActionSheetModel> _acuteMedicationActionSheetModelList = [];
  List<MedicationListActionSheetModel> _preventiveMedicationActionSheetModelListBackup = [];


  bool _isPreventiveMedicationLogged = false;

  ///Method to get section widget
  Widget _getSectionWidget() {
    switch (widget.contentType) {
      case 'headacheType':
        var value = widget.valuesList
            .firstWhereOrNull((model) => model.text == Constant.plusText);
        if (value == null) {
          widget.valuesList.add(Values(
              text: Constant.plusText,
              valueNumber: widget.valuesList.length.toString()));
        }

        if (widget.selectedAnswers != null) {
          SelectedAnswers? selectedAnswers = widget.selectedAnswers
              .firstWhereOrNull(
                  (element) => element.questionTag == widget.contentType);

          if (selectedAnswers != null) {
            Values? selectedValue = widget.valuesList.firstWhereOrNull(
                (element) => element.text == selectedAnswers.answer);
            if (selectedValue != null) selectedValue.isSelected = true;
          }
        }
        return _getWidget(Consumer<HeadacheTypeInfo>(
          builder: (context, data, child) {
            return CircleLogOptions(
              currentTag: widget.contentType,
              logOptions: widget.valuesList,
              onCircleItemSelected: _onHeadacheTypeItemSelected,
            );
          },
        ));
      case 'onset':
        return _getWidget(TimeSection(
          currentTag: widget.contentType,
          updatedDateValue: widget.updateAtValue ?? '',
          addHeadacheDateTimeDetailsData: _onHeadacheDateTimeSelected,
          isHeadacheEnded: widget.isHeadacheEnded!,
          currentUserHeadacheModel: widget.currentUserHeadacheModel!,
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
                answer: widget.min!.toInt().toString()));
          }
        }

        if (selectedCurrentValue == null)
          selectedCurrentValue = widget.selectedCurrentValue;
        return _getWidget(SignUpAgeScreen(
          sliderValue:
              (selectedCurrentValue == null || selectedCurrentValue.isEmpty)
                  ? widget.min!
                  : double.parse(selectedCurrentValue),
          minText: Constant.one,
          maxText: Constant.ten,
          currentTag: widget.contentType,
          sliderMinValue: widget.min!,
          sliderMaxValue: widget.max!,
          minTextLabel: Constant.mild,
          maxTextLabel: Constant.veryPainful,
          labelText: '',
          horizontalPadding: 0,
          selectedAnswerCallBack: _onHeadacheIntensitySelected,
          isAnimate: false,
          uiHints: widget.uiHints,
        ));
      case 'disability':
        String? selectedCurrentValue;
        if (widget.selectedAnswers != null) {
          SelectedAnswers? intensitySelectedAnswer = widget.selectedAnswers
              .firstWhereOrNull(
                  (element) => element.questionTag == 'disability');
          if (intensitySelectedAnswer != null) {
            selectedCurrentValue = intensitySelectedAnswer.answer;
          } else {
            widget.selectedAnswers.add(SelectedAnswers(
                questionTag: 'disability',
                answer: widget.min!.toInt().toString()));
          }
        }

        if (selectedCurrentValue == null)
          selectedCurrentValue = widget.selectedCurrentValue;
        return _getWidget(Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        text: '${Constant.noneDisability}:',
                        style: TextStyle(
                            color: Constant.locationServiceGreen,
                            fontSize: 14,
                            fontFamily: Constant.jostBold),
                      ),
                      Expanded(
                        child: CustomTextWidget(
                          text: ' ${Constant.noneDisabilityDesc}',
                          style: TextStyle(
                              color: Constant.locationServiceGreen,
                              fontSize: 14,
                              fontFamily: Constant.jostRegular),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        text: '${Constant.mildDisability}:',
                        style: TextStyle(
                            color: Constant.locationServiceGreen,
                            fontSize: 14,
                            fontFamily: Constant.jostBold),
                      ),
                      Expanded(
                        child: CustomTextWidget(
                          text: ' ${Constant.mildDisabilityDesc}',
                          style: TextStyle(
                              color: Constant.locationServiceGreen,
                              fontSize: 14,
                              fontFamily: Constant.jostRegular),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        text: '${Constant.moderateDisability}:',
                        style: TextStyle(
                            color: Constant.locationServiceGreen,
                            fontSize: 14,
                            fontFamily: Constant.jostBold),
                      ),
                      Expanded(
                        child: CustomTextWidget(
                          text: ' ${Constant.moderateDisabilityDesc}',
                          style: TextStyle(
                              color: Constant.locationServiceGreen,
                              fontSize: 14,
                              fontFamily: Constant.jostRegular),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        text: '${Constant.severeDisability}:',
                        style: TextStyle(
                            color: Constant.locationServiceGreen,
                            fontSize: 14,
                            fontFamily: Constant.jostBold),
                      ),
                      Expanded(
                        child: CustomTextWidget(
                          text: ' ${Constant.severeDisabilityDesc}',
                          style: TextStyle(
                              color: Constant.locationServiceGreen,
                              fontSize: 14,
                              fontFamily: Constant.jostRegular),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        text: '${Constant.bedriddenDisability}:',
                        style: TextStyle(
                            color: Constant.locationServiceGreen,
                            fontSize: 14,
                            fontFamily: Constant.jostBold),
                      ),
                      Expanded(
                        child: CustomTextWidget(
                          text: ' ${Constant.bedriddenDisabilityDesc}',
                          style: TextStyle(
                              color: Constant.locationServiceGreen,
                              fontSize: 14,
                              fontFamily: Constant.jostRegular),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SignUpAgeScreen(
              sliderValue:
                  (selectedCurrentValue == null || selectedCurrentValue.isEmpty)
                      ? widget.min!
                      : double.parse(selectedCurrentValue),
              minText: Constant.one,
              maxText: Constant.ten,
              currentTag: widget.contentType,
              sliderMinValue: widget.min!,
              sliderMaxValue: widget.max!,
              minTextLabel: Constant.noneAtALL,
              maxTextLabel: Constant.totalDisability,
              labelText: '',
              horizontalPadding: 0,
              selectedAnswerCallBack: _onHeadacheIntensitySelected,
              isAnimate: false,
              uiHints: widget.uiHints,
            ),
          ],
        ));

      case 'behavior.presleep':
        if (!isValuesUpdated) {
          isValuesUpdated = true;
          Values? value = widget.valuesList.firstWhereOrNull(
              (element) => element.isDoubleTapped || element.isSelected);
          if (value != null) {
            try {
              _onSleepItemSelected(widget.valuesList.indexOf(value));
            } catch (e) {
              debugPrint(e.toString());
            }
          }
        }

        numberOfSleepItemSelected = 0;
        widget.sleepExpandableWidgetList![0].values!.forEach((element) {
          if (element.isSelected != null && element.isSelected) {
            numberOfSleepItemSelected++;
          }
        });

        Values? selectedExpandedSleepItemValue = widget
            .sleepExpandableWidgetList![0].values!
            .firstWhereOrNull((element) => element.isSelected);
        return _getWidget(CircleLogOptions(
          logOptions: widget.valuesList,
          preCondition: widget.sleepExpandableWidgetList![0].precondition!,
          overlayNumber: numberOfSleepItemSelected,
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
      case 'medication':
        try {
          ///This below code is to show expanded view of medications
          if (!isValuesUpdated) {
            isValuesUpdated = true;
            List<Values> valueList = widget.valuesList
                .where(
                    (element) => element.isDoubleTapped || element.isSelected)
                .toList();
            valueList.forEach((value1) {
              int medicationIndex = widget.valuesList.indexOf(value1);

              int? indexValue = whichMedicationItemSelected
                  .firstWhereOrNull((element) => element == medicationIndex);

              if (indexValue == null)
                whichMedicationItemSelected.add(medicationIndex);

              Values? value = widget.valuesList
                  .firstWhereOrNull((element) => element.isSelected);

              if (value != null) {
                _animationController!.forward();
              } else {
                _animationController!.reverse();
                widget.selectedAnswers.removeWhere(
                    (element) => element.questionTag == 'administered');
              }

              String valueNumber =
                  widget.valuesList[medicationIndex].valueNumber!;
              String text = widget.valuesList[medicationIndex].text!;
              bool isSelected = widget.valuesList[medicationIndex].isSelected;
              bool isNewlyAdded =
                  widget.valuesList[medicationIndex].isNewlyAdded;

              if (!isSelected) {
                whichMedicationItemSelected.remove(medicationIndex);
              }

              if (isNewlyAdded && isSelected) {
                if (_additionalMedicationDosage[medicationIndex].length <
                    _numberOfDosageAddedList[medicationIndex] + 1) {
                  for (var i = 0;
                      i < _numberOfDosageAddedList[medicationIndex] + 1;
                      i++) {
                    _additionalMedicationDosage[medicationIndex].add('50 mg');
                  }
                }
              }

              _updateMedicationSelectedDataModel();
              _updateSelectedAnswerListWhenCircleItemSelected(text, isSelected);
              _storeExpandedWidgetDataIntoLocalModel();

              SelectedAnswers? selectedAnswers = widget.selectedAnswers
                  .firstWhereOrNull(
                      (element) => element.questionTag == 'administered');
              if (selectedAnswers != null) {
                /*DateTime dateTime = DateTime.parse(selectedAnswers.answer);
                _medicineTimeList[medicationIndex][0] =
                    Utils.getTimeInAmPmFormat(dateTime.hour, dateTime.minute);*/

                //_medicineTimeList[medicationIndex][0] = selectedAnswers.answer;
              }
            });
          }
        } catch (e) {
          debugPrint(e.toString());
        }

        Values? plusValue = widget.valuesList
            .firstWhereOrNull((element) => element.text == Constant.plusText);
        if (plusValue == null) {
          widget.valuesList.add(Values(
              text: Constant.plusText,
              valueNumber: (widget.valuesList.length + 1).toString()));
          /*_medicineTimeList
              .add(List.generate(1, (index) => DateTime.now().toString()));*/
          _medicineTimeList
              .add(List.generate(1, (index) => Constant.morningTime));
          _medicationDosageList.add(List.generate(1, (index) => Questions()));
          _numberOfDosageAddedList.add(0);
        }

        return _getWidget(
            /*CircleLogOptions(
          logOptions: _medicationList,
          onCircleItemSelected: _onMedicationItemSelected,
          onDoubleTapItem: _onDoubleTapItem,
          currentTag: widget.contentType,
          questionType: widget.questionType!,
          isForMedication: true,
        )*/
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Divider(
                height: 40,
                thickness: 0.5,
                color: Constant.chatBubbleGreen,
              ),
            ),
            MedicationItemView(
              medicationDataModelList: _preventiveMedicationDataModelList,
              contentType: Constant.logDayMedicationTag,
              openSearchMedicationActionSheet: _openSearchMedicationActionSheet,
              openDeleteMedicationDialog: _openMedicationDeleteDialog,
              medicationType: Constant.preventive,
              checkbox: _medicationCheckBoxValue,
              selectedDateTime: _selectedDateTime ?? DateTime.now(),
              preventiveMedicationListActionSheetModelList: _preventiveMedicationActionSheetModelList.where((element) => !element.isDeleted).toList(),
              onChanged: () {
                _updateMedicationModel();
              },
              preventiveCheckbox: _medicationCheckBoxValue,
              onPreventiveMedicationCheckboxChanged: (value) {
                setState(() {
                  _medicationCheckBoxValue = value;

                  if (_medicationCheckBoxValue) {
                    _preventiveMedicationActionSheetModelListBackup = _preventiveMedicationActionSheetModelList.where((element) => true).toList();
                    _preventiveMedicationDataModelListBackup = _preventiveMedicationDataModelList.where((element) => true).toList();

                    _preventiveMedicationActionSheetModelList.clear();
                    _preventiveMedicationDataModelList.clear();

                    widget.userMedicationHistoryList.where((el) => el.endDate == null && el.isPreventive).toList().forEach((element) {
                      if (element.isPreventive) {

                        if (_medicationCheckBoxValue) {
                          int? id = element.id;
                          String medicationText = element.medicationName;
                          String formulationText = '';
                          String formulationTag = '';

                          Questions? formulationQuestion = _formulationQuestionList.firstWhereOrNull((el) {
                            List<String> splitConditionList = el.text!.split('=');
                            if (splitConditionList.length == 2) {
                              splitConditionList[0] = splitConditionList[0].trim();
                              splitConditionList[1] = splitConditionList[1].trim();
                              return medicationText == splitConditionList[1];
                            } else {
                              return false;
                            }
                          });

                          if (formulationQuestion != null) {
                            formulationText = element.formulation;
                            formulationTag = formulationQuestion.tag ?? '';
                          } else {
                            formulationText = element.formulation;
                            formulationTag = '${medicationText}_custom.formulation';
                          }

                          String selectedTime = element.medicationTime;
                          DateTime? startDate = element.startDate;
                          DateTime? endDate = element.endDate;

                          String selectedDosage = '';
                          String dosageTag = '';

                          Questions? dosageQuestion = widget.medicationExpandableWidgetList?.firstWhereOrNull((el) {
                            List<String> splitConditionList = el.precondition!.split('=');
                            if (splitConditionList.length == 2) {
                              splitConditionList[0] = splitConditionList[0].trim();
                              splitConditionList[1] = splitConditionList[1].trim();

                              return splitConditionList[0] == formulationTag && splitConditionList[1] == formulationText;
                            } else {
                              return false;
                            }
                          });

                          if (dosageQuestion != null) {
                            selectedDosage = element.dosage;
                            dosageTag = dosageQuestion.tag ?? '';
                          } else {
                            selectedDosage = element.dosage;
                            dosageTag = '${medicationText}_custom.dosage';
                          }


                          Values? medicationValue;
                          double? numberOfDosage = double.tryParse(element.numberOfDosage);
                          bool isPreventive = element.isPreventive;
                          String? reason = element.reason;
                          String? comments = element.comments;
                          bool isDeleted = false;

                          _preventiveMedicationActionSheetModelList.add(MedicationListActionSheetModel(
                            id: id,
                            medicationText: medicationText,
                            formulationText: formulationText,
                            formulationTag: formulationTag,
                            selectedTime: selectedTime,
                            startDate: startDate,
                            endDate: endDate,
                            selectedDosage: selectedDosage,
                            dosageTag: dosageTag,
                            medicationValue: medicationValue,
                            numberOfDosage: numberOfDosage,
                            isPreventive: isPreventive,
                            reason: reason,
                            comments: comments,
                            isDeleted: isDeleted,
                            isChecked: true,
                          ));

                          MedicationDataModel medicationDataModel = MedicationDataModel();

                          medicationDataModel.medicationText = medicationText;
                          medicationDataModel.dosageValue = selectedDosage;
                          medicationDataModel.formulation = formulationText;
                          medicationDataModel.numberOfDosage = numberOfDosage;
                          medicationDataModel.medicationTime = selectedTime;
                          medicationDataModel.startDateTime = startDate;
                          medicationDataModel.endDateTime = endDate;
                          medicationDataModel.isPreventive = isPreventive;
                          medicationDataModel.isChecked = true;

                          if (element.isPreventive)
                            _preventiveMedicationDataModelList.add(medicationDataModel);
                        }
                      }
                    });
                  } else {
                    _preventiveMedicationActionSheetModelList = _preventiveMedicationActionSheetModelListBackup;
                    _preventiveMedicationDataModelList = _preventiveMedicationDataModelListBackup;
                  }

                  _updateMedicationModel();
                });
              },
              medicationHistoryDataModelList: widget.userMedicationHistoryList,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Divider(
                height: 40,
                thickness: 0.5,
                color: Constant.chatBubbleGreen,
              ),
            ),
            MedicationItemView(
              medicationDataModelList: _acuteMedicationDataModelList,
              contentType: Constant.logDayMedicationTag,
              openSearchMedicationActionSheet: _openSearchMedicationActionSheet,
              openDeleteMedicationDialog: _openMedicationDeleteDialog,
              medicationType: Constant.acute,
              checkbox: _medicationCheckBoxValue,
              onChanged: () {},
              preventiveCheckbox: _medicationCheckBoxValue,
              onPreventiveMedicationCheckboxChanged: (value) {},
              selectedDateTime: _selectedDateTime ?? DateTime.now(),
              medicationHistoryDataModelList: widget.userMedicationHistoryList,
            ),
          ],
        ));
      case 'triggers1':
        if (!isValuesUpdated) {
          isValuesUpdated = true;
          widget.valuesList.asMap().forEach((index, element) {
            if (element.isSelected || element.isDoubleTapped) {
              debugPrint('coming in here');
              _animationController!.forward();
              /*Future.delayed(Duration(milliseconds: index * 400), () {
                _onTriggerItemSelected(index);
              });*/

              SelectedAnswers? selectedAnswersValue = widget.selectedAnswers
                  .firstWhereOrNull((element1) =>
                      element1.questionTag == widget.contentType &&
                      element1.answer == element.text);
              if (selectedAnswersValue == null)
                widget.selectedAnswers.add(SelectedAnswers(
                    questionTag: widget.contentType, answer: element.text));

              Questions? questionTriggerData = widget
                  .triggerExpandableWidgetList!
                  .firstWhereOrNull((element1) =>
                      element1.precondition!.contains(element.text!));
              if (questionTriggerData != null) {
                SelectedAnswers? selectedAnswerTriggerData =
                    selectedAnswerListOfTriggers.firstWhereOrNull((element1) =>
                        element1.questionTag == questionTriggerData.tag);
                if (selectedAnswerTriggerData != null) {
                  SelectedAnswers? selectedAnswerData = widget.selectedAnswers
                      .firstWhereOrNull((element1) =>
                          element1.questionTag ==
                              selectedAnswerTriggerData.questionTag &&
                          element1.answer == selectedAnswerTriggerData.answer);
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
      case 'device':
        return _getWidget(CircleLogOptions(
          logOptions: _devicesList,
          onCircleItemSelected: _onDeviceItemSelected,
          onDoubleTapItem: _onDoubleTapItem,
          currentTag: widget.contentType,
          questionType: widget.questionType!,
          isForMedication: false,
        ));
      default:
        return Container();
    }
  }

  void _onHeadacheTypeItemSelected(int index) {
    if (widget.valuesList[index].text == Constant.plusText) {
      widget.moveWelcomeOnBoardTwoScreen!();
    } else {
      Values headacheTypeValue = widget.valuesList[index];
      if (headacheTypeValue.isSelected) {
        widget.addHeadacheDetailsData!(
            widget.contentType, headacheTypeValue.text!);
      } else {
        widget.removeHeadacheTypeData!(
            widget.contentType, headacheTypeValue.text!);
      }
    }
  }

  void _onHeadacheIntensitySelected(String currentTag, String currentValue) {
    widget.addHeadacheDetailsData!(currentTag, currentValue);
  }

  void _onHeadacheDateTimeSelected(String currentTag, String currentValue) {
    widget.addHeadacheDetailsData!(currentTag, currentValue);
  }

  void _onDoubleTapItem(String currentTag, String selectedAnswer,
      String questionType, bool isDoubleTapped, int index) {
    whichSleepItemSelected = index;

    _removeExpandableWidgetDoubleTapData(currentTag, selectedAnswer, isDoubleTapped);

    if (currentTag == Constant.medicationEventType) {
      index = widget.valuesList.indexOf(_medicationList[index]);
    } else if (currentTag == 'devices') {
      index = widget.valuesList.indexOf(_devicesList[index]);
    }

    int? indexValue = whichMedicationItemSelected
        .firstWhereOrNull((element) => element == index);

    if (indexValue == null) whichMedicationItemSelected.add(index);

    whichTriggerItemSelected = index;

    if (widget.contentType == 'medication')
      _updateMedicationSelectedDataModel();

    if (widget.valuesList[index].text!.toLowerCase() == Constant.none) {
      setState(() {
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
      widget.doubleTapSelectedAnswer!
          .removeWhere((element) => element.questionTag!.contains('triggers1'));
    }

    if (isDoubleTapped) {
      if (questionType == 'multi') {
        SelectedAnswers? selectedAnswerValue = widget.selectedAnswers
            .firstWhereOrNull((element) => (element.questionTag == currentTag &&
                element.answer == selectedAnswer));
        if (selectedAnswerValue == null) {
          widget.selectedAnswers.add(
              SelectedAnswers(questionTag: currentTag, answer: selectedAnswer));
        }

        SelectedAnswers? doubleTapSelectedAnswer = widget
            .doubleTapSelectedAnswer!
            .firstWhereOrNull((element) => (element.questionTag == currentTag &&
                element.answer == selectedAnswer));
        if (doubleTapSelectedAnswer == null)
          widget.doubleTapSelectedAnswer!.add(
              SelectedAnswers(questionTag: currentTag, answer: selectedAnswer));
      } else {
        widget.selectedAnswers.removeWhere(
            (element) => element.questionTag == widget.contentType);
        SelectedAnswers? selectedAnswerObj = widget.selectedAnswers
            .firstWhereOrNull((element) =>
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
            .doubleTapSelectedAnswer!
            .firstWhereOrNull((element) => element.questionTag == currentTag);
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
        SelectedAnswers? selectedAnswerObj = widget.selectedAnswers
            .firstWhereOrNull((element) => element.questionTag == currentTag);

        if (selectedAnswerObj != null) {
          widget.selectedAnswers.remove(selectedAnswerObj);
        }

        SelectedAnswers? doubleTapSelectedAnswerObj = widget
            .doubleTapSelectedAnswer!
            .firstWhereOrNull((element) => element.questionTag == currentTag);

        if (doubleTapSelectedAnswerObj != null) {
          widget.doubleTapSelectedAnswer!.remove(doubleTapSelectedAnswerObj);
        }
      }
    }
    storeExpandableViewSelectedData(isDoubleTapped);
    storeLogDayDataIntoDatabase();
    debugPrint("${widget.selectedAnswers.length}");
  }

  void storeExpandableViewSelectedData(bool isDoubleTapped) {
    switch (widget.contentType) {
      case 'behavior.presleep':
        if (isDoubleTapped) {
          String text = widget.valuesList[whichSleepItemSelected].text!;
          String preCondition =
          widget.sleepExpandableWidgetList![0].precondition!;

          if (preCondition.contains(text)) {
            List<Values> values = widget.sleepExpandableWidgetList![0].values!;
            values.forEach((element) {
              if (element.isSelected) {
                SelectedAnswers? selectedAnswers = widget.selectedAnswers
                    .firstWhereOrNull((element1) =>
                element1.questionTag == 'behavior.sleep' &&
                    element1.answer == element.text);
                if (selectedAnswers == null)
                  widget.selectedAnswers.add(SelectedAnswers(
                      questionTag: 'behavior.sleep', answer: element.text));

                SelectedAnswers? doubleTapSelectedAnswer =
                widget.doubleTapSelectedAnswer!.firstWhereOrNull((element1) =>
                element1.questionTag == 'behavior.sleep' &&
                    element1.answer == element.text);
                if (doubleTapSelectedAnswer == null)
                  widget.doubleTapSelectedAnswer!.add(SelectedAnswers(
                      questionTag: 'behavior.sleep', answer: element.text));
              }
            });
          } else {
            widget.selectedAnswers.removeWhere(
                    (element) => element.questionTag == 'behavior.sleep');
            widget.doubleTapSelectedAnswer!.removeWhere(
                    (element) => element.questionTag == 'behavior.sleep');
          }
        }
        break;
      case 'medication':
        if (isDoubleTapped) {
          SelectedAnswers? selectedAnswers = widget.selectedAnswers
              .firstWhereOrNull(
                  (element) => element.questionTag == 'administered');

          if (selectedAnswers == null) {
            if (_medicationSelectedDataModel != null) {
              if (_medicationSelectedDataModel
                  .selectedMedicationIndex.isNotEmpty)
                widget.selectedAnswers.add(SelectedAnswers(
                    questionTag: 'administered',
                    answer: medicationSelectedDataModelToJson(
                        _medicationSelectedDataModel)));
            }
          } else {
            if (_medicationSelectedDataModel != null) {
              if (_medicationSelectedDataModel
                  .selectedMedicationIndex.isNotEmpty)
                selectedAnswers.answer = medicationSelectedDataModelToJson(
                    _medicationSelectedDataModel);
              else
                widget.selectedAnswers.removeWhere(
                    (element) => element.questionTag == 'administered');
            }
          }
        } else {
          if (_medicationSelectedDataModel.selectedMedicationIndex.isEmpty)
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
                .selectedMedicationDosageList[index]);
            nonDoubleTappedDateList.add(
                medicationSelectedDataModel.selectedMedicationDateList[index]);
          }
        });

        medicationSelectedDataModel.selectedMedicationIndex
            .retainWhere((element) => element.isDoubleTapped);

        nonDoubleTappedDosageList.forEach((element) {
          medicationSelectedDataModel.selectedMedicationDosageList
              .remove(element);
        });

        nonDoubleTappedDateList.forEach((element) {
          medicationSelectedDataModel.selectedMedicationDateList
              .remove(element);
        });

        debugPrint(
            'BeforeLengthOfMeds???${medicationSelectedDataModel.selectedMedicationIndex.length}');

        debugPrint(
            'Meds???${medicationSelectedDataModel.selectedMedicationIndex}');

        medicationSelectedDataModel.selectedMedicationIndex
            .retainWhere((element) => element.isDoubleTapped);

        debugPrint(
            'AfterLengthOfMeds???${medicationSelectedDataModel.selectedMedicationIndex.length}');

        if (isDoubleTapped) {
          SelectedAnswers? selectedAnswers = widget.doubleTapSelectedAnswer!
              .firstWhereOrNull(
                  (element) => element.questionTag == 'administered');
          if (selectedAnswers == null) {
            if (_medicationSelectedDataModel != null) {
              if (_medicationSelectedDataModel
                  .selectedMedicationIndex.isNotEmpty)
                widget.doubleTapSelectedAnswer!.add(SelectedAnswers(
                    questionTag: 'administered',
                    answer: medicationSelectedDataModelToJson(
                        _medicationSelectedDataModel)));
            }
          } else {
            if (_medicationSelectedDataModel != null) {
              if (_medicationSelectedDataModel
                  .selectedMedicationIndex.isNotEmpty)
                selectedAnswers.answer = medicationSelectedDataModelToJson(
                    _medicationSelectedDataModel);
              else
                widget.doubleTapSelectedAnswer!.removeWhere(
                    (element) => element.questionTag == 'administered');
            }
          }
        } else {
          MedicationSelectedDataModel medicationSelectedDataModel =
              MedicationSelectedDataModel.fromJson(
                  jsonDecode(jsonEncode(_medicationSelectedDataModel)));

          debugPrint(
              'BeforeLengthOfMeds???${medicationSelectedDataModel.selectedMedicationIndex.length}');

          medicationSelectedDataModel.selectedMedicationIndex
              .retainWhere((element) => element.isDoubleTapped);

          debugPrint(
              'AfterLengthOfMeds???${medicationSelectedDataModel.selectedMedicationIndex.length}');

          if (medicationSelectedDataModel.selectedMedicationIndex.isEmpty)
            widget.doubleTapSelectedAnswer!.removeWhere(
                (element) => element.questionTag == 'administered');
        }
        break;
      case 'triggers1':
        if (isDoubleTapped) {
          widget.valuesList.forEach((element) {
            if (element.isDoubleTapped && element.isSelected) {
              Questions? questionTriggerData = widget
                  .triggerExpandableWidgetList!
                  .firstWhereOrNull((element1) =>
                  element1.precondition!.contains(element.text!));
              if (questionTriggerData != null) {
                SelectedAnswers? selectedAnswerTriggerData =
                selectedAnswerListOfTriggers.firstWhereOrNull((element1) =>
                element1.questionTag == questionTriggerData.tag);
                if (selectedAnswerTriggerData != null) {
                  SelectedAnswers? selectedAnswerData = widget.selectedAnswers
                      .firstWhereOrNull((element1) =>
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
          });

          widget.valuesList.forEach((element) {
            if (element.isDoubleTapped && element.isSelected) {
              Questions? questionTriggerData = widget
                  .triggerExpandableWidgetList!
                  .firstWhereOrNull((element1) =>
                  element1.precondition!.contains(element.text!));
              if (questionTriggerData != null) {
                SelectedAnswers? selectedAnswerTriggerData =
                selectedAnswerListOfTriggers.firstWhereOrNull((element1) =>
                element1.questionTag == questionTriggerData.tag);
                if (selectedAnswerTriggerData != null) {
                  SelectedAnswers? selectedAnswerData = widget
                      .doubleTapSelectedAnswer!
                      .firstWhereOrNull((element1) =>
                  element1.questionTag ==
                      selectedAnswerTriggerData.questionTag);
                  if (selectedAnswerData == null) {
                    widget.doubleTapSelectedAnswer!.add(SelectedAnswers(
                        questionTag: selectedAnswerTriggerData.questionTag,
                        answer: selectedAnswerTriggerData.answer));
                  } else {
                    selectedAnswerData.answer =
                        selectedAnswerTriggerData.answer;
                  }
                }
              }
            }
          });
        }
        break;
    }
  }

  void storeLogDayDataIntoDatabase() async {
    debugPrint("${widget.doubleTapSelectedAnswer}");
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
    //String valueNumber = widget.valuesList[index].valueNumber;
    bool isSelected = widget.valuesList[index].isSelected;

    whichSleepItemSelected = index;

    _updateSelectedAnswerListWhenCircleItemSelected(text, isSelected);

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
    String text = widget.valuesList[index].text!;
    bool isSelected = widget.valuesList[index].isSelected;
    _updateSelectedAnswerListWhenCircleItemSelected(text, isSelected);
  }

  void _onMedicationItemSelected(int index) {
    if (_medicationList[index].text == Constant.plusText) {
      /*_openAddNewMedicationDialog();*/
      _openSearchMedicationActionSheet(
          context, LatestMedicationDataModelInfo(), false, null, true);
    } else {
      index = widget.valuesList.indexOf(_medicationList[index]);

      String valueNumber = widget.valuesList[index].valueNumber!;
      String text = widget.valuesList[index].text!;
      bool isSelected = widget.valuesList[index].isSelected;
      bool isNewlyAdded = widget.valuesList[index].isNewlyAdded;

      setState(() {
        int? indexValue = whichMedicationItemSelected
            .firstWhereOrNull((element) => element == index);

        if (indexValue == null) whichMedicationItemSelected.add(index);

        bool isNewlyAdded = widget.valuesList[index].isNewlyAdded;
        bool isSelected = widget.valuesList[index].isSelected;

        if (isNewlyAdded && isSelected) {
          DateTime nowDateTime = DateTime(
            _selectedDateTime!.year,
            _selectedDateTime!.month,
            _selectedDateTime!.day,
            DateTime.now().hour,
            DateTime.now().minute,
            0,
            0,
            0,
          );
          /*_medicineTimeList
              .add(List.generate(1, (index) => nowDateTime.toString()));*/
          _medicineTimeList
              .add(List.generate(1, (index) => Constant.morningTime));
          _medicationDosageList.add(List.generate(1, (index) => Questions()));
          _numberOfDosageAddedList.add(0);
          _additionalMedicationDosage.add([]);
          widget.medicationExpandableWidgetList!
              .add(Questions(precondition: ''));
        }

        if (!isSelected) {
          _medicationList.remove(widget.valuesList[index]);
        }
      });

      Values? value =
          widget.valuesList.firstWhereOrNull((element) => element.isSelected);

      if (value != null) {
        _animationController!.forward();
      } else {
        _animationController!.reverse();
        widget.selectedAnswers
            .removeWhere((element) => element.questionTag == 'administered');
      }

      if (!isSelected) {
        whichMedicationItemSelected.remove(index);
      }

      if (isNewlyAdded && isSelected) {
        if (_additionalMedicationDosage[index].length <
            _numberOfDosageAddedList[index] + 1) {
          for (var i = 0; i < _numberOfDosageAddedList[index] + 1; i++) {
            _additionalMedicationDosage[index].add('50 mg');
          }
        }
      }

      _updateMedicationSelectedDataModel();
      _updateSelectedAnswerListWhenCircleItemSelected(text, isSelected);
      _storeExpandedWidgetDataIntoLocalModel();
    }
  }

  void _onTriggerItemSelected(int index) {
    Values? value =
        widget.valuesList.firstWhereOrNull((element) => element.isSelected);

    if (value != null) {
      _animationController!.forward();
    } else {
      _animationController!.reverse();
    }

    String valueNumber = widget.valuesList[index].valueNumber!;
    String text = widget.valuesList[index].text!;
    String valueText = widget.valuesList[index].text!;
    bool isSelected = widget.valuesList[index].isSelected;

    if (valueText.toLowerCase() == Constant.none && isSelected) {
      setState(() {
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
          noneValue
            ..isSelected = false
            ..isDoubleTapped = false;
        });
      }

      //'1' for none option
      widget.selectedAnswers.removeWhere((element) =>
          element.questionTag == 'triggers1' &&
          element.answer!.toLowerCase() == Constant.none);
    }

    if (!isSelected) {
      Questions? triggerExpandableQuestionObj = widget
          .triggerExpandableWidgetList!
          .firstWhereOrNull((element) => element.precondition!
              .toLowerCase()
              .contains(valueText.toLowerCase()));
      if (triggerExpandableQuestionObj != null)
        widget.selectedAnswers.removeWhere((element) =>
            element.questionTag == triggerExpandableQuestionObj.tag);
    }

    debugPrint('check here 2');
    _updateSelectedAnswerListWhenCircleItemSelected(text, isSelected);
    debugPrint('check here');
    _storeExpandedWidgetDataIntoLocalModel();
    debugPrint('check here 1');


    setState(() {
      whichTriggerItemSelected = index;
    });

  }

  void _onDeviceItemSelected(int index) {
    if (_devicesList[index].text == Constant.plusText) {
      _openDeviceListActionSheet();
    } else {}
  }

  Widget _getWidget(Widget mainWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: CustomTextWidget(
                    text: widget.headerText,
                    style: TextStyle(
                        fontSize: Platform.isAndroid ? 16 : 17,
                        color: Constant.chatBubbleGreen,
                        fontFamily: Constant.jostMedium),
                  ),
                ),
              ),
              Visibility(
                visible: /*widget.contentType == 'medication'*/ false,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    //_openSearchMedicationActionSheet(context, false, null);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 5),
                    child: Icon(
                      Icons.search,
                      color: Constant.chatBubbleGreen,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CustomTextWidget(
              text: widget.contentType != Constant.logDayMedicationTag
                  ? widget.subText
                  : 'Note: ${Constant.doNotStopMedications}',
              style: TextStyle(
                  fontSize: Platform.isAndroid ? 14 : 15,
                  color: Constant.locationServiceGreen,
                  fontFamily: Constant.jostRegular),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Visibility(
          visible: widget.contentType == Constant.logDayMedicationTag && widget.userMedicationHistoryList.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: CustomRichTextWidget(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Tap to see your',
                    style: TextStyle(
                      fontSize: Platform.isAndroid ? 14 : 15,
                      fontFamily: Constant.jostRegular,
                      color: Constant.locationServiceGreen,
                    ),
                  ),
                  TextSpan(
                    text: ' medication history',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _openMedicationHistoryActionSheet(),
                    style: TextStyle(
                      fontSize: Platform.isAndroid ? 14 : 15,
                      fontFamily: Constant.jostRegular,
                      color: Constant.addCustomNotificationTextColor,
                    ),
                  ),
                  TextSpan(
                    text: '.',
                    style: TextStyle(
                      fontSize: Platform.isAndroid ? 14 : 15,
                      fontFamily: Constant.jostRegular,
                      color: Constant.locationServiceGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        mainWidget,
        SizeTransition(
          sizeFactor: _animationController!,
          child: FadeTransition(
              opacity: _animationController!,
              child: AnimatedSize(
                alignment: Alignment.bottomLeft,
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
      case 'medication':
        List<Widget> widgetList = [];
        whichMedicationItemSelected.reversed.forEach((index) {
          String medName = widget.valuesList[index].selectedText!;

          Questions? questions = widget.medicationExpandableWidgetList!
              .firstWhereOrNull((element) {
            List<String> splitConditionList = element.precondition!.split('=');
            if (splitConditionList.length == 2) {
              splitConditionList[0] = splitConditionList[0].trim();
              splitConditionList[1] = splitConditionList[1].trim();

              if (medName.length < 5) {
                return medName == splitConditionList[1];
              } else if (medName == widget.valuesList[index].text) {
                return medName == splitConditionList[1];
              } else {
                return (splitConditionList[1].contains(medName
                    .replaceAll("(generic)", Constant.blankString)
                    .trim()));
              }
            } else {
              return false;
            }
          });

          String medicationTime =
              _medicationListActionSheetModel?.selectedTime ??
                  _medicineTimeList[index][0];

          if (_medicationListActionSheetModel != null) {
            _medicationDosageList[index][0].values?.forEach((element) {
              if (element.text ==
                  _medicationListActionSheetModel?.selectedDosage) {
                element.isSelected = true;
              }
            });
          }

          debugPrint('MedicationOnSelect???$questions');

          widgetList.add(Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Divider(
                  height: 40,
                  thickness: 0.5,
                  color: Constant.chatBubbleGreen,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 5),
                child: CustomTextWidget(
                  text: medName,
                  style: TextStyle(
                    color: Constant.locationServiceGreen,
                    fontFamily: Constant.jostRegular,
                    fontSize: Platform.isAndroid ? 14 : 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 5),
                child: CustomTextWidget(
                  text: 'Dose 1',
                  style: TextStyle(
                    color: Constant.locationServiceGreen,
                    fontFamily: Constant.jostRegular,
                    fontSize: Platform.isAndroid ? 14 : 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomTextWidget(
                  text:
                      'When did you take ${medName[0].toLowerCase()}${medName.substring(1)}?',
                  style: TextStyle(
                      color: Constant.locationServiceGreen,
                      fontFamily: Constant.jostRegular,
                      fontSize: Platform.isAndroid ? 14 : 15,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              _getMedicationTimeRadioButton(
                selectedMedicationTime: medicationTime,
                medicationItemIndex: 0,
                index: index,
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomTextWidget(
                  text: (questions == null)
                      ? 'What dosage did you take?'
                      : (questions.helpText!.contains('mg')
                              ? 'What was the total dosage, in mg, of ${medName[0].toLowerCase()}${medName.substring(1)} that you took at this time?'
                              : questions.helpText) ??
                          '',
                  style: TextStyle(
                      color: Constant.locationServiceGreen,
                      fontFamily: Constant.jostRegular,
                      fontSize: Platform.isAndroid ? 14 : 15,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              if (_medicationDosageList[index][0].values != null)
                Container(
                  height: 30,
                  child: LogDayChipList(
                    question: _medicationDosageList[index][0],
                    onSelectCallback: _onMedicationChipSelectedCallback,
                  ),
                )
              else
                Visibility(
                  visible: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Constant.backgroundTransparentColor,
                                borderRadius: BorderRadius.circular(5)),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  _showMedicationDosagePicker(0, index);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color:
                                          Constant.backgroundTransparentColor,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: CustomTextWidget(
                                      text: (_additionalMedicationDosage[index]
                                                  .length >=
                                              1)
                                          ? _additionalMedicationDosage[index]
                                              [0]
                                          : '50 mg',
                                      style: TextStyle(
                                          color: Constant.splashColor,
                                          fontFamily: Constant.jostRegular,
                                          fontSize:
                                              Platform.isAndroid ? 14 : 15),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: 15,
              ),
              _getAddedDosageList(index),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _numberOfDosageAddedList[index] =
                          _numberOfDosageAddedList[index] + 1;
                      //_medicineTimeList[index].add(DateTime.now().toString());
                      _medicineTimeList[index].add(Constant.morningTime);
                      _additionalMedicationDosage[index].add('50 mg');

                      _updateMedicationSelectedDataModel();
                      _storeExpandedWidgetDataIntoLocalModel();

                      String medName = widget.valuesList[index].selectedText!;
                      Questions? questions1 = widget
                          .medicationExpandableWidgetList!
                          .firstWhereOrNull((element) {
                        List<String> splitConditionList =
                            element.precondition!.split('=');
                        if (splitConditionList.length == 2) {
                          splitConditionList[0] = splitConditionList[0].trim();
                          splitConditionList[1] = splitConditionList[1].trim();

                          if (medName.length < 5) {
                            return medName == splitConditionList[1];
                          } else if (widget.valuesList[index].text == medName) {
                            return medName == splitConditionList[1];
                          } else {
                            return (splitConditionList[1].contains(medName
                                .replaceAll("(generic)", Constant.blankString)
                                .trim()));
                          }
                        } else {
                          return false;
                        }
                      });

                      if (questions1 != null) {
                        List<Values> valuesList = [];

                        questions1.values!.forEach((element) {
                          valuesList.add(Values(
                              text: element.text,
                              valueNumber: element.valueNumber,
                              isSelected: element.isSelected));
                        });

                        Questions questions2 = Questions(
                            tag: questions1.tag,
                            id: questions1.id,
                            questionType: questions1.questionType,
                            precondition: questions1.precondition,
                            next: questions1.next,
                            text: questions1.text,
                            helpText: questions1.helpText,
                            values: valuesList,
                            min: questions1.min,
                            max: questions1.max,
                            updatedAt: questions1.updatedAt,
                            exclusiveValue: questions1.exclusiveValue,
                            phi: questions1.phi,
                            required: questions1.required,
                            uiHints: questions1.uiHints,
                            currentValue: questions1.currentValue);
                        _medicationDosageList[index].add(questions2);
                      } else {
                        _medicationDosageList[index].add(Questions());
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(
                          text: '+ ',
                          style: TextStyle(
                            fontSize: Platform.isAndroid ? 14 : 15,
                            color: Constant.addCustomNotificationTextColor,
                            fontWeight: FontWeight.w500,
                            fontFamily: Constant.jostRegular,
                          ),
                        ),
                        Expanded(
                          child: CustomTextWidget(
                            text:
                                'Add another dose of ${medName[0].toLowerCase()}${medName.substring(1)}',
                            style: TextStyle(
                              fontSize: Platform.isAndroid ? 14 : 15,
                              color: Constant.addCustomNotificationTextColor,
                              fontWeight: FontWeight.w500,
                              fontFamily: Constant.jostRegular,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ));
        });

        //_medicationListActionSheetModel = null;

        return Container();
      /*return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widgetList,
        );*/
      case 'triggers1':
        if (_triggerWidgetList == null) {
          _triggerWidgetList = [];
        }

        _generateTriggerWidgetList(whichTriggerItemSelected);

        List<Widget> widgetList = [];

        _triggerWidgetList.reversed.forEach((element) {
          widgetList.add(element.widget ?? Container());
        });
        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widgetList.length,
          itemBuilder: (context, index) {
            return widgetList[index];
          },
        );
      default:
        return Container();
    }
  }

  void _onMedicationChipSelectedCallback(
      String tag, String data, bool boolValue) {
    _updateMedicationSelectedDataModel();
    _storeExpandedWidgetDataIntoLocalModel();
  }

  Widget _getAddedDosageList(int index1) {
    if (_numberOfDosageAddedList[index1] > 0) {
      String medName = widget.valuesList[index1].selectedText!;
      Questions? questions =
          widget.medicationExpandableWidgetList!.firstWhereOrNull((element) {
        List<String> splitConditionList = element.precondition!.split('=');
        if (splitConditionList.length == 2) {
          splitConditionList[0] = splitConditionList[0].trim();
          splitConditionList[1] = splitConditionList[1].trim();

          if (medName.length < 5) {
            return medName == splitConditionList[1];
          } else if (medName == widget.valuesList[index1].text) {
            return medName == splitConditionList[1];
          } else {
            return (splitConditionList[1].contains(
                medName.replaceAll("(generic)", Constant.blankString).trim()));
          }
        } else {
          return false;
        }
      });

      //DateTime medicationDateTime = DateTime.now();
      String medicationTime = Constant.morningTime;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_numberOfDosageAddedList[index1], (index) {
          /*try {
            medicationDateTime =
                DateTime.parse(_medicineTimeList[index1][index + 1]);
          } catch (e) {
            debugPrint(e.toString());
          }*/
          medicationTime = _medicineTimeList[index1][index + 1];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /*Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Divider(
                  height: 40,
                  thickness: 0.5,
                  color: Constant.chatBubbleGreen,
                ),
              ),*/
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 5),
                child: CustomTextWidget(
                  text: 'Dose ${index + 2}',
                  style: TextStyle(
                    color: Constant.locationServiceGreen,
                    fontFamily: Constant.jostRegular,
                    fontSize: Platform.isAndroid ? 14 : 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomTextWidget(
                  text:
                      'When did you take ${medName[0].toLowerCase()}${medName.substring(1)}?',
                  style: TextStyle(
                      color: Constant.locationServiceGreen,
                      fontFamily: Constant.jostRegular,
                      fontSize: Platform.isAndroid ? 14 : 15,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              _getMedicationTimeRadioButton(
                  selectedMedicationTime: medicationTime,
                  medicationItemIndex: index + 1,
                  index: index1),
              /*Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        color: Constant.backgroundTransparentColor,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _whichExpandedMedicationItemSelected = index + 1;
                              _openDatePickerBottomSheet(
                                  CupertinoDatePickerMode.time, index1);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: CustomTextWidget(
                                text: Utils.getTimeInAmPmFormat(
                                    medicationDateTime.hour,
                                    medicationDateTime.minute),
                                style: TextStyle(
                                    color: Constant.splashColor,
                                    fontFamily: Constant.jostRegular,
                                    fontSize: Platform.isAndroid ? 14 : 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),*/
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _numberOfDosageAddedList[index1] =
                          _numberOfDosageAddedList[index1] - 1;
                      _medicineTimeList[index1].removeAt(index + 1);
                      _medicationDosageList[index1].removeAt(index + 1);
                      try {
                        _additionalMedicationDosage[index1].removeAt(index + 1);
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                      _updateMedicationSelectedDataModel();
                      _storeExpandedWidgetDataIntoLocalModel();
                    });
                  },
                  child: CustomTextWidget(
                    text:
                        '- Remove this dose of ${medName[0].toLowerCase()}${medName.substring(1)}',
                    style: TextStyle(
                      fontSize: Platform.isAndroid ? 14 : 15,
                      color: Constant.addCustomNotificationTextColor,
                      fontWeight: FontWeight.w500,
                      fontFamily: Constant.jostRegular,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomTextWidget(
                  text: (questions == null)
                      ? 'What dosage did you take?'
                      : questions.helpText ?? '',
                  style: TextStyle(
                    color: Constant.locationServiceGreen,
                    fontFamily: Constant.jostRegular,
                    fontSize: Platform.isAndroid ? 14 : 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              if (_medicationDosageList[index1][index + 1].values != null)
                Container(
                  height: 30,
                  child: LogDayChipList(
                    question: _medicationDosageList[index1][index + 1],
                    onSelectCallback: _onMedicationChipSelectedCallback,
                  ),
                )
              else
                Visibility(
                  visible: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Constant.backgroundTransparentColor,
                                borderRadius: BorderRadius.circular(5)),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  _showMedicationDosagePicker(
                                      index + 1, index1);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color:
                                          Constant.backgroundTransparentColor,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: CustomTextWidget(
                                      text: (_additionalMedicationDosage[index1]
                                                  .length >=
                                              index + 2)
                                          ? _additionalMedicationDosage[index1]
                                              [index + 1]
                                          : '50 mg',
                                      style: TextStyle(
                                          color: Constant.splashColor,
                                          fontFamily: Constant.jostRegular,
                                          fontSize:
                                              Platform.isAndroid ? 14 : 15),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: 15,
              ),
            ],
          );
        }),
      );
    } else {
      return Container();
    }
  }

  void onValueChangedCallback(String currentTag, String value,
      [bool isFromTextField = false]) {
    SelectedAnswers? selectedAnswersObj = selectedAnswerListOfTriggers
        .firstWhereOrNull((element) => element.questionTag == currentTag);
    if (selectedAnswersObj != null) {
      selectedAnswersObj.answer = value;
    } else {
      selectedAnswerListOfTriggers
          .add(SelectedAnswers(questionTag: currentTag, answer: value));
    }

    _storeExpandedWidgetDataIntoLocalModel(-1, isFromTextField);
  }

  /// This method is used to get list of chips widget which will be shown when user taps on the options of sleep section
  List<Widget> _getChipsWidget() {
    List<Widget> chipsList = [];

    widget.sleepExpandableWidgetList![0].values!.forEach((element) {
      chipsList.add(GestureDetector(
        onTap: () {
          setState(() {
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
                color: /*element.isDoubleTapped ? Constant.doubleTapTextColor : Constant.chatBubbleGreen*/
                    Constant.chatBubbleGreen,
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

    DateTime now = DateTime.now();
    _selectedDateTime = widget.selectedDateTime ?? now;

    _selectedDateTime = DateTime(
      _selectedDateTime?.year ?? now.year,
      _selectedDateTime?.month ?? now.month,
      _selectedDateTime?.day ?? now.day,
    );

    _animationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);

    if (widget.selectedAnswers != null) {
      widget.selectedAnswers.forEach((element) {
        if (element.questionTag!.contains('triggers1.')) {
          selectedAnswerListOfTriggers.add(element);
        }
      });
    }

    if (widget.contentType == 'triggers1')
      debugPrint('abc');

    if (widget.contentType == 'medication') {
      _formulationQuestionList = widget.allQuestionsList?.where((element) => element.tag!.contains('.formulation')).toList() ?? [];

      SelectedAnswers? selectedAnswers = widget.selectedAnswers.firstWhereOrNull((element) => element.questionTag == Constant.administeredTag);

      if (selectedAnswers != null) {
        List<MedicationListActionSheetModel> list = medicationListActionSheetModelFromJson(selectedAnswers.answer ?? '[]');

        list.forEach((element) {
          if (element.isPreventive) {
            _isPreventiveMedicationLogged = true;
            _preventiveMedicationActionSheetModelList.add(element);
          }
          else
            _acuteMedicationActionSheetModelList.add(element);

          MedicationDataModel medicationDataModel = MedicationDataModel();

          medicationDataModel.medicationText = element.medicationText;
          medicationDataModel.dosageValue = element.selectedDosage;
          medicationDataModel.formulation = element.formulationText;
          medicationDataModel.numberOfDosage = element.numberOfDosage;
          medicationDataModel.medicationTime = element.selectedTime;
          medicationDataModel.startDateTime = element.startDate;
          medicationDataModel.endDateTime = element.endDate;
          medicationDataModel.isPreventive = element.isPreventive;
          medicationDataModel.isChecked = element.isChecked;

          if (element.isPreventive)
            _preventiveMedicationDataModelList.add(medicationDataModel);
          else
            _acuteMedicationDataModelList.add(medicationDataModel);
        });
      }

      if (_preventiveMedicationActionSheetModelList.isEmpty) {
        widget.userMedicationHistoryList.where((el) => el.endDate == null).toList().forEach((element) {
          if (element.isPreventive) {
            _medicationCheckBoxValue = true && _selectedDateTime!.isAtSameMomentAs(DateTime(now.year, now.month, now.day));

            if (_medicationCheckBoxValue) {
              int? id = element.id;
              String medicationText = element.medicationName;
              String formulationText = '';
              String formulationTag = '';

              Questions? formulationQuestion = _formulationQuestionList.firstWhereOrNull((el) {
                List<String> splitConditionList = el.text!.split('=');
                if (splitConditionList.length == 2) {
                  splitConditionList[0] = splitConditionList[0].trim();
                  splitConditionList[1] = splitConditionList[1].trim();
                  return medicationText == splitConditionList[1];
                } else {
                  return false;
                }
              });

              if (formulationQuestion != null) {
                formulationText = element.formulation;
                formulationTag = formulationQuestion.tag ?? '';
              } else {
                formulationText = element.formulation;
                formulationTag = '${medicationText}_custom.formulation';
              }

              String selectedTime = element.medicationTime;
              DateTime? startDate = element.startDate;
              DateTime? endDate = element.endDate;

              String selectedDosage = '';
              String dosageTag = '';

              Questions? dosageQuestion = widget.medicationExpandableWidgetList?.firstWhereOrNull((el) {
                List<String> splitConditionList = el.precondition!.split('=');
                if (splitConditionList.length == 2) {
                  splitConditionList[0] = splitConditionList[0].trim();
                  splitConditionList[1] = splitConditionList[1].trim();

                  return splitConditionList[0] == formulationTag && splitConditionList[1] == formulationText;
                } else {
                  return false;
                }
              });

              if (dosageQuestion != null) {
                selectedDosage = element.dosage;
                dosageTag = dosageQuestion.tag ?? '';
              } else {
                selectedDosage = element.dosage;
                dosageTag = '${medicationText}_custom.dosage';
              }


              Values? medicationValue;
              double? numberOfDosage = double.tryParse(element.numberOfDosage);
              bool isPreventive = element.isPreventive;
              String? reason = element.reason;
              String? comments = element.comments;
              bool isDeleted = false;

              _preventiveMedicationActionSheetModelList.add(MedicationListActionSheetModel(
                id: id,
                medicationText: medicationText,
                formulationText: formulationText,
                formulationTag: formulationTag,
                selectedTime: selectedTime,
                startDate: startDate,
                endDate: endDate,
                selectedDosage: selectedDosage,
                dosageTag: dosageTag,
                medicationValue: medicationValue,
                numberOfDosage: numberOfDosage,
                isPreventive: isPreventive,
                reason: reason,
                comments: comments,
                isDeleted: isDeleted,
                isChecked: true,
              ));

              MedicationDataModel medicationDataModel = MedicationDataModel();

              medicationDataModel.medicationText = medicationText;
              medicationDataModel.dosageValue = selectedDosage;
              medicationDataModel.formulation = formulationText;
              medicationDataModel.numberOfDosage = numberOfDosage;
              medicationDataModel.medicationTime = selectedTime;
              medicationDataModel.startDateTime = startDate;
              medicationDataModel.endDateTime = endDate;
              medicationDataModel.isPreventive = isPreventive;
              medicationDataModel.isChecked = true;

              if (element.isPreventive)
                _preventiveMedicationDataModelList.add(medicationDataModel);
            }
          }
        });
      }

      /*if (_acuteMedicationActionSheetModelList.isEmpty) {
        widget.userMedicationHistoryList.where((el) => el.endDate == null && !el.isPreventive).toList().forEach((element) {
          int? id = element.id;
          String medicationText = element.medicationName;
          String formulationText = '';
          String formulationTag = '';

          Questions? formulationQuestion = _formulationQuestionList.firstWhereOrNull((el) {
            List<String> splitConditionList = el.text!.split('=');
            if (splitConditionList.length == 2) {
              splitConditionList[0] = splitConditionList[0].trim();
              splitConditionList[1] = splitConditionList[1].trim();
              return medicationText == splitConditionList[1];
            } else {
              return false;
            }
          });

          if (formulationQuestion != null) {
            Values? formulationValue = formulationQuestion.values?.firstWhereOrNull((el) => el.text == element.formulation);

            if (formulationValue != null) {
              formulationText = element.formulation;
              formulationTag = formulationQuestion.tag ?? '';
            }
          }

          String selectedTime = element.medicationTime;
          DateTime? startDate = element.startDate;
          DateTime? endDate = element.endDate;

          String selectedDosage = '';
          String dosageTag = '';

          Questions? dosageQuestion = widget.medicationExpandableWidgetList?.firstWhereOrNull((el) {
            List<String> splitConditionList = el.precondition!.split('=');
            if (splitConditionList.length == 2) {
              splitConditionList[0] = splitConditionList[0].trim();
              splitConditionList[1] = splitConditionList[1].trim();

              return splitConditionList[0] == formulationTag && splitConditionList[1] == formulationText;
            } else {
              return false;
            }
          });

          if (dosageQuestion != null) {
            Values? dosageValue = dosageQuestion.values?.firstWhereOrNull((el) => el.text == element.dosage);

            if (dosageValue != null) {
              selectedDosage = element.dosage;
              dosageTag = dosageQuestion.tag ?? '';
            }
          }


          Values? medicationValue;
          double? numberOfDosage = double.tryParse(element.numberOfDosage);
          bool isPreventive = element.isPreventive;
          String? reason = element.reason;
          String? comments = element.comments;
          bool isDeleted = false;

          _acuteMedicationActionSheetModelList.add(MedicationListActionSheetModel(
            id: id,
            medicationText: medicationText,
            formulationText: formulationText,
            formulationTag: formulationTag,
            selectedTime: selectedTime,
            startDate: startDate,
            endDate: endDate,
            selectedDosage: selectedDosage,
            dosageTag: dosageTag,
            medicationValue: medicationValue,
            numberOfDosage: numberOfDosage,
            isPreventive: isPreventive,
            reason: reason,
            comments: comments,
            isDeleted: isDeleted,
            isChecked: true,
          ));

          MedicationDataModel medicationDataModel = MedicationDataModel();

          medicationDataModel.medicationText = medicationText;
          medicationDataModel.dosageValue = selectedDosage;
          medicationDataModel.formulation = formulationText;
          medicationDataModel.numberOfDosage = numberOfDosage;
          medicationDataModel.medicationTime = selectedTime;
          medicationDataModel.startDateTime = startDate;
          medicationDataModel.endDateTime = endDate;
          medicationDataModel.isPreventive = isPreventive;
          medicationDataModel.isChecked = true;

          _acuteMedicationDataModelList.add(medicationDataModel);
        });
      }*/

      _updateMedicationModel();
    } else if (widget.contentType == 'device') {
      _devicesList.add(
          Values(valueNumber: '500', text: Constant.plusText, isValid: true));
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

  /// @param cupertinoDatePickerMode: for time and date mode selection
  /// @param whichPickerClicked: 0 for startDate, 1 for startTime, 2 for endDate, 3 for endTime
  void _openDatePickerBottomSheet(
      MonthYearCupertinoDatePickerMode cupertinoDatePickerMode, int index) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (context) => DatePicker(
              cupertinoDatePickerMode: cupertinoDatePickerMode,
              onDateTimeSelected: (DateTime dateTime) {
                DateTime nowDateTime = DateTime(
                  _selectedDateTime!.year,
                  _selectedDateTime!.month,
                  _selectedDateTime!.day,
                  dateTime.hour,
                  dateTime.minute,
                  0,
                  0,
                  0,
                );
                setState(() {
                  /*_medicineTimeList[index]
                          [_whichExpandedMedicationItemSelected] =
                      nowDateTime.toString();*/
                  _medicineTimeList[index]
                          [_whichExpandedMedicationItemSelected] =
                      Constant.morningTime;
                });

                _updateMedicationSelectedDataModel();

                _storeExpandedWidgetDataIntoLocalModel(index);
              },
            ));
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
                selectedDosageList.add(element3.text!);
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
            .firstWhereOrNull((element) =>
                element.questionTag == widget.contentType &&
                element.answer == selectedAnswer);
        if (selectedAnswersValue == null)
          widget.selectedAnswers.add(SelectedAnswers(
              questionTag: widget.contentType, answer: selectedAnswer));
      } else {
        SelectedAnswers? selectedAnswerObj = widget.selectedAnswers
            .firstWhereOrNull((element) =>
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
    debugPrint('check here 4');
  }

  void _storeExpandedWidgetDataIntoLocalModel(
      [int? selectedMedicationIndex, bool? isFromTextField]) {
    switch (widget.contentType) {
      case 'behavior.presleep':
        String text = widget.valuesList[whichSleepItemSelected].text!;
        String preCondition =
            widget.sleepExpandableWidgetList![0].precondition!;

        if (preCondition.contains(text)) {
          List<Values> values = widget.sleepExpandableWidgetList![0].values!;

          widget.selectedAnswers.removeWhere(
              (element) => element.questionTag == 'behavior.sleep');

          values.forEach((element) {
            if (element.isSelected) {
              SelectedAnswers? selectedAnswers = widget.selectedAnswers
                  .firstWhereOrNull((element1) =>
                      element1.questionTag == 'behavior.sleep' &&
                      element1.answer == element.text);
              if (selectedAnswers == null)
                widget.selectedAnswers.add(SelectedAnswers(
                    questionTag: 'behavior.sleep', answer: element.text));
            }
          });
        } else {
          widget.selectedAnswers.removeWhere(
              (element) => element.questionTag == 'behavior.sleep');
        }
        break;
      case 'medication':
        widget.selectedAnswers
            .removeWhere((element) => element.questionTag == 'administered');
        SelectedAnswers? selectedAnswers = widget.selectedAnswers
            .firstWhereOrNull(
                (element) => element.questionTag == 'administered');
        if (selectedAnswers == null) {
          if (_medicationSelectedDataModel != null) {
            if (_medicationSelectedDataModel.selectedMedicationIndex.isNotEmpty)
              widget.selectedAnswers.add(SelectedAnswers(
                  questionTag: 'administered',
                  answer: medicationSelectedDataModelToJson(
                      _medicationSelectedDataModel)));
          }
        } else {
          if (_medicationSelectedDataModel != null) {
            if (_medicationSelectedDataModel.selectedMedicationIndex.isNotEmpty)
              selectedAnswers.answer = medicationSelectedDataModelToJson(
                  _medicationSelectedDataModel);
            else
              widget.selectedAnswers.removeWhere(
                  (element) => element.questionTag == 'administered');
          }
        }

        if (previousMedicationTag != null) {
          widget.selectedAnswers.removeWhere(
              (element) => element.questionTag == previousMedicationTag);
        }

        try {
          previousMedicationTag = widget
              .medicationExpandableWidgetList![selectedMedicationIndex!].tag;
          Values? selectedDosageValue = widget
              .medicationExpandableWidgetList![selectedMedicationIndex].values!
              .firstWhereOrNull((element) => element.isSelected);
          if (selectedDosageValue != null) {
            widget.selectedAnswers.add(SelectedAnswers(
                questionTag: previousMedicationTag!,
                answer: selectedDosageValue.text));
          }
        } catch (e) {
          print(e);
        }
        break;
      case 'triggers1':
        widget.valuesList.forEach((element) {
          if (element.isSelected) {
            Questions? questionTriggerData = widget.triggerExpandableWidgetList!
                .firstWhereOrNull((element1) => element1.precondition!
                    .toLowerCase()
                    .contains(element.text!.toLowerCase()));
            if (questionTriggerData != null) {
              if (questionTriggerData.tag != 'triggers1.travel') {
                SelectedAnswers? selectedAnswerTriggerData =
                    selectedAnswerListOfTriggers.firstWhereOrNull((element1) =>
                        element1.questionTag == questionTriggerData.tag);
                if (selectedAnswerTriggerData != null) {
                  SelectedAnswers? selectedAnswerData;
                  if ((isFromTextField == null) ? false : !isFromTextField) {
                    selectedAnswerData = widget.selectedAnswers
                        .firstWhereOrNull((element1) =>
                            element1.questionTag ==
                            selectedAnswerTriggerData.questionTag);
                  } else {
                    selectedAnswerData = widget.selectedAnswers
                        .firstWhereOrNull((element1) =>
                            element1.questionTag ==
                            selectedAnswerTriggerData.questionTag);

                    debugPrint(selectedAnswerData.toString());
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
                SelectedAnswers? selectedAnswerTriggerData =
                    selectedAnswerListOfTriggers.firstWhereOrNull((element1) =>
                        element1.questionTag == questionTriggerData.tag);
                if (selectedAnswerTriggerData != null) {
                  SelectedAnswers? selectedAnswerData = widget.selectedAnswers
                      .firstWhereOrNull((element1) =>
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

  void _openAddNewMedicationDialog() async {
    FocusScope.of(context).requestFocus(FocusNode());
    var addMedicationResult = await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: AddNewMedicationDialog(
                onSubmitClickedCallback: (addMedicationResult) {},
              ),
            ));

    if (addMedicationResult != null &&
        addMedicationResult is String &&
        addMedicationResult != '') {
      Values? medValue = widget.valuesList.firstWhereOrNull((element) =>
          element.text!.toLowerCase() ==
          addMedicationResult.toLowerCase().trim());
      if (medValue == null) {
        setState(() {
          widget.valuesList.insert(
              widget.valuesList.length - 1,
              Values(
                text: addMedicationResult.trim(),
                valueNumber: (widget.valuesList.length).toString(),
                isSelected: true,
                isNewlyAdded: true,
                selectedText: addMedicationResult.trim(),
              ));
          DateTime nowDateTime = DateTime(
            _selectedDateTime!.year,
            _selectedDateTime!.month,
            _selectedDateTime!.day,
            DateTime.now().hour,
            DateTime.now().minute,
            0,
            0,
            0,
          );
          /*_medicineTimeList
              .add(List.generate(1, (index) => nowDateTime.toString()));*/
          _medicineTimeList
              .add(List.generate(1, (index) => Constant.morningTime));
          _medicationDosageList.add(List.generate(1, (index) => Questions()));
          _numberOfDosageAddedList.add(0);
          _additionalMedicationDosage.add([]);
          widget.medicationExpandableWidgetList!
              .add(Questions(precondition: ''));

          _onMedicationItemSelected(widget.valuesList.length - 2);
        });
      } else {
        Future.delayed(Duration(milliseconds: 900), () {
          Utils.showValidationErrorDialog(
              context, 'Medication already added.', 'Alert!');
        });
      }
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

  void _showMedicationDosagePicker(
      int index, int selectedMedicationIndex) async {
    var resultFromActionSheet = await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (context) => MedicationDosagePicker(
              selectedDosageValue:
                  _additionalMedicationDosage[selectedMedicationIndex].length >=
                          index + 1
                      ? _additionalMedicationDosage[selectedMedicationIndex]
                          [index]
                      : null,
            ));

    if (resultFromActionSheet != null && resultFromActionSheet is String) {
      SelectedAnswers? dosageSelectedAnswer = widget.selectedAnswers
          .firstWhereOrNull((element) =>
              element.questionTag ==
              '${widget.valuesList[selectedMedicationIndex].text}_custom.dosage');
      if (dosageSelectedAnswer != null) {
        List<String> selectedValuesList =
            (json.decode(dosageSelectedAnswer.answer!) as List<dynamic>)
                .cast<String>();
        if (selectedValuesList != null && selectedValuesList.length >= 1) {
          selectedValuesList[index] = resultFromActionSheet;
        }
      }
      if (_additionalMedicationDosage[selectedMedicationIndex].length >=
          index + 1) {
        _additionalMedicationDosage[selectedMedicationIndex][index] =
            resultFromActionSheet;
      } else {
        _additionalMedicationDosage[selectedMedicationIndex]
            .add(resultFromActionSheet);
      }
      _updateMedicationSelectedDataModel();
      _storeExpandedWidgetDataIntoLocalModel();
      setState(() {});
    }
  }

  void _generateTriggerWidgetList(int whichTriggerItemSelected) {
    String triggerName = widget.valuesList[whichTriggerItemSelected].text!;

    bool isSelected = widget.valuesList[whichTriggerItemSelected].isSelected;
    Questions? questions = widget.triggerExpandableWidgetList!.firstWhereOrNull(
        (element) => element.precondition!
            .toLowerCase()
            .contains(triggerName.toLowerCase()));
    String questionTag = (questions == null)
        ? ((triggerName == Constant.menstruatingTriggerOption)
            ? 'triggers1.menstruation'
            : '')
        : questions.tag ?? '';
    TriggerWidgetModel? triggerWidgetModel = _triggerWidgetList
        .firstWhereOrNull((element) => element.questionTag == questionTag);

    String? selectedTriggerValue;
    SelectedAnswers? selectedAnswerTriggerData = selectedAnswerListOfTriggers
        .firstWhereOrNull((element) => element.questionTag == questionTag);
    if (selectedAnswerTriggerData != null) {
      selectedTriggerValue = selectedAnswerTriggerData.answer;
    }

    List<TriggerWidgetModel> tempList = [];

    _triggerWidgetList.forEach((element) {
      tempList.add(element);
    });

    List<int> indexList = [];

    tempList.forEach((element) {
      indexList.add(_triggerWidgetList.indexOf(element));
    });

    _triggerWidgetList.clear();

    tempList.asMap().forEach((index, value) {
      _addTextBoxDataToList(indexList, value, index);
    });

    if (triggerWidgetModel == null) {
      if (questions == null) {
        if (triggerName == Constant.menstruatingTriggerOption) {
          if (isSelected) {
            _triggerWidgetList.add(TriggerWidgetModel(
              questionTag: "triggers1.menstruation",
              questionType: questions?.questionType,
              helpText: questions?.helpText,
              widget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      height: 40,
                      thickness: 0.5,
                      color: Constant.chatBubbleGreen,
                    ),
                  ),
                  CheckboxWidget(
                    questionTag: "triggers1.menstruation",
                    checkboxTitle: "I started my menses today.",
                    checkboxColor: Constant.locationServiceGreen,
                    textColor: Constant.locationServiceGreen,
                    initialValue: selectedTriggerValue == Constant.trueString,
                    onChanged: (String questionTag, bool value) {
                      onValueChangedCallback(questionTag, value.toString());

                      SelectedAnswers? selectedAnswersObj = widget.selectedAnswers
                          .firstWhereOrNull((element) => element.questionTag == questionTag);
                      if (selectedAnswersObj != null) {
                        selectedAnswersObj.answer = value.toString();
                      } else {
                        widget.selectedAnswers.add(SelectedAnswers(questionTag: questionTag, answer: value.toString()));
                      }
                    },
                  ),
                ],
              ),
            ));
          }
        } else {
          _triggerWidgetList
              .add(TriggerWidgetModel(questionTag: "", widget: Container()));
        }
      } else {
        switch (questions.questionType) {
          case 'number':
            _triggerWidgetList.add(TriggerWidgetModel(
                questionTag: questions.tag,
                questionType: questions.questionType,
                helpText: questions.helpText,
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        height: 40,
                        thickness: 0.5,
                        color: Constant.chatBubbleGreen,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomTextWidget(
                        text: questions.helpText!,
                        style: TextStyle(
                          color: Constant.locationServiceGreen,
                          fontFamily: Constant.jostRegular,
                          fontSize: Platform.isAndroid ? 14 : 15,
                          fontWeight: FontWeight.w500,
                        ),
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
                      onValueChangeCallback: onValueChangedCallback,
                      uiHints: questions.uiHints!,
                    ),
                  ],
                )));
            break;
          case 'text':
            _triggerWidgetList.add(TriggerWidgetModel(
                questionTag: questions.tag,
                questionType: questions.questionType,
                helpText: questions.helpText,
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        height: 40,
                        thickness: 0.5,
                        color: Constant.chatBubbleGreen,
                      ),
                    ),
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
                        questionTag: questionTag,
                        minLines: 5,
                        maxLines: 6,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        controller: TextEditingController(text: (selectedTriggerValue != null)
                            ? selectedTriggerValue
                            : ''),
                        onChanged: (text) {
                          selectedTriggerValue = text.trim();
                          onValueChangedCallback(
                              questionTag, text.trim(), true);
                        },
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
                questionType: questions.questionType,
                helpText: questions.helpText,
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        height: 40,
                        thickness: 0.5,
                        color: Constant.chatBubbleGreen,
                      ),
                    ),
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
                          onSelectCallback: onValueChangedCallback,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                )));
            break;
          default:
            _triggerWidgetList.add(TriggerWidgetModel(
                helpText: questions.helpText,
                questionTag: questions.tag, questionType: questions.questionType, widget: Container()));
        }
      }
    } else {
      if (!isSelected) {
        _triggerWidgetList.removeWhere((element) => element.questionTag == questionTag);
        selectedAnswerListOfTriggers
            .removeWhere((element) => element.questionTag == questionTag);
      }
    }
  }

  void _openSearchMedicationActionSheet(
      BuildContext context,
      LatestMedicationDataModelInfo data,
      bool isEdit,
      int? elementIndex,
      bool isPreventive) async {
    List<Values> preventiveMedicationValuesList = [];
    List<Values> acuteMedicationValuesList = [];
    for (Values value in widget.valuesList) {
      if (value.medicationType == 1) {
        acuteMedicationValuesList.add(value);
      } else if(value.medicationType == 2){
        preventiveMedicationValuesList.add(value);
      } else{
        acuteMedicationValuesList.add(value);
        preventiveMedicationValuesList.add(value);
      }
    }

    if (isEdit) {
      MedicationListActionSheetModel model = isPreventive ? _preventiveMedicationActionSheetModelList.where((element) => !element.isDeleted).toList()[elementIndex!] : _acuteMedicationActionSheetModelList.where((element) => !element.isDeleted).toList()[elementIndex!];

      data.setMedicationListActionSheetModel = model.createCopy(model);
      data.updateLatestMedicationDataModelIndex(elementIndex, true);
      data.updateLatestMedicationDataModel(
          null,
          (isPreventive)
              ? _preventiveMedicationDataModelList
              : _acuteMedicationDataModelList,
          (isPreventive) ? Constant.preventive : Constant.acute);
    } else {
      data.updateLatestMedicationDataModelIndex(null, false);
    }

    MedicationListActionSheetModel? medicationListActionSheetModel =
        await showModalBottomSheet(
      backgroundColor: Constant.transparentColor,
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => BackVisibilityProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => data,
            ),
          ],
          child: MedicationListActionSheet(medicationValuesList: (isPreventive)
                ? preventiveMedicationValuesList
                : acuteMedicationValuesList,
            recentMedicationMapList: widget.recentMedicationMapList!,
            selectedMedicationMapList: widget.selectedMedicationMapList!,
            dosageQuestionList: widget.medicationExpandableWidgetList!,
            formulationQuestionList: _formulationQuestionList,
            medicationHistoryModelList: widget.userMedicationHistoryList.where((element) => element.isPreventive == isPreventive).toList(),
            selectedDateTime: _selectedDateTime ?? DateTime.now(),
          ),
        ),
      ),
    );

    data.setMedicationListActionSheetModel = null;
    data.setMedicationHistoryModel = null;

    if (medicationListActionSheetModel != null) {
      _medicationListActionSheetModel = medicationListActionSheetModel;

      if (!isEdit) {
        MedicationDataModel _newMedicationDataModel = MedicationDataModel(
          medicationText: medicationListActionSheetModel.medicationText,
          dosageValue: medicationListActionSheetModel.selectedDosage,
          numberOfDosage: medicationListActionSheetModel.numberOfDosage,
          medicationTime: medicationListActionSheetModel.selectedTime,
          formulation: medicationListActionSheetModel.formulationText,
          startDateTime: medicationListActionSheetModel.startDate,
          endDateTime: medicationListActionSheetModel.endDate,
          isPreventive: isPreventive,
          isChecked: true,
        );

        (isPreventive)
            ? _preventiveMedicationDataModelList.add(_newMedicationDataModel)
            : _acuteMedicationDataModelList.add(_newMedicationDataModel);

        data.updateLatestMedicationDataModel(
            _newMedicationDataModel,
            (isPreventive)
                ? _preventiveMedicationDataModelList
                : _acuteMedicationDataModelList,
            (isPreventive) ? Constant.preventive : Constant.acute);
      } else {
        MedicationDataModel _editedMedicationDataModel = MedicationDataModel(
          medicationText: (isPreventive) ? _preventiveMedicationDataModelList[elementIndex!].medicationText : _acuteMedicationDataModelList[elementIndex!].medicationText,
          dosageValue: medicationListActionSheetModel.selectedDosage,
          numberOfDosage: medicationListActionSheetModel.numberOfDosage,
          medicationTime: medicationListActionSheetModel.selectedTime,
          formulation: medicationListActionSheetModel.formulationText,
          startDateTime: medicationListActionSheetModel.startDate,
          endDateTime: medicationListActionSheetModel.endDate,
          isPreventive: isPreventive,
          isChecked: true,
        );

        (isPreventive)
            ? _preventiveMedicationDataModelList[elementIndex] =
                _editedMedicationDataModel
            : _acuteMedicationDataModelList[elementIndex] =
                _editedMedicationDataModel;

        data.updateLatestMedicationDataModel(
            _editedMedicationDataModel,
            (isPreventive)
                ? _preventiveMedicationDataModelList
                : _acuteMedicationDataModelList,
            (isPreventive) ? Constant.preventive : Constant.acute);
      }

      if (!isEdit) {
        medicationListActionSheetModel.isPreventive = isPreventive;
        if (isPreventive) {
          _preventiveMedicationActionSheetModelList.add(medicationListActionSheetModel);
        } else {
          _acuteMedicationActionSheetModelList.add(medicationListActionSheetModel);
        }
      } else {
        if (isPreventive) {
          _preventiveMedicationActionSheetModelList.where((element) => !element.isDeleted).toList()[elementIndex!]
            ..id = medicationListActionSheetModel.id
            ..medicationText = medicationListActionSheetModel.medicationText
            ..formulationText = medicationListActionSheetModel.formulationText
            ..formulationTag = medicationListActionSheetModel.formulationTag
            ..selectedTime = medicationListActionSheetModel.selectedTime
            ..startDate = medicationListActionSheetModel.startDate
            ..endDate = medicationListActionSheetModel.endDate
            ..selectedDosage = medicationListActionSheetModel.selectedDosage
            ..dosageTag = medicationListActionSheetModel.dosageTag
            ..medicationValue = medicationListActionSheetModel.medicationValue
            ..numberOfDosage = medicationListActionSheetModel.numberOfDosage
            ..isChecked = true
            ..isPreventive = true;
        } else {
          _acuteMedicationActionSheetModelList.where((element) => !element.isDeleted).toList()[elementIndex!]
            ..id = medicationListActionSheetModel.id
            ..medicationText = medicationListActionSheetModel.medicationText
            ..formulationText = medicationListActionSheetModel.formulationText
            ..formulationTag = medicationListActionSheetModel.formulationTag
            ..selectedTime = medicationListActionSheetModel.selectedTime
            ..startDate = medicationListActionSheetModel.startDate
            ..endDate = medicationListActionSheetModel.endDate
            ..selectedDosage = medicationListActionSheetModel.selectedDosage
            ..dosageTag = medicationListActionSheetModel.dosageTag
            ..medicationValue = medicationListActionSheetModel.medicationValue
            ..numberOfDosage = medicationListActionSheetModel.numberOfDosage
            ..isChecked = true
            ..isPreventive = false;
        }
      }

      debugPrint('check');

      //_onMedicationItemSelected(index);
    }

    _updateMedicationModel();
  }

  //Opens the MedicationHistoryActionSheet
  void _openMedicationHistoryActionSheet() async {
    List<MedicationHistoryModel> medicationDataModelList = [];

    medicationDataModelList = widget.userMedicationHistoryList./*where((element) => element.endDate != null).*/toList();

    await showModalBottomSheet(
      backgroundColor: Constant.transparentColor,
      context: context,
      isScrollControlled: true,
      builder: (context) => MedicationHistoryActionSheet(
        medicationDataModelList: medicationDataModelList,
      ),
    );
  }

  void _openMedicationDeleteDialog(BuildContext context, int index, bool isPreventive, LatestMedicationDataModelInfo data) async {
    //show dialog with questionnaire and save its result list
    //delete the give index element from the list
    List medicationListActionSheetModelList = isPreventive ? _preventiveMedicationActionSheetModelList : _acuteMedicationDataModelList;
    MedicationListActionSheetModel model;
    //if(medicationListActionSheetModelList.isNotEmpty && medicationListActionSheetModelList.length > index){
      model = isPreventive ? _preventiveMedicationActionSheetModelList.where((element) => !element.isDeleted).toList()[index] : _acuteMedicationActionSheetModelList.where((element) => !element.isDeleted).toList()[index];
    //}

    if (model.id != null && model.endDate == null) {
      MedicationDeleteModel? medicationDeleteModel = await showDialog(
          context: context,
          builder: (context) {
            return ChangeNotifierProvider(
              create: (_) => SelectedAnswersInfo(),
              child: Consumer<SelectedAnswersInfo>(
                builder: (context, data, child) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: MedicationDeleteDialog(),
                    ),
                  );
                },
              ),
            );
          });
      if (medicationDeleteModel != null) {
          data.deleteCustomMedicationElement(index);
          setState(() {
            if (isPreventive) {
              _preventiveMedicationDataModelList.removeAt(index);
            } else {
              _acuteMedicationDataModelList.removeAt(index);
            }
          });

        MedicationListActionSheetModel medicationListActionSheetModel = isPreventive ? _preventiveMedicationActionSheetModelList.where((element) => !element.isDeleted).toList()[index] : _acuteMedicationActionSheetModelList.where((element) => !element.isDeleted).toList()[index];

        if (medicationListActionSheetModel.id == null) {
          if (isPreventive) {
            _preventiveMedicationActionSheetModelList.remove(medicationListActionSheetModel);
          }
          else {
            _acuteMedicationActionSheetModelList.remove(medicationListActionSheetModel);
          }
        } else {
          medicationListActionSheetModel.isDeleted = true;
          if (medicationDeleteModel.isStopped == true) {
            DateTime now = DateTime.now();
            medicationListActionSheetModel.endDate = DateTime(now.year, now.month, now.day);
            medicationListActionSheetModel.reason = medicationDeleteModel.reason;
            medicationListActionSheetModel.comments = medicationDeleteModel.comments;
          }
        }
        _updateMedicationModel();
      }
    } else {
      dynamic data = await Utils.showConfirmationDialog(context, "Are you sure you want to delete this medication?",);

      if (data != null && data is String) {
        if (data == 'Yes') {
          MedicationListActionSheetModel medicationListActionSheetModel = isPreventive ? _preventiveMedicationActionSheetModelList.where((element) => !element.isDeleted).toList()[index] : _acuteMedicationActionSheetModelList.where((element) => !element.isDeleted).toList()[index];
          if (isPreventive) {
            _preventiveMedicationActionSheetModelList.remove(medicationListActionSheetModel);
            _preventiveMedicationDataModelList.removeAt(index);
          } else {
            _acuteMedicationActionSheetModelList.remove(medicationListActionSheetModel);
            _acuteMedicationDataModelList.removeAt(index);
          }

          setState(() {});

          _updateMedicationModel();
        }
      }
    }
  }

  Widget _getMedicationTimeRadioButton({String? selectedMedicationTime, int? index, int? medicationItemIndex}) {
    List<Widget> widgetList = [];

    List<MedicationTimeModel> medicationTimeList = [
      MedicationTimeModel(
        medicationTime: Constant.morningTime,
        isSelected: selectedMedicationTime == Constant.morningTime,
      ),
      MedicationTimeModel(
        medicationTime: Constant.afternoonTime,
        isSelected: selectedMedicationTime == Constant.afternoonTime,
      ),
      MedicationTimeModel(
        medicationTime: Constant.eveningTime,
        isSelected: selectedMedicationTime == Constant.eveningTime,
      ),
      MedicationTimeModel(
        medicationTime: Constant.bedTime,
        isSelected: selectedMedicationTime == Constant.bedTime,
      ),
    ];

    debugPrint(medicationTimeList.toString());

    medicationTimeList.forEach((element) {
      widgetList.add(
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _whichExpandedMedicationItemSelected = medicationItemIndex!;
            setState(() {
              _medicineTimeList[index!][_whichExpandedMedicationItemSelected] = element.medicationTime!;
            });

            _updateMedicationSelectedDataModel();
            _storeExpandedWidgetDataIntoLocalModel(index);
          },
          child: Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Constant.chatBubbleGreen, width: 1),
              color: element.isSelected!
                  ? Constant.chatBubbleGreen
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: CustomTextWidget(
                text: element.medicationTime!,
                style: TextStyle(
                    color: element.isSelected! ? Constant.bubbleChatTextView : Constant.locationServiceGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: Constant.jostRegular),
              ),
            ),
          ),
        ),
      );
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: widgetList,
      ),
    );
  }

  void _openDeviceListActionSheet() async {
    Questions? deviceQuestion = widget.allQuestionsList
        ?.firstWhereOrNull((element) => element.tag == 'device');
    if (deviceQuestion != null) {
      await showModalBottomSheet(
        backgroundColor: Constant.transparentColor,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DeviceListActionSheet(
            deviceQuestion: deviceQuestion,
          ),
        ),
      );
    }
  }

  //for disposing active provider objects
  void disposeResources() {
    super.dispose();
  }

  void _updateMedicationModel() {
    List<MedicationListActionSheetModel> list = [];
    list.addAll(_preventiveMedicationActionSheetModelList);
    list.addAll(_acuteMedicationActionSheetModelList);

    if (list.isEmpty) {
      widget.selectedAnswers.removeWhere((element) => element.questionTag == Constant.administeredTag);
      return;
    }

    SelectedAnswers? administeredSelectedAnswer = widget.selectedAnswers.firstWhereOrNull((element) => element.questionTag == Constant.administeredTag);

    String json = medicationListActionSheetModelToJson(list);

    if (administeredSelectedAnswer != null) {
      administeredSelectedAnswer.answer = json;
    } else {
      widget.selectedAnswers.add(SelectedAnswers(questionTag: Constant.administeredTag, answer: json));
    }
  }

  void _addTextBoxDataToList(List<int> indexList, TriggerWidgetModel value, int index) {
    String questionTag = value.questionTag ?? '';

    String? selectedTriggerValue;
    SelectedAnswers? selectedAnswerTriggerData = selectedAnswerListOfTriggers
        .firstWhereOrNull((element) => element.questionTag == questionTag);
    if (selectedAnswerTriggerData != null) {
      selectedTriggerValue = selectedAnswerTriggerData.answer;
    }

    Questions? questions = widget.allQuestionsList?.firstWhereOrNull((element) => element.tag == questionTag);

    if (value.questionTag == 'triggers1.menstruation') {
      _triggerWidgetList.insert(index, TriggerWidgetModel(
        questionTag: "triggers1.menstruation",
        questionType: value.questionType,
        helpText: value.helpText,
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Divider(
                height: 40,
                thickness: 0.5,
                color: Constant.chatBubbleGreen,
              ),
            ),
            CheckboxWidget(
              questionTag: "triggers1.menstruation",
              checkboxTitle: "I started my menses today.",
              checkboxColor: Constant.locationServiceGreen,
              textColor: Constant.locationServiceGreen,
              initialValue: selectedTriggerValue == Constant.trueString,
              onChanged: (String questionTag, bool value) {
                onValueChangedCallback(questionTag, value.toString());

                SelectedAnswers? selectedAnswersObj = widget.selectedAnswers
                    .firstWhereOrNull((element) => element.questionTag == questionTag);
                if (selectedAnswersObj != null) {
                  selectedAnswersObj.answer = value.toString();
                } else {
                  widget.selectedAnswers.add(SelectedAnswers(questionTag: questionTag, answer: value.toString()));
                }
              },
            ),
          ],
        ),
      ));
    } else {
      switch (value.questionType) {
        case 'number':
          _triggerWidgetList.insert(index, TriggerWidgetModel(
              questionTag: value.questionTag,
              questionType: value.questionType,
              helpText: value.helpText,
              widget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      height: 40,
                      thickness: 0.5,
                      color: Constant.chatBubbleGreen,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomTextWidget(
                      text: value.helpText!,
                      style: TextStyle(
                        color: Constant.locationServiceGreen,
                        fontFamily: Constant.jostRegular,
                        fontSize: Platform.isAndroid ? 14 : 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SignUpAgeScreen(
                    currentTag: value.questionTag!,
                    sliderValue: (selectedTriggerValue != null)
                        ? double.parse(selectedTriggerValue)
                        : questions?.min!.toDouble(),
                    sliderMinValue: questions?.min!.toDouble(),
                    sliderMaxValue: questions?.max!.toDouble(),
                    minText: questions?.min.toString(),
                    maxText: questions?.max.toString(),
                    labelText: '',
                    isAnimate: false,
                    horizontalPadding: 0,
                    onValueChangeCallback: onValueChangedCallback,
                    uiHints: questions?.uiHints!,
                  ),
                ],
              )));
          break;
        case 'text':
          _triggerWidgetList.insert(index, TriggerWidgetModel(
              questionTag: value.questionTag,
              questionType: value.questionType,
              helpText: value.helpText,
              widget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      height: 40,
                      thickness: 0.5,
                      color: Constant.chatBubbleGreen,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CustomTextWidget(
                      text: value.helpText!,
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
                      questionTag: questionTag,
                      minLines: 5,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      controller: TextEditingController(text: (selectedTriggerValue != null)
                          ? selectedTriggerValue
                          : ''),
                      onChanged: (text) {
                        selectedTriggerValue = text.trim();
                        onValueChangedCallback(
                            questionTag, text.trim(), true);
                      },
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
          _triggerWidgetList.insert(index, TriggerWidgetModel(
              questionTag: questions!.tag,
              questionType: questions.questionType,
              helpText: questions.helpText,
              widget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      height: 40,
                      thickness: 0.5,
                      color: Constant.chatBubbleGreen,
                    ),
                  ),
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
                        onSelectCallback: onValueChangedCallback,
                      )),
                  SizedBox(
                    height: 10,
                  ),
                ],
              )));
          break;
        default:
          _triggerWidgetList.insert(index, TriggerWidgetModel(
              helpText: value.helpText,
              questionTag: value.questionTag, questionType: value.questionType, widget: Container()));
      }
    }
  }

  void _removeExpandableWidgetDoubleTapData(String currentTag, String selectedAnswer, bool isDoubleTapped) {
    switch (currentTag) {
      case Constant.behaviourPreSleepTag:
        if (!isDoubleTapped) {
          widget.doubleTapSelectedAnswer?.removeWhere((element) => element.questionTag == Constant.behaviourSleepTag);
        }
        break;
      case Constant.triggersTag:
        if (!isDoubleTapped) {
          switch (selectedAnswer) {
            case Constant.menstruatingTriggerOption:
              widget.doubleTapSelectedAnswer?.removeWhere((element) => element.questionTag == 'triggers1.menstruation');
              break;
            case 'Alcohol':
              widget.doubleTapSelectedAnswer?.removeWhere((element) => element.questionTag == 'triggers1.alcohol');
              break;
            case 'Caffeine':
              widget.doubleTapSelectedAnswer?.removeWhere((element) => element.questionTag == 'triggers1.caffeine');
              break;
            case 'Foods':
              widget.doubleTapSelectedAnswer?.removeWhere((element) => element.questionTag == 'triggers1.food');
              break;
            case 'Change in schedule':
              widget.doubleTapSelectedAnswer?.removeWhere((element) => element.questionTag == 'triggers1.scheduleChange');
              break;
            case 'Travel':
              widget.doubleTapSelectedAnswer?.removeWhere((element) => element.questionTag == 'triggers1.travel');
              break;
            case 'Environmental changes':
              widget.doubleTapSelectedAnswer?.removeWhere((element) => element.questionTag == 'triggers1.environment');
              break;
            case 'Other':
              widget.doubleTapSelectedAnswer?.removeWhere((element) => element.questionTag == 'triggers1.other');
              break;
          }
        }
        break;
    }
  }
}
