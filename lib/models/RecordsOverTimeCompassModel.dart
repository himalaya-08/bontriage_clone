import 'package:mobile/models/HeadacheListDataModel.dart';
import 'package:mobile/models/RecordsCompassAxesResultModel.dart';

class RecordsOverTimeCompassModel{
  RecordsCompassAxesResultModel? recordsCompareCompassAxesResultModel;
  List<HeadacheListDataModel>? headacheListDataModel = [];

  RecordsOverTimeCompassModel({this.recordsCompareCompassAxesResultModel,
    this.headacheListDataModel});


}