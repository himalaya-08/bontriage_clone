import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/RecordsCompassAxesResultModel.dart';
import 'package:mobile/models/UserGenerateReportDataModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/SignUpSecondStepCompassRepository.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';

class SignUpSecondStepCompassBloc {
  SignUpSecondStepCompassRepository _repository = SignUpSecondStepCompassRepository();
  StreamController<dynamic> _recordsCompassStreamController = StreamController();
  StreamController<dynamic> _networkStreamController = StreamController();

  StreamSink<dynamic> get recordsCompassDataSink =>
      _recordsCompassStreamController.sink;

  Stream<dynamic> get recordsCompassDataStream =>
      _recordsCompassStreamController.stream;

  Stream<dynamic> get networkDataStream => _networkStreamController.stream;

  StreamSink<dynamic> get networkDataSink => _networkStreamController.sink;

  StreamController<dynamic> _viewReportStreamController = StreamController();

  Stream<dynamic> get viewReportStream => _viewReportStreamController.stream;
  StreamSink<dynamic> get viewReportSink => _viewReportStreamController.sink;

  String clinicalImpression = '';

  List<String> clinicalImpressionList = [];

  SignUpSecondStepCompassBloc() {
    _repository = SignUpSecondStepCompassRepository();
    clinicalImpression = Constant.blankString;
    _recordsCompassStreamController = StreamController<dynamic>();
    _networkStreamController = StreamController<dynamic>();
    _viewReportStreamController = StreamController<dynamic>();
  }

  Future<void> fetchFirstLoggedScoreData(String headacheName, BuildContext context) async {
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      print('USERID????${userProfileInfoData.userId}');
      String url = '${WebservicePost.getServerUrl(context)}compass/profile/${userProfileInfoData.userId}';
      var response = await _repository.serviceCall(
          url, RequestMethod.GET);
      if (response is AppException) {
        networkDataSink.addError(response);
      } else {
        if (response != null) {
          RecordsCompassAxesResultModel recordsCompareCompassAxesResultModel = RecordsCompassAxesResultModel.fromJson(jsonDecode(response));
          await getClinicalImpressionData(headacheName, context);

          if(clinicalImpression.isNotEmpty) {
            recordsCompassDataSink.add(recordsCompareCompassAxesResultModel);
            networkDataSink.add(Constant.success);
          } else {
            networkDataSink.addError(Exception(Constant.somethingWentWrong));
          }
        } else {
          networkDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      networkDataSink.addError(Exception(Constant.somethingWentWrong));
    }
  }

  Future<dynamic> getUserGenerateReportData(String startTime, String endTime, String headacheName, BuildContext context) async {
    String? apiResponse;
    var userProfileInfoData =
    await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url = '${WebservicePost.getServerUrl(context)}report?mobile_user_id=${userProfileInfoData.userId}&start_date=$startTime&end_date=$endTime&headache_name=${Uri.encodeComponent(headacheName)}';
      var response = await _repository.callServiceForViewReport(url, RequestMethod.GET);
      if (response is AppException) {
        networkDataSink.addError(response);
        debugPrint(response.toString());
      } else {
        print(response);
        if(response != null && response is UserGenerateReportDataModel) {
          networkDataSink.add(Constant.success);
          viewReportSink.add(response);
        } else {
          networkDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      networkDataSink.addError(Exception(Constant.somethingWentWrong));
      debugPrint(e.toString());
    }
    return apiResponse;
  }

  ///This method is used to get clinical impression for a headache type
  Future<void> getClinicalImpressionData(String headacheName, BuildContext context) async {
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url = '${WebservicePost.getServerUrl(context)}common/headachetype?userId=${userProfileInfoData.userId}&headache_name=${Uri.encodeComponent(headacheName)}';
      //String url = 'https://migrainementorstaging.bontriage.com/mobileapi/v0/common/headachetype?userId=5895&headache_name=StageHead1';
      var response = await _repository.callServiceForClinicalImpression(url, RequestMethod.GET);

      if (response is AppException) {
        networkDataSink.addError(response);
        debugPrint(response.toString());
      } else {
        if(response != null && response is List<String>) {
          clinicalImpressionList = response;
          response.asMap().forEach((index, value) {
            if(index == response.length - 1) {
              if(clinicalImpression.isNotEmpty)
                clinicalImpression = '$clinicalImpression, $value';
              else
                clinicalImpression = value;
            } else {
              if(clinicalImpression.isNotEmpty)
                clinicalImpression = '$clinicalImpression, $value';
              else
                clinicalImpression = value;
            }
          });
        } else {
          networkDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch(e) {
      networkDataSink.addError(Exception(Constant.somethingWentWrong));
      debugPrint(e.toString());
    }
  }


  void initNetworkStreamController() {
    _networkStreamController?.close();
    _networkStreamController = StreamController<dynamic>();
  }

  void enterDummyDataToNetworkStream() {
    networkDataSink.add(Constant.loading);
  }

  void dispose() {
    _recordsCompassStreamController?.close();
    _networkStreamController?.close();
    _viewReportStreamController?.close();
  }
}