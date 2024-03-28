import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/OnBoardInformationScreen.dart';

class OnBoardHeadacheInfoScreen extends StatefulWidget {
  @override
  _OnBoardHeadacheInfoScreenState createState() =>
      _OnBoardHeadacheInfoScreenState();
}

class _OnBoardHeadacheInfoScreenState extends State<OnBoardHeadacheInfoScreen> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    Utils.saveUserProgress(0, Constant.headacheInfoEventStep);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: OnBoardInformationScreen(
          bubbleChatTextSpanList: [
            TextSpan(
                text: Constant.letsBeginBySeeing,
                style: TextStyle(
                    height: 1.3,
                    fontSize: 15,
                    fontFamily: Constant.jostRegular,
                    color: Constant.bubbleChatTextView))
          ],
          isShowNextButton: true,
          chatText: Constant.letsBeginBySeeing,
          nextButtonFunction: () {
            sendToNextScreen();
          },
          isShowSecondBottomButton: false,
          closeButtonFunction: () {
            Utils.navigateToExitScreen(context);
          },
        ),
      ),
    );
  }

  void sendToNextScreen()async{
    TextToSpeechRecognition.speechToText("");
    Navigator.pushReplacementNamed(
        context, Constant.partOneOnBoardScreenTwoRouter);
  }

  Future<bool> _onBackPressed() async{
    return true;
  }
}
