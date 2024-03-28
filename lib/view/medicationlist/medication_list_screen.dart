import 'package:flutter/material.dart';
import 'package:mobile/util/EmojiFilteringTextInputFormatter.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:collection/collection.dart';
import 'package:mobile/view/medication_item_view.dart';
import 'package:mobile/view/medicationlist/medication_formulation_screen.dart';
import 'package:provider/provider.dart';

import '../../models/QuestionsModel.dart';
import '../../providers/SignUpOnBoardProviders.dart';
import '../../util/Utils.dart';
import '../CustomTextFormFieldWidget.dart';

class MedicationListScreen extends StatefulWidget {
  final Function(BuildContext, String, dynamic) onPush;
  final List<Values> medicationValuesList;
  final List<Map> selectedMedicationMapList;
  final List<Map> recentMedicationMapList;

  const MedicationListScreen({
    Key? key,
    required this.onPush,
    required this.medicationValuesList,
    required this.selectedMedicationMapList,
    required this.recentMedicationMapList,
  }) : super(key: key);

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  String _searchText = Constant.blankString;
  bool _isOpenSecondaryMedicationView = false;
  int _mainMedicationItemIndexSelected = 0;

  List<Values> _medicationList = [];
  List<Values> _newMedicationList = [];

  bool _isExtraDataAdded = false;
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    List<Values> medicationSelectedList = widget.medicationValuesList
        .where((element) => element.isSelected)
        .toList();

    if (medicationSelectedList.isNotEmpty) {
      medicationSelectedList.forEach((element) {
        _medicationList.add(Values(valueNumber: element.valueNumber, isSelected: false, text: element.text, selectedText: element.selectedText));
      });
    }

    widget.selectedMedicationMapList.forEach((element) {
      Values? medicationValue = widget.medicationValuesList.firstWhereOrNull(
              (medicationElement) =>
          medicationElement.text ==
              element[SignUpOnBoardProviders.MEDICATION_NAME]);

      if (medicationValue != null) if (!medicationValue
          .isSelected) if (_medicationList.length < 5)
        _medicationList.add(Values(valueNumber: medicationValue.valueNumber, isSelected: false, text: medicationValue.text, selectedText: medicationValue.selectedText));
    });

    widget.recentMedicationMapList.forEach((element) {
      Values? medicationValue = widget.medicationValuesList.firstWhereOrNull(
              (medicationElement) =>
          medicationElement.text ==
              element[SignUpOnBoardProviders.MEDICATION_NAME]);
      Values? medicationValueElement = _medicationList.firstWhereOrNull(
              (medicationElement) =>
          medicationElement.text ==
              element[SignUpOnBoardProviders.MEDICATION_NAME]);

      if (medicationValue != null &&
          medicationValueElement ==
              null) if (!medicationValue.isSelected) if (_medicationList.length <
          5){
        _medicationList.add(Values(valueNumber: medicationValue.valueNumber, isSelected: false, text: medicationValue.text, selectedText: medicationValue.selectedText));
      }
    });

    List<Values> medications = List.from(widget.medicationValuesList);
    for(Values medicationValue in _medicationList){
      for(Values medication in medications){
        if(medication.valueNumber == medicationValue.valueNumber){
          widget.medicationValuesList.remove(medication);
          break;
        }
      }
    }

    widget.medicationValuesList.forEach((element) {
      if (!element.isSelected) {
        Values? medicationValueElement = _medicationList.firstWhereOrNull(
                (medicationElement) => medicationElement == element);

        if (medicationValueElement == null) {
          _medicationList.add(Values(valueNumber: element.valueNumber, isSelected: false, text: element.text, selectedText: element.selectedText));
        }
      }
    });

    /*medicationList.forEach((element) {
      if(element.medicationType == Constant.acute){
        acuteMedicationList.add(element);
      }
      else if(element.medicationType == Constant.preventive){
        preventiveMedicationList.add(element);
      }
    });*/

