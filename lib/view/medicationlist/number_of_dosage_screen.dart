import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/medication_data_model.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/medication_item_view.dart';
import 'package:mobile/view/medicationlist/medication_time_screen.dart';
import 'package:provider/provider.dart';

import '../../models/QuestionsModel.dart';
import '../../util/constant.dart';

class NumberOfDosageScreen extends StatefulWidget {
  final Function(BuildContext, String, dynamic) onPush;
  final NumberOfDosageArgumentModel? numberOfDosageArgumentModel;

  const NumberOfDosageScreen(
      {Key? key, required this.onPush, this.numberOfDosageArgumentModel})
      : super(key: key);

  @override
  State<NumberOfDosageScreen> createState() => _NumberOfDosageScreenState();
}

class _NumberOfDosageScreenState extends State<NumberOfDosageScreen> {
  //contains number of dosages selected by the user
  double dosage = 1;
  String title = '';

  @override
  void initState() {
    super.initState();

    if (widget.numberOfDosageArgumentModel?.formulationText == 'Oral syrup' ||
    widget.numberOfDosageArgumentModel?.formulationText == 'Oral suspension' ||
    widget.numberOfDosageArgumentModel?.formulationText == 'Oral solution' ||
    widget.numberOfDosageArgumentModel?.formulationText == 'Oral powder') {
      title = 'Select the amount of ${widget.numberOfDosageArgumentModel?.medicationText} ${widget.numberOfDosageArgumentModel?.selectedDosage} ${widget.numberOfDosageArgumentModel?.formulationText.toLowerCase()} you take for this dose:';
    } else {
      title = 'Select the quantity of ${widget.numberOfDosageArgumentModel?.medicationText} ${widget.numberOfDosageArgumentModel?.selectedDosage} ${widget.numberOfDosageArgumentModel?.formulationText.toLowerCase()} you take for this dose:';
    }
  }

  //provides the initial data to the dosage & dosageString variables
  void _initialDosageProvider(BuildContext context) {
    bool isEdit = context.read<LatestMedicationDataModelInfo>().getIsEdit;
    int index =
        context.read<LatestMedicationDataModelInfo>().getElementIndex ?? 0;
    String _medicationType =
        context.read<LatestMedicationDataModelInfo>().getMedicationType;
    List<MedicationDataModel> medicationDataModelList = context
        .read<LatestMedicationDataModelInfo>()
        .getLatestMedicationDataModelList(_medicationType);

    if (isEdit) {
      dosage = medicationDataModelList[index].numberOfDosage ?? 1;
    }
  }

  int count = 0;

