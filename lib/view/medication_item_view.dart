import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/models/medication_data_model.dart';
import 'package:mobile/models/medication_history_model.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomRichTextWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/medicationlist/medication_info_dialog.dart';
import 'package:mobile/view/medicationlist/medication_list_action_sheet.dart';
import 'package:provider/provider.dart';

import 'checkbox_widget.dart';

class MedicationItemView extends StatefulWidget {
  final String medicationType;
  final String contentType;
  final List<MedicationDataModel> medicationDataModelList;
  final List<MedicationListActionSheetModel>
      preventiveMedicationListActionSheetModelList;
  final Function(BuildContext, LatestMedicationDataModelInfo, bool, int?, bool)
      openSearchMedicationActionSheet;
  final Function(BuildContext, int, bool, LatestMedicationDataModelInfo)
      openDeleteMedicationDialog;
  final bool checkbox;
  final Function onChanged;
  final bool preventiveCheckbox;
  final Function(bool) onPreventiveMedicationCheckboxChanged;
  final DateTime selectedDateTime;
  final List<MedicationHistoryModel> medicationHistoryDataModelList;

  const MedicationItemView({
    Key? key,
    required this.medicationDataModelList,
    required this.contentType,
    required this.openSearchMedicationActionSheet,
    required this.openDeleteMedicationDialog,
    required this.medicationType,
    required this.checkbox,
    this.preventiveMedicationListActionSheetModelList = const [],
    required this.onChanged,
    required this.onPreventiveMedicationCheckboxChanged,
    required this.preventiveCheckbox,
    required this.selectedDateTime,
    required this.medicationHistoryDataModelList,
  }) : super(key: key);

  @override
  State<MedicationItemView> createState() => _MedicationItemViewState();
}

class _MedicationItemViewState extends State<MedicationItemView> {
  //regex for removing the redundant decimal zeros from doubleString
  RegExp regex = RegExp(r'([.]*0)(?!.*\d)');

  //List containing all the acute care medicationDataModels
  List<MedicationDataModel> _acuteCareMedicationDataModelList = [];

  //List containing all the preventive medicationDataModels
  List<MedicationDataModel> _preventiveMedicationDataModelList = [];

  //contains the selected medications(checkbox) indices
  List<int> _selectedMedications = [];

  Map<String, DateTime> _unitMedicationsLastDate = Map();

  List<MedicationListActionSheetModel> _preventiveMedicationListActionSheetModelList = [];

