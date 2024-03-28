import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:mobile/models/SignUpScreenOnBoardModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/util/constant.dart';

import '../models/SiteNameModelResponse.dart';

class TonixSignUpRepository {
  Future<dynamic> checkUserExistServiceCall(String url, RequestMethod requestMethod) async {
    var response;
    try {
      response = await NetworkService.getRequest(url, requestMethod).serviceCall();

      if (response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return response;
    }
  }

  Future<dynamic> signUpServiceCall(String url, RequestMethod requestMethod, String subjectId, String birthYear, String password, {String? siteName, List<SiteNameModel>? siteNameModelList}) async {
    var response;

    String payload = _getSignUpPayload(subjectId, birthYear, password, siteName: siteName!, siteNameModelList: siteNameModelList!);

    try {
      response = await NetworkService(url, requestMethod,
          payload)
          .serviceCall();

      if(response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return response;
    }
  }

  String _getSignUpPayload(String subjectId, String birthYear, String password, {String? siteName, List<SiteNameModel>? siteNameModelList}) {
    SignUpScreenOnBoardModel signUpScreenOnBoardModel = SignUpScreenOnBoardModel();

    var siteNameModel = siteNameModelList?.firstWhereOrNull((element) => element.siteName == siteName);

    signUpScreenOnBoardModel.subjectId = subjectId;
    signUpScreenOnBoardModel.age = '0';
    signUpScreenOnBoardModel.firstName = Constant.blankString;
    signUpScreenOnBoardModel.lastName = Constant.blankString;
    signUpScreenOnBoardModel.location = Constant.blankString;
    signUpScreenOnBoardModel.notificationKey = Constant.blankString;
    signUpScreenOnBoardModel.password = password;
    signUpScreenOnBoardModel.sex = Constant.blankString;
    signUpScreenOnBoardModel.termsAndPolicy = true;
    signUpScreenOnBoardModel.emailNotification = true;
    signUpScreenOnBoardModel.birthYear = birthYear;
    signUpScreenOnBoardModel.siteId = siteNameModel?.id.toString() ?? '';
    signUpScreenOnBoardModel.siteCode = siteNameModel!.siteCode;
    signUpScreenOnBoardModel.siteName = siteNameModel.siteName;
    signUpScreenOnBoardModel.siteCoordinatorName = siteNameModel.coordinatorName;
    signUpScreenOnBoardModel.sitePhNumber = siteNameModel.phNumber;
    signUpScreenOnBoardModel.siteEmail = siteNameModel.email;

    return jsonEncode(signUpScreenOnBoardModel.toTonixSignUpJson());
  }

  Future<dynamic> createAndDeletePushNotificationServiceCall(String url, RequestMethod requestMethod, String requestBody) async {
    try {
      var response = await NetworkService(url, requestMethod,requestBody).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return null;
    }
  }
}