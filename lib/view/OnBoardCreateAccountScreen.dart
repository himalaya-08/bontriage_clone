import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/OnBoardInformationScreen.dart';

class OnBoardCreateAccount extends StatefulWidget {
  @override
  _OnBoardCreateAccountState createState() => _OnBoardCreateAccountState();
}

class _OnBoardCreateAccountState extends State<OnBoardCreateAccount> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    Utils.saveUserProgress(0, Constant.createAccountEventStep);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnBoardInformationScreen(
        bubbleChatTextSpanList: [
          TextSpan(
              text: Constant.beforeContinuing,
              style: TextStyle(
                  height: 1.3,
                  fontSize: 16,
                  fontFamily: Constant.jostRegular,
                  color: Constant.bubbleChatTextView))
        ],
        isShowNextButton: false,
        chatText: Constant.beforeContinuing,
        bottomButtonText: Constant.createAccount,
        bottomButtonFunction: () {
          sendToNextScreen();

        },
        isShowSecondBottomButton: false,
        closeButtonFunction: () {
          Utils.navigateToExitScreen(context);
        },
      ),
    );
  }

  void sendToNextScreen() async {
    TextToSpeechRecognition.speechToText("");
    Navigator.pushReplacementNamed(
        context, Constant.onBoardingScreenSignUpRouter);
  }
}
