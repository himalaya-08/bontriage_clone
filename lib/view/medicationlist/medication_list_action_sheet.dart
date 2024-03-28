import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/view/medication_item_view.dart';
import 'package:mobile/view/medicationlist/medication_dosage_screen.dart';
import 'package:mobile/view/medicationlist/medication_formulation_screen.dart';
import 'package:mobile/view/medicationlist/medication_list_screen.dart';
import 'package:mobile/view/medicationlist/medication_start_date_screen.dart';
import 'package:mobile/view/medicationlist/medication_time_screen.dart';
import 'package:mobile/view/medicationlist/number_of_dosage_screen.dart';
import 'package:provider/provider.dart';

import '../../models/QuestionsModel.dart';
import '../../models/medication_history_model.dart';
import '../../util/constant.dart';
import '../CustomTextWidget.dart';

class MedicationListActionSheet extends StatefulWidget {
  final List<Values> medicationValuesList;
  final List<Map> selectedMedicationMapList;
  final List<Map> recentMedicationMapList;
  final List<Questions> dosageQuestionList;
  final List<Questions> formulationQuestionList;
  final List<MedicationHistoryModel> medicationHistoryModelList;
  final DateTime selectedDateTime;

  const MedicationListActionSheet({
    Key? key,
    required this.medicationValuesList,
    required this.selectedMedicationMapList,
    required this.recentMedicationMapList,
    required this.dosageQuestionList,
    required this.formulationQuestionList,
    required this.medicationHistoryModelList,
    required this.selectedDateTime,
  }) : super(key: key);

  @override
  State<MedicationListActionSheet> createState() =>
      _MedicationListActionSheetState();
}

class _MedicationListActionSheetState extends State<MedicationListActionSheet> {
  GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  Map<String, WidgetBuilder> _routeBuilders(
      BuildContext context, dynamic arguments) {

    LatestMedicationDataModelInfo latestMedicationDataModelInfo = Provider.of<LatestMedicationDataModelInfo>(context, listen: false);

    return {
      Constant.medicationListScreenRouter: (context) {
        return MedicationListScreen(
          onPush: _push,
          medicationValuesList: widget.medicationValuesList,
          selectedMedicationMapList: widget.selectedMedicationMapList,
          recentMedicationMapList: widget.recentMedicationMapList,
        );
      },
      Constant.medicationFormulationScreenRouter: (context) {
        return MedicationFormulationScreen(
          onPush: _push,
          medicationFormulationArgumentModel: arguments,
          formulationQuestionList: widget.formulationQuestionList,
          medicationText: latestMedicationDataModelInfo.getMedicationListActionSheetModel?.medicationText,
        );
      },
      Constant.medicationTimeScreenRouter: (context) {
        return MedicationTimeScreen(
          onPush: _push,
          medicationTimeArgumentModel: arguments,
          medicationHistoryModelList: widget.medicationHistoryModelList,
          historyId: latestMedicationDataModelInfo.getMedicationListActionSheetModel?.id,
          isPreventive: latestMedicationDataModelInfo.getMedicationListActionSheetModel?.isPreventive,
          closeActionSheet: _closeActionSheet,
        );
      },
      Constant.medicationDosageScreenRouter: (context) {
        return MedicationDosageScreen(
          onPush: _push,
          dosageQuestionList: widget.dosageQuestionList,
          closeActionSheet: _closeActionSheet,
          medicationDosageListArgumentModel: arguments,
          selectedDateTime: widget.selectedDateTime,
        );
      },
      Constant.numberOfDosageScreenRouter: (context) {
        return NumberOfDosageScreen(
          onPush: _push,
          numberOfDosageArgumentModel: arguments,
        );
      },
      Constant.medicationStartDateScreenRouter: (context) {
        return MedicationStartDateScreen(
          closeActionSheet: _closeActionSheet,
          medicationStartDateArgumentModel: arguments,
          medicationHistoryModelList: widget.medicationHistoryModelList,
          historyId: latestMedicationDataModelInfo.getMedicationListActionSheetModel?.id,
          maxDateTime: widget.selectedDateTime,
        );
      }
    };
  }