  @override
  void initState() {
    super.initState();
    _preventiveMedicationListActionSheetModelList = widget.preventiveMedicationListActionSheetModelList;
    Utils.lastGivenDateGenerator(
        widget.medicationHistoryDataModelList, _unitMedicationsLastDate);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      lazy: false,
      create: (_) => LatestMedicationDataModelInfo(),
      child: Consumer<LatestMedicationDataModelInfo>(
        builder: (context, data, child) {
          data.setMedicationType(widget.medicationType);
          (widget.medicationType == Constant.preventive)
              ? _preventiveMedicationDataModelList =
                  widget.medicationDataModelList
              : _acuteCareMedicationDataModelList =
                  widget.medicationDataModelList;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 7),
                    child: CustomTextWidget(
                      text: widget.medicationType,
                      style: TextStyle(
                        color: Constant.chatBubbleGreen,
                        fontSize: Platform.isAndroid ? 16 : 17,
                        fontFamily: Constant.jostMedium,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 17),
                    child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                contentPadding: EdgeInsets.all(0),
                                backgroundColor: Colors.transparent,
                                content: MedicationInfoDialog(
                                  dialogTitle:
                                      '${widget.medicationType} medications',
                                  dialogContent: (widget.medicationType ==
                                          Constant.preventive)
                                      ? 'Medications you take regularly that are intended to help reduce the frequency and/or severity of your migraine headaches. '
                                      : 'Medications you take at the first sign of a migraine, intended to reduce the duration and/or severity of your current migraine headache.',
                                ),
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.info_outlined,
                            color: Constant.chatBubbleGreen,
                            size: 18,
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Visibility(
                  visible: widget.contentType == Constant.logDayMedicationTag,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    child: CustomTextWidget(
                      text: (widget.medicationType == Constant.preventive)
                          ? 'Select each ${(widget.medicationType == Constant.preventive) ? Constant.preventive.toLowerCase() : Constant.acute.toLowerCase()} medication you took today.'
                          : 'Add any acute care medications you took today, even if you didn\'t have a migraine or headache.',
                      style: TextStyle(
                          fontSize: Platform.isAndroid ? 14 : 15,
                          color: Constant.locationServiceGreen,
                          fontFamily: Constant.jostRegular),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: widget.medicationType == Constant.preventive &&
                    widget.selectedDateTime.isAtSameMomentAs(DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day)) && _preventiveMedicationListActionSheetModelList.isNotEmpty,
                child: CheckboxWidget(
                  questionTag: "",
                  checkboxTitle: "My preventive medications have not changed.",
                  initialValue: widget.preventiveCheckbox,
                  checkboxColor: Constant.locationServiceGreen,
                  textColor: Constant.locationServiceGreen,
                  onChanged: (String questionTag, bool value) {
                    widget.onPreventiveMedicationCheckboxChanged(value);
                  },
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              (_medicationSectionChecker(widget.medicationType).isEmpty)
                  ? const SizedBox()
                  : Column(
                      children: _medicationWidgetBuilder(data),
                    ),
              Visibility(
                visible:
                    !widget.checkbox || widget.medicationType == Constant.acute,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        widget.openSearchMedicationActionSheet(
                            context,
                            data,
                            false,
                            null,
                            (widget.medicationType == Constant.preventive));
                      },
                      child: CustomTextWidget(
                        text: (widget.medicationType == Constant.preventive)
                            ? Constant.addAPreventiveMedication
                            : Constant.addAnAcuteCareMedication,
                        style: TextStyle(
                          fontSize: Platform.isAndroid ? 16 : 17,
                          color: Constant.addCustomNotificationTextColor,
                          fontFamily: Constant.jostRegular,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  //builds the list of medications widget
  List<Widget> _medicationWidgetBuilder(LatestMedicationDataModelInfo data) {
    List<Widget> medicationWidgetList = [];
    for (int index = 0;
        index < _medicationSectionChecker(widget.medicationType).length;
        index++) {
      String dosageValueString = _dosageValueStringGenerator(
          _medicationSectionChecker(widget.medicationType)[index].dosageValue ??
              '');
      medicationWidgetList.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                (widget.checkbox)
                    ? ((widget.medicationType == Constant.preventive)
                        ? Column(
                            children: [
                              ChangeNotifierProvider(
                                create: (_) => CheckboxToggleInfo(),
                                child: Consumer<CheckboxToggleInfo>(
                                  builder: (context, data, child) {
                                    return Theme(
                                      data: ThemeData(
                                          unselectedWidgetColor:
                                              Constant.locationServiceGreen),
                                      child: Visibility(
                                        visible: false,
                                        child: Checkbox(
                                          value: _medicationSectionChecker(
                                                  widget.medicationType)[index]
                                              .isChecked,
                                          checkColor:
                                              Constant.bubbleChatTextView,
                                          activeColor:
                                              Constant.locationServiceGreen,
                                          focusColor:
                                              Constant.locationServiceGreen,
                                          onChanged: (bool? val) {
                                            (val ?? true)
                                                ? _selectedMedications
                                                    .add(index)
                                                : _selectedMedications
                                                    .remove(index);
                                            Provider.of<CheckboxToggleInfo>(
                                                    context,
                                                    listen: false)
                                                .updateCheckboxNotifier(
                                                    val ?? true);

                                            _medicationSectionChecker(widget
                                                    .medicationType)[index]
                                                .isChecked = val ?? false;
                                            widget
                                                .preventiveMedicationListActionSheetModelList[
                                                    index]
                                                .isChecked = val ?? false;
                                            widget.onChanged();
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              )
                            ],
                          )
                        : Container())
                    : Padding(
                        padding:
                            EdgeInsets.only(right: widget.checkbox ? 0 : 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  widget.openSearchMedicationActionSheet(
                                      context,
                                      data,
                                      true,
                                      index,
                                      (widget.medicationType ==
                                              Constant.preventive)
                                          ? true
                                          : false),
                              behavior: HitTestBehavior.translucent,
                              child: Icon(
                                Icons.edit,
                                color: Constant.locationServiceGreen,
                                size: 19,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () => widget.openDeleteMedicationDialog(
                                  context,
                                  index,
                                  (widget.medicationType == Constant.preventive)
                                      ? true
                                      : false,
                                  data),
                              behavior: HitTestBehavior.translucent,
                              child: Icon(
                                Icons.delete,
                                color: Constant.locationServiceGreen,
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                      ),
                Flexible(
                  child: CustomRichTextWidget(
                    text: TextSpan(children: [
                      TextSpan(
                        text: _medicationSectionChecker(
                                widget.medicationType)[index]
                            .medicationText,
                        style: TextStyle(
                          height: 1.3,
                          fontFamily: Constant.jostBold,
                          fontSize: Platform.isAndroid ? 14 : 15,
                          color: Constant.locationServiceGreen,
                        ),
                      ),
                      TextSpan(
                        text: _medicationSectionChecker(
                                        widget.medicationType)[index]
                                    .dosageValue
                                    ?.contains('units') ==
                                true
                            ? ' (started ${Utils.getDateText(_medicationSectionChecker(widget.medicationType)[index].startDateTime ?? DateTime.now(), true)})\n'
                            : ((_medicationSectionChecker(
                                                widget.medicationType)[index]
                                            .startDateTime ==
                                        null &&
                                    _medicationSectionChecker(
                                                widget.medicationType)[index]
                                            .endDateTime ==
                                        null)
                                ? '\n'
                                : (_medicationSectionChecker(
                                                widget.medicationType)[index]
                                            .endDateTime ==
                                        null)
                                    ? ' (started ${Utils.getDateText(_medicationSectionChecker(widget.medicationType)[index].startDateTime ?? DateTime.now(), true)})\n'
                                    : ' (${Utils.getDateText(_medicationSectionChecker(widget.medicationType)[index].startDateTime ?? DateTime.now(), true)} - ${Utils.getDateText(_medicationSectionChecker(widget.medicationType)[index].endDateTime ?? DateTime.now(), true)})\n'),
                        style: TextStyle(
                          height: 1.3,
                          fontFamily: Constant.jostRegular,
                          fontSize: Platform.isAndroid ? 14 : 15,
                          color: Constant.locationServiceGreen,
                        ),
                      ),
                      _medicationSectionChecker(widget.medicationType)[index]
                                  .dosageValue
                                  ?.contains('units') ==
                              true
                          ? TextSpan(
                              text:
                                  '${(_unitMedicationsLastDate.isNotEmpty && _unitMedicationsLastDate[_medicationSectionChecker(widget.medicationType)[index].medicationText] != null) ? 'Last given on ${Utils.getDateText(_unitMedicationsLastDate[_medicationSectionChecker(widget.medicationType)[index].medicationText]!, true)} ${Utils.dateDifferenceTextGenerator(_medicationSectionChecker(widget.medicationType)[index].medicationText, _unitMedicationsLastDate)}\n' : 'You have not taken this before\n'}',
                              style: TextStyle(
                                height: 1.3,
                                fontFamily: Constant.jostRegular,
                                fontSize: Platform.isAndroid ? 14 : 15,
                                color: Constant.locationServiceGreen,
                              ),
                            )
                          : TextSpan(),
                      TextSpan(
                        text: _medicationSectionChecker(
                                        widget.medicationType)[index]
                                    .formulation
                                    ?.isNotEmpty ==
                                true
                            ? '${_medicationSectionChecker(widget.medicationType)[index].formulation}, $dosageValueString'
                            : '$dosageValueString',
                        style: TextStyle(
                          height: 1.3,
                          fontFamily: Constant.jostRegular,
                          fontSize: Platform.isAndroid ? 14 : 15,
                          color: Constant.locationServiceGreen,
                        ),
                      ),
                      _medicationSectionChecker(widget.medicationType)[index]
                                  .dosageValue
                                  ?.contains('units') ==
                              true
                          ? TextSpan()
                          : TextSpan(
                              text: '\n\u2022  ',
                              style: TextStyle(
                                fontSize: Platform.isAndroid ? 14 : 15,
                                fontFamily: Constant.jostMedium,
                                color: Constant.locationServiceGreen,
                              ),
                            ),
                      _medicationSectionChecker(widget.medicationType)[index]
                                  .dosageValue
                                  ?.contains('units') ==
                              true
                          ? TextSpan()
                          : TextSpan(
                              text: _medicationSectionChecker(
                                              widget.medicationType)[index]
                                          .numberOfDosage !=
                                      null
                                  ? '${_medicationSectionChecker(widget.medicationType)[index].numberOfDosage.toString().replaceAll(regex, '')} ${formulationStringGenerator(index).toLowerCase()}${_medicationSectionChecker(widget.medicationType)[index].dosageValue?.contains("units") == true ? '' : ' (${_medicationSectionChecker(widget.medicationType)[index].medicationTime?.toLowerCase()})'}'
                                  : _medicationSectionChecker(
                                          widget.medicationType)[index]
                                      .medicationTime,
                              style: TextStyle(
                                height: 1.3,
                                fontFamily: Constant.jostRegular,
                                fontSize: Platform.isAndroid ? 14 : 15,
                                color: Constant.locationServiceGreen,
                              ),
                            ),
                    ]),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ));
    }
    return medicationWidgetList;
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

  String formulationStringGenerator(int index) {
    if (_medicationSectionChecker(widget.medicationType)[index]
            .numberOfDosage !=
        null) {
      if (_medicationSectionChecker(widget.medicationType)[index]
              .numberOfDosage! >
          1) {
        return '${_medicationSectionChecker(widget.medicationType)[index].formulation}s';
      } else {
        return _medicationSectionChecker(widget.medicationType)[index]
                .formulation ??
            '';
      }
    } else {
      return _medicationSectionChecker(widget.medicationType)[index]
              .formulation ??
          '';
    }
  }

  List<MedicationDataModel> _medicationSectionChecker(String medicationType) {
    if (medicationType == Constant.preventive) {
      return _preventiveMedicationDataModelList;
    } else {
      return _acuteCareMedicationDataModelList;
    }
  }
}

//toggle notifier for the checkbox
class CheckboxToggleInfo with ChangeNotifier {
  bool checkboxToggle = false;

  bool getCheckboxToggle() => checkboxToggle;

  void updateCheckboxNotifier(bool toggleValue) {
    checkboxToggle = toggleValue;
    notifyListeners();
  }
}

//notifier for the latest MedicationDataModel
class LatestMedicationDataModelInfo with ChangeNotifier {
  //Tells the medication section type
  String _medicationType = Constant.preventive;

  //contains the list of all the item's custom status
  List<bool> _isCustomMedicationList = [];

  //Tells whether element is being edited or not
  bool _isEdit = false;

  //contains latest edited OR added OR deleted MedicationDataModel
  MedicationDataModel _latestMedicationDataModel = MedicationDataModel();

  //contains the index of the latest edited OR deleted MedicationDataModel
  int? _index;

  //contains latest acute care medicationDataModel list
  List<MedicationDataModel> _acuteCareMedicationDataModelList = [];

  //contains latest acute care medicationDataModel list
  List<MedicationDataModel> _preventiveMedicationDataModelList = [];

  void setPreventiveMedicationDataModelList(List<MedicationDataModel> list) {
    _preventiveMedicationDataModelList = list;
  }

  MedicationListActionSheetModel? _medicationListActionSheetModel;

  MedicationHistoryModel? _medicationHistoryModel;

  //Tells the medication section type
  String get getMedicationType => _medicationType;

  //Returns the list of all the item's custom status
  List<bool> get getIsCustomMedicationList => _isCustomMedicationList;

  //Tells whether element is being edited or not
  bool get getIsEdit => _isEdit;

  //contains the index of the latest edited OR deleted MedicationDataModel
  int? get getElementIndex => _index;

  //returns latest edited OR added OR deleted MedicationDataModel
  MedicationDataModel get getLatestMedicationDataModel =>
      _latestMedicationDataModel;

  MedicationListActionSheetModel? get getMedicationListActionSheetModel =>
      _medicationListActionSheetModel;

  MedicationHistoryModel? get medicationHistoryModel => _medicationHistoryModel;

  set setMedicationListActionSheetModel(
      MedicationListActionSheetModel? medicationListActionSheetModel) {
    _medicationListActionSheetModel = medicationListActionSheetModel;
  }

  set setMedicationHistoryModel(
      MedicationHistoryModel? medicationHistoryModel) {
    _medicationHistoryModel = medicationHistoryModel;
  }

  //returns latest MedicationDataModel list
  List<MedicationDataModel> getLatestMedicationDataModelList(
          String medicationSectionType) =>
      (medicationSectionType == Constant.preventive)
          ? _preventiveMedicationDataModelList
          : _acuteCareMedicationDataModelList;

  //Resets the custom medication list for saved data
  void resetIsCustomMedicationList() {
    List<MedicationDataModel> medicationList =
        (_medicationType == Constant.preventive)
            ? _preventiveMedicationDataModelList
            : _acuteCareMedicationDataModelList;
    if (_isCustomMedicationList.length < medicationList.length) {
      int diff = medicationList.length - _isCustomMedicationList.length;
      for (int i = 0; i < diff; i++) {
        _isCustomMedicationList.add(false);
      }
    }
  }

  //Sets the list of all the item's custom status
  void setIsCustomMedicationList(bool isCustomMedication) {
    List<MedicationDataModel> medicationList =
        (_medicationType == Constant.preventive)
            ? _preventiveMedicationDataModelList
            : _acuteCareMedicationDataModelList;
    if (_isCustomMedicationList.length == medicationList.length) {
      _isCustomMedicationList.add(isCustomMedication);
    } else if (_isCustomMedicationList.length > medicationList.length) {
      _isCustomMedicationList[_isCustomMedicationList.length - 1] =
          isCustomMedication;
    } else {
      int diff = medicationList.length - _isCustomMedicationList.length;
      for (int i = 0; i < diff; i++) {
        _isCustomMedicationList.add(false);
      }
      _isCustomMedicationList.add(isCustomMedication);
    }
  }

  //Deletes an element in list of all the item's custom status
  void deleteCustomMedicationElement(int index) {
    if (_isCustomMedicationList.isNotEmpty &&
        index < _isCustomMedicationList.length) {
      _isCustomMedicationList.removeAt(index);
    }
  }

  //Sets the medication section type
  void setMedicationType(String medicationSectionType) {
    _medicationType = medicationSectionType;
  }

  //updates the latest MedicationDataModel & corresponding list
  void updateLatestMedicationDataModel(
      MedicationDataModel? latestMedicationDataModel,
      List<MedicationDataModel> medicationDataModelList,
      String medicationSectionType) {
    (medicationSectionType == Constant.preventive)
        ? _preventiveMedicationDataModelList = medicationDataModelList
        : _acuteCareMedicationDataModelList = medicationDataModelList;
    notifyListeners();
  }

  //updates the index of the latest edited OR deleted MedicationDataModel
  void updateLatestMedicationDataModelIndex(int? index, bool isEdit) {
    _isEdit = isEdit;
    _index = index;
  }

  @override
  // ignore: must_call_super
  void dispose() {}
}
