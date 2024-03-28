import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/models/PartTwoOnBoardArgumentModel.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/OnBoardInformationScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PartTwoOnBoardMoveOnScreen extends StatefulWidget {
  @override
  _PartTwoOnBoardMoveOnScreenState createState() =>
      _PartTwoOnBoardMoveOnScreenState();
}

class _PartTwoOnBoardMoveOnScreenState
    extends State<PartTwoOnBoardMoveOnScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    Utils.saveUserProgress(0, Constant.onBoardMoveOnForNowEventStep);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: OnBoardInformationScreen(
          bubbleChatTextSpanList: [
            TextSpan(
                text: Constant.experienceTypesOfHeadaches,
                style: TextStyle(
                    height: 1.3,
                    fontSize: 16,
                    fontFamily: Constant.jostRegular,
                    color: Constant.bubbleChatTextView))
          ],
          isShowNextButton: false,
          chatText: Constant.experienceTypesOfHeadaches,
          bottomButtonText: Constant.moveOnForNow,
          bottomButtonFunction: () {
            moveToNextScreen();

          },
          isShowSecondBottomButton: true,
          secondBottomButtonText: Constant.addAnotherHeadache,
          secondBottomButtonFunction: () {
            Utils.saveUserProgress(0, Constant.secondEventStep);
            Navigator.pushReplacementNamed(
                context, Constant.partTwoOnBoardScreenRouter, arguments: PartTwoOnBoardArgumentModel(argumentName: Constant.clinicalImpressionShort1, isFromSignUp: true));
          },
          closeButtonFunction: () {
            Utils.navigateToExitScreen(context);
          },
        ),
      ),
    );
  }

  void moveToNextScreen() async {
    TextToSpeechRecognition.speechToText("");
    Navigator.pushReplacementNamed(
        context, Constant.prePartThreeOnBoardScreenRouter);
  }
}
