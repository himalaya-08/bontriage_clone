import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextFormFieldWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';

import '../providers/SignUpOnBoardProviders.dart';
import '../util/Utils.dart';

class LogDayMedicationListActionSheet extends StatefulWidget {
  final List<Values> medicationValuesList;
  final Function(Values) onItemDeselect;
  final List<Map> selectedMedicationMapList;
  final List<Map> recentMedicationMapList;

  const LogDayMedicationListActionSheet(
      {Key? key,
      required this.medicationValuesList,
      required this.onItemDeselect,
      required this.recentMedicationMapList,
      required this.selectedMedicationMapList})
      : super(key: key);

  @override
  _LogDayMedicationListActionSheetState createState() =>
      _LogDayMedicationListActionSheetState();
}

class _LogDayMedicationListActionSheetState
    extends State<LogDayMedicationListActionSheet> {
  String _searchText = Constant.blankString;
  bool _isOpenSecondaryMedicationView = false;
  int _mainMedicationItemIndexSelected = 0;
  int _secondaryMedicationItemIndexSelected = 0;
  List<Values> medicationList = [];
  List<Values> newMedicationList = [];

  bool _isExtraDataAdded = false;
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    List<Values> medicationSelectedList = widget.medicationValuesList
        .where((element) => element.isSelected)
        .toList();

    if (medicationSelectedList != null) {
      if (medicationSelectedList.isNotEmpty) {
        medicationSelectedList.forEach((element) {
          medicationList.add(element);
        });
      }
    }

    if (widget.selectedMedicationMapList != null) {
      widget.selectedMedicationMapList.forEach((element) {
        Values? medicationValue = widget.medicationValuesList.firstWhereOrNull(
            (medicationElement) =>
                medicationElement.text ==
                element[SignUpOnBoardProviders.MEDICATION_NAME]);

        if (medicationValue != null) if (!medicationValue
            .isSelected) if (medicationList.length < 5)
          medicationList.add(medicationValue);
      });
    }

    widget.recentMedicationMapList.forEach((element) {
      Values? medicationValue = widget.medicationValuesList.firstWhereOrNull(
          (medicationElement) =>
              medicationElement.text ==
              element[SignUpOnBoardProviders.MEDICATION_NAME]);
      Values? medicationValueElement = medicationList.firstWhereOrNull(
          (medicationElement) =>
              medicationElement.text ==
              element[SignUpOnBoardProviders.MEDICATION_NAME]);

      if (medicationValue != null &&
          medicationValueElement ==
              null) if (!medicationValue.isSelected) if (medicationList.length <
          5) medicationList.add(medicationValue);
    });

    widget.medicationValuesList.forEach((element) {
      if (!element.isSelected) {
        Values? medicationValueElement = medicationList.firstWhereOrNull(
            (medicationElement) => medicationElement == element);

        if (medicationValueElement == null) {
          medicationList.add(element);
        }
      }
    });
  }

  @override
  void dispose() {
    _removeLastCustomValue();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isOpenSecondaryMedicationView) {
          setState(() {
            _isOpenSecondaryMedicationView = false;
            newMedicationList = [];
          });
          return false;
        }
        return true;
      },
      child: Container(
        color: Colors.transparent,
        height: MediaQuery.of(context).size.height * 0.95,
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: Constant.backgroundTransparentColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, right: 15),
                        child: CustomTextWidget(
                          text: Constant.close,
                          style: TextStyle(
                            fontFamily: Constant.jostMedium,
                            color: Constant.locationServiceGreen,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _isOpenSecondaryMedicationView,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        setState(() {
                          _isOpenSecondaryMedicationView = false;
                          newMedicationList = [];
                          _textEditingController.text = Constant.blankString;
                          _searchText = Constant.blankString;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Constant.locationServiceGreen,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 35,
                    margin: EdgeInsets.only(left: 10, right: 10, top: 0),
                    child: CustomTextFormFieldWidget(
                      controller: _textEditingController,
                      onChanged: (searchText) {
                        if (searchText.trim().isNotEmpty) {
                          Values? valueData = medicationList.firstWhereOrNull(
                              (element) => element.text
                                  !.toLowerCase()
                                  .contains(searchText.toLowerCase().trim()));

                          if (valueData == null) {
                            if (!_isOpenSecondaryMedicationView) {
                              if (!_isExtraDataAdded) {
                                medicationList.insert(
                                    medicationList.length - 1,
                                    Values(
                                        text: searchText.trim(),
                                        valueNumber:
                                            (medicationList.length).toString(),
                                        isNewlyAdded: true));
                                _isExtraDataAdded = true;
                              } else {
                                if (medicationList[medicationList.length - 2]
                                    .isSelected) {
                                  medicationList.insert(
                                      medicationList.length - 1,
                                      Values(
                                          text: searchText.trim(),
                                          valueNumber: (medicationList.length)
                                              .toString(),
                                          isNewlyAdded: true));
                                } else {
                                  medicationList[medicationList.length - 2]
                                      .text = searchText;
                                }
                              }
                            }
                          } else {
                            if (_isExtraDataAdded) {
                              if (!valueData.isNewlyAdded) {
                                medicationList
                                    .removeAt(medicationList.length - 2);
                                _isExtraDataAdded = false;
                              } else {
                                medicationList[medicationList.length - 2].text =
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
                            color: Constant.locationServiceGreen,
                            fontSize: 13,
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
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      itemCount: !_isOpenSecondaryMedicationView
                          ? medicationList.length
                          : newMedicationList.length,
                      itemBuilder: (context, index) {
                        String medicationText =
                            (!_isOpenSecondaryMedicationView)
                                ? medicationList[index].text!
                                : newMedicationList[index].text!;
                        debugPrint(
                            "$medicationText = ${Utils.getMedicationValidation(medicationText)}");

                        debugPrint('Visibility??${(_searchText.trim().isNotEmpty) ? medicationList[index].text!.toLowerCase().contains(_searchText.trim().toLowerCase()) : true}');
                        if (medicationText == '+') {
                          return Container();
                        }
                        return GestureDetector(
                          onTap: () {
                            if (!_isOpenSecondaryMedicationView) {
                              bool isSelected =
                                  medicationList[index].isSelected;
                              _mainMedicationItemIndexSelected = index;

                              if (!isSelected) {
                                if (medicationList[index].isNewlyAdded) {
                                  medicationList[index].isSelected =
                                      !isSelected;
                                  Navigator.pop(context, medicationList[index]);
                                } else if (Utils.getMedicationValidation(
                                    medicationText)) {
                                  _isOpenSecondaryMedicationView = true;
                                  String brandNames = medicationText.substring(
                                      medicationText.lastIndexOf('(') + 1,
                                      medicationText.length - 1);
                                  debugPrint("BrandNames=$brandNames");
                                  List<String> brandNameList =
                                      brandNames.split(", ");
                                  debugPrint("BrandNameList=$brandNameList");
                                  debugPrint(
                                      "SelectedText1=${medicationList[index].selectedText}");

                                  String genericName =
                                      "${medicationText.substring(0, medicationText.lastIndexOf("(") - 1)} (generic)";
                                  newMedicationList.add(Values(
                                      valueNumber: "1",
                                      text: genericName,
                                  ));
                                  brandNameList.asMap().forEach((idx, element) {
                                    newMedicationList.add(
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
                                  medicationList[index].isSelected =
                                      !isSelected;
                                  Navigator.pop(context, medicationList[index]);
                                }
                              } else {
                                if (Utils.getMedicationValidation(
                                    medicationText)) {
                                  _isOpenSecondaryMedicationView = true;
                                  String brandNames = medicationText.substring(
                                      medicationText.lastIndexOf('(') + 1,
                                      medicationText.length - 1);
                                  debugPrint("BrandNames=$brandNames");
                                  List<String> brandNameList =
                                      brandNames.split(", ");
                                  debugPrint("BrandNameList=$brandNameList");
                                  debugPrint(
                                      "SelectedText2=${medicationList[index].selectedText}");

                                  String genericName =
                                      "${medicationText.substring(0, medicationText.lastIndexOf("(") - 1)} (generic)";
                                  newMedicationList.add(Values(
                                      valueNumber: "1",
                                      text: genericName,
                                      isSelected:
                                          medicationList[index].selectedText ==
                                              genericName));

                                  brandNameList.asMap().forEach((idx, element) {
                                    newMedicationList.add(
                                      Values(
                                          valueNumber: (idx + 2).toString(),
                                          text: element,
                                          isSelected: medicationList[index]
                                                  .selectedText ==
                                              element),
                                    );
                                  });
                                } else {
                                  medicationList[index].isDoubleTapped = false;
                                  medicationList[index].isSelected = false;
                                  widget.onItemDeselect(medicationList[index]);
                                }
                              }
                            } else {
                              Values newMedicationValue =
                                  newMedicationList[index];
                              bool isSelected = newMedicationValue.isSelected;

                              if (!isSelected) {
                                newMedicationValue.isSelected = !isSelected;
                                medicationList[_mainMedicationItemIndexSelected]
                                    .isSelected = true;
                                Navigator.pop(context, newMedicationValue);
                              } else {
                                medicationList[_mainMedicationItemIndexSelected]
                                    .isDoubleTapped = false;
                                medicationList[_mainMedicationItemIndexSelected].isSelected = false;

                                newMedicationValue.isSelected = false;
                                widget.onItemDeselect(medicationList[_mainMedicationItemIndexSelected]);
                              }
                            }
                            setState(() {

                            });
                            debugPrint("OnTapClosed!");
                          },
                          child: Visibility(
                            visible: (_searchText.trim().isNotEmpty)
                                ? medicationList[index]
                                    .text
                                    !.toLowerCase()
                                    .contains(_searchText.trim().toLowerCase())
                                : true,
                            child: Container(
                              margin:
                                  EdgeInsets.only(left: 2, top: 0, right: 2),
                              color: (!_isOpenSecondaryMedicationView
                                      ? medicationList[index].isSelected
                                      : newMedicationList[index].isSelected)
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
                                              ? medicationList[index].isSelected
                                              : newMedicationList[index]
                                                  .isSelected)
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
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _removeLastCustomValue() {
    if (_isExtraDataAdded) {
      Values lastValue = medicationList[medicationList.length - 2];

      if (lastValue.isNewlyAdded && !lastValue.isSelected) {
        medicationList.removeLast();
      }
    }
  }
}