    //acuteMedicationList = medicationList;
    //preventiveMedicationList = medicationList;
  }

  @override
  Widget build(BuildContext context) {

    String _medicationType = context.read<LatestMedicationDataModelInfo>().getMedicationType;

    return Container(
      color: Constant.backgroundTransparentColor,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Center(
              child: CustomTextWidget(
                text: '$_medicationType Medications',
                style: TextStyle(
                    color: Constant.locationServiceGreen,
                    fontFamily: Constant.jostMedium,
                    fontSize: 25),
                textAlign: TextAlign.center,
              )),
          const SizedBox(
            height: 20,
          ),
          Container(
            height: 40,
            margin: EdgeInsets.only(left: 10, right: 10, top: 0),
            child: CustomTextFormFieldWidget(
              controller: _textEditingController,
              inputFormatters: [EmojiFilteringTextInputFormatter()],
              onChanged: (searchText) {
                if (searchText.trim().isNotEmpty) {
                  Values? valueData = _medicationList.firstWhereOrNull(
                          (element) => element.text
                      !.toLowerCase()
                          .contains(searchText.toLowerCase().trim()));

                  if (valueData == null) {
                    if (!_isOpenSecondaryMedicationView) {
                      if (!_isExtraDataAdded) {
                        _medicationList.insert(
                            _medicationList.length - 1,
                            Values(
                                text: searchText.trim(),
                                valueNumber:
                                (_medicationList.length).toString(),
                                isNewlyAdded: true));
                        _isExtraDataAdded = true;
                      } else {
                        if (_medicationList[_medicationList.length - 2]
                            .isSelected) {
                          _medicationList.insert(
                              _medicationList.length - 1,
                              Values(
                                  text: searchText.trim(),
                                  valueNumber: (_medicationList.length)
                                      .toString(),
                                  isNewlyAdded: true));
                        } else {
                          _medicationList[_medicationList.length - 2]
                              .text = searchText;
                        }
                      }
                    }
                  } else {
                    if (_isExtraDataAdded) {
                      if (!valueData.isNewlyAdded) {
                        _medicationList
                            .removeAt(_medicationList.length - 2);
                        _isExtraDataAdded = false;
                      } else {
                        _medicationList[_medicationList.length - 2].text =
                            searchText;
                      }
                    }
                  }
                }

                setState(() {
                  _searchText = searchText;
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
                    color: Constant.locationServiceGreen.withOpacity(0.9),
                    fontSize: 14,
                    fontFamily: Constant.jostMedium),
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                  BorderSide(color: Constant.locationServiceGreen),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                  BorderSide(color: Constant.locationServiceGreen),
                ),
                contentPadding:
                EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              ),
            ),
          ),
          //const SizedBox(height: 15,),
          /*Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: DefaultTabController(
              length: 2,
              initialIndex: selectedTabIndex,
              child: Container(
                padding: EdgeInsets.all(5),
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Constant.locationServiceGreen,
                    ),
                    color: Colors.transparent),
                child: TabBar(
                  onTap: (index) {
                    setState(() {
                      selectedTabIndex = index;
                    });
                  },
                  indicatorPadding: EdgeInsets.all(0),
                  labelPadding: EdgeInsets.all(0),
                  labelStyle:
                  TextStyle(fontSize: 14, fontFamily: Constant.jostRegular),
                  //For Selected tab
                  unselectedLabelStyle:
                  TextStyle(fontSize: 14, fontFamily: Constant.jostRegular),
                  //For Un-selected Tabs
                  labelColor: Constant.backgroundColor,
                  unselectedLabelColor: Constant.locationServiceGreen,
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Constant.locationServiceGreen),
                  tabs: [
                    Tab(
                      text: Constant.preventive,
                    ),
                    Tab(
                      text: Constant.acute,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),*/
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 7,),
              child: RawScrollbar(
                thickness: 2,
                padding: const EdgeInsets.only(top: 10),
                thumbColor: Constant.locationServiceGreen,
                thumbVisibility: true,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                  itemCount: _medicationList.length,
                  itemBuilder: (context, index) {
                    String medicationText =
                        _medicationList[index].text ?? '';
                    debugPrint(
                        "$medicationText = ${Utils.getMedicationValidation(medicationText)}");

                    debugPrint('Visibility??${(_searchText.trim().isNotEmpty) ? _medicationList[index].text!.toLowerCase().contains(_searchText.trim().toLowerCase()) : true}');
                    if (medicationText == '+') {
                      return Container();
                    }
                    return GestureDetector(
                      onTap: () {
                        if (!_isOpenSecondaryMedicationView) {
                          bool isSelected =
                              _medicationList[index].isSelected;
                          _mainMedicationItemIndexSelected = index;

                          if (!isSelected) {
                            if (_medicationList[index].isNewlyAdded) {
                              //medicationList[index].isSelected = !isSelected;
                              //Navigator.pop(context, medicationList[index]);

                              //retains the data that current medication is custom
                              context.read<LatestMedicationDataModelInfo>().setIsCustomMedicationList(true);

                              //This is the custom medication added in the medication list
                              widget.onPush(context, Constant.medicationFormulationScreenRouter, MedicationFormulationArgumentModel(
                                medicationText: _medicationList[index].text ?? Constant.blankString,
                                medicationValue: _medicationList[index],
                              ));
                            } else if (Utils.getMedicationValidation(medicationText)) {
                              //_isOpenSecondaryMedicationView = true;
                              String brandNames = medicationText.substring(
                                  medicationText.lastIndexOf('(') + 1,
                                  medicationText.length - 1);
                              debugPrint("BrandNames=$brandNames");
                              List<String> brandNameList =
                              brandNames.split(", ");
                              debugPrint("BrandNameList=$brandNameList");
                              debugPrint(
                                  "SelectedText1=${_medicationList[index].selectedText}");

                              String genericName =
                                  "${medicationText.substring(0, medicationText.lastIndexOf("(") - 1)} (generic)";
                              _medicationList.add(Values(
                                valueNumber: "1",
                                text: genericName,
                              ));
                              brandNameList.asMap().forEach((idx, element) {
                                _medicationList.add(
                                  Values(
                                    valueNumber: (idx + 2).toString(),
                                    text: element,
                                  ),
                                );
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                              _textEditingController.text = Constant.blankString;
                              _searchText = Constant.blankString;
                            } else {
                              //retains the data that current medication is custom
                              context.read<LatestMedicationDataModelInfo>().setIsCustomMedicationList(false);

                              widget.onPush(context, Constant.medicationFormulationScreenRouter, MedicationFormulationArgumentModel(
                                medicationText: _medicationList[index].text ?? Constant.blankString,
                                medicationValue: _medicationList[index],
                              ));
                              //medicationList[index].isSelected = !isSelected;
                              //Navigator.pop(context, medicationList[index]);

                            }
                          } else {
                            if (Utils.getMedicationValidation(medicationText)) {
                              _isOpenSecondaryMedicationView = true;
                              String brandNames = medicationText.substring(
                                  medicationText.lastIndexOf('(') + 1,
                                  medicationText.length - 1);
                              debugPrint("BrandNames=$brandNames");
                              List<String> brandNameList =
                              brandNames.split(", ");
                              debugPrint("BrandNameList=$brandNameList");
                              debugPrint(
                                  "SelectedText2=${_medicationList[index].selectedText}");

                              String genericName =
                                  "${medicationText.substring(0, medicationText.lastIndexOf("(") - 1)} (generic)";
                              _medicationList.add(Values(
                                  valueNumber: "1",
                                  text: genericName,
                                  isSelected:
                                  _medicationList[index].selectedText ==
                                      genericName));

                              brandNameList.asMap().forEach((idx, element) {
                                _medicationList.add(
                                  Values(
                                      valueNumber: (idx + 2).toString(),
                                      text: element,
                                      isSelected: _medicationList[index]
                                          .selectedText ==
                                          element),
                                );
                              });
                            } else {
                              /*medicationList[index].isDoubleTapped = false;
                              medicationList[index].isSelected = false;*/
                              //widget.onItemDeselect(medicationList[index]);
                            }
                          }
                        } else {
                          Values newMedicationValue =
                          _medicationList[index];
                          bool isSelected = newMedicationValue.isSelected;

                          if (!isSelected) {
                            newMedicationValue.isSelected = !isSelected;
                            _medicationList[_mainMedicationItemIndexSelected]
                                .isSelected = true;
                            Navigator.pop(context, newMedicationValue);
                          } else {
                            _medicationList[_mainMedicationItemIndexSelected]
                                .isDoubleTapped = false;
                            _medicationList[_mainMedicationItemIndexSelected].isSelected = false;

                            newMedicationValue.isSelected = false;
                            //widget.onItemDeselect(medicationList[_mainMedicationItemIndexSelected]);
                          }
                        }
                        setState(() {

                        });
                        debugPrint("OnTapClosed!");
                      },
                      child: Visibility(
                        visible: (_searchText.trim().isNotEmpty)
                            ? _medicationList[index]
                            .text
                        !.toLowerCase()
                            .contains(_searchText.trim().toLowerCase())
                            : true,
                        child: Container(
                          margin: EdgeInsets.only(left: 2, top: 0, right: 2),
                          color: (!_isOpenSecondaryMedicationView
                              ? _medicationList[index].isSelected
                              : _medicationList[index].isSelected)
                              ? Constant.locationServiceGreen
                              : Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            child: CustomTextWidget(
                              text: medicationText,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: (!_isOpenSecondaryMedicationView
                                      ? _medicationList[index].isSelected
                                      : _medicationList[index].isSelected)
                                      ? Constant.bubbleChatTextView
                                      : Constant.locationServiceGreen,
                                  fontFamily: Constant.jostMedium,
                                  height: 1.2),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _removeLastCustomValue();
    super.dispose();
  }

  void _removeLastCustomValue() {
    if (_isExtraDataAdded) {
      Values lastValue = _medicationList[_medicationList.length - 2];

      if (lastValue.isNewlyAdded && !lastValue.isSelected) {
        _medicationList.removeLast();
      }
    }
  }
}
