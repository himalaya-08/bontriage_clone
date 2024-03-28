import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/medication_data_model.dart';
import 'package:mobile/util/EmojiFilteringTextInputFormatter.dart';
import 'package:mobile/util/constant.dart';
import 'package:collection/collection.dart';
import 'package:mobile/view/CustomTextFormFieldWidget.dart';
import 'package:mobile/view/DateTimePicker.dart';
import 'package:mobile/view/medication_item_view.dart';
import 'package:mobile/view/medicationlist/medication_list_action_sheet.dart';
import 'package:mobile/view/medicationlist/medication_start_date_screen.dart';
import 'package:provider/provider.dart';

import '../CustomTextWidget.dart';
import 'medication_time_screen.dart';
import 'number_of_dosage_screen.dart';

class MedicationDosageScreen extends StatefulWidget {
  final Function(BuildContext, String, dynamic) onPush;
  final Function(MedicationListActionSheetModel) closeActionSheet;
  final List<Questions> dosageQuestionList;
  final MedicationDosageListArgumentModel? medicationDosageListArgumentModel;
  final DateTime selectedDateTime;

  const MedicationDosageScreen(
      {Key? key,
      required this.onPush,
      required this.dosageQuestionList,
      required this.closeActionSheet,
      this.medicationDosageListArgumentModel,
      required this.selectedDateTime})
      : super(key: key);

  @override
  State<MedicationDosageScreen> createState() => _MedicationDosageScreenState();
}

class _MedicationDosageScreenState extends State<MedicationDosageScreen> {
  List<Values> _dosageList = [];
  String _dosageTag = Constant.blankString;
  String _dosageQuestionText = Constant.blankString;

  late TextEditingController _textEditingController = TextEditingController();
  int _count = 0;
  bool _unitDosage = false;

  DateTime? _selectedDate;

  String _errorMessage = Constant.blankString;

  @override
  void initState() {
    super.initState();
    if (_dosageList.isEmpty) {
      Questions? dosageQuestion =
          widget.dosageQuestionList.firstWhereOrNull((element) {
        List<String> splitConditionList = element.precondition!.split('=');
        if (splitConditionList.length == 2) {
          splitConditionList[0] = splitConditionList[0].trim();
          splitConditionList[1] = splitConditionList[1].trim();

          return splitConditionList[0] ==
                  widget.medicationDosageListArgumentModel?.formulationTag &&
              splitConditionList[1] ==
                  widget.medicationDosageListArgumentModel?.formulationText;
        } else {
          return false;
        }
      });

      if (dosageQuestion != null) {
        _dosageTag = dosageQuestion.tag ?? Constant.blankString;
        _dosageQuestionText =
            'Indicate the dosage strength of ${widget.medicationDosageListArgumentModel?.medicationText}:';
        dosageQuestion.values?.forEach((element) {
          _dosageList.add(Values(
            valueNumber: element.valueNumber,
            text: element.text,
            isSelected: element.isSelected,
          ));
        });
      } else {
        _dosageTag =
            '${widget.medicationDosageListArgumentModel?.medicationText}_custom.dosage';
        _dosageQuestionText =
            'How much ${widget.medicationDosageListArgumentModel?.medicationText} did you take?';
        Future.delayed(Duration(milliseconds: 200),(){
          _focusNode.requestFocus(); //auto focus on custom text field.
        });
      }
    }

    if (_dosageList.isNotEmpty) {
      List<String> dosage = _dosageList[0].text!.split(' ');
      if (dosage.length == 2 && dosage[1] == 'units') {
        _unitDosage = true;
      }
    }
  }

  DateTime? _initialDateTime;

  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    _count++;
    bool _isEdit = context.read<LatestMedicationDataModelInfo>().getIsEdit;
    int _index =
        context.read<LatestMedicationDataModelInfo>().getElementIndex ?? 0;

    List<bool> _isCustomMedicationList =
        context.read<LatestMedicationDataModelInfo>().getIsCustomMedicationList;
    bool _isCustomMedication = false;

    String _medicationType =
        context.read<LatestMedicationDataModelInfo>().getMedicationType;
    List<MedicationDataModel> _medicationDataModelList = context
        .read<LatestMedicationDataModelInfo>()
        .getLatestMedicationDataModelList(_medicationType);

