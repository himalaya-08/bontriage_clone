import 'ResponseModel.dart';
import 'SignUpOnBoardSelectedAnswersModel.dart';

class MoreGeneralProfileSettingsArgumentModel {
  List<SelectedAnswers>? selectedAnswerList;
  int? profileId;
  ResponseModel? responseModel;

  MoreGeneralProfileSettingsArgumentModel({this.selectedAnswerList, this.profileId, this.responseModel});
}