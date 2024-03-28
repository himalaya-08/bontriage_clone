import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mobile/models/ResponseModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/UserProfileInfoModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/repository/MoreMyProfileRepository.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';

class MoreMyProfileBloc {

  StreamController<dynamic> _myProfileStreamController = StreamController();

  Stream<dynamic> get myProfileStream => _myProfileStreamController.stream;
  StreamSink<dynamic> get myProfileSink => _myProfileStreamController.sink;

  StreamController<dynamic> _networkStreamController = StreamController();

  Stream<dynamic> get networkStream => _networkStreamController.stream;
  StreamSink<dynamic> get networkSink => _networkStreamController.sink;

  MoreMyProfileRepository _moreMyProfileRepository = MoreMyProfileRepository();
  UserProfileInfoModel userProfileInfoModel = UserProfileInfoModel();
  List<SelectedAnswers> profileSelectedAnswerList = [];

  ResponseModel? _responseModel;

  int? profileId;

  MoreMyProfileBloc() {
    _myProfileStreamController = StreamController<dynamic>();
    _moreMyProfileRepository = MoreMyProfileRepository();
  }

  Future<void> fetchMyProfileData(BuildContext context) async {
    userProfileInfoModel = await _moreMyProfileRepository.getUserProfileInfoModel();

    if(userProfileInfoModel != null) {
      try {
        String url = '${WebservicePost.getServerUrl(context)}event/?event_type=profile&latest_event_only=true&user_id=${userProfileInfoModel.userId}';
        var response = await _moreMyProfileRepository.myProfileServiceCall(url, RequestMethod.GET);
        if (response is AppException) {
          myProfileSink.addError(response);
          networkSink.addError(response);
        } else {
          if (response != null && response is ResponseModel) {
            debugPrint('Id:' + response.id.toString());
            profileId = response.id;
            profileSelectedAnswerList = [];
            response.mobileEventDetails.forEach((element) {
              profileSelectedAnswerList.add(SelectedAnswers(questionTag: element.questionTag, answer: element.value));
            });

            SelectedAnswers? genderSelectedAnswers = profileSelectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.profileGenderTag);
            if(genderSelectedAnswers == null)
              profileSelectedAnswerList.add(SelectedAnswers(questionTag: Constant.profileGenderTag, answer: ''));

            /*SelectedAnswers emailSelectedAnswer = profileSelectedAnswerList.firstWhere((element) => element.questionTag == Constant.profileEmailTag, orElse: () => null);
            if(emailSelectedAnswer == null) {
              profileSelectedAnswerList.add(SelectedAnswers(questionTag: Constant.profileEmailTag, answer: userProfileInfoModel.email));
            }*/

            networkSink.add(Constant.success);
            myProfileSink.add(response);
            _responseModel = response;
          } else {
            myProfileSink.addError(Exception(Constant.somethingWentWrong));
            networkSink.addError(Exception(Constant.somethingWentWrong));
          }
        }
      } catch (e) {
        myProfileSink.addError(Exception(Constant.somethingWentWrong));
        networkSink.addError(Exception(Constant.somethingWentWrong));
      }
    } else {
      networkSink.add(Constant.success);
    }
  }

  ResponseModel get getResponseModel {
    return _responseModel!;
  }

  set setResponseModel(ResponseModel responseModel) {
    _responseModel = responseModel;
  }

  Future<void> editMyProfileServiceCall(BuildContext context) async {
    if(userProfileInfoModel != null && profileId != null) {
      try {
        String url = '${WebservicePost.getServerUrl(context)}event/$profileId';
        var response = await _moreMyProfileRepository.editMyProfileServiceCall(url, RequestMethod.POST, profileSelectedAnswerList, context);
        if (response is AppException) {
          myProfileSink.addError(response);
          networkSink.addError(response);
        } else {
          if (response != null && response is ResponseModel) {
            print('Id:' + response.id.toString());
            profileId = response.id;
            profileSelectedAnswerList = [];
            response.mobileEventDetails.forEach((element) {
              profileSelectedAnswerList.add(SelectedAnswers(questionTag: element.questionTag, answer: element.value));
            });

            SelectedAnswers? genderSelectedAnswers = profileSelectedAnswerList.firstWhereOrNull((element) => element.questionTag == Constant.profileGenderTag);
            if(genderSelectedAnswers == null)
              profileSelectedAnswerList.add(SelectedAnswers(questionTag: Constant.profileGenderTag, answer: ''));

            _updateUserProfileInfoInDatabase();

            if(_responseModel != null) {
              response.headacheList = _responseModel!.headacheList;
              response.medicationValues = _responseModel!.medicationValues;
              response.triggerValues = _responseModel!.triggerValues;
              response.triggerMedicationValues = _responseModel!.triggerMedicationValues;

              _responseModel = response;
            }

            networkSink.add(Constant.success);
            myProfileSink.add(response);
          } else {
            myProfileSink.addError(Exception(Constant.somethingWentWrong));
            networkSink.addError(Exception(Constant.somethingWentWrong));
          }
        }
      } catch (e) {
        myProfileSink.addError(Exception(Constant.somethingWentWrong));
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
    _myProfileStreamController.close();
    _networkStreamController.close();
  }

  void _updateUserProfileInfoInDatabase() {
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

  void setSelectedAnswerList(List<SelectedAnswers> selectedAnswerList, ResponseModel? triggerMedicationValues) {
    if(triggerMedicationValues != null) {
      triggerMedicationValues.mobileEventDetails.forEach((element) {
        if(element.value!.isNotEmpty) {
          List<String> splitList = element.value!.split('%@');
          String answer = jsonEncode(splitList);
          selectedAnswerList.add(SelectedAnswers(questionTag: element.questionTag, answer: answer));
        }
      });
    }
  }
}