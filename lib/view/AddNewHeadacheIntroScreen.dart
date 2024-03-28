import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/providers/SignUpOnBoardProviders.dart';
import 'package:mobile/providers/UserNameInfo.dart';
import 'package:mobile/util/PhotoHero.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomRichTextWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ChatBubbleRightPointed.dart';

class AddNewHeadacheIntroScreen extends StatefulWidget {

  final String fromScreenRouter;
  AddNewHeadacheIntroScreen({required this.fromScreenRouter});

  @override
  _AddNewHeadacheIntroScreenState createState() =>
      _AddNewHeadacheIntroScreenState();
}

class _AddNewHeadacheIntroScreenState extends State<AddNewHeadacheIntroScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool isVolumeOn = false;
  late AnimationController _animationController;
  String _userName = '';

  String _speechToTextData = '';
  bool _shouldSpeak = false;
  bool _isScreenExited = false;

  late ScrollController _scrollController;

  ///Method to toggle volume on or off
  void _toggleVolume() async {
    setState(() {
      isVolumeOn = !isVolumeOn;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constant.chatBubbleVolumeState, isVolumeOn);
    var appConfig = AppConfig.of(context);

    if (appConfig?.buildFlavor == Constant.migraineMentorBuildFlavor)
      TextToSpeechRecognition.speechToText(_speechToTextData);
    else
      TextToSpeechRecognition.speechToText(_speechToTextData);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    WidgetsBinding.instance.addObserver(this);

    _animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    _animationController.forward();

    setVolumeIcon();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getUserProfileDetails();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      TextToSpeechRecognition.stopSpeech();
    } else if (state == AppLifecycleState.resumed) {
      if (_shouldSpeak && isVolumeOn && !_isScreenExited)
        TextToSpeechRecognition.speechToText(_speechToTextData);
    }
  }

  double _nextParaSpacingPixel = 22.0;

  @override
  Widget build(BuildContext context) {
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
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Image(
                            image: AssetImage(Constant.closeIcon),
                            width: 26,
                            height: 26,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
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
                          duration: Duration(milliseconds: 300),
                          child: Container(
                            height: 360,
                            child: FadeTransition(
                              opacity: _animationController,
                              child: Consumer<UserNameInfo>(
                                builder: (context, data, child) {
                                  _speechToTextData = 'Hello $_userName! ${Constant.addNewHeadacheIntroScreenTextView}';

                                  _shouldSpeak = true;
                                  if (_shouldSpeak && isVolumeOn && !_isScreenExited) {
                                    TextToSpeechRecognition.speechToText(_speechToTextData);
                                  }
                                  return RawScrollbar(
                                    controller: _scrollController,
                                    thickness: 5,
                                    radius: Radius.circular(5),
                                    thumbColor: Colors.black45,
                                    thumbVisibility: true,
                                    padding: const EdgeInsets.only(right: 4, top: 2, bottom: 2),
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      child: Container(
                                        padding: const EdgeInsets.all(15.0),
                                        child: CustomRichTextWidget(
                                          text: TextSpan(
                                            children: _buildTextData(_userName),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
                              _shouldSpeak = false;
                              _isScreenExited = true;
                              TextToSpeechRecognition.stopSpeech();
                              Navigator.pushNamed(context, Constant.headacheQuestionnaireDisclaimerScreenRouter, arguments: widget.fromScreenRouter);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: Color(0xffafd794),
                                borderRadius: BorderRadius.circular(30),
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
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    )
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

  void _getUserProfileDetails() async {
    var userProfileInfoData = await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    _userName = userProfileInfoData.profileName ?? '';
    Provider.of<UserNameInfo>(context, listen: false).updateUserName(userProfileInfoData.profileName!);
  }

  List<TextSpan> _buildTextData(String userName) {
    TextSpan bulletPoint = TextSpan(
        text: '•',
        style:  TextStyle(
            height: 1.3,
            fontSize: 20,
            fontFamily: Constant.jostMedium,
            color: Constant.bubbleChatTextView)
    );
    List<TextSpan> spannableTextViewList = [
      TextSpan(
        text: 'Hello $userName!\n\nTo customize the app for you, we need a short clinical assessment. It will take approximately 10 minutes to complete.\n\n',
        style: TextStyle(
          height: 1.3,
          fontSize: 16,
          fontFamily: Constant.jostRegular,
          color: Constant.bubbleChatTextView,
        ),
      ),
      TextSpan(
          children: [
            WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(left: _nextParaSpacingPixel),
                  child: CustomRichTextWidget(
                    text: TextSpan(
                        children: [
                          bulletPoint,
                          TextSpan(
                            text: ' For each question, please consider ',
                            style: TextStyle(
                              height: 1.3,
                              fontSize: 16,
                              fontFamily: Constant.jostRegular,
                              color: Constant.bubbleChatTextView,
                            ),
                          ),
                          TextSpan(
                            text: 'a single headache type you currently have, or have had in the past.',
                            style: TextStyle(
                              height: 1.3,
                              fontSize: 16,
                              fontFamily: Constant.jostMedium,
                              color: Constant.bubbleChatTextView,
                            ),
                          ),
                          TextSpan(
                            text: ' You can enter as many headache types as you wish by recording a new headache in the app.',
                            style: TextStyle(
                              height: 1.3,
                              fontSize: 16,
                              fontFamily: Constant.jostRegular,
                              color: Constant.bubbleChatTextView,
                            ),
                          ),
                        ]
                    ),
                  ),
                )
            )
          ]
      ),
      TextSpan(
          children: [
            WidgetSpan(
              child: Padding(
                padding: EdgeInsets.only(left: _nextParaSpacingPixel),
                child: CustomRichTextWidget(
                    text: TextSpan(
                        children: [
                          bulletPoint,
                          TextSpan(
                            text: ' You may review or edit your responses by using the "back" and "next" buttons at the bottom of each screen or update your answers from ',
                            style: TextStyle(
                              height: 1.3,
                              fontSize: 16,
                              fontFamily: Constant.jostRegular,
                              color: Constant.bubbleChatTextView,
                            ),
                          ),
                          TextSpan(
                            text: 'My Profile > My Headache Types',
                            style: TextStyle(
                              height: 1.3,
                              fontSize: 16,
                              fontFamily: Constant.jostMedium,
                              color: Constant.bubbleChatTextView,
                            ),
                          ),
                          TextSpan(
                            text: ' section of the app. Try to keep your assessment answers up-to-date by reviewing your headache types periodically.',
                            style: TextStyle(
                              height: 1.3,
                              fontSize: 16,
                              fontFamily: Constant.jostRegular,
                              color: Constant.bubbleChatTextView,
                            ),
                          ),
                        ]
                    )
                ),
              ),
            )
          ]
      ),
      TextSpan(
        text: '\n\nWhen you are ready to begin, please press the button below.',
        style: TextStyle(
          height: 1.3,
          fontSize: 16,
          fontFamily: Constant.jostRegular,
          color: Constant.bubbleChatTextView,
        ),
      ),
    ];
    return spannableTextViewList;
  }

  void setVolumeIcon() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isVolume = sharedPreferences.getBool(Constant.chatBubbleVolumeState) ?? false;
    setState(() {
      if (isVolume == null || isVolume) {
        isVolumeOn = true;
      } else {
        isVolumeOn = false;
      }
    });
  }
}