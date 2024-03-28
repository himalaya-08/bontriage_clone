import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/constant.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'CustomTextWidget.dart';

class PartOneOnBoardBottomView extends StatefulWidget {
  final int currentPageIndex;
  final Function backButtonFunction;
  final Function nextButtonFunction;
  final double progressPercent;

  const PartOneOnBoardBottomView({Key? key, required this.currentPageIndex, required this.backButtonFunction, required this.nextButtonFunction, required this.progressPercent}) : super(key: key);
  @override
  _PartOneOnBoardBottomViewState createState() => _PartOneOnBoardBottomViewState();
}

class _PartOneOnBoardBottomViewState extends State<PartOneOnBoardBottomView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal:
              Constant.chatBubbleHorizontalPadding),
          child: Stack(
            children: [
              AnimatedPositioned(
                left: (widget.currentPageIndex != 0)
                    ? 0
                    : (MediaQuery.of(context).size.width -
                    190),
                duration: Duration(milliseconds: 250),
                child: AnimatedOpacity(
                  opacity:
                  (widget.currentPageIndex != 0) ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 250),
                  child: BouncingWidget(
                    duration: Duration(milliseconds: 100),
                    scaleFactor: 1.5,
                    onPressed: () {
                      widget.backButtonFunction();
                    },
                    child: Container(
                      width: 130,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Color(0xffafd794),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: CustomTextWidget(
                          text: Constant.back,
                          style: TextStyle(
                            color:
                            Constant.bubbleChatTextView,
                            fontSize: 14,
                            fontFamily: Constant.jostMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: BouncingWidget(
                  duration: Duration(milliseconds: 100),
                  scaleFactor: 1.5,
                  onPressed: () {
                    TextToSpeechRecognition.stopSpeech();
                    widget.nextButtonFunction();
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
                          fontSize: 14,
                          fontFamily: Constant.jostMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 36,
        ),
        if (widget.currentPageIndex != 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 23),
            child: LinearPercentIndicator(
              animation: true,
              lineHeight: 8.0,
              animationDuration: 200,
              animateFromLastPercent: true,
              percent: widget.progressPercent,
              backgroundColor: Constant.chatBubbleGreenBlue,
              barRadius: Radius.circular(10),
              progressColor: Constant.chatBubbleGreen,
            ),
          )
        else
          SizedBox(
            height: 12.5,
          ),
        SizedBox(
          height: 10.5,
        ),
        if (widget.currentPageIndex != 0)
          Container(
            padding: EdgeInsets.symmetric(
                horizontal:
                Constant.chatBubbleHorizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomTextWidget(
                  text: 'PART 1 OF 3',
                  style: TextStyle(
                      color: Constant.chatBubbleGreen,
                      fontSize: 13,
                      fontFamily: Constant.jostMedium),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 14,
          ),
        SizedBox(
          height: 46,
        )
      ],
    );
  }
}
