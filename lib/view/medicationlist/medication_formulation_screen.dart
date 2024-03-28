import 'dart:io';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/medication_data_model.dart';
import 'package:mobile/util/EmojiFilteringTextInputFormatter.dart';
import 'package:mobile/view/CustomRichTextWidget.dart';
import 'package:mobile/view/CustomTextFormFieldWidget.dart';
import 'package:mobile/view/medication_item_view.dart';
import 'package:mobile/view/medicationlist/medication_dosage_screen.dart';
import 'package:provider/provider.dart';

import '../../models/QuestionsModel.dart';
import '../../util/constant.dart';
import '../CustomTextWidget.dart';
import 'package:collection/collection.dart';

class MedicationFormulationScreen extends StatefulWidget {
  final Function(BuildContext, String, dynamic) onPush;
  final MedicationFormulationArgumentModel? medicationFormulationArgumentModel;
  final List<Questions> formulationQuestionList;
  final String? medicationText;

  const MedicationFormulationScreen({
    Key? key,
    required this.onPush,
    this.medicationFormulationArgumentModel,
    required this.formulationQuestionList,
    this.medicationText,
  }) : super(key: key);

  @override
  State<MedicationFormulationScreen> createState() =>
      _MedicationFormulationScreenState();
}

class _MedicationFormulationScreenState
    extends State<MedicationFormulationScreen> {
  List<Values> _formulationList = [];
  String _formulationTag = '';

  double _customTextBoxHeight = 0;
  bool _isCustomFormulation = false;

  late TextEditingController _controller;

  String _errorMessage = Constant.blankString;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();

    if (_formulationList.isEmpty) {
      String? medName = widget.medicationText == null
          ? widget.medicationFormulationArgumentModel?.medicationText
          : widget.medicationText;

      Questions? formulationQuestion =
          widget.formulationQuestionList.firstWhereOrNull((element) {
        List<String> splitConditionList = element.text!.split('=');
        if (splitConditionList.length == 2) {
          splitConditionList[0] = splitConditionList[0].trim();
          splitConditionList[1] = splitConditionList[1].trim();
          return medName == splitConditionList[1];
        } else {
          return false;
        }
      });

      if (formulationQuestion != null) {
        _formulationTag = formulationQuestion.tag ?? '';
        _formulationList.addAll(formulationQuestion.values ?? []);
      } else {
        List<Values> formulations = List.generate(
            Constant.formulationTypesList.length,
            (index) => Values(
                text: Constant.formulationTypesList[index], isSelected: false));
        _formulationList.addAll(formulations);
        _formulationTag =
            '${widget.medicationFormulationArgumentModel?.medicationText}_custom.formulation';
      }
    }
  }

  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    context.read<LatestMedicationDataModelInfo>().resetIsCustomMedicationList();

    bool _isEdit = context.read<LatestMedicationDataModelInfo>().getIsEdit;
    int _index =
        context.read<LatestMedicationDataModelInfo>().getElementIndex ?? 0;
    String _medicationType =
        context.read<LatestMedicationDataModelInfo>().getMedicationType;
    List<MedicationDataModel> _medicationDataModelList = context
        .read<LatestMedicationDataModelInfo>()
        .getLatestMedicationDataModelList(_medicationType);
    List<bool> _isCustomMedicationList =
        context.read<LatestMedicationDataModelInfo>().getIsCustomMedicationList;

    if (_isEdit) {
      if (_isCustomMedicationList[_index]) {
        List<Values> formulations = List.generate(
            Constant.formulationTypesList.length,
            (index) => Values(
                text: Constant.formulationTypesList[index], isSelected: false));
        _formulationList.addAll(formulations);
        _formulationTag =
            '${widget.medicationFormulationArgumentModel?.medicationText}_custom.formulation';
        if (_formulationList.length > Constant.formulationTypesList.length) {
          _formulationList.removeRange(
              Constant.formulationTypesList.length, _formulationList.length);
        }
      }
    } else {
      if (_isCustomMedicationList[_isCustomMedicationList.length - 1]) {
        List<Values> formulations = List.generate(
            Constant.formulationTypesList.length,
            (index) => Values(
                text: Constant.formulationTypesList[index], isSelected: false));
        _formulationList.addAll(formulations);
        _formulationTag =
            '${widget.medicationFormulationArgumentModel?.medicationText}_custom.formulation';
        if (_formulationList.length > Constant.formulationTypesList.length) {
          _formulationList.removeRange(
              Constant.formulationTypesList.length, _formulationList.length);
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(15),
      color: Constant.backgroundTransparentColor,
      child: Column(
        children: [
          Expanded(
            flex: 9,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                      child: CustomTextWidget(
                    text:
                        'Choose the Medication Dosage Form for ${widget.medicationFormulationArgumentModel?.medicationText ?? _medicationDataModelList[_index].medicationText}:',
                    style: TextStyle(
                        color: Constant.locationServiceGreen,
                        fontFamily: Constant.jostMedium,
                        fontSize: 24),
                    textAlign: TextAlign.center,
                  )),
                  const SizedBox(
                    height: 20,
                  ),
                  AnimatedContainer(
                      padding: const EdgeInsets.all(10),
                      height: _customTextBoxHeight,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Constant.oliveGreen.withOpacity(0.5)),
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CustomTextFormFieldWidget(
                          inputFormatters: [EmojiFilteringTextInputFormatter()],
                          focusNode: _focusNode,
                          onFieldSubmitted: (val) {
                            setState(() {
                              _errorMessage = Constant.blankString;
                            });
                            if(_controller.text == Constant.blankString){
                              setState(() {
                                _errorMessage = 'Please enter a custom medication dosage formulation';
                              });
                            }
                            else{
                              widget.onPush(
                                  context,
                                  Constant.medicationDosageScreenRouter,
                                  MedicationDosageListArgumentModel(
                                    medicationText: (!_isEdit)
                                        ? widget.medicationFormulationArgumentModel
                                        ?.medicationText ??
                                        Constant.blankString
                                        : _medicationDataModelList[_index]
                                        .medicationText ??
                                        '',
                                    formulationText: _controller.text,
                                    formulationTag: _formulationTag,
                                    medicationValue: widget
                                        .medicationFormulationArgumentModel
                                        ?.medicationValue ??
                                        Values(),
                                  ));
                            }
                          },
                          controller: _controller,
                          style: TextStyle(
                              fontFamily: Constant.jostRegular,
                              color: Constant.locationServiceGreen,
                              fontSize: Platform.isAndroid ? 16 : 17),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 7,
                              horizontal: 0,
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: "+ Add medication's custom formulation",
                            alignLabelWithHint: true,
                            hintStyle: TextStyle(
                              fontFamily: Constant.jostRegular,
                              color: Constant.notificationTextColor,
                              fontSize: Platform.isAndroid ? 16 : 17,
                            ),
                          ),
                        ),
                      )),
                  (_errorMessage == Constant.blankString)
                      ? const SizedBox()
                      : Column(
                        children: [
                          const SizedBox(height: 5),
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 10, top: 10),
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
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    height: (_formulationList.length <= 7)
                        ? 67.5 * _formulationList.length
                        : (_isCustomFormulation) ? 290 : 480,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Constant.oliveGreen.withOpacity(0.5)),
                    child: RawScrollbar(
                      thickness: 2,
                      radius: Radius.circular(2),
                      thumbColor: Constant.locationServiceGreen,
                      thumbVisibility: (_formulationList.length > 8) ? true : false,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        itemCount: _formulationList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 2, top: 0, right: 2),
                                  color: _formulationList[index].isSelected
                                      ? Constant.locationServiceGreen
                                      : Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 15),
                                    child: CustomTextWidget(
                                      text: _formulationList[index].text ??
                                          Constant.blankString,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: _formulationList[index].isSelected
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
                            onTap: () {
                              widget.onPush(
                                  context,
                                  Constant.medicationDosageScreenRouter,
                                  MedicationDosageListArgumentModel(
                                    medicationText: (!_isEdit)
                                        ? widget.medicationFormulationArgumentModel
                                                ?.medicationText ??
                                            Constant.blankString
                                        : _medicationDataModelList[_index]
                                                .medicationText ??
                                            '',
                                    formulationText: _formulationList[index].text ??
                                        Constant.blankString,
                                    formulationTag: _formulationTag,
                                    medicationValue: widget
                                            .medicationFormulationArgumentModel
                                            ?.medicationValue ??
                                        Values(),
                                  ));
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: CustomRichTextWidget(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Can't see your medication's",
                              style: TextStyle(
                                fontSize: Platform.isAndroid ? 14 : 15,
                                fontFamily: Constant.jostRegular,
                                color: Constant.locationServiceGreen,
                              ),
                            ),
                            TextSpan(
                              text: ' formulation',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Future.delayed(Duration(milliseconds: 200),(){
                                    _focusNode.requestFocus(); //auto focus on custom text field.
                                  });
                                  setState(() {
                                    _customTextBoxHeight = 50;
                                    _isCustomFormulation = true;
                                  });
                                },
                              style: TextStyle(
                                fontSize: Platform.isAndroid ? 14 : 15,
                                fontFamily: Constant.jostRegular,
                                color: Constant.addCustomNotificationTextColor,
                              ),
                            ),
                            TextSpan(
                              text: '?',
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
                ],
              ),
            ),
          ),

          (_isCustomFormulation) ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: BouncingWidget(
              onPressed: () {
                {
                  setState(() {
                    _errorMessage = Constant.blankString;
                  });
                  if(_controller.text == Constant.blankString){
                    setState(() {
                      _errorMessage = 'Please enter a custom medication dosage formulation';
                    });
                  }
                  else{
                          widget.onPush(
                              context,
                              Constant.medicationDosageScreenRouter,
                              MedicationDosageListArgumentModel(
                                medicationText: (!_isEdit)
                                    ? widget.medicationFormulationArgumentModel
                                            ?.medicationText ??
                                        Constant.blankString
                                    : _medicationDataModelList[_index]
                                            .medicationText ??
                                        '',
                                formulationText: _controller.text,
                                formulationTag: _formulationTag,
                                medicationValue: widget
                                        .medicationFormulationArgumentModel
                                        ?.medicationValue ??
                                    Values(),
                              ));
                        }
                      }
                    },
              child: Container(
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: (_controller.text != Constant.blankString) ? Constant.chatBubbleGreen : Colors.grey,
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
          ) : const SizedBox(),
        ],
      ),
    );
  }
}

class MedicationFormulationArgumentModel {
  String medicationText;
  Values medicationValue;

  MedicationFormulationArgumentModel({
    required this.medicationText,
    required this.medicationValue,
  });
}
