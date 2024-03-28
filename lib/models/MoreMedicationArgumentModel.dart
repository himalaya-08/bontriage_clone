import 'package:mobile/models/QuestionsModel.dart';
import 'package:mobile/models/ResponseModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';

class MoreMedicationArgumentModel {
  String? eventId;
  ResponseModel? responseModel;
  List<Values>? medicationValues;
  List<SelectedAnswers>? selectedAnswerList;

  MoreMedicationArgumentModel({this.eventId, this.responseModel, this.medicationValues, this.selectedAnswerList});
}