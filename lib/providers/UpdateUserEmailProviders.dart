import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mobile/models/SignUpScreenOnBoardModel.dart';
import 'package:mobile/networking/AppException.dart';
import 'package:mobile/networking/NetworkService.dart';
import 'package:mobile/networking/RequestMethod.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/util/WebservicePost.dart';
import 'package:mobile/util/constant.dart';

class UpdateUserEmailProvider extends ChangeNotifier {
  void initNetworkStreamController() {
    _networkStreamController?.close();
    _networkStreamController = StreamController<dynamic>();
  }

  void enterSomeDummyData() {
    networkSink?.add(Constant.loading);
  }

  void dispose() {
    _networkStreamController?.close();
  }

  String? errorMessage;

  StreamController<dynamic>? _networkStreamController;

  Stream<dynamic>? get networkStream => _networkStreamController?.stream;

  StreamSink<dynamic>? get networkSink => _networkStreamController?.sink;

  Future<dynamic> changeUserEmail(String email, String mobileUserId,
      RequestMethod requestMethod, BuildContext context) async {
    Map<String, dynamic> requestBody = {
      'mobile_user_id': mobileUserId,
      'updatedEmail': email
    };
    try {
      var response = await NetworkService.getRequest(
              '${WebservicePost.getServerUrl(context)}user/UpdateEmail?mobile_user_id=$mobileUserId&updatedEmail=$email',
              requestMethod)
          .serviceCall();
      if (response is AppException) {
        errorMessage = Constant.blankString;
        notifyListeners();
        networkSink?.addError(response);
      } else {
        var json = jsonDecode(response);
        print('---------------------------> $json');

        if (json['message_type'] == null) {
          if (json['email'] != null || json['email'] != Constant.blankString) {
            String email = json['email'];
            var userProfileInfoData =
                await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
            userProfileInfoData.email = email;
            await SignUpOnBoardProviders.db
                .updateUserProfileInfo(userProfileInfoData);
            errorMessage = null;
            notifyListeners();
            networkSink?.add(Constant.success);
            return response;
          } else {
            errorMessage = Constant.signUpEmilFieldAlertMessage;
            notifyListeners();
            return errorMessage;
          }
        } else {
          errorMessage = Constant.duplicateEmailAlertMessage;
          notifyListeners();
          networkSink?.add(Constant.success);
          return errorMessage;
        }
      }
    } catch (e) {
      errorMessage = Constant.somethingWentWrong;
      notifyListeners();
      //networkSink.addError(Exception(Constant.somethingWentWrong));
      return Constant.somethingWentWrong;
    }
  }
}
