import 'package:mobile/providers/SignUpOnBoardProviders.dart';

class UserProgressDataModel {
  String? userId;
  String? step;
  String? questionTag;
  int? userScreenPosition;
  List<int>? backQuestionIndexList;

  UserProgressDataModel({this.userId, this.step, this.questionTag,this.userScreenPosition, this.backQuestionIndexList});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      SignUpOnBoardProviders.USER_ID: userId,
      SignUpOnBoardProviders.STEP: step,
      SignUpOnBoardProviders.QUESTION_TAG: questionTag,
      SignUpOnBoardProviders.USER_SCREEN_POSITION: userScreenPosition,
      SignUpOnBoardProviders.backQuestionIndexList: backQuestionIndexList,
    };
    return map;
  }

  UserProgressDataModel.fromMap(Map<String, dynamic> map){
    userId = map[SignUpOnBoardProviders.USER_ID];
    step = map[SignUpOnBoardProviders.STEP];
    questionTag = map[SignUpOnBoardProviders.QUESTION_TAG];
    userScreenPosition = map[SignUpOnBoardProviders.USER_SCREEN_POSITION];
    backQuestionIndexList = map[SignUpOnBoardProviders.backQuestionIndexList];
  }
}