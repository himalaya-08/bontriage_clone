import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/ChatBubbleRightPointed.dart';
import 'package:mobile/view/CustomRichTextWidget.dart';
import '../util/PhotoHero.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CustomTextWidget.dart';

class OnBoardInformationScreen extends StatefulWidget {
  final bool isShowNextButton;
  final bool isSpannable;
  final List<TextSpan> bubbleChatTextSpanList;
  final String chatText;
  final String? bottomButtonText;
  Function? nextButtonFunction = (){};
  final Function? bottomButtonFunction;
  final isShowSecondBottomButton;
  final String? secondBottomButtonText;
  final Function? secondBottomButtonFunction;
  final void Function()? closeButtonFunction;
  final bool isShowCloseButton;

   OnBoardInformationScreen(
      {Key? key,
      this.isSpannable = false,
      required this.bubbleChatTextSpanList,
      required this.isShowNextButton,
      required this.chatText,
      this.bottomButtonText,
      this.bottomButtonFunction,
      this.nextButtonFunction,
      this.isShowSecondBottomButton,
      this.secondBottomButtonText,
      this.secondBottomButtonFunction,
      this.closeButtonFunction,
      this.isShowCloseButton = true})
      : super(key: key);

  @override
  _OnBoardInformationScreenState createState() =>
      _OnBoardInformationScreenState();
}

class _OnBoardInformationScreenState extends State<OnBoardInformationScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool isVolumeOn = false;
  AnimationController? _animationController;

  ///Method to toggle volume on or off
  void _toggleVolume() async {
    setState(() {
      isVolumeOn = !isVolumeOn;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constant.chatBubbleVolumeState, isVolumeOn);
    TextToSpeechRecognition.speechToText(widget.chatText);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setVolumeIcon();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    _animationController!.forward();
    TextToSpeechRecognition.speechToText(widget.chatText);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      TextToSpeechRecognition.stopSpeech();
    } else if (state == AppLifecycleState.resumed) {
      TextToSpeechRecognition.speechToText(widget.chatText);
    }
  }

  @override
  void didUpdateWidget(OnBoardInformationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_animationController!.isAnimating) {
      _animationController!.reset();
      _animationController!.forward();
    }
    if (isVolumeOn) TextToSpeechRecognition.speechToText(widget.chatText);
  }

  @override
  void dispose() {
    _animationController!.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> _onBackPressed() async {
    //Utils.navigateToExitScreen(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Constant.backgroundBoxDecoration,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: widget.isShowCloseButton,
                            child: GestureDetector(
                              onTap: widget.closeButtonFunction,
                              child: Image(
                                image: AssetImage(Constant.closeIcon),
                                width: 26,
                                height: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 80,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: GestureDetector(
                              onTap: _toggleVolume,
                              child: AnimatedCrossFade(
                                duration: Duration(milliseconds: 250),
                                firstChild: Image(
                                  image: AssetImage(Constant.volumeOn),
                                  width: 20,
                                  height: 20,
                                ),
                                secondChild: Image(
                                  image: AssetImage(Constant.volumeOff),
                                  width: 20,
                                  height: 20,
                                ),
                                crossFadeState: isVolumeOn
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Center(
                                  child: Container(
                            margin: EdgeInsets.only(right: 20),
                            child: PhotoHero(
                              photo: Constant.userAvatar,
                              width: 90,
                            ),
                          ))),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: ChatBubbleRightPointed(
                          painter: ChatBubbleRightPointedPainter(
                              Constant.chatBubbleGreen),
                          child: AnimatedSize(
                            //vsync: this,
                            duration: Duration(milliseconds: 300),
                            child: Container(
                                padding: const EdgeInsets.all(15.0),
                                child: FadeTransition(
                                  opacity: _animationController!,
                                  child: CustomRichTextWidget(
                                    text: TextSpan(
                                      children: widget.bubbleChatTextSpanList,
                                    ),
                                  ),
                                )),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Visibility(
                        visible: widget.isShowNextButton,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            BouncingWidget(
                              onPressed: () {
                                TextToSpeechRecognition.stopSpeech();
                                widget.nextButtonFunction!();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Constant.chatBubbleGreen,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: CustomTextWidget(
                                    text: Constant.next,
                                    style: TextStyle(
                                        color: Constant.bubbleChatTextView,
                                        fontSize: 14,
                                        fontFamily: Constant.jostMedium),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: !widget.isShowNextButton,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: BouncingWidget(
                                onPressed: () {
                                  TextToSpeechRecognition.stopSpeech();
                                  widget.bottomButtonFunction!();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 13),
                                  decoration: BoxDecoration(
                                    color: Color(0xffafd794),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: CustomTextWidget(
                                      text: widget.bottomButtonText ??
                                          Constant.blankString,
                                      style: TextStyle(
                                          color: Constant.bubbleChatTextView,
                                          fontSize: 15,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      Visibility(
                        visible: widget.isShowSecondBottomButton,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: BouncingWidget(
                                onPressed: () {
                                  if(widget.secondBottomButtonText == Constant.saveAndFinishLater){
                                    Utils.sendAnalyticsEvent(Constant.assessmentPartiallyCompleted, {}, context);
                                  }
                                  TextToSpeechRecognition.stopSpeech();
                                  widget.secondBottomButtonFunction!();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 13),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1.3,
                                        color: Constant.chatBubbleGreen),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: CustomTextWidget(
                                      text: widget.secondBottomButtonText ??
                                          Constant.blankString,
                                      style: TextStyle(
                                          color: Constant.chatBubbleGreen,
                                          fontSize: 15,
                                          fontFamily: Constant.jostMedium),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setVolumeIcon() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? isVolume = sharedPreferences.getBool(Constant.chatBubbleVolumeState);
    setState(() {
      if (isVolume == null || isVolume) {
        isVolumeOn = true;
      } else {
        isVolumeOn = false;
      }
    });
  }
}
