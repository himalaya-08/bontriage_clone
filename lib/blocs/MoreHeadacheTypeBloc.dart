import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/repository/MoreHeadacheTypeRepository.dart';

import '../networking/AppException.dart';
import '../providers/SignUpOnBoardProviders.dart';
import '../util/WebservicePost.dart';
import '../util/constant.dart';

class MoreHeadacheTypeBloc {
  MoreHeadacheTypeRepository _repository = MoreHeadacheTypeRepository();

  StreamController<dynamic> _networkStreamController = StreamController();

  Stream<dynamic> get networkStream => _networkStreamController.stream;
  StreamSink<dynamic> get networkSink => _networkStreamController.sink;

  StreamController<dynamic> _headacheTypeStreamController = StreamController();

  Stream<dynamic> get headacheTypeStream => _headacheTypeStreamController.stream;
  StreamSink<dynamic> get headacheTypeSink => _headacheTypeStreamController.sink;

  MoreHeadacheTypeBloc() {
    _repository = MoreHeadacheTypeRepository();
    _headacheTypeStreamController = StreamController<dynamic>();
  }

  void initNetworkStreamController() {
    _networkStreamController.close();
    _networkStreamController = StreamController<dynamic>();
  }

  void enterDummyDataToNetworkStream() {
    networkSink.add(Constant.loading);
  }

  void dispose() {
    _networkStreamController.close();
  }

  ///This method is used to get all headache type
  Future<void> getAllHeadacheTypeService(BuildContext context) async {
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    try {
      String url = '${WebservicePost.getServerUrl(context)}common/fetchheadaches/${userProfileInfoData.userId}';
      var response = await _repository.callFetchAllHeadacheTypes(url, RequestMethod.GET);

      if (response is AppException) {
        networkSink.addError(response);
        debugPrint(response.toString());
      } else {
        headacheTypeSink.add(response);
        networkSink.add(Constant.success);
      }
    } catch(e) {
      networkSink.addError(Exception(Constant.somethingWentWrong));
      debugPrint(e.toString());
    }
  }
}