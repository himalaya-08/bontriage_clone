import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/models/medication_history_model.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';

import 'CustomRichTextWidget.dart';
import 'CustomTextWidget.dart';
import 'medicationlist/medication_info_dialog.dart';

class MedicationHistoryActionSheet extends StatefulWidget {

  final List<MedicationHistoryModel> medicationDataModelList;
  const MedicationHistoryActionSheet({Key? key, required this.medicationDataModelList}) : super(key: key);

  @override
  State<MedicationHistoryActionSheet> createState() => _MedicationHistoryActionSheetState();
}

class _MedicationHistoryActionSheetState extends State<MedicationHistoryActionSheet> {

  Map<String, DateTime> _unitMedicationsLastDate = Map();
  List<MedicationExpansionPanelList> _medicationExpansionPanelList = [];
  List<MedicationHistoryModel> _onGoingMedicationList = [];
  List<MedicationHistoryModel> _endedMedicationList = [];

  @override
  void initState() {
    super.initState();
    Utils.lastGivenDateGenerator(widget.medicationDataModelList, _unitMedicationsLastDate);

    _prepareList();
  }
  
  @override
  Widget build(BuildContext context) {
    //regex for removing the redundant decimal zeros from doubleString
    RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
    return Container(
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
            padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15, top: 10),
            decoration: const BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: Constant.backgroundTransparentColor,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        debugPrint('CancelClicked');
                        Navigator.of(context).pop();
                        },
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        child: CustomTextWidget(
                          text: Constant.cancel,
                          style: TextStyle(
                            fontFamily: Constant.jostMedium,
                            color: Constant.locationServiceGreen,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 50,),
                              CustomTextWidget(
                                text: 'Medication History',
                                style: TextStyle(
                                    color: Constant.locationServiceGreen,
                                    fontFamily: Constant.jostMedium,
                                    fontSize: 24),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(width: 15,),
                              GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible: false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          contentPadding: EdgeInsets.all(0),
                                          backgroundColor: Colors.transparent,
                                          content: MedicationInfoDialog(dialogTitle: Constant.medicationHistory, dialogContent: 'Your medication history serves as a comprehensive record of all current and past medications that you have entered in Migraine Mentor and provided both a valid start date and end date (if applicable).',),
                                        );
                                      },
                                    );
                                  },
                                  child: Icon(Icons.info_outlined,
                                    color: Constant.locationServiceGreen, size: 20,)),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ExpansionPanelList(
                                elevation: 0,
                                materialGapSize: 5,
                                expandedHeaderPadding: EdgeInsets.symmetric(horizontal: 15),
                                dividerColor: Colors.black12,
                                expandIconColor: Constant.locationServiceGreen,
                                expansionCallback: (index, isExpanded) {
                                  setState(() {
                                    _medicationExpansionPanelList[index].isExpanded = isExpanded;
                                  });
                                },
                                children: _medicationExpansionPanelList.map<ExpansionPanel>((medicationExpansionPanelElement) {
                                  bool isOnGoingMedication = medicationExpansionPanelElement.title == 'On-Going';
                                  return ExpansionPanel(
                                    backgroundColor: Constant.oliveGreen.withOpacity(0.5),
                                    headerBuilder: (context, isExpanded) {
                                      return ListTile(
                                        title: CustomTextWidget(
                                          text: medicationExpansionPanelElement.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: Constant.jostRegular,
                                            color: Constant.locationServiceGreen,
                                          ),
                                        ),
                                      );
                                    },
                                    body: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: isOnGoingMedication ? _onGoingMedicationList.length : _endedMedicationList.length,
                                      itemBuilder: (context, idx) {
                                        MedicationHistoryModel medicationHistoryModelElement = isOnGoingMedication ? _onGoingMedicationList[idx] : _endedMedicationList[idx];
                                        String dosageValueString =
                                        _dosageValueStringGenerator(
                                            medicationHistoryModelElement.dosage);
                                        return GestureDetector(
                                          onTap: () {
                              
                                          },
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  children: [
                                                    Text('\u2022  ', style: TextStyle(
                                                        fontSize: Platform.isAndroid
                                                            ? 20
                                                            : 15,
                                                        fontFamily:
                                                        Constant.jostMedium,
                                                        color: Constant
                                                            .locationServiceGreen)),
                                                    const SizedBox(height: 75,)
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 11,
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: CustomRichTextWidget(
                                                            text: TextSpan(children: [
                                                              TextSpan(
                                                                  text:
                                                                  medicationHistoryModelElement.medicationName,
                                                                  style: TextStyle(
                                                                      height: 1.3,
                                                                      fontFamily: Constant.jostBold,
                                                                      fontSize: Platform.isAndroid
                                                                          ? 14
                                                                          : 15,
                                                                      color: Constant
                                                                          .locationServiceGreen)),
                                                              TextSpan(
                                                                  text: medicationHistoryModelElement
                                                                      .dosage
                                                                      .contains('units') ==
                                                                      true
                                                                      ? ' (started ${Utils.getDateText(medicationHistoryModelElement.startDate ?? DateTime.now(), true)})\n' : (
                                                                      medicationHistoryModelElement.endDate == null ? ' (started ${Utils.getDateText(medicationHistoryModelElement.startDate ?? DateTime.now(), true)})\n' :
                                                                      ' (${Utils.getDateText(medicationHistoryModelElement.startDate ?? DateTime.now(), true)} - ${Utils.getDateText(medicationHistoryModelElement.endDate ?? DateTime.now(), true)})\n'),
                                                                  style: TextStyle(
                                                                      height: 1.3,
                                                                      fontFamily:
                                                                      Constant.jostMedium,
                                                                      fontSize: Platform.isAndroid
                                                                          ? 14
                                                                          : 15,
                                                                      color: Constant
                                                                          .locationServiceGreen)),
                                                              WidgetSpan(
                                                                child: const SizedBox(height: 20,),
                                                              ),
                                                              medicationHistoryModelElement
                                                                  .dosage
                                                                  .contains('units') ==
                                                                  true
                                                                  ? TextSpan(
                                                                text:
                                                                '${(_unitMedicationsLastDate.isNotEmpty && _unitMedicationsLastDate[medicationHistoryModelElement.medicationName] != null) ? 'Last given on ${Utils.getDateText(_unitMedicationsLastDate[medicationHistoryModelElement.medicationName]!, true)} ${Utils.dateDifferenceTextGenerator(medicationHistoryModelElement.medicationName, _unitMedicationsLastDate)}\n' : 'You have not taken this before\n'}',
                                                                style: TextStyle(
                                                                  height: 1.3,
                                                                  fontFamily: Constant.jostRegular,
                                                                  fontSize: Platform.isAndroid ? 14 : 15,
                                                                  color: Constant.locationServiceGreen,
                                                                ),
                                                              )
                                                                  : TextSpan(),
                                                              TextSpan(
                                                                  text:
                                                                  '${medicationHistoryModelElement.formulation}, $dosageValueString\n',
                                                                  style: TextStyle(
                                                                      height: 1.3,
                                                                      fontFamily:
                                                                      Constant.jostMedium,
                                                                      fontSize: Platform.isAndroid
                                                                          ? 14
                                                                          : 15,
                                                                      color: Constant
                                                                          .locationServiceGreen)),
                              
                                                              medicationHistoryModelElement
                                                                  .dosage
                                                                  .contains('units') ==
                                                                  true ?
                                                              TextSpan() :
                                                              WidgetSpan(
                                                                  child: CustomRichTextWidget(
                                                                    text: TextSpan(
                                                                        children: [
                                                                          TextSpan(
                                                                              text: '   \u2022  ',
                                                                              style: TextStyle(
                                                                                  fontSize: Platform.isAndroid
                                                                                      ? 14
                                                                                      : 15,
                                                                                  fontFamily:
                                                                                  Constant.jostMedium,
                                                                                  color: Constant
                                                                                      .locationServiceGreen)),
                                                                          TextSpan(
                                                                              text:
                                                                              '${medicationHistoryModelElement.numberOfDosage.toString().replaceAll(regex, '')} ${medicationHistoryModelElement.formulation.toLowerCase()} (${medicationHistoryModelElement.medicationTime.toLowerCase()})',
                                                                              style: TextStyle(
                                                                                  height: 1.3,
                                                                                  fontFamily:
                                                                                  Constant.jostMedium,
                                                                                  fontSize: Platform.isAndroid
                                                                                      ? 14
                                                                                      : 15,
                                                                                  color: Constant
                                                                                      .locationServiceGreen)),
                                                                        ]
                                                                    ),
                                                                  )
                                                              ),
                                                            ]),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 30,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    isExpanded: medicationExpansionPanelElement.isExpanded,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          /*Expanded(
                            child: (widget.medicationDataModelList.isNotEmpty) ?
                            RawScrollbar(
                              thickness: 2,
                              radius: Radius.circular(2),
                              thumbColor: Constant.locationServiceGreen,
                              thumbVisibility: (widget.medicationDataModelList.length > 5) ? true : false,
                              child: ListView.builder(
                                itemCount: widget.medicationDataModelList.length,
                                itemBuilder: (context, index) {
                                  String dosageValueString =
                                  _dosageValueStringGenerator(
                                      widget.medicationDataModelList[index].dosage);
                                  return GestureDetector(
                                    onTap: () {

                                    },
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Text('\u2022  ', style: TextStyle(
                                                  fontSize: Platform.isAndroid
                                                      ? 20
                                                      : 15,
                                                  fontFamily:
                                                  Constant.jostMedium,
                                                  color: Constant
                                                      .locationServiceGreen)),
                                              const SizedBox(height: 75,)
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 11,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: CustomRichTextWidget(
                                                      text: TextSpan(children: [
                                                        TextSpan(
                                                            text:
                                                            widget.medicationDataModelList[index].medicationName,
                                                            style: TextStyle(
                                                                height: 1.3,
                                                                fontFamily: Constant.jostBold,
                                                                fontSize: Platform.isAndroid
                                                                    ? 14
                                                                    : 15,
                                                                color: Constant
                                                                    .locationServiceGreen)),
                                                        TextSpan(
                                                            text: widget.medicationDataModelList[index]
                                                                .dosage
                                                                .contains('units') ==
                                                                true
                                                                ? ' (started ${Utils.getDateText(widget.medicationDataModelList[index].startDate ?? DateTime.now(), true)})\n' : (
                                                            widget.medicationDataModelList[index].endDate == null ? ' (started ${Utils.getDateText(widget.medicationDataModelList[index].startDate ?? DateTime.now(), true)})\n' :
                                                            ' (${Utils.getDateText(widget.medicationDataModelList[index].startDate ?? DateTime.now(), true)} - ${Utils.getDateText(widget.medicationDataModelList[index].endDate ?? DateTime.now(), true)})\n'),
                                                            style: TextStyle(
                                                                height: 1.3,
                                                                fontFamily:
                                                                Constant.jostMedium,
                                                                fontSize: Platform.isAndroid
                                                                    ? 14
                                                                    : 15,
                                                                color: Constant
                                                                    .locationServiceGreen)),
                                                        WidgetSpan(
                                                          child: const SizedBox(height: 20,),
                                                        ),
                                                        widget.medicationDataModelList[index]
                                                            .dosage
                                                            .contains('units') ==
                                                            true
                                                            ? TextSpan(
                                                          text:
                                                          '${(_unitMedicationsLastDate.isNotEmpty && _unitMedicationsLastDate[widget.medicationDataModelList[index].medicationName] != null) ? 'Last given on ${Utils.getDateText(_unitMedicationsLastDate[widget.medicationDataModelList[index].medicationName]!, true)} ${Utils.dateDifferenceTextGenerator(widget.medicationDataModelList[index].medicationName, _unitMedicationsLastDate)}\n' : 'You have not taken this before\n'}',
                                                          style: TextStyle(
                                                            height: 1.3,
                                                            fontFamily: Constant.jostRegular,
                                                            fontSize: Platform.isAndroid ? 14 : 15,
                                                            color: Constant.locationServiceGreen,
                                                          ),
                                                        )
                                                            : TextSpan(),
                                                        TextSpan(
                                                            text:
                                                            '${widget.medicationDataModelList[index].formulation}, $dosageValueString\n',
                                                            style: TextStyle(
                                                                height: 1.3,
                                                                fontFamily:
                                                                Constant.jostMedium,
                                                                fontSize: Platform.isAndroid
                                                                    ? 14
                                                                    : 15,
                                                                color: Constant
                                                                    .locationServiceGreen)),

                                                        widget.medicationDataModelList[index]
                                                            .dosage
                                                            .contains('units') ==
                                                            true ?
                                                        TextSpan() :
                                                        WidgetSpan(
                                                            child: CustomRichTextWidget(
                                                              text: TextSpan(
                                                                  children: [
                                                                   TextSpan(
                                                                        text: '   \u2022  ',
                                                                        style: TextStyle(
                                                                            fontSize: Platform.isAndroid
                                                                                ? 14
                                                                                : 15,
                                                                            fontFamily:
                                                                            Constant.jostMedium,
                                                                            color: Constant
                                                                                .locationServiceGreen)),
                                                                    TextSpan(
                                                                        text:
                                                                        '${widget.medicationDataModelList[index].numberOfDosage.toString().replaceAll(regex, '')} ${widget.medicationDataModelList[index].formulation.toLowerCase()} (${widget.medicationDataModelList[index].medicationTime.toLowerCase()})',
                                                                        style: TextStyle(
                                                                            height: 1.3,
                                                                            fontFamily:
                                                                            Constant.jostMedium,
                                                                            fontSize: Platform.isAndroid
                                                                                ? 14
                                                                                : 15,
                                                                            color: Constant
                                                                                .locationServiceGreen)),
                                                                  ]
                                                              ),
                                                            )
                                                        ),
                                                      ]),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 30,
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ) : Container(
                              padding: EdgeInsets.only(top: 40,),
                              child: CustomTextWidget(
                                text: 'Data is not available.',
                                style: TextStyle(
                                  color: Constant.locationServiceGreen,
                                  fontFamily: Constant.jostMedium,
                                  fontSize: 25,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),*/
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //dosage value String generator:
  String _dosageValueStringGenerator(String dosageValue) {
    List<String> dosageVal = dosageValue.split(' ');
    if (dosageVal.length < 2) {
      return '$dosageValue mg';
    } else {
      return dosageValue;
    }
  }

  void _prepareList() {
    _medicationExpansionPanelList.add(MedicationExpansionPanelList(title: 'On-Going', isExpanded: true));
    _medicationExpansionPanelList.add(MedicationExpansionPanelList(title: 'Completed', isExpanded: false));

    _onGoingMedicationList = widget.medicationDataModelList.where((element) => element.endDate == null).toList();
    _endedMedicationList = widget.medicationDataModelList.where((element) => element.endDate != null).toList();
  }
}

class MedicationExpansionPanelList {
  String title;
  bool isExpanded;

  MedicationExpansionPanelList({required this.title, required this.isExpanded});
}