  Future<dynamic> _push(
      BuildContext context, String routeName, dynamic argument) async {
    var routeBuilders = _routeBuilders(context, argument);

    BackVisibilityProvider provider =
        Provider.of<BackVisibilityProvider>(context, listen: false);

    if (!provider.isVisible) {
      provider.updateVisibility(true);
    }

    await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              routeBuilders[routeName]!(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 350),
          settings: RouteSettings(name: routeName),
        ));
  }

  void _closeActionSheet(
      MedicationListActionSheetModel medicationListActionSheetModel) {
    medicationListActionSheetModel.isChecked = true;
    Navigator.pop(context, medicationListActionSheetModel);
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context, null);

    return Consumer<LatestMedicationDataModelInfo>(
      builder: (context, data, child){
        bool _isEdit = context.watch<LatestMedicationDataModelInfo>().getIsEdit;
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
                decoration: const BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  color: Constant.backgroundTransparentColor,
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Consumer<BackVisibilityProvider>(
                            builder: (context, value, child) {
                              return Visibility(
                                visible: value.isVisible,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    bool canPop =
                                        navigationKey.currentState?.canPop() ??
                                            false;

                                    if (canPop) {
                                      navigationKey.currentState?.pop();
                                    }

                                    canPop = navigationKey.currentState?.canPop() ??
                                        false;

                                    if (!canPop) {
                                      BackVisibilityProvider provider =
                                      Provider.of<BackVisibilityProvider>(
                                          context,
                                          listen: false);

                                      if (provider.isVisible) {
                                        provider.updateVisibility(false);
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.only(top: 10, right: 15),
                                    child: Row(
                                      children: [
                                        Icon(Icons.arrow_back_ios, color: Constant.locationServiceGreen, size: 17,),
                                        CustomTextWidget(
                                          text: Constant.back,
                                          style: TextStyle(
                                            fontFamily: Constant.jostMedium,
                                            color: Constant.locationServiceGreen,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => Navigator.of(context).pop(),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10, right: 15),
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
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Expanded(
                          child: Navigator(
                            key: navigationKey,
                            initialRoute: (_isEdit) ? Constant.medicationFormulationScreenRouter : Constant.medicationListScreenRouter,
                            onGenerateRoute: (routeSettings) {
                              return MaterialPageRoute(builder: (context) {
                                return routeBuilders[routeSettings.name]!(context);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class BackVisibilityProvider extends ChangeNotifier {
  bool isVisible = false;

  void updateVisibility(bool isVisible) {
    this.isVisible = isVisible;
    notifyListeners();
  }
}

String medicationListActionSheetModelToJson(List<MedicationListActionSheetModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

List<MedicationListActionSheetModel> medicationListActionSheetModelFromJson(String str) => List<MedicationListActionSheetModel>.from(json.decode(str).map((x) => MedicationListActionSheetModel.fromJson(x)));

class MedicationListActionSheetModel {
  int? id;
  String medicationText;
  String formulationText;
  String formulationTag;
  String selectedTime;
  DateTime? startDate;
  DateTime? endDate;
  String selectedDosage;
  String dosageTag;
  Values? medicationValue;
  double? numberOfDosage;
  bool isPreventive;
  String? reason;
  String? comments;
  bool isDeleted;
  bool isChecked;

  MedicationListActionSheetModel({
    this.id,
    required this.medicationText,
    required this.formulationText,
    required this.selectedTime,
    required this.startDate,
    required this.medicationValue,
    required this.selectedDosage,
    required this.formulationTag,
    required this.dosageTag,
    required this.numberOfDosage,
    this.isPreventive = true,
    this.endDate,
    this.reason,
    this.comments,
    this.isDeleted = false,
    this.isChecked = false,
  });

  MedicationListActionSheetModel createCopy(MedicationListActionSheetModel medicationListActionSheetModel) {
    MedicationListActionSheetModel model = MedicationListActionSheetModel(
      id: medicationListActionSheetModel.id,
      medicationText: medicationListActionSheetModel.medicationText,
      formulationText: medicationListActionSheetModel.formulationText,
      selectedTime: medicationListActionSheetModel.selectedTime,
      startDate: medicationListActionSheetModel.startDate,
      medicationValue: medicationListActionSheetModel.medicationValue,
      selectedDosage: medicationListActionSheetModel.selectedDosage,
      formulationTag: medicationListActionSheetModel.formulationTag,
      dosageTag: medicationListActionSheetModel.dosageTag,
      numberOfDosage: medicationListActionSheetModel.numberOfDosage,
      isPreventive: medicationListActionSheetModel.isPreventive,
      endDate: medicationListActionSheetModel.endDate,
      reason: medicationListActionSheetModel.reason,
      comments: medicationListActionSheetModel.comments,
      isDeleted: medicationListActionSheetModel.isDeleted,
      isChecked: medicationListActionSheetModel.isChecked,
    );

    return model;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "id": id,
      "medicationText": medicationText,
      "formulationText": formulationText,
      "selectedTime": selectedTime,
      "startDate": startDate?.toIso8601String(),
      "selectedDosage": selectedDosage,
      "formulationTag": formulationTag,
      "dosageTag": dosageTag,
      "numberOfDosage": numberOfDosage.toString(),
      "isPreventive": isPreventive,
      "endDate": endDate?.toIso8601String(),
      "reason": reason,
      "comments": comments,
      "medicationValue": null,
      "isDeleted": isDeleted,
      "isChecked": isChecked,
    };

    return map;
  }

  factory MedicationListActionSheetModel.fromJson(Map<String, dynamic> json) => MedicationListActionSheetModel(
    id: json["id"],
    medicationText: json["medicationText"],
    formulationText: json["formulationText"],
    selectedTime: json["selectedTime"],
    startDate: DateTime.tryParse(json["startDate"] ?? ''),
    selectedDosage: json['selectedDosage'],
    formulationTag: json['formulationTag'],
    dosageTag: json["dosageTag"],
    numberOfDosage: double.tryParse(json["numberOfDosage"] ?? ''),
    isPreventive: json['isPreventive'],
    endDate: DateTime.tryParse(json["endDate"] ?? ''),
    reason: json["reason"] ?? '',
    comments: json["comments"] ?? '',
    medicationValue: null,
    isDeleted: json["isDeleted"],
    isChecked: json['isChecked'] ?? false,
  );
}
