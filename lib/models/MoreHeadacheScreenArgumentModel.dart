import 'package:mobile/models/ResponseModel.dart';

class MoreHeadacheScreenArgumentModel {
  HeadacheTypeData? headacheTypeData;
  bool? isFromMyProfile;

  MoreHeadacheScreenArgumentModel({this.headacheTypeData, this.isFromMyProfile = false});
}