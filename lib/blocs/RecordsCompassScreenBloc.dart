import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mobile/models/HeadacheListDataModel.dart';
import 'package:mobile/models/RecordsCompareCompassModel.dart';
import 'package:mobile/models/RecordsCompassAxesResultModel.dart';
import 'package:mobile/models/RecordsOverTimeCompassModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/RecordsCompassRepository.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';

class RecordsCompassScreenBloc {
  RecordsCompassRepository _recordsCompassRepository = RecordsCompassRepository();
  StreamController<dynamic> _recordsCompassStreamController = StreamController();
  StreamController<dynamic> _networkStreamController = StreamController();
  int count = 0;

  StreamSink<dynamic> get recordsCompassDataSink =>
      _recordsCompassStreamController.sink;

  Stream<dynamic> get recordsCompassDataStream =>
      _recordsCompassStreamController.stream;

  Stream<dynamic> get networkDataStream => _networkStreamController.stream;

  StreamSink<dynamic> get networkDataSink => _networkStreamController.sink;

  RecordsOverTimeCompassModel _recordsOverTimeCompassModel =
  RecordsOverTimeCompassModel();

  RecordsCompareCompassModel _recordsCompareCompassModel =
  RecordsCompareCompassModel();

  RecordsCompassScreenBloc({this.count = 0}) {
    _recordsCompassStreamController = StreamController<dynamic>();
    _recordsCompassRepository = RecordsCompassRepository();
    _networkStreamController = StreamController<dynamic>();
  }

  fetchAllHeadacheListData(String startDate, String endDate,
      bool isOverTimeCompassScreen, String? headacheName, BuildContext context) async {
    String? apiResponse;
    var userProfileInfoData =
    await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url = '${WebservicePost.getServerUrl(context)}common/fetchheadaches/' +
          userProfileInfoData.userId!;
      var response = await _recordsCompassRepository.compassServiceCall(
          url, RequestMethod.GET);
      if (response is AppException) {
        networkDataSink.addError(response);
        apiResponse = response.toString();
      } else {
        if (response != null) {
          var json = jsonDecode(response);
          List<HeadacheListDataModel> headacheListModelData = [];
          json.forEach((v) {
            headacheListModelData.add(HeadacheListDataModel.fromJson(v));
          });

          if (headacheListModelData.length > 0) {
            if (isOverTimeCompassScreen) {
              _recordsOverTimeCompassModel.headacheListDataModel =
                  headacheListModelData;
              if (headacheName != null) {
                fetchOverTimeCompassAxesResult(
                    startDate, endDate, headacheName, context);
              } else {
                fetchOverTimeCompassAxesResult(startDate, endDate, headacheListModelData[headacheListModelData.length-1].text ?? '', context);
              }
            } else {
              _recordsCompareCompassModel.headacheListDataModel =
                  headacheListModelData;
              if (headacheName == null) {
                fetchCompareCompassAxesResult(startDate, endDate, headacheListModelData[headacheListModelData.length-1].text ?? '', context);
              } else {
                fetchCompareCompassAxesResult(startDate, endDate, headacheName, context);
              }
            }
          } else {
            networkDataSink.add(Constant.success);
            recordsCompassDataSink.add(Constant.noHeadacheData);
          }
          print(headacheListModelData);
        } else {
          recordsCompassDataSink
              .addError(Exception(Constant.somethingWentWrong));
          networkDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      networkDataSink.addError(Exception(Constant.somethingWentWrong));
      apiResponse = Constant.somethingWentWrong;
    }
    return apiResponse;
  }

  fetchOverTimeCompassAxesResult(
      String startDate, String endDate, String headacheName, BuildContext context) async {
    String? apiResponse;
    var userProfileInfoData =
    await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url = '${WebservicePost.getServerUrl(context)}compass/calender?start_date=$startDate&end_date=$endDate&user_id=${userProfileInfoData.userId}&headache_name=${Uri.encodeComponent(headacheName)}';
      var response = await _recordsCompassRepository.compassServiceCall(
          url, RequestMethod.GET);
      if (response is AppException) {
        networkDataSink.addError(response);
        apiResponse = response.toString();
      } else {
        if (response != null) {
          _recordsOverTimeCompassModel.recordsCompareCompassAxesResultModel =
              RecordsCompassAxesResultModel.fromJson(jsonDecode(response));
          networkDataSink.add(Constant.success);
          recordsCompassDataSink.add(_recordsOverTimeCompassModel);
        } else {
          recordsCompassDataSink
              .addError(Exception(Constant.somethingWentWrong));
          networkDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      networkDataSink.addError(Exception(Constant.somethingWentWrong));
      apiResponse = Constant.somethingWentWrong;
    }
    return apiResponse;
  }

  fetchCompareCompassAxesResult(
      String startDate, String endDate, String headacheName, BuildContext context) async {
    String? apiResponse;
    var userProfileInfoData =
    await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url = '${WebservicePost.getServerUrl(context)}compass/calender?start_date=$startDate&end_date=$endDate&user_id=${userProfileInfoData.userId}&headache_name=${Uri.encodeComponent(headacheName)}';
      var response = await _recordsCompassRepository.compassServiceCall(url, RequestMethod.GET);
      if (response is AppException) {
        networkDataSink.addError(response);
        apiResponse = response.toString();
      } else {
        if (response != null) {
          _recordsCompareCompassModel.recordsCompareCompassAxesResultModel =
              RecordsCompassAxesResultModel.fromJson(jsonDecode(response));
          await fetchFirstLoggedCompassAxesResult(context);
        } else {
          networkDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      networkDataSink.addError(Exception(Constant.somethingWentWrong));
      apiResponse = Constant.somethingWentWrong;
    }
    return apiResponse;
  }

  //http://localhost:8080/mobileapi/v0/compass/profile/4579
  fetchFirstLoggedCompassAxesResult(BuildContext context) async {
    String? apiResponse;
    var userProfileInfoData =
    await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url = '${WebservicePost.getServerUrl(context)}compass/profile/${userProfileInfoData.userId}';
      var response = await _recordsCompassRepository.compassServiceCall(
          url, RequestMethod.GET);
      if (response is AppException) {
        networkDataSink.addError(response);
        apiResponse = response.toString();
      } else {
        if (response != null) {
          _recordsCompareCompassModel.signUpCompassAxesResultModel =
              RecordsCompassAxesResultModel.fromJson(jsonDecode(response));
          recordsCompassDataSink.add(_recordsCompareCompassModel);
          networkDataSink.add(Constant.success);
        } else {
          networkDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      networkDataSink.addError(Exception(Constant.somethingWentWrong));
      apiResponse = Constant.somethingWentWrong;
    }
    return apiResponse;
  }

  void enterSomeDummyDataToStreamController() {
    networkDataSink.add(Constant.loading);
  }

  void initNetworkStreamController() {
    _networkStreamController.close();
    _networkStreamController = StreamController<dynamic>();
  }

  void dispose() {
    _recordsCompassStreamController.close();
    _networkStreamController.close();
  }
}