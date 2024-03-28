import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/blocs/PostClinicalImpressionBloc.dart';
import 'package:mobile/models/PostClinicalImpressionArgumentModel.dart';
import 'package:mobile/models/SignUpOnBoardSelectedAnswersModel.dart';
import 'package:mobile/util/PhotoHero.dart';
import 'package:mobile/util/TextToSpeechRecognition.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomRichTextWidget.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/Utils.dart';
import 'ChatBubbleRightPointed.dart';

class PostClinicalImpressionScreen extends StatefulWidget {
  final PostClinicalImpressionArgumentModel? postClinicalImpressionArgumentModel;

  const PostClinicalImpressionScreen(
      {Key? key, this.postClinicalImpressionArgumentModel})
      : super(key: key);

  @override
  _PostClinicalImpressionScreenState createState() =>
      _PostClinicalImpressionScreenState();
}

class _PostClinicalImpressionScreenState
    extends State<PostClinicalImpressionScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool isVolumeOn = false;
  late AnimationController _animationController;
  late ScrollController _scrollController;
  late PostClinicalImpressionBloc _bloc;
  bool _shouldSpeak = false;

  String _textToSpeechText = '';

  ///Method to toggle volume on or off
  void _toggleVolume() async {
    setState(() {
      isVolumeOn = !isVolumeOn;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constant.chatBubbleVolumeState, isVolumeOn);

    TextToSpeechRecognition.speechToText(_textToSpeechText);
  }

  List<TextSpan> _spannableTextViewList = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _bloc = PostClinicalImpressionBloc();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addObserver(this);
    _animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Utils.showApiLoaderDialog(context, networkStream: _bloc.networkDataStream,
          tapToRetryFunction: () {
            _bloc.networkDataSink.add(Constant.loading);
            _bloc.getClinicalImpressionOfHeadache(widget
                .postClinicalImpressionArgumentModel
                ?.signUpOnBoardSelectedAnswersModel ?? SignUpOnBoardSelectedAnswersModel());
          });
      _bloc.getClinicalImpressionOfHeadache(widget
          .postClinicalImpressionArgumentModel
          ?.signUpOnBoardSelectedAnswersModel ?? SignUpOnBoardSelectedAnswersModel());
    });
    setVolumeIcon();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      TextToSpeechRecognition.stopSpeech();
    } else if (state == AppLifecycleState.resumed) {
      if (isVolumeOn && _shouldSpeak) {
        TextToSpeechRecognition.speechToText(_textToSpeechText);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Container(
          decoration: Constant.backgroundBoxDecoration,
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: StreamBuilder<dynamic>(
                  stream: _bloc.clinicalImpressionStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data;

                      if (data is List<String>) {
                        _shouldSpeak = true;

                        bool isMigraine =
                        data.toString().toLowerCase().contains("migraine");

                        _saveIsMigraineValueOnSharedPref(isMigraine);

                        if (_shouldSpeak && isVolumeOn) {
                          //Text to speech
                          if (_textToSpeechText.isEmpty) {
                            _textToSpeechText = 'Based on the answers you provided, we would categorize your headache as ${isMigraine ? 'migraine:' : 'headache:'}\n${_getClinicalImpressionText(data)} \n\nIf you don\'t have a formal diagnosis for ${isMigraine ? 'migraine' : 'headache'}  or your previous diagnosis does not match our clinical impression, consider scheduling an appointment with your primary care provider or headache-specialist to discuss this assessment.\n\nOn the next screen, you can provide a name for this headache type ${isMigraine ? '(Migraine)' : '(Headache)'} or simply keep the name we have assigned.';
                            TextToSpeechRecognition.speechToText(
                                _textToSpeechText);
                          }
                        }

                        _spannableTextViewList = [
                          TextSpan(
                            text:
                            'Based on the answers you provided, we would categorize your headache as ',
                            style: TextStyle(
                              height: 1.3,
                              fontSize: 16,
                              fontFamily: Constant.jostRegular,
                              color: Constant.bubbleChatTextView,
                            ),
                          ),
                          TextSpan(
                            text: isMigraine ? 'migraine:' : 'headache:',
                            style: TextStyle(
                              height: 1.3,
                              fontSize: 16,
                              fontFamily: Constant.jostMedium,
                              color: Constant.bubbleChatTextView,
                            ),
                          ),
                          TextSpan(
                            children: [
                              WidgetSpan(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: CustomRichTextWidget(
                                    text: TextSpan(
                                      text: '${_getClinicalImpressionText(data)}',
                                      style: TextStyle(
                                        height: 1.3,
                                        fontSize: 16,
                                        fontFamily: Constant.jostRegular,
                                        color: Constant.bubbleChatTextView,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          TextSpan(
                              children: [
                                WidgetSpan(
                                  child: CustomRichTextWidget(
                                    text: TextSpan(
                                      text: '\nIf you don\'t have a formal diagnosis for ',
                                      style: TextStyle(
                                        height: 1.3,
                                        fontSize: 16,
                                        fontFamily: Constant.jostRegular,
                                        color: Constant.bubbleChatTextView,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: isMigraine ? 'migraine' : 'headache',
                                          style: TextStyle(
                                            height: 1.3,
                                            fontSize: 16,
                                            fontFamily: Constant.jostMedium,
                                            color: Constant.bubbleChatTextView,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                          ' or your previous diagnosis does not match our clinical impression, consider scheduling an appointment with your primary care provider or headache-specialist to discuss this assessment.\n\nOn the next screen, you can provide a name for this headache type ',
                                          style: TextStyle(
                                            height: 1.3,
                                            fontSize: 16,
                                            fontFamily: Constant.jostRegular,
                                            color: Constant.bubbleChatTextView,
                                          ),
                                        ),
                                        TextSpan(
                                          text: isMigraine ? '(Migraine)' : '(Headache)',
                                          style: TextStyle(
                                            height: 1.3,
                                            fontSize: 16,
                                            fontFamily: Constant.jostMedium,
                                            color: Constant.bubbleChatTextView,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' or simply keep the name we have assigned.',
                                          style: TextStyle(
                                            height: 1.3,
                                            fontSize: 16,
                                            fontFamily: Constant.jostRegular,
                                            color: Constant.bubbleChatTextView,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]
                          ),
                        ];
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
                                    ),
                                  ),
                                ),
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
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: 360,
                                          ),
                                          child: RawScrollbar(
                                            thickness: 5,
                                            radius: Radius.circular(5),
                                            thumbColor: Colors.black45,
                                            thumbVisibility: true,
                                            padding: const EdgeInsets.only(
                                                right: 4, top: 2, bottom: 2),
                                            controller: _scrollController,
                                            child: SingleChildScrollView(
                                              controller: _scrollController,
                                              child: Container(
                                                padding:
                                                const EdgeInsets.all(15.0),
                                                child: FadeTransition(
                                                  opacity: _animationController,
                                                  child: CustomRichTextWidget(
                                                    text: TextSpan(
                                                      children:
                                                      _spannableTextViewList,
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
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            BouncingWidget(
                              onPressed: () {
                                Navigator.pop(context, Constant.next);
                              },
                              child: Container(
                                padding:
                                EdgeInsets.symmetric(vertical: 13),
                                decoration: BoxDecoration(
                                  color: Constant.chatBubbleGreen,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: CustomTextWidget(
                                    text: Constant.next,
                                    style: TextStyle(
                                      color: Constant.bubbleChatTextView,
                                      fontSize: 15,
                                      fontFamily: Constant.jostMedium,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        );
                      } else {
                        return Container();
                      }
                    } else {
                      return Container();
                    }
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
    _bloc.dispose();
    super.dispose();
  }

  void setVolumeIcon() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isVolume = sharedPreferences.getBool(Constant.chatBubbleVolumeState) ?? false;
    setState(() {
      if (isVolume) {
        isVolumeOn = true;
      } else {
        isVolumeOn = false;
      }
    });
  }

  String _getClinicalImpressionText(List<String> data) {
    String text = '';

    data.asMap().forEach((index, element) {
      if (element.isEmpty)
        text = '\n${index + 1}. $element';
      else
        text = '$text\n${index + 1}. $element';
    });

    return text;
  }

  Future<void> _saveIsMigraineValueOnSharedPref(bool isMigraine) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool("isMigraine", isMigraine);
  }
}