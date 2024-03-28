import 'package:mobile/models/RecordsCompassAxesResultModel.dart';

import 'HeadacheListDataModel.dart';

class RecordsCompareCompassModel {
  RecordsCompassAxesResultModel? recordsCompareCompassAxesResultModel;
  RecordsCompassAxesResultModel? signUpCompassAxesResultModel;
  List<HeadacheListDataModel>? headacheListDataModel = [];

  RecordsCompareCompassModel({this.recordsCompareCompassAxesResultModel,
  this.signUpCompassAxesResultModel,this.headacheListDataModel});


}