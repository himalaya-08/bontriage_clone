
import 'package:mobile/providers/SignUpOnBoardProviders.dart';

class UserAddHeadacheLogModel {
  String? userId;
  String? selectedAnswers;

  UserAddHeadacheLogModel(
      {this.userId, this.selectedAnswers});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      SignUpOnBoardProviders.USER_ID: userId,
      SignUpOnBoardProviders.SELECTED_ANSWERS: selectedAnswers,
    };
    return map;
  }

  UserAddHeadacheLogModel.fromJson(Map<String,dynamic> map){
    userId = map[SignUpOnBoardProviders.USER_ID];
    selectedAnswers = map[SignUpOnBoardProviders.SELECTED_ANSWERS];
  }
}