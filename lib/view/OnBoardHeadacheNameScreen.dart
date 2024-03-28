import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:mobile/view/on_board_chat_bubble.dart';

import 'CustomTextFormFieldWidget.dart';

class OnBoardHeadacheNameScreen extends StatefulWidget {
  @override
  _OnBoardHeadacheNameScreenState createState() =>
      _OnBoardHeadacheNameScreenState();
}

class _OnBoardHeadacheNameScreenState extends State<OnBoardHeadacheNameScreen> {
  bool isEndOfOnBoard = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Constant.backgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OnBoardChatBubble(
              isEndOfOnBoard: isEndOfOnBoard,
              chatBubbleText: Constant.greatWeAreDone,
              chatBubbleColor: Constant.chatBubbleGreen, textSpanList: [],
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Constant.chatBubbleHorizontalPadding,
                    vertical: 80),
                child: CustomTextFormFieldWidget(
                  style: TextStyle(
                      color: Constant.chatBubbleGreen,
                      fontSize: 15,
                      fontFamily: Constant.jostRegular),
                  cursorColor: Constant.chatBubbleGreen,
                  decoration: InputDecoration(
                    hintText: Constant.tapToType,
                    hintStyle: TextStyle(
                        color: Color.fromARGB(50, 175, 215, 148),
                        fontSize: 15,
                        fontFamily: Constant.jostMedium),
                    enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Constant.chatBubbleGreen)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Constant.chatBubbleGreen)),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Constant.chatBubbleHorizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BouncingWidget(
                    duration: Duration(milliseconds: 100),
                    scaleFactor: 1.5,
                    onPressed: () {},
                    child: Container(
                      width: 130,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Constant.chatBubbleGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: CustomTextWidget(
                          text: Constant.back,
                          style: TextStyle(
                              color: Constant.bubbleChatTextView,
                              fontSize: 15,
                              fontFamily: Constant.jostMedium),
                        ),
                      ),
                    ),
                  ),
                  BouncingWidget(
                    duration: Duration(milliseconds: 100),
                    scaleFactor: 1.5,
                    onPressed: () {
                      saveHeadacheNameInLocalDataBase();
                    },
                    child: Container(
                      width: 130,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Color(0xffafd794),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: CustomTextWidget(
                          text: Constant.next,
                          style: TextStyle(
                              color: Constant.bubbleChatTextView,
                              fontSize: 15,
                              fontFamily: Constant.jostMedium),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 114.5,
            ),
          ],
        ),
      ),
    );
  }

  void saveHeadacheNameInLocalDataBase()async {
    isEndOfOnBoard = true;
    TextToSpeechRecognition.speechToText("");
    Navigator.pushReplacementNamed(
        context,
        Constant
            .signUpOnBoardSecondStepPersonalizedHeadacheResultRouter);
  }

}
