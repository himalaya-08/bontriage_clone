import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/UserGenerateReportDataModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/LoginScreenRepository.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';

class UserGenerateReportBloc {
  LoginScreenRepository _loginScreenRepository = LoginScreenRepository();
  StreamController<dynamic> _userGenerateReportStreamController = StreamController();
  int count = 0;
  UserGenerateReportDataModel _userGenerateReportDataModel = UserGenerateReportDataModel();

  StreamSink<dynamic> get userGenerateReportDataSink =>
      _userGenerateReportStreamController.sink;

  Stream<dynamic> get userGenerateReportDataStream =>
      _userGenerateReportStreamController.stream;

  UserGenerateReportBloc({this.count = 0}) {
    _userGenerateReportStreamController = StreamController<dynamic>();

    _userGenerateReportStreamController = StreamController<dynamic>();
    _loginScreenRepository = LoginScreenRepository();
  }
//http://34.222.200.187:8080/mobileapi/v0/report?mobile_user_id=4678&start_date=2021-3-24T00:00:00Z&end_date=2021-3-10T00:00:00Z
//http://34.222.200.187:8080/mobileapi/v0/report?mobile_user_id=4642&start_date=2021-3-1T00:00:00Z&end_date=2021-3-31T00:00:00Z
  /// This method.
  Future<dynamic> getUserGenerateReportData(String startTime, String endTime, BuildContext context) async {
    String? apiResponse;
    var userProfileInfoData =
    await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url =
          '${WebservicePost.getServerUrl(context)}report?mobile_user_id=${userProfileInfoData.userId}&start_date=$startTime&end_date=$endTime';
      var response =
      await _loginScreenRepository.loginServiceCall(url, RequestMethod.GET);
      if (response is AppException) {
        userGenerateReportDataSink.addError(response);
        print(apiResponse.toString());
      } else {
          _userGenerateReportDataModel = UserGenerateReportDataModel.fromJson(json.decode(response));
          userGenerateReportDataSink.add(Constant.success);
          apiResponse = _userGenerateReportDataModel.map!.base64;
      }
    } catch (e) {
      userGenerateReportDataSink.addError(Exception(Constant.somethingWentWrong));
      print(e.toString());
    }
    return apiResponse;
  }

  void enterSomeDummyDataToStreamController() {
    userGenerateReportDataSink.add(Constant.loading);
  }

  void dispose() {
    _userGenerateReportStreamController.close();
    _userGenerateReportStreamController.close();
  }

  void inItNetworkStream() {
    _userGenerateReportStreamController.close();
    _userGenerateReportStreamController = StreamController<dynamic>();
  }

}
