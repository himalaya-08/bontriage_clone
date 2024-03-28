import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mobile/models/ResponseModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/repository/MoreLocationServicesRepository.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/constant.dart';

class MoreLocationServicesBloc {
  StreamController<dynamic> _controller = StreamController();

  Stream<dynamic> get stream => _controller.stream;
  StreamSink<dynamic> get sink => _controller.sink;

  StreamController<dynamic> _myProfileController = StreamController();

  Stream<dynamic> get myProfileStream => _myProfileController.stream;
  StreamSink<dynamic> get myProfileSink => _myProfileController.sink;

  StreamController<dynamic> _locationStreamController = StreamController();

  Stream<dynamic> get locationStream => _locationStreamController.stream;
  StreamSink<dynamic> get locationSink => _locationStreamController.sink;

  List<SelectedAnswers> profileSelectedAnswerList = [];

  MoreLocationServicesRepository _repository = MoreLocationServicesRepository();

  int? profileId;

  double? lat;
  double? lng;

  MoreLocationServicesBloc() {
    _controller = StreamController<dynamic>.broadcast();
    _myProfileController = StreamController<dynamic>.broadcast();
    _repository = MoreLocationServicesRepository();
  }

  Future<void> fetchMyProfileData(BuildContext context) async {
    var userProfileInfoModel = await _repository.getUserProfileInfoModel();

    if(userProfileInfoModel != null) {
      try {
        String url = '${WebservicePost.getServerUrl(context)}event/?event_type=profile&latest_event_only=true&user_id=${userProfileInfoModel.userId}';
        var response = await _repository.myProfileServiceCall(url, RequestMethod.GET);

        if (response is AppException) {
          sink.addError(response);
        } else {
          if (response != null && response is ResponseModel) {
            profileId = response.id;

            profileSelectedAnswerList = [];

            response.mobileEventDetails.forEach((element) {
              profileSelectedAnswerList.add(SelectedAnswers(questionTag: element.questionTag, answer: element.value));
            });

            SelectedAnswers? genderSelectedAnswers = profileSelectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.profileGenderTag);
            if(genderSelectedAnswers == null)
              profileSelectedAnswerList.add(SelectedAnswers(questionTag: Constant.profileGenderTag, answer: Constant.blankString));

            SelectedAnswers? locationSelectedAnswers = profileSelectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.profileLocationTag);
            if(locationSelectedAnswers != null) {
              List<String> splitValues = locationSelectedAnswers.answer!.split('%@');
              if(splitValues.length == 2) {
                lat = double.tryParse(splitValues[0]);
                lng = double.tryParse(splitValues[1]);
              }
            }

            sink.add(Constant.success);
          } else {
            sink.addError(Exception(Constant.somethingWentWrong));
          }
        }
      } catch(e) {
        sink.addError(Exception(Constant.somethingWentWrong));
      }
    }
  }

  Future<void> editMyProfileData(BuildContext context) async {
    var userProfileInfoModel = await _repository.getUserProfileInfoModel();

    if(userProfileInfoModel != null && profileId != null) {
      try {
        String url = '${WebservicePost.getServerUrl(context)}event/$profileId';
        var response = await _repository.editMyProfileServiceCall(url, RequestMethod.POST, profileSelectedAnswerList, context);
        if (response is AppException) {
          sink.addError(response);
        } else {
          if (response != null && response is ResponseModel) {
            sink.add(Constant.success);
            myProfileSink.add(Constant.success);
          } else {
            sink.addError(Exception(Constant.somethingWentWrong));
          }
        }
      } catch (e) {
        sink.addError(Exception(Constant.somethingWentWrong));
      }
    }
  }

  void enterDummyDataToStreamController() {
    sink.add(Constant.loading);
  }

  void dispose() {
    _myProfileController.close();
    _controller.close();
    _locationStreamController.close();
  }
}