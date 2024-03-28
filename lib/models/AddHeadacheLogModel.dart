import 'QuestionsModel.dart';

class AddHeadacheLogModel {
  AddHeadacheLogModel({
    required this.initialQuestionnaire,
    required this.questionnaires,
  });

  String initialQuestionnaire;
  List<Questionnaire> questionnaires;

  factory AddHeadacheLogModel.fromJson(Map<String, dynamic> json) => AddHeadacheLogModel(
    initialQuestionnaire: json["initial_questionnaire"],
    questionnaires: List<Questionnaire>.from(json["questionnaires"].map((x) => Questionnaire.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "initial_questionnaire": initialQuestionnaire,
    "questionnaires": List<dynamic>.from(questionnaires.map((x) => x.toJson())),
  };
}

class Questionnaire {
  Questionnaire({
    required this.tag,
    required this.precondition,
    required this.next,
    required this.initialQuestion,
    required this.questionGroups,
    required this.updatedAt,
  });

  String tag;
  String precondition;
  String next;
  String initialQuestion;
  List<QuestionGroup> questionGroups;
  DateTime updatedAt;

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
    "question_groups": List<dynamic>.from(questionGroups.map((x) => x.toJson())),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class QuestionGroup {
  QuestionGroup({
    required this.groupNumber,
    required this.questions,
  });

  int groupNumber;
  List<Questions> questions;

  factory QuestionGroup.fromJson(Map<String, dynamic> json) => QuestionGroup(
    groupNumber: json["group_number"],
    questions: List<Questions>.from(json["questions"].map((x) => Questions.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "group_number": groupNumber,
    "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
  };
}

