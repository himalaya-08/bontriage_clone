import 'package:flutter/material.dart';
import 'package:mobile/models/HomeScreenArgumentModel.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/OnBoardInformationScreen.dart';

class PostNotificationOnBoardScreen extends StatefulWidget {
  @override
  _PostNotificationOnBoardScreenState createState() =>
      _PostNotificationOnBoardScreenState();
}

class _PostNotificationOnBoardScreenState
    extends State<PostNotificationOnBoardScreen> {
  @override
  void initState() {
    super.initState();
    Utils.saveUserProgress(0, Constant.postNotificationEventStep);
  }

  List<List<TextSpan>> _questionList = [
    [
      TextSpan(
          text: Constant.greatFromHere,
          style: TextStyle(
              height: 1.3,
              fontSize: 16,
              fontFamily: Constant.jostRegular,
              color: Constant.bubbleChatTextView))
    ],
    [
      TextSpan(
          text: Constant.finallyNotification,
          style: TextStyle(
              height: 1.3,
              fontSize: 16,
              fontFamily: Constant.jostRegular,
              color: Constant.bubbleChatTextView))
    ]
  ];

  List<String> bubbleChatList = [
    Constant.greatFromHere,Constant.finallyNotification
  ];

  int _currentIndex = 0;
  bool _isButtonClicked = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: OnBoardInformationScreen(
          isShowNextButton: true,
          chatText: bubbleChatList[_currentIndex],
          nextButtonFunction: () {
            if (_currentIndex == _questionList.length - 1) {
              Utils.navigateToHomeScreen(context, false, homeScreenArgumentModel: HomeScreenArgumentModel(isFromOnBoard: true));
              print('Move to Next Screen');
            } else {
              setState(() {
                _currentIndex++;
              });
            }
          },
          bubbleChatTextSpanList: _questionList[_currentIndex],
          isShowSecondBottomButton: false,
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



}
