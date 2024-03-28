import 'package:flutter/material.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextFormFieldWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';

import 'package:collection/collection.dart';

class TonixLogDayMedicationListActionSheet extends StatefulWidget {
  final List<Values> medicationValuesList;
  final Function(Values) onItemDeselect;
  final List<Questions> genericMedicationQuestionList;
  final List<Questions> dosageTypeQuestionList;
  final List<Map> recentMedicationMapList;

  const TonixLogDayMedicationListActionSheet({
    Key? key,
    required this.medicationValuesList,
    required this.onItemDeselect,
    required this.dosageTypeQuestionList,
    required this.genericMedicationQuestionList,
    required this.recentMedicationMapList,
  }) : super(key: key);

  @override
  _TonixLogDayMedicationListActionSheetState createState() => _TonixLogDayMedicationListActionSheetState();
}

class _TonixLogDayMedicationListActionSheetState extends State<TonixLogDayMedicationListActionSheet> {
  String _searchText = Constant.blankString;
  List<Values> recentMedicationList = [];
  List<Values> medicationList = [];

  @override
  void initState() {
    super.initState();

    List<Values> medicationSelectedList = widget.medicationValuesList.where((element) => element.isSelected).toList();

    if(medicationSelectedList != null) {
      if(medicationSelectedList.isNotEmpty) {
        medicationSelectedList.forEach((element) {
          medicationList.add(element);
        });
      }
    }

    widget.recentMedicationMapList.forEach((element) {
      Values? medicationValue = widget.medicationValuesList.firstWhereOrNull((medicationElement) => medicationElement.text == element[SignUpOnBoardProviders.MEDICATION_NAME]);

      if (medicationValue != null)
        if(!medicationValue.isSelected)
          medicationList.add(medicationValue);
    });

    widget.medicationValuesList.forEach((element) {
      if(!element.isSelected) {
        Map? recentMedicationMap = widget.recentMedicationMapList.firstWhereOrNull((
            recentMedicationElement) =>
        recentMedicationElement[SignUpOnBoardProviders.MEDICATION_NAME] ==
            element.text);

        if (recentMedicationMap == null) {
          medicationList.add(element);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: MediaQuery
          .of(context)
          .size
          .height * 0.5,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 10),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10),
                  topRight: Radius.circular(10)),
              color: Constant.backgroundTransparentColor,
            ),
            child: Column(
              children: [
                Container(
                  height: 35,
                  margin: EdgeInsets.only(left: 10, right: 10, top: 0),
                  child: CustomTextFormFieldWidget(
                    onChanged: (searchText) {
                      setState(() {
                        this._searchText = searchText;
                      });
                    },
                    style: TextStyle(
                        color: Constant.locationServiceGreen,
                        fontSize: 15,
                        fontFamily: Constant.jostMedium),
                    cursorColor: Constant.locationServiceGreen,
                    decoration: InputDecoration(
                      hintText: Constant.searchType,
                      hintStyle: TextStyle(
                          color: Constant.locationServiceGreen,
                          fontSize: 13,
                          fontFamily: Constant.jostMedium),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Constant.locationServiceGreen),),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Constant.locationServiceGreen),),
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    itemCount: medicationList.length,
                    itemBuilder: (context, index) {
                      String medicationText = medicationList[index].text!;
                      String genericMedicationName = _getGenericMedicationName(medicationText);
                      if(medicationText == '+') {
                        return Container();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            onTap: () {
                              bool isSelected = medicationList[index].isSelected;
                              medicationList[index].isSelected = !isSelected;

                              setState(() {

                              });
                              if(!isSelected) {
                                Navigator.pop(context, medicationList[index]);
                              } else {
                                medicationList[index].isDoubleTapped = false;
                                widget.onItemDeselect(medicationList[index]);
                              }
                            },
                            child: Visibility(
                              visible: (_searchText.trim().isNotEmpty)
                                  ? _getOptionText(medicationText, genericMedicationName).toLowerCase().contains(_searchText.trim().toLowerCase()) : true,
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: 2, top: 0, right: 2),
                                color: medicationList[index].isSelected ? Constant.locationServiceGreen : Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 15),
                                  child: CustomTextWidget(
                                    text: _getOptionText(medicationText, genericMedicationName),
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: medicationList[index].isSelected ? Constant.bubbleChatTextView : Constant.locationServiceGreen,
                                        fontFamily: Constant.jostMedium,
                                        height: 1.2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  ///This method is used to get generic medication name
  ///[medicationName] is used to identify the generic name of medication
  String _getGenericMedicationName(String medicationName) {
    String genericMedicationName = Constant.blankString;

    if(widget.dosageTypeQuestionList != null && widget.genericMedicationQuestionList != null) {
      Questions typeQuestion = Utils.getDosageTypeQuestion(widget.dosageTypeQuestionList, medicationName)!;

      if (typeQuestion != null) {
        String dosageType = typeQuestion.values!.first.text!;
        Questions genericQuestion = Utils.getGenericMedicationQuestion(widget.genericMedicationQuestionList, medicationName, dosageType)!;
        if (genericQuestion != null)
          genericMedicationName = genericQuestion.values!.first.text!;
      }
    }

    return genericMedicationName;
  }

  String _getOptionText(String optionValue, String genericMedicationName) {
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
