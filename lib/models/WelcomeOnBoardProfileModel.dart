import 'QuestionsModel.dart';

class WelcomeOnBoardProfileModel {
  String? initialQuestionnaire;
  List<Questionnaires>? questionnaires;

  WelcomeOnBoardProfileModel({this.initialQuestionnaire, this.questionnaires});

  WelcomeOnBoardProfileModel.fromJson(Map<String, dynamic> json) {
    initialQuestionnaire = json['initial_questionnaire'];

    if(json['initialQuestionnaire'] != null)
      initialQuestionnaire = json['initialQuestionnaire'];

    if (json['questionnaires'] != null) {
      questionnaires = <Questionnaires>[];
      json['questionnaires'].forEach((v) {
        questionnaires!.add(new Questionnaires.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['initial_questionnaire'] = this.initialQuestionnaire;
    if (this.questionnaires != null) {
      data['questionnaires'] =
          this.questionnaires!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Questionnaires {
  String? tag;
  String? precondition;
  String? next;
  String? initialQuestion;
  List<QuestionGroups>? questionGroups;
  String? updatedAt;

  Questionnaires(
      {this.tag,
        this.precondition,
        this.next,
        this.initialQuestion,
        this.questionGroups,
        this.updatedAt});

  Questionnaires.fromJson(Map<String, dynamic> json) {
    tag = json['tag'];
    precondition = json['precondition'];
    next = json['next'];
    initialQuestion = json['initial_question'];

    if(json['initialQuestion'] != null)
      initialQuestion = json['initialQuestion'];

    if (json['question_groups'] != null) {
      questionGroups = <QuestionGroups>[];
      json['question_groups'].forEach((v) {
        questionGroups!.add(new QuestionGroups.fromJson(v));
      });
    }

    if (json['questionGroups'] != null) {
      questionGroups = <QuestionGroups>[];
      json['questionGroups'].forEach((v) {
        questionGroups!.add(new QuestionGroups.fromJson(v));
      });
    }
    updatedAt = json['updated_at'];

    if(json['updatedAt'] != null) {
      updatedAt = json['updatedAt'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tag'] = this.tag;
    data['precondition'] = this.precondition;
    data['next'] = this.next;
    data['initial_question'] = this.initialQuestion;
    if (this.questionGroups != null) {
      data['question_groups'] =
          this.questionGroups!.map((v) => v.toJson()).toList();
    }
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class QuestionGroups {
  int? groupNumber;
  List<Questions>? questions;

  QuestionGroups({this.groupNumber, this.questions});

  QuestionGroups.fromJson(Map<String, dynamic> json) {
    groupNumber = json['group_number'];

    if(json['groupNumber'] != null)
      groupNumber = json['groupNumber'];

    if (json['questions'] != null) {
      questions = <Questions>[];
      json['questions'].forEach((v) {
        questions!.add(new Questions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['group_number'] = this.groupNumber;
    if (this.questions != null) {
      data['questions'] = this.questions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}



