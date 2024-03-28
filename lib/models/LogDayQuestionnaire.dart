import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';

class LogDayQuestionnaire {
  String? userId;
  String? selectedAnswers;

  LogDayQuestionnaire(
      {this.userId, this.selectedAnswers});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      SignUpOnBoardProviders.USER_ID: userId,
      SignUpOnBoardProviders.SELECTED_ANSWERS: selectedAnswers,
    };
    return map;
  }

  LogDayQuestionnaire.fromJson(Map<String,dynamic> map){
    userId = map[SignUpOnBoardProviders.USER_ID];
    selectedAnswers = map[SignUpOnBoardProviders.SELECTED_ANSWERS];
  }
}