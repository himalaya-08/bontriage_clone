

import 'package:flutter/material.dart';
import 'package:mobile/models/ResponseModel.dart';

class MoreHeadachesDeleteProvider with ChangeNotifier{
  HeadacheTypeData? deletedHeadache;

  HeadacheTypeData? getDeletedHeadache() => deletedHeadache;

  void updateDeletedHeadache(HeadacheTypeData updatedDeletedHeadache){
    deletedHeadache = updatedDeletedHeadache;
    notifyListeners();
  }
}