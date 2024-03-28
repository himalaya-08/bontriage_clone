import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:collection/collection.dart';

import '../../models/medication_history_model.dart';
import '../checkbox_widget.dart';
import 'medication_list_action_sheet.dart';

class MedicationStartDateScreen extends StatefulWidget {
  const MedicationStartDateScreen({
    Key? key,
    required this.closeActionSheet,
    this.medicationStartDateArgumentModel,
    required this.medicationHistoryModelList,
    this.historyId,
    required this.maxDateTime,
  }) : super(key: key);

  final Function(MedicationListActionSheetModel) closeActionSheet;
  final MedicationStartDateArgumentModel? medicationStartDateArgumentModel;
  final List<MedicationHistoryModel> medicationHistoryModelList;
  final int? historyId;
  final DateTime maxDateTime;

  @override
  State<MedicationStartDateScreen> createState() =>
      _MedicationStartDateScreenState();
}

class _MedicationStartDateScreenState extends State<MedicationStartDateScreen> {
  DateTime? _selectedDate;

  bool _isChecked = false;
  MedicationHistoryModel? _medicationHistoryModel;
  DateTime _maxDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    _maxDateTime = widget.maxDateTime;
    _maxDateTime =
        DateTime(_maxDateTime.year, _maxDateTime.month, _maxDateTime.day);

    MedicationHistoryModel? data = widget.medicationHistoryModelList
        .firstWhereOrNull((element) => element.id == widget.historyId);

    bool checkCondition = data?.endDate == null &&
        data?.medicationName ==
            widget.medicationStartDateArgumentModel?.medicationText &&
        double.tryParse(data?.numberOfDosage ?? '') ==
            widget.medicationStartDateArgumentModel?.numberOfDosage &&
        data?.medicationTime ==
            widget.medicationStartDateArgumentModel?.selectedTime &&
        data?.formulation ==
            widget.medicationStartDateArgumentModel?.formulationText;

