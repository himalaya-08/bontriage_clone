import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/LocalQuestionnaire.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/WelcomeOnBoardProfileModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/repository/WelcomeOnBoardProfileRepository.dart';
import 'package:mobile/util/LinearListFilter.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';

class WelcomeOnBoardProfileBloc {
  WelcomeOnBoardProfileRepository _welcomeOnBoardProfileRepository = WelcomeOnBoardProfileRepository();
  StreamController<dynamic> _signUpFirstStepDataStreamController = StreamController();
  int count = 0;

  StreamSink<dynamic> get signUpFirstStepDataSink =>
      _signUpFirstStepDataStreamController.sink;

  Stream<dynamic> get albumDataStream =>
      _signUpFirstStepDataStreamController.stream;

  WelcomeOnBoardProfileBloc({this.count = 0}) {
    _signUpFirstStepDataStreamController = StreamController<dynamic>();
    _welcomeOnBoardProfileRepository = WelcomeOnBoardProfileRepository();
  }

  fetchSignUpFirstStepData(BuildContext context) async {
    try {
      var signUpFirstStepData =
          await _welcomeOnBoardProfileRepository.serviceCall('${WebservicePost.getServerUrl(context)}questionnaire', RequestMethod.POST);
      if (signUpFirstStepData is AppException) {
        signUpFirstStepDataSink.addError(signUpFirstStepData);
      } else {
        if(signUpFirstStepData is WelcomeOnBoardProfileModel) {
          if(signUpFirstStepData != null) {
            var filterQuestionsListData = LinearListFilter.getQuestionSeries(
                signUpFirstStepData.questionnaires![0].initialQuestion!,
                signUpFirstStepData.questionnaires![0].questionGroups![0]
                    .questions!);
            print(filterQuestionsListData);
            signUpFirstStepDataSink.add(filterQuestionsListData);
          } else {
            signUpFirstStepDataSink.addError(Exception(Constant.somethingWentWrong));
          }
        } else {
          signUpFirstStepDataSink.addError(Exception(Constant.somethingWentWrong));
        }
      }
    } catch (e) {
      signUpFirstStepDataSink.addError(Exception(Constant.somethingWentWrong));
      //  signUpFirstStepDataSink.add("Error");
      print(e.toString());
    }
  }

  sendSignUpFirstStepData(
      SignUpOnBoardSelectedAnswersModel
          signUpOnBoardSelectedAnswersModel, BuildContext context) async {
    try {
      var signUpFirstStepData = await _welcomeOnBoardProfileRepository
          .signUpProfileInfoObjectServiceCall(
              '${WebservicePost.getServerUrl(context)}event',
              RequestMethod.POST,
              signUpOnBoardSelectedAnswersModel, context);
      if (signUpFirstStepData is AppException) {
        //signUpFirstStepDataSink.add(signUpFirstStepData.toString());
      } else {
        /*   var filterQuestionsListData = LinearListFilter.getQuestionSeries(
            signUpFirstStepData.questionnaires[0].initialQuestion,
            signUpFirstStepData.questionnaires[0].questionGroups[0].questions);
        print(filterQuestionsListData);
        signUpFirstStepDataSink.add(filterQuestionsListData);*/
      }
    } catch (e) {
      //  signUpFirstStepDataSink.add("Error");
    }
  }

  void dispose() {
    _signUpFirstStepDataStreamController.close();
  }

  fetchDataFromLocalDatabase(
      List<LocalQuestionnaire> localQuestionnaireData) async {
    LocalQuestionnaire localQuestionnaireEventData = localQuestionnaireData[0];
    WelcomeOnBoardProfileModel welcomeOnBoardProfileModel =
        WelcomeOnBoardProfileModel();
    welcomeOnBoardProfileModel = WelcomeOnBoardProfileModel.fromJson(
        json.decode(localQuestionnaireEventData.questionnaires!));
    var filterQuestionsListData = LinearListFilter.getQuestionSeries(
        welcomeOnBoardProfileModel.questionnaires![0].initialQuestion!,
        welcomeOnBoardProfileModel
            .questionnaires![0].questionGroups![0].questions!);
    signUpFirstStepDataSink.add(filterQuestionsListData);

    return SignUpOnBoardSelectedAnswersModel.fromJson(
        jsonDecode(localQuestionnaireEventData.selectedAnswers!));
  }
}