    if (_isEdit) {
      _initialDateTime = _medicationDataModelList[_index].startDateTime;
      if (_count <= 1) {
        if (_medicationDataModelList.length > _index) {
          _textEditingController.text = _medicationDataModelList[_index]
                  .dosageValue
                  ?.replaceAll('mg', '')
                  .trim()
                  .split(' ')[0] ??
              '';
        }
      }
      if (_isCustomMedicationList[_index]) {
        _isCustomMedication = _isCustomMedicationList[_index];
        _dosageTag =
            '${widget.medicationDosageListArgumentModel?.medicationText}_custom.dosage';
        _dosageQuestionText =
            'How much ${widget.medicationDosageListArgumentModel?.medicationText} did you take?';
      }
    } else {
      if (_isCustomMedicationList[_isCustomMedicationList.length - 1]) {
        _isCustomMedication =
            _isCustomMedicationList[_isCustomMedicationList.length - 1];
        _dosageTag =
            '${widget.medicationDosageListArgumentModel?.medicationText}_custom.dosage';
        _dosageQuestionText =
            'How much ${widget.medicationDosageListArgumentModel?.medicationText} did you take?';
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        color: Constant.backgroundTransparentColor,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Center(
                child: CustomTextWidget(
              text: _dosageQuestionText,
              style: TextStyle(
                  color: Constant.locationServiceGreen,
                  fontFamily: Constant.jostMedium,
                  fontSize: 24),
              textAlign: TextAlign.center,
            )),
            const SizedBox(
              height: 20,
            ),
            (!_isCustomMedication && _dosageList.isNotEmpty)
                ? Container(
                    padding: const EdgeInsets.all(10),
                    height: (_dosageList.length <= 7)
                        ? 67.5 * _dosageList.length
                        : 520,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Constant.oliveGreen.withOpacity(0.5)),
                    child: RawScrollbar(
                      thickness: 2,
                      radius: Radius.circular(2),
                      thumbColor: Constant.locationServiceGreen,
                      thumbVisibility: (_dosageList.length > 8) ? true : false,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        itemCount: _dosageList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 2, top: 0, right: 2),
                                  color: _dosageList[index].isSelected
                                      ? Constant.locationServiceGreen
                                      : Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 15),
                                    child: CustomTextWidget(
                                      text: _dosageList[index].text ??
                                          Constant.blankString,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: _dosageList[index].isSelected
                                            ? Constant.bubbleChatTextView
                                            : Constant.locationServiceGreen,
                                        fontFamily: Constant.jostMedium,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                                const Divider(
                                  color: Colors.black12,
                                )
                              ],
                            ),
                            onTap: (!_unitDosage)
                                ? () {
                                    widget.onPush(
                                        context,
                                        Constant.numberOfDosageScreenRouter,
                                        NumberOfDosageArgumentModel(
                                          medicationText: widget
                                                  .medicationDosageListArgumentModel
                                                  ?.medicationText ??
                                              Constant.blankString,
                                          formulationText: widget
                                                  .medicationDosageListArgumentModel
                                                  ?.formulationText ??
                                              Constant.blankString,
                                          formulationTag: widget
                                                  .medicationDosageListArgumentModel
                                                  ?.formulationTag ??
                                              Constant.blankString,
                                          medicationValue: widget
                                                  .medicationDosageListArgumentModel
                                                  ?.medicationValue ??
                                              Values(),
                                          selectedDosage:
                                              _dosageList[index].text ??
                                                  Constant.blankString,
                                          dosageTag: _dosageTag,
                                        ));
                                  }
                                : () {
                                    widget.onPush(
                                        context,
                                        Constant
                                            .medicationStartDateScreenRouter,
                                        MedicationStartDateArgumentModel(
                                            medicationText: widget
                                                    .medicationDosageListArgumentModel
                                                    ?.medicationText ??
                                                Constant.blankString,
                                            formulationText: widget
                                                    .medicationDosageListArgumentModel
                                                    ?.formulationText ??
                                                Constant.blankString,
                                            formulationTag: widget
                                                    .medicationDosageListArgumentModel
                                                    ?.formulationTag ??
                                                Constant.blankString,
                                            medicationValue: widget
                                                    .medicationDosageListArgumentModel
                                                    ?.medicationValue ??
                                                Values(),
                                            selectedDosage:
                                                _dosageList[index].text ??
                                                    Constant.blankString,
                                            dosageTag: _dosageTag,
                                            numberOfDosage: 1,
                                            selectedTime: 'Morning',
                                            isUnitDosage: true));
                                  },
                          );
                        },
                      ),
                    ))
                : Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      height: MediaQuery.of(context).size.height * 0.687,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 80,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 100,
                                height: 35,
                                child: CustomTextFormFieldWidget(
                                  inputFormatters: [EmojiFilteringTextInputFormatter()],
                                  focusNode: _focusNode,
                                  onFieldSubmitted: (val) {
                                    setState(() {
                                      _errorMessage = Constant.blankString;
                                    });
                                    if (!isNumeric(val)) {
                                      setState(() {
                                        _errorMessage =
                                            'Please enter a valid dosage value!';
                                      });
                                    }
                                    if (val == Constant.blankString) {
                                      setState(() {
                                        _errorMessage =
                                            'Please enter a dosage value!';
                                      });
                                    }
                                    if(isNumeric(val) && val != Constant.blankString){
                                      widget.onPush(
                                          context,
                                          Constant.numberOfDosageScreenRouter,
                                          NumberOfDosageArgumentModel(
                                            medicationText: widget
                                                    .medicationDosageListArgumentModel
                                                    ?.medicationText ??
                                                Constant.blankString,
                                            formulationText: widget
                                                    .medicationDosageListArgumentModel
                                                    ?.formulationText ??
                                                Constant.blankString,
                                            formulationTag: widget
                                                    .medicationDosageListArgumentModel
                                                    ?.formulationTag ??
                                                Constant.blankString,
                                            medicationValue: widget
                                                    .medicationDosageListArgumentModel
                                                    ?.medicationValue ??
                                                Values(),
                                            selectedDosage:
                                                '${_textEditingController.text} mg',
                                            dosageTag: _dosageTag,
                                          ));
                                    }
                                  },
                                  controller: _textEditingController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: Constant.jostMedium),
                                  cursorColor: Constant.bubbleChatTextView,
                                  textAlign: TextAlign.start,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 20,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                    filled: true,
                                    fillColor: Constant.locationServiceGreen,
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color:
                                                Constant.editTextBoarderColor,
                                            width: 1)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color:
                                                Constant.editTextBoarderColor,
                                            width: 1)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                child: CustomTextWidget(
                                  text: 'mg',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Constant.locationServiceGreen,
                                    fontFamily: Constant.jostMedium,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          (_errorMessage == Constant.blankString)
                              ? const SizedBox()
                              : Column(
                            children: [
                              const SizedBox(height: 5),
                              Container(
                                margin: EdgeInsets.only(left: 20, right: 10, top: 10),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 20,),
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
                                        text: _errorMessage,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Constant.pinkTriggerColor,
                                            fontFamily: Constant.jostRegular),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

            (!_isCustomMedication && _dosageList.isNotEmpty)
                ? const SizedBox()
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: BouncingWidget(
                        onPressed: () {
                          setState(() {
                            _errorMessage = Constant.blankString;
                          });
                          if (!isNumeric(_textEditingController.text)) {
                            setState(() {
                              _errorMessage =
                                  'Please enter a valid dosage value!';
                            });
                          }
                          if (_textEditingController.text == Constant.blankString) {
                            setState(() {
                              _errorMessage = 'Please enter a dosage value!';
                            });
                          }
                          if(isNumeric(_textEditingController.text) && _textEditingController.text != Constant.blankString){
                            widget.onPush(
                                context,
                                Constant.numberOfDosageScreenRouter,
                                NumberOfDosageArgumentModel(
                                  medicationText: widget
                                          .medicationDosageListArgumentModel
                                          ?.medicationText ??
                                      Constant.blankString,
                                  formulationText: widget
                                          .medicationDosageListArgumentModel
                                          ?.formulationText ??
                                      Constant.blankString,
                                  formulationTag: widget
                                          .medicationDosageListArgumentModel
                                          ?.formulationTag ??
                                      Constant.blankString,
                                  medicationValue: widget
                                          .medicationDosageListArgumentModel
                                          ?.medicationValue ??
                                      Values(),
                                  selectedDosage:
                                      '${_textEditingController.text} mg',
                                  dosageTag: _dosageTag,
                                ));
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 20),
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: (_textEditingController.text.isNotEmpty)
                                ? Constant.chatBubbleGreen
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: CustomTextWidget(
                              text: Constant.next,
                              style: TextStyle(
                                  color: Constant.bubbleChatTextView,
                                  fontSize: 15,
                                  fontFamily: Constant.jostMedium),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class MedicationDosageListArgumentModel {
  String medicationText;
  String formulationText;
  String formulationTag;
  Values medicationValue;

  MedicationDosageListArgumentModel({
    required this.medicationText,
    required this.formulationText,
    required this.formulationTag,
    required this.medicationValue,
  });
}
