import 'package:flutter/material.dart';
import 'package:mobile/models/QuestionsModel.dart';

class LinearListFilter {
  static List<Questions> getQuestionSeries(
      String initialQuestion, List<Questions> questionGroup) {
    List<Questions> localListOfDataPriority = <Questions>[];
    var nextTag = initialQuestion;
    do {
      debugPrint(nextTag);
      Questions model = questionGroup.firstWhere((model) => model.tag == nextTag);
      localListOfDataPriority.add(model);
      nextTag = model.next!;
      questionGroup.remove(model);
    } while (nextTag != "");
    return localListOfDataPriority;
  }
}
