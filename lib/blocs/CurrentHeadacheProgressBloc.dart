import 'dart:async';

import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';

class CurrentHeadacheProgressBloc {
  StreamController<dynamic> _streamController = StreamController();
  Stream<dynamic> get stream => _streamController.stream;
  StreamSink<dynamic> get sink => _streamController.sink;

  CurrentHeadacheProgressBloc() {
    _streamController = StreamController<dynamic>();
  }

  fetchDataFromLocalDatabase(CurrentUserHeadacheModel? currentUserHeadacheModelData) async {
    CurrentUserHeadacheModel? currentUserHeadacheModel;

    if(currentUserHeadacheModelData != null) {
      currentUserHeadacheModel = currentUserHeadacheModelData;
    } else {
      var userProfileInfoData = null;
      userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

      if(userProfileInfoData != null)
        currentUserHeadacheModel = await SignUpOnBoardProviders.db.getUserCurrentHeadacheData(userProfileInfoData.userId!);

      /*if(currentUserHeadacheModel == null && userProfileInfoData != null) {
        await SignUpOnBoardProviders.db.insertUserCurrentHeadacheData(CurrentUserHeadacheModel(userId: userProfileInfoData.userId, selectedDate: DateTime.now().toUtc().toIso8601String()));
      }*/
    }

    sink.add(currentUserHeadacheModel ?? CurrentUserHeadacheModel());
  }

  void dispose() {
    _streamController.close();
  }
}