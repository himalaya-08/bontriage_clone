import 'dart:async';

import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/repository/PostClinicalImpressionRepository.dart';
import 'package:mobile/util/WebservicePost.dart';

import '../models/SignUpOnBoardSelectedAnswersModel.dart';
import '../util/constant.dart';
import 'package:flutter/foundation.dart';

class PostClinicalImpressionBloc {
  PostClinicalImpressionRepository _repository = PostClinicalImpressionRepository();

  StreamController<dynamic> _clinicalImpressionController = StreamController();

  StreamSink<dynamic> get clinicalImpressionSink =>
      _clinicalImpressionController.sink;

  Stream<dynamic>? get clinicalImpressionStream =>
      _clinicalImpressionController.stream;

  StreamController<dynamic> _networkStreamController = StreamController();

  Stream<dynamic> get networkDataStream => _networkStreamController.stream;

  StreamSink<dynamic> get networkDataSink => _networkStreamController.sink;

  PostClinicalImpressionBloc() {
    _repository = PostClinicalImpressionRepository();

    _clinicalImpressionController = StreamController<dynamic>();
    _networkStreamController = StreamController<dynamic>();
  }

  Future<void> getClinicalImpressionOfHeadache(SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel) async {
    try {
      String url = WebservicePost.sanareAPIUrl;
      var response = await _repository.serviceCall(url, RequestMethod.POST, signUpOnBoardSelectedAnswersModel);

      if (response is AppException) {
        networkDataSink.addError(response);
      } else {
        if (response != null) {
          List<String> clinicalImpressionList = [];
          if (response is Map) {
            var diagnosticMap =  response['diagnostic'];

            if (diagnosticMap is List) {
              if (diagnosticMap.length == 1) {
                String result = diagnosticMap[0];
                clinicalImpressionList.add(result.trim());
              } else {
                diagnosticMap.forEach((element) {
                  if (element is String)
                    clinicalImpressionList.add(element.substring(element.indexOf(".") + 1).trim());
                });
              }
            }

            clinicalImpressionSink.add(clinicalImpressionList.reversed.toList());
            networkDataSink.add(Constant.success);
          }
        } else {
          networkDataSink.addError(Exception(Constant.somethingWentWrong));
        }
        debugPrint(response.toString());
      }
    } catch (e) {
      networkDataSink.addError(Exception(Constant.somethingWentWrong));
    }
  }

  void enterSomeDummyDataToStreamController() {
    networkDataSink.add(Constant.loading);
  }
  void initNetworkStreamController() {
    _networkStreamController.close();
    _networkStreamController = StreamController<dynamic>();
  }

  void dispose() {
    _clinicalImpressionController.close();
    _networkStreamController.close();
  }
}