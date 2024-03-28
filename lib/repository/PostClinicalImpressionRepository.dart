import 'dart:convert';
import 'dart:io';

import '../models/SignUpOnBoardSelectedAnswersModel.dart';
import '../networking/AppException.dart';
import '../networking/NetworkService.dart';
import '../networking/RequestMethod.dart';
import 'package:flutter/foundation.dart';
import '../util/constant.dart';

class PostClinicalImpressionRepository {

  Future<dynamic> serviceCall(String url, RequestMethod requestMethod, SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel) async{
    try {
      //signUpOnBoardSelectedAnswersModel.selectedAnswers?.add(SelectedAnswers(questionTag: 'headache.typicalPain', answer: "4"));
      String payload = _getPayload(signUpOnBoardSelectedAnswersModel);

      //String payload = "{\"answers\":[{\"headache1.sided\":\"usuallybothsides\"},{\"headache1.restlessness\":\"Yes\"},{\"drowsiness\":\"decreasedmemory\"},{\"headache1.exp2During\":\"Worseningofpainorincreaseddiscomfortfromloudsounds\"},{\"comeOnWithin\":\"within10minutes\"},{\"experienceAfterHeadache\":\"Fatigue\"},{\"headache1.severityBeforeTreating\":1},{\"headache1.typicalPain\":5},{\"headache1.cluster\":\"No\"},{\"headache1.aveDaysPerMonth\":28},{\"headache1.haveAuraBoolean\":\"Yes\"},{\"headache1.chronic\":\"No\"},{\"headache1.exp1During\":[\"Dizziness/roomspinning(vertigo)\",\"Ringinginmyears\"]},{\"headache1.averageDurationWithoutTreatment\":\"1-3hours\"},{\"headache1.haveAura\":[\"zigzaglines\",\"numbnessortingling\"]},{\"paralysis\":\"No\"},{\"recentChanges\":\"No\"},{\"headache1.auraGap\":\"in1-20minutes\"},{\"headache1.painType\":\"boththrobbingandsteady\"},{\"agitated\":\"No\"},{\"headache1.lessThanThreeHours\":\"Yes\"},{\"headache1.number\":\"2-4\"},{\"headache1.averageDurationWithTreatment\":\"16-30minutes\"},{\"fever\":\"No\"},{\"headache1.location\":\"inoraroundmylefteye\"},{\"headache1.eventAssociatedWithFirstHeadache\":\"No\"},{\"headache1.aveEpisodesPerDay\":\"between1attackeveryotherdayand8perday\"},{\"startedRecently\":\"Yes\"},{\"headache1.awakens\":\"Yes\"},{\"headache1.auraPrecedesHeadache\":\"rarely\"},{\"headache1.sameLocation\":\"No\"},{\"howDisabledAfter\":\"none\"},{\"headache1.durationOnAwakening\":\"Yes\"},{\"headache1.trauma\":\"surgerywithanesthesia\"}],\"questionnaire_id\":\"12\"}";
      HttpClient httpClient = new HttpClient();
      HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
      request.headers.set('Content-type', 'application/json');
      request.headers.set('Accept', 'application/json');
      request.headers.set('Authorization', 'Basic dXNlcm5hbWU6cGFzc3dvcmQ=');
      request.add(utf8.encode(payload));
      HttpClientResponse httpResponse = await request.close();
      String reply = await httpResponse.transform(utf8.decoder).join();

      switch(httpResponse.statusCode) {
        case 200:
        case 201:
          break;
        case 404:
          return NotFoundException();
        case 400:
        case 401:
        case 409:
          return BadRequestException();
        case 500:
          return ServerResponseException();
        default:
          return FetchDataException();
      }

      var jsonReply = json.decode(reply);
      httpClient.close();

      return jsonReply;
    } catch(e) {
      return null;
    }
  }

  String _getPayload(SignUpOnBoardSelectedAnswersModel signUpOnBoardSelectedAnswersModel) {
    List<Map<String, dynamic>> answerMapList = [];

    signUpOnBoardSelectedAnswersModel.selectedAnswers?.forEach((selectedAnswerElement) {
      Map<String, dynamic> map = Map<String, dynamic>();

      try {
        var decodedJson = json.decode(selectedAnswerElement.answer ?? '');

        if (decodedJson is List<dynamic>) {
          List<String> valuesList = decodedJson.cast<String>();

          if (Constant.questionTagMap.containsKey(selectedAnswerElement.questionTag))
            map[Constant.questionTagMap[selectedAnswerElement.questionTag] ?? ''] = valuesList;
        } else {
          if (Constant.questionTagMap.containsKey(selectedAnswerElement.questionTag))
            map[Constant.questionTagMap[selectedAnswerElement.questionTag] ?? ''] = selectedAnswerElement.answer;
        }
      } on FormatException {
        if (Constant.questionTagMap.containsKey(selectedAnswerElement.questionTag))
          map[Constant.questionTagMap[selectedAnswerElement.questionTag] ?? ''] = selectedAnswerElement.answer;
      } catch (e) {
        debugPrint(e.toString());
      }

      if (Constant.questionTagMap.containsKey(selectedAnswerElement.questionTag))
        if (Constant.questionTagMap.containsKey(selectedAnswerElement.questionTag))
          answerMapList.add(map);
    });

    Map<String, dynamic> payloadMap = Map<String, dynamic>();
    payloadMap['answers'] = answerMapList;
    payloadMap['questionnaire_id'] = 12;

    return jsonEncode(payloadMap);
  }
}