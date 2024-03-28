import 'package:mobile/util/constant.dart';

import 'RecordsTrendsDataModel.dart';
import 'package:mobile/models/TrendsFilterModel.dart';

class EditGraphViewFilterModel {
  String? singleTypeHeadacheSelected;
  String? compareHeadacheTypeSelected1;
  String? compareHeadacheTypeSelected2;
  String headacheTypeRadioButtonSelected;

  //None, Logged Behaviors, LoggedPotentialTriggers, and Medications
  String whichOtherFactorSelected;

  RecordsTrendsDataModel? recordsTrendsDataModel;
  TrendsFilterListModel? trendsFilterListModel;
  int currentTabIndex;
  int numberOfDaysInMonth;
  DateTime? selectedDateTime;



  EditGraphViewFilterModel({
    this.singleTypeHeadacheSelected,
    this.compareHeadacheTypeSelected1,
    this.compareHeadacheTypeSelected2,
    this.whichOtherFactorSelected = Constant.noneRadioButtonText,
    this.recordsTrendsDataModel,
    this.currentTabIndex = 0,
    this.headacheTypeRadioButtonSelected = Constant.viewSingleHeadache,
    this.numberOfDaysInMonth = 0,
    this.selectedDateTime,
  });
}