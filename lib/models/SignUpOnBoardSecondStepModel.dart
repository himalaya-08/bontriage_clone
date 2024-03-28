
import 'dart:convert';

import 'QuestionsModel.dart';



class SignUpOnBoardSecondStepModel {
  SignUpOnBoardSecondStepModel({
    this.initialQuestionnaire,
    this.questionnaires,
  });

  String? initialQuestionnaire;
  List<Questionnaire>? questionnaires;

  factory SignUpOnBoardSecondStepModel.fromJson(Map<String, dynamic> json) => SignUpOnBoardSecondStepModel(
    initialQuestionnaire: json["initial_questionnaire"],
    questionnaires: List<Questionnaire>.from(json["questionnaires"].map((x) => Questionnaire.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "initial_questionnaire": initialQuestionnaire,
    "questionnaires": List<dynamic>.from(questionnaires!.map((x) => x.toJson())),
  };
}

class Questionnaire {
  Questionnaire({
    this.tag,
    this.precondition,
    this.next,
    this.initialQuestion,
    this.questionGroups,
    this.updatedAt,
  });

  String? tag;
  String? precondition;
  String? next;
  String? initialQuestion;
  List<QuestionGroup>? questionGroups;
  DateTime? updatedAt;

  factory Questionnaire.fromJson(Map<String, dynamic> json) => Questionnaire(
    tag: json["tag"],
    precondition: json["precondition"],
    next: json["next"],
    initialQuestion: json["initial_question"],
    questionGroups: List<QuestionGroup>.from(json["question_groups"].map((x) => QuestionGroup.fromJson(x))),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "tag": tag,
    "precondition": precondition,
    "next": next,
    "initial_question": initialQuestion,
    "question_groups": List<dynamic>.from(questionGroups!.map((x) => x.toJson())),
    "updated_at": updatedAt!.toIso8601String(),
  };
}

class QuestionGroup {
  QuestionGroup({
    this.groupNumber,
    this.questions,
  });

  int? groupNumber;
  List<Questions>? questions;

  factory QuestionGroup.fromJson(Map<String, dynamic> json) => QuestionGroup(
    groupNumber: json["group_number"],
    questions: List<Questions>.from(json["questions"].map((x) => Questions.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "group_number": groupNumber,
    "questions": List<dynamic>.from(questions!.map((x) => x.toJson())),
  };
}



enum QuestionType { SINGLE, NUMBER, INFO, MULTI }

final questionTypeValues = EnumValues({
  "info": QuestionType.INFO,
  "multi": QuestionType.MULTI,
  "number": QuestionType.NUMBER,
  "single": QuestionType.SINGLE
});

enum Text { EMPTY, CLINICAL_IMPRESSION }

final textValues = EnumValues({
  "Clinical Impression": Text.CLINICAL_IMPRESSION,
  "": Text.EMPTY
});

enum UiHints { EMPTY, MINLABEL_MAXLABEL }

final uiHintsValues = EnumValues({
  "": UiHints.EMPTY,
  "minlabel= ;maxlabel= ": UiHints.MINLABEL_MAXLABEL
});



class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap = Map();

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