    if (checkCondition) {
      _medicationHistoryModel = data;
    } else {
      widget.medicationHistoryModelList
          .where((element) => element.id != widget.historyId)
          .toList()
          .forEach((element) {
        if (element.endDate == null &&
            element.medicationName ==
                widget.medicationStartDateArgumentModel?.medicationText &&
            double.tryParse(element.numberOfDosage) ==
                widget.medicationStartDateArgumentModel?.numberOfDosage &&
            element.medicationTime ==
                widget.medicationStartDateArgumentModel?.selectedTime &&
            element.formulation ==
                widget.medicationStartDateArgumentModel?.formulationText &&
            element.startDate?.isBefore(widget.maxDateTime) == true) {
          _medicationHistoryModel = element;
        }
      });
    }

    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day);

    if (_medicationHistoryModel != null) {
      _selectedDate = _medicationHistoryModel?.startDate;
      _isChecked = true;

      _maxDateTime = _selectedDate ?? now;
    } else {
      if (now.isAfter(_maxDateTime)) {
        _selectedDate = _maxDateTime;
        _isChecked = false;
      } else {
        _selectedDate = now;
        _isChecked = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Constant.backgroundTransparentColor,
      child: RawScrollbar(
        thickness: 2,
        thumbColor: Constant.locationServiceGreen,
        thumbVisibility: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        text: (widget.medicationStartDateArgumentModel!.isUnitDosage)
                            ? '${widget.medicationStartDateArgumentModel?.medicationText} ${widget.medicationStartDateArgumentModel?.selectedDosage} ${widget.medicationStartDateArgumentModel?.formulationText}s'
                            : '${widget.medicationStartDateArgumentModel?.medicationText} ${widget.medicationStartDateArgumentModel?.selectedDosage} ${widget.medicationStartDateArgumentModel?.formulationText.toLowerCase()}s',
                        style: TextStyle(
                          color: Constant.locationServiceGreen,
                          fontFamily: Constant.jostMedium,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                        child: CustomTextWidget(
                          text: 'When did you first start taking this dose?',
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
                        text: 'If you don’t recall the exact date, an approximate date is helpful too!',
                        style: TextStyle(
                          color: Constant.locationServiceGreen.withOpacity(0.7),
                          fontFamily: Constant.jostRegular,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: (widget.medicationStartDateArgumentModel!.isUnitDosage) ? 30 : 0,
                    ),
                    Visibility(
                      visible: _medicationHistoryModel != null,
                      child: CheckboxWidget(
                        questionTag: "",
                        checkboxTitle: "The start date of this dosage has not changed.",
                        initialValue: _isChecked,
                        checkboxColor: Constant.locationServiceGreen,
                        textColor: Constant.locationServiceGreen,
                        onChanged: (String questionTag, bool value) {
                          setState(() {
                            _isChecked = value;
                          });
                        },
                      ),
                    ),
                    Visibility(
                      visible: _medicationHistoryModel != null,
                      child: const SizedBox(
                        height: 20,
                      ),
                    ),
                    Container(
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: CupertinoTheme(
                          data: CupertinoThemeData(
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(
                                fontSize: 18,
                                color: Constant.locationServiceGreen,
                                fontFamily: Constant.jostRegular,
                              ),
                            ),
                          ),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            use24hFormat: false,
                            minimumDate:
                                _isChecked ? _selectedDate : (DateTime(2000, 1, 1)),
                            maximumYear:
                                _isChecked ? _selectedDate?.year : _maxDateTime.year,
                            minimumYear: _isChecked
                                ? _selectedDate?.year ?? DateTime.now().year
                                : 2000,
                            maximumDate: _isChecked ? _selectedDate : _maxDateTime,
                            initialDateTime: _selectedDate ?? DateTime.now(),
                            backgroundColor: Colors.transparent,
                            onDateTimeChanged: (DateTime value) {
                              _selectedDate =
                                  DateTime(value.year, value.month, value.day);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: BouncingWidget(
                      onPressed: () {
                        widget.medicationStartDateArgumentModel?.medicationValue
                            .isSelected = true;
                        widget.closeActionSheet(MedicationListActionSheetModel(
                          id: _medicationHistoryModel?.id,
                          medicationText: widget.medicationStartDateArgumentModel
                              ?.medicationText ??
                              Constant.blankString,
                          formulationText: widget.medicationStartDateArgumentModel
                              ?.formulationText ??
                              Constant.blankString,
                          formulationTag: widget.medicationStartDateArgumentModel
                              ?.formulationTag ??
                              Constant.blankString,
                          medicationValue: widget.medicationStartDateArgumentModel
                              ?.medicationValue ??
                              Values(),
                          selectedTime: widget.medicationStartDateArgumentModel
                              ?.selectedTime ??
                              Constant.blankString,
                          selectedDosage: widget.medicationStartDateArgumentModel
                              ?.selectedDosage ??
                              Constant.blankString,
                          dosageTag: widget
                              .medicationStartDateArgumentModel?.dosageTag ??
                              Constant.blankString,
                          numberOfDosage: widget.medicationStartDateArgumentModel
                              ?.numberOfDosage ??
                              1,
                          startDate: _selectedDate ?? DateTime.now(),
                          endDate: (widget
                              .medicationStartDateArgumentModel!.isUnitDosage)
                              ? _selectedDate ?? DateTime.now()
                              : null,
                        ));
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Constant.chatBubbleGreen,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: CustomTextWidget(
                            text: Constant.next,
                            style: TextStyle(
                              color: Constant.bubbleChatTextView,
                              fontSize: 15,
                              fontFamily: Constant.jostMedium,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class MedicationStartDateArgumentModel {
  String medicationText;
  String formulationText;
  String formulationTag;
  Values medicationValue;
  String selectedDosage;
  String dosageTag;
  double numberOfDosage;
  String selectedTime;

  bool isUnitDosage;

  MedicationStartDateArgumentModel(
      {required this.medicationText,
      required this.medicationValue,
      required this.formulationText,
      required this.formulationTag,
      required this.selectedDosage,
      required this.dosageTag,
      required this.numberOfDosage,
      required this.selectedTime,
      this.isUnitDosage = false});
}