  @override
  Widget build(BuildContext context) {
    _initialDosageProvider(context);
    return ChangeNotifierProvider(
      create: (_) => DosageInfo(),
      child: Consumer<DosageInfo>(
        builder: (context, data, child) {
          count++;
          if (count <= 1) {
            data.setDosage(dosage);
          }
          return Container(
            color: Constant.backgroundTransparentColor,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: CustomTextWidget(
                      text: title,
                      style: TextStyle(
                        color: Constant.locationServiceGreen,
                        fontFamily: Constant.jostMedium,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  //const SizedBox(height: 20,),
                  /*const SizedBox(
                    height: 85,
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _dosageButtonBuilder(
                              -0.5, '-1/2', Colors.brown, data),
                          _dosageButtonBuilder(
                              0.5, '+1/2', Constant.chatBubbleGreen, data),
                        ]),
                  ),
                  Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _dosageButtonBuilder(-1, '-1', Colors.brown, data),
                          Container(
                            padding: const EdgeInsets.all(29),
                            width: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.lightBlueAccent),
                              shape: BoxShape.circle,
                              color: Colors.deepPurple,
                            ),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: CustomTextWidget(
                                  text: '${data.getDosageString}x',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: Constant.jostRegular,
                                      fontSize: 25),
                                ),
                              ),
                            ),
                          ),
                          _dosageButtonBuilder(
                              1, '+1', Constant.chatBubbleGreen, data),
                        ],
                      )),
                  CustomTextWidget(
                    text:
                        '${widget.numberOfDosageArgumentModel?.medicationText}',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constant.jostRegular,
                        fontSize: 20),
                  ),
                  const SizedBox(
                    height: 190,
                  ),*/
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 100,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 10,),
                            BouncingWidget(
                              onPressed: () {
                                double currentDosage = data.getDosage;
                                if(currentDosage > 0.5) data.updateDosage(currentDosage-0.5);
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Constant.chatBubbleGreen
                                ),
                                child: Center(
                                  child: Icon(Icons.remove, color: Colors.black, size: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 25,),
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 0.3, color: Constant.chatBubbleGreen),
                                  borderRadius: BorderRadius.circular(40),
                                  color: Constant.oliveGreen,
                                ),
                                child: Center(
                                  child: CustomTextWidget(
                                    text: '${data.getDosageString}x',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: Constant.jostRegular,
                                      fontSize: 20,
                                      color: Constant.locationServiceGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 25,),
                            BouncingWidget(
                              onPressed: (){
                                data.updateDosage(data.getDosage+0.5);
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Constant.chatBubbleGreen
                                ),
                                child: Center(
                                  child: Icon(Icons.add, color: Colors.black, size: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10,),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: BouncingWidget(
                      onPressed: () {
                        widget.onPush(
                            context,
                            Constant.medicationTimeScreenRouter,
                            MedicationTimeArgumentModel(
                              medicationText: widget.numberOfDosageArgumentModel
                                      ?.medicationText ??
                                  Constant.blankString,
                              formulationText: widget
                                      .numberOfDosageArgumentModel
                                      ?.formulationText ??
                                  Constant.blankString,
                              formulationTag: widget.numberOfDosageArgumentModel
                                      ?.formulationTag ??
                                  Constant.blankString,
                              medicationValue: widget
                                      .numberOfDosageArgumentModel
                                      ?.medicationValue ??
                                  Values(),
                              selectedDosage: widget.numberOfDosageArgumentModel
                                      ?.selectedDosage ??
                                  Constant.blankString,
                              dosageTag: widget
                                      .numberOfDosageArgumentModel?.dosageTag ??
                                  Constant.blankString,
                              numberOfDosage: data.getDosage,
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
                                fontFamily: Constant.jostMedium),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  //method for building the dosage change buttons
  /*Widget _dosageButtonBuilder(double dosageChange, String buttonText,
      Color buttonColor, DosageInfo data) {
    return InkWell(
      child: GestureDetector(
        onTap: ((dosageChange == -1 && data.getDosage == 1) ||
                (dosageChange < 0 && data.getDosage == 0.5))
            ? null
            : () {
                double newDosage = data.getDosage + dosageChange;
                data.updateDosage(newDosage);
              },
        child: Container(
          width: 85,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ((dosageChange == -1 && data.getDosage == 1) ||
                    (dosageChange < 0 && data.getDosage == 0.5))
                ? Colors.black26
                : buttonColor,
          ),
          child: Center(
              child: Text(
            buttonText,
            style: TextStyle(color: Colors.white),
          )),
        ),
      ),
    );
  }*/


}

class DosageInfo with ChangeNotifier {
  //regex for removing the redundant decimal zeros from doubleString
  RegExp regex = RegExp(r'([.]*0)(?!.*\d)');

  double _dosage = 1;
  String _dosageString = '1';

  double get getDosage => _dosage;

  String get getDosageString => _dosageString;

  void setDosage(double dosage) {
    _dosage = dosage;
    _dosageString = dosage.toString().replaceAll(regex, '');
  }

  void updateDosage(double dosage) {
    _dosage = dosage;
    _dosageString = dosage.toString().replaceAll(regex, '');
    notifyListeners();
  }
}

class NumberOfDosageArgumentModel {
  String medicationText;
  String formulationText;
  String formulationTag;
  Values medicationValue;
  String selectedDosage;
  String dosageTag;

  NumberOfDosageArgumentModel({
    required this.medicationText,
    required this.formulationText,
    required this.formulationTag,
    required this.medicationValue,
    required this.selectedDosage,
    required this.dosageTag,
  });
}
