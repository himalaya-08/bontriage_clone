import 'package:flutter/cupertino.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';

class PartTwoOnBoardArgumentModel {
  String? eventId;
  List<SelectedAnswers>? selectedAnswersList;
  String? argumentName;

  bool isFromMoreScreen; ///Re-complete initial assessment
  bool isFromHeadacheTypeScreen; ///moreHeadacheType screen
  bool isFromSignUp;

  String? fromScreenRouter;

  PartTwoOnBoardArgumentModel({this.eventId, this.selectedAnswersList, this.argumentName, this.isFromMoreScreen = false, this.isFromHeadacheTypeScreen = false, this.isFromSignUp = false, this.fromScreenRouter});
}