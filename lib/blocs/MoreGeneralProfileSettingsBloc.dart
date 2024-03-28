import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/ResponseModel.dart';
import '../models/SignUpOnBoardSelectedAnswersModel.dart';
import '../models/UserProfileInfoModel.dart';
import '../networking/AppException.dart';
import '../networking/RequestMethod.dart';
import '../providers/SignUpOnBoardProviders.dart';
import '../repository/MoreGeneralProfileSettingsRepository.dart';
import '../util/WebservicePost.dart';
import '../util/constant.dart';

class MoreGeneralProfileSettingsBloc {
  StreamController<dynamic> _generalProfileStreamController = StreamController();

  Stream<dynamic> get generalProfileStream => _generalProfileStreamController.stream;
  StreamSink<dynamic> get generalProfileSink => _generalProfileStreamController.sink;

  StreamController<dynamic> _networkStreamController = StreamController();

  Stream<dynamic> get networkStream => _networkStreamController.stream;
  StreamSink<dynamic> get networkSink => _networkStreamController.sink;

  UserProfileInfoModel userProfileInfoModel = UserProfileInfoModel();
  MoreGeneralProfileSettingsRepository _moreGeneralProfileSettingsRepository = MoreGeneralProfileSettingsRepository();
  int? profileId;
  ResponseModel? _responseModel;

  MoreGeneralProfileSettingsBloc(int profileId) {
    _moreGeneralProfileSettingsRepository = MoreGeneralProfileSettingsRepository();
    _generalProfileStreamController = StreamController<dynamic>();
    this.profileId = profileId;
  }

  void updateUserProfileModel() async {
    userProfileInfoModel = await _moreGeneralProfileSettingsRepository.getUserProfileInfoModel();
    generalProfileSink.add(Constant.success);
  }

  Future<void> editMyProfileServiceCall(BuildContext context, List<SelectedAnswers> selectedAnswersList) async {
    if(userProfileInfoModel != null && profileId != null) {
      try {
        String url = '${WebservicePost.getServerUrl(context)}event/$profileId';
        var response = await _moreGeneralProfileSettingsRepository.editMyProfileServiceCall(url, RequestMethod.POST, selectedAnswersList, context);
        if (response is AppException) {
          networkSink.addError(response);
        } else {
          if (response != null && response is ResponseModel) {
            debugPrint('Id:' + response.id.toString());
            profileId = response.id;
            selectedAnswersList = [];
            response.mobileEventDetails.forEach((element) {
              selectedAnswersList.add(SelectedAnswers(questionTag: element.questionTag, answer: element.value));
            });

            SelectedAnswers? genderSelectedAnswers = selectedAnswersList.firstWhereOrNull((element) => element.questionTag == Constant.profileGenderTag);
            if(genderSelectedAnswers == null)
              selectedAnswersList.add(SelectedAnswers(questionTag: Constant.profileGenderTag, answer: ''));

            _updateUserProfileInfoInDatabase(selectedAnswersList);

            if(_responseModel != null) {
              response.headacheList = _responseModel!.headacheList;
              response.medicationValues = _responseModel!.medicationValues;
              response.triggerValues = _responseModel!.triggerValues;
              response.triggerMedicationValues = _responseModel!.triggerMedicationValues;

              _responseModel = response;
            }

            networkSink.add(Constant.success);
            generalProfileSink.add(Constant.success);
          } else {
            networkSink.addError(Exception(Constant.somethingWentWrong));
          }
        }
      } catch (e) {
        networkSink.addError(Exception(Constant.somethingWentWrong));
      }
    } else {
      networkSink.add(Constant.success);
    }
  }

  void initNetworkStreamController() {
    _networkStreamController.close();
    _networkStreamController = StreamController<dynamic>();
  }

  void enterSomeDummyData() {
    networkSink.add(Constant.loading);
  }

  void dispose() {
    _networkStreamController.close();
    _generalProfileStreamController.close();
  }

  void _updateUserProfileInfoInDatabase(List<SelectedAnswers> profileSelectedAnswerList) {
    if(profileSelectedAnswerList != null) {
      SelectedAnswers? nameSelectedAnswer = profileSelectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.profileFirstNameTag);
      SelectedAnswers? ageSelectedAnswer = profileSelectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.profileAgeTag);
      SelectedAnswers? sexSelectedAnswer = profileSelectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.profileSexTag);

      if(nameSelectedAnswer != null && ageSelectedAnswer != null && sexSelectedAnswer != null) {
        if(nameSelectedAnswer.answer!.isNotEmpty && ageSelectedAnswer.answer!.isNotEmpty && sexSelectedAnswer.answer!.isNotEmpty) {
          userProfileInfoModel
            ..profileName = nameSelectedAnswer.answer
            ..age = ageSelectedAnswer.answer
            ..sex = sexSelectedAnswer.answer;

          SignUpOnBoardProviders.db.updateUserProfileInfoModel(userProfileInfoModel);
        }
      }
    }
  }
}