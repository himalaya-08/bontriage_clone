import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile/util/PhotoHero.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomRichTextWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChatBubbleLeftPointed.dart';
import 'CustomScrollBar.dart';
import 'CustomTextWidget.dart';

class TutorialChatBubble extends StatefulWidget {
  final String chatBubbleText;
  final List<InlineSpan> textSpanList;
  final int currentIndex;
  final Function backButtonFunction;
  final Function nextButtonFunction;
  final bool isShowBackNextButton;
  final bool isFromTrends;
  final bool shouldSpeak;
  final int? chatTextListLength;

  const TutorialChatBubble(
      {Key? key,
      required this.chatBubbleText,
      required this.textSpanList,
      this.currentIndex = 0,
      required this.backButtonFunction,
      required this.nextButtonFunction,
      this.isShowBackNextButton = true,
      this.isFromTrends = false,
      this.shouldSpeak = true,
      this.chatTextListLength})
      : super(key: key);

  @override
  _TutorialChatBubbleState createState() => _TutorialChatBubbleState();
}

class _TutorialChatBubbleState extends State<TutorialChatBubble>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController? _animationController;
  ScrollController? _scrollController;
  bool isVolumeOn = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();

    _animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animationController!.forward();
    setVolumeIcon();

    TextToSpeechRecognition.speechToText(widget.chatBubbleText);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      TextToSpeechRecognition.stopSpeech();
    } else if (state == AppLifecycleState.resumed) {
      TextToSpeechRecognition.speechToText(widget.chatBubbleText);
    }
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

  @override
  void dispose() {
    _animationController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    TextToSpeechRecognition.stopSpeech();
    super.dispose();
  }

  @override
  void didUpdateWidget(TutorialChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_animationController!.isAnimating) {
      _animationController?.reset();
      _animationController?.forward();
    }

    if (isVolumeOn) {
      TextToSpeechRecognition.speechToText(widget.chatBubbleText);
    }

    try {
      _scrollController?.animateTo(1,
          duration: Duration(milliseconds: 150), curve: Curves.easeIn);
      Future.delayed(Duration(milliseconds: 150), () {
        _scrollController?.jumpTo(0);
      });
    } catch (e) {
      print(e);
    }
  }

  ///Method to toggle volume on or off
  void _toggleVolume() async {
    setState(() {
      isVolumeOn = !isVolumeOn;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constant.chatBubbleVolumeState, isVolumeOn);
    TextToSpeechRecognition.speechToText(widget.chatBubbleText);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: Constant.chatBubbleHorizontalPadding, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhotoHero(
                  photo: Constant.userAvatar,
                  width: 60,
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
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
              ],
            ),
            SizedBox(
              height: 10,
            ),
            ChatBubbleLeftPointed(
              painter: ChatBubblePainter(Constant.oliveGreen),
              child: AnimatedSize(
                duration: Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  child: FadeTransition(
                    opacity: _animationController!,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: Constant.chatBubbleMaxHeight,
                      ),
                      child: CustomScrollBar(
                        controller: _scrollController!,
                        isAlwaysShown: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: CustomRichTextWidget(
                              text: TextSpan(
                                children: widget.textSpanList,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Stack(
              children: [
                AnimatedPositioned(
                  left: (widget.currentIndex != 0)
                      ? 0
                      : (MediaQuery.of(context).size.width - 190),
                  duration: Duration(milliseconds: 250),
                  child: AnimatedOpacity(
                    opacity: (widget.currentIndex != 0) ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 250),
                    child: Visibility(
                      visible: widget.isShowBackNextButton,
                      child: BouncingWidget(
                        duration: Duration(milliseconds: 100),
                        scaleFactor: 1.5,
                        onPressed: () {
                          TextToSpeechRecognition.stopSpeech();
                          widget.backButtonFunction();
                        },
                        child: Container(
                          width: 120,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Color(0xffafd794),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: CustomTextWidget(
                              text: Constant.back,
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
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Visibility(
                    visible: widget.isShowBackNextButton,
                    child: BouncingWidget(
                      duration: Duration(milliseconds: 100),
                      scaleFactor: 1.5,
                      onPressed: () {
                        TextToSpeechRecognition.stopSpeech();
                        widget.nextButtonFunction();
                      },
                      child: Container(
                        width: 120,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color(0xffafd794),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: CustomTextWidget(
                            text: widget.chatTextListLength != null
                                ? (widget.currentIndex ==
                                        widget.chatTextListLength! - 1)
                                    ? 'Got it!'
                                    : Constant.next
                                : Constant.next,
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
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
