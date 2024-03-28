import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/OnBoardInformationScreen.dart';

class SignUpOnBoardBubbleTextView extends StatefulWidget  {
  @override
  _StateSignUpOnBoardBubbleTextView createState() =>
      _StateSignUpOnBoardBubbleTextView();
}

class _StateSignUpOnBoardBubbleTextView
    extends State<SignUpOnBoardBubbleTextView> {
  TextStyle _textStyle = TextStyle(
      height: 1.3,
      fontSize: 16,
      fontFamily: Constant.jostRegular,
      color: Constant.bubbleChatTextView);

  TextStyle _highlightedTextStyle = TextStyle(
      height: 1.3,
      fontSize: 16,
      fontFamily: Constant.jostMedium,
      color: Constant.splashMigraineMentorTextColor);

  late List<List<TextSpan>> _questionList;

  static List<String> bubbleChatTextView = [
    Constant.welcomeMigraineMentorBubbleTextView,
    Constant.answeringTheNextBubbleTextView,
    Constant.letsStarted
  ];

  int _currentIndex = 0;
  bool _isButtonClicked = false;

  Future<bool> _onBackPressed() async {
    if(!_isButtonClicked) {
      _isButtonClicked = true;
      if (_currentIndex == 0) {
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

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    _questionList = [
      [
        TextSpan(
            text: 'Welcome to',
            style: _textStyle),
        TextSpan(
            text: ' MigraineMentor. ',
            style: _highlightedTextStyle,
        ),
        TextSpan(
            text: Constant.welcomeMigraineMentorTextView,
            style: _textStyle,
        )
      ],
      [
        TextSpan(
            text: 'MigraineMentor ',
            style: _highlightedTextStyle,
        ),
        TextSpan(
            text: Constant.migraineMentorHelpTextView,
            style: _textStyle,
        )
      ],
      [
        TextSpan(
            text: Constant.letsStarted,
            style: _textStyle,
        ),
      ]
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: OnBoardInformationScreen(
          isSpannable: true,
          chatText: bubbleChatTextView[_currentIndex],
          bubbleChatTextSpanList: _questionList[_currentIndex],
          isShowNextButton: _currentIndex != (_questionList.length - 1),
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
          bottomButtonText: Constant.startAssessment,
          bottomButtonFunction: () {
            Navigator.pushReplacementNamed(
                context, Constant.signUpOnBoardProfileQuestionRouter);
          },
          isShowSecondBottomButton: false,
          closeButtonFunction: () {
            Utils.navigateToExitScreen(context);
          },
        ),
      ),
    );
  }
}
