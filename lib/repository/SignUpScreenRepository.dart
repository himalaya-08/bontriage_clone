import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/models/SignUpScreenOnBoardModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';

class SignUpScreenRepository {
  String? url;

  Future<dynamic> serviceCall(String url, RequestMethod requestMethod) async {
    var album;
    try {
      var response = await NetworkService.getRequest(url, requestMethod).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (Exception) {
      return album;
    }
  }

  Future<dynamic> signUpServiceCall(String url, RequestMethod requestMethod,
      List<SelectedAnswers> selectedAnswerListData, String emailValue, String passwordValue, bool isTermConditionCheck, bool isEmailMarkCheck) async {
    try {
      var response = await NetworkService(
          url, requestMethod, _setUserSignUpPayload(selectedAnswerListData,emailValue,passwordValue,isTermConditionCheck,isEmailMarkCheck))
          .serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<dynamic> createAndDeletePushNotificationServiceCall(String url, RequestMethod requestMethod, String requestBody) async {
    try {
      var response = await NetworkService(url, requestMethod,requestBody).serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return null;
    }
  }

/*  Future<dynamic> signUpServiceCall(String url, RequestMethod requestMethod,
      List<SelectedAnswers> selectedAnswerListData, String emailValue, String passwordValue, bool isTermConditionCheck, bool isEmailMarkCheck) async {
    var album;
    try {
      var response = await NetworkService(
              url, requestMethod, _setUserSignUpPayload(selectedAnswerListData,emailValue,passwordValue,isTermConditionCheck,isEmailMarkCheck))
          .serviceCall();
      if (response is AppException) {
        return response;
      } else {
        return response;
      }
    } catch (Exception) {
      return album;
    }
  }*/

  String _setUserSignUpPayload(List<SelectedAnswers> selectedAnswers, String emailValue, String passwordValue, bool isTermConditionCheck, bool isEmailMarkCheck) {
    SignUpScreenOnBoardModel signUpScreenOnBoardModel =
        SignUpScreenOnBoardModel();

    SelectedAnswers ageValue = selectedAnswers
        .firstWhere((model) => model.questionTag == "profile.age");
    SelectedAnswers genderValue = selectedAnswers
        .firstWhere((model) => model.questionTag == "profile.sex");
    SelectedAnswers nameValue = selectedAnswers
        .firstWhere((model) => model.questionTag == "profile.firstname");

    signUpScreenOnBoardModel.email = emailValue;
    signUpScreenOnBoardModel.age = ageValue.answer;
    signUpScreenOnBoardModel.firstName = nameValue.answer;
    signUpScreenOnBoardModel.lastName = "";
    signUpScreenOnBoardModel.location = "";
    signUpScreenOnBoardModel.notificationKey = "";
    signUpScreenOnBoardModel.password = passwordValue;
    signUpScreenOnBoardModel.sex = genderValue.answer;
    signUpScreenOnBoardModel.termsAndPolicy = isTermConditionCheck;
    signUpScreenOnBoardModel.emailNotification = isEmailMarkCheck;

    return jsonEncode(signUpScreenOnBoardModel);
  }
}
