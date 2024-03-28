import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/repository/LoginScreenRepository.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/models/VersionUpdateModel.dart';

class CheckVersionUpdateBloc {
  LoginScreenRepository _loginScreenRepository = LoginScreenRepository();
  StreamController<String> _checkVersionUpdateStreamController = StreamController();
  int count = 0;
  VersionUpdateModel versionUpdateModel = VersionUpdateModel();

  StreamSink<dynamic> get checkVersionUpdateDataSink =>
      _checkVersionUpdateStreamController.sink;

  Stream<dynamic> get changePasswordDataStream =>
      _checkVersionUpdateStreamController.stream;

  StreamController<dynamic> _checkVersionStreamController = StreamController();

  StreamController<dynamic> _networkStreamController = StreamController();

  StreamSink<dynamic> get networkSink =>
      _networkStreamController.sink;

  Stream<dynamic> get networkStream =>
      _networkStreamController.stream;

  CheckVersionUpdateBloc() {
    _checkVersionUpdateStreamController = StreamController<String>();

    _checkVersionStreamController = StreamController<dynamic>();
    _networkStreamController = StreamController<dynamic>.broadcast();
    _loginScreenRepository = LoginScreenRepository();
  }

//https://mobileapp.bontriage.com/mobileapi/v0/app/details/VERSION
  /// This method will be use for implement API for to check app build version is updated or not from the backend.
  Future<dynamic> checkVersionUpdateData(BuildContext context) async {
    try {
      String url = '${WebservicePost.getServerUrl(context)}app/details/VERSION';
      var response = await _loginScreenRepository.loginServiceCall(url, RequestMethod.GET);
      if (response is AppException) {
        //checkVersionUpdateDataSink.addError(response);
        if(response is NoInternetConnection){
          networkSink.add('No Internet Connection.');
        }else{
          networkSink.add(Constant.somethingWentWrong);
        }
      } else {
        if(response is String)
          versionUpdateModel = VersionUpdateModel.fromJson(json.decode(response));
        else
          networkSink.add(Constant.somethingWentWrong);
      }
    } catch (e) {
      networkSink.add(Constant.somethingWentWrong);
      //checkVersionUpdateDataSink.addError(Exception(Constant.somethingWentWrong));
      print(e.toString());
    }
    return versionUpdateModel;
  }

  void dispose() {
    _checkVersionUpdateStreamController.close();
    _checkVersionStreamController.close();
    _networkStreamController.close();
  }
}
