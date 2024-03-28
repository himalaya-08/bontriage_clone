import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/HeadacheListDataModel.dart';
import 'package:mobile/models/RecordsTrendsDataModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/RecordsTrendsRepository.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/models/RecordsTrendsMultipleHeadacheDataModel.dart';
import 'package:provider/provider.dart';

import '../view/TrendsScreen.dart';

class RecordsTrendsScreenBloc {
  RecordsTrendsRepository _recordsTrendsRepository = RecordsTrendsRepository();
  StreamController<dynamic> _recordsTrendsStreamController = StreamController();
  StreamController<dynamic> _networkStreamController = StreamController();
  RecordsTrendsDataModel _recordsTrendsDataModel = RecordsTrendsDataModel();

  int count = 0;

  StreamSink<dynamic> get recordsTrendsDataSink =>
      _recordsTrendsStreamController.sink;

  Stream<dynamic> get recordsTrendsDataStream =>
      _recordsTrendsStreamController.stream;

  Stream<dynamic> get networkDataStream => _networkStreamController.stream;

  StreamSink<dynamic> get networkDataSink => _networkStreamController.sink;

  RecordsTrendsRepository _repository = RecordsTrendsRepository();

  RecordsTrendsScreenBloc({this.count = 0}) {
    _recordsTrendsStreamController = StreamController<dynamic>();
    _recordsTrendsRepository = RecordsTrendsRepository();
    _networkStreamController = StreamController<dynamic>();
  }

  fetchAllHeadacheListData(
      String startDate, String endDate, String? firstHeadacheName,String? secondHeadacheName, bool isMultiPleHeadacheSelected, BuildContext context) async {
    String? apiResponse;
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url ='${ WebservicePost.getServerUrl(context)}common/fetchheadaches/${userProfileInfoData.userId}';
      var response = await _recordsTrendsRepository.trendsServiceCall(
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
            if (firstHeadacheName == null) {
              firstHeadacheName = headacheListModelData[headacheListModelData.length - 1].text;
            }
            _recordsTrendsDataModel.headacheListModelData =
                headacheListModelData;
            if (firstHeadacheName != null) {
              if(isMultiPleHeadacheSelected){
                getMultipleHeadacheTrendsDate(startDate, endDate, firstHeadacheName, secondHeadacheName, context);
              }else getTrendsUserData(startDate, endDate, firstHeadacheName, context);
            } else {
              getTrendsUserData(
                  startDate, endDate, headacheListModelData[0].text!, context);
            }
          } else {
            TrendsInfo info = Provider.of<TrendsInfo>(context, listen: false);
            info.updateTrendsInfo(0);
            networkDataSink.add(Constant.success);
            recordsTrendsDataSink.add(Constant.noHeadacheData);
          }
          debugPrint(headacheListModelData.toString());
        } else {
          recordsTrendsDataSink.addError(Exception(Constant.somethingWentWrong));
          networkDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      networkDataSink.addError(Exception(Constant.somethingWentWrong));
      apiResponse = Constant.somethingWentWrong;
    }
    return apiResponse;
  }



//http://34.222.200.187:8080/mobileapi/v0/trends/event/?end_date=2021-01-31T18:30:00Z&headache_name=Headache1&start_date=2021-01-01T18:30:00Z&user_id=4613
  getTrendsUserData(
      String startDate, String endDate, String headacheName, BuildContext context) async {
    String? apiResponse;
    var userProfileInfoData =
        await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url = '${WebservicePost.getServerUrl(context)}trends/event?start_date=$startDate&end_date=$endDate&user_id=${userProfileInfoData.userId}&headache_name=$headacheName';
      var response = await _recordsTrendsRepository.trendsServiceCall(
          url, RequestMethod.GET);
      if (response is AppException) {
        recordsTrendsDataSink.addError(response);
        networkDataSink.addError(Exception(Constant.somethingWentWrong));
        apiResponse = response.toString();
      } else {
        if (response != null) {
          List<HeadacheListDataModel> headacheDataList = [];
          if (_recordsTrendsDataModel.headacheListModelData!.length > 0) {
            headacheDataList = _recordsTrendsDataModel.headacheListModelData!;
          }
          _recordsTrendsDataModel = RecordsTrendsDataModel.fromJson(jsonDecode(response));
          apiResponse = Constant.success;
          _recordsTrendsDataModel.headacheListModelData = headacheDataList;
          recordsTrendsDataSink.add(_recordsTrendsDataModel);
          networkDataSink.add(Constant.success);
        } else {
          debugPrint('here 1');
          recordsTrendsDataSink.addError(Exception(Constant.somethingWentWrong));
          networkDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      debugPrint('here 2');
      recordsTrendsDataSink.addError(Exception(Constant.somethingWentWrong));
      networkDataSink.addError(Exception(Constant.somethingWentWrong));
      apiResponse = Constant.somethingWentWrong;
    }
    return apiResponse;
  }

  getMultipleHeadacheTrendsDate(String startDate, String endDate,String? firstHeadacheName,String? secondHeadacheName, BuildContext context) async{
    String? apiResponse;
    var userProfileInfoData =
    await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url = '${WebservicePost.getServerUrl(context)}trends/compare?start_date=$startDate&end_date=$endDate&user_id=${userProfileInfoData.userId}&headache_first=$firstHeadacheName&headache_second=$secondHeadacheName';
      var response = await _recordsTrendsRepository.trendsServiceCall(
          url, RequestMethod.GET);
      if (response is AppException) {
        recordsTrendsDataSink.addError(response);
        apiResponse = response.toString();
      } else {
        if (response != null) {
          List<HeadacheListDataModel> headacheDataList = [];
          if (_recordsTrendsDataModel.headacheListModelData!.length > 0) {
            headacheDataList = _recordsTrendsDataModel.headacheListModelData!;
          }
          _recordsTrendsDataModel.recordsTrendsMultipleHeadacheDataModel = RecordsTrendsMultipleHeadacheDataModel.fromJson(jsonDecode(response));
          apiResponse = Constant.success;
          _recordsTrendsDataModel.headacheListModelData = headacheDataList;

          _recordsTrendsDataModel.behaviors = _recordsTrendsDataModel.recordsTrendsMultipleHeadacheDataModel!.behaviors;
          _recordsTrendsDataModel.medication = _recordsTrendsDataModel.recordsTrendsMultipleHeadacheDataModel!.medication;
          _recordsTrendsDataModel.triggers = _recordsTrendsDataModel.recordsTrendsMultipleHeadacheDataModel!.triggers;
          recordsTrendsDataSink.add(_recordsTrendsDataModel);
          networkDataSink.add(Constant.success);
        } else {
          recordsTrendsDataSink.addError(Exception(Constant.somethingWentWrong));
          networkDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      recordsTrendsDataSink.addError(Exception(Constant.somethingWentWrong));
      networkDataSink.addError(Exception(Constant.somethingWentWrong));
      apiResponse = Constant.somethingWentWrong;
    }
    return apiResponse;

  }

  void enterSomeDummyDataToStream() {
    recordsTrendsDataSink.add(Constant.loading);
  }

  void init() {
    _recordsTrendsStreamController.close();
    _recordsTrendsStreamController = StreamController<dynamic>();
  }

  void initNetworkStreamController() {
    _networkStreamController.close();
    _networkStreamController = StreamController<dynamic>();
  }

  void dispose() {
    _recordsTrendsStreamController.close();
  }
}
