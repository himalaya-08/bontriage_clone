import 'package:flutter/material.dart';

import '../../models/QuestionsModel.dart';
import '../../models/medication_history_model.dart';
import '../../util/constant.dart';
import '../CustomTextWidget.dart';
import 'medication_list_action_sheet.dart';
import 'medication_start_date_screen.dart';
import 'package:collection/collection.dart';

class MedicationTimeScreen extends StatefulWidget {
  final Function(BuildContext, String, dynamic) onPush;
  final MedicationTimeArgumentModel? medicationTimeArgumentModel;
  final List<MedicationHistoryModel> medicationHistoryModelList;
  final int? historyId;
  final bool? isPreventive;
  final Function(MedicationListActionSheetModel) closeActionSheet;

  const MedicationTimeScreen({
    Key? key,
    required this.onPush,
    this.medicationTimeArgumentModel,
    this.historyId,
    required this.medicationHistoryModelList,
    this.isPreventive,
    required this.closeActionSheet,
  }) : super(key: key);

  @override
  State<MedicationTimeScreen> createState() => _MedicationTimeScreenState();
}

class _MedicationTimeScreenState extends State<MedicationTimeScreen> {
  List<Values> _timeList = [];
  late String _medicationName;

  @override
  void initState() {
    super.initState();

    _medicationName =
        widget.medicationTimeArgumentModel?.medicationText ?? '';

    if (_timeList.isEmpty) {
      _timeList.add(Values(
        valueNumber: '1',
        text: Constant.morningTime,
      ));

      _timeList.add(Values(
        valueNumber: '2',
        text: Constant.afternoonTime,
      ));

      _timeList.add(Values(
        valueNumber: '3',
        text: Constant.eveningTime,
      ));

      _timeList.add(Values(
        valueNumber: '4',
        text: Constant.bedTime,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Constant.backgroundTransparentColor,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Center(
              child: CustomTextWidget(
            text: '$_medicationName ${widget.medicationTimeArgumentModel?.selectedDosage} ${widget.medicationTimeArgumentModel?.formulationText.toLowerCase()}s',
            style: TextStyle(
                color: Constant.locationServiceGreen,
                fontFamily: Constant.jostMedium,
                fontSize: 24),
            textAlign: TextAlign.center,
          )),
          const SizedBox(
            height: 10,
          ),
          Center(
              child: CustomTextWidget(
                text: 'When do you take this dose?',
                style: TextStyle(
                    color: Constant.locationServiceGreen,
                    fontFamily: Constant.jostMedium,
                    fontSize: 24),
                textAlign: TextAlign.center,
              )),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            height: (_timeList.length <= 7) ? 67.5 * _timeList.length : 520,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Constant.oliveGreen.withOpacity(0.5)),
            child: RawScrollbar(
              thickness: 2,
              radius: Radius.circular(2),
              thumbColor: Constant.locationServiceGreen,
              thumbVisibility: (_timeList.length > 8) ? true : false,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                itemCount: _timeList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 2, top: 0, right: 2),
                          color: _timeList[index].isSelected
                              ? Constant.locationServiceGreen
                              : Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            child: CustomTextWidget(
                              text: _timeList[index].text ?? Constant.blankString,
                              style: TextStyle(
                                fontSize: 15,
                                color: _timeList[index].isSelected
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
                      MedicationHistoryModel? medicationHistoryModel = widget.medicationHistoryModelList.firstWhereOrNull((el) => el.id == widget.historyId);
                      if (medicationHistoryModel != null) {
                        if (medicationHistoryModel.medicationName == widget.medicationTimeArgumentModel?.medicationText &&
                            medicationHistoryModel.medicationTime == _timeList[index].text &&
                            medicationHistoryModel.dosage == widget.medicationTimeArgumentModel?.selectedDosage &&
                            double.tryParse(medicationHistoryModel.numberOfDosage) == widget.medicationTimeArgumentModel?.numberOfDosage &&
                            medicationHistoryModel.formulation == widget.medicationTimeArgumentModel?.formulationText &&
                            medicationHistoryModel.isPreventive == widget.isPreventive
                        ) {
                          widget.closeActionSheet(MedicationListActionSheetModel(
                            id: medicationHistoryModel.id,
                            medicationText: widget.medicationTimeArgumentModel?.medicationText ?? Constant.blankString,
                            formulationText: widget.medicationTimeArgumentModel?.formulationText ?? Constant.blankString,
                            selectedTime: _timeList[index].text ?? Constant.blankString,
                            startDate: medicationHistoryModel.startDate,
                            medicationValue: null,
                            selectedDosage: widget.medicationTimeArgumentModel?.selectedDosage ?? Constant.blankString,
                            formulationTag: widget.medicationTimeArgumentModel?.formulationTag ?? Constant.blankString,
                            dosageTag: widget.medicationTimeArgumentModel?.dosageTag ?? Constant.blankString,
                            numberOfDosage: double.tryParse(medicationHistoryModel.numberOfDosage),
                            isPreventive: medicationHistoryModel.isPreventive,
                            endDate: medicationHistoryModel.endDate,
                            reason: medicationHistoryModel.reason,
                            comments: medicationHistoryModel.comments,
                            isDeleted: false,
                            isChecked: true,
                          ));
                        } else {
                            widget.onPush(
                              context,
                              Constant.medicationStartDateScreenRouter,
                              MedicationStartDateArgumentModel(
                                medicationText: widget
                                        .medicationTimeArgumentModel
                                        ?.medicationText ??
                                    Constant.blankString,
                                medicationValue: widget
                                        .medicationTimeArgumentModel
                                        ?.medicationValue ??
                                    Values(),
                                formulationText: widget
                                        .medicationTimeArgumentModel
                                        ?.formulationText ??
                                    Constant.blankString,
                                formulationTag: widget
                                        .medicationTimeArgumentModel
                                        ?.formulationTag ??
                                    Constant.blankString,
                                selectedDosage: widget
                                        .medicationTimeArgumentModel
                                        ?.selectedDosage ??
                                    Constant.blankString,
                                dosageTag: widget.medicationTimeArgumentModel
                                        ?.dosageTag ??
                                    Constant.blankString,
                                numberOfDosage: widget
                                        .medicationTimeArgumentModel
                                        ?.numberOfDosage ??
                                    1,
                                selectedTime: _timeList[index].text ??
                                    Constant.blankString,
                              ),
                            );
                        }
                      } else {
                          widget.onPush(
                            context,
                            Constant.medicationStartDateScreenRouter,
                            MedicationStartDateArgumentModel(
                              medicationText: widget.medicationTimeArgumentModel
                                      ?.medicationText ??
                                  Constant.blankString,
                              medicationValue: widget
                                      .medicationTimeArgumentModel
                                      ?.medicationValue ??
                                  Values(),
                              formulationText: widget
                                      .medicationTimeArgumentModel
                                      ?.formulationText ??
                                  Constant.blankString,
                              formulationTag: widget.medicationTimeArgumentModel
                                      ?.formulationTag ??
                                  Constant.blankString,
                              selectedDosage: widget.medicationTimeArgumentModel
                                      ?.selectedDosage ??
                                  Constant.blankString,
                              dosageTag: widget
                                      .medicationTimeArgumentModel?.dosageTag ??
                                  Constant.blankString,
                              numberOfDosage: widget.medicationTimeArgumentModel
                                      ?.numberOfDosage ??
                                  1,
                              selectedTime:
                                  _timeList[index].text ?? Constant.blankString,
                            ),
                          );
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MedicationTimeArgumentModel {
  String medicationText;
  String formulationText;
  String formulationTag;
  Values medicationValue;
  String selectedDosage;
  String dosageTag;
  double numberOfDosage;

  MedicationTimeArgumentModel({
    required this.medicationText,
    required this.medicationValue,
    required this.formulationText,
    required this.formulationTag,
    required this.selectedDosage,
    required this.dosageTag,
    required this.numberOfDosage,
  });
}
