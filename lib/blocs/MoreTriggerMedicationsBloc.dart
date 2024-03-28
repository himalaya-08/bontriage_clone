import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/models/ResponseModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/repository/MoreTriggerMedicationRepository.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';

class MoreTriggerMedicationBloc {
  MoreTriggerMedicationRepository _repository = MoreTriggerMedicationRepository();
  StreamController<dynamic> _editStreamController = StreamController();

  Stream<dynamic> get editStream => _editStreamController.stream;
  StreamSink<dynamic> get editSink => _editStreamController.sink;

  StreamController<dynamic> _networkStreamController = StreamController();

  Stream<dynamic> get networkStream => _networkStreamController.stream;
  StreamSink<dynamic> get networkSink => _networkStreamController.sink;

  MoreTriggerMedicationBloc() {
    _repository = MoreTriggerMedicationRepository();

    _editStreamController = StreamController<dynamic>();
    _networkStreamController = StreamController<dynamic>();
  }

  void initNetworkStreamController() {
    _networkStreamController.close();
    _networkStreamController = StreamController<dynamic>();
  }

  void enterLoadingDataToNetworkStreamController() {
    networkSink.add(Constant.loading);
  }

  Future<void> callEditApi(String eventId, List<SelectedAnswers> selectedAnswerList, ResponseModel responseModel, BuildContext context) async {
    try {
      var response;
      if(eventId == null) {
        response = await _repository
            .editServiceCall(
            '${WebservicePost.getServerUrl(context)}event',
            RequestMethod.POST,
            selectedAnswerList, context);
      } else {
        response = await _repository
            .editServiceCall(
            '${WebservicePost.getServerUrl(context)}event/$eventId',
            RequestMethod.POST,
            selectedAnswerList, context);
      }
      if (response is AppException) {
        networkSink.addError(response);
      } else {
        if(response != null && response is ResponseModel) {
          if(responseModel.triggerMedicationValues!.length > 0)
            responseModel.triggerMedicationValues![0] = response;
          else
            responseModel.triggerMedicationValues?.add(response);
          networkSink.add(Constant.success);
          editSink.add(Constant.success);
        } else {
          networkSink.add(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      networkSink.add(Exception(Constant.somethingWentWrong));
    }
  }

  void dispose() {
    _editStreamController.close();
    _networkStreamController.close();
  }
}