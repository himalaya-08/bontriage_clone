import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/AppConfig.dart';
import 'package:mobile/models/PartTwoOnBoardArgumentModel.dart';
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

class HeadacheQuestionnaireDisclaimerScreen extends StatefulWidget {

  final String fromScreenRouter;
  HeadacheQuestionnaireDisclaimerScreen({required this.fromScreenRouter});

  @override
  _HeadacheQuestionnaireDisclaimerScreenState createState() =>
      _HeadacheQuestionnaireDisclaimerScreenState();
}

class _HeadacheQuestionnaireDisclaimerScreenState extends State<HeadacheQuestionnaireDisclaimerScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  ScrollController _controller = ScrollController();

  bool isVolumeOn = false;
  late AnimationController _animationController;
  String _userName = '';

  String _speechToTextData = '';
  bool _shouldSpeak = false;
  bool _isScreenExited = false;

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
    _getUserProfileDetails();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    WidgetsBinding.instance.addObserver(this);

    _animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    _animationController.forward();

    setVolumeIcon();
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
    _speechToTextData = Constant.headacheQuestionnaireDisclaimerTextView;

    _shouldSpeak = true;
    if (_shouldSpeak &&
        isVolumeOn &&
        !_isScreenExited) {
      TextToSpeechRecognition.speechToText(
          _speechToTextData);
    }

    return Scaffold(
      body: Container(
        decoration: Constant.backgroundBoxDecoration,
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: ChangeNotifierProvider(
              create: (_) => CheckboxToggleInfo(),
              child: Consumer<CheckboxToggleInfo>(
                  builder: (context, data, child) {
                    return Column(
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
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                child: ChatBubbleRightPointed(
                                  painter: ChatBubbleRightPointedPainter(
                                      Constant.chatBubbleGreen),
                                  child: AnimatedSize(
                                    duration: Duration(milliseconds: 300),
                                    child: Container(
                                      height: 330,
                                      child: FadeTransition(
                                        opacity: _animationController,
                                        child: Consumer<UserNameInfo>(
                                          builder: (context, data, child) {
                                            return RawScrollbar(
                                              controller: _controller,
                                              thickness: 5,
                                              radius: Radius.circular(5),
                                              thumbColor: Colors.black45,
                                              thumbVisibility: true,
                                              padding: const EdgeInsets.only(
                                                  right: 4, top: 2, bottom: 2),
                                              child: SingleChildScrollView(
                                                controller: _controller,
                                                child: Container(
                                                  padding: const EdgeInsets.all(15.0),
                                                  child: CustomRichTextWidget(
                                                    text: TextSpan(
                                                      children:
                                                      _buildTextData(_userName),
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
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Theme(
                              data: ThemeData(
                                  unselectedWidgetColor: Constant.editTextBoarderColor
                              ),
                              child: Checkbox(
                                value: data.getCheckboxToggle(),
                                checkColor: Constant.bubbleChatTextView,
                                activeColor: Constant.chatBubbleGreen,
                                focusColor: Constant.chatBubbleGreen,
                                onChanged: (val) {
                                  Provider.of<CheckboxToggleInfo>(context, listen: false)
                                      .updateCheckboxNotifier(val ?? true);
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            CustomTextWidget(
                              text: 'I understand the above statement',
                              style: TextStyle(
                                  height: 1.3,
                                  fontFamily: Constant.jostRegular,
                                  fontSize: 15,
                                  color: Constant.chatBubbleGreen),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: BouncingWidget(
                                onPressed: (!data.getCheckboxToggle()) ? (){} : () {
                                  _shouldSpeak = false;
                                  _isScreenExited = true;
                                  TextToSpeechRecognition.stopSpeech();
                                  Navigator.pushReplacementNamed(context,
                                      Constant.partTwoOnBoardScreenRouter,
                                      arguments: PartTwoOnBoardArgumentModel(
                                          argumentName: Constant
                                              .clinicalImpressionEventType,
                                      isFromMoreScreen: false,
                                      isFromHeadacheTypeScreen: true,
                                      fromScreenRouter: widget.fromScreenRouter));
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 13),
                                  decoration: BoxDecoration(
                                    color: (data.getCheckboxToggle()) ? Color(0xffafd794) : Colors.grey,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: CustomTextWidget(
                                      text: Constant.agreeAndContinue,
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
                    );
                  }),
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
    var userProfileInfoData =
    await SignUpOnBoardProviders.db.getLoggedInUserAllInformation();
    _userName = userProfileInfoData.profileName ?? '';
    Provider.of<UserNameInfo>(context, listen: false)
        .updateUserName(userProfileInfoData.profileName ?? '');
  }

  List<TextSpan> _buildTextData(String userName) {
    TextSpan bulletPoint = TextSpan(
        text: '•',
        style: TextStyle(
            height: 1.3,
            fontSize: 20,
            fontFamily: Constant.jostMedium,
            color: Constant.bubbleChatTextView));
    List<TextSpan> spannableTextViewList = [
      TextSpan(
          text: 'Disclaimer\n\n',
          style: TextStyle(
              height: 1.3,
              fontSize: 16,
              fontFamily: Constant.jostMedium,
              color: Constant.bubbleChatTextView)),
      TextSpan(children: [
        WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(left: _nextParaSpacingPixel),
              child: CustomRichTextWidget(
                text: TextSpan(children: [
                  bulletPoint,
                  TextSpan(
                      text:
                      ' The questionnaire you are about to complete is intended as a tool to help your physician or other qualified health professional make a diagnosis and create a treatment plan for you.\n',
                      style: TextStyle(
                        height: 1.3,
                        fontSize: 16,
                        fontFamily: Constant.jostRegular,
                        color: Constant.bubbleChatTextView,
                      ))
                ]),
              ),
            ))
      ]),
      TextSpan(children: [
        WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(left: _nextParaSpacingPixel),
              child: CustomRichTextWidget(
                text: TextSpan(children: [
                  bulletPoint,
                  TextSpan(
                      text:
                      ' Only a physician can make a diagnosis after taking a history and doing a medical and neurological examination and appropriate testing.\n',
                      style: TextStyle(
                        height: 1.3,
                        fontSize: 16,
                        fontFamily: Constant.jostRegular,
                        color: Constant.bubbleChatTextView,
                      ))
                ]),
              ),
            ))
      ]),
      TextSpan(children: [
        WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(left: _nextParaSpacingPixel),
              child: CustomRichTextWidget(
                text: TextSpan(children: [
                  bulletPoint,
                  TextSpan(
                      text:
                      ' The answers you give to the questions will be used to generate a clinical impression that should be taken to your physician or other qualified health professional for further evaluation, physical examination and any appropriate testing.\n',
                      style: TextStyle(
                        height: 1.3,
                        fontSize: 16,
                        fontFamily: Constant.jostRegular,
                        color: Constant.bubbleChatTextView,
                      ))
                ]),
              ),
            ))
      ]),
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

class CheckboxToggleInfo with ChangeNotifier {
  bool checkboxToggle = false;

  bool getCheckboxToggle() => checkboxToggle;

  void updateCheckboxNotifier(bool toggleValue) {
    checkboxToggle = toggleValue;
    notifyListeners();
  }
}