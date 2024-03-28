import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/ResponseModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';

class MoreTriggersArgumentModel {
  String? eventId;
  ResponseModel? responseModel;
  List<Values>? triggerValues;
  List<SelectedAnswers>? selectedAnswerList;

  MoreTriggersArgumentModel({this.eventId, this.responseModel, this.triggerValues, this.selectedAnswerList});
}