import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/TonixSignUpRepository.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';

import '../main.dart';
import '../models/SiteNameModelResponse.dart';

class SiteNameBloc {
  TonixSignUpRepository _repository = TonixSignUpRepository();

  StreamController<dynamic> _siteNameStreamController = StreamController();

  Stream<dynamic> get siteNameStream => _siteNameStreamController.stream;

  StreamSink<dynamic> get siteNameSink => _siteNameStreamController.sink;

  List<SiteNameModel> siteNameModelList = [];

  SiteNameBloc() {
    _repository = TonixSignUpRepository();

    _siteNameStreamController = StreamController.broadcast();
  }

  Future<dynamic> getSiteNameServiceCall(BuildContext context) async {
    try {
      var response;

      ///https://mobileapp.bontriage.com/tonixqa/v0/app/sites
      response = await _repository.checkUserExistServiceCall(
          '${WebservicePost.getServerUrl(context)}app/sites', RequestMethod.GET);

      if (response is AppException) {
        siteNameSink.addError(response);
      } else {
        if (response != null) {
          var json = jsonDecode(response);

          json.forEach((v) {
            siteNameModelList.add(new SiteNameModel.fromJson(v));
          });

          siteNameSink.add(Constant.success);
        } else {
          siteNameSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      siteNameSink.addError(Exception(Constant.somethingWentWrong));
    }
  }

  void enterSomeDummyData() {
    siteNameSink.add(Constant.loading);
  }

  void dispose() {
    _siteNameStreamController.close();
  }
}
