import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/OnBoardInformationScreen.dart';

class PostPartThreeOnBoardScreen extends StatefulWidget {
  @override
  _PostPartThreeOnBoardScreenState createState() =>
      _PostPartThreeOnBoardScreenState();
}

class _PostPartThreeOnBoardScreenState
    extends State<PostPartThreeOnBoardScreen> {
  List<String> _chatTextList = [
    Constant.qualityOfOurMentorShip,
    Constant.easyToLoseTrack,
  ];

  List<List<TextSpan>> _questionList = [
    [
      TextSpan(
          text: Constant.qualityOfOurMentorShip,
          style: TextStyle(
              height: 1.3,
              fontSize: 16,
              fontFamily: Constant.jostRegular,
              color: Constant.bubbleChatTextView))
    ],
    [
      TextSpan(
          text: Constant.easyToLoseTrack,
          style: TextStyle(
              height: 1.3,
              fontSize: 16,
              fontFamily: Constant.jostRegular,
              color: Constant.bubbleChatTextView))
    ]
  ];

  int _currentIndex = 0;
  bool _isButtonClicked = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    Utils.saveUserProgress(0, Constant.postPartThreeEventStep);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: OnBoardInformationScreen(
          isShowNextButton: _currentIndex != (_questionList.length - 1),
          bubbleChatTextSpanList: _questionList[_currentIndex],
          nextButtonFunction: () {
            if(!_isButtonClicked) {
              _isButtonClicked = true;
              setState(() {
                _currentIndex++;
              });
              Future.delayed(Duration(milliseconds: 350), () {
                _isButtonClicked = false;
              });
            }
          },
          chatText: _chatTextList[_currentIndex],
          bottomButtonText: Constant.setUpNotifications,
          bottomButtonFunction: () {
            Navigator.pushReplacementNamed(
                context, Constant.notificationScreenRouter);
          },
          isShowSecondBottomButton: _currentIndex == (_questionList.length - 1),
          secondBottomButtonText: Constant.notNow,
          secondBottomButtonFunction: () {
            TextToSpeechRecognition.speechToText("");
            Navigator.pushReplacementNamed(context, Constant.postNotificationOnBoardRouter);
          },
          closeButtonFunction: () {
            Utils.navigateToExitScreen(context);
          },
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    if(!_isButtonClicked) {
      _isButtonClicked = true;
      if(_currentIndex == 0) {
        Future.delayed(Duration(milliseconds: 350), () {
          _isButtonClicked = false;
        });
        return true;
      } else {
        setState(() {
          _currentIndex--;
        });
        Future.delayed(Duration(milliseconds: 350), () {
          _isButtonClicked = false;
        });
        return false;
      }
    } else {
      return false;
    }
  }
}
