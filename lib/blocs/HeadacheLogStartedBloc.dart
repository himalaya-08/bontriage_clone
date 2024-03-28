import 'package:flutter/material.dart';
import 'package:mobile/models/CurrentUserHeadacheModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/Utils.dart';

class HeadacheLogStartedBloc {

  ///This method is used to store headache data into DB
  Future<CurrentUserHeadacheModel?>
      storeHeadacheDetailsIntoLocalDatabase(BuildContext context) async {
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();

    CurrentUserHeadacheModel? currentUserHeadacheModel;

    if (userProfileInfoData != null)
      currentUserHeadacheModel = await SignUpOnBoardProviders.db
          .getUserCurrentHeadacheData(userProfileInfoData.userId!);

    if (currentUserHeadacheModel == null && userProfileInfoData != null) {
      DateTime currentDateTime = DateTime.now();
      DateTime dateTime = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day, currentDateTime.hour, currentDateTime.minute, 0, 0, 0);
      currentUserHeadacheModel = CurrentUserHeadacheModel(
        userId: userProfileInfoData.userId,
        selectedDate: Utils.getDateTimeInUtcFormat(dateTime, true, context),
        isOnGoing: true,
        isFromServer: false,
      );
      await SignUpOnBoardProviders.db
          .insertUserCurrentHeadacheData(currentUserHeadacheModel);
    }

    return currentUserHeadacheModel;
  }
}
