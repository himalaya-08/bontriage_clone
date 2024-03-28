import 'package:mobile/providers/SignUpOnBoardProviders.dart';

class LocalQuestionnaire {
  String? eventType;
  String? questionnaires;
  String? selectedAnswers;

  LocalQuestionnaire(
      {this.eventType, this.questionnaires, this.selectedAnswers});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      SignUpOnBoardProviders.EVENT_TYPE: eventType,
      SignUpOnBoardProviders.QUESTIONNAIRES: questionnaires,
      SignUpOnBoardProviders.SELECTED_ANSWERS: selectedAnswers
    };
    return map;
  }

  LocalQuestionnaire.fromJson(Map<String,dynamic> map){
    eventType = map[SignUpOnBoardProviders.EVENT_TYPE];
    questionnaires = map[SignUpOnBoardProviders.QUESTIONNAIRES];
    selectedAnswers = map[SignUpOnBoardProviders.SELECTED_ANSWERS];
  }


}