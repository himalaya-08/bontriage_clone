import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/util/PhotoHero.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomRichTextWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ChatBubbleRightPointed.dart';

class ProfileComplete extends StatefulWidget {
  @override
  _ProfileCompleteState createState() => _ProfileCompleteState();
}

class _ProfileCompleteState extends State<ProfileComplete>
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
    var appConfig = AppConfig.of(context);

    if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
      TextToSpeechRecognition.speechToText(Constant.profileCompleteTextView);
    else
      TextToSpeechRecognition.speechToText(Constant.tonixTextSpeechProfileCompleteTextView);
  }

  List<TextSpan>? _spannableTextViewList;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    _animationController!.forward();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 200), () {
        var appConfig = AppConfig.of(context);

        if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
          TextToSpeechRecognition.speechToText(Constant.profileCompleteTextView);
        else
          TextToSpeechRecognition.speechToText(Constant.tonixTextSpeechProfileCompleteTextView);
      });
    });
    setVolumeIcon();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.detached || state == AppLifecycleState.inactive){
      TextToSpeechRecognition.stopSpeech();
    }else if(state == AppLifecycleState.resumed){
      var appConfig = AppConfig.of(context);

      if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
        TextToSpeechRecognition.speechToText(Constant.profileCompleteTextView);
      else
        TextToSpeechRecognition.speechToText(Constant.tonixTextSpeechProfileCompleteTextView);
    }
  }

  @override
  Widget build(BuildContext context) {
    var appConfig = AppConfig.of(context);

    if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor) {
      _spannableTextViewList = [
        TextSpan(
            text: Constant.profileCompleteThatNow,
            style: TextStyle(
                height: 1.3,
                fontSize: 16,
                fontFamily: Constant.jostRegular,
                color: Constant.bubbleChatTextView)),
        TextSpan(
            text: ' MigraineMentor! ',
            style: TextStyle(
                height: 1.3,
                fontSize: 16,
                fontFamily: Constant.jostMedium,
                color: Constant.splashMigraineMentorTextColor)),
        TextSpan(
            text: Constant.profileCompleteCommentsSignedInfo,
            style: TextStyle(
                height: 1.3,
                fontSize: 16,
                fontFamily: Constant.jostRegular,
                color: Constant.bubbleChatTextView))
      ];
    } else {
      _spannableTextViewList = [
        TextSpan(
            text: 'Thank you for registering for the',
            style: TextStyle(
                height: 1.3,
                fontSize: 16,
                fontFamily: Constant.jostRegular,
                color: Constant.bubbleChatTextView)),
        TextSpan(
            text: ' Tonix eDiary app! ',
            style: TextStyle(
                height: 1.3,
                fontSize: 16,
                fontFamily: Constant.jostMedium,
                color: Constant.splashMigraineMentorTextColor)),
        TextSpan(
          text: Constant.tonixProfileCompleteTextView,
          style: TextStyle(
              height: 1.3,
              fontSize: 16,
              fontFamily: Constant.jostRegular,
              color: Constant.bubbleChatTextView),
        ),
        TextSpan(
          text: 'Settings',
          style: TextStyle(
              height: 1.3,
              fontSize: 16,
              fontFamily: Constant.jostMedium,
              fontStyle: FontStyle.italic,
              color: Constant.bubbleChatTextView),
        ),
        TextSpan(
          text: ' menu) to best suit your daily schedule.',
          style: TextStyle(
              height: 1.3,
              fontSize: 16,
              fontFamily: Constant.jostRegular,
              color: Constant.bubbleChatTextView),
        ),
      ];
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            decoration: Constant.backgroundBoxDecoration,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextWidget(
                      text: Constant.thankYouProfile,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Constant.chatBubbleGreen,
                          fontSize: 17,
                          fontFamily: Constant.jostMedium),
                    ),
                    SizedBox(height: 30),
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
                        painter:
                            ChatBubbleRightPointedPainter(Constant.chatBubbleGreen),
                        child: AnimatedSize(
                          duration: Duration(milliseconds: 300),
                          child: Container(
                              padding: const EdgeInsets.all(15.0),
                              child: FadeTransition(
                                opacity: _animationController!,
                                child: CustomRichTextWidget(
                                  text: TextSpan(
                                    children: _spannableTextViewList,
                                  ),
                                ),
                              ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 80,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: BouncingWidget(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: Color(0xffafd794),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: CustomTextWidget(
                                  text: Constant.finish,
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
                    SizedBox(height: 10,)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    TextToSpeechRecognition.stopSpeech();
    super.dispose();
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
